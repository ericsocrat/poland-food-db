-- ══════════════════════════════════════════════════════════════════════════
-- Migration: Canonical Scoring Engine
-- Issue:     #189 — Versioned, Auditable, Multi-Country Scoring Layer
-- ══════════════════════════════════════════════════════════════════════════
--
-- Creates a scoring engine that wraps the existing compute_unhealthiness_v32()
-- function with version management, audit trail, shadow scoring,
-- multi-country parameterization, and monitoring infrastructure.
--
-- Core design:
--   • score_category() remains the batch pipeline entry point
--   • compute_score() is the new single-product canonical entry point
--   • v3.2 fast-path delegates directly to compute_unhealthiness_v32()
--   • Future versions use config-driven _compute_from_config()
--   • All score changes are audited via trigger
--   • Exactly one model version can be 'active' at any time
-- ══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ══════════════════════════════════════════════════════════════════════════
-- Section A: Scoring Model Version Registry
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.scoring_model_versions (
    id               serial       PRIMARY KEY,
    version          text         NOT NULL UNIQUE,
    status           text         NOT NULL DEFAULT 'draft',
    description      text,
    config           jsonb        NOT NULL,
    country_overrides jsonb       NOT NULL DEFAULT '{}',
    created_at       timestamptz  NOT NULL DEFAULT now(),
    activated_at     timestamptz,
    retired_at       timestamptz,
    created_by       text         NOT NULL DEFAULT current_user,

    CONSTRAINT smv_valid_status
        CHECK (status IN ('draft', 'active', 'shadow', 'retired')),
    -- Exactly one active version at any time
    CONSTRAINT smv_single_active
        EXCLUDE USING btree (status WITH =) WHERE (status = 'active')
);

CREATE INDEX idx_smv_status  ON public.scoring_model_versions (status);
CREATE INDEX idx_smv_version ON public.scoring_model_versions (version);

COMMENT ON TABLE  public.scoring_model_versions IS 'Registry of scoring model versions with JSON config and country overrides.';
COMMENT ON COLUMN public.scoring_model_versions.config IS 'Canonical factor definitions: weights, ceilings, categorical maps.';
COMMENT ON COLUMN public.scoring_model_versions.country_overrides IS 'Per-country config deltas merged over base config.';

-- Seed v3.2 as the active model (mirrors current compute_unhealthiness_v32)
INSERT INTO public.scoring_model_versions (version, status, description, config, activated_at)
VALUES (
    'v3.2', 'active',
    'Current 9-factor unhealthiness scoring with ingredient concern (2026-02-10)',
    '{
        "factors": [
            {"name": "saturated_fat", "weight": 0.17, "ceiling": 10.0, "unit": "g/100g", "column": "saturated_fat_g"},
            {"name": "sugars",        "weight": 0.17, "ceiling": 27.0, "unit": "g/100g", "column": "sugars_g"},
            {"name": "salt",          "weight": 0.17, "ceiling": 3.0,  "unit": "g/100g", "column": "salt_g"},
            {"name": "calories",      "weight": 0.10, "ceiling": 600,  "unit": "kcal/100g", "column": "calories"},
            {"name": "trans_fat",     "weight": 0.11, "ceiling": 2.0,  "unit": "g/100g", "column": "trans_fat_g"},
            {"name": "additives",     "weight": 0.07, "ceiling": 10,   "unit": "count",  "column": "_additives_count"},
            {"name": "prep_method",   "weight": 0.08, "type": "categorical", "map": {"air-popped": 20, "steamed": 30, "baked": 40, "grilled": 60, "smoked": 65, "fried": 80, "deep-fried": 100, "_default": 50}},
            {"name": "controversies", "weight": 0.08, "type": "categorical", "map": {"none": 0, "minor": 30, "palm oil": 40, "moderate": 60, "serious": 100, "_default": 0}},
            {"name": "ingredient_concern", "weight": 0.05, "ceiling": 100, "unit": "score", "column": "_concern_score"}
        ],
        "clamp_min": 1,
        "clamp_max": 100,
        "null_handling": "coalesce_zero"
    }'::jsonb,
    now()
);


-- ══════════════════════════════════════════════════════════════════════════
-- Section B: Add Scoring Metadata Columns to Products
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
    ADD COLUMN IF NOT EXISTS score_model_version text DEFAULT 'v3.2',
    ADD COLUMN IF NOT EXISTS scored_at           timestamptz DEFAULT now();

COMMENT ON COLUMN public.products.score_model_version IS 'Which scoring model version produced the current unhealthiness_score.';
COMMENT ON COLUMN public.products.scored_at           IS 'When the unhealthiness_score was last computed.';

-- Backfill existing products
UPDATE public.products
SET    score_model_version = 'v3.2',
       scored_at           = COALESCE(updated_at, created_at, now())
WHERE  unhealthiness_score IS NOT NULL
  AND  score_model_version IS NULL;


-- ══════════════════════════════════════════════════════════════════════════
-- Section C: Score Audit Log
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.score_audit_log (
    id            bigserial    PRIMARY KEY,
    product_id    bigint       NOT NULL,
    field_name    text         NOT NULL,
    old_value     text,
    new_value     text,
    model_version text         NOT NULL DEFAULT 'v3.2',
    country       text         NOT NULL DEFAULT 'PL',
    trigger_type  text         NOT NULL DEFAULT 'unknown',
    trigger_ref   text,
    changed_at    timestamptz  NOT NULL DEFAULT now(),
    changed_by    text         NOT NULL DEFAULT current_user
);

CREATE INDEX idx_sal_product   ON public.score_audit_log (product_id, changed_at DESC);
CREATE INDEX idx_sal_version   ON public.score_audit_log (model_version, changed_at DESC);
CREATE INDEX idx_sal_trigger   ON public.score_audit_log (trigger_type);
CREATE INDEX idx_sal_changed   ON public.score_audit_log (changed_at DESC);

ALTER TABLE public.score_audit_log ENABLE ROW LEVEL SECURITY;

-- Service role: full access
CREATE POLICY "sal_service_write"
    ON public.score_audit_log FOR ALL
    USING  (true)
    WITH CHECK (true);

-- Authenticated users: read-only
CREATE POLICY "sal_authenticated_read"
    ON public.score_audit_log FOR SELECT
    USING (true);

COMMENT ON TABLE public.score_audit_log IS 'Immutable audit trail logging every unhealthiness_score change.';

-- Audit trigger — fires on score changes in products
CREATE OR REPLACE FUNCTION public.trg_score_audit()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    IF OLD.unhealthiness_score IS DISTINCT FROM NEW.unhealthiness_score THEN
        INSERT INTO score_audit_log
            (product_id, field_name, old_value, new_value,
             model_version, country, trigger_type)
        VALUES (
            NEW.product_id,
            'unhealthiness_score',
            OLD.unhealthiness_score::text,
            NEW.unhealthiness_score::text,
            COALESCE(NEW.score_model_version, 'v3.2'),
            COALESCE(NEW.country, 'PL'),
            COALESCE(current_setting('app.score_trigger', true), 'pipeline')
        );
    END IF;
    RETURN NEW;
END;
$fn$;

CREATE TRIGGER score_change_audit
    AFTER UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION trg_score_audit();


-- ══════════════════════════════════════════════════════════════════════════
-- Section D: Shadow Scoring Table
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.score_shadow_results (
    id             bigserial    PRIMARY KEY,
    product_id     bigint       NOT NULL,
    model_version  text         NOT NULL,
    shadow_score   integer      NOT NULL,
    breakdown      jsonb,
    country        text         NOT NULL DEFAULT 'PL',
    computed_at    timestamptz  NOT NULL DEFAULT now(),

    CONSTRAINT ssr_unique_product_version
        UNIQUE (product_id, model_version)
);

CREATE INDEX idx_ssr_version ON public.score_shadow_results (model_version);

ALTER TABLE public.score_shadow_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ssr_service_all"
    ON public.score_shadow_results FOR ALL
    USING  (true)
    WITH CHECK (true);

COMMENT ON TABLE public.score_shadow_results IS 'Shadow scoring: run new model versions without affecting production.';


-- ══════════════════════════════════════════════════════════════════════════
-- Section E: Distribution Snapshot Table
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.score_distribution_snapshots (
    id                serial       PRIMARY KEY,
    snapshot_date     date         NOT NULL DEFAULT CURRENT_DATE,
    country           text         NOT NULL,
    category          text,
    model_version     text         NOT NULL,
    total_products    integer      NOT NULL,
    mean_score        numeric(5,2),
    median_score      numeric(5,2),
    stddev_score      numeric(5,2),
    p10_score         integer,
    p25_score         integer,
    p75_score         integer,
    p90_score         integer,
    band_distribution jsonb,
    created_at        timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX sds_unique_snapshot
    ON public.score_distribution_snapshots (snapshot_date, country, COALESCE(category, ''), model_version);

CREATE INDEX idx_sds_date ON public.score_distribution_snapshots (snapshot_date DESC);

ALTER TABLE public.score_distribution_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sds_service_all"
    ON public.score_distribution_snapshots FOR ALL
    USING  (true)
    WITH CHECK (true);

CREATE POLICY "sds_authenticated_read"
    ON public.score_distribution_snapshots FOR SELECT
    USING (true);

COMMENT ON TABLE public.score_distribution_snapshots IS 'Daily score distribution snapshots for drift detection.';


-- ══════════════════════════════════════════════════════════════════════════
-- Section F: Config-Driven Compute Helpers (for future versions)
-- ══════════════════════════════════════════════════════════════════════════

-- _compute_from_config: evaluates a product against a JSONB factor config.
-- Used by compute_score() for any version other than v3.2 (which uses the
-- native SQL function for bit-perfect backward compatibility).
CREATE OR REPLACE FUNCTION public._compute_from_config(
    p_product_id bigint,
    p_config     jsonb
)
RETURNS integer
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_factor         jsonb;
    v_weighted_sum   numeric := 0;
    v_raw            numeric;
    v_weight         numeric;
    v_ceiling        numeric;
    v_map            jsonb;
    v_lookup_key     text;
    v_nf             record;
    v_prod           record;
    v_additives      integer;
    v_clamp_min      integer;
    v_clamp_max      integer;
BEGIN
    -- Load nutrition data
    SELECT * INTO v_nf FROM nutrition_facts WHERE product_id = p_product_id;
    -- Load product data
    SELECT * INTO v_prod FROM products WHERE product_id = p_product_id;
    -- Additives count
    SELECT COUNT(*) FILTER (WHERE ir.is_additive)::int INTO v_additives
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p_product_id;

    v_clamp_min := COALESCE((p_config->>'clamp_min')::int, 1);
    v_clamp_max := COALESCE((p_config->>'clamp_max')::int, 100);

    -- Iterate factors
    FOR v_factor IN SELECT jsonb_array_elements(p_config->'factors')
    LOOP
        v_weight := (v_factor->>'weight')::numeric;

        IF v_factor->>'type' = 'categorical' THEN
            -- Categorical factor: lookup from map
            v_map := v_factor->'map';
            CASE v_factor->>'name'
                WHEN 'prep_method'   THEN v_lookup_key := v_prod.prep_method;
                WHEN 'controversies' THEN v_lookup_key := v_prod.controversies;
                ELSE v_lookup_key := NULL;
            END CASE;
            v_raw := COALESCE(
                (v_map->>v_lookup_key)::numeric,
                (v_map->>'_default')::numeric,
                0
            );
            v_weighted_sum := v_weighted_sum + (v_raw * v_weight);
        ELSE
            -- Numeric factor: (value / ceiling * 100) capped at 100
            v_ceiling := COALESCE((v_factor->>'ceiling')::numeric, 100);
            CASE v_factor->>'column'
                WHEN 'saturated_fat_g' THEN v_raw := v_nf.saturated_fat_g;
                WHEN 'sugars_g'        THEN v_raw := v_nf.sugars_g;
                WHEN 'salt_g'          THEN v_raw := v_nf.salt_g;
                WHEN 'calories'        THEN v_raw := v_nf.calories;
                WHEN 'trans_fat_g'     THEN v_raw := v_nf.trans_fat_g;
                WHEN '_additives_count' THEN v_raw := v_additives;
                WHEN '_concern_score'   THEN v_raw := v_prod.ingredient_concern_score;
                ELSE v_raw := 0;
            END CASE;
            v_raw := LEAST(100, COALESCE(v_raw, 0) / NULLIF(v_ceiling, 0) * 100);
            v_weighted_sum := v_weighted_sum + (v_raw * v_weight);
        END IF;
    END LOOP;

    RETURN GREATEST(v_clamp_min, LEAST(v_clamp_max, round(v_weighted_sum)))::integer;
END;
$fn$;

-- _explain_from_config: produces a JSONB breakdown matching explain_score_v32() shape.
CREATE OR REPLACE FUNCTION public._explain_from_config(
    p_product_id bigint,
    p_config     jsonb
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_factor         jsonb;
    v_factors_arr    jsonb := '[]'::jsonb;
    v_weighted_sum   numeric := 0;
    v_raw            numeric;
    v_input          numeric;
    v_weight         numeric;
    v_ceiling        numeric;
    v_weighted       numeric;
    v_map            jsonb;
    v_lookup_key     text;
    v_nf             record;
    v_prod           record;
    v_additives      integer;
    v_clamp_min      integer;
    v_clamp_max      integer;
BEGIN
    SELECT * INTO v_nf FROM nutrition_facts WHERE product_id = p_product_id;
    SELECT * INTO v_prod FROM products WHERE product_id = p_product_id;
    SELECT COUNT(*) FILTER (WHERE ir.is_additive)::int INTO v_additives
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p_product_id;

    v_clamp_min := COALESCE((p_config->>'clamp_min')::int, 1);
    v_clamp_max := COALESCE((p_config->>'clamp_max')::int, 100);

    FOR v_factor IN SELECT jsonb_array_elements(p_config->'factors')
    LOOP
        v_weight := (v_factor->>'weight')::numeric;

        IF v_factor->>'type' = 'categorical' THEN
            v_map := v_factor->'map';
            CASE v_factor->>'name'
                WHEN 'prep_method'   THEN v_lookup_key := v_prod.prep_method; v_input := NULL;
                WHEN 'controversies' THEN v_lookup_key := v_prod.controversies; v_input := NULL;
                ELSE v_lookup_key := NULL; v_input := NULL;
            END CASE;
            v_raw := COALESCE((v_map->>v_lookup_key)::numeric, (v_map->>'_default')::numeric, 0);
            v_ceiling := NULL;
            v_weighted := round(v_raw * v_weight, 2);
        ELSE
            v_ceiling := COALESCE((v_factor->>'ceiling')::numeric, 100);
            CASE v_factor->>'column'
                WHEN 'saturated_fat_g'  THEN v_input := v_nf.saturated_fat_g;
                WHEN 'sugars_g'         THEN v_input := v_nf.sugars_g;
                WHEN 'salt_g'           THEN v_input := v_nf.salt_g;
                WHEN 'calories'         THEN v_input := v_nf.calories;
                WHEN 'trans_fat_g'      THEN v_input := v_nf.trans_fat_g;
                WHEN '_additives_count' THEN v_input := v_additives;
                WHEN '_concern_score'   THEN v_input := v_prod.ingredient_concern_score;
                ELSE v_input := 0;
            END CASE;
            v_raw := LEAST(100, COALESCE(v_input, 0) / NULLIF(v_ceiling, 0) * 100);
            v_weighted := round(v_raw * v_weight, 2);
        END IF;

        v_weighted_sum := v_weighted_sum + v_weighted;
        v_factors_arr := v_factors_arr || jsonb_build_object(
            'name',     v_factor->>'name',
            'weight',   v_weight,
            'raw',      round(v_raw, 2),
            'weighted', v_weighted,
            'input',    v_input,
            'ceiling',  v_ceiling
        );
    END LOOP;

    RETURN jsonb_build_object(
        'version',     'config-driven',
        'final_score', GREATEST(v_clamp_min, LEAST(v_clamp_max, round(v_weighted_sum)))::integer,
        'factors',     v_factors_arr
    );
END;
$fn$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section G: compute_score() — Canonical Single-Product Entry Point
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_score(
    p_product_id  bigint,
    p_version     text    DEFAULT NULL,   -- NULL = active version
    p_country     text    DEFAULT NULL,   -- NULL = product's own country
    p_mode        text    DEFAULT 'apply' -- 'apply', 'dry_run', 'shadow'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_version_rec  record;
    v_config       jsonb;
    v_country      text;
    v_old_score    integer;
    v_new_score    integer;
    v_breakdown    jsonb;
    v_nf           record;
    v_additives    integer;
    v_prod         record;
BEGIN
    -- 1. Resolve model version
    IF p_version IS NULL THEN
        SELECT * INTO v_version_rec
        FROM scoring_model_versions WHERE status = 'active';
    ELSE
        SELECT * INTO v_version_rec
        FROM scoring_model_versions WHERE version = p_version;
    END IF;

    IF v_version_rec IS NULL THEN
        RAISE EXCEPTION 'Scoring version not found: %',
            COALESCE(p_version, '(active)');
    END IF;

    -- 2. Load product + resolve country
    SELECT * INTO v_prod FROM products WHERE product_id = p_product_id;
    IF v_prod IS NULL THEN
        RAISE EXCEPTION 'Product not found: %', p_product_id;
    END IF;
    v_country := COALESCE(p_country, v_prod.country, 'PL');

    -- 3. Apply country overrides to config
    v_config := v_version_rec.config;
    IF v_version_rec.country_overrides ? v_country
       AND v_version_rec.country_overrides->v_country != 'null'::jsonb THEN
        v_config := v_config || (v_version_rec.country_overrides->v_country);
    END IF;

    -- 4. Compute score — v3.2 fast path uses native function
    IF v_version_rec.version = 'v3.2' THEN
        -- Load nutrition
        SELECT * INTO v_nf FROM nutrition_facts WHERE product_id = p_product_id;
        -- Additives count
        SELECT COUNT(*) FILTER (WHERE ir.is_additive)::int INTO v_additives
        FROM product_ingredient pi
        JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        WHERE pi.product_id = p_product_id;

        v_new_score := compute_unhealthiness_v32(
            v_nf.saturated_fat_g,
            v_nf.sugars_g,
            v_nf.salt_g,
            v_nf.calories,
            v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method,
            v_prod.controversies,
            COALESCE(v_prod.ingredient_concern_score, 0)
        );
        v_breakdown := explain_score_v32(
            v_nf.saturated_fat_g,
            v_nf.sugars_g,
            v_nf.salt_g,
            v_nf.calories,
            v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method,
            v_prod.controversies,
            COALESCE(v_prod.ingredient_concern_score, 0)
        );
    ELSE
        -- Future versions: config-driven engine
        v_new_score := _compute_from_config(p_product_id, v_config);
        v_breakdown := _explain_from_config(p_product_id, v_config);
    END IF;

    -- 5. Record old score for comparison
    v_old_score := v_prod.unhealthiness_score;

    -- 6. Apply based on mode
    IF p_mode = 'apply' THEN
        PERFORM set_config('app.score_trigger', 'compute_score', true);
        UPDATE products
        SET    unhealthiness_score = v_new_score,
               score_model_version = v_version_rec.version,
               scored_at           = now()
        WHERE  product_id = p_product_id;

    ELSIF p_mode = 'shadow' THEN
        INSERT INTO score_shadow_results
            (product_id, model_version, shadow_score, breakdown, country, computed_at)
        VALUES
            (p_product_id, v_version_rec.version, v_new_score, v_breakdown, v_country, now())
        ON CONFLICT (product_id, model_version)
        DO UPDATE SET
            shadow_score = EXCLUDED.shadow_score,
            breakdown    = EXCLUDED.breakdown,
            country      = EXCLUDED.country,
            computed_at  = EXCLUDED.computed_at;
    END IF;
    -- mode = 'dry_run' → no side effects

    -- 7. Return result
    RETURN jsonb_build_object(
        'product_id',      p_product_id,
        'score',           v_new_score,
        'previous_score',  v_old_score,
        'version',         v_version_rec.version,
        'country',         v_country,
        'mode',            p_mode,
        'breakdown',       v_breakdown,
        'changed',         (v_new_score IS DISTINCT FROM v_old_score)
    );
END;
$fn$;

COMMENT ON FUNCTION public.compute_score IS
    'Canonical scoring entry point. Modes: apply (persist), dry_run (preview), shadow (A/B test).';


-- ══════════════════════════════════════════════════════════════════════════
-- Section H: rescore_batch() — Batch Re-Scoring
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.rescore_batch(
    p_version     text    DEFAULT NULL,
    p_country     text    DEFAULT NULL,
    p_category    text    DEFAULT NULL,
    p_mode        text    DEFAULT 'dry_run',
    p_batch_size  integer DEFAULT 1000
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_count    integer := 0;
    v_changed  integer := 0;
    v_result   jsonb;
    v_pid      bigint;
BEGIN
    FOR v_pid IN
        SELECT p.product_id
        FROM products p
        WHERE (p_country IS NULL  OR p.country  = p_country)
          AND (p_category IS NULL OR p.category = p_category)
          AND p.is_deprecated IS NOT TRUE
        ORDER BY p.product_id
        LIMIT p_batch_size
    LOOP
        v_result := compute_score(v_pid, p_version, p_country, p_mode);
        v_count := v_count + 1;
        IF (v_result->>'changed')::boolean THEN
            v_changed := v_changed + 1;
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'total_processed', v_count,
        'scores_changed',  v_changed,
        'version',         COALESCE(p_version, '(active)'),
        'country',         COALESCE(p_country, '(all)'),
        'category',        COALESCE(p_category, '(all)'),
        'mode',            p_mode
    );
END;
$fn$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section I: Country Profile Validation
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.validate_country_profile(
    p_version text,
    p_country text
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_rec          record;
    v_config       jsonb;
    v_total_weight numeric := 0;
    v_factor_count integer := 0;
    v_factor       jsonb;
    v_issues       text[] := '{}';
BEGIN
    SELECT * INTO v_rec FROM scoring_model_versions WHERE version = p_version;
    IF v_rec IS NULL THEN
        RETURN jsonb_build_object('valid', false, 'error', 'Version not found: ' || p_version);
    END IF;

    -- Merge base + country override
    v_config := v_rec.config;
    IF v_rec.country_overrides ? p_country THEN
        v_config := v_config || (v_rec.country_overrides->p_country);
    END IF;

    -- Validate factors
    FOR v_factor IN SELECT jsonb_array_elements(v_config->'factors')
    LOOP
        v_factor_count := v_factor_count + 1;
        v_total_weight := v_total_weight + (v_factor->>'weight')::numeric;

        IF (v_factor->>'weight')::numeric <= 0 THEN
            v_issues := array_append(v_issues,
                'Factor ' || (v_factor->>'name') || ' has non-positive weight');
        END IF;

        IF v_factor->>'type' != 'categorical'
           AND v_factor ? 'ceiling'
           AND (v_factor->>'ceiling')::numeric <= 0 THEN
            v_issues := array_append(v_issues,
                'Factor ' || (v_factor->>'name') || ' has non-positive ceiling');
        END IF;
    END LOOP;

    IF ABS(v_total_weight - 1.0) >= 0.01 THEN
        v_issues := array_append(v_issues,
            'Weight sum = ' || round(v_total_weight, 4) || ' (expected 1.0 ±0.01)');
    END IF;

    RETURN jsonb_build_object(
        'valid',        array_length(v_issues, 1) IS NULL,
        'total_weight', round(v_total_weight, 4),
        'factor_count', v_factor_count,
        'version',      p_version,
        'country',      p_country,
        'issues',       to_jsonb(v_issues)
    );
END;
$fn$;


-- Seed country overrides for future expansion (DE, CZ)
UPDATE public.scoring_model_versions
SET country_overrides = '{
    "DE": {"factor_overrides": [
        {"name": "sugars",   "weight": 0.18, "ceiling": 22.0},
        {"name": "salt",     "weight": 0.18, "ceiling": 2.0}
    ]},
    "CZ": {"factor_overrides": [
        {"name": "trans_fat", "weight": 0.14, "ceiling": 1.5}
    ]}
}'::jsonb
WHERE version = 'v3.2';


-- ══════════════════════════════════════════════════════════════════════════
-- Section J: Monitoring — Distribution Capture + Drift Detection
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.capture_score_distribution()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_rows integer;
BEGIN
    INSERT INTO score_distribution_snapshots
        (snapshot_date, country, category, model_version, total_products,
         mean_score, median_score, stddev_score,
         p10_score, p25_score, p75_score, p90_score,
         band_distribution)
    SELECT
        CURRENT_DATE,
        p.country,
        p.category,
        COALESCE(p.score_model_version, 'v3.2'),
        COUNT(*)::int,
        ROUND(AVG(p.unhealthiness_score), 2),
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.unhealthiness_score)::numeric(5,2),
        ROUND(STDDEV(p.unhealthiness_score), 2),
        PERCENTILE_CONT(0.1)  WITHIN GROUP (ORDER BY p.unhealthiness_score)::integer,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY p.unhealthiness_score)::integer,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY p.unhealthiness_score)::integer,
        PERCENTILE_CONT(0.9)  WITHIN GROUP (ORDER BY p.unhealthiness_score)::integer,
        jsonb_build_object(
            '1-20',   COUNT(*) FILTER (WHERE p.unhealthiness_score BETWEEN 1 AND 20),
            '21-40',  COUNT(*) FILTER (WHERE p.unhealthiness_score BETWEEN 21 AND 40),
            '41-60',  COUNT(*) FILTER (WHERE p.unhealthiness_score BETWEEN 41 AND 60),
            '61-80',  COUNT(*) FILTER (WHERE p.unhealthiness_score BETWEEN 61 AND 80),
            '81-100', COUNT(*) FILTER (WHERE p.unhealthiness_score BETWEEN 81 AND 100)
        )
    FROM products p
    WHERE p.unhealthiness_score IS NOT NULL
      AND p.is_deprecated IS NOT TRUE
    GROUP BY p.country, p.category, p.score_model_version
    ON CONFLICT (snapshot_date, country, COALESCE(category, ''), model_version)
    DO UPDATE SET
        total_products    = EXCLUDED.total_products,
        mean_score        = EXCLUDED.mean_score,
        median_score      = EXCLUDED.median_score,
        stddev_score      = EXCLUDED.stddev_score,
        p10_score         = EXCLUDED.p10_score,
        p25_score         = EXCLUDED.p25_score,
        p75_score         = EXCLUDED.p75_score,
        p90_score         = EXCLUDED.p90_score,
        band_distribution = EXCLUDED.band_distribution;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$fn$;


CREATE OR REPLACE FUNCTION public.detect_score_drift(
    p_threshold_pct numeric DEFAULT 10.0
)
RETURNS TABLE(
    country       text,
    category      text,
    metric        text,
    prev_val      numeric,
    curr_val      numeric,
    drift_pct     numeric
)
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    RETURN QUERY
    -- Mean score drift
    SELECT
        t.country,
        t.category,
        'mean_score'::text AS metric,
        y.mean_score       AS prev_val,
        t.mean_score       AS curr_val,
        ROUND(ABS(t.mean_score - y.mean_score)
              / NULLIF(y.mean_score, 0) * 100, 2) AS drift_pct
    FROM score_distribution_snapshots t
    JOIN score_distribution_snapshots y
        ON  y.country   = t.country
        AND COALESCE(y.category, '') = COALESCE(t.category, '')
        AND y.model_version = t.model_version
        AND y.snapshot_date = t.snapshot_date - 1
    WHERE t.snapshot_date = CURRENT_DATE
      AND ABS(t.mean_score - y.mean_score)
          / NULLIF(y.mean_score, 0) * 100 > p_threshold_pct

    UNION ALL

    -- Stddev drift
    SELECT
        t.country,
        t.category,
        'stddev_score'::text,
        y.stddev_score,
        t.stddev_score,
        ROUND(ABS(t.stddev_score - y.stddev_score)
              / NULLIF(y.stddev_score, 0) * 100, 2)
    FROM score_distribution_snapshots t
    JOIN score_distribution_snapshots y
        ON  y.country   = t.country
        AND COALESCE(y.category, '') = COALESCE(t.category, '')
        AND y.model_version = t.model_version
        AND y.snapshot_date = t.snapshot_date - 1
    WHERE t.snapshot_date = CURRENT_DATE
      AND y.stddev_score > 0
      AND ABS(t.stddev_score - y.stddev_score)
          / y.stddev_score * 100 > p_threshold_pct;
END;
$fn$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section K: Admin RPCs
-- ══════════════════════════════════════════════════════════════════════════

-- admin_scoring_versions: list all versions + stats
CREATE OR REPLACE FUNCTION public.admin_scoring_versions()
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(row_to_jsonb(v) ORDER BY v.id), '[]'::jsonb)
        FROM (
            SELECT
                smv.id,
                smv.version,
                smv.status,
                smv.description,
                smv.created_at,
                smv.activated_at,
                smv.retired_at,
                smv.created_by,
                (SELECT COUNT(*)::int FROM products p
                 WHERE p.score_model_version = smv.version
                   AND p.is_deprecated IS NOT TRUE) AS product_count,
                (SELECT COUNT(*)::int FROM score_shadow_results ssr
                 WHERE ssr.model_version = smv.version) AS shadow_count
            FROM scoring_model_versions smv
        ) v
    );
END;
$fn$;


-- admin_activate_scoring_version: promote a version to active
CREATE OR REPLACE FUNCTION public.admin_activate_scoring_version(
    p_version text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_target   record;
    v_current  record;
BEGIN
    SELECT * INTO v_target FROM scoring_model_versions WHERE version = p_version;
    IF v_target IS NULL THEN
        RAISE EXCEPTION 'Version not found: %', p_version;
    END IF;
    IF v_target.status = 'active' THEN
        RETURN jsonb_build_object('ok', true, 'message', 'Already active', 'version', p_version);
    END IF;
    IF v_target.status = 'retired' THEN
        RAISE EXCEPTION 'Cannot activate retired version: %', p_version;
    END IF;

    -- Retire current active
    SELECT * INTO v_current FROM scoring_model_versions WHERE status = 'active';
    IF v_current IS NOT NULL THEN
        UPDATE scoring_model_versions
        SET status = 'retired', retired_at = now()
        WHERE id = v_current.id;
    END IF;

    -- Activate target
    UPDATE scoring_model_versions
    SET status = 'active', activated_at = now()
    WHERE id = v_target.id;

    RETURN jsonb_build_object(
        'ok',       true,
        'activated', p_version,
        'retired',   v_current.version
    );
END;
$fn$;


-- admin_rescore_batch: wrapper for rescore_batch with input validation
CREATE OR REPLACE FUNCTION public.admin_rescore_batch(
    p_version    text    DEFAULT NULL,
    p_country    text    DEFAULT NULL,
    p_category   text    DEFAULT NULL,
    p_mode       text    DEFAULT 'dry_run',
    p_batch_size integer DEFAULT 1000
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    IF p_mode NOT IN ('apply', 'dry_run', 'shadow') THEN
        RAISE EXCEPTION 'Invalid mode: %. Use apply, dry_run, or shadow.', p_mode;
    END IF;
    IF p_batch_size < 1 OR p_batch_size > 50000 THEN
        RAISE EXCEPTION 'batch_size must be 1–50000, got %', p_batch_size;
    END IF;

    RETURN rescore_batch(p_version, p_country, p_category, p_mode, p_batch_size);
END;
$fn$;


-- admin_score_drift_report
CREATE OR REPLACE FUNCTION public.admin_score_drift_report(
    p_threshold_pct numeric DEFAULT 10.0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_drifts  jsonb;
    v_latest  date;
BEGIN
    SELECT MAX(snapshot_date) INTO v_latest FROM score_distribution_snapshots;

    SELECT COALESCE(jsonb_agg(row_to_jsonb(d)), '[]'::jsonb) INTO v_drifts
    FROM detect_score_drift(p_threshold_pct) d;

    RETURN jsonb_build_object(
        'latest_snapshot',  v_latest,
        'threshold_pct',    p_threshold_pct,
        'drift_count',      jsonb_array_length(v_drifts),
        'drifts',           v_drifts
    );
END;
$fn$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section L: Public API — Score History
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_score_history(
    p_product_id bigint,
    p_limit      integer DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    RETURN jsonb_build_object(
        'api_version',  '1.0',
        'product_id',   p_product_id,
        'history', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'old_score',     sal.old_value,
                'new_score',     sal.new_value,
                'model_version', sal.model_version,
                'trigger_type',  sal.trigger_type,
                'changed_at',    sal.changed_at
            ) ORDER BY sal.changed_at DESC), '[]'::jsonb)
            FROM score_audit_log sal
            WHERE sal.product_id = p_product_id
              AND sal.field_name = 'unhealthiness_score'
            LIMIT p_limit
        )
    );
END;
$fn$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section M: Wire score_category() to Record Metadata
-- ══════════════════════════════════════════════════════════════════════════

-- Re-create score_category() with score_model_version + scored_at tracking.
-- NOTE: preserves the batch UPDATE path for performance — does NOT
-- loop via compute_score(). The audit trigger handles logging.
CREATE OR REPLACE PROCEDURE public.score_category(
    p_category          text,
    p_data_completeness integer DEFAULT 100,
    p_country           text    DEFAULT 'PL'
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Set trigger context for audit trail
    PERFORM set_config('app.score_trigger', 'score_category', true);

    -- 0. DEFAULT concern score for products without ingredient data
    UPDATE products
    SET    ingredient_concern_score = 0
    WHERE  country = p_country
      AND  category = p_category
      AND  is_deprecated IS NOT TRUE
      AND  ingredient_concern_score IS NULL;

    -- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors) + metadata
    UPDATE products p
    SET    unhealthiness_score = compute_unhealthiness_v32(
               nf.saturated_fat_g,
               nf.sugars_g,
               nf.salt_g,
               nf.calories,
               nf.trans_fat_g,
               ia.additives_count,
               p.prep_method,
               p.controversies,
               p.ingredient_concern_score
           ),
           score_model_version = 'v3.2',
           scored_at = now()
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 4. Health-risk flags + DYNAMIC data_completeness_pct
    UPDATE products p
    SET    high_salt_flag    = CASE WHEN nf.salt_g >= 1.5 THEN 'YES' ELSE 'NO' END,
           high_sugar_flag   = CASE WHEN nf.sugars_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_sat_fat_flag = CASE WHEN nf.saturated_fat_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_additive_load = CASE WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END,
           data_completeness_pct = compute_data_completeness(p.product_id)
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 5. SET confidence level
    UPDATE products p
    SET    confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
    WHERE  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 6. AUTO-REFRESH materialized views
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
END;
$procedure$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section N: Update api_score_explanation() with Scoring Metadata
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_score_explanation(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'product_id',      m.product_id,
        'product_name',    m.product_name,
        'brand',           m.brand,
        'category',        m.category,
        'score_breakdown', m.score_breakdown,
        'model_version',   pp.score_model_version,
        'scored_at',       pp.scored_at,
        'summary', jsonb_build_object(
            'score',       m.unhealthiness_score,
            'score_band',  CASE
                             WHEN m.unhealthiness_score <= 25 THEN 'low'
                             WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                             WHEN m.unhealthiness_score <= 75 THEN 'high'
                             ELSE 'very_high'
                           END,
            'headline',    CASE
                             WHEN m.unhealthiness_score <= 15 THEN
                                 'This product scores very well. It has low levels of nutrients of concern.'
                             WHEN m.unhealthiness_score <= 30 THEN
                                 'This product has a moderate profile. Some areas could be better.'
                             WHEN m.unhealthiness_score <= 50 THEN
                                 'This product has several areas of nutritional concern.'
                             ELSE
                                 'This product has significant nutritional concerns across multiple factors.'
                           END,
            'nutri_score',    m.nutri_score_label,
            'nova_group',     m.nova_classification,
            'processing_risk',m.processing_risk
        ),
        'top_factors', (
            SELECT jsonb_agg(f ORDER BY (f->>'weighted')::numeric DESC)
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS f
            WHERE (f->>'weighted')::numeric > 0
        ),
        'warnings', (
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'message', 'Salt content exceeds 1.5g per 100g.')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'message', 'Sugar content is elevated.')             WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'message', 'Saturated fat content is elevated.')     WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'message', 'This product has a high additive load.') WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'message', 'Contains palm oil.')                     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'message', 'Classified as ultra-processed (NOVA 4).') WHERE m.nova_classification = '4'
            ) warnings
        ),
        'category_context', (
            SELECT jsonb_build_object(
                'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
                'category_rank',      (
                    SELECT COUNT(*) + 1
                    FROM v_master m2
                    WHERE m2.category = m.category
                      AND m2.country = m.country
                      AND m2.unhealthiness_score < m.unhealthiness_score
                ),
                'category_total',     COUNT(*)::int,
                'relative_position',  CASE
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score)       THEN 'better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                    ELSE 'much_worse_than_average'
                END
            )
            FROM products p2
            WHERE p2.category = m.category
              AND p2.country = m.country
              AND p2.is_deprecated IS NOT TRUE
        )
    )
    FROM v_master m
    JOIN products pp ON pp.product_id = m.product_id
    WHERE m.product_id = p_product_id;
$function$;


-- ══════════════════════════════════════════════════════════════════════════
-- Section O: Grants
-- ══════════════════════════════════════════════════════════════════════════

-- Tables
GRANT SELECT ON public.scoring_model_versions      TO anon, authenticated, service_role;
GRANT ALL    ON public.scoring_model_versions      TO service_role;

GRANT SELECT ON public.score_audit_log             TO authenticated, service_role;
GRANT INSERT ON public.score_audit_log             TO service_role;

GRANT ALL    ON public.score_shadow_results        TO service_role;
GRANT SELECT ON public.score_shadow_results        TO authenticated;

GRANT ALL    ON public.score_distribution_snapshots TO service_role;
GRANT SELECT ON public.score_distribution_snapshots TO authenticated;

-- Sequences (for INSERT)
GRANT USAGE ON SEQUENCE public.scoring_model_versions_id_seq      TO service_role;
GRANT USAGE ON SEQUENCE public.score_audit_log_id_seq             TO service_role;
GRANT USAGE ON SEQUENCE public.score_shadow_results_id_seq        TO service_role;
GRANT USAGE ON SEQUENCE public.score_distribution_snapshots_id_seq TO service_role;

-- Functions: revoke default PUBLIC access, then grant explicitly
REVOKE EXECUTE ON FUNCTION public.compute_score                    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.rescore_batch                    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.validate_country_profile         FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.capture_score_distribution       FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.detect_score_drift               FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.admin_scoring_versions           FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.admin_activate_scoring_version   FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.admin_rescore_batch              FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.admin_score_drift_report         FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_score_history                FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public._compute_from_config             FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public._explain_from_config             FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.compute_score                    TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.rescore_batch                    TO service_role;
GRANT EXECUTE ON FUNCTION public.validate_country_profile         TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.capture_score_distribution       TO service_role;
GRANT EXECUTE ON FUNCTION public.detect_score_drift               TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_scoring_versions           TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_activate_scoring_version   TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_rescore_batch              TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_score_drift_report         TO service_role;
GRANT EXECUTE ON FUNCTION public.api_score_history                TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public._compute_from_config             TO service_role;
GRANT EXECUTE ON FUNCTION public._explain_from_config             TO service_role;


-- ══════════════════════════════════════════════════════════════════════════
-- Section P: Verification
-- ══════════════════════════════════════════════════════════════════════════

-- Verify: exactly one active version
DO $verify$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM scoring_model_versions WHERE status = 'active';
    IF v_count != 1 THEN
        RAISE EXCEPTION 'Expected 1 active version, found %', v_count;
    END IF;
END
$verify$;

-- Verify: v3.2 config has 9 factors summing to ~1.0
DO $verify$
DECLARE
    v_sum numeric;
    v_cnt integer;
BEGIN
    SELECT
        SUM((f->>'weight')::numeric),
        COUNT(*)
    INTO v_sum, v_cnt
    FROM scoring_model_versions smv,
         jsonb_array_elements(smv.config->'factors') f
    WHERE smv.version = 'v3.2';

    IF v_cnt != 9 THEN
        RAISE EXCEPTION 'v3.2 should have 9 factors, found %', v_cnt;
    END IF;
    IF ABS(v_sum - 1.0) >= 0.01 THEN
        RAISE EXCEPTION 'v3.2 weights sum to %, expected 1.0', v_sum;
    END IF;
END
$verify$;

COMMIT;

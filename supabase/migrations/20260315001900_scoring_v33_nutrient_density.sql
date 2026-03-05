-- Migration: Scoring v3.3 — Nutrient Density Bonus (protein + fibre credit)
-- Issue: #608
-- Date: 2026-03-15
--
-- Problem: v3.2 has 9 penalty factors (all measuring unhealthy attributes).
-- No credit for nutritious attributes like protein and fibre. A yogurt with
-- 15g protein scores the same as one with 2g if unhealthy factors are equal.
--
-- Solution: Add a 10th factor — nutrient_density_bonus — that REDUCES the
-- unhealthiness score for protein-/fibre-rich products.
--
--   Weight: -0.08 (negative = subtracts from penalty total)
--   Raw input: protein_bonus + fibre_bonus (0-100 scale)
--   Max reduction: 100 * 0.08 = 8 points
--
-- Protein bonus tiers (per 100g):
--   >= 20g → 50, 15-20g → 40, 10-15g → 30, 5-10g → 15, <5g → 0
--
-- Fibre bonus tiers (per 100g):
--   >= 8g → 50, 5-8g → 35, 3-5g → 20, 1-3g → 10, <1g → 0
--
-- The 9 penalty weights remain unchanged (sum to 1.00). The bonus is
-- subtracted: GREATEST(1, LEAST(100, round(penalty_sum - bonus * 0.08)))
--
-- Rollback: Restore compute_unhealthiness_v32() calls in score_category()
--           and compute_score(); retire v3.3 in scoring_model_versions;
--           re-activate v3.2; re-score all categories.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. compute_unhealthiness_v33() — 11 params (9 penalty + 2 bonus)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_unhealthiness_v33(
    p_saturated_fat_g  numeric,
    p_sugars_g         numeric,
    p_salt_g           numeric,
    p_calories         numeric,
    p_trans_fat_g      numeric,
    p_additives_count  numeric,
    p_prep_method      text,
    p_controversies    text,
    p_concern_score    numeric,
    p_protein_g        numeric,
    p_fibre_g          numeric
)
RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
    SELECT GREATEST(1, LEAST(100, round(
        -- ── 9 penalty factors (unchanged from v3.2, weights sum to 1.00) ──
        LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) * 0.17 +
        LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) * 0.10 +
        LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) * 0.11 +
        LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) * 0.07 +
        (CASE p_prep_method
           WHEN 'air-popped'  THEN 20
           WHEN 'steamed'     THEN 30
           WHEN 'baked'       THEN 40
           WHEN 'grilled'     THEN 60
           WHEN 'smoked'      THEN 65
           WHEN 'fried'       THEN 80
           WHEN 'deep-fried'  THEN 100
           ELSE 50
         END) * 0.08 +
        (CASE p_controversies
           WHEN 'none'      THEN 0
           WHEN 'minor'     THEN 30
           WHEN 'palm oil'  THEN 40
           WHEN 'moderate'  THEN 60
           WHEN 'serious'   THEN 100
           ELSE 0
         END) * 0.08 +
        LEAST(100, COALESCE(p_concern_score, 0)) * 0.05
        -- ── 10th factor: nutrient density BONUS (subtracted) ──
        - LEAST(100,
            -- Protein bonus tiers
            (CASE
               WHEN COALESCE(p_protein_g, 0) >= 20 THEN 50
               WHEN COALESCE(p_protein_g, 0) >= 15 THEN 40
               WHEN COALESCE(p_protein_g, 0) >= 10 THEN 30
               WHEN COALESCE(p_protein_g, 0) >= 5  THEN 15
               ELSE 0
             END) +
            -- Fibre bonus tiers
            (CASE
               WHEN COALESCE(p_fibre_g, 0) >= 8 THEN 50
               WHEN COALESCE(p_fibre_g, 0) >= 5 THEN 35
               WHEN COALESCE(p_fibre_g, 0) >= 3 THEN 20
               WHEN COALESCE(p_fibre_g, 0) >= 1 THEN 10
               ELSE 0
             END)
          ) * 0.08
    )))::integer;
$$;

COMMENT ON FUNCTION public.compute_unhealthiness_v33 IS
    'v3.3 unhealthiness score: 9 penalty factors (sum 1.00) minus nutrient density bonus (protein + fibre, weight -0.08). Returns integer [1,100]. Issue #608.';

-- Grant same permissions as v3.2
GRANT EXECUTE ON FUNCTION public.compute_unhealthiness_v33 TO authenticated, service_role, anon;


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. explain_score_v33() — JSONB breakdown with 10 factors
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.explain_score_v33(
    p_saturated_fat_g  numeric,
    p_sugars_g         numeric,
    p_salt_g           numeric,
    p_calories         numeric,
    p_trans_fat_g      numeric,
    p_additives_count  numeric,
    p_prep_method      text,
    p_controversies    text,
    p_concern_score    numeric,
    p_protein_g        numeric,
    p_fibre_g          numeric
)
RETURNS jsonb
LANGUAGE sql IMMUTABLE AS $$
    WITH factors AS (
        SELECT
            -- Raw sub-scores (0-100 scale before weighting)
            LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) AS sat_fat_raw,
            LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) AS sugars_raw,
            LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) AS salt_raw,
            LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) AS calories_raw,
            LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) AS trans_fat_raw,
            LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) AS additives_raw,
            (CASE p_prep_method
               WHEN 'air-popped'  THEN 20
               WHEN 'steamed'     THEN 30
               WHEN 'baked'       THEN 40
               WHEN 'grilled'     THEN 60
               WHEN 'smoked'      THEN 65
               WHEN 'fried'       THEN 80
               WHEN 'deep-fried'  THEN 100
               ELSE 50
             END)::numeric AS prep_raw,
            (CASE p_controversies
               WHEN 'none'      THEN 0
               WHEN 'minor'     THEN 30
               WHEN 'palm oil'  THEN 40
               WHEN 'moderate'  THEN 60
               WHEN 'serious'   THEN 100
               ELSE 0
             END)::numeric AS controversies_raw,
            LEAST(100, COALESCE(p_concern_score, 0)) AS concern_raw,
            -- Nutrient density bonus raw
            LEAST(100,
                (CASE
                   WHEN COALESCE(p_protein_g, 0) >= 20 THEN 50
                   WHEN COALESCE(p_protein_g, 0) >= 15 THEN 40
                   WHEN COALESCE(p_protein_g, 0) >= 10 THEN 30
                   WHEN COALESCE(p_protein_g, 0) >= 5  THEN 15
                   ELSE 0
                 END) +
                (CASE
                   WHEN COALESCE(p_fibre_g, 0) >= 8 THEN 50
                   WHEN COALESCE(p_fibre_g, 0) >= 5 THEN 35
                   WHEN COALESCE(p_fibre_g, 0) >= 3 THEN 20
                   WHEN COALESCE(p_fibre_g, 0) >= 1 THEN 10
                   ELSE 0
                 END)
            )::numeric AS nutrient_density_raw
    )
    SELECT jsonb_build_object(
        'version', 'v3.3',
        'final_score', GREATEST(1, LEAST(100, round(
            sat_fat_raw * 0.17 + sugars_raw * 0.17 + salt_raw * 0.17 +
            calories_raw * 0.10 + trans_fat_raw * 0.11 + additives_raw * 0.07 +
            prep_raw * 0.08 + controversies_raw * 0.08 + concern_raw * 0.05
            - nutrient_density_raw * 0.08
        )))::integer,
        'factors', jsonb_build_array(
            jsonb_build_object('name', 'saturated_fat',    'weight',  0.17, 'raw', round(sat_fat_raw, 1),
                'weighted', round(sat_fat_raw * 0.17, 2), 'input', p_saturated_fat_g, 'ceiling', 10.0),
            jsonb_build_object('name', 'sugars',           'weight',  0.17, 'raw', round(sugars_raw, 1),
                'weighted', round(sugars_raw * 0.17, 2), 'input', p_sugars_g, 'ceiling', 27.0),
            jsonb_build_object('name', 'salt',             'weight',  0.17, 'raw', round(salt_raw, 1),
                'weighted', round(salt_raw * 0.17, 2), 'input', p_salt_g, 'ceiling', 3.0),
            jsonb_build_object('name', 'calories',         'weight',  0.10, 'raw', round(calories_raw, 1),
                'weighted', round(calories_raw * 0.10, 2), 'input', p_calories, 'ceiling', 600.0),
            jsonb_build_object('name', 'trans_fat',        'weight',  0.11, 'raw', round(trans_fat_raw, 1),
                'weighted', round(trans_fat_raw * 0.11, 2), 'input', p_trans_fat_g, 'ceiling', 2.0),
            jsonb_build_object('name', 'additives',        'weight',  0.07, 'raw', round(additives_raw, 1),
                'weighted', round(additives_raw * 0.07, 2), 'input', p_additives_count, 'ceiling', 10.0),
            jsonb_build_object('name', 'prep_method',      'weight',  0.08, 'raw', prep_raw,
                'weighted', round(prep_raw * 0.08, 2), 'input', p_prep_method),
            jsonb_build_object('name', 'controversies',    'weight',  0.08, 'raw', controversies_raw,
                'weighted', round(controversies_raw * 0.08, 2), 'input', p_controversies),
            jsonb_build_object('name', 'ingredient_concern', 'weight',  0.05, 'raw', round(concern_raw, 1),
                'weighted', round(concern_raw * 0.05, 2), 'input', p_concern_score),
            jsonb_build_object('name', 'nutrient_density', 'weight', -0.08, 'raw', round(nutrient_density_raw, 1),
                'weighted', round(-nutrient_density_raw * 0.08, 2),
                'input', jsonb_build_object('protein_g', p_protein_g, 'fibre_g', p_fibre_g),
                'ceiling', 100.0,
                'components', jsonb_build_object(
                    'protein_bonus', (CASE
                        WHEN COALESCE(p_protein_g, 0) >= 20 THEN 50
                        WHEN COALESCE(p_protein_g, 0) >= 15 THEN 40
                        WHEN COALESCE(p_protein_g, 0) >= 10 THEN 30
                        WHEN COALESCE(p_protein_g, 0) >= 5  THEN 15
                        ELSE 0
                    END),
                    'fibre_bonus', (CASE
                        WHEN COALESCE(p_fibre_g, 0) >= 8 THEN 50
                        WHEN COALESCE(p_fibre_g, 0) >= 5 THEN 35
                        WHEN COALESCE(p_fibre_g, 0) >= 3 THEN 20
                        WHEN COALESCE(p_fibre_g, 0) >= 1 THEN 10
                        ELSE 0
                    END)
                ))
        )
    )
    FROM factors;
$$;

COMMENT ON FUNCTION public.explain_score_v33 IS
    'Returns JSONB breakdown of v3.3 unhealthiness score: final_score + 10 factors (9 penalty + 1 nutrient density bonus). Issue #608.';

GRANT EXECUTE ON FUNCTION public.explain_score_v33 TO authenticated, service_role, anon;


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Update scoring_model_versions — retire v3.2, activate v3.3
-- ═══════════════════════════════════════════════════════════════════════════

-- Retire v3.2 (EXCLUDE constraint prevents two active versions)
UPDATE public.scoring_model_versions
SET    status = 'retired',
       retired_at = now()
WHERE  version = 'v3.2'
  AND  status = 'active';

-- Insert v3.3 as active
INSERT INTO public.scoring_model_versions (version, status, description, config, activated_at, created_by)
VALUES (
    'v3.3',
    'active',
    'Nutrient density bonus: protein + fibre credit (weight -0.08). 9 penalty factors unchanged. Issue #608.',
    jsonb_build_object(
        'factors', jsonb_build_array(
            jsonb_build_object('name', 'saturated_fat',    'weight',  0.17, 'ceiling', 10.0,  'unit', 'g',    'column', 'saturated_fat_g', 'type', 'continuous'),
            jsonb_build_object('name', 'sugars',           'weight',  0.17, 'ceiling', 27.0,  'unit', 'g',    'column', 'sugars_g',        'type', 'continuous'),
            jsonb_build_object('name', 'salt',             'weight',  0.17, 'ceiling', 3.0,   'unit', 'g',    'column', 'salt_g',          'type', 'continuous'),
            jsonb_build_object('name', 'calories',         'weight',  0.10, 'ceiling', 600.0, 'unit', 'kcal', 'column', 'calories',        'type', 'continuous'),
            jsonb_build_object('name', 'trans_fat',        'weight',  0.11, 'ceiling', 2.0,   'unit', 'g',    'column', 'trans_fat_g',     'type', 'continuous'),
            jsonb_build_object('name', 'additives',        'weight',  0.07, 'ceiling', 10.0,  'unit', 'count','column', 'additives_count', 'type', 'continuous'),
            jsonb_build_object('name', 'prep_method',      'weight',  0.08, 'type', 'categorical',
                'map', jsonb_build_object('air-popped',20,'steamed',30,'baked',40,'grilled',60,'smoked',65,'fried',80,'deep-fried',100,'default',50)),
            jsonb_build_object('name', 'controversies',    'weight',  0.08, 'type', 'categorical',
                'map', jsonb_build_object('none',0,'minor',30,'palm oil',40,'moderate',60,'serious',100,'default',0)),
            jsonb_build_object('name', 'ingredient_concern','weight', 0.05, 'ceiling', 100.0, 'unit', 'score','column', 'ingredient_concern_score', 'type', 'continuous'),
            jsonb_build_object('name', 'nutrient_density', 'weight', -0.08, 'ceiling', 100.0, 'unit', 'combined', 'type', 'bonus',
                'components', jsonb_build_array(
                    jsonb_build_object('name', 'protein', 'column', 'protein_g', 'tiers', jsonb_build_array(
                        jsonb_build_object('min', 20, 'bonus', 50),
                        jsonb_build_object('min', 15, 'bonus', 40),
                        jsonb_build_object('min', 10, 'bonus', 30),
                        jsonb_build_object('min', 5,  'bonus', 15)
                    )),
                    jsonb_build_object('name', 'fibre', 'column', 'fibre_g', 'tiers', jsonb_build_array(
                        jsonb_build_object('min', 8, 'bonus', 50),
                        jsonb_build_object('min', 5, 'bonus', 35),
                        jsonb_build_object('min', 3, 'bonus', 20),
                        jsonb_build_object('min', 1, 'bonus', 10)
                    ))
                ))
        ),
        'clamp_min', 1,
        'clamp_max', 100,
        'null_handling', 'coalesce_zero'
    ),
    now(),
    'migration-608'
)
ON CONFLICT (version) DO UPDATE SET
    status = 'active',
    description = EXCLUDED.description,
    config = EXCLUDED.config,
    activated_at = now(),
    retired_at = NULL;


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Update compute_score() — add v3.3 fast-path
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_score(
    p_product_id  bigint,
    p_version     text    DEFAULT NULL,
    p_country     text    DEFAULT NULL,
    p_mode        text    DEFAULT 'apply'
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

    -- 4. Compute score — fast-path per version
    IF v_version_rec.version = 'v3.3' THEN
        -- v3.3 fast path: 9 penalty + nutrient density bonus
        SELECT * INTO v_nf FROM nutrition_facts WHERE product_id = p_product_id;
        SELECT COUNT(*) FILTER (WHERE ir.is_additive)::int INTO v_additives
        FROM product_ingredient pi
        JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        WHERE pi.product_id = p_product_id;

        v_new_score := compute_unhealthiness_v33(
            v_nf.saturated_fat_g, v_nf.sugars_g, v_nf.salt_g,
            v_nf.calories, v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method, v_prod.controversies,
            COALESCE(v_prod.ingredient_concern_score, 0),
            v_nf.protein_g, v_nf.fibre_g
        );
        v_breakdown := explain_score_v33(
            v_nf.saturated_fat_g, v_nf.sugars_g, v_nf.salt_g,
            v_nf.calories, v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method, v_prod.controversies,
            COALESCE(v_prod.ingredient_concern_score, 0),
            v_nf.protein_g, v_nf.fibre_g
        );

    ELSIF v_version_rec.version = 'v3.2' THEN
        -- v3.2 fast path: 9 penalty factors only
        SELECT * INTO v_nf FROM nutrition_facts WHERE product_id = p_product_id;
        SELECT COUNT(*) FILTER (WHERE ir.is_additive)::int INTO v_additives
        FROM product_ingredient pi
        JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        WHERE pi.product_id = p_product_id;

        v_new_score := compute_unhealthiness_v32(
            v_nf.saturated_fat_g, v_nf.sugars_g, v_nf.salt_g,
            v_nf.calories, v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method, v_prod.controversies,
            COALESCE(v_prod.ingredient_concern_score, 0)
        );
        v_breakdown := explain_score_v32(
            v_nf.saturated_fat_g, v_nf.sugars_g, v_nf.salt_g,
            v_nf.calories, v_nf.trans_fat_g,
            COALESCE(v_additives, 0)::numeric,
            v_prod.prep_method, v_prod.controversies,
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
    'Canonical scoring entry point. v3.3 fast-path (protein + fibre bonus). Modes: apply (persist), dry_run (preview), shadow (A/B test).';


-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Update score_category() — use v3.3 with protein + fibre
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE PROCEDURE public.score_category(
    IN p_category text,
    IN p_data_completeness integer DEFAULT 100,
    IN p_country text DEFAULT 'PL'::text
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Set trigger context for audit trail
    PERFORM set_config('app.score_trigger', 'score_category', true);

    -- 0a. COMPUTE ingredient_concern_score from ingredient concern tiers
    UPDATE products p
    SET    ingredient_concern_score = sub.concern_score
    FROM (
        SELECT pp.product_id,
               CASE WHEN MAX(ir.concern_tier) > 0
                   THEN LEAST(100,
                       MAX(ir.concern_tier) * 25
                       + (SUM(ir.concern_tier) - MAX(ir.concern_tier)) * 5
                   )
                   ELSE 0
               END AS concern_score
        FROM   products pp
        LEFT JOIN product_ingredient pi ON pi.product_id = pp.product_id
        LEFT JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
                                    AND ir.is_additive = true
        WHERE  pp.country = p_country
          AND  pp.category = p_category
          AND  pp.is_deprecated IS NOT TRUE
        GROUP BY pp.product_id
    ) sub
    WHERE  p.product_id = sub.product_id;

    -- 0b. DEFAULT concern score for products without ingredient data
    UPDATE products
    SET    ingredient_concern_score = 0
    WHERE  country = p_country
      AND  category = p_category
      AND  is_deprecated IS NOT TRUE
      AND  ingredient_concern_score IS NULL;

    -- 0c. SYNC controversies from palm-oil ingredient data
    UPDATE products p
    SET    controversies = 'palm oil'
    WHERE  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE
      AND  p.controversies = 'none'
      AND  EXISTS (
          SELECT 1
          FROM   product_ingredient pi
          JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
          WHERE  pi.product_id = p.product_id
            AND  ir.from_palm_oil = 'yes'
      );

    -- 1. COMPUTE unhealthiness_score (v3.3 — 9 penalty + nutrient density bonus)
    UPDATE products p
    SET    unhealthiness_score = compute_unhealthiness_v33(
               nf.saturated_fat_g,
               nf.sugars_g,
               nf.salt_g,
               nf.calories,
               nf.trans_fat_g,
               ia.additives_count,
               p.prep_method,
               p.controversies,
               p.ingredient_concern_score,
               nf.protein_g,
               nf.fibre_g
           ),
           score_model_version = 'v3.3',
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


-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Update v_master — use explain_score_v33() for score_breakdown
-- ═══════════════════════════════════════════════════════════════════════════
-- Must DROP CASCADE and recreate since we're changing the function signature
-- used in the view definition.

DROP VIEW IF EXISTS public.v_master CASCADE;

CREATE VIEW public.v_master AS
SELECT
    p.product_id,
    p.country,
    p.brand,
    p.product_type,
    p.category,
    p.product_name,
    p.prep_method,
    p.store_availability,
    p.controversies,
    p.ean,

    -- Nutrition (per 100g — direct from nutrition_facts, no serving indirection)
    nf.calories,
    nf.total_fat_g,
    nf.saturated_fat_g,
    nf.trans_fat_g,
    nf.carbs_g,
    nf.sugars_g,
    nf.fibre_g,
    nf.protein_g,
    nf.salt_g,

    -- Scores (now on products directly)
    p.unhealthiness_score,
    p.confidence,
    p.data_completeness_pct,
    p.nutri_score_label,
    p.nova_classification,
    CASE p.nova_classification
        WHEN '4' THEN 'High'
        WHEN '3' THEN 'Moderate'
        WHEN '2' THEN 'Low'
        WHEN '1' THEN 'Low'
        ELSE 'Unknown'
    END AS processing_risk,
    p.high_salt_flag,
    p.high_sugar_flag,
    p.high_sat_fat_flag,
    p.high_additive_load,
    p.ingredient_concern_score,

    -- Score explainability (JSONB breakdown of all 10 factors — v3.3)
    explain_score_v33(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, ingr.additives_count::numeric, p.prep_method, p.controversies,
        p.ingredient_concern_score,
        nf.protein_g, nf.fibre_g
    ) AS score_breakdown,

    -- Ingredients (derived from junction tables)
    ingr.additives_count,
    ingr.ingredients_text AS ingredients_raw,
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,

    -- Vegan / vegetarian — override to NULL when allergens contradict
    CASE
        WHEN ingr.vegan_status = 'yes'
             AND COALESCE(agg_ai.has_animal_allergen, false)
        THEN NULL
        ELSE ingr.vegan_status
    END AS vegan_status,

    CASE
        WHEN ingr.vegetarian_status = 'yes'
             AND COALESCE(agg_ai.has_meat_fish_allergen, false)
        THEN NULL
        ELSE ingr.vegetarian_status
    END AS vegetarian_status,

    -- Contradiction flags (for frontend warnings)
    (ingr.vegan_status = 'yes'
        AND COALESCE(agg_ai.has_animal_allergen, false)) AS vegan_contradiction,
    (ingr.vegetarian_status = 'yes'
        AND COALESCE(agg_ai.has_meat_fish_allergen, false)) AS vegetarian_contradiction,

    -- Allergen/trace (from unified product_allergen_info table)
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance (now on products directly)
    p.source_type,
    p.source_url,
    p.source_ean,

    -- Primary product image URL (from product_images table)
    (SELECT img.url
     FROM product_images img
     WHERE img.product_id = p.product_id AND img.is_primary = true
     LIMIT 1) AS image_thumb_url,

    -- Data quality indicators
    CASE
        WHEN ingr.ingredient_count > 0 THEN 'complete'
        ELSE 'missing'
    END AS ingredient_data_quality,

    CASE
        WHEN nf.calories IS NOT NULL
             AND nf.total_fat_g IS NOT NULL
             AND nf.carbs_g IS NOT NULL
             AND nf.protein_g IS NOT NULL
             AND nf.salt_g IS NOT NULL
             AND (nf.total_fat_g IS NULL OR nf.saturated_fat_g IS NULL
                  OR nf.saturated_fat_g <= nf.total_fat_g)
             AND (nf.carbs_g IS NULL OR nf.sugars_g IS NULL
                  OR nf.sugars_g <= nf.carbs_g)
        THEN 'clean'
        ELSE 'suspect'
    END AS nutrition_data_quality,

    -- Phase 2: Product English name + provenance + timestamps
    p.product_name_en,
    p.product_name_en_source,
    p.created_at,
    p.updated_at,

    -- Phase 4: Cross-border translations
    p.name_translations,

    -- Store architecture: count and names from M:N junction
    (SELECT COUNT(*)::int
     FROM product_store_availability psa
     JOIN store_ref sr ON sr.store_id = psa.store_id
     WHERE psa.product_id = p.product_id AND sr.is_active = true
    ) AS store_count,
    (SELECT STRING_AGG(sr.store_name, ', ' ORDER BY sr.sort_order)
     FROM product_store_availability psa
     JOIN store_ref sr ON sr.store_id = psa.store_id
     WHERE psa.product_id = p.product_id AND sr.is_active = true
    ) AS store_names,

    -- Nutri-Score provenance (#353)
    p.nutri_score_source

FROM public.products p
LEFT JOIN public.nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::integer AS ingredient_count,
        COUNT(*) FILTER (WHERE ir.is_additive)::integer AS additives_count,
        STRING_AGG(ir.name_en, ', ' ORDER BY pi.position) AS ingredients_text,
        STRING_AGG(CASE WHEN ir.is_additive THEN ir.name_en END, ', ' ORDER BY pi.position) AS additive_names,
        BOOL_OR(ir.from_palm_oil = 'yes') AS has_palm_oil,
        CASE
            WHEN BOOL_AND(ir.vegan IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegan = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegan_status,
        CASE
            WHEN BOOL_AND(ir.vegetarian IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegetarian = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegetarian_status
    FROM public.product_ingredient pi
    JOIN public.ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
) ingr ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) FILTER (WHERE ai.type = 'contains')::integer AS allergen_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'contains') AS allergen_tags,
        COUNT(*) FILTER (WHERE ai.type = 'traces')::integer AS trace_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'traces') AS trace_tags,
        -- Contradiction detection flags
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'milk', 'eggs', 'fish', 'crustaceans', 'molluscs'
        )) AS has_animal_allergen,
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'fish', 'crustaceans', 'molluscs'
        )) AS has_meat_fish_allergen
    FROM public.product_allergen_info ai
    WHERE ai.product_id = p.product_id
) agg_ai ON true
WHERE p.is_deprecated IS NOT TRUE;


-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Re-score all categories with v3.3
-- ═══════════════════════════════════════════════════════════════════════════

-- PL categories
CALL score_category('Alcohol');
CALL score_category('Baby');
CALL score_category('Bread');
CALL score_category('Breakfast & Grain-Based');
CALL score_category('Canned Goods');
CALL score_category('Cereals');
CALL score_category('Chips');
CALL score_category('Condiments');
CALL score_category('Dairy');
CALL score_category('Drinks');
CALL score_category('Frozen & Prepared');
CALL score_category('Instant & Frozen');
CALL score_category('Meat');
CALL score_category('Nuts, Seeds & Legumes');
CALL score_category('Plant-Based & Alternatives');
CALL score_category('Sauces');
CALL score_category('Seafood & Fish');
CALL score_category('Snacks');
CALL score_category('Sweets');

-- DE categories
CALL score_category('Chips', 100, 'DE');
CALL score_category('Bread', 100, 'DE');
CALL score_category('Dairy', 100, 'DE');
CALL score_category('Drinks', 100, 'DE');
CALL score_category('Sweets', 100, 'DE');


-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Update formula_source_hashes for drift detection
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO public.formula_source_hashes (function_name, expected_hash)
VALUES
    ('compute_unhealthiness_v33', encode(digest(
        (SELECT prosrc FROM pg_proc WHERE proname = 'compute_unhealthiness_v33' LIMIT 1),
        'sha256'
    ), 'hex')),
    ('explain_score_v33', encode(digest(
        (SELECT prosrc FROM pg_proc WHERE proname = 'explain_score_v33' LIMIT 1),
        'sha256'
    ), 'hex'))
ON CONFLICT (function_name) DO UPDATE SET
    expected_hash = EXCLUDED.expected_hash,
    updated_at = now();

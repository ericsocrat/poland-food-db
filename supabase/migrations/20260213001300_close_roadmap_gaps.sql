-- ═══════════════════════════════════════════════════════════════════════════════
-- Roadmap Gap Closure: Phases A–E final sweep
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Closes ALL remaining gaps identified in the 5-phase roadmap audit:
--
--  Phase A — Identity
--    1. canonical_brand / canonical_product_name  (generated stored columns)
--    2. identity_key  (md5 hash for fallback dedup)
--    3. UNIQUE(country, ean) — multi-country ready  (replaces single-column idx)
--    4. UNIQUE(country, identity_key) — fallback dedup for EAN-null products
--
--  Phase D — Data Acquisition
--    5. created_at / updated_at timestamps on products
--    6. trg_set_updated_at() trigger — first trigger in the database
--    7. product_field_provenance table — per-field source tracking
--    8. source_nutrition table — multi-source nutrition snapshots (re-created)
--    9. cross_validate_product() function — nutrition cross-source comparison
--   10. Freshness data in api_product_detail response
--
--  Phase B — API Hardening
--   11. Revoke raw SELECT from anon/authenticated on ALL data tables + views
--       (RPC-only model: only SECURITY DEFINER functions serve data)
--   12. RLS + policies on new tables
--
--  Phase E — Scale Guardrails
--   13. Expand check_table_ceilings() with new tables
--
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═════════════════════════════════════════════════════════════════════════════
-- PHASE A: Identity columns + multi-country unique constraints
-- ═════════════════════════════════════════════════════════════════════════════

-- 1-2. Canonical columns and identity key  (generated stored)
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS canonical_brand TEXT
        GENERATED ALWAYS AS (lower(trim(brand))) STORED,
    ADD COLUMN IF NOT EXISTS canonical_product_name TEXT
        GENERATED ALWAYS AS (lower(trim(product_name))) STORED,
    ADD COLUMN IF NOT EXISTS identity_key TEXT
        GENERATED ALWAYS AS (md5(lower(trim(brand)) || '::' || lower(trim(product_name)))) STORED;

COMMENT ON COLUMN products.canonical_brand IS
    'Auto-generated: lower(trim(brand)). Used for dedup matching.';
COMMENT ON COLUMN products.canonical_product_name IS
    'Auto-generated: lower(trim(product_name)). Used for dedup matching.';
COMMENT ON COLUMN products.identity_key IS
    'Auto-generated: md5(canonical_brand || ''::'' || canonical_product_name). Fallback dedup key when EAN is NULL.';

-- 3. Multi-country EAN uniqueness (replace single-column index)
DROP INDEX IF EXISTS products_ean_uniq;
CREATE UNIQUE INDEX products_ean_country_uniq
    ON products (country, ean) WHERE ean IS NOT NULL;

-- 4a. Deprecate case-variant duplicates before adding uniqueness constraint
--     (e.g. "Kajzerka kebab" vs "Kajzerka Kebab" — same product after normalization)
UPDATE products
SET    is_deprecated   = true,
       deprecated_reason = 'case-variant duplicate resolved during identity-key migration'
WHERE  product_id IN (
    SELECT p2.product_id
    FROM   products p1
    JOIN   products p2 ON p2.country = p1.country
                      AND lower(trim(p2.brand)) = lower(trim(p1.brand))
                      AND lower(trim(p2.product_name)) = lower(trim(p1.product_name))
                      AND p2.product_id > p1.product_id   -- keep the lower (older) id
    WHERE  p1.is_deprecated IS NOT TRUE
      AND  p2.is_deprecated IS NOT TRUE
);

-- 4b. Fallback dedup for EAN-null products (excludes deprecated)
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_identity_key
    ON products (country, identity_key)
    WHERE is_deprecated IS NOT TRUE;

-- ═════════════════════════════════════════════════════════════════════════════
-- PHASE D: Timestamps, provenance, multi-source infrastructure
-- ═════════════════════════════════════════════════════════════════════════════

-- 5. Lifecycle timestamps
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS created_at  timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at  timestamptz NOT NULL DEFAULT now();

COMMENT ON COLUMN products.created_at IS 'Row creation timestamp (backfilled to migration time for existing rows).';
COMMENT ON COLUMN products.updated_at IS 'Last modification timestamp. Auto-maintained by trg_products_updated_at.';

-- 6. Auto-update trigger — the first trigger in the database
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;
COMMENT ON FUNCTION trg_set_updated_at IS
    'Generic trigger function: sets updated_at = now() on every UPDATE.';

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

-- 7. Per-field provenance tracking
CREATE TABLE IF NOT EXISTS product_field_provenance (
    product_id   bigint   NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    field_name   text     NOT NULL,
    source_type  text     NOT NULL,
    source_url   text,
    recorded_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT pk_field_provenance PRIMARY KEY (product_id, field_name),
    CONSTRAINT chk_fp_source_type CHECK (
        source_type IN ('off_api','off_search','manual','label_scan','retailer_api')
    )
);

CREATE INDEX IF NOT EXISTS idx_field_provenance_product
    ON product_field_provenance (product_id);

COMMENT ON TABLE product_field_provenance IS
    'Per-field source tracking: which data source populated each field of a product.';

-- 8. Multi-source nutrition snapshots  (re-created after cleanup in 20260211)
CREATE TABLE IF NOT EXISTS source_nutrition (
    source_nutrition_id  bigint       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id           bigint       NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    source_type          text         NOT NULL,
    calories             numeric,
    total_fat_g          numeric,
    saturated_fat_g      numeric,
    trans_fat_g          numeric,
    carbs_g              numeric,
    sugars_g             numeric,
    fibre_g              numeric,
    protein_g            numeric,
    salt_g               numeric,
    collected_at         timestamptz  NOT NULL DEFAULT now(),
    notes                text,

    CONSTRAINT chk_sn_source_type CHECK (
        source_type IN ('off_api','off_search','manual','label_scan','retailer_api')
    ),
    CONSTRAINT chk_source_nutrition_non_negative CHECK (
        coalesce(calories, 0) >= 0 AND coalesce(total_fat_g, 0) >= 0 AND
        coalesce(saturated_fat_g, 0) >= 0 AND coalesce(trans_fat_g, 0) >= 0 AND
        coalesce(carbs_g, 0) >= 0 AND coalesce(sugars_g, 0) >= 0 AND
        coalesce(fibre_g, 0) >= 0 AND coalesce(protein_g, 0) >= 0 AND
        coalesce(salt_g, 0) >= 0
    ),
    CONSTRAINT uq_source_nutrition_entry UNIQUE (product_id, source_type)
);

CREATE INDEX IF NOT EXISTS idx_source_nutrition_product
    ON source_nutrition (product_id);

COMMENT ON TABLE source_nutrition IS
    'Per-source nutrition snapshots. When multiple sources exist for the same product, '
    'cross_validate_product() compares them.';

-- 9. Cross-validation function  (re-created, previously dropped in cleanup)
CREATE OR REPLACE FUNCTION cross_validate_product(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
    WITH src AS (
        SELECT source_type, calories, total_fat_g, saturated_fat_g, trans_fat_g,
               carbs_g, sugars_g, fibre_g, protein_g, salt_g
        FROM   source_nutrition
        WHERE  product_id = p_product_id
    ),
    summary AS (
        SELECT count(*)::int AS source_count,
               CASE count(*)
                   WHEN 0 THEN 'no_sources'
                   WHEN 1 THEN 'single_source'
                   ELSE 'multi_source'
               END AS validation_status
        FROM src
    ),
    divergence AS (
        SELECT
            jsonb_build_object(
                'calories',       max(a.calories)       - min(a.calories),
                'total_fat_g',    max(a.total_fat_g)    - min(a.total_fat_g),
                'saturated_fat_g',max(a.saturated_fat_g)- min(a.saturated_fat_g),
                'carbs_g',        max(a.carbs_g)        - min(a.carbs_g),
                'sugars_g',       max(a.sugars_g)       - min(a.sugars_g),
                'protein_g',      max(a.protein_g)      - min(a.protein_g),
                'salt_g',         max(a.salt_g)         - min(a.salt_g)
            ) AS field_divergence
        FROM src a
    )
    SELECT jsonb_build_object(
        'product_id',        p_product_id,
        'source_count',      s.source_count,
        'validation_status', s.validation_status,
        'sources',           coalesce((SELECT jsonb_agg(jsonb_build_object(
            'source_type',    src.source_type,
            'calories',       src.calories,
            'total_fat_g',    src.total_fat_g,
            'protein_g',      src.protein_g,
            'salt_g',         src.salt_g
        )) FROM src), '[]'::jsonb),
        'field_divergence',  CASE WHEN s.source_count > 1
                                  THEN d.field_divergence
                                  ELSE NULL
                             END
    )
    FROM summary s
    CROSS JOIN divergence d;
$fn$;

COMMENT ON FUNCTION cross_validate_product IS
    'Compares nutrition data across multiple sources for a single product. '
    'Returns divergence metrics to flag potential data quality issues.';

-- Ensure anon cannot call internal cross-validation directly
REVOKE ALL ON FUNCTION cross_validate_product(bigint) FROM anon, authenticated;

-- ═════════════════════════════════════════════════════════════════════════════
-- PHASE D (cont): Freshness data in api_product_detail
-- ═════════════════════════════════════════════════════════════════════════════

-- 10. Recreate api_product_detail with freshness key  (19 top-level keys)
--     api_version stays "1.0" — adding keys is backward-compatible
CREATE OR REPLACE FUNCTION api_product_detail(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',         '1.0',

        -- Identity
        'product_id',          m.product_id,
        'ean',                 m.ean,
        'product_name',        m.product_name,
        'brand',               m.brand,
        'category',            m.category,
        'category_display',    cr.display_name,
        'category_icon',       cr.icon_emoji,
        'product_type',        m.product_type,
        'country',             m.country,
        'store_availability',  m.store_availability,
        'prep_method',         m.prep_method,

        -- Scores
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nutri_score_color',   nsr.color_hex,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk
        ),

        -- Flags
        'flags', jsonb_build_object(
            'high_salt',           (m.high_salt_flag = 'YES'),
            'high_sugar',          (m.high_sugar_flag = 'YES'),
            'high_sat_fat',        (m.high_sat_fat_flag = 'YES'),
            'high_additive_load',  (m.high_additive_load = 'YES'),
            'has_palm_oil',        COALESCE(m.has_palm_oil, false)
        ),

        -- Nutrition per 100 g
        'nutrition_per_100g', jsonb_build_object(
            'calories',       m.calories,
            'total_fat_g',    m.total_fat_g,
            'saturated_fat_g',m.saturated_fat_g,
            'trans_fat_g',    m.trans_fat_g,
            'carbs_g',        m.carbs_g,
            'sugars_g',       m.sugars_g,
            'fibre_g',        m.fibre_g,
            'protein_g',      m.protein_g,
            'salt_g',         m.salt_g
        ),

        -- Ingredients
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additives_count',    m.additives_count,
            'additive_names',     m.additive_names,
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'data_quality',       m.ingredient_data_quality
        ),

        -- Allergens
        'allergens', jsonb_build_object(
            'count',         m.allergen_count,
            'tags',          m.allergen_tags,
            'trace_count',   m.trace_count,
            'trace_tags',    m.trace_tags
        ),

        -- Data trust
        'trust', jsonb_build_object(
            'confidence',              m.confidence,
            'data_completeness_pct',   m.data_completeness_pct,
            'source_type',             m.source_type,
            'nutrition_data_quality',  m.nutrition_data_quality,
            'ingredient_data_quality', m.ingredient_data_quality
        ),

        -- Freshness (NEW — Phase D gap closure)
        'freshness', jsonb_build_object(
            'created_at',    p.created_at,
            'updated_at',    p.updated_at,
            'data_age_days', EXTRACT(DAY FROM now() - p.updated_at)::int
        )
    )
    FROM public.v_master m
    JOIN public.products p ON p.product_id = m.product_id
    LEFT JOIN public.category_ref cr ON cr.category = m.category
    LEFT JOIN public.nutri_score_ref nsr ON nsr.label = m.nutri_score_label
    WHERE m.product_id = p_product_id;
$function$;

-- ═════════════════════════════════════════════════════════════════════════════
-- PHASE B: RPC-only model — revoke raw SELECT from anon / authenticated
-- ═════════════════════════════════════════════════════════════════════════════

-- 11. Revoke direct table/view SELECT from client-facing roles.
--     SECURITY DEFINER functions (api_*) still work because they execute as
--     the function owner (postgres), bypassing these privilege restrictions.
--     RLS policies are retained as documentation / defense-in-depth.

-- Data tables
REVOKE SELECT ON products              FROM anon, authenticated;
REVOKE SELECT ON nutrition_facts        FROM anon, authenticated;
REVOKE SELECT ON product_allergen_info  FROM anon, authenticated;
REVOKE SELECT ON product_ingredient     FROM anon, authenticated;
REVOKE SELECT ON ingredient_ref         FROM anon, authenticated;

-- Reference tables (small lookups, but still routed through RPCs)
REVOKE SELECT ON category_ref           FROM anon, authenticated;
REVOKE SELECT ON country_ref            FROM anon, authenticated;
REVOKE SELECT ON nutri_score_ref        FROM anon, authenticated;
REVOKE SELECT ON concern_tier_ref       FROM anon, authenticated;

-- Views
REVOKE SELECT ON v_master               FROM anon, authenticated;
REVOKE SELECT ON v_api_category_overview FROM anon, authenticated;

-- New tables (12)
ALTER TABLE product_field_provenance ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_field_provenance FORCE ROW LEVEL SECURITY;
CREATE POLICY allow_select_field_provenance ON product_field_provenance
    FOR SELECT USING (true);

ALTER TABLE source_nutrition ENABLE ROW LEVEL SECURITY;
ALTER TABLE source_nutrition FORCE ROW LEVEL SECURITY;
CREATE POLICY allow_select_source_nutrition ON source_nutrition
    FOR SELECT USING (true);

-- Grant service_role full access on new tables
GRANT ALL ON product_field_provenance TO service_role;
GRANT ALL ON source_nutrition TO service_role;

-- No SELECT for anon/authenticated on new tables (RPC-only model)
-- (Tables are created with no grants by default, so nothing to revoke)

-- ═════════════════════════════════════════════════════════════════════════════
-- PHASE E: Expand check_table_ceilings() with new tables
-- ═════════════════════════════════════════════════════════════════════════════

-- 13. Recreate with source_nutrition + product_field_provenance
CREATE OR REPLACE FUNCTION check_table_ceilings()
RETURNS TABLE(table_name text, current_rows bigint, ceiling bigint,
              pct_of_ceiling numeric, status text)
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
    WITH ceilings(tbl, cap) AS (VALUES
        ('products',                15000::bigint),
        ('nutrition_facts',         15000),
        ('product_ingredient',      200000),
        ('ingredient_ref',          10000),
        ('product_allergen_info',   50000),
        ('source_nutrition',        30000),
        ('product_field_provenance', 150000)
    ),
    counts AS (
        SELECT 'products'                AS tbl, COUNT(*) AS n FROM products
        UNION ALL
        SELECT 'nutrition_facts',               COUNT(*) FROM nutrition_facts
        UNION ALL
        SELECT 'product_ingredient',            COUNT(*) FROM product_ingredient
        UNION ALL
        SELECT 'ingredient_ref',                COUNT(*) FROM ingredient_ref
        UNION ALL
        SELECT 'product_allergen_info',         COUNT(*) FROM product_allergen_info
        UNION ALL
        SELECT 'source_nutrition',              COUNT(*) FROM source_nutrition
        UNION ALL
        SELECT 'product_field_provenance',      COUNT(*) FROM product_field_provenance
    )
    SELECT c.tbl,
           ct.n,
           c.cap,
           ROUND(100.0 * ct.n / c.cap, 1),
           CASE
               WHEN ct.n > c.cap       THEN 'EXCEEDED'
               WHEN ct.n > c.cap * 0.8 THEN 'WARNING'
               ELSE 'OK'
           END
    FROM ceilings c
    JOIN counts ct ON ct.tbl = c.tbl
    ORDER BY ROUND(100.0 * ct.n / c.cap, 1) DESC;
$fn$;

-- ═════════════════════════════════════════════════════════════════════════════
-- Verification block
-- ═════════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
    v_count int;
BEGIN
    -- canonical columns exist
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_name = 'products' AND column_name IN ('canonical_brand','canonical_product_name','identity_key');
    IF v_count != 3 THEN
        RAISE EXCEPTION 'Expected 3 canonical columns, found %', v_count;
    END IF;

    -- timestamps exist
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_name = 'products' AND column_name IN ('created_at','updated_at');
    IF v_count != 2 THEN
        RAISE EXCEPTION 'Expected 2 timestamp columns, found %', v_count;
    END IF;

    -- updated_at trigger exists
    SELECT COUNT(*) INTO v_count
    FROM information_schema.triggers
    WHERE trigger_name = 'trg_products_updated_at';
    IF v_count = 0 THEN
        RAISE EXCEPTION 'trg_products_updated_at trigger not found';
    END IF;

    -- new tables exist
    SELECT COUNT(*) INTO v_count
    FROM pg_tables WHERE schemaname = 'public'
      AND tablename IN ('product_field_provenance','source_nutrition');
    IF v_count != 2 THEN
        RAISE EXCEPTION 'Expected 2 new tables, found %', v_count;
    END IF;

    -- RLS enabled on new tables
    SELECT COUNT(*) INTO v_count
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND c.relname IN ('product_field_provenance','source_nutrition')
      AND c.relrowsecurity = true;
    IF v_count != 2 THEN
        RAISE EXCEPTION 'RLS not enabled on all new tables';
    END IF;

    -- anon cannot SELECT products directly
    IF has_table_privilege('anon', 'public.products', 'SELECT') THEN
        RAISE EXCEPTION 'anon still has SELECT on products — RPC-only model not enforced';
    END IF;

    -- api_product_detail returns freshness key
    IF NOT (api_product_detail(2) ? 'freshness') THEN
        RAISE EXCEPTION 'api_product_detail missing freshness key';
    END IF;

    -- check_table_ceilings includes new tables
    SELECT COUNT(*) INTO v_count
    FROM check_table_ceilings()
    WHERE table_name IN ('source_nutrition','product_field_provenance');
    IF v_count != 2 THEN
        RAISE EXCEPTION 'check_table_ceilings missing new tables';
    END IF;

    RAISE NOTICE '✅ All gap-closure verifications passed';
END;
$$;

COMMIT;

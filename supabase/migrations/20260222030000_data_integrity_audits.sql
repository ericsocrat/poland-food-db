-- Migration: Automated Data Integrity Audits
-- Issue: #184 — [Hardening 2/7] Automated Data Integrity Audits (Nightly)
--
-- Creates 8 category audit functions + 1 master runner + audit_results table.
-- All functions return a uniform (check_name, severity, product_id, product_name, ean, details) shape.
-- severity ∈ {critical, warning, info}.
-- All functions are STABLE SECURITY DEFINER (read-only, bypass RLS).

-- ═══════════════════════════════════════════════════════════════════════════════
-- AUDIT RESULTS TABLE (historical log)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS audit_results (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id           UUID          NOT NULL,
    run_timestamp    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    check_name       TEXT          NOT NULL,
    severity         TEXT          NOT NULL CHECK (severity IN ('critical', 'warning', 'info')),
    product_id       BIGINT,
    product_name     TEXT,
    ean              TEXT,
    details          JSONB,
    resolved_at      TIMESTAMPTZ,
    resolved_by      TEXT
);

CREATE INDEX IF NOT EXISTS idx_audit_results_run      ON audit_results(run_id);
CREATE INDEX IF NOT EXISTS idx_audit_results_severity ON audit_results(severity);
CREATE INDEX IF NOT EXISTS idx_audit_results_check    ON audit_results(check_name);

-- RLS: only service_role can read/write audit results
ALTER TABLE audit_results ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON audit_results TO service_role;
REVOKE ALL ON audit_results FROM anon, authenticated;

COMMENT ON TABLE audit_results IS
'Historical log of data integrity audit findings. '
'Each row is one finding from one audit run. run_id groups findings from the same invocation.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 1: Score-Band Contradictions
-- ═══════════════════════════════════════════════════════════════════════════════
-- nutri_score_label (A-E, from Nutri-Score) vs unhealthiness_score (1-100, own score).
-- These are independent systems but should broadly correlate.
-- Flag obvious contradictions where they wildly disagree.

CREATE OR REPLACE FUNCTION audit_score_band_contradictions()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- A-labelled products should not have high unhealthiness
    SELECT
        'score_band_contradiction'::TEXT,
        'critical'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'A-labelled product has high unhealthiness score (>50)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'A'
      AND p.unhealthiness_score > 50
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- E-labelled products should not have low unhealthiness
    SELECT
        'score_band_contradiction'::TEXT,
        'critical'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'E-labelled product has low unhealthiness score (<30)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'E'
      AND p.unhealthiness_score < 30
      AND p.is_deprecated IS NOT TRUE;
$$;

COMMENT ON FUNCTION audit_score_band_contradictions() IS
'Detects products where Nutri-Score label (A-E) wildly contradicts the unhealthiness_score.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 2: Impossible Nutritional Values
-- ═══════════════════════════════════════════════════════════════════════════════
-- nutrition_facts stores values as TEXT; we cast to numeric for range checks.

CREATE OR REPLACE FUNCTION audit_impossible_values()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- Negative calorie values
    SELECT 'negative_calories', 'critical', p.product_id, p.product_name, p.ean,
        jsonb_build_object('field', 'calories', 'value', nf.calories)
    FROM products p
    JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE nf.calories IS NOT NULL
      AND nf.calories::numeric < 0
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Salt > 100g per 100g (impossible)
    SELECT 'salt_overflow', 'critical', p.product_id, p.product_name, p.ean,
        jsonb_build_object('field', 'salt_g', 'value', nf.salt_g)
    FROM products p
    JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE nf.salt_g IS NOT NULL
      AND nf.salt_g::numeric > 100
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Protein + Fat + Carbs > 105g per 100g (5% tolerance)
    SELECT 'macro_overflow', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object(
            'protein_g',   nf.protein_g,
            'total_fat_g', nf.total_fat_g,
            'carbs_g',     nf.carbs_g,
            'total',       COALESCE(nf.protein_g::numeric, 0)
                         + COALESCE(nf.total_fat_g::numeric, 0)
                         + COALESCE(nf.carbs_g::numeric, 0)
        )
    FROM products p
    JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE COALESCE(nf.protein_g::numeric, 0)
        + COALESCE(nf.total_fat_g::numeric, 0)
        + COALESCE(nf.carbs_g::numeric, 0) > 105
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Unhealthiness score outside valid range (1-100)
    SELECT 'score_out_of_range', 'critical', p.product_id, p.product_name, p.ean,
        jsonb_build_object('unhealthiness_score', p.unhealthiness_score)
    FROM products p
    WHERE (p.unhealthiness_score < 1 OR p.unhealthiness_score > 100)
      AND p.unhealthiness_score IS NOT NULL
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Negative nutritional values
    SELECT 'negative_nutrient', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object(
            'protein_g',   nf.protein_g,
            'total_fat_g', nf.total_fat_g,
            'carbs_g',     nf.carbs_g,
            'fibre_g',     nf.fibre_g
        )
    FROM products p
    JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE (nf.protein_g::numeric < 0
        OR nf.total_fat_g::numeric < 0
        OR nf.carbs_g::numeric < 0
        OR nf.fibre_g::numeric < 0)
      AND p.is_deprecated IS NOT TRUE;
$$;

COMMENT ON FUNCTION audit_impossible_values() IS
'Detects physiologically impossible nutritional values: negatives, overflow, score out of range.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 3: Required Field Completeness
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit_missing_required_fields()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- Products with scores but no ingredients
    SELECT 'score_without_ingredients', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object('unhealthiness_score', p.unhealthiness_score, 'has_ingredients', false)
    FROM products p
    LEFT JOIN product_ingredient pi ON p.product_id = pi.product_id
    WHERE p.unhealthiness_score IS NOT NULL
      AND pi.product_id IS NULL
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Products without names
    SELECT 'missing_name', 'critical', p.product_id, p.product_name, p.ean,
        jsonb_build_object('product_name', p.product_name)
    FROM products p
    WHERE (p.product_name IS NULL OR TRIM(p.product_name) = '')
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Products without valid EAN
    SELECT 'missing_ean', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object('ean', p.ean)
    FROM products p
    WHERE (p.ean IS NULL OR LENGTH(p.ean) < 8)
      AND p.is_deprecated IS NOT TRUE;
$$;

COMMENT ON FUNCTION audit_missing_required_fields() IS
'Detects products missing required fields: name, valid EAN, or ingredients when scores exist.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 4: Foreign Key Integrity (Orphans)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit_orphan_records()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- Allergen info records without matching product
    SELECT 'orphan_allergen', 'critical', pai.product_id, NULL, NULL,
        jsonb_build_object('table', 'product_allergen_info', 'tag', pai.tag, 'type', pai.type)
    FROM product_allergen_info pai
    LEFT JOIN products p ON pai.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL

    -- Ingredient records without matching product
    SELECT 'orphan_ingredient', 'warning', pi.product_id, NULL, NULL,
        jsonb_build_object('table', 'product_ingredient', 'ingredient_id', pi.ingredient_id)
    FROM product_ingredient pi
    LEFT JOIN products p ON pi.product_id = p.product_id
    WHERE p.product_id IS NULL;
$$;

COMMENT ON FUNCTION audit_orphan_records() IS
'Detects orphan records in junction tables (allergens, ingredients) with no matching product.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 5: Materialized View Staleness
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit_mv_staleness()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT 'mv_staleness', 'warning', NULL::BIGINT, NULL::TEXT, NULL::TEXT,
        jsonb_build_object(
            'mv_name',       s.relname,
            'last_analyze',  pg_stat_get_last_analyze_time(s.relid),
            'note',          'MV may need refresh if source data changed recently'
        )
    FROM pg_stat_user_tables s
    WHERE s.relname IN ('mv_ingredient_frequency', 'mv_product_similarity')
      AND (pg_stat_get_last_analyze_time(s.relid) IS NULL
           OR pg_stat_get_last_analyze_time(s.relid) < NOW() - INTERVAL '24 hours');
$$;

COMMENT ON FUNCTION audit_mv_staleness() IS
'Detects materialized views not analyzed in the last 24 hours.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 6: Duplicate EAN Detection
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit_duplicate_eans()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT 'duplicate_ean', 'critical',
        MIN(p.product_id),
        MIN(p.product_name),
        p.ean,
        jsonb_build_object(
            'count',       COUNT(*),
            'product_ids', array_agg(p.product_id),
            'categories',  array_agg(DISTINCT p.category)
        )
    FROM products p
    WHERE p.ean IS NOT NULL AND p.ean != ''
      AND p.is_deprecated IS NOT TRUE
    GROUP BY p.ean
    HAVING COUNT(*) > 1;
$$;

COMMENT ON FUNCTION audit_duplicate_eans() IS
'Detects active products sharing the same EAN barcode.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 7: Band Consistency
-- ═══════════════════════════════════════════════════════════════════════════════
-- Cross-checks Nutri-Score label against unhealthiness_score.
-- Since they come from different systems, we use wide tolerance bands
-- and only flag >=2 band gap discrepancies.

CREATE OR REPLACE FUNCTION audit_band_consistency()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT 'band_mismatch', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object(
            'nutri_score_label',   p.nutri_score_label,
            'unhealthiness_score', p.unhealthiness_score,
            'expected_label',      CASE
                WHEN p.unhealthiness_score <= 20 THEN 'A'
                WHEN p.unhealthiness_score <= 40 THEN 'B'
                WHEN p.unhealthiness_score <= 60 THEN 'C'
                WHEN p.unhealthiness_score <= 80 THEN 'D'
                ELSE 'E'
            END,
            'note', 'Nutri-Score and unhealthiness_score disagree by >=2 bands'
        )
    FROM products p
    WHERE p.nutri_score_label IN ('A', 'B', 'C', 'D', 'E')
      AND p.unhealthiness_score IS NOT NULL
      AND p.is_deprecated IS NOT TRUE
      -- Only flag when the gap is >= 2 bands
      AND ABS(
          -- Convert label to numeric: A=1, B=2, C=3, D=4, E=5
          CASE p.nutri_score_label
              WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3
              WHEN 'D' THEN 4 WHEN 'E' THEN 5
          END
          -
          -- Convert score to expected band number
          CASE
              WHEN p.unhealthiness_score <= 20 THEN 1
              WHEN p.unhealthiness_score <= 40 THEN 2
              WHEN p.unhealthiness_score <= 60 THEN 3
              WHEN p.unhealthiness_score <= 80 THEN 4
              ELSE 5
          END
      ) >= 2;
$$;

COMMENT ON FUNCTION audit_band_consistency() IS
'Flags products where Nutri-Score label and unhealthiness_score disagree by 2+ bands.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- CATEGORY 8: Category-Level Consistency
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit_category_consistency()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- Products with no category assignment
    SELECT 'missing_category', 'warning', p.product_id, p.product_name, p.ean,
        jsonb_build_object('category', p.category)
    FROM products p
    WHERE (p.category IS NULL OR TRIM(p.category) = '')
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- Categories with suspiciously few products (< 3, might indicate import failure)
    SELECT 'sparse_category', 'info', NULL::BIGINT, NULL::TEXT, NULL::TEXT,
        jsonb_build_object(
            'category', p.category,
            'count',    COUNT(*)
        )
    FROM products p
    WHERE p.category IS NOT NULL
      AND p.is_deprecated IS NOT TRUE
    GROUP BY p.category
    HAVING COUNT(*) < 3;
$$;

COMMENT ON FUNCTION audit_category_consistency() IS
'Detects products without categories and categories with suspiciously few products.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- MASTER AUDIT RUNNER
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION run_full_data_audit()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT * FROM audit_score_band_contradictions()
    UNION ALL SELECT * FROM audit_impossible_values()
    UNION ALL SELECT * FROM audit_missing_required_fields()
    UNION ALL SELECT * FROM audit_orphan_records()
    UNION ALL SELECT * FROM audit_mv_staleness()
    UNION ALL SELECT * FROM audit_duplicate_eans()
    UNION ALL SELECT * FROM audit_band_consistency()
    UNION ALL SELECT * FROM audit_category_consistency();
$$;

COMMENT ON FUNCTION run_full_data_audit() IS
'Master audit runner. Calls all 8 audit category functions and returns unified results.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- GRANTS
-- ═══════════════════════════════════════════════════════════════════════════════
-- Only service_role should execute audit functions (they bypass RLS).

GRANT EXECUTE ON FUNCTION audit_score_band_contradictions() TO service_role;
GRANT EXECUTE ON FUNCTION audit_impossible_values()         TO service_role;
GRANT EXECUTE ON FUNCTION audit_missing_required_fields()   TO service_role;
GRANT EXECUTE ON FUNCTION audit_orphan_records()            TO service_role;
GRANT EXECUTE ON FUNCTION audit_mv_staleness()              TO service_role;
GRANT EXECUTE ON FUNCTION audit_duplicate_eans()            TO service_role;
GRANT EXECUTE ON FUNCTION audit_band_consistency()          TO service_role;
GRANT EXECUTE ON FUNCTION audit_category_consistency()      TO service_role;
GRANT EXECUTE ON FUNCTION run_full_data_audit()             TO service_role;

REVOKE EXECUTE ON FUNCTION audit_score_band_contradictions() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_impossible_values()         FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_missing_required_fields()   FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_orphan_records()            FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_mv_staleness()              FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_duplicate_eans()            FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_band_consistency()          FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION audit_category_consistency()      FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION run_full_data_audit()             FROM PUBLIC;

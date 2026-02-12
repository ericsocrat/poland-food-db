-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Dynamic data_completeness_pct computation
-- Date:      2026-02-13
-- Purpose:   Replace static data_completeness_pct (set during pipeline at 90-100)
--            with a dynamically computed value based on actual field coverage.
--
-- Changes:
--   1. CREATE FUNCTION compute_data_completeness(product_id) — 15-checkpoint
--      formula counting EAN, 9 nutrition fields, Nutri-Score grade, NOVA,
--      ingredients, allergen assessment, and source provenance.
--   2. UPDATE score_category() to use dynamic computation instead of the
--      static p_data_completeness parameter.
--   3. One-time recalculation of data_completeness_pct + confidence for
--      all active products.
--   4. Refresh materialized views.
--
-- Impact:
--   Before: 1025 verified / 0 estimated / 0 low
--   After:  ~859 verified / ~166 estimated / 0 low
--   Products missing ingredient data or UNKNOWN Nutri-Score now honestly
--   report lower completeness and 'estimated' confidence.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. compute_data_completeness(product_id) → numeric (0–100)
--
-- 15 checkpoints, each worth ~6.67%:
--   1.  has EAN
--   2-10. has each of 9 nutrition fields (calories, total_fat_g, saturated_fat_g,
--         sugars_g, salt_g, protein_g, carbs_g, fibre_g, trans_fat_g)
--   11. has Nutri-Score grade (A-E or NOT-APPLICABLE; UNKNOWN = missing)
--   12. has NOVA classification
--   13. has at least 1 ingredient row in product_ingredient
--   14. allergen assessment done (has allergen data OR has ingredients)
--   15. has source provenance (source_type)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION compute_data_completeness(p_product_id bigint)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
    SELECT ROUND(
        (
            -- EAN
            (CASE WHEN p.ean IS NOT NULL THEN 1 ELSE 0 END) +
            -- Nutrition facts (9 fields)
            (CASE WHEN nf.calories        IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g     IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.sugars_g        IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.salt_g          IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.protein_g       IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.carbs_g         IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.fibre_g         IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN nf.trans_fat_g     IS NOT NULL THEN 1 ELSE 0 END) +
            -- Nutri-Score (A–E or NOT-APPLICABLE count; UNKNOWN = missing)
            (CASE WHEN p.nutri_score_label IS NOT NULL
                   AND p.nutri_score_label != 'UNKNOWN'
                  THEN 1 ELSE 0 END) +
            -- NOVA classification
            (CASE WHEN p.nova_classification IS NOT NULL THEN 1 ELSE 0 END) +
            -- Ingredients (at least 1 row)
            (CASE WHEN EXISTS (
                SELECT 1 FROM product_ingredient pi
                WHERE pi.product_id = p.product_id
            ) THEN 1 ELSE 0 END) +
            -- Allergen assessment (has allergen data, OR has ingredients which
            -- implies the assessment was possible even if product is allergen-free)
            (CASE WHEN EXISTS (
                SELECT 1 FROM product_allergen_info ai
                WHERE ai.product_id = p.product_id
            ) OR EXISTS (
                SELECT 1 FROM product_ingredient pi2
                WHERE pi2.product_id = p.product_id
            ) THEN 1 ELSE 0 END) +
            -- Source provenance
            (CASE WHEN p.source_type IS NOT NULL THEN 1 ELSE 0 END)
        )::numeric / 15.0 * 100
    )
    FROM products p
    LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE p.product_id = p_product_id;
$$;

COMMENT ON FUNCTION compute_data_completeness(bigint) IS
'Computes data_completeness_pct for a product based on 15 field-coverage checkpoints '
'(EAN, 9 nutrition fields, Nutri-Score grade, NOVA, ingredients, allergen assessment, source). '
'Returns 0–100 rounded to nearest integer.';


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Update score_category() to use dynamic computation
--    The p_data_completeness parameter is kept for backward compatibility
--    but is now ignored — the function always computes dynamically.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE score_category(
    p_category      text,
    p_data_completeness integer DEFAULT 100   -- kept for signature compat; ignored
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- 0. DEFAULT concern score for products without ingredient data
    UPDATE products
    SET    ingredient_concern_score = 0
    WHERE  country = 'PL'
      AND  category = p_category
      AND  is_deprecated IS NOT TRUE
      AND  ingredient_concern_score IS NULL;

    -- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
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
           )
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = 'PL'
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
      AND  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 5. SET confidence level (now uses dynamic completeness)
    UPDATE products p
    SET    confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
    WHERE  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;
END;
$procedure$;

COMMENT ON PROCEDURE score_category(text, int) IS
'Consolidated scoring procedure for a given category. '
'Steps: 0 (concern defaults), 1 (unhealthiness v3.2), 4 (flags + dynamic data_completeness), 5 (confidence). '
'The p_data_completeness parameter is retained for backward compatibility but is now ignored — '
'completeness is always computed dynamically via compute_data_completeness().';


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. One-time recalculation of all active products
-- ─────────────────────────────────────────────────────────────────────────────

-- 3a. Update data_completeness_pct
UPDATE products p
SET    data_completeness_pct = compute_data_completeness(p.product_id)
WHERE  p.is_deprecated IS NOT TRUE;

-- 3b. Re-assign confidence based on new completeness values
UPDATE products p
SET    confidence = assign_confidence(p.data_completeness_pct, p.source_type)
WHERE  p.is_deprecated IS NOT TRUE;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Refresh materialized views
-- ─────────────────────────────────────────────────────────────────────────────
REFRESH MATERIALIZED VIEW mv_ingredient_frequency;
REFRESH MATERIALIZED VIEW v_product_confidence;


-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Verification queries
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
    v_verified  int;
    v_estimated int;
    v_low       int;
    v_pct_min   numeric;
    v_pct_max   numeric;
    v_pct_avg   numeric;
BEGIN
    SELECT COUNT(*) FILTER (WHERE confidence = 'verified'),
           COUNT(*) FILTER (WHERE confidence = 'estimated'),
           COUNT(*) FILTER (WHERE confidence = 'low'),
           MIN(data_completeness_pct),
           MAX(data_completeness_pct),
           ROUND(AVG(data_completeness_pct), 1)
    INTO   v_verified, v_estimated, v_low, v_pct_min, v_pct_max, v_pct_avg
    FROM   products
    WHERE  is_deprecated IS NOT TRUE;

    RAISE NOTICE '── Dynamic data_completeness_pct results ──';
    RAISE NOTICE 'Confidence: % verified / % estimated / % low', v_verified, v_estimated, v_low;
    RAISE NOTICE 'Completeness range: %–% (avg %)', v_pct_min, v_pct_max, v_pct_avg;

    -- Sanity: no NULLs
    IF EXISTS (SELECT 1 FROM products WHERE is_deprecated IS NOT TRUE AND data_completeness_pct IS NULL) THEN
        RAISE EXCEPTION 'BUG: found active product with NULL data_completeness_pct';
    END IF;
    IF EXISTS (SELECT 1 FROM products WHERE is_deprecated IS NOT TRUE AND confidence IS NULL) THEN
        RAISE EXCEPTION 'BUG: found active product with NULL confidence';
    END IF;
END $$;

COMMIT;

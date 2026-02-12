-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: score_category() procedure
-- ═══════════════════════════════════════════════════════════════════════════
-- Consolidates the repeated scoring boilerplate (Steps 0, 1, 4, 5) that
-- was duplicated across all 20 category scoring pipelines (~760 lines).
-- Category pipelines now only need Steps 2 (Nutri-Score) and 3 (NOVA)
-- plus a single CALL score_category('CategoryName');
--
-- The Żabka category is the only exception: it uses a custom
-- data_completeness_pct CASE expression in Step 4, so its scoring file
-- keeps the full inline SQL (but can still call this for Steps 0/1/5).
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE PROCEDURE score_category(
    p_category text,
    p_data_completeness int DEFAULT 100
)
LANGUAGE plpgsql
AS $$
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

    -- 4. Health-risk flags
    UPDATE products p
    SET    high_salt_flag    = CASE WHEN nf.salt_g >= 1.5 THEN 'YES' ELSE 'NO' END,
           high_sugar_flag   = CASE WHEN nf.sugars_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_sat_fat_flag = CASE WHEN nf.saturated_fat_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_additive_load = CASE WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END,
           data_completeness_pct = p_data_completeness
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

    -- 5. SET confidence level
    UPDATE products p
    SET    confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
    WHERE  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;
END;
$$;

COMMENT ON PROCEDURE score_category(text, int) IS
'Applies Steps 0/1/4/5 of the standard scoring pipeline for a given category. '
'Category scoring SQL files only need Nutri-Score (Step 2) and NOVA (Step 3) data, '
'then CALL score_category(''CategoryName'');';

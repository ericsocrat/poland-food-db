-- Migration: Re-score all products with ingredient-derived scoring factors
--
-- After enrichment populated product_ingredient (15,900 rows) and
-- product_allergen_info (3,144 rows), scoring factors that depend on
-- ingredient data were never recomputed:
--
--   1. ingredient_concern_score — was 0 for ALL 1,279 products despite
--      195 having concern-tier > 0 ingredients (EFSA-classified additives).
--   2. controversies — 79 products have palm-oil ingredients but
--      controversies = 'none' (not synced from ingredient data).
--
-- This migration enhances score_category() to:
--   Step 0a: COMPUTE ingredient_concern_score from ingredient concern tiers
--   Step 0b: DEFAULT to 0 for products without ingredient data
--   Step 0c: SYNC controversies from palm-oil ingredient data
--
-- Formula (unchanged from 20260210001900):
--   concern_score = LEAST(100, max_tier * 25 + (sum_tiers - max_tier) * 5)
--
-- Then re-scores all 19 active categories.
--
-- To roll back: restore prior score_category() from 20260213000800 migration
--               and re-run CALL score_category() for all categories.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Enhanced score_category() procedure
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
    --     Formula: LEAST(100, max_tier * 25 + (sum_tiers - max_tier) * 5)
    --     Only additive ingredients with concern_tier > 0 contribute.
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
    --     Products with at least one palm-oil ingredient get 'palm oil'.
    --     Only upgrades 'none' → 'palm oil'; does not downgrade.
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

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Re-score all 19 active categories
-- ═══════════════════════════════════════════════════════════════════════════
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

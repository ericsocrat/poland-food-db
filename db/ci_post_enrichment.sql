-- Post-enrichment: recompute ingredient concern scores and re-score all categories
-- This file runs AFTER enrich_ingredients.py populates product_ingredient + product_allergen_info
-- It bridges the gap between enrichment data and the scoring pipeline.
--
-- Rollback: Re-run score_category() for all categories (resets scores from current data)

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- Step 1: Populate ingredient_concern_score from actual ingredient data
-- ═══════════════════════════════════════════════════════════════
-- Based on EFSA concern tiers: tier 1 = 15pts, tier 2 = 40pts, tier 3 = 100pts
-- Capped at LEAST(100, SUM(...)) per SCORING_METHODOLOGY.md v3.2

UPDATE products p
SET ingredient_concern_score = COALESCE(concern.score, 0)
FROM (
    SELECT pi.product_id,
           LEAST(100, SUM(
               CASE ir.concern_tier
                   WHEN 1 THEN 15
                   WHEN 2 THEN 40
                   WHEN 3 THEN 100
                   ELSE 0
               END
           ))::int AS score
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.concern_tier > 0
    GROUP BY pi.product_id
) concern
WHERE concern.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE
  AND p.ingredient_concern_score IS DISTINCT FROM COALESCE(concern.score, 0);

-- ═══════════════════════════════════════════════════════════════
-- Step 2: Flag palm oil controversy from actual ingredient data
-- ═══════════════════════════════════════════════════════════════

UPDATE products p
SET controversies = 'palm oil'
FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.from_palm_oil = 'yes'
) palm
WHERE palm.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE
  AND p.controversies = 'none';

-- ═══════════════════════════════════════════════════════════════
-- Step 3: Re-score all categories (propagates concern scores into unhealthiness)
-- ═══════════════════════════════════════════════════════════════

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
CALL score_category('Żabka');

-- DE categories (micro-pilot)
CALL score_category('Chips',    p_country := 'DE');
CALL score_category('Bread',    p_country := 'DE');
CALL score_category('Dairy',    p_country := 'DE');
CALL score_category('Drinks',   p_country := 'DE');
CALL score_category('Sweets',   p_country := 'DE');

COMMIT;

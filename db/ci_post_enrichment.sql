-- Post-enrichment: clean ingredient data, infer allergens, recompute scores
-- This file runs AFTER enrich_ingredients.py populates product_ingredient + product_allergen_info
-- It bridges the gap between enrichment data and the scoring pipeline.
--
-- Rollback: Re-run score_category() for all categories (resets scores from current data)

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- Step 0a: Clean junk ingredient names from OFF API parser artifacts
-- ═══════════════════════════════════════════════════════════════
-- Remove bare numbers, single-char names, and nutrition label fragments
-- that the OFF API parser sometimes produces.

DELETE FROM product_ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id FROM ingredient_ref
    WHERE name_en ~ '^\d+$'
       OR length(trim(name_en)) <= 1
       OR name_en ~* '^(per 100|kcal|kj\b)'
);

DELETE FROM ingredient_ref
WHERE name_en ~ '^\d+$'
   OR length(trim(name_en)) <= 1
   OR name_en ~* '^(per 100|kcal|kj\b)';

-- ═══════════════════════════════════════════════════════════════
-- Step 0b: Infer allergen declarations from ingredient data
-- ═══════════════════════════════════════════════════════════════
-- Products whose ingredients clearly indicate an allergen (e.g. "milk",
-- "wheat flour") but lack a matching product_allergen_info row get one
-- inferred here.  Logic mirrors QA__allergen_integrity checks 9-14.

-- Milk (excludes cocoa butter, coconut milk, lactic acid, etc.)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY[
    '%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%'
])
AND NOT (ir.name_en ILIKE ANY(ARRAY[
    '%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%',
    '%coconut milk%','%coconut cream%','%almond milk%','%oat milk%',
    '%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%',
    '%ice cream plant%','%buttercup%','%lactic acid%','%cream soda%',
    '%factory%handles%','%produced%facility%'
]))
AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'milk' AND pai.type = 'contains'
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Gluten (excludes buckwheat, benzoate, coat)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY[
    '%wheat%','%barley%','%rye%','%spelt%',
    '%oats%','%oatmeal%','%oat flake%','%oat bran%','%oat fibre%',
    '%oat fiber%','%rolled oat%',
    '%owsian%','%owies%',
    '%haferfloc%','%haferkl%'
])
AND ir.name_en NOT ILIKE '%buckwheat%'
AND ir.name_en NOT ILIKE '%benzoate%'
AND ir.name_en NOT ILIKE '%coat%'
AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'gluten' AND pai.type = 'contains'
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Eggs (excludes eggplant, reggiano, egg noodle)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'eggs', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
AND NOT (ir.name_en ILIKE ANY(ARRAY['%eggplant%','%reggiano%','%egg noodle%']))
AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'eggs' AND pai.type = 'contains'
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Soybeans
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'soybeans', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'soybeans' AND pai.type = 'contains'
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Fish
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'fish', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY[
    '%fish%','%salmon%','%tuna%','%herring%','%mackerel%','%anchov%','%cod %','%trout%'
])
AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'fish' AND pai.type = 'contains'
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- Step 0c: Remove ingredient data for deprecated products
-- ═══════════════════════════════════════════════════════════════
-- Keeps MV row counts consistent (mv_ingredient_frequency excludes
-- deprecated products via JOIN, but product_ingredient doesn't).

DELETE FROM product_ingredient
WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);

DELETE FROM product_allergen_info
WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);

-- Remove orphan ingredient_ref entries left behind (only used by deprecated products)
DELETE FROM ingredient_ref
WHERE NOT EXISTS (
    SELECT 1 FROM product_ingredient pi WHERE pi.ingredient_id = ingredient_ref.ingredient_id
)
AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

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

-- ═══════════════════════════════════════════════════════════════
-- Step 4: Refresh materialized views
-- ═══════════════════════════════════════════════════════════════
-- Must run AFTER COMMIT because some MVs use CONCURRENTLY refresh.
-- Ensures v_product_confidence, mv_product_similarity, and
-- mv_ingredient_frequency reflect the updated scores.
SELECT refresh_all_materialized_views();

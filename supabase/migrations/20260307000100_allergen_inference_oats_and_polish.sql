-- Extend allergen inference to cover oat/gluten and Polish-named dairy ingredients
-- Fixes: PL Drinks allergen gap (issue #367) + cross-category oat-gluten gap
--
-- Impact:
--   - Gluten: ~16 products with oat ingredients (Breakfast & Grain-Based, Cereals, Drinks)
--   - Milk:   ~6 products with Polish dairy ingredient names across multiple categories
--
-- Pattern: Follows the same inference approach as 20260306000200 Step 4
--          (ingredient-based allergen inference with conservative exclusions)
--
-- Rollback: DELETE FROM product_allergen_info WHERE tag = 'en:gluten'
--           AND product_id IN (products matched by oat-pattern below);
--           DELETE FROM product_allergen_info WHERE tag = 'en:milk'
--           AND product_id IN (products matched by Polish-dairy-pattern below);

BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 1: Infer en:gluten from oat ingredients
-- ────────────────────────────────────────────────────────────────────────────
-- EU allergen regulation lists "cereals containing gluten: wheat, rye, barley,
-- OATS, spelt".  The existing inference (20260306000200 Step 4) covers wheat,
-- barley, rye, and spelt but omits oats.  This step adds oat-pattern matching
-- in both English and Polish.
--
-- Exclusions: 'benzoate' (Sodium Benzoate contains 'oat' as substring),
--             'coat' (chocolate coating etc.)

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products       p  ON p.product_id = pi.product_id
                      AND p.is_deprecated IS NOT TRUE
WHERE (
    -- English oat patterns
    ir.name_en ILIKE '%oats%'
    OR ir.name_en ILIKE '%oatmeal%'
    OR ir.name_en ILIKE '%oat flake%'
    OR ir.name_en ILIKE '%oat bran%'
    OR ir.name_en ILIKE '%oat fibre%'
    OR ir.name_en ILIKE '%oat fiber%'
    OR ir.name_en ILIKE '%rolled oat%'
    -- Polish oat patterns
    OR ir.name_en ILIKE '%owsian%'     -- Płatki Owsiane, Otręby Owsiane, etc.
    OR ir.name_en ILIKE '%owies%'      -- owies (oat base)
    -- German oat patterns (DE products)
    OR ir.name_en ILIKE '%haferfloc%'  -- Haferflocken
    OR ir.name_en ILIKE '%haferkl%'    -- Haferkleie
  )
  -- Exclusions: substrings that contain 'oat' but are NOT oats
  AND ir.name_en NOT ILIKE '%benzoate%'
  AND ir.name_en NOT ILIKE '%coat%'
  -- Do not duplicate existing declarations
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id
      AND pai.tag = 'en:gluten'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 2: Infer en:milk from Polish-named dairy ingredients
-- ────────────────────────────────────────────────────────────────────────────
-- The existing inference (20260306000200 Step 4) uses English patterns (milk,
-- cream, butter, cheese, whey, lactose, casein).  Some products have Polish-only
-- ingredient names that are genuine dairy but miss the English-only patterns.
--
-- Exclusions:
--   'kwas mlekow' = lactic acid (not dairy)
--   'fermentacji mlekow' = lactic acid fermentation culture (not dairy)
--   'kokos' = coconut (not dairy)
--   'sojow/ryżow/migdałow/owsian' = plant-based milk alternatives

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products       p  ON p.product_id = pi.product_id
                      AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY[
    '%mleko%',          -- mleko (milk)
    '%śmietan%',        -- śmietana (cream)
    '%serwatk%',        -- serwatka (whey)
    '%laktoz%',         -- laktoza (lactose)
    '%kazein%',         -- kazeina (casein)
    '%twaróg%',         -- twaróg (curd cheese)
    '%jogurt%',         -- jogurt (yogurt)
    '%kefir%',          -- kefir
    '%białka mleka%'    -- białka mleka (milk proteins)
  ])
  -- Exclusions: not dairy despite containing dairy-like substrings
  AND ir.name_en NOT ILIKE '%kwas mlekow%'           -- lactic acid
  AND ir.name_en NOT ILIKE '%fermentacji mlekow%'     -- fermentation culture
  AND ir.name_en NOT ILIKE '%kokos%'                   -- coconut milk/cream
  AND ir.name_en NOT ILIKE '%sojow%'                   -- soy milk
  AND ir.name_en NOT ILIKE '%ryżow%'                   -- rice milk
  AND ir.name_en NOT ILIKE '%migdałow%'                -- almond milk
  AND ir.name_en NOT ILIKE '%owsian%'                   -- oat milk
  -- Do not duplicate existing declarations
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id
      AND pai.tag = 'en:milk'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 3: Re-score affected categories (confidence + data_completeness_pct)
-- ────────────────────────────────────────────────────────────────────────────
-- New allergen rows change the allergen checkpoint in compute_data_completeness().
-- Re-run score_category for the affected categories.

CALL score_category('Breakfast & Grain-Based');
CALL score_category('Cereals');
CALL score_category('Chips');
CALL score_category('Dairy');
CALL score_category('Drinks');
CALL score_category('Meat');
CALL score_category('Nuts, Seeds & Legumes');
CALL score_category('Snacks');

COMMIT;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 4: Refresh materialized views (must be outside transaction)
-- ────────────────────────────────────────────────────────────────────────────
SELECT refresh_all_materialized_views();

-- ============================================================
-- QA: Allergen & Trace Integrity
-- Validates allergen/trace tag quality, cross-references
-- ingredient data against declared allergens, and detects
-- orphaned or junk entries.
-- All checks are BLOCKING.
-- Updated: product_allergen and product_trace merged into
-- product_allergen_info (product_id, tag, type).
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Allergen tags must use the 'en:' taxonomy prefix
--    Tags like 'pl:sojowego' or 'sr:soja-lecitin' are locale junk
--    from unprocessed OFF imports and should be mapped or removed.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. allergen tags use en: prefix' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info
WHERE type = 'contains'
  AND tag NOT LIKE 'en:%';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Trace tags must use the 'en:' taxonomy prefix
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. trace tags use en: prefix' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info
WHERE type = 'traces'
  AND tag NOT LIKE 'en:%';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Allergen tags must be in the EU-14 major allergens + accepted extras
--    EU regulation 1169/2011 defines 14 allergen groups.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. allergen tags in recognized domain' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info
WHERE type = 'contains'
  AND tag NOT IN (
  'en:gluten', 'en:milk', 'en:eggs', 'en:fish', 'en:crustaceans',
  'en:molluscs', 'en:peanuts', 'en:nuts', 'en:soybeans', 'en:celery',
  'en:mustard', 'en:sesame-seeds', 'en:lupin',
  'en:sulphur-dioxide-and-sulphites',
  -- Accepted extras beyond EU-14
  'en:kiwi', 'en:pork', 'en:none', 'en:peach'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Trace tags must be in recognized domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. trace tags in recognized domain' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info
WHERE type = 'traces'
  AND tag NOT IN (
  'en:gluten', 'en:milk', 'en:eggs', 'en:fish', 'en:crustaceans',
  'en:molluscs', 'en:peanuts', 'en:nuts', 'en:soybeans', 'en:celery',
  'en:mustard', 'en:sesame-seeds', 'en:lupin',
  'en:sulphur-dioxide-and-sulphites',
  'en:kiwi', 'en:pork', 'en:none'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. No duplicate allergen declarations per product
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. no duplicate allergen per product' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT product_id, tag
  FROM product_allergen_info
  WHERE type = 'contains'
  GROUP BY product_id, tag
  HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. No duplicate trace declarations per product
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. no duplicate trace per product' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT product_id, tag
  FROM product_allergen_info
  WHERE type = 'traces'
  GROUP BY product_id, tag
  HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Orphan allergen rows (product doesn't exist)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. no orphan allergen rows' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info pai
WHERE pai.type = 'contains'
  AND NOT EXISTS (
  SELECT 1 FROM products p WHERE p.product_id = pai.product_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Orphan trace rows (product doesn't exist)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. no orphan trace rows' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info pai
WHERE pai.type = 'traces'
  AND NOT EXISTS (
  SELECT 1 FROM products p WHERE p.product_id = pai.product_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Milk-ingredient products should declare en:milk allergen
--    Products with ingredients containing milk/cream/butter/cheese/whey/
--    lactose/casein should have an en:milk allergen tag.
--    Only checks products that have ingredient data.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. milk ingredients declare milk allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE ANY(ARRAY[
    '%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%'
  ])
  -- Exclude non-dairy false positives
  AND ir.name_en NOT ILIKE ANY(ARRAY[
    '%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%',
    '%coconut milk%','%coconut cream%','%almond milk%','%oat milk%',
    '%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%',
    '%ice cream plant%','%buttercup%'
  ])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:milk' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Gluten-ingredient products should declare en:gluten allergen
--     Products with wheat/barley/rye/oat/spelt ingredients should have
--     an en:gluten allergen tag.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. gluten ingredients declare gluten allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE ANY(ARRAY[
    '%wheat%','%barley%','%rye%','%spelt%'
  ])
  AND ir.name_en NOT ILIKE '%buckwheat%'
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:gluten' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Egg-ingredient products should declare en:eggs allergen
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. egg ingredients declare eggs allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
  AND ir.name_en NOT ILIKE ANY(ARRAY['%eggplant%','%reggiano%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:eggs' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Soy-ingredient products should declare en:soybeans allergen
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. soy ingredients declare soybeans allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:soybeans' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Peanut-ingredient products should declare en:peanuts allergen
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. peanut ingredients declare peanuts allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE '%peanut%'
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:peanuts' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Fish-ingredient products should declare en:fish allergen
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. fish ingredients declare fish allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
  WHERE ir.name_en ILIKE ANY(ARRAY['%fish%','%salmon%','%tuna%','%herring%','%mackerel%','%anchov%','%cod %','%trout%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:fish' AND pai.type = 'contains'
  )
) x;


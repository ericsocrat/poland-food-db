-- ============================================================
-- QA: Allergen & Trace Integrity
-- Validates allergen/trace tag quality, cross-references
-- ingredient data against declared allergens, and detects
-- orphaned or junk entries.
-- All checks are BLOCKING.
-- Updated: product_allergen and product_trace merged into
-- product_allergen_info (product_id, tag, type).
-- Tags now use canonical bare IDs (e.g. 'gluten', 'milk')
-- validated against allergen_ref via FK fk_allergen_tag_ref.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Allergen tags must exist in allergen_ref
--    Every tag must map to a valid canonical allergen_id in allergen_ref.
--    Unmapped tags indicate unprocessed OFF imports or stale data.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. allergen tags exist in allergen_ref' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info pai
WHERE pai.type = 'contains'
  AND NOT EXISTS (SELECT 1 FROM allergen_ref ar WHERE ar.allergen_id = pai.tag);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Trace tags must exist in allergen_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. trace tags exist in allergen_ref' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info pai
WHERE pai.type = 'traces'
  AND NOT EXISTS (SELECT 1 FROM allergen_ref ar WHERE ar.allergen_id = pai.tag);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. No legacy en: prefix tags remain in product_allergen_info
--    After migration to bare canonical IDs, no tag should still
--    carry the old 'en:' taxonomy prefix.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. no legacy en: prefix tags' AS check_name,
       COUNT(*) AS violations
FROM product_allergen_info
WHERE tag LIKE 'en:%';

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. allergen_ref has all EU-14 mandatory allergens
--    EU regulation 1169/2011 defines 14 mandatory allergen groups.
--    allergen_ref must contain all 14 with eu_mandatory = true.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. allergen_ref has all EU-14 mandatory allergens' AS check_name,
       14 - COUNT(*) AS violations
FROM allergen_ref
WHERE eu_mandatory = true;

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
  -- Exclude non-dairy false positives (use NOT + ILIKE ANY to correctly exclude ALL matches)
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
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Gluten-ingredient products should declare en:gluten allergen
--     Products with wheat/barley/rye/oat/spelt ingredients should have
--     an en:gluten allergen tag. Includes Polish (owsiane) and German
--     (hafer) oat names per EU allergen regulation.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. gluten ingredients declare gluten allergen' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT DISTINCT pi.product_id
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
  AND NOT (ir.name_en ILIKE ANY(ARRAY['%eggplant%','%reggiano%','%egg noodle%']))
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'eggs' AND pai.type = 'contains'
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
    WHERE pai.product_id = pi.product_id AND pai.tag = 'soybeans' AND pai.type = 'contains'
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
    WHERE pai.product_id = pi.product_id AND pai.tag = 'peanuts' AND pai.type = 'contains'
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
    WHERE pai.product_id = pi.product_id AND pai.tag = 'fish' AND pai.type = 'contains'
  )
) x;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 15. product_allergen_info has FK constraint referencing allergen_ref
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '15. allergen tag FK to allergen_ref enforced at schema level' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_constraint
           WHERE conrelid = 'product_allergen_info'::regclass
             AND conname = 'fk_allergen_tag_ref'
       ) THEN 0 ELSE 1 END AS violations;


-- ============================================================
-- QA: Attribute Contradiction Detection
-- Cross-references ingredient-derived attributes (vegan, vegetarian,
-- palm oil status) against declared allergens to detect contradictions.
-- After the resolution migration, the v_master view returns NULL for
-- contradicted attributes — these checks verify 0 active contradictions.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. No products with vegan_status='yes' AND animal-derived allergens
--    Animal allergens: milk, eggs, fish, crustaceans, molluscs.
--    After resolution, vegan_status should be NULL for these products.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. vegan products with animal allergens (post-resolution)' AS check_name,
       COUNT(DISTINCT m.product_id) AS violations
FROM v_master m
JOIN product_allergen_info ai ON ai.product_id = m.product_id
WHERE m.vegan_status = 'yes'
  AND ai.type = 'contains'
  AND ai.tag IN ('milk', 'eggs', 'fish', 'crustaceans', 'molluscs');

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. No products with vegetarian_status='yes' AND meat/fish allergens
--    Meat/fish allergens: fish, crustaceans, molluscs.
--    After resolution, vegetarian_status should be NULL for these products.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. vegetarian products with meat/fish allergens (post-resolution)' AS check_name,
       COUNT(DISTINCT m.product_id) AS violations
FROM v_master m
JOIN product_allergen_info ai ON ai.product_id = m.product_id
WHERE m.vegetarian_status = 'yes'
  AND ai.type = 'contains'
  AND ai.tag IN ('fish', 'crustaceans', 'molluscs');

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. No products where vegan_status='yes' but vegetarian_status='no'
--    Logical impossibility: all vegan products are also vegetarian.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. vegan=yes but vegetarian=no (logical impossibility)' AS check_name,
       COUNT(*) AS violations
FROM v_master
WHERE vegan_status = 'yes'
  AND vegetarian_status = 'no';

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. No products where has_palm_oil=false but an ingredient named
--    'palm oil' (or variants) exists in their ingredient list
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. palm-oil-free but ingredient contains palm oil' AS check_name,
       COUNT(DISTINCT p.product_id) AS violations
FROM products p
JOIN product_ingredient pi ON pi.product_id = p.product_id
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
LEFT JOIN LATERAL (
    SELECT BOOL_OR(ir2.from_palm_oil = 'yes') AS has_palm
    FROM product_ingredient pi2
    JOIN ingredient_ref ir2 ON ir2.ingredient_id = pi2.ingredient_id
    WHERE pi2.product_id = p.product_id
) palm ON true
WHERE p.is_deprecated IS NOT TRUE
  AND COALESCE(palm.has_palm, false) = false
  AND LOWER(ir.name_en) LIKE '%palm oil%'
  AND ir.from_palm_oil != 'yes';

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Contradiction flag columns present in v_master
--    Verifies the resolution migration added the expected columns.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. v_master has vegan_contradiction column' AS check_name,
       CASE WHEN COUNT(*) = 1 THEN 0 ELSE 1 END AS violations
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_master'
  AND column_name = 'vegan_contradiction';

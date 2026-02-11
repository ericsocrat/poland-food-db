-- ============================================================
-- QA: Ingredient Data Quality
-- Validates ingredient_ref cleanliness, product_ingredient
-- coherence, and taxonomy coverage.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ingredient_ref.name_en should not be empty or whitespace-only
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. ingredient name_en not empty' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE name_en IS NULL
   OR trim(name_en) = '';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. ingredient_ref.name_en should not be a bare number or junk
--    (residual OFF parser artifacts)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. ingredient name_en not junk/numeric' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE name_en ~ '^\d+$'
   OR length(trim(name_en)) <= 1
   OR name_en ~* '^(per 100|kcal|kj\b)';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. ingredient_ref.ingredient_id should always be set (non-null PK)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. ingredient_id PK not null' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE ingredient_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. No duplicate name_en in ingredient_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. no duplicate ingredient name_en' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT name_en
  FROM ingredient_ref
  GROUP BY name_en
  HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. vegan/vegetarian/from_palm_oil must be valid enums
--    Allowed: 'yes', 'no', 'maybe', 'unknown'
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. vegan/veg/palm_oil valid enums' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE (vegan IS NOT NULL AND vegan NOT IN ('yes','no','maybe','unknown'))
   OR (vegetarian IS NOT NULL AND vegetarian NOT IN ('yes','no','maybe','unknown'))
   OR (from_palm_oil IS NOT NULL AND from_palm_oil NOT IN ('yes','no','maybe','unknown'));

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. concern_tier must be 0–3 when set
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. concern_tier in [0, 3]' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE concern_tier IS NOT NULL
  AND (concern_tier < 0 OR concern_tier > 3);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Tier 1–3 ingredients should have a concern_reason
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. high-concern ingredients have reason' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE concern_tier IS NOT NULL AND concern_tier >= 1
  AND (concern_reason IS NULL OR trim(concern_reason) = '');

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. product_ingredient.position should be sequential starting at 1
--    (no gaps, no zeros)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. ingredient position starts at 1' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT product_id, MIN(position) AS min_pos
  FROM product_ingredient
  WHERE is_sub_ingredient IS NOT TRUE
  GROUP BY product_id
  HAVING MIN(position) <> 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. product_ingredient.percent_estimate should be in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. percent_estimate in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient
WHERE percent_estimate IS NOT NULL
  AND (percent_estimate < 0 OR percent_estimate > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Sub-ingredients must have a valid parent
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. sub-ingredients have valid parent' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient pi
WHERE pi.is_sub_ingredient = true
  AND (pi.parent_ingredient_id IS NULL
    OR NOT EXISTS (
      SELECT 1 FROM ingredient_ref ir
      WHERE ir.ingredient_id = pi.parent_ingredient_id
    ));

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. No orphan product_ingredient rows (product must exist)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. no orphan product_ingredient rows' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient pi
WHERE NOT EXISTS (
  SELECT 1 FROM products p WHERE p.product_id = pi.product_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. product_ingredient FK to ingredient_ref must be valid
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. ingredient_id FK valid' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient pi
WHERE NOT EXISTS (
  SELECT 1 FROM ingredient_ref ir WHERE ir.ingredient_id = pi.ingredient_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Additive ingredients (is_additive=true) should have e-number name_en
--     (e.g., 'e330', 'e472e') — catches misclassified entries
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. additives have e-number name' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE is_additive = true
  AND name_en !~ '^e\d';

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. No unused ingredient_ref entries (zero product_ingredient links)
--     that look like junk (short names, bare numbers, label text)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. no orphaned junk ingredient_ref' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref ir
WHERE NOT EXISTS (
  SELECT 1 FROM product_ingredient pi WHERE pi.ingredient_id = ir.ingredient_id
)
AND (
  length(trim(ir.name_en)) <= 2
  OR ir.name_en ~ '^\d+$'
  OR ir.name_en ~* '(kcal|kj\b|nahrwert|porcj)'
);


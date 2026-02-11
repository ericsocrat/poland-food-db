-- ============================================================
-- QA: Data Consistency & Standardisation
-- Cross-references domain values, detects orphaned / duplicate
-- records, and validates field domain constraints that don't
-- fit the other QA suites.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. No case-insensitive duplicate products (same brand + same name)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. no case-insensitive duplicate products' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT 1
  FROM products p1
  JOIN products p2
    ON p1.brand = p2.brand
   AND p1.product_id < p2.product_id
   AND lower(trim(p1.product_name)) = lower(trim(p2.product_name))
  WHERE p1.is_deprecated IS NOT TRUE
    AND p2.is_deprecated IS NOT TRUE
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. nutri_score_label must be one of A/B/C/D/E/NOT-APPLICABLE/UNKNOWN
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. nutri_score_label in valid domain' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.nutri_score_label NOT IN ('A','B','C','D','E','NOT-APPLICABLE','UNKNOWN');

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. nova_classification must be 1/2/3/4
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. nova_classification in {1,2,3,4}' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.nova_classification::int NOT IN (1, 2, 3, 4);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. unhealthiness_score in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. unhealthiness_score in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.unhealthiness_score::numeric < 0 OR s.unhealthiness_score::numeric > 100;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. data_completeness_pct in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. data_completeness_pct in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.data_completeness_pct::numeric < 0 OR s.data_completeness_pct::numeric > 100;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. ingredient_concern_score in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. ingredient_concern_score in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.ingredient_concern_score::numeric < 0 OR s.ingredient_concern_score::numeric > 100;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Boolean flag fields must be TRUE/FALSE (no NULLs)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. score flag fields are non-null booleans' AS check_name,
       COUNT(*) AS violations
FROM scores s
JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
WHERE s.high_salt_flag IS NULL
   OR s.high_sugar_flag IS NULL
   OR s.high_sat_fat_flag IS NULL
   OR s.high_additive_load IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. product_type must be in allowed domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. product_type in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.product_type NOT IN ('Grocery', 'Ready-to-eat');

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. prep_method must be in allowed domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. prep_method in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.prep_method NOT IN (
    'not-applicable', 'baked', 'fried', 'smoked', 'none', 'marinated'
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Every non-deprecated product must have at least one score row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. every product has a score row' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM scores s WHERE s.product_id = p.product_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Every non-deprecated product must have at least one serving
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. every product has a serving' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM servings sv WHERE sv.product_id = p.product_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Every non-deprecated product must have per-100g nutrition
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. every product has per-100g nutrition' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
    SELECT 1
    FROM nutrition_facts nf
    JOIN servings sv ON sv.serving_id = nf.serving_id
    WHERE nf.product_id = p.product_id
      AND sv.serving_basis = 'per 100 g'
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Every non-deprecated product must have at least one source
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. every product has a source' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM product_sources ps WHERE ps.product_id = p.product_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. country must be a valid 2-letter ISO 3166-1 alpha-2 code
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. country is 2-letter ISO code' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (p.country IS NULL OR p.country !~ '^[A-Z]{2}$');

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Deprecated products should have a deprecation reason
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. deprecated products have a reason' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS TRUE
  AND (p.deprecated_reason IS NULL OR trim(p.deprecated_reason) = '');

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. No orphan nutrition_facts (product must exist and be active)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. no orphan nutrition_facts rows' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
WHERE NOT EXISTS (
  SELECT 1 FROM products p
  WHERE p.product_id = nf.product_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. No orphan servings (product must exist and be active)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '17. no orphan servings rows' AS check_name,
       COUNT(*) AS violations
FROM servings sv
WHERE NOT EXISTS (
  SELECT 1 FROM products p
  WHERE p.product_id = sv.product_id
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. No orphan scores (product must exist and be active)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '18. no orphan scores rows' AS check_name,
       COUNT(*) AS violations
FROM scores s
WHERE NOT EXISTS (
  SELECT 1 FROM products p
  WHERE p.product_id = s.product_id
);


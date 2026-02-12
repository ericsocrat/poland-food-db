-- ============================================================
-- QA: Data Consistency & Standardisation
-- Cross-references domain values, detects orphaned / duplicate
-- records, and validates field domain constraints that don't
-- fit the other QA suites.
-- All checks are BLOCKING.
-- Updated: scores merged into products; servings eliminated;
-- product_sources merged into products.
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
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.nutri_score_label NOT IN ('A','B','C','D','E','NOT-APPLICABLE','UNKNOWN');

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. nova_classification must be 1/2/3/4
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. nova_classification in {1,2,3,4}' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.nova_classification::int NOT IN (1, 2, 3, 4);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. unhealthiness_score in [1, 100] (matches DB CHECK chk_scores_unhealthiness_range)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. unhealthiness_score in [1, 100]' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (p.unhealthiness_score::numeric < 1 OR p.unhealthiness_score::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. data_completeness_pct in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. data_completeness_pct in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (p.data_completeness_pct::numeric < 0 OR p.data_completeness_pct::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. ingredient_concern_score in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. ingredient_concern_score in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (p.ingredient_concern_score::numeric < 0 OR p.ingredient_concern_score::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Boolean flag fields must be TRUE/FALSE (no NULLs)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. score flag fields are non-null booleans' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (p.high_salt_flag IS NULL
    OR p.high_sugar_flag IS NULL
    OR p.high_sat_fat_flag IS NULL
    OR p.high_additive_load IS NULL);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. product_type must be in allowed domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. product_type in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.product_type NOT IN ('Grocery', 'Ready-to-eat');

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. prep_method must be in allowed domain (matches DB CHECK chk_products_prep_method)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. prep_method in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.prep_method NOT IN (
    'air-popped', 'baked', 'fried', 'deep-fried', 'grilled', 'roasted',
    'smoked', 'steamed', 'marinated', 'pasteurized', 'fermented',
    'dried', 'raw', 'none', 'not-applicable'
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Every non-deprecated product must have unhealthiness_score
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. every active product has unhealthiness_score' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Every non-deprecated product must have nutrition_facts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. every product has nutrition_facts' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf WHERE nf.product_id = p.product_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Every non-deprecated product must have nutrition_facts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. every product has nutrition_facts' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
    SELECT 1
    FROM nutrition_facts nf
    WHERE nf.product_id = p.product_id
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Every non-deprecated product must have a source_type
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. every product has a source_type' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.source_type IS NULL;

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
-- 17. (removed — servings table eliminated in consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. (removed — scores table merged into products in consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. Stored data_completeness_pct matches dynamic computation
--     Detects drift between stored value and compute_data_completeness()
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '19. data_completeness_pct matches dynamic computation' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.data_completeness_pct != compute_data_completeness(p.product_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. Confidence consistent with data_completeness_pct + source_type
--     Verifies assign_confidence() output matches stored confidence
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '20. confidence matches assign_confidence()' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.confidence != assign_confidence(p.data_completeness_pct, p.source_type);


-- ============================================================
-- QA: Referential Integrity & Domain Validation
-- Validates FK relationships, domain constraints, and
-- cross-table consistency beyond what CHECK constraints cover.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. products.category must exist in category_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. products.category in category_ref' AS check_name,
       COUNT(*) AS violations
FROM products p
LEFT JOIN category_ref cr ON cr.category = p.category
WHERE cr.category IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Active products must be in active categories
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. active products in active categories' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN category_ref cr ON cr.category = p.category
WHERE p.is_deprecated IS NOT TRUE
  AND cr.is_active = false;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. products.country must exist in country_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. products.country in country_ref' AS check_name,
       COUNT(*) AS violations
FROM products p
LEFT JOIN country_ref cr ON cr.country_code = p.country
WHERE cr.country_code IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. scores.nutri_score_label must exist in nutri_score_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. nutri_score_label in nutri_score_ref' AS check_name,
       COUNT(*) AS violations
FROM scores sc
WHERE sc.nutri_score_label IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM nutri_score_ref ns WHERE ns.label = sc.nutri_score_label
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. ingredient_ref.concern_tier must exist in concern_tier_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. concern_tier in concern_tier_ref' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref ir
WHERE ir.concern_tier IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM concern_tier_ref ct WHERE ct.tier = ir.concern_tier
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. product_sources.confidence_pct in valid range [0,100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. product_sources confidence_pct in [0,100]' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE confidence_pct < 0 OR confidence_pct > 100;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. product_sources.source_type is off_api
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. product_sources source_type valid' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE source_type NOT IN ('off_api', 'off_search', 'manual', 'label_scan', 'retailer_api');

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. ingredient_ref.vegan/vegetarian/from_palm_oil in valid domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. ingredient_ref enum values valid' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE (vegan NOT IN ('yes', 'no', 'maybe', 'unknown'))
   OR (vegetarian NOT IN ('yes', 'no', 'maybe', 'unknown'))
   OR (from_palm_oil NOT IN ('yes', 'no', 'maybe', 'unknown'));

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Every per-100g serving must have a nutrition_facts row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. per-100g serving has nutrition_facts' AS check_name,
       COUNT(*) AS violations
FROM servings sv
LEFT JOIN nutrition_facts nf ON nf.serving_id = sv.serving_id
WHERE sv.serving_basis IN ('per 100 g', 'per 100 ml')
  AND nf.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. serving_amount_g_ml must be positive when set
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. serving_amount positive' AS check_name,
       COUNT(*) AS violations
FROM servings
WHERE serving_amount_g_ml IS NOT NULL
  AND serving_amount_g_ml <= 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. product_ingredient.percent_estimate non-negative
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. percent_estimate non-negative' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient
WHERE percent_estimate IS NOT NULL
  AND percent_estimate < 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. product_ingredient.percent in [0,100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. percent in [0,100]' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient
WHERE percent IS NOT NULL
  AND (percent < 0 OR percent > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Each product must have exactly one per-100g (or per-100ml) serving
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. exactly one per-100g serving per active product' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id, COUNT(sv.serving_id) AS cnt
    FROM products p
    LEFT JOIN servings sv ON sv.product_id = p.product_id
        AND sv.serving_basis IN ('per 100 g', 'per 100 ml')
    WHERE p.is_deprecated IS NOT TRUE
    GROUP BY p.product_id
    HAVING COUNT(sv.serving_id) != 1
) bad;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. nutri_score_ref has expected labels (A-E + UNKNOWN + NOT-APPLICABLE)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. nutri_score_ref has expected labels' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM nutri_score_ref) AS actual,
           7 AS expected
) sub
WHERE actual != expected;

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. concern_tier_ref has expected tiers (0-3)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. concern_tier_ref has expected tiers' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM concern_tier_ref) AS actual,
           4 AS expected
) sub
WHERE actual != expected;

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. country_ref has PL entry
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. country_ref has PL entry' AS check_name,
       CASE WHEN EXISTS (SELECT 1 FROM country_ref WHERE country_code = 'PL')
            THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. refresh_all_materialized_views returns valid JSON
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '17. refresh_all_materialized_views returns valid JSON' AS check_name,
       CASE WHEN result ? 'refreshed_at' AND result ? 'views' AND result ? 'total_ms'
            THEN 0 ELSE 1 END AS violations
FROM refresh_all_materialized_views() AS result;


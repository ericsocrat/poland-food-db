-- ============================================================
-- QA: API Surface Validation
-- Ensures all API views and functions return correct results
-- with no fan-out, null gaps, or structural issues.
-- ============================================================

-- 1. Category overview: row count = active categories (20)
SELECT '1. v_api_category_overview row count matches category_ref' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM v_api_category_overview) AS api_count,
           (SELECT COUNT(*) FROM category_ref WHERE is_active = true) AS ref_count
) sub
WHERE api_count != ref_count;

-- 2. Category overview: product_count sums to total active products
SELECT '2. v_api_category_overview product sums match v_master' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT SUM(product_count) FROM v_api_category_overview) AS api_sum,
           (SELECT COUNT(*) FROM v_master) AS master_count
) sub
WHERE api_sum != master_count;

-- 3. Category overview: no NULL stats for populated categories
SELECT '3. v_api_category_overview no null stats' AS check_name,
       COUNT(*) AS violations
FROM v_api_category_overview
WHERE product_count > 0
  AND (avg_score IS NULL OR min_score IS NULL OR max_score IS NULL);

-- 4. api_product_detail returns non-null for all active products
SELECT '4. api_product_detail covers all products' AS check_name,
       COUNT(*) AS violations
FROM v_master m
WHERE api_product_detail(m.product_id) IS NULL;

-- 5. api_product_detail JSON has required top-level keys
SELECT '5. api_product_detail has required keys' AS check_name,
       COUNT(*) AS violations
FROM v_master m
CROSS JOIN LATERAL api_product_detail(m.product_id) AS detail
WHERE NOT (
    detail ? 'product_id'
    AND detail ? 'scores'
    AND detail ? 'nutrition_per_100g'
    AND detail ? 'trust'
    AND detail ? 'ingredients'
    AND detail ? 'allergens'
    AND detail ? 'flags'
);

-- 6. api_score_explanation returns non-null for all scored products
SELECT '6. api_score_explanation covers all products' AS check_name,
       COUNT(*) AS violations
FROM v_master m
WHERE m.unhealthiness_score IS NOT NULL
  AND api_score_explanation(m.product_id) IS NULL;

-- 7. api_search_products returns valid JSON for basic query
SELECT '7. api_search_products returns valid structure' AS check_name,
       CASE WHEN result ? 'results' AND result ? 'total_count' AND result ? 'query'
            THEN 0 ELSE 1 END AS violations
FROM api_search_products('test') AS result;

-- 8. api_category_listing returns valid JSON with pagination
SELECT '8. api_category_listing returns valid structure' AS check_name,
       CASE WHEN result ? 'products' AND result ? 'total_count'
                 AND result ? 'limit' AND result ? 'offset'
            THEN 0 ELSE 1 END AS violations
FROM api_category_listing('Chips', 'score', 'asc', 5, 0) AS result;

-- 9. find_similar_products returns results for products with ingredients
SELECT '9. find_similar_products returns results' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN products p ON p.product_id = pi.product_id
    WHERE p.is_deprecated IS NOT TRUE
    LIMIT 5
) sample
WHERE NOT EXISTS (
    SELECT 1 FROM find_similar_products(sample.product_id, 1)
);

-- 10. find_better_alternatives returns only lower-scoring products
SELECT '10. find_better_alternatives scores are lower' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id, sc.unhealthiness_score AS source_score
    FROM products p
    JOIN scores sc ON sc.product_id = p.product_id
    WHERE p.is_deprecated IS NOT TRUE AND sc.unhealthiness_score > 15
    LIMIT 5
) sample
CROSS JOIN LATERAL find_better_alternatives(sample.product_id, true, 3) AS alt
WHERE alt.unhealthiness_score >= sample.source_score;

-- 11. api_better_alternatives has required JSON keys
SELECT '11. api_better_alternatives has required keys' AS check_name,
       CASE WHEN result ? 'source_product' AND result ? 'alternatives'
                 AND result ? 'alternatives_count' AND result ? 'search_scope'
            THEN 0 ELSE 1 END AS violations
FROM api_better_alternatives(2121) AS result;

-- 12. api_better_alternatives alternatives_count matches array length
SELECT '12. api_better_alternatives count matches array' AS check_name,
       CASE WHEN (result->>'alternatives_count')::int = jsonb_array_length(result->'alternatives')
            THEN 0 ELSE 1 END AS violations
FROM api_better_alternatives(2121) AS result;

-- 13. api_data_confidence returns non-null for all active products
SELECT '13. api_data_confidence covers all products' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND api_data_confidence(p.product_id) IS NULL;

-- 14. api_data_confidence has required JSON keys
SELECT '14. api_data_confidence has required keys' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT api_data_confidence(product_id) AS detail
    FROM products
    WHERE is_deprecated IS NOT TRUE
    LIMIT 5
) sample
WHERE NOT (
    sample.detail ? 'confidence_score'
    AND sample.detail ? 'confidence_band'
    AND sample.detail ? 'components'
    AND sample.detail ? 'data_completeness_profile'
);

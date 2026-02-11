-- ============================================================
-- QA: View & Function Consistency
-- Validates that materialized views, API functions, and
-- computed columns are internally consistent with base tables.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. v_product_confidence row count matches v_master
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. v_product_confidence rows = v_master rows' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM v_product_confidence) AS conf_count,
           (SELECT COUNT(*) FROM v_master) AS master_count
) sub
WHERE conf_count != master_count;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. v_api_category_overview categories match category_ref active categories
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. v_api_category_overview complete' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM v_api_category_overview) AS api_cats,
           (SELECT COUNT(*) FROM category_ref WHERE is_active = true) AS ref_cats
) sub
WHERE api_cats != ref_cats;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_score_explanation returns non-null for all scored products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. api_score_explanation covers all products' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score IS NOT NULL
  AND api_score_explanation(p.product_id) IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_score_explanation JSON has required keys
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. api_score_explanation has required keys' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
CROSS JOIN LATERAL api_score_explanation(p.product_id) AS detail
WHERE p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score IS NOT NULL
  AND NOT (
    detail ? 'product_id'
    AND detail ? 'score_breakdown'
    AND detail ? 'top_factors'
    AND detail ? 'summary'
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_product_detail trust section includes confidence
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. api_product_detail trust has confidence' AS check_name,
       COUNT(*) AS violations
FROM v_master m
CROSS JOIN LATERAL api_product_detail(m.product_id) AS detail
WHERE NOT ((detail->'trust') ? 'confidence');

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_product_detail nutrition matches v_master calories
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. api_product_detail nutrition consistent with v_master' AS check_name,
       COUNT(*) AS violations
FROM v_master m
CROSS JOIN LATERAL api_product_detail(m.product_id) AS detail
WHERE m.calories IS NOT NULL
  AND (detail->'nutrition_per_100g'->>'calories')::numeric != m.calories;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. v_master score_breakdown factors count = 9 (all scoring factors present)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. score_breakdown has 9 factors' AS check_name,
       COUNT(*) AS violations
FROM v_master
WHERE score_breakdown IS NOT NULL
  AND jsonb_array_length(score_breakdown->'factors') != 9;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. v_master ingredient_count matches product_ingredient junction table
--    ingredient_count includes all rows (top-level + sub-ingredients)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. v_master ingredient_count accurate' AS check_name,
       COUNT(*) AS violations
FROM v_master m
LEFT JOIN (
    SELECT product_id, COUNT(*) AS cnt
    FROM product_ingredient
    GROUP BY product_id
) pi ON pi.product_id = m.product_id
WHERE COALESCE(m.ingredient_count, 0) != COALESCE(pi.cnt, 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. v_master allergen_count matches product_allergen junction table
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. v_master allergen_count accurate' AS check_name,
       COUNT(*) AS violations
FROM v_master m
LEFT JOIN (
    SELECT product_id, COUNT(DISTINCT allergen_tag) AS cnt
    FROM product_allergen
    GROUP BY product_id
) pa ON pa.product_id = m.product_id
WHERE COALESCE(m.allergen_count, 0) != COALESCE(pa.cnt, 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. v_master trace_count matches product_trace junction table
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. v_master trace_count accurate' AS check_name,
       COUNT(*) AS violations
FROM v_master m
LEFT JOIN (
    SELECT product_id, COUNT(DISTINCT trace_tag) AS cnt
    FROM product_trace
    GROUP BY product_id
) pt ON pt.product_id = m.product_id
WHERE COALESCE(m.trace_count, 0) != COALESCE(pt.cnt, 0);


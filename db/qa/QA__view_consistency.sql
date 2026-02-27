-- ============================================================
-- QA: View & Function Consistency
-- Validates that materialized views, API functions, and
-- computed columns are internally consistent with base tables.
-- All checks are BLOCKING.
-- Updated: scores merged into products; product_allergen and
-- product_trace merged into product_allergen_info.
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
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NOT NULL
  AND api_score_explanation(p.product_id) IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_score_explanation JSON has required keys
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. api_score_explanation has required keys' AS check_name,
       COUNT(*) AS violations
FROM products p
CROSS JOIN LATERAL api_score_explanation(p.product_id) AS detail
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NOT NULL
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
-- 9. v_master allergen_count matches product_allergen_info (type='contains')
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. v_master allergen_count accurate' AS check_name,
       COUNT(*) AS violations
FROM v_master m
LEFT JOIN (
    SELECT product_id, COUNT(DISTINCT tag) AS cnt
    FROM product_allergen_info
    WHERE type = 'contains'
    GROUP BY product_id
) pai ON pai.product_id = m.product_id
WHERE COALESCE(m.allergen_count, 0) != COALESCE(pai.cnt, 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. v_master trace_count matches product_allergen_info (type='traces')
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. v_master trace_count accurate' AS check_name,
       COUNT(*) AS violations
FROM v_master m
LEFT JOIN (
    SELECT product_id, COUNT(DISTINCT tag) AS cnt
    FROM product_allergen_info
    WHERE type = 'traces'
    GROUP BY product_id
) pai ON pai.product_id = m.product_id
WHERE COALESCE(m.trace_count, 0) != COALESCE(pai.cnt, 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. mv_ingredient_frequency row count = used ingredient_ref count
--     MV uses INNER JOIN to product_ingredient + non-deprecated products,
--     so unused ingredients are excluded by design.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. mv_ingredient_frequency row count matches used ingredients' AS check_name,
       ABS(
         (SELECT COUNT(*) FROM mv_ingredient_frequency) -
         (SELECT COUNT(DISTINCT ir.ingredient_id)
          FROM ingredient_ref ir
          JOIN product_ingredient pi ON pi.ingredient_id = ir.ingredient_id
          JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE)
       ) AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. mv_ingredient_frequency product_count accuracy (spot-check top-5)
--     For each of the 5 most-used ingredients, the MV count should match
--     the actual product_ingredient count.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. mv_ingredient_frequency counts accurate' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT mv.ingredient_id, mv.product_count,
         (SELECT COUNT(DISTINCT pi.product_id)
          FROM product_ingredient pi
          JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
          WHERE pi.ingredient_id = mv.ingredient_id) AS actual
  FROM mv_ingredient_frequency mv
  ORDER BY mv.product_count DESC
  LIMIT 5
) x
WHERE x.product_count <> x.actual;

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. v_master column count matches expected (drift detection)
--     v_master should have exactly 55 columns.  If a migration adds or
--     removes columns without updating the reference, this catches it.
--     Original 47 + 5 from localization phases 2 & 4:
--       product_name_en, product_name_en_source, created_at, updated_at, name_translations
--     + 3 from 2026-02-22 migrations:
--       image_thumb_url, vegan_contradiction, vegetarian_contradiction
--     + 1 from #353: nutri_score_source
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. v_master has expected column count (58)' AS check_name,
       ABS(58 - COUNT(*)) AS violations
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_master';

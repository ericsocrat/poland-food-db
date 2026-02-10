-- ============================================================
-- QA: Confidence & Completeness Scoring
-- Validates the composite data confidence score (0-100),
-- band assignments (high/medium/low), and data completeness
-- profiles for all active products.
-- ============================================================

-- 1. MV row count matches active products
SELECT '1. v_product_confidence row count matches active products' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT (SELECT COUNT(*) FROM v_product_confidence) AS mv_count,
           (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS product_count
) sub
WHERE mv_count != product_count;

-- 2. Confidence scores within valid range (0-100)
SELECT '2. confidence_score within 0-100' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE confidence_score < 0 OR confidence_score > 100;

-- 3. Confidence band matches score range
SELECT '3. confidence_band matches score thresholds' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE (confidence_band = 'high'   AND confidence_score < 80)
   OR (confidence_band = 'medium' AND (confidence_score >= 80 OR confidence_score < 50))
   OR (confidence_band = 'low'    AND confidence_score >= 50);

-- 4. Component sub-scores within allowed ranges
SELECT '4. component sub-scores within max ranges' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE nutrition_pts   < 0 OR nutrition_pts   > 30
   OR ingredient_pts  < 0 OR ingredient_pts  > 25
   OR source_pts      < 0 OR source_pts      > 20
   OR ean_pts         < 0 OR ean_pts         > 10
   OR allergen_pts    < 0 OR allergen_pts    > 10
   OR serving_pts     < 0 OR serving_pts     > 5;

-- 5. Component sum equals confidence_score
SELECT '5. component sum equals confidence_score' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE (nutrition_pts + ingredient_pts + source_pts + ean_pts + allergen_pts + serving_pts)
      != confidence_score;

-- 6. compute_data_confidence() returns non-null for all active products
SELECT '6. compute_data_confidence covers all products' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND compute_data_confidence(p.product_id) IS NULL;

-- 7. compute_data_confidence() has required JSON keys
SELECT '7. compute_data_confidence has required keys' AS check_name,
       COUNT(*) AS violations
FROM products p
CROSS JOIN LATERAL compute_data_confidence(p.product_id) AS detail
WHERE p.is_deprecated IS NOT TRUE
  AND NOT (
    detail ? 'confidence_score'
    AND detail ? 'confidence_band'
    AND detail ? 'components'
    AND detail ? 'data_completeness_profile'
    AND detail ? 'missing_data'
    AND detail ? 'explanation'
  );

-- 8. Function score matches MV score (consistency)
SELECT '8. function score matches MV score' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence vc
JOIN LATERAL compute_data_confidence(vc.product_id) AS fn ON true
WHERE (fn->>'confidence_score')::int != vc.confidence_score;

-- 9. Completeness profile values are valid enums
SELECT '9. completeness profile values are valid' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE ingredient_status NOT IN ('complete', 'partial', 'missing')
   OR nutrition_status NOT IN ('full', 'partial', 'missing')
   OR allergen_status NOT IN ('known', 'unknown');

-- 10. No NULL confidence_band
SELECT '10. no null confidence_band' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE confidence_band IS NULL;

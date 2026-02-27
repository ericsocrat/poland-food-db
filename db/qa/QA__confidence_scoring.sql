-- ============================================================
-- QA: Confidence & Completeness Scoring — 14 checks
-- Validates the composite data confidence score (0-100),
-- band assignments (high/medium/low), and data completeness
-- profiles for all active products.
-- Checks 11-13: regression guards against mono-modal confidence
-- Check 14: high-band population threshold (#445)
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
SELECT '2. total_confidence within 0-100' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE total_confidence < 0 OR total_confidence > 100;

-- 3. Confidence band matches score range
SELECT '3. confidence_band matches score thresholds' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE (confidence_band = 'high'   AND total_confidence < 80)
   OR (confidence_band = 'medium' AND (total_confidence >= 80 OR total_confidence < 50))
   OR (confidence_band = 'low'    AND total_confidence >= 50);

-- 4. Component sub-scores within allowed ranges
SELECT '4. component sub-scores within max ranges' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE nutrition_pts         < 0 OR nutrition_pts         > 30
   OR ingredient_pts        < 0 OR ingredient_pts        > 25
   OR source_pts            < 0 OR source_pts            > 20
   OR ean_pts               < 0 OR ean_pts               > 10
   OR allergen_pts          < 0 OR allergen_pts          > 10;

-- 5. Component sum equals total_confidence (capped at 100)
SELECT '5. component sum equals total_confidence' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE LEAST(nutrition_pts + ingredient_pts + source_pts
            + ean_pts + allergen_pts, 100)
      != total_confidence;

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
WHERE (fn->>'confidence_score')::int != vc.total_confidence;

-- 9. Completeness profile values are valid enums (via function)
SELECT '9. completeness profile values are valid' AS check_name,
       COUNT(*) AS violations
FROM products p
CROSS JOIN LATERAL compute_data_confidence(p.product_id) AS fn
WHERE p.is_deprecated IS NOT TRUE
  AND (
    fn->'data_completeness_profile'->>'ingredients' NOT IN ('complete', 'partial', 'missing')
    OR fn->'data_completeness_profile'->>'nutrition' NOT IN ('full', 'partial', 'missing')
    OR fn->'data_completeness_profile'->>'allergens' NOT IN ('known', 'unknown')
  );

-- 10. No NULL confidence_band
SELECT '10. no null confidence_band' AS check_name,
       COUNT(*) AS violations
FROM v_product_confidence
WHERE confidence_band IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- Confidence distribution regression guards (#344)
-- After ingredient enrichment, confidence must never be mono-modal again.
-- ═══════════════════════════════════════════════════════════════════════════

-- 11. Confidence distribution is multi-modal (at least 2 distinct levels)
SELECT '11. confidence is not mono-modal' AS check_name,
       CASE WHEN (
           SELECT COUNT(DISTINCT confidence)
           FROM products
           WHERE is_deprecated IS NOT TRUE AND confidence IS NOT NULL
       ) >= 2 THEN 0 ELSE 1 END AS violations;

-- 12. Verified products exist (regression guard)
SELECT '12. verified products exist' AS check_name,
       CASE WHEN (
           SELECT COUNT(*)
           FROM products
           WHERE is_deprecated IS NOT TRUE AND confidence = 'verified'
       ) > 0 THEN 0 ELSE 1 END AS violations;

-- 13. MV confidence bands are multi-modal (at least 2 distinct bands)
SELECT '13. MV confidence bands are multi-modal' AS check_name,
       CASE WHEN (
           SELECT COUNT(DISTINCT confidence_band)
           FROM v_product_confidence
       ) >= 2 THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- High-band population threshold (#445)
-- After ingredient/allergen enrichment, at least 100 products must
-- reach the "high" confidence band (80+).  Prevents regression to
-- the pre-enrichment state where 0% of products were "high".
-- ═══════════════════════════════════════════════════════════════════════════

-- 14. At least 100 products in "high" confidence band
SELECT '14. at least 100 products in high confidence band' AS check_name,
       CASE WHEN (
           SELECT COUNT(*)
           FROM v_product_confidence
           WHERE confidence_band = 'high'
       ) >= 100 THEN 0 ELSE 1 END AS violations;

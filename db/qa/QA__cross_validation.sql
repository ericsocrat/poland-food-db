-- ============================================================
-- QA: Cross-Validation Checks
-- Validates multi-source nutrition data integrity and
-- cross-validation agreement between independent sources.
-- ============================================================

-- 1. No orphaned source_nutrition rows (must reference active product)
SELECT '1. no orphaned source_nutrition rows' AS check_name,
       COUNT(*) AS violations
FROM source_nutrition sn
LEFT JOIN products p ON p.product_id = sn.product_id
WHERE p.product_id IS NULL
   OR p.is_deprecated = true;

-- 2. source_nutrition source_type has matching product_sources entry
SELECT '2. source_nutrition matches product_sources' AS check_name,
       COUNT(*) AS violations
FROM source_nutrition sn
WHERE NOT EXISTS (
    SELECT 1 FROM product_sources ps
    WHERE ps.product_id = sn.product_id
      AND ps.source_type = sn.source_type
);

-- 3. source_nutrition nutrition values non-negative (where non-null)
SELECT '3. source_nutrition values non-negative' AS check_name,
       COUNT(*) AS violations
FROM source_nutrition
WHERE (calories        IS NOT NULL AND calories        < 0)
   OR (total_fat_g     IS NOT NULL AND total_fat_g     < 0)
   OR (saturated_fat_g IS NOT NULL AND saturated_fat_g < 0)
   OR (trans_fat_g     IS NOT NULL AND trans_fat_g     < 0)
   OR (carbs_g         IS NOT NULL AND carbs_g         < 0)
   OR (sugars_g        IS NOT NULL AND sugars_g        < 0)
   OR (fibre_g         IS NOT NULL AND fibre_g         < 0)
   OR (protein_g       IS NOT NULL AND protein_g       < 0)
   OR (salt_g          IS NOT NULL AND salt_g          < 0);

-- 4. source_nutrition calories in valid range (0-900)
SELECT '4. source_nutrition calories in range 0-900' AS check_name,
       COUNT(*) AS violations
FROM source_nutrition
WHERE calories IS NOT NULL
  AND (calories < 0 OR calories > 900);

-- 5. cross_validate_product() returns valid JSON for multi-source products
SELECT '5. cross_validate_product returns valid JSON' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT DISTINCT sn.product_id
    FROM source_nutrition sn
    GROUP BY sn.product_id
    HAVING COUNT(DISTINCT sn.source_type) >= 2
) multi
WHERE cross_validate_product(multi.product_id) IS NULL
   OR NOT (cross_validate_product(multi.product_id) ? 'status');

-- 6. No multi-source products with <60% agreement (data quality gate)
SELECT '6. multi-source agreement >= 60%' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT DISTINCT sn.product_id
    FROM source_nutrition sn
    GROUP BY sn.product_id
    HAVING COUNT(DISTINCT sn.source_type) >= 2
) multi
CROSS JOIN LATERAL cross_validate_product(multi.product_id) AS cv
WHERE (cv->>'agreement_pct')::int < 60;


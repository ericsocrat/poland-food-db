-- ============================================================
-- QA: Serving & Source Validation
-- Validates serving data, product_sources quality, and
-- cross-references between related tables.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. serving_basis must be in allowed domain
--    Valid values: 'per 100 g', 'per 100 ml', 'per serving'
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. serving_basis in valid domain' AS check_name,
       COUNT(*) AS violations
FROM servings
WHERE serving_basis NOT IN ('per 100 g', 'per 100 ml', 'per serving');

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. serving_amount_g_ml must be positive for per-serving rows
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. per-serving amount is positive' AS check_name,
       COUNT(*) AS violations
FROM servings
WHERE serving_basis = 'per serving'
  AND (serving_amount_g_ml IS NULL OR serving_amount_g_ml <= 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. per-serving amount must be reasonable (1g–5000g)
--    A 5kg serving would be extreme but covers large catering packs
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. per-serving amount in [1, 5000]' AS check_name,
       COUNT(*) AS violations
FROM servings
WHERE serving_basis = 'per serving'
  AND serving_amount_g_ml IS NOT NULL
  AND (serving_amount_g_ml < 1 OR serving_amount_g_ml > 5000);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. product_sources.source_type in valid domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. source_type in valid domain' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE source_type NOT IN ('off_api', 'manual', 'label', 'retailer');

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. product_sources.confidence_pct in [0, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. source confidence_pct in [0, 100]' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE confidence_pct IS NOT NULL
  AND (confidence_pct < 0 OR confidence_pct > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. product_sources.collected_at must not be in the future
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. collected_at not in the future' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE collected_at > NOW() + INTERVAL '1 day';

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. product_sources.collected_at should be after project start (2024-01-01)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. collected_at after project start' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE collected_at < '2024-01-01'::timestamptz;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. product_sources.source_ean should match products.ean when both exist
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. source_ean matches product ean' AS check_name,
       COUNT(*) AS violations
FROM product_sources ps
JOIN products p ON p.product_id = ps.product_id
WHERE ps.source_ean IS NOT NULL
  AND p.ean IS NOT NULL
  AND ps.source_ean <> p.ean;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. product_sources.fields_populated should not be empty array
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. fields_populated is not empty' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE fields_populated IS NULL
   OR array_length(fields_populated, 1) IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Exactly one primary source per product
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. exactly one primary source per product' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT product_id
  FROM product_sources
  WHERE is_primary = true
  GROUP BY product_id
  HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. No duplicate product_sources (same product + source_type)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. no duplicate sources per product+type' AS check_name,
       COUNT(*) AS violations
FROM (
  SELECT product_id, source_type
  FROM product_sources
  GROUP BY product_id, source_type
  HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. controversies field in valid domain (lowercase per CHECK constraint)
--     Must be one of: 'none', 'palm oil', 'minor', 'moderate', 'serious'
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. controversies in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND controversies NOT IN ('none', 'palm oil', 'minor', 'moderate', 'serious');


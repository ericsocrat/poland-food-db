-- ============================================================
-- QA: Serving & Source Validation
-- Validates source data quality and cross-references between
-- related tables.
-- All checks are BLOCKING.
-- Updated: servings table eliminated; product_sources merged
-- into products (source_type, source_url, source_ean columns).
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1–3. (removed — servings table eliminated in consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. source_type must be in valid domain
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. source_type in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE source_type IS NOT NULL
  AND source_type NOT IN ('off_api', 'off_search', 'manual', 'label_scan', 'retailer_api');

-- ═══════════════════════════════════════════════════════════════════════════
-- 5–7. (removed — confidence_pct, collected_at columns eliminated with
--       product_sources table consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. source_ean should match products.ean when both exist
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. source_ean matches product ean' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.source_ean IS NOT NULL
  AND p.ean IS NOT NULL
  AND p.source_ean <> p.ean;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9–11. (removed — fields_populated, is_primary, duplicate source checks
--        eliminated with product_sources table consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. controversies field in valid domain (lowercase per CHECK constraint)
--     Must be one of: 'none', 'palm oil', 'minor', 'moderate', 'serious'
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. controversies in valid domain' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND controversies NOT IN ('none', 'palm oil', 'minor', 'moderate', 'serious');

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. (removed — primary source concept eliminated with product_sources
--      table consolidation)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. store_availability must not be empty string for active products
--     NULL is allowed (store info not yet collected).
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. store_availability not empty string' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND store_availability IS NOT NULL
  AND trim(store_availability) = '';

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. store_availability must not have leading/trailing whitespace
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. store_availability is trimmed' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND store_availability IS NOT NULL
  AND store_availability <> trim(store_availability);

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. source_url should be a valid URL format (http/https)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. source_url is valid URL format' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE source_url IS NOT NULL
  AND source_url !~ '^https?://';


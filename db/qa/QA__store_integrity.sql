-- ============================================================
-- QA: Store Architecture Integrity
-- Validates store_ref and product_store_availability data
-- quality, referential integrity, and business rules.
-- 12 checks — All BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Every product_store_availability.store_id references an active store
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. all junction store_ids reference active stores' AS check_name,
       COUNT(*) AS violations
FROM product_store_availability psa
JOIN store_ref sr ON sr.store_id = psa.store_id
WHERE sr.is_active = false;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. No duplicate store slugs within a country
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. no duplicate store slugs within country' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT country, store_slug, COUNT(*) AS cnt
    FROM store_ref
    GROUP BY country, store_slug
    HAVING COUNT(*) > 1
) dups;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. All store_type values are valid
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. all store_type values valid' AS check_name,
       COUNT(*) AS violations
FROM store_ref
WHERE store_type NOT IN (
    'convenience','supermarket','hypermarket',
    'discounter','specialty','online','drugstore'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Every store_ref.country references active country_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. store countries reference active country_ref' AS check_name,
       COUNT(*) AS violations
FROM store_ref sr
LEFT JOIN country_ref cr ON cr.country_code = sr.country
WHERE cr.country_code IS NULL OR cr.is_active = false;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. No orphan junction rows (product must exist and not be deprecated)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. no orphan junction rows' AS check_name,
       COUNT(*) AS violations
FROM product_store_availability psa
LEFT JOIN products p ON p.product_id = psa.product_id
WHERE p.product_id IS NULL OR p.is_deprecated = true;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. No product has category = 'Żabka' (reclassification complete)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. no products with category Żabka' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE category = 'Żabka'
  AND is_deprecated = false;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Żabka is deactivated in category_ref
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. Żabka deactivated in category_ref' AS check_name,
       COUNT(*) AS violations
FROM category_ref
WHERE category = 'Żabka'
  AND is_active = true;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Every ex-Żabka product has at least 1 store linkage
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. ex-Żabka products have store linkage' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.brand IN ('Żabka', 'Tomcio Paluch', 'Szamamm')
  AND p.is_deprecated = false
  AND NOT EXISTS (
    SELECT 1 FROM product_store_availability psa
    WHERE psa.product_id = p.product_id
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. store_ref has both PL and DE stores
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. store_ref covers PL and DE' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM store_ref WHERE country = 'PL')
    UNION ALL
    SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM store_ref WHERE country = 'DE')
) missing;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. store_slug format is valid (lowercase, hyphens, no spaces)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. store_slug format valid' AS check_name,
       COUNT(*) AS violations
FROM store_ref
WHERE store_slug !~ '^[a-z][a-z0-9-]*$';

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Junction source values are valid
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. junction source values valid' AS check_name,
       COUNT(*) AS violations
FROM product_store_availability
WHERE source IS NOT NULL
  AND source NOT IN ('off_api','manual','user_report','pipeline');

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Backfilled junction row count matches store_availability non-NULL count
--     (products whose store_availability name matches a store_ref entry)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. backfill coverage complete' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.store_availability IS NOT NULL
  AND p.is_deprecated = false
  AND EXISTS (
    SELECT 1 FROM store_ref sr
    WHERE sr.country = p.country AND sr.store_name = p.store_availability
  )
  AND NOT EXISTS (
    SELECT 1 FROM product_store_availability psa
    WHERE psa.product_id = p.product_id
  );

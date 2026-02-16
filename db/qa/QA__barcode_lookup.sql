-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Barcode Lookup
-- Validates the api_product_detail_by_ean scanner endpoint.
-- 6 checks.  All product-dependent checks are guarded for empty-DB safety.
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Known EAN resolves to correct product
--    Guarded: returns 0 when no products with EANs exist.
SELECT '1. known EAN resolves to correct product' AS check_name,
       COALESCE((
           SELECT CASE WHEN (api_product_detail_by_ean(p.ean, p.country))->>'product_name' IS NOT NULL
                       THEN 0 ELSE 1 END
           FROM products p
           WHERE p.ean IS NOT NULL AND p.is_deprecated IS NOT TRUE
           ORDER BY p.product_id
           LIMIT 1
       ), 0) AS violations;

-- 2. Unknown EAN returns found=false
SELECT '2. unknown EAN returns not-found response' AS check_name,
       CASE WHEN (
           api_product_detail_by_ean('0000000000000')
       )->>'found' = 'false'
       THEN 0 ELSE 1 END AS violations;

-- 3. EAN lookup with correct country returns product
--    Guarded: returns 0 when no PL products with EANs exist.
SELECT '3. EAN with correct country returns product' AS check_name,
       COALESCE((
           SELECT CASE WHEN (api_product_detail_by_ean(p.ean, 'PL'))->'scan'->>'found' = 'true'
                       THEN 0 ELSE 1 END
           FROM products p
           WHERE p.ean IS NOT NULL AND p.country = 'PL' AND p.is_deprecated IS NOT TRUE
           LIMIT 1
       ), 0) AS violations;

-- 4. EAN lookup with wrong country returns not-found
--    Guarded: returns 0 when no PL products with EANs exist.
SELECT '4. EAN with wrong country returns not-found' AS check_name,
       COALESCE((
           SELECT CASE WHEN (api_product_detail_by_ean(p.ean, 'XX'))->>'found' = 'false'
                       THEN 0 ELSE 1 END
           FROM products p
           WHERE p.ean IS NOT NULL AND p.country = 'PL' AND p.is_deprecated IS NOT TRUE
           LIMIT 1
       ), 0) AS violations;

-- 5. EAN lookup response includes scan metadata
--    Guarded: returns 0 when no PL products with EANs exist.
SELECT '5. EAN response includes scan metadata' AS check_name,
       COALESCE((
           SELECT CASE WHEN api_product_detail_by_ean(p.ean, 'PL') ? 'scan'
                       THEN 0 ELSE 1 END
           FROM products p
           WHERE p.ean IS NOT NULL AND p.country = 'PL' AND p.is_deprecated IS NOT TRUE
           LIMIT 1
       ), 0) AS violations;

-- 6. EAN lookup response includes api_version
--    Guarded: returns 0 when no products with EANs exist.
SELECT '6. EAN response includes api_version' AS check_name,
       COALESCE((
           SELECT CASE WHEN (api_product_detail_by_ean(p.ean))->>'api_version' = '1.0'
                       THEN 0 ELSE 1 END
           FROM products p
           WHERE p.ean IS NOT NULL AND p.is_deprecated IS NOT TRUE
           LIMIT 1
       ), 0) AS violations;

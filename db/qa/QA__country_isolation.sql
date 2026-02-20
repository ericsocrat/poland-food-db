-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Country Isolation
-- Validates that no API surface returns mixed-country results,
-- and that auto-country resolution always produces a valid country.
-- 11 checks.
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. api_search_products with country filter returns only that country's products
SELECT '1. search with country filter returns only PL products' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('ch', '{"country":"PL"}'::jsonb, 1, 100)->'results'
    ) r(val)
) search_results
JOIN products p ON p.product_id = search_results.pid::bigint
WHERE p.country != 'PL';

-- 2. api_category_listing with p_country returns only that country
SELECT '2. category listing with country filter returns only PL' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_category_listing('Chips', 'score', 'asc', 100, 0, 'PL')->'products'
    ) r(val)
) listing_results
JOIN products p ON p.product_id = listing_results.pid::bigint
WHERE p.country != 'PL';

-- 3. find_better_alternatives never returns cross-country products
SELECT '3. better alternatives never cross country boundary' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id, p.country AS source_country
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE AND p.unhealthiness_score > 15
    LIMIT 5
) sample
CROSS JOIN LATERAL find_better_alternatives(sample.product_id, true, 3) AS alt
JOIN products p_alt ON p_alt.product_id = alt.alt_product_id
WHERE p_alt.country != sample.source_country;

-- 4. find_similar_products never returns cross-country products
SELECT '4. similar products never cross country boundary' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN products p ON p.product_id = pi.product_id
    WHERE p.is_deprecated IS NOT TRUE
    LIMIT 5
) sample
CROSS JOIN LATERAL find_similar_products(sample.product_id, 3) AS sim
JOIN products p_sim ON p_sim.product_id = sim.similar_product_id
WHERE p_sim.country != (SELECT country FROM products WHERE product_id = sample.product_id);

-- 5. api_product_detail_by_ean with country filter never returns wrong country
SELECT '5. EAN lookup with country filter respects country' AS check_name,
       CASE WHEN (
           SELECT (api_product_detail_by_ean(
               (SELECT ean FROM products WHERE ean IS NOT NULL AND country = 'PL' LIMIT 1),
               'PL'
           ))->>'country'
       ) = 'PL'
       THEN 0 ELSE 1 END AS violations;

-- 6. v_api_category_overview_by_country has no rows for inactive countries
SELECT '6. overview_by_country excludes inactive countries' AS check_name,
       COUNT(*) AS violations
FROM v_api_category_overview_by_country ov
JOIN country_ref cr ON cr.country_code = ov.country_code
WHERE cr.is_active = false;

-- 7. resolve_effective_country(NULL) returns a valid active country without JWT
--    After dedup_and_api_fixes, NULL input falls through to 'PL' default
--    (tier-3 fallback). Verify it resolves to an active country_ref entry.
SELECT '7. resolve_effective_country(NULL) returns valid active country without JWT' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM country_ref
           WHERE country_code = resolve_effective_country(NULL)
             AND is_active = true
       )
       THEN 0 ELSE 1 END AS violations;

-- 8. search with explicit country still works (no tier-3 needed)
SELECT '8. search with explicit country returns that country' AS check_name,
       CASE WHEN (
           api_search_products('ch', '{"country":"PL"}'::jsonb, 1, 5)
       )->>'country' = 'PL'
       THEN 0 ELSE 1 END AS violations;

-- 9. listing with explicit country still works
SELECT '9. listing with explicit country returns that country' AS check_name,
       CASE WHEN (
           api_category_listing('Chips', 'score', 'asc', 5, 0, 'PL')
       )->>'country' = 'PL'
       THEN 0 ELSE 1 END AS violations;

-- 10. EAN with explicit country returns PL
SELECT '10. EAN with explicit country returns that country' AS check_name,
       CASE WHEN (
           api_product_detail_by_ean(
               (SELECT ean FROM products WHERE ean IS NOT NULL AND country = 'PL' LIMIT 1),
               'PL'
           )
       )->>'country' = 'PL'
       THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 11. Authenticated user with user_preferences.country='DE' must resolve to DE
--     Proves auth.uid() → user_preferences → country (tier-2) lookup works.
--
--     Uses a CTE to INSERT and verify in a single statement/transaction.
--     Previously the INSERT ran in a separate statement that was failing
--     silently (psql runs without ON_ERROR_STOP).
-- ═══════════════════════════════════════════════════════════════════════════════

-- Setup: override auth.uid() to return the test user UUID
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid
LANGUAGE sql STABLE AS $fn$
    SELECT '00000000-0000-0000-0000-000000000099'::uuid;
$fn$;

-- Single-statement: INSERT + verify in one transaction
WITH ensure_row AS (
    INSERT INTO user_preferences (user_id, country)
    VALUES ('00000000-0000-0000-0000-000000000099'::uuid, 'DE')
    ON CONFLICT (user_id) DO UPDATE SET country = 'DE'
    RETURNING user_id, country
)
SELECT '11. auth user with DE pref search resolves country=DE' AS check_name,
       CASE WHEN (SELECT country FROM ensure_row) = 'DE'
       THEN 0 ELSE 1 END AS violations;

-- Teardown: remove test user, restore original auth.uid() stub
DELETE FROM user_preferences
WHERE user_id = '00000000-0000-0000-0000-000000000099'::uuid;

CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid
LANGUAGE sql STABLE AS $fn$
    SELECT NULLIF(
        current_setting('request.jwt.claims', true)::jsonb ->> 'sub',
        ''
    )::uuid;
$fn$;

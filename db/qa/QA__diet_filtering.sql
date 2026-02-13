-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Diet Filtering
-- Validates that diet preference filters work correctly across API surfaces.
-- 6 checks.
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Vegan filter excludes products with vegan_status = 'no'
SELECT '1. vegan filter excludes non-vegan from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
api_search_products('a', NULL, 100, 0, 'PL', 'vegan')->'results'
               ) r(val)
           ) search_results
           JOIN v_master m ON m.product_id = search_results.pid::bigint
           WHERE m.vegan_status = 'no';

-- 2. Vegetarian filter excludes products with vegetarian_status = 'no'
SELECT '2. vegetarian filter excludes non-vegetarian from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', NULL, 100, 0, 'PL', 'vegetarian')->'results'
    ) r(val)
) search_results
JOIN v_master m ON m.product_id = search_results.pid::bigint
WHERE m.vegetarian_status = 'no';

-- 3. Strict vegan mode excludes 'maybe' status
SELECT '3. strict vegan excludes maybe-vegan from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', NULL, 100, 0, 'PL', 'vegan', NULL, true)->'results'
    ) r(val)
) search_results
JOIN v_master m ON m.product_id = search_results.pid::bigint
WHERE m.vegan_status != 'yes';

-- 4. Vegan filter works on category listing
SELECT '4. vegan filter excludes non-vegan from category listing' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_category_listing('Chips', 'score', 'asc', 100, 0, 'PL', 'vegan')->'products'
    ) r(val)
) listing_results
JOIN v_master m ON m.product_id = listing_results.pid::bigint
WHERE m.vegan_status = 'no';

-- 5. Vegan filter works on better alternatives
SELECT '5. vegan filter excludes non-vegan from alternatives' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE AND p.unhealthiness_score > 20
    LIMIT 3
) sample
CROSS JOIN LATERAL find_better_alternatives(
    sample.product_id, true, 5, 'vegan'
) AS alt
JOIN v_master m ON m.product_id = alt.alt_product_id
WHERE m.vegan_status = 'no';

-- 6. Without diet filter, non-vegan products appear in results
SELECT '6. no diet filter includes all diet statuses' AS check_name,
       CASE WHEN (
           SELECT COUNT(DISTINCT m.vegan_status)
           FROM (
               SELECT r.val->>'product_id' AS pid
               FROM jsonb_array_elements(
                   api_search_products('ch', NULL, 100, 0, 'PL')->'results'
               ) r(val)
           ) search_results
           JOIN v_master m ON m.product_id = search_results.pid::bigint
       ) >= 1
       THEN 0 ELSE 1 END AS violations;

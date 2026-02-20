-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Diet Filtering
-- Validates that diet preference filters work correctly across API surfaces.
-- 6 checks.
--
-- NOTE: api_search_products now reads diet_preference / strict_diet from
-- user_preferences via auth.uid().  Checks 1-3 set up a test user.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── Auth setup for diet filtering (checks 1–3) ────────────────────────────
-- Use set_config to inject JWT claims so that auth.uid() returns the test UUID
-- inside SECURITY DEFINER functions (more reliable than replacing auth.uid()).
SELECT set_config('request.jwt.claims',
    '{"sub":"00000000-0000-0000-0000-000000000098"}', false);

INSERT INTO user_preferences (user_id, diet_preference, strict_diet, country)
VALUES ('00000000-0000-0000-0000-000000000098'::uuid, 'vegan', false, 'PL')
ON CONFLICT (user_id) DO UPDATE
    SET diet_preference = 'vegan', strict_diet = false, country = 'PL';

-- 1. Vegan filter excludes products with vegan_status = 'no'
SELECT '1. vegan filter excludes non-vegan from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', '{"country":"PL"}'::jsonb, 1, 100)->'results'
    ) r(val)
) search_results
JOIN v_master m ON m.product_id = search_results.pid::bigint
WHERE m.vegan_status = 'no';

-- Switch to vegetarian for check 2
UPDATE user_preferences
SET diet_preference = 'vegetarian', strict_diet = false
WHERE user_id = '00000000-0000-0000-0000-000000000098'::uuid;

-- 2. Vegetarian filter excludes products with vegetarian_status = 'no'
SELECT '2. vegetarian filter excludes non-vegetarian from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', '{"country":"PL"}'::jsonb, 1, 100)->'results'
    ) r(val)
) search_results
JOIN v_master m ON m.product_id = search_results.pid::bigint
WHERE m.vegetarian_status = 'no';

-- Switch to strict vegan for check 3
UPDATE user_preferences
SET diet_preference = 'vegan', strict_diet = true
WHERE user_id = '00000000-0000-0000-0000-000000000098'::uuid;

-- 3. Strict vegan mode excludes 'maybe' status
SELECT '3. strict vegan excludes maybe-vegan from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', '{"country":"PL"}'::jsonb, 1, 100)->'results'
    ) r(val)
) search_results
JOIN v_master m ON m.product_id = search_results.pid::bigint
WHERE m.vegan_status != 'yes';

-- ─── Teardown auth for diet checks ─────────────────────────────────────────
DELETE FROM user_preferences
WHERE user_id = '00000000-0000-0000-0000-000000000098'::uuid;

SELECT set_config('request.jwt.claims', '', false);

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
                   api_search_products('ch', '{"country":"PL"}'::jsonb, 1, 100)->'results'
               ) r(val)
           ) search_results
           JOIN v_master m ON m.product_id = search_results.pid::bigint
       ) >= 1
       THEN 0 ELSE 1 END AS violations;

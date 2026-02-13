-- ============================================================
-- QA: Auth & Onboarding Validation
-- Ensures auth-only access, onboarding flow, and country resolution.
-- 8 checks.
-- ============================================================

-- Setup: simulate authenticated user via JWT claims
DO $setup$
BEGIN
    DELETE FROM user_preferences
    WHERE user_id = '00000000-0000-0000-0000-000000000077'::uuid;
    PERFORM set_config('request.jwt.claims',
        '{"sub":"00000000-0000-0000-0000-000000000077"}', false);
END $setup$;

-- 1. api_get_user_preferences returns onboarding_complete key
SELECT '1. api_get_user_preferences has onboarding_complete key' AS check_name,
       CASE WHEN (
           SELECT api_get_user_preferences() ? 'onboarding_complete'
       ) THEN 0 ELSE 1 END AS violations;

-- 2. api_get_user_preferences auto-creates row (has user_id in response)
SELECT '2. api_get_user_preferences auto-creates preference row' AS check_name,
       CASE WHEN (
           SELECT api_get_user_preferences() ? 'user_id'
       ) THEN 0 ELSE 1 END AS violations;

-- 3. api_set_user_preferences with valid country returns onboarding_complete=true
SELECT '3. set_user_preferences with country returns onboarding_complete true' AS check_name,
       CASE WHEN (
           SELECT (api_set_user_preferences(p_country := 'PL'))->>'onboarding_complete' = 'true'
       ) THEN 0 ELSE 1 END AS violations;

-- 4. api_set_user_preferences with invalid country returns error
SELECT '4. set_user_preferences rejects invalid country' AS check_name,
       CASE WHEN (
           SELECT api_set_user_preferences(p_country := 'XX') ? 'error'
       ) THEN 0 ELSE 1 END AS violations;

-- 5. api_set_user_preferences with invalid diet returns error
SELECT '5. set_user_preferences rejects invalid diet' AS check_name,
       CASE WHEN (
           SELECT api_set_user_preferences(p_country := 'PL', p_diet_preference := 'pescatarian') ? 'error'
       ) THEN 0 ELSE 1 END AS violations;

-- Teardown: remove test user, reset JWT
DO $teardown$
BEGIN
    DELETE FROM user_preferences
    WHERE user_id = '00000000-0000-0000-0000-000000000077'::uuid;
    PERFORM set_config('request.jwt.claims', '', false);
END $teardown$;

-- 6. resolve_effective_country returns NULL when no preference and no explicit param
--    (tier-3 "first active country" fallback removed)
SELECT '6. resolve_effective_country returns NULL without preference or param' AS check_name,
       CASE WHEN (
           -- We test via a check on the function definition: it should NOT reference country_ref
           SELECT pg_get_functiondef(oid) NOT LIKE '%country_ref%'
           FROM pg_proc
           WHERE proname = 'resolve_effective_country'
       ) THEN 0 ELSE 1 END AS violations;

-- 7. api_set_user_preferences p_country default is NULL (not hardcoded 'PL')
SELECT '7. set_user_preferences p_country default is NULL not PL' AS check_name,
       CASE WHEN (
           SELECT pg_get_function_arguments(oid) LIKE '%DEFAULT NULL%'
           FROM pg_proc
           WHERE proname = 'api_set_user_preferences'
       ) THEN 0 ELSE 1 END AS violations;

-- 8. user_preferences.country has no NOT NULL constraint (allows pre-onboarding NULL)
SELECT '8. user_preferences.country is nullable' AS check_name,
       CASE WHEN (
           SELECT is_nullable FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'user_preferences'
             AND column_name = 'country'
       ) = 'YES'
       THEN 0 ELSE 1 END AS violations;

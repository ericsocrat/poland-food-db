-- ============================================================
-- QA: Security Posture Validation
-- Ensures RLS, grant restrictions, SECURITY DEFINER attributes,
-- and function access controls are in place.
-- ============================================================

-- 1. All data tables have RLS enabled
SELECT '1. All data tables have RLS enabled' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN (
    'products','nutrition_facts','product_allergen_info','product_ingredient',
    'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
  )
  AND c.relrowsecurity = false;

-- 2. All data tables have FORCE RLS enabled
SELECT '2. All data tables have FORCE RLS' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN (
    'products','nutrition_facts','product_allergen_info','product_ingredient',
    'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
  )
  AND c.relforcerowsecurity = false;

-- 3. Each data table has exactly one SELECT-only policy
SELECT '3. Each data table has a SELECT policy' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON pol.polrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND c.relname = expected.tbl
      AND pol.polcmd = 'r'  -- SELECT policy
);

-- 4. No INSERT/UPDATE/DELETE policies exist (write access blocked)
SELECT '4. No write policies exist on data tables' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname IN (
    'products','nutrition_facts','product_allergen_info','product_ingredient',
    'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
  )
  AND pol.polcmd != 'r';  -- anything other than SELECT

-- 5. anon cannot INSERT into any data table
SELECT '5. anon has no INSERT privilege on data tables' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) t
WHERE has_table_privilege('anon', 'public.' || t.tbl, 'INSERT');

-- 6. anon cannot UPDATE any data table
SELECT '6. anon has no UPDATE privilege on data tables' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) t
WHERE has_table_privilege('anon', 'public.' || t.tbl, 'UPDATE');

-- 7. anon cannot DELETE from any data table
SELECT '7. anon has no DELETE privilege on data tables' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) t
WHERE has_table_privilege('anon', 'public.' || t.tbl, 'DELETE');

-- 8. All api_* functions are SECURITY DEFINER
SELECT '8. All api_* functions are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND p.prosecdef = false;

-- 9. anon CANNOT EXECUTE any api_* function (auth-only platform)
SELECT '9. anon blocked from ALL api_* functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND has_function_privilege('anon', p.oid, 'EXECUTE');

-- 10. anon cannot EXECUTE internal computation functions
SELECT '10. anon blocked from internal functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN (
    'compute_unhealthiness_v31','compute_unhealthiness_v32',
    'explain_score_v32','compute_data_confidence','compute_data_completeness',
    'assign_confidence','find_similar_products','find_better_alternatives',
    'refresh_all_materialized_views','mv_staleness_check',
    'check_product_preferences','resolve_effective_country'
  )
  AND has_function_privilege('anon', p.oid, 'EXECUTE');

-- 11. service_role retains full table access
SELECT '11. service_role has full table privileges' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) t
WHERE NOT (
    has_table_privilege('service_role', 'public.' || t.tbl, 'SELECT')
    AND has_table_privilege('service_role', 'public.' || t.tbl, 'INSERT')
    AND has_table_privilege('service_role', 'public.' || t.tbl, 'UPDATE')
    AND has_table_privilege('service_role', 'public.' || t.tbl, 'DELETE')
);

-- 12. All api_* functions have search_path set (anti-hijack)
SELECT '12. All api_* functions have search_path set' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND p.prosecdef = true
  AND (p.proconfig IS NULL OR NOT EXISTS (
    SELECT 1
    FROM unnest(p.proconfig) AS cfg
    WHERE cfg LIKE 'search_path=%'
  ));

-- 13. anon cannot SELECT any data table directly (RPC-only model)
SELECT '13. anon has no SELECT on data tables (RPC-only)' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref'
    ]) AS tbl
) t
WHERE has_table_privilege('anon', 'public.' || t.tbl, 'SELECT');

-- 14. New tables have RLS enabled
SELECT '14. New tables have RLS enabled' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN ('product_field_provenance','source_nutrition')
  AND c.relrowsecurity = false;

-- 15. products has updated_at trigger
SELECT '15. products has updated_at trigger' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM information_schema.triggers
           WHERE trigger_name = 'trg_products_updated_at'
             AND event_object_table = 'products'
       ) THEN 0 ELSE 1 END AS violations;

-- 16. user_preferences has RLS enabled
SELECT '16. user_preferences has RLS enabled' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname = 'user_preferences'
  AND c.relrowsecurity = false;

-- 17. user_preferences has per-user RLS policies (SIUD)
SELECT '17. user_preferences has SIUD policies' AS check_name,
       CASE WHEN (
           SELECT COUNT(DISTINCT pol.polcmd)
           FROM pg_policy pol
           JOIN pg_class c ON pol.polrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_preferences'
       ) >= 4
       THEN 0 ELSE 1 END AS violations;

-- 18. authenticated CAN EXECUTE all api_* functions
SELECT '18. authenticated can execute all api_* functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND NOT has_function_privilege('authenticated', p.oid, 'EXECUTE');

-- 19. user_preferences.country allows NULL (pre-onboarding state)
SELECT '19. user_preferences.country nullable for onboarding' AS check_name,
       CASE WHEN (
           SELECT is_nullable FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'user_preferences'
             AND column_name = 'country'
       ) = 'YES'
       THEN 0 ELSE 1 END AS violations;

-- 20. user_preferences has updated_at trigger
SELECT '20. user_preferences has updated_at trigger' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM information_schema.triggers
           WHERE trigger_name = 'user_preferences_updated_at'
             AND event_object_table = 'user_preferences'
       ) THEN 0 ELSE 1 END AS violations;

-- 21. resolve_effective_country is SECURITY DEFINER with search_path set
SELECT '21. resolve_effective_country is SECURITY DEFINER with search_path' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'resolve_effective_country'
             AND p.prosecdef = true
             AND EXISTS (
                 SELECT 1 FROM unnest(p.proconfig) AS cfg
                 WHERE cfg LIKE 'search_path=%'
             )
       ) THEN 0 ELSE 1 END AS violations;

-- 22. resolve_effective_country EXECUTE revoked from authenticated (internal-only)
SELECT '22. resolve_effective_country EXECUTE revoked from authenticated' AS check_name,
       CASE WHEN has_function_privilege(
           'authenticated',
           'public.resolve_effective_country(text)',
           'EXECUTE'
       ) THEN 1 ELSE 0 END AS violations;

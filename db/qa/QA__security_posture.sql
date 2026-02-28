-- ============================================================
-- QA: Security Posture Validation — 38 checks
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
    'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref',
    'store_ref','product_store_availability'
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
    'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref',
    'store_ref','product_store_availability'
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

-- 9. anon CANNOT EXECUTE api_* functions except approved public endpoints
--    Allowlist: autocomplete, filter options, shared lists/comparisons,
--    comparison data, telemetry, product/ingredient profiles (all public).
--    NOTE: api_search_products and api_record_scan were revoked from anon
--    in localization phase 4 (20260216001100) and are now auth-only.
SELECT '9. anon blocked from non-public api_* functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND has_function_privilege('anon', p.oid, 'EXECUTE')
  AND p.proname NOT IN (
    'api_search_autocomplete',       -- public autocomplete
    'api_get_filter_options',        -- public filter facets
    'api_get_shared_list',          -- shared list (public link)
    'api_get_shared_comparison',    -- shared comparison (public link)
    'api_get_products_for_compare', -- comparison data (needed by shared links)
    'api_track_event',              -- fire-and-forget analytics (anon + auth)
    'api_get_product_profile',      -- public product lookup
    'api_get_product_profile_by_ean', -- public EAN lookup
    'api_get_ingredient_profile',   -- public ingredient lookup
    'api_get_score_history',        -- public score history
    'api_get_product_allergens',     -- public allergen batch lookup
    'api_product_provenance',         -- public product provenance/trust score (#193)
    'api_validate_event_schema',       -- public schema validation (#190)
    'api_completeness_gap_analysis'    -- public completeness diagnostic (#376)
  );

-- 10. anon cannot EXECUTE internal computation functions
SELECT '10. anon blocked from internal functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN (
    'compute_unhealthiness_v32',
    'explain_score_v32','compute_data_confidence','compute_data_completeness',
    'assign_confidence','find_similar_products','find_better_alternatives',
    'refresh_all_materialized_views','mv_staleness_check',
    'check_product_preferences','resolve_effective_country',
    'compute_health_warnings',
    'check_formula_drift','check_function_source_drift',
    'governance_drift_check','log_drift_check',
    'register_backfill','start_backfill','update_backfill_progress',
    'complete_backfill','fail_backfill'
  )
  AND has_function_privilege('anon', p.oid, 'EXECUTE');

-- 11. service_role retains full table access
SELECT '11. service_role has full table privileges' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'products','nutrition_facts','product_allergen_info','product_ingredient',
        'ingredient_ref','category_ref','country_ref','nutri_score_ref','concern_tier_ref',
        'backfill_registry'
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
--     Excludes admin-only functions that are restricted to service_role.
SELECT '18. authenticated can execute all api_* functions' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND p.proname NOT IN (
    'api_refresh_mvs',                  -- MV refresh (service_role cron)
    'api_health_check',                 -- monitoring (service_role only)
    'api_get_pending_notifications',    -- push queue (service_role only)
    'api_mark_notifications_sent',      -- push queue (service_role only)
    'api_cleanup_push_subscriptions'    -- push cleanup (service_role only)
  )
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

-- ═══════════════════════════════════════════════════════════════════════════
-- RLS HARDENING CHECKS (Issue #359)
-- ═══════════════════════════════════════════════════════════════════════════

-- 23. No user_* MUTATION policies grant to {public} role
--     (all user table mutations must require {authenticated})
SELECT '23. No user_* mutation policies use {public}' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname LIKE 'user_%'
  AND pol.polcmd != 'r'  -- not SELECT
  AND pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'anon')]::oid[];

-- 24. feature_flags write policies restricted to service_role only
SELECT '24. feature_flags writes restricted to service_role' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname = 'feature_flags'
  AND pol.polcmd != 'r'  -- not SELECT
  AND NOT (pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'service_role')]::oid[]
      AND NOT pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'anon')]::oid[]);

-- 25. flag_overrides write policies restricted to service_role only
SELECT '25. flag_overrides writes restricted to service_role' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname = 'flag_overrides'
  AND pol.polcmd != 'r'  -- not SELECT
  AND NOT (pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'service_role')]::oid[]
      AND NOT pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'anon')]::oid[]);

-- 26. All admin/service tables have service_role-only write policies
--     (no {public} write access on operational tables)
SELECT '26. Admin tables have service_role-only writes' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname IN (
    'score_audit_log', 'score_distribution_snapshots', 'score_shadow_results',
    'data_conflicts', 'product_change_log', 'flag_audit_log',
    'analytics_daily', 'audit_results', 'deletion_audit_log'
  )
  AND pol.polcmd != 'r'  -- not SELECT
  AND pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'anon')]::oid[];

-- 27. All tables with RLS enabled have at least one policy
SELECT '27. All RLS-enabled tables have >=1 policy' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relrowsecurity = true
  AND NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    WHERE pol.polrelid = c.oid
  );

-- 28. No public tables have RLS disabled (all must be enabled)
SELECT '28. No tables have RLS disabled' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relrowsecurity = false;

-- 29. scan_history and product_submissions use {authenticated} role
SELECT '29. scan/submission policies use {authenticated}' AS check_name,
       COUNT(*) AS violations
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname IN ('scan_history', 'product_submissions')
  AND pol.polroles @> ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'anon')]::oid[];

-- 30. Rate limiting functions exist and are SECURITY DEFINER
SELECT '30. rate limit functions are SECURITY DEFINER' AS check_name,
       2 - COUNT(*)::int AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('check_submission_rate_limit', 'check_scan_rate_limit')
  AND p.prosecdef = true;

-- 31. Rate limit index exists on product_submissions (user_id, created_at)
SELECT '31. rate limit index exists (idx_ps_user_created)' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE schemaname = 'public'
             AND tablename = 'product_submissions'
             AND indexname = 'idx_ps_user_created'
       ) THEN 0 ELSE 1 END AS violations;

-- 32. api_record_scan source contains rate limit check
SELECT '32. api_record_scan includes rate limit check' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'api_record_scan'
             AND p.prosrc LIKE '%check_scan_rate_limit%'
       ) THEN 0 ELSE 1 END AS violations;

-- 33. check_api_rate_limit is SECURITY DEFINER
SELECT '33. check_api_rate_limit is SECURITY DEFINER' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'check_api_rate_limit'
             AND p.prosecdef = true
       ) THEN 0 ELSE 1 END AS violations;

-- 34. api_rate_limits has 6 configured endpoints
SELECT '34. api_rate_limits has >= 6 endpoints' AS check_name,
       CASE WHEN (SELECT COUNT(*) FROM api_rate_limits) >= 6
       THEN 0 ELSE 1 END AS violations;

-- 35. api_rate_limit_log has retention policy
SELECT '35. api_rate_limit_log has retention policy' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM retention_policies
           WHERE table_name = 'api_rate_limit_log'
             AND is_enabled = true
       ) THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- User Trust Scoring (#471)
-- ═══════════════════════════════════════════════════════════════════════════

-- 36. user_trust_scores table has RLS enabled
SELECT '36. user_trust_scores has RLS enabled' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_class
           WHERE relname = 'user_trust_scores' AND relrowsecurity = true
       ) THEN 0 ELSE 1 END AS violations;

-- 37. trig_adjust_trust_score is SECURITY DEFINER
SELECT '37. trig_adjust_trust_score is SECURITY DEFINER' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc
           WHERE proname = 'trig_adjust_trust_score'
             AND prosecdef = true
       ) THEN 0 ELSE 1 END AS violations;

-- 38. user_trust_scores has CHECK constraint on trust_score range
SELECT '38. user_trust_scores has trust_score range CHECK' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM information_schema.check_constraints
           WHERE constraint_name = 'chk_trust_score_range'
       ) THEN 0 ELSE 1 END AS violations;

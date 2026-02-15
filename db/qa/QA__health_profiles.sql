-- ============================================================
-- QA: Health Profiles
-- Validates the user_health_profiles table structure, RLS
-- policies, CRUD RPCs, and compute_health_warnings function.
-- All checks are BLOCKING.
-- Updated 2026-02-15: Phase 5.1 hardening — unique active
--   index, compute_health_warnings flag fix, clear flags.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. user_health_profiles table exists with required columns
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. user_health_profiles table has required columns' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    FROM (VALUES
        ('profile_id'), ('user_id'), ('profile_name'), ('is_active'),
        ('health_conditions'), ('max_sugar_g'), ('max_salt_g'),
        ('max_saturated_fat_g'), ('max_calories_kcal'), ('notes'),
        ('created_at'), ('updated_at')
    ) AS expected(col)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema = 'public'
          AND c.table_name = 'user_health_profiles'
          AND c.column_name = expected.col
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. RLS is enabled and forced
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. RLS enabled and forced on user_health_profiles' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname = 'user_health_profiles'
  AND NOT (c.relrowsecurity AND c.relforcerowsecurity);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. All 4 RLS policies exist (select, insert, update, delete)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. all 4 RLS policies exist' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('health_profiles_select_own'),
    ('health_profiles_insert_own'),
    ('health_profiles_update_own'),
    ('health_profiles_delete_own')
) AS expected(pol)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_policies p
    WHERE p.schemaname = 'public'
      AND p.tablename = 'user_health_profiles'
      AND p.policyname = expected.pol
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. CRUD RPCs exist
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. health profile CRUD RPCs exist' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('api_list_health_profiles'),
    ('api_get_active_health_profile'),
    ('api_create_health_profile'),
    ('api_update_health_profile'),
    ('api_delete_health_profile')
) AS expected(fn)
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.routines r
    WHERE r.routine_schema = 'public'
      AND r.routine_name = expected.fn
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. compute_health_warnings function exists
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. compute_health_warnings function exists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.routines r
        WHERE r.routine_schema = 'public'
          AND r.routine_name = 'compute_health_warnings'
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_product_health_warnings function exists
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. api_product_health_warnings function exists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.routines r
        WHERE r.routine_schema = 'public'
          AND r.routine_name = 'api_product_health_warnings'
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. All CRUD RPCs are SECURITY DEFINER
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. health profile RPCs are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('api_list_health_profiles'),
    ('api_get_active_health_profile'),
    ('api_create_health_profile'),
    ('api_update_health_profile'),
    ('api_delete_health_profile'),
    ('api_product_health_warnings')
) AS expected(fn)
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.routines r
    WHERE r.routine_schema = 'public'
      AND r.routine_name = expected.fn
      AND r.security_type = 'DEFINER'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. CHECK constraint on health_conditions exists
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. chk_health_conditions constraint exists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints tc
        WHERE tc.table_schema = 'public'
          AND tc.table_name = 'user_health_profiles'
          AND tc.constraint_name = 'chk_health_conditions'
          AND tc.constraint_type = 'CHECK'
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Enforce single active trigger exists
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. enforce single active profile trigger exists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.triggers t
        WHERE t.event_object_schema = 'public'
          AND t.event_object_table = 'user_health_profiles'
          AND t.trigger_name = 'trg_health_profile_active'
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. anon role cannot access health profile RPCs
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. anon cannot execute health profile RPCs' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('api_list_health_profiles'),
    ('api_get_active_health_profile'),
    ('api_create_health_profile'),
    ('api_update_health_profile'),
    ('api_delete_health_profile'),
    ('api_product_health_warnings')
) AS expected(fn)
WHERE EXISTS (
    SELECT 1 FROM information_schema.routine_privileges rp
    WHERE rp.routine_schema = 'public'
      AND rp.routine_name = expected.fn
      AND rp.grantee = 'anon'
      AND rp.privilege_type = 'EXECUTE'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Unique partial index for one active profile per user exists
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. unique active profile index exists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT 1
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'user_health_profiles'
          AND indexname = 'idx_one_active_profile_per_user'
    )
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. api_update_health_profile has clear flag parameters
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. update RPC has clear flag parameters' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('p_clear_max_sugar'),
    ('p_clear_max_salt'),
    ('p_clear_max_sat_fat'),
    ('p_clear_max_calories')
) AS expected(param)
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.parameters ip
    WHERE ip.specific_schema = 'public'
      AND ip.specific_name LIKE 'api_update_health_profile%'
      AND ip.parameter_name = expected.param
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. No duplicate active profiles (invariant)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. no duplicate active profiles per user' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT user_id, COUNT(*) AS active_count
    FROM public.user_health_profiles
    WHERE is_active = true
    GROUP BY user_id
    HAVING COUNT(*) > 1
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. CHECK constraints exist for threshold bounds
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. nutrient threshold CHECK constraints exist' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
    ('chk_max_sugar_positive'),
    ('chk_max_salt_positive'),
    ('chk_max_sat_fat_positive'),
    ('chk_max_calories_positive')
) AS expected(con)
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints tc
    WHERE tc.table_schema = 'public'
      AND tc.table_name = 'user_health_profiles'
      AND tc.constraint_name = expected.con
      AND tc.constraint_type = 'CHECK'
);

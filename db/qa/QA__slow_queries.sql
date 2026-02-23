-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Slow Query Detection
-- Uses pg_stat_statements to identify queries exceeding performance thresholds.
-- Validates the report_slow_queries() function and pg_stat_statements extension.
-- Issue: #185
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  pg_stat_statements extension is installed
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. pg_stat_statements installed' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  report_slow_queries function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. report_slow_queries function exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'report_slow_queries'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  report_slow_queries is SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. report_slow_queries is SECURITY DEFINER' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'report_slow_queries'
             AND p.prosecdef = true
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  report_slow_queries is NOT accessible to anon
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. report_slow_queries not accessible to anon' AS check_name,
       CASE WHEN NOT has_function_privilege(
           'anon',
           'report_slow_queries(double precision)',
           'EXECUTE'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  report_slow_queries is NOT accessible to authenticated
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. report_slow_queries not accessible to authenticated' AS check_name,
       CASE WHEN NOT has_function_privilege(
           'authenticated',
           'report_slow_queries(double precision)',
           'EXECUTE'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  report_slow_queries(0) returns valid result set (may be empty in CI)
--     Verifies the function runs without error.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. report_slow_queries(0) executes without error' AS check_name,
       CASE WHEN (
           SELECT COUNT(*) >= 0 FROM report_slow_queries(0)
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  check_plan_quality function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. check_plan_quality function exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'check_plan_quality'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  check_plan_quality is SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. check_plan_quality is SECURITY DEFINER' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'check_plan_quality'
             AND p.prosecdef = true
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  check_plan_quality is NOT accessible to anon
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. check_plan_quality not accessible to anon' AS check_name,
       CASE WHEN NOT has_function_privilege(
           'anon',
           'check_plan_quality(text)',
           'EXECUTE'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  check_plan_quality is NOT accessible to authenticated
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. check_plan_quality not accessible to authenticated' AS check_name,
       CASE WHEN NOT has_function_privilege(
           'authenticated',
           'check_plan_quality(text)',
           'EXECUTE'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #11  Global statement_timeout is set to 30s
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. global statement_timeout = 30s' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           WHERE rs.setrole = 0  -- 0 = database-level (no specific role)
             AND rs.setconfig::text[] @> ARRAY['statement_timeout=30s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12  report_slow_queries returns expected columns
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. report_slow_queries has correct return columns' AS check_name,
       CASE WHEN (
           SELECT COUNT(*) = 7
           FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid,
           LATERAL unnest(proargnames) AS col
           WHERE n.nspname = 'public'
             AND p.proname = 'report_slow_queries'
             AND col IN ('query_preview','calls','avg_ms','max_ms','total_ms','rows_returned','category')
       ) THEN 0 ELSE 1 END AS violations;

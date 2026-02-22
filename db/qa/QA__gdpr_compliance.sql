-- QA: GDPR Data Export — api_export_user_data()
-- Issue #145
-- Checks: function existence, auth, return structure, permissions

/* ── 1. Function exists ──────────────────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_function_exists' AS check_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_export_user_data'
  ) THEN 'PASS' ELSE 'FAIL — api_export_user_data() not found' END AS result;

/* ── 2. Function returns JSONB ──────────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_returns_jsonb' AS check_name,
  CASE WHEN (
    SELECT pg_catalog.format_type(p.prorettype, NULL)
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_export_user_data'
  ) = 'jsonb' THEN 'PASS' ELSE 'FAIL — expected JSONB return type' END AS result;

/* ── 3. Function has SECURITY DEFINER ────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_security_definer' AS check_name,
  CASE WHEN (
    SELECT p.prosecdef
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_export_user_data'
  ) THEN 'PASS' ELSE 'FAIL — must be SECURITY DEFINER' END AS result;

/* ── 4. Anon role cannot execute ─────────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_no_anon_access' AS check_name,
  CASE WHEN NOT has_function_privilege(
    'anon', 'api_export_user_data()', 'EXECUTE'
  ) THEN 'PASS' ELSE 'FAIL — anon should NOT have EXECUTE' END AS result;

/* ── 5. Authenticated role can execute ───────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_auth_access' AS check_name,
  CASE WHEN has_function_privilege(
    'authenticated', 'api_export_user_data()', 'EXECUTE'
  ) THEN 'PASS' ELSE 'FAIL — authenticated should have EXECUTE' END AS result;

/* ── 6. Function comment exists (documentation) ──────────────────────────── */
SELECT '✅' AS status, 'gdpr_export_has_comment' AS check_name,
  CASE WHEN (
    SELECT obj_description(p.oid, 'pg_proc')
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_export_user_data'
  ) IS NOT NULL THEN 'PASS' ELSE 'FAIL — function should have a COMMENT' END AS result;

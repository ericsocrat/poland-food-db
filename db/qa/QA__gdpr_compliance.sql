-- QA: GDPR Compliance — Data Export (Art.20) + Account Deletion (Art.17)
-- Issues #145, #146
-- Checks: functions, auth, return structure, permissions, audit log

/* ════════════════════════════════════════════════════════════════════════════
   DATA EXPORT — api_export_user_data() (#145)
   ════════════════════════════════════════════════════════════════════════════ */

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

/* ════════════════════════════════════════════════════════════════════════════
   ACCOUNT DELETION — api_delete_user_data() (#146)
   ════════════════════════════════════════════════════════════════════════════ */

/* ── 7. Delete function exists ───────────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_function_exists' AS check_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_delete_user_data'
  ) THEN 'PASS' ELSE 'FAIL — api_delete_user_data() not found' END AS result;

/* ── 8. Delete function returns JSONB ────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_returns_jsonb' AS check_name,
  CASE WHEN (
    SELECT pg_catalog.format_type(p.prorettype, NULL)
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_delete_user_data'
  ) = 'jsonb' THEN 'PASS' ELSE 'FAIL — expected JSONB return type' END AS result;

/* ── 9. Delete function is SECURITY DEFINER ──────────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_security_definer' AS check_name,
  CASE WHEN (
    SELECT p.prosecdef
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_delete_user_data'
  ) THEN 'PASS' ELSE 'FAIL — must be SECURITY DEFINER' END AS result;

/* ── 10. Anon cannot call delete function ────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_no_anon_access' AS check_name,
  CASE WHEN NOT has_function_privilege(
    'anon', 'api_delete_user_data()', 'EXECUTE'
  ) THEN 'PASS' ELSE 'FAIL — anon should NOT have EXECUTE' END AS result;

/* ── 11. Authenticated can call delete function ──────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_auth_access' AS check_name,
  CASE WHEN has_function_privilege(
    'authenticated', 'api_delete_user_data()', 'EXECUTE'
  ) THEN 'PASS' ELSE 'FAIL — authenticated should have EXECUTE' END AS result;

/* ── 12. Delete function has comment ─────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_delete_has_comment' AS check_name,
  CASE WHEN (
    SELECT obj_description(p.oid, 'pg_proc')
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'api_delete_user_data'
  ) IS NOT NULL THEN 'PASS' ELSE 'FAIL — function should have a COMMENT' END AS result;

/* ── 13. deletion_audit_log table exists ─────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_audit_log_exists' AS check_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'deletion_audit_log'
  ) THEN 'PASS' ELSE 'FAIL — deletion_audit_log table not found' END AS result;

/* ── 14. Audit log has RLS enabled ───────────────────────────────────────── */
SELECT '✅' AS status, 'gdpr_audit_log_rls_enabled' AS check_name,
  CASE WHEN (
    SELECT relrowsecurity FROM pg_class
    WHERE relname = 'deletion_audit_log' AND relnamespace = 'public'::regnamespace
  ) THEN 'PASS' ELSE 'FAIL — RLS must be enabled on deletion_audit_log' END AS result;

/* ── 15. Audit log has NO user_id column (no PII) ────────────────────────── */
SELECT '✅' AS status, 'gdpr_audit_log_no_pii' AS check_name,
  CASE WHEN NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'deletion_audit_log'
      AND column_name = 'user_id'
  ) THEN 'PASS' ELSE 'FAIL — deletion_audit_log must NOT store user_id (PII)' END AS result;

-- ============================================================
-- QA: Function Security Audit — SECURITY DEFINER Inventory
-- Enumerates all public functions with their security mode,
-- search_path config, and per-role execute privileges.
-- Used to populate the SECURITY_AUDIT.md function matrix.
-- Re-run quarterly to verify posture.
-- ============================================================
-- See also: QA__security_posture.sql for pass/fail assertions.

-- 1. All SECURITY DEFINER functions with search_path audit
SELECT
  p.proname                                      AS function_name,
  pg_get_function_identity_arguments(p.oid)      AS arguments,
  CASE WHEN p.prosecdef
       THEN '⚠️ SECURITY DEFINER'
       ELSE '✅ INVOKER'
  END                                            AS security_mode,
  COALESCE(
    (SELECT cfg FROM unnest(p.proconfig) AS cfg WHERE cfg LIKE 'search_path=%'),
    CASE WHEN p.prosecdef THEN '❌ MISSING' ELSE 'n/a' END
  )                                              AS search_path_config
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
ORDER BY p.proname;

-- 2. Per-role EXECUTE privilege matrix for all api_* functions
SELECT
  p.proname                                             AS function_name,
  pg_get_function_identity_arguments(p.oid)             AS arguments,
  has_function_privilege('anon',          p.oid, 'EXECUTE') AS anon_exec,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') AS auth_exec,
  has_function_privilege('service_role',  p.oid, 'EXECUTE') AS svc_exec
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
ORDER BY p.proname;

-- 3. All SECURITY DEFINER functions (not just api_*) — full inventory
SELECT
  p.proname                                      AS function_name,
  pg_get_function_identity_arguments(p.oid)      AS arguments,
  p.prosecdef                                    AS is_security_definer,
  COALESCE(
    (SELECT cfg FROM unnest(p.proconfig) AS cfg WHERE cfg LIKE 'search_path=%'),
    '❌ MISSING'
  )                                              AS search_path_config
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.prosecdef = true
ORDER BY p.proname;

-- 4. Functions callable by anon role (potential attack surface)
SELECT
  p.proname                                             AS function_name,
  pg_get_function_identity_arguments(p.oid)             AS arguments,
  p.prosecdef                                           AS is_security_definer
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND has_function_privilege('anon', p.oid, 'EXECUTE')
ORDER BY p.proname;

-- 5. Functions referencing user_id but NOT auth.uid() — potential auth bypass
--    (flag for manual review)
SELECT
  p.proname                                      AS function_name,
  pg_get_function_identity_arguments(p.oid)      AS arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND pg_get_functiondef(p.oid) ILIKE '%user_id%'
  AND pg_get_functiondef(p.oid) NOT ILIKE '%auth.uid()%'
  AND p.proname LIKE 'api_%'
ORDER BY p.proname;

-- 6. Internal (non-api) functions — verify anon/authenticated cannot execute
SELECT
  p.proname                                             AS function_name,
  has_function_privilege('anon',          p.oid, 'EXECUTE') AS anon_exec,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') AS auth_exec
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname NOT LIKE 'api_%'
  AND p.proname NOT LIKE 'pg_%'
  AND p.proname NOT IN ('cron_job_handler')
  AND (
    has_function_privilege('anon', p.oid, 'EXECUTE')
    OR has_function_privilege('authenticated', p.oid, 'EXECUTE')
  )
ORDER BY p.proname;

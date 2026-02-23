-- ============================================================
-- QA: RLS Audit — Comprehensive Row Level Security Inventory
-- Enumerates all public tables, their RLS status, policies,
-- and privilege grants. Used to populate the SECURITY_AUDIT.md
-- RLS matrix. Re-run quarterly to verify posture.
-- ============================================================
-- See also: QA__security_posture.sql for pass/fail assertions.

-- 1. All public tables with RLS and FORCE RLS status
SELECT
  c.relname                                       AS table_name,
  c.relrowsecurity                                AS rls_enabled,
  c.relforcerowsecurity                           AS force_rls,
  CASE WHEN c.relrowsecurity THEN '✅' ELSE '❌' END AS rls_status,
  CASE WHEN c.relforcerowsecurity THEN '✅' ELSE '❌' END AS force_status
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY c.relrowsecurity DESC, c.relname;

-- 2. All RLS policies per table (detailed)
SELECT
  p.tablename,
  p.policyname,
  p.permissive,
  p.roles,
  p.cmd,
  p.qual::text   AS using_condition,
  p.with_check::text AS with_check_condition
FROM pg_policies p
WHERE p.schemaname = 'public'
ORDER BY p.tablename, p.policyname;

-- 3. Tables with RLS enabled but NO policies (blocks all non-superuser access)
SELECT t.tablename AS orphan_rls_table
FROM pg_tables t
LEFT JOIN pg_policies p
  ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public'
  AND t.rowsecurity = true
  AND p.policyname IS NULL;

-- 4. Tables without RLS that contain user-identifying columns
--    (potential exposure — flag for manual review)
SELECT
  t.tablename,
  c.column_name AS user_column
FROM pg_tables t
JOIN information_schema.columns c
  ON c.table_schema = 'public' AND c.table_name = t.tablename
WHERE t.schemaname = 'public'
  AND t.rowsecurity = false
  AND c.column_name IN ('user_id', 'created_by', 'owner_id', 'auth_uid')
ORDER BY t.tablename;

-- 5. Per-table privilege matrix for anon role
SELECT
  c.relname AS table_name,
  has_table_privilege('anon', c.oid, 'SELECT')  AS anon_select,
  has_table_privilege('anon', c.oid, 'INSERT')  AS anon_insert,
  has_table_privilege('anon', c.oid, 'UPDATE')  AS anon_update,
  has_table_privilege('anon', c.oid, 'DELETE')  AS anon_delete
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY c.relname;

-- 6. Per-table privilege matrix for authenticated role
SELECT
  c.relname AS table_name,
  has_table_privilege('authenticated', c.oid, 'SELECT')  AS auth_select,
  has_table_privilege('authenticated', c.oid, 'INSERT')  AS auth_insert,
  has_table_privilege('authenticated', c.oid, 'UPDATE')  AS auth_update,
  has_table_privilege('authenticated', c.oid, 'DELETE')  AS auth_delete
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY c.relname;

-- 7. Per-table privilege matrix for service_role
SELECT
  c.relname AS table_name,
  has_table_privilege('service_role', c.oid, 'SELECT')  AS svc_select,
  has_table_privilege('service_role', c.oid, 'INSERT')  AS svc_insert,
  has_table_privilege('service_role', c.oid, 'UPDATE')  AS svc_update,
  has_table_privilege('service_role', c.oid, 'DELETE')  AS svc_delete
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY c.relname;

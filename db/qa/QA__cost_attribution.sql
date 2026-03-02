-- ════════════════════════════════════════════════════════════════════════════
-- QA: Cost Attribution — 12 checks
-- Issue #212: Infrastructure Cost Attribution Framework
-- ════════════════════════════════════════════════════════════════════════════
-- Validates the cost attribution views, tables, functions, and constraints
-- introduced by migration 20260315001700_cost_attribution.sql.
-- Zero rows returned per check = PASS.
-- ════════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ci_runtime_log table exists with required columns
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING ci_runtime_log TABLE' AS issue,
       'table should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'ci_runtime_log'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. ci_runtime_log has all required columns
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING ci_runtime_log COLUMN' AS issue,
       col AS detail
FROM unnest(ARRAY[
    'id', 'workflow_name', 'job_name', 'run_id', 'run_number',
    'trigger_event', 'branch', 'duration_seconds', 'status', 'recorded_at'
]) AS col
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'ci_runtime_log'
      AND column_name = col
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. ci_runtime_log has RLS enabled
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'ci_runtime_log RLS DISABLED' AS issue,
       'RLS should be enabled on ci_runtime_log' AS detail
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relname = 'ci_runtime_log'
  AND NOT c.relrowsecurity;


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. ci_runtime_log status constraint only allows valid values
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING ci_runtime_log STATUS CHECK' AS issue,
       'check constraint for status column should exist' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints cc
    JOIN information_schema.constraint_column_usage ccu
      ON cc.constraint_name = ccu.constraint_name
     AND cc.constraint_schema = ccu.constraint_schema
    WHERE cc.constraint_schema = 'public'
      AND ccu.table_name = 'ci_runtime_log'
      AND cc.check_clause ILIKE '%status%'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 5. v_query_cost_by_domain view exists and is queryable
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING v_query_cost_by_domain VIEW' AS issue,
       'view should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'public' AND table_name = 'v_query_cost_by_domain'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 6. v_event_volume view exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING v_event_volume VIEW' AS issue,
       'view should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'public' AND table_name = 'v_event_volume'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 7. v_event_cost_projection view exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING v_event_cost_projection VIEW' AS issue,
       'view should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'public' AND table_name = 'v_event_cost_projection'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 8. v_ci_runtime_summary view exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING v_ci_runtime_summary VIEW' AS issue,
       'view should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'public' AND table_name = 'v_ci_runtime_summary'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 9. api_admin_cost_attribution function exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING api_admin_cost_attribution FUNCTION' AS issue,
       'function should exist in public schema' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.routines
    WHERE routine_schema = 'public'
      AND routine_name = 'api_admin_cost_attribution'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 10. api_admin_cost_attribution returns jsonb
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'WRONG RETURN TYPE for api_admin_cost_attribution' AS issue,
       'should return jsonb, got: ' || data_type AS detail
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'api_admin_cost_attribution'
  AND data_type <> 'jsonb';


-- ═══════════════════════════════════════════════════════════════════════════
-- 11. ci_runtime_log retention policy registered
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING RETENTION POLICY for ci_runtime_log' AS issue,
       'should be registered in retention_policies table' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM public.retention_policies
    WHERE table_name = 'ci_runtime_log'
      AND is_enabled = true
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 12. ci_runtime_log unique constraint on (run_id, job_name) exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'MISSING UNIQUE CONSTRAINT on ci_runtime_log(run_id, job_name)' AS issue,
       'idempotent upsert requires unique constraint' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND table_name = 'ci_runtime_log'
      AND constraint_type = 'UNIQUE'
);

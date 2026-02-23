-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Query-Level Performance Guardrails
-- Issue: #185 — [Hardening 5/7] Query-Level Performance Guardrails
--
-- Changes:
--   1. Update statement_timeout: global=30s, anon=10s, authenticated=15s
--   2. Enable pg_stat_statements extension
--   3. report_slow_queries(threshold_ms) — surfaces queries above threshold
--   4. check_plan_quality(query_text) — flags seq scans / nested loops
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Statement Timeout Configuration
--    Previous: 5s across anon/authenticated/authenticator
--    New: tiered approach — stricter for anonymous, looser for authenticated
--    service_role / postgres remain unlimited for pipeline/admin operations
-- ─────────────────────────────────────────────────────────────────────────────

-- Global database-level timeout (safety net for all roles)
ALTER DATABASE postgres SET statement_timeout = '30s';

-- Per-role timeouts (override global for user-facing roles)
DO $$
DECLARE
    role_cfg RECORD;
BEGIN
    FOR role_cfg IN
        SELECT * FROM (VALUES
            ('anon',          '10s'),
            ('authenticated', '15s'),
            ('authenticator', '10s')  -- authenticator proxies anon, keep restrictive
        ) AS t(role_name, timeout_val)
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_cfg.role_name) THEN
            EXECUTE format(
                'ALTER ROLE %I SET statement_timeout = %L',
                role_cfg.role_name, role_cfg.timeout_val
            );
        END IF;
    END LOOP;
END
$$;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Enable pg_stat_statements
--    Supabase includes this extension; we just need to CREATE it.
--    Provides cumulative query statistics for slow query analysis.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. report_slow_queries(threshold_ms)
--    Returns queries whose mean execution time exceeds the threshold.
--    SECURITY DEFINER: pg_stat_statements requires superuser-level access.
--    Restricted to service_role via REVOKE/GRANT below.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION report_slow_queries(
    p_threshold_ms FLOAT DEFAULT 100
)
RETURNS TABLE(
    query_preview  TEXT,
    calls          BIGINT,
    avg_ms         FLOAT,
    max_ms         FLOAT,
    total_ms       FLOAT,
    rows_returned  BIGINT,
    category       TEXT
)
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
    -- pg_stat_statements view only exists when shared_preload_libraries
    -- includes it (always on Supabase, may be absent in bare CI PostgreSQL).
    IF NOT EXISTS (
        SELECT 1 FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'pg_catalog' AND c.relname = 'pg_stat_statements'
    ) THEN
        RAISE NOTICE 'pg_stat_statements view not available — returning empty result';
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        LEFT(s.query, 200)                                     AS query_preview,
        s.calls                                                AS calls,
        ROUND(s.mean_exec_time::numeric, 2)::FLOAT             AS avg_ms,
        ROUND(s.max_exec_time::numeric, 2)::FLOAT              AS max_ms,
        ROUND(s.total_exec_time::numeric, 2)::FLOAT            AS total_ms,
        s.rows                                                 AS rows_returned,
        CASE
            WHEN s.mean_exec_time > 1000  THEN 'critical (>1s)'
            WHEN s.mean_exec_time > 500   THEN 'slow (>500ms)'
            WHEN s.mean_exec_time > p_threshold_ms THEN 'warning (>threshold)'
            ELSE 'ok'
        END                                                    AS category
    FROM pg_stat_statements s
    WHERE s.mean_exec_time > p_threshold_ms
      AND s.query NOT LIKE '%pg_stat%'
      AND s.query NOT LIKE '%pg_catalog%'
    ORDER BY s.mean_exec_time DESC
    LIMIT 50;
END;
$$;

COMMENT ON FUNCTION report_slow_queries IS
    'Returns queries whose mean execution time exceeds the given threshold (ms). '
    'Uses pg_stat_statements. Restricted to service_role.';

-- Restrict access: admin/service only
REVOKE EXECUTE ON FUNCTION report_slow_queries FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION report_slow_queries FROM anon;
REVOKE EXECUTE ON FUNCTION report_slow_queries FROM authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. check_plan_quality(query_text)
--    Runs EXPLAIN ANALYZE on the given query and flags problematic plan nodes:
--    - Seq Scan on > 100 estimated rows
--    - Nested Loop with 50+ iterations
--    - Row estimate off by 10x+
--
--    WARNING: Executes arbitrary SQL. Restricted to service_role.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION check_plan_quality(
    p_query_text TEXT
)
RETURNS TABLE(
    plan_node      TEXT,
    node_type      TEXT,
    estimated_rows FLOAT,
    actual_rows    FLOAT,
    loops          FLOAT,
    warning        TEXT
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
    plan_json JSONB;
BEGIN
    -- Get EXPLAIN ANALYZE output as JSON
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || p_query_text INTO plan_json;

    -- Extract plan nodes and flag issues
    RETURN QUERY
    WITH RECURSIVE nodes AS (
        SELECT (plan_json->0->'Plan')::JSONB AS node, 0 AS depth
        UNION ALL
        SELECT jsonb_array_elements(n.node->'Plans'), n.depth + 1
        FROM nodes n
        WHERE n.node->'Plans' IS NOT NULL
    )
    SELECT
        repeat('  ', n2.depth) || (n2.node->>'Node Type'),
        n2.node->>'Node Type',
        (n2.node->>'Plan Rows')::FLOAT,
        (n2.node->>'Actual Rows')::FLOAT,
        (n2.node->>'Actual Loops')::FLOAT,
        CASE
            WHEN n2.node->>'Node Type' = 'Seq Scan'
                 AND (n2.node->>'Plan Rows')::FLOAT > 100
                THEN 'Sequential scan on >100 rows - consider index'
            WHEN n2.node->>'Node Type' = 'Nested Loop'
                 AND (n2.node->>'Actual Loops')::FLOAT > 50
                THEN 'Nested loop with 50+ iterations - potential N+1'
            WHEN (n2.node->>'Actual Rows')::FLOAT >
                 (n2.node->>'Plan Rows')::FLOAT * 10
                THEN 'Row estimate off by 10x+ - consider ANALYZE'
            ELSE NULL
        END
    FROM nodes n2
    WHERE (
        (n2.node->>'Node Type' = 'Seq Scan'
         AND (n2.node->>'Plan Rows')::FLOAT > 100)
        OR
        (n2.node->>'Node Type' = 'Nested Loop'
         AND (n2.node->>'Actual Loops')::FLOAT > 50)
        OR
        ((n2.node->>'Actual Rows')::FLOAT >
         (n2.node->>'Plan Rows')::FLOAT * 10)
    );
END;
$$;

COMMENT ON FUNCTION check_plan_quality IS
    'Runs EXPLAIN ANALYZE on the given query and flags problematic plan nodes '
    '(seq scans on large tables, high-iteration nested loops, inaccurate row estimates). '
    'WARNING: Executes arbitrary SQL — restricted to service_role only.';

-- Restrict access: admin/service only
REVOKE EXECUTE ON FUNCTION check_plan_quality FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION check_plan_quality FROM anon;
REVOKE EXECUTE ON FUNCTION check_plan_quality FROM authenticated;

COMMIT;

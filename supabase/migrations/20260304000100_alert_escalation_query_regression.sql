-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Alert Escalation & Query Regression Detection
-- Issue: #211 (GOV-F2)
--
-- Creates:
--   1. query_performance_snapshots — weekly query performance history
--   2. snapshot_query_performance() — captures pg_stat_statements into snapshots
--   3. v_query_regressions — detects week-over-week performance regressions
--   4. v_unused_indexes — identifies unused or rarely used indexes
--   5. v_missing_indexes — identifies tables needing index coverage
--   6. v_index_bloat_estimate — estimates index fragmentation
--
-- Dependencies: pg_stat_statements extension (enabled in 20260222050000)
--
-- Rollback:
--   DROP VIEW IF EXISTS v_index_bloat_estimate;
--   DROP VIEW IF EXISTS v_missing_indexes;
--   DROP VIEW IF EXISTS v_unused_indexes;
--   DROP VIEW IF EXISTS v_query_regressions;
--   DROP FUNCTION IF EXISTS snapshot_query_performance();
--   DROP TABLE IF EXISTS query_performance_snapshots;
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── Step 1: query_performance_snapshots table ───────────────────────────────

CREATE TABLE IF NOT EXISTS public.query_performance_snapshots (
    id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    snapshot_date   date NOT NULL DEFAULT CURRENT_DATE,
    queryid         bigint NOT NULL,
    query_preview   text,
    calls           bigint,
    mean_ms         numeric(10,2),
    max_ms          numeric(10,2),
    cache_hit_pct   numeric(5,1),
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (snapshot_date, queryid)
);

COMMENT ON TABLE public.query_performance_snapshots IS
    'Weekly snapshots of pg_stat_statements query performance. Retention: 12 weeks. Used for regression detection.';

-- ─── Step 2: RLS (Pattern B: service-write / auth-read) ─────────────────────

ALTER TABLE public.query_performance_snapshots ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'query_performance_snapshots' AND policyname = 'qps_service_all') THEN
        CREATE POLICY qps_service_all ON public.query_performance_snapshots
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'query_performance_snapshots' AND policyname = 'qps_auth_read') THEN
        CREATE POLICY qps_auth_read ON public.query_performance_snapshots
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

-- ─── Step 3: snapshot_query_performance() ────────────────────────────────────
--    Captures current pg_stat_statements data for queries with > 10 calls.
--    SECURITY DEFINER: pg_stat_statements requires elevated access.
--    Restricted to service_role.

CREATE OR REPLACE FUNCTION public.snapshot_query_performance()
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog
AS $fn$
DECLARE
    v_count integer := 0;
BEGIN
    -- Guard: pg_stat_statements may not be available in CI/test environments
    IF NOT EXISTS (
        SELECT 1 FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'pg_catalog' AND c.relname = 'pg_stat_statements'
    ) THEN
        RETURN jsonb_build_object(
            'status', 'skipped',
            'reason', 'pg_stat_statements not available',
            'rows_inserted', 0
        );
    END IF;

    INSERT INTO public.query_performance_snapshots
        (snapshot_date, queryid, query_preview, calls, mean_ms, max_ms, cache_hit_pct)
    SELECT
        CURRENT_DATE,
        s.queryid,
        LEFT(s.query, 200),
        s.calls,
        ROUND(s.mean_exec_time::numeric, 2),
        ROUND(s.max_exec_time::numeric, 2),
        ROUND(
            s.shared_blks_hit * 100.0
            / NULLIF(s.shared_blks_hit + s.shared_blks_read, 0),
            1
        )
    FROM pg_stat_statements s
    WHERE s.calls > 10
    ON CONFLICT (snapshot_date, queryid) DO UPDATE SET
        calls         = EXCLUDED.calls,
        mean_ms       = EXCLUDED.mean_ms,
        max_ms        = EXCLUDED.max_ms,
        cache_hit_pct = EXCLUDED.cache_hit_pct;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    -- Retention: delete snapshots older than 12 weeks
    DELETE FROM public.query_performance_snapshots
    WHERE snapshot_date < CURRENT_DATE - 84;

    RETURN jsonb_build_object(
        'status', 'ok',
        'snapshot_date', CURRENT_DATE,
        'rows_inserted', v_count
    );
END;
$fn$;

COMMENT ON FUNCTION public.snapshot_query_performance() IS
    'Captures pg_stat_statements performance data into query_performance_snapshots. '
    'Run weekly. Deletes data older than 12 weeks. Restricted to service_role.';

REVOKE EXECUTE ON FUNCTION public.snapshot_query_performance() FROM anon, public;
GRANT EXECUTE ON FUNCTION public.snapshot_query_performance() TO service_role;

-- ─── Step 4: v_query_regressions view ────────────────────────────────────────
--    Compares latest snapshot against the snapshot from 7 days prior.

CREATE OR REPLACE VIEW public.v_query_regressions AS
SELECT
    c.queryid,
    c.query_preview,
    p.mean_ms                                                       AS prev_mean_ms,
    c.mean_ms                                                       AS curr_mean_ms,
    ROUND((c.mean_ms - p.mean_ms) / NULLIF(p.mean_ms, 0) * 100, 1) AS regression_pct,
    c.calls                                                         AS curr_calls,
    CASE
        WHEN c.mean_ms > p.mean_ms * 2   THEN 'CRITICAL'
        WHEN c.mean_ms > p.mean_ms * 1.5 THEN 'WARNING'
        ELSE 'OK'
    END                                                             AS status
FROM public.query_performance_snapshots c
JOIN public.query_performance_snapshots p
    ON  c.queryid = p.queryid
    AND p.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM public.query_performance_snapshots
        WHERE snapshot_date < c.snapshot_date
    )
WHERE c.snapshot_date = (
    SELECT MAX(snapshot_date) FROM public.query_performance_snapshots
)
AND c.mean_ms > p.mean_ms * 1.3  -- only show > 30% regressions
ORDER BY regression_pct DESC;

COMMENT ON VIEW public.v_query_regressions IS
    'Compares query performance between the latest two snapshots. '
    'Shows regressions > 30% with WARNING/CRITICAL status classification.';

-- ─── Step 5: v_unused_indexes ────────────────────────────────────────────────

CREATE OR REPLACE VIEW public.v_unused_indexes AS
SELECT
    schemaname,
    relname                                      AS tablename,
    indexrelname                                 AS indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    pg_relation_size(indexrelid)                 AS index_size_bytes,
    CASE
        WHEN idx_scan = 0  THEN 'UNUSED'
        WHEN idx_scan < 10 THEN 'RARELY_USED'
        ELSE 'ACTIVE'
    END AS status
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC, pg_relation_size(indexrelid) DESC;

COMMENT ON VIEW public.v_unused_indexes IS
    'Lists public-schema indexes ranked by scan count. UNUSED = 0 scans since stats reset.';

-- ─── Step 6: v_missing_indexes ───────────────────────────────────────────────

CREATE OR REPLACE VIEW public.v_missing_indexes AS
SELECT
    schemaname,
    relname                                      AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    CASE
        WHEN seq_scan > 100 AND COALESCE(idx_scan, 0) = 0 THEN 'NEEDS_INDEX'
        WHEN seq_scan > COALESCE(idx_scan, 0) * 10        THEN 'INDEX_UNDERUSED'
        ELSE 'OK'
    END AS status,
    pg_size_pretty(pg_relation_size(relid))      AS table_size,
    pg_relation_size(relid)                      AS table_size_bytes
FROM pg_stat_user_tables
WHERE schemaname = 'public'
  AND seq_scan > 50
ORDER BY seq_tup_read DESC;

COMMENT ON VIEW public.v_missing_indexes IS
    'Identifies tables with high sequential scan counts relative to index scans. '
    'NEEDS_INDEX: > 100 seq scans with 0 index scans.';

-- ─── Step 7: v_index_bloat_estimate ──────────────────────────────────────────

CREATE OR REPLACE VIEW public.v_index_bloat_estimate AS
SELECT
    t.relname                                                       AS tablename,
    i.indexrelname                                                  AS indexname,
    pg_size_pretty(pg_relation_size(i.indexrelid))                  AS index_size,
    pg_size_pretty(pg_relation_size(t.relid))                       AS table_size,
    ROUND(
        pg_relation_size(i.indexrelid)::numeric
        / NULLIF(pg_relation_size(t.relid), 0) * 100,
        1
    ) AS index_to_table_pct,
    CASE
        WHEN pg_relation_size(i.indexrelid) > pg_relation_size(t.relid) * 2
            THEN 'POSSIBLY_BLOATED'
        ELSE 'OK'
    END AS status
FROM pg_stat_user_indexes i
JOIN pg_stat_user_tables t ON i.relid = t.relid
WHERE i.schemaname = 'public'
ORDER BY pg_relation_size(i.indexrelid) DESC;

COMMENT ON VIEW public.v_index_bloat_estimate IS
    'Estimates index bloat by comparing index size to table size. '
    'POSSIBLY_BLOATED: index > 2x table size.';

-- ─── Step 8: Access control for monitoring views ─────────────────────────────
--    These views read from pg_stat_* system catalogs.
--    Grant SELECT to authenticated users (read-only monitoring).
--    Revoke from anon (no public access to performance data).

REVOKE ALL ON public.v_query_regressions    FROM anon;
REVOKE ALL ON public.v_unused_indexes       FROM anon;
REVOKE ALL ON public.v_missing_indexes      FROM anon;
REVOKE ALL ON public.v_index_bloat_estimate FROM anon;

GRANT SELECT ON public.v_query_regressions    TO authenticated, service_role;
GRANT SELECT ON public.v_unused_indexes       TO authenticated, service_role;
GRANT SELECT ON public.v_missing_indexes      TO authenticated, service_role;
GRANT SELECT ON public.v_index_bloat_estimate TO authenticated, service_role;
GRANT SELECT ON public.query_performance_snapshots TO authenticated, service_role;

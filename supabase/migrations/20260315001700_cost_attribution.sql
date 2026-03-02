-- ════════════════════════════════════════════════════════════════════════════
-- Infrastructure Cost Attribution Framework
-- Issue #212: [GOV-G1] Infrastructure Cost Attribution Framework
-- ════════════════════════════════════════════════════════════════════════════
--
-- Adds cost attribution views and functions that classify infrastructure
-- usage by domain (scoring, search, events, etc.) across three dimensions:
--   1. Query compute cost — from query_performance_snapshots
--   2. Event ingestion volume — from analytics_events
--   3. CI pipeline runtime — from ci_runtime_log (pushed by CI workflows)
--
-- Objects created:
--   Tables:  ci_runtime_log
--   Views:   v_query_cost_by_domain, v_event_volume,
--            v_event_cost_projection, v_ci_runtime_summary
--   Functions: api_admin_cost_attribution()
--
-- Rollback:
--   DROP FUNCTION IF EXISTS api_admin_cost_attribution() CASCADE;
--   DROP VIEW IF EXISTS v_ci_runtime_summary, v_event_cost_projection,
--                       v_event_volume, v_query_cost_by_domain CASCADE;
--   DROP TABLE IF EXISTS ci_runtime_log CASCADE;
-- ════════════════════════════════════════════════════════════════════════════


-- ─── 1. ci_runtime_log — CI pipeline execution timing history ───────────────
-- Populated by GitHub Actions workflow steps after each run.
-- Each row represents one job in one workflow run.

CREATE TABLE IF NOT EXISTS public.ci_runtime_log (
    id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_name   text        NOT NULL,
    job_name        text        NOT NULL,
    run_id          bigint,                       -- GitHub Actions run ID
    run_number      integer,                      -- GitHub Actions run number
    trigger_event   text,                         -- 'push', 'pull_request', 'schedule', etc.
    branch          text,
    duration_seconds integer   NOT NULL CHECK (duration_seconds >= 0),
    status          text       NOT NULL DEFAULT 'success'
                               CHECK (status IN ('success', 'failure', 'cancelled', 'skipped')),
    recorded_at     timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_ci_runtime_run_job UNIQUE (run_id, job_name)
);

COMMENT ON TABLE public.ci_runtime_log IS
    'CI pipeline execution timings. Populated by GH Actions post-job steps. Retention: 90 days.';

CREATE INDEX IF NOT EXISTS idx_ci_runtime_log_recorded
    ON public.ci_runtime_log (recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_ci_runtime_log_workflow
    ON public.ci_runtime_log (workflow_name, recorded_at DESC);

-- RLS: service-write / auth-read
ALTER TABLE public.ci_runtime_log ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ci_runtime_log' AND policyname = 'ci_runtime_service_all') THEN
        CREATE POLICY ci_runtime_service_all ON public.ci_runtime_log
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ci_runtime_log' AND policyname = 'ci_runtime_auth_read') THEN
        CREATE POLICY ci_runtime_auth_read ON public.ci_runtime_log
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

REVOKE ALL ON public.ci_runtime_log FROM anon, public;
GRANT SELECT ON public.ci_runtime_log TO authenticated;
GRANT ALL    ON public.ci_runtime_log TO service_role;


-- ─── 2. v_query_cost_by_domain — Query cost attribution ────────────────────
-- Classifies captured query performance snapshots into domains using
-- naming convention patterns from the query text preview.
-- One row per domain per snapshot date.

CREATE OR REPLACE VIEW public.v_query_cost_by_domain AS
SELECT
    qps.snapshot_date,
    CASE
        WHEN qps.query_preview ILIKE '%scoring%'
          OR qps.query_preview ILIKE '%unhealthiness%'
          OR qps.query_preview ILIKE '%health_score%'
          OR qps.query_preview ILIKE '%compute_unhealthiness%'
          OR qps.query_preview ILIKE '%explain_score%'
          OR qps.query_preview ILIKE '%score_category%'
          THEN 'scoring'
        WHEN qps.query_preview ILIKE '%search%'
          OR qps.query_preview ILIKE '%tsvector%'
          OR qps.query_preview ILIKE '%pg_trgm%'
          OR qps.query_preview ILIKE '%autocomplete%'
          THEN 'search'
        WHEN qps.query_preview ILIKE '%analytics_event%'
          OR qps.query_preview ILIKE '%event_schema%'
          OR qps.query_preview ILIKE '%track_event%'
          THEN 'events'
        WHEN qps.query_preview ILIKE '%provenance%'
          OR qps.query_preview ILIKE '%field_provenance%'
          OR qps.query_preview ILIKE '%data_confidence%'
          THEN 'provenance'
        WHEN qps.query_preview ILIKE '%flag%'
          OR qps.query_preview ILIKE '%feature_flag%'
          THEN 'flags'
        WHEN qps.query_preview ILIKE '%ingredient%'
          OR qps.query_preview ILIKE '%allergen%'
          THEN 'ingredients'
        WHEN qps.query_preview ILIKE '%scan%'
          OR qps.query_preview ILIKE '%submission%'
          THEN 'scanner'
        WHEN qps.query_preview ILIKE '%auth%'
          OR qps.query_preview ILIKE '%user_pref%'
          OR qps.query_preview ILIKE '%health_profile%'
          THEN 'auth_users'
        ELSE 'other'
    END                                             AS domain,
    count(*)                                        AS query_count,
    COALESCE(sum(qps.calls), 0)                     AS total_calls,
    ROUND(sum(qps.mean_ms * qps.calls)::numeric, 2) AS total_exec_ms,
    ROUND(
        sum(qps.mean_ms * qps.calls)::numeric
        / NULLIF(sum(qps.calls), 0), 2
    )                                               AS avg_ms_per_call,
    ROUND(avg(qps.cache_hit_pct), 1)                AS avg_cache_hit_pct
FROM public.query_performance_snapshots qps
GROUP BY qps.snapshot_date,
    CASE
        WHEN qps.query_preview ILIKE '%scoring%'
          OR qps.query_preview ILIKE '%unhealthiness%'
          OR qps.query_preview ILIKE '%health_score%'
          OR qps.query_preview ILIKE '%compute_unhealthiness%'
          OR qps.query_preview ILIKE '%explain_score%'
          OR qps.query_preview ILIKE '%score_category%'
          THEN 'scoring'
        WHEN qps.query_preview ILIKE '%search%'
          OR qps.query_preview ILIKE '%tsvector%'
          OR qps.query_preview ILIKE '%pg_trgm%'
          OR qps.query_preview ILIKE '%autocomplete%'
          THEN 'search'
        WHEN qps.query_preview ILIKE '%analytics_event%'
          OR qps.query_preview ILIKE '%event_schema%'
          OR qps.query_preview ILIKE '%track_event%'
          THEN 'events'
        WHEN qps.query_preview ILIKE '%provenance%'
          OR qps.query_preview ILIKE '%field_provenance%'
          OR qps.query_preview ILIKE '%data_confidence%'
          THEN 'provenance'
        WHEN qps.query_preview ILIKE '%flag%'
          OR qps.query_preview ILIKE '%feature_flag%'
          THEN 'flags'
        WHEN qps.query_preview ILIKE '%ingredient%'
          OR qps.query_preview ILIKE '%allergen%'
          THEN 'ingredients'
        WHEN qps.query_preview ILIKE '%scan%'
          OR qps.query_preview ILIKE '%submission%'
          THEN 'scanner'
        WHEN qps.query_preview ILIKE '%auth%'
          OR qps.query_preview ILIKE '%user_pref%'
          OR qps.query_preview ILIKE '%health_profile%'
          THEN 'auth_users'
        ELSE 'other'
    END
ORDER BY qps.snapshot_date DESC, total_exec_ms DESC;


-- ─── 3. v_event_volume — Daily event ingestion volume ──────────────────────
-- Tracks event volume by type per day from analytics_events.

CREATE OR REPLACE VIEW public.v_event_volume AS
SELECT
    ae.event_name,
    DATE_TRUNC('day', ae.created_at)::date          AS event_date,
    count(*)                                         AS event_count,
    count(DISTINCT ae.user_id)                       AS unique_users,
    count(DISTINCT ae.session_id)                    AS unique_sessions,
    count(DISTINCT ae.device_type) FILTER
        (WHERE ae.device_type IS NOT NULL)           AS device_type_count,
    pg_size_pretty(
        sum(pg_column_size(ae.event_data))::bigint
    )                                                AS payload_size
FROM public.analytics_events ae
GROUP BY ae.event_name, DATE_TRUNC('day', ae.created_at)::date
ORDER BY event_date DESC, event_count DESC;


-- ─── 4. v_event_cost_projection — Monthly event cost projection ────────────
-- Projects monthly event volume and estimated storage cost.
-- Cost model: $5 per million events (conservative estimate for
-- Supabase Pro tier compute + storage).

CREATE OR REPLACE VIEW public.v_event_cost_projection AS
SELECT
    DATE_TRUNC('month', ae.created_at)::date         AS month,
    count(*)                                          AS total_events,
    count(DISTINCT ae.user_id)                        AS unique_users,
    count(DISTINCT ae.session_id)                     AS unique_sessions,
    pg_size_pretty(
        sum(pg_column_size(ae.event_data))::bigint
    )                                                 AS total_payload_size,
    sum(pg_column_size(ae.event_data))                AS payload_bytes,
    -- Cost estimate: $5 per million events (adjustable)
    ROUND(count(*) / 1000000.0 * 5, 2)               AS estimated_cost_usd
FROM public.analytics_events ae
GROUP BY DATE_TRUNC('month', ae.created_at)::date
ORDER BY month DESC;


-- ─── 5. v_ci_runtime_summary — CI pipeline runtime trends ──────────────────
-- Weekly CI runtime aggregations by workflow name.

CREATE OR REPLACE VIEW public.v_ci_runtime_summary AS
SELECT
    cr.workflow_name,
    DATE_TRUNC('week', cr.recorded_at)::date        AS week,
    count(*)                                         AS run_count,
    ROUND(avg(cr.duration_seconds), 0)               AS avg_duration_s,
    max(cr.duration_seconds)                         AS max_duration_s,
    min(cr.duration_seconds)                         AS min_duration_s,
    sum(cr.duration_seconds)                         AS total_duration_s,
    -- GitHub Actions billing: rounded up to nearest minute per job
    sum(CEIL(cr.duration_seconds / 60.0)::integer)   AS billable_minutes,
    count(*) FILTER (WHERE cr.status = 'failure')    AS failure_count,
    ROUND(
        100.0 * count(*) FILTER (WHERE cr.status = 'success')
        / NULLIF(count(*), 0), 1
    )                                                AS success_rate_pct
FROM public.ci_runtime_log cr
GROUP BY cr.workflow_name, DATE_TRUNC('week', cr.recorded_at)::date
ORDER BY week DESC, total_duration_s DESC;


-- ─── 6. api_admin_cost_attribution() — Combined cost overview ──────────────
-- Returns a structured JSONB summary across all three cost dimensions:
-- query compute, event ingestion, and CI runtime.

CREATE OR REPLACE FUNCTION public.api_admin_cost_attribution()
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_result jsonb;
BEGIN
    -- Auth guard: require authenticated user
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', 1,
            'error', 'Authentication required'
        );
    END IF;

    SELECT jsonb_build_object(
        'api_version', 1,
        'generated_at', now(),

        -- ── Query compute costs (last 7 days of snapshots) ──
        'query_compute', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'domain',          domain,
                    'query_count',     query_count,
                    'total_calls',     total_calls,
                    'total_exec_ms',   total_exec_ms,
                    'avg_ms_per_call', avg_ms_per_call,
                    'avg_cache_hit_pct', avg_cache_hit_pct
                ) ORDER BY total_exec_ms DESC
            ), '[]'::jsonb)
            FROM v_query_cost_by_domain
            WHERE snapshot_date >= CURRENT_DATE - 7
        ),

        -- ── Query compute totals ──
        'query_compute_summary', (
            SELECT jsonb_build_object(
                'total_queries',   COALESCE(sum(query_count), 0),
                'total_calls',     COALESCE(sum(total_calls), 0),
                'total_exec_ms',   COALESCE(sum(total_exec_ms), 0),
                'avg_cache_hit',   COALESCE(ROUND(avg(avg_cache_hit_pct), 1), 0),
                'snapshot_count',  count(DISTINCT snapshot_date),
                'status', CASE
                    WHEN COALESCE(avg(avg_cache_hit_pct), 100) < 80 THEN 'warning'
                    ELSE 'healthy'
                END
            )
            FROM v_query_cost_by_domain
            WHERE snapshot_date >= CURRENT_DATE - 7
        ),

        -- ── Event ingestion (last 30 days) ──
        'event_volume', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'event_name',    event_name,
                    'event_count',   event_count,
                    'unique_users',  unique_users,
                    'payload_size',  payload_size
                ) ORDER BY event_count DESC
            ), '[]'::jsonb)
            FROM v_event_volume
            WHERE event_date >= CURRENT_DATE - 30
        ),

        -- ── Event cost projection (current and previous month) ──
        'event_cost_projection', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'month',              month,
                    'total_events',       total_events,
                    'unique_users',       unique_users,
                    'total_payload_size', total_payload_size,
                    'estimated_cost_usd', estimated_cost_usd
                ) ORDER BY month DESC
            ), '[]'::jsonb)
            FROM v_event_cost_projection
            WHERE month >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 months'
        ),

        -- ── CI runtime (last 4 weeks) ──
        'ci_runtime', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'workflow_name',   workflow_name,
                    'week',            week,
                    'run_count',       run_count,
                    'avg_duration_s',  avg_duration_s,
                    'max_duration_s',  max_duration_s,
                    'billable_minutes', billable_minutes,
                    'success_rate_pct', success_rate_pct
                ) ORDER BY week DESC, total_duration_s DESC
            ), '[]'::jsonb)
            FROM v_ci_runtime_summary
            WHERE week >= CURRENT_DATE - 28
        ),

        -- ── CI runtime totals ──
        'ci_runtime_summary', (
            SELECT jsonb_build_object(
                'total_runs',      COALESCE(sum(run_count), 0),
                'total_minutes',   COALESCE(sum(billable_minutes), 0),
                'total_failures',  COALESCE(sum(failure_count), 0),
                'avg_success_pct', COALESCE(ROUND(avg(success_rate_pct), 1), 0),
                'status', CASE
                    WHEN COALESCE(sum(billable_minutes), 0) > 1800 THEN 'critical'
                    WHEN COALESCE(sum(billable_minutes), 0) > 900  THEN 'warning'
                    ELSE 'healthy'
                END
            )
            FROM v_ci_runtime_summary
            WHERE week >= CURRENT_DATE - 28
        ),

        -- ── Database storage (live) ──
        'storage', (
            SELECT jsonb_build_object(
                'database_size',   pg_size_pretty(pg_database_size(current_database())),
                'database_bytes',  pg_database_size(current_database()),
                'status', CASE
                    WHEN pg_database_size(current_database()) > 5368709120  THEN 'critical'
                    WHEN pg_database_size(current_database()) > 2147483648  THEN 'warning'
                    ELSE 'healthy'
                END
            )
        ),

        -- ── Overall health status ──
        'overall_status', (
            SELECT CASE
                WHEN pg_database_size(current_database()) > 5368709120 THEN 'critical'
                WHEN (SELECT COALESCE(sum(billable_minutes), 0) FROM v_ci_runtime_summary WHERE week >= CURRENT_DATE - 28) > 1800 THEN 'critical'
                WHEN (SELECT COALESCE(avg(avg_cache_hit_pct), 100) FROM v_query_cost_by_domain WHERE snapshot_date >= CURRENT_DATE - 7) < 80 THEN 'warning'
                WHEN pg_database_size(current_database()) > 2147483648 THEN 'warning'
                ELSE 'healthy'
            END
        ),

        -- ── Activation thresholds (from issue #212) ──
        'activation_thresholds', jsonb_build_object(
            'monthly_cost_threshold_usd', 100,
            'ci_runtime_threshold_min',   30,
            'event_volume_threshold_month', 100000,
            'country_count_threshold',    3,
            'db_size_threshold_gb',       5,
            'current_country_count',      (SELECT count(*) FROM country_ref WHERE is_active),
            'thresholds_breached',        (
                SELECT jsonb_agg(threshold)
                FROM (
                    SELECT 'db_size_5gb' AS threshold
                    WHERE pg_database_size(current_database()) > 5368709120
                    UNION ALL
                    SELECT 'country_count_3'
                    WHERE (SELECT count(*) FROM country_ref WHERE is_active) >= 3
                    UNION ALL
                    SELECT 'event_volume_100k'
                    WHERE (SELECT count(*) FROM analytics_events
                           WHERE created_at > now() - INTERVAL '30 days') > 100000
                ) t
            )
        )
    ) INTO v_result;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.api_admin_cost_attribution() IS
    'Infrastructure cost attribution across query compute, event ingestion, and CI runtime. '
    'Returns structured JSONB with per-domain breakdown, projections, and activation thresholds. '
    'Issue #212.';


-- ─── Grants ─────────────────────────────────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.api_admin_cost_attribution() FROM anon, public;
GRANT EXECUTE ON FUNCTION public.api_admin_cost_attribution() TO authenticated;


-- ─── Retention: ci_runtime_log cleanup via existing retention framework ─────
INSERT INTO public.retention_policies (table_name, timestamp_column, active_retention_days, is_enabled)
VALUES ('ci_runtime_log', 'recorded_at', 90, true)
ON CONFLICT (table_name) DO UPDATE SET
    timestamp_column      = EXCLUDED.timestamp_column,
    active_retention_days = EXCLUDED.active_retention_days,
    is_enabled            = EXCLUDED.is_enabled;

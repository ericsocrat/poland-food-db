-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: MV Refresh Log & Automated Tracking
-- Issue: #377 — Materialized view refresh automation
-- Rollback: DROP TABLE IF EXISTS mv_refresh_log; then restore original
--           refresh_all_materialized_views() from previous migration.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. mv_refresh_log table ─────────────────────────────────────────────────
-- Tracks when each MV was refreshed, how long it took, and what triggered it.

CREATE TABLE IF NOT EXISTS public.mv_refresh_log (
    refresh_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mv_name      text        NOT NULL,
    refreshed_at timestamptz NOT NULL DEFAULT now(),
    duration_ms  integer,
    row_count    bigint,
    triggered_by text        NOT NULL DEFAULT 'manual',
    CONSTRAINT chk_mv_refresh_triggered_by
        CHECK (triggered_by IN ('manual', 'post_pipeline', 'scheduled', 'api', 'migration'))
);

COMMENT ON TABLE  public.mv_refresh_log IS 'Audit trail for materialized view refreshes — when, how long, and what triggered each refresh.';
COMMENT ON COLUMN public.mv_refresh_log.mv_name      IS 'Name of the materialized view that was refreshed.';
COMMENT ON COLUMN public.mv_refresh_log.refreshed_at  IS 'Timestamp when the refresh completed.';
COMMENT ON COLUMN public.mv_refresh_log.duration_ms   IS 'Elapsed time in milliseconds for the REFRESH CONCURRENTLY operation.';
COMMENT ON COLUMN public.mv_refresh_log.row_count     IS 'Number of rows in the MV after refresh.';
COMMENT ON COLUMN public.mv_refresh_log.triggered_by  IS 'What initiated the refresh: manual, post_pipeline, scheduled, api, or migration.';

-- Index for lookups by MV name + recency (staleness queries)
CREATE INDEX IF NOT EXISTS idx_mv_refresh_log_name_time
    ON public.mv_refresh_log (mv_name, refreshed_at DESC);

-- ─── 2. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE public.mv_refresh_log ENABLE ROW LEVEL SECURITY;

-- service_role can read and write
GRANT SELECT, INSERT ON public.mv_refresh_log TO service_role;

-- authenticated users can read (for transparency / health dashboards)
GRANT SELECT ON public.mv_refresh_log TO authenticated;

-- anon: no access
REVOKE ALL ON public.mv_refresh_log FROM anon;

-- RLS policies
CREATE POLICY mv_refresh_log_service_write
    ON public.mv_refresh_log
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY mv_refresh_log_auth_read
    ON public.mv_refresh_log
    FOR SELECT
    TO authenticated
    USING (true);

-- ─── 3. Updated refresh_all_materialized_views() ─────────────────────────────
-- Now logs each refresh into mv_refresh_log.
-- Accepts optional p_triggered_by parameter (defaults to 'manual').
-- Drop the old no-parameter overload first to avoid ambiguity.

DROP FUNCTION IF EXISTS public.refresh_all_materialized_views();

CREATE OR REPLACE FUNCTION public.refresh_all_materialized_views(
    p_triggered_by text DEFAULT 'manual'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
SET statement_timeout TO '30s'
AS $function$
DECLARE
    start_ts  timestamptz;
    t1        numeric;
    t2        numeric;
    t3        numeric;
    r1        bigint;
    r2        bigint;
    r3        bigint;
    v_trigger text;
BEGIN
    -- Validate triggered_by
    v_trigger := COALESCE(p_triggered_by, 'manual');
    IF v_trigger NOT IN ('manual', 'post_pipeline', 'scheduled', 'api', 'migration') THEN
        v_trigger := 'manual';
    END IF;

    -- Refresh mv_ingredient_frequency
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    t1 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r1 := (SELECT COUNT(*) FROM mv_ingredient_frequency);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('mv_ingredient_frequency', t1::integer, r1, v_trigger);

    -- Refresh v_product_confidence
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
    t2 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r2 := (SELECT COUNT(*) FROM v_product_confidence);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('v_product_confidence', t2::integer, r2, v_trigger);

    -- Refresh mv_product_similarity
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_similarity;
    t3 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r3 := (SELECT COUNT(*) FROM mv_product_similarity);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('mv_product_similarity', t3::integer, r3, v_trigger);

    RETURN jsonb_build_object(
        'refreshed_at', NOW(),
        'triggered_by', v_trigger,
        'views', jsonb_build_array(
            jsonb_build_object('name', 'mv_ingredient_frequency',
                               'rows', r1,
                               'ms',   t1),
            jsonb_build_object('name', 'v_product_confidence',
                               'rows', r2,
                               'ms',   t2),
            jsonb_build_object('name', 'mv_product_similarity',
                               'rows', r3,
                               'ms',   t3)
        ),
        'total_ms', t1 + t2 + t3
    );
END;
$function$;

-- ─── 4. mv_last_refresh() — convenience view for staleness checks ────────────
-- Returns the most recent refresh per MV name.

CREATE OR REPLACE FUNCTION public.mv_last_refresh()
RETURNS TABLE (
    mv_name      text,
    refreshed_at timestamptz,
    duration_ms  integer,
    row_count    bigint,
    triggered_by text,
    age_minutes  double precision
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT DISTINCT ON (l.mv_name)
        l.mv_name,
        l.refreshed_at,
        l.duration_ms,
        l.row_count,
        l.triggered_by,
        EXTRACT(EPOCH FROM (now() - l.refreshed_at)) / 60.0 AS age_minutes
    FROM mv_refresh_log l
    ORDER BY l.mv_name, l.refreshed_at DESC;
$function$;

COMMENT ON FUNCTION public.mv_last_refresh IS 'Returns the most recent refresh entry per materialized view. Used by staleness checks and monitoring dashboards.';

-- Block anon from internal functions
REVOKE EXECUTE ON FUNCTION public.mv_last_refresh() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.refresh_all_materialized_views(text) FROM anon, public;

-- ─── 5. Update api_refresh_mvs() to pass 'api' trigger ──────────────────────

CREATE OR REPLACE FUNCTION public.api_refresh_mvs()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
SET statement_timeout TO '30s'
AS $function$
DECLARE
    refresh_result jsonb;
BEGIN
    refresh_result := refresh_all_materialized_views('api');
    RETURN jsonb_build_object(
        'status',    'refreshed',
        'timestamp', NOW(),
        'details',   refresh_result
    );
END;
$function$;

-- ─── 6. Seed initial log entry (current state) ──────────────────────────────
-- Record current MV state as a 'migration' triggered refresh so staleness
-- checks have a baseline.

INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
VALUES
    ('mv_ingredient_frequency', 0, (SELECT COUNT(*) FROM mv_ingredient_frequency), 'migration'),
    ('v_product_confidence',    0, (SELECT COUNT(*) FROM v_product_confidence),    'migration'),
    ('mv_product_similarity',   0, (SELECT COUNT(*) FROM mv_product_similarity),   'migration');

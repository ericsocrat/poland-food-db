-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: MV Hardening — CONCURRENTLY + Periodic Refresh RPC
-- Issue:     #138
-- Purpose:   Harden materialized views for scale (5K+ products):
--            1. Ensure unique indexes exist for CONCURRENTLY support
--            2. Re-create refresh_all_materialized_views() as SECURITY DEFINER
--               with statement_timeout guard
--            3. Create api_refresh_mvs() RPC (service_role only) for scheduled
--               refresh via cron / Vercel Cron / Edge Function
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Ensure unique indexes for CONCURRENTLY (idempotent)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_ingredient_freq_id
    ON mv_ingredient_frequency (ingredient_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_confidence_id
    ON v_product_confidence (product_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Harden refresh_all_materialized_views()
--    - SECURITY DEFINER so it runs as the owner (bypasses row-level security)
--    - statement_timeout = 30s to prevent runaway refreshes
--    - Returns JSONB with timing details (backward-compatible signature)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET statement_timeout = '30s'
AS $$
DECLARE
    start_ts  timestamptz;
    t1        numeric;
    t2        numeric;
BEGIN
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    t1 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));

    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
    t2 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));

    RETURN jsonb_build_object(
        'refreshed_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object('name', 'mv_ingredient_frequency',
                               'rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                               'ms',   t1),
            jsonb_build_object('name', 'v_product_confidence',
                               'rows', (SELECT COUNT(*) FROM v_product_confidence),
                               'ms',   t2)
        ),
        'total_ms', t1 + t2
    );
END;
$$;

-- Preserve existing grant model
REVOKE EXECUTE ON FUNCTION refresh_all_materialized_views() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION refresh_all_materialized_views() TO authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Create api_refresh_mvs() — service_role-only RPC for scheduled refresh
--    Wraps refresh_all_materialized_views() and returns a status envelope.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION api_refresh_mvs()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET statement_timeout = '30s'
AS $$
DECLARE
    refresh_result jsonb;
BEGIN
    refresh_result := refresh_all_materialized_views();
    RETURN jsonb_build_object(
        'status',    'refreshed',
        'timestamp', NOW(),
        'details',   refresh_result
    );
END;
$$;

-- service_role ONLY — not accessible from frontend or anonymous callers
REVOKE ALL    ON FUNCTION api_refresh_mvs() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION api_refresh_mvs() TO service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Statement timeout documentation (applied via ALTER ROLE, not migration)
--    Already configured in security_hardening.sql for anon/authenticated/
--    authenticator at 5s. The MVs have their own 30s timeout above.
--
--    Recommended PostgREST / Supabase Dashboard config (production):
--      statement_timeout = 5000   (5 seconds for API queries)
--
--    For periodic MV refresh calls (service_role via cron):
--      The 30s SET on api_refresh_mvs() overrides the session default.
--
--    Recommended refresh cadence:
--      - Every 15 minutes via pg_cron or Vercel Cron
--      - Immediately after pipeline runs (already in RUN_LOCAL.ps1)
-- ─────────────────────────────────────────────────────────────────────────────

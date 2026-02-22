-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Health Check Monitoring Endpoint
-- Purpose:   api_health_check() RPC for /api/health and admin monitoring dashboard
-- Issue:     #119 — Monitoring & Alerting
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- api_health_check() — Returns JSONB with connectivity, MV staleness,
-- row counts, and overall status. SECURITY DEFINER, service_role only.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_health_check()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_mv_ingredient_rows   bigint;
    v_mv_ingredient_source bigint;
    v_mv_confidence_rows   bigint;
    v_mv_confidence_source bigint;
    v_product_count        bigint;
    v_product_ceiling      bigint := 15000;
    v_utilization_pct      numeric;
    v_mv_stale             boolean;
    v_status               text;
    v_result               jsonb;
BEGIN
    -- ── MV staleness checks ──────────────────────────────────────────────
    SELECT COUNT(*) INTO v_mv_ingredient_rows FROM mv_ingredient_frequency;
    SELECT COUNT(DISTINCT ingredient_id) INTO v_mv_ingredient_source FROM product_ingredient;

    SELECT COUNT(*) INTO v_mv_confidence_rows FROM v_product_confidence;
    SELECT COUNT(*) INTO v_mv_confidence_source FROM products WHERE is_deprecated IS NOT TRUE;

    v_mv_stale := (v_mv_ingredient_rows != v_mv_ingredient_source)
               OR (v_mv_confidence_rows != v_mv_confidence_source);

    -- ── Row count / capacity ─────────────────────────────────────────────
    SELECT COUNT(*) INTO v_product_count FROM products WHERE is_deprecated IS NOT TRUE;
    v_utilization_pct := ROUND(100.0 * v_product_count / v_product_ceiling, 1);

    -- ── Overall status ───────────────────────────────────────────────────
    IF v_product_count = 0 THEN
        v_status := 'unhealthy';
    ELSIF v_utilization_pct > 95 OR v_mv_stale THEN
        v_status := 'degraded';
    ELSIF v_utilization_pct > 80 THEN
        v_status := 'degraded';
    ELSE
        v_status := 'healthy';
    END IF;

    -- ── Build response (NO secrets, NO connection strings) ───────────────
    v_result := jsonb_build_object(
        'status', v_status,
        'checks', jsonb_build_object(
            'connectivity', true,
            'mv_staleness', jsonb_build_object(
                'mv_ingredient_frequency', jsonb_build_object(
                    'mv_rows', v_mv_ingredient_rows,
                    'source_rows', v_mv_ingredient_source,
                    'stale', v_mv_ingredient_rows != v_mv_ingredient_source
                ),
                'v_product_confidence', jsonb_build_object(
                    'mv_rows', v_mv_confidence_rows,
                    'source_rows', v_mv_confidence_source,
                    'stale', v_mv_confidence_rows != v_mv_confidence_source
                )
            ),
            'row_counts', jsonb_build_object(
                'products', v_product_count,
                'ceiling', v_product_ceiling,
                'utilization_pct', v_utilization_pct
            )
        ),
        'timestamp', to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );

    RETURN v_result;
END;
$fn$;

COMMENT ON FUNCTION api_health_check IS
    'Health check endpoint for monitoring. Returns JSONB with connectivity, '
    'MV staleness, and row count metrics. SECURITY DEFINER — service_role only. '
    'Response contains NO secrets, connection strings, or infrastructure details.';

-- ── Security: service_role only ──────────────────────────────────────────────
REVOKE ALL ON FUNCTION api_health_check() FROM PUBLIC;
REVOKE ALL ON FUNCTION api_health_check() FROM anon;
REVOKE ALL ON FUNCTION api_health_check() FROM authenticated;
GRANT EXECUTE ON FUNCTION api_health_check() TO service_role;

COMMIT;

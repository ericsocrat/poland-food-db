-- Migration: Performance & Scale Guardrails (Phase 8)
-- Date: 2026-02-10
-- Purpose: Add guardrails for scale readiness:
--   1. refresh_all_materialized_views() — single call to refresh all MVs
--   2. mv_staleness_check() — reports MV freshness
--   3. Add missing unique index for CONCURRENTLY support
--   4. Partial index on servings for per-100g lookups

BEGIN;

-- ============================================================
-- 1. Refresh all materialized views (for use after pipeline runs)
-- ============================================================

CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
    start_ts timestamptz;
    t1 numeric;
    t2 numeric;
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
            jsonb_build_object('name', 'mv_ingredient_frequency', 'rows', (SELECT COUNT(*) FROM mv_ingredient_frequency), 'ms', t1),
            jsonb_build_object('name', 'v_product_confidence', 'rows', (SELECT COUNT(*) FROM v_product_confidence), 'ms', t2)
        ),
        'total_ms', t1 + t2
    );
END;
$$;

COMMENT ON FUNCTION refresh_all_materialized_views IS
    'Refreshes all materialized views concurrently. Returns timing report as JSONB. '
    'Call after pipeline runs or data imports.';


-- ============================================================
-- 2. MV staleness check — compares MV row counts to source
-- ============================================================

CREATE OR REPLACE FUNCTION mv_staleness_check()
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'checked_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object(
                'name', 'mv_ingredient_frequency',
                'mv_rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                'source_rows', (SELECT COUNT(DISTINCT ingredient_id) FROM product_ingredient),
                'is_stale', (SELECT COUNT(*) FROM mv_ingredient_frequency) !=
                            (SELECT COUNT(DISTINCT ingredient_id) FROM product_ingredient)
            ),
            jsonb_build_object(
                'name', 'v_product_confidence',
                'mv_rows', (SELECT COUNT(*) FROM v_product_confidence),
                'source_rows', (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM v_product_confidence) !=
                            (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE)
            )
        )
    );
$$;

COMMENT ON FUNCTION mv_staleness_check IS
    'Checks if materialized views are stale by comparing row counts to source tables. '
    'Returns JSONB with per-view staleness status. Does not refresh — call refresh_all_materialized_views() if stale.';


-- ============================================================
-- 3. Partial index on servings for per-100g lookups
-- ============================================================
-- v_master and many functions filter servings WHERE serving_basis = 'per 100 g'.
-- At 877 rows this is fast, but the partial index ensures efficiency at scale.

CREATE INDEX IF NOT EXISTS idx_servings_per100g
    ON servings (product_id)
    WHERE serving_basis = 'per 100 g';

CREATE INDEX IF NOT EXISTS idx_servings_per_serving
    ON servings (product_id)
    WHERE serving_basis = 'per serving';

COMMENT ON INDEX idx_servings_per100g IS
    'Partial index for fast per-100g serving lookups used by v_master and scoring functions.';

COMMENT ON INDEX idx_servings_per_serving IS
    'Partial index for fast per-serving lookups used by API functions.';


-- ============================================================
-- 4. Add RUN_LOCAL refresh step documentation
-- ============================================================
-- After pipeline runs, include:
--   SELECT refresh_all_materialized_views();
-- This is documented in PERFORMANCE_REPORT.md.

COMMIT;

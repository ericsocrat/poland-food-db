-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Monitoring & Health Check
-- Validates the api_health_check() function returns correct structure and
-- meaningful data. All checks are read-only.
-- Issue: #119
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  api_health_check() returns valid JSONB
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT pg_typeof(api_health_check()) = 'jsonb'::regtype
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#1  api_health_check returns valid JSONB";

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  Status is one of healthy / degraded / unhealthy
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT api_health_check()->>'status' IN ('healthy', 'degraded', 'unhealthy')
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#2  status is valid enum value";

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  All expected top-level keys present (status, checks, timestamp)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT api_health_check() ?& ARRAY['status', 'checks', 'timestamp']
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#3  top-level keys present (status, checks, timestamp)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  MV staleness fields are present with non-negative row counts
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT
            (api_health_check()->'checks'->'mv_staleness'->'mv_ingredient_frequency'->>'mv_rows')::int >= 0
            AND
            (api_health_check()->'checks'->'mv_staleness'->'mv_ingredient_frequency'->>'source_rows')::int >= 0
            AND
            (api_health_check()->'checks'->'mv_staleness'->'v_product_confidence'->>'mv_rows')::int >= 0
            AND
            (api_health_check()->'checks'->'mv_staleness'->'v_product_confidence'->>'source_rows')::int >= 0
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#4  MV staleness ages are non-negative integers";

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  Row count matches actual active product count
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT
            (api_health_check()->'checks'->'row_counts'->>'products')::bigint
            = (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE)
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#5  row count matches SELECT count(*) FROM products";

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  Connectivity flag is true (we're connected if running this)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT (api_health_check()->'checks'->>'connectivity')::boolean = true
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#6  connectivity flag is true";

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  Timestamp is a valid ISO-8601 string
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT (api_health_check()->>'timestamp')::timestamptz IS NOT NULL
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#7  timestamp is valid ISO-8601";

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  retention_policies table has at least one enabled policy
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT COUNT(*) FROM retention_policies WHERE is_enabled = true
    ) > 0
    THEN 'PASS' ELSE 'FAIL' END AS "#8  retention_policies has enabled policies";

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  execute_retention_cleanup() returns valid JSONB on dry-run
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT (execute_retention_cleanup(true))->>'dry_run' = 'true'
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#9  execute_retention_cleanup dry-run returns valid JSONB";

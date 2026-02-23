-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Materialized View Refresh Cost
-- Measures refresh times for all materialized views and validates they
-- complete within acceptable thresholds.
-- Issue: #185
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  refresh_all_materialized_views() completes successfully
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. refresh_all_materialized_views succeeds' AS check_name,
       CASE WHEN (refresh_all_materialized_views() IS NOT NULL)
       THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  Refresh returns timing data for all views
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. refresh returns timing for all views' AS check_name,
       CASE WHEN (
           SELECT jsonb_array_length(refresh_all_materialized_views()->'views') >= 2
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  Individual MV refresh times are under 10 seconds
--     At current scale (~2,500 products), refreshes should be < 1s.
--     10s threshold is the alarm level for growth monitoring.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. all MV refreshes under 10s' AS check_name,
       (SELECT COUNT(*)
        FROM jsonb_array_elements(refresh_all_materialized_views()->'views') v
        WHERE (v->>'ms')::FLOAT > 10000
       ) AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  Total refresh time is under 30 seconds
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. total refresh under 30s' AS check_name,
       CASE WHEN (
           SELECT (refresh_all_materialized_views()->>'total_ms')::FLOAT < 30000
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  All materialized views exist and are accessible
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. all expected MVs exist' AS check_name,
       CASE WHEN (
           SELECT COUNT(*) >= 3
           FROM pg_class c
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE c.relkind = 'm'
             AND n.nspname = 'public'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  All MVs have unique indexes (required for CONCURRENTLY)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. all MVs have unique indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT c.relname AS mv_name
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relkind = 'm'
      AND n.nspname = 'public'
    EXCEPT
    SELECT DISTINCT i.tablename
    FROM pg_indexes i
    WHERE i.schemaname = 'public'
      AND i.indexdef ILIKE '%unique%'
      AND i.tablename IN (
          SELECT c2.relname FROM pg_class c2
          JOIN pg_namespace n2 ON c2.relnamespace = n2.oid
          WHERE c2.relkind = 'm' AND n2.nspname = 'public'
      )
) mvs_without_unique_idx;

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  MV row counts are consistent with source data
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. MVs are not stale after refresh' AS check_name,
       (SELECT COUNT(*)
        FROM jsonb_array_elements(mv_staleness_check()->'views') v
        WHERE (v->>'is_stale')::boolean = true
       ) AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  mv_ingredient_frequency refresh time is under 5s
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. ingredient freq MV refresh under 5s' AS check_name,
       CASE WHEN (
           SELECT (v->>'ms')::FLOAT < 5000
           FROM jsonb_array_elements(refresh_all_materialized_views()->'views') v
           WHERE v->>'name' = 'mv_ingredient_frequency'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  v_product_confidence refresh time is under 5s
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. confidence MV refresh under 5s' AS check_name,
       CASE WHEN (
           SELECT (v->>'ms')::FLOAT < 5000
           FROM jsonb_array_elements(refresh_all_materialized_views()->'views') v
           WHERE v->>'name' = 'v_product_confidence'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  mv_staleness_check function returns valid JSONB
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. mv_staleness_check returns valid JSONB' AS check_name,
       CASE WHEN (
           SELECT mv_staleness_check() IS NOT NULL
              AND mv_staleness_check() ? 'checked_at'
              AND mv_staleness_check() ? 'views'
       ) THEN 0 ELSE 1 END AS violations;

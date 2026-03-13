-- Migration: scoring band distribution materialized view
-- Purpose: Provides fast, pre-aggregated scoring band distribution metrics
--          per country and category for 10K-scale monitoring
-- Rollback: DROP MATERIALIZED VIEW IF EXISTS mv_scoring_distribution;
-- Issue: #865

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Materialized view: mv_scoring_distribution
-- ═══════════════════════════════════════════════════════════════════════════

CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_scoring_distribution AS
WITH band_assignment AS (
  SELECT
    p.product_id,
    p.country,
    p.category,
    p.unhealthiness_score,
    CASE
      WHEN p.unhealthiness_score BETWEEN  1 AND 20 THEN 'Green'
      WHEN p.unhealthiness_score BETWEEN 21 AND 40 THEN 'Yellow'
      WHEN p.unhealthiness_score BETWEEN 41 AND 60 THEN 'Orange'
      WHEN p.unhealthiness_score BETWEEN 61 AND 80 THEN 'Red'
      WHEN p.unhealthiness_score BETWEEN 81 AND 100 THEN 'Dark Red'
    END AS band
  FROM public.products p
  WHERE p.is_deprecated IS NOT TRUE
    AND p.unhealthiness_score IS NOT NULL
)
SELECT
  country,
  category,
  band,
  COUNT(*)                     AS product_count,
  ROUND(COUNT(*)::numeric
        / SUM(COUNT(*)) OVER (PARTITION BY country, category) * 100, 1)
                               AS pct_of_category,
  ROUND(AVG(unhealthiness_score), 1)   AS avg_score,
  MIN(unhealthiness_score)             AS min_score,
  MAX(unhealthiness_score)             AS max_score,
  ROUND(STDDEV_POP(unhealthiness_score)::numeric, 1) AS stddev_score
FROM band_assignment
GROUP BY country, category, band
ORDER BY country, category,
  CASE band
    WHEN 'Green'    THEN 1
    WHEN 'Yellow'   THEN 2
    WHEN 'Orange'   THEN 3
    WHEN 'Red'      THEN 4
    WHEN 'Dark Red' THEN 5
  END;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_scoring_dist_country_cat_band
  ON mv_scoring_distribution (country, category, band);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Add to refresh_all_materialized_views()
-- ═══════════════════════════════════════════════════════════════════════════

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
    t4        numeric;
    t5        numeric;
    r1        bigint;
    r2        bigint;
    r3        bigint;
    r4        bigint;
    r5        bigint;
    v_trigger text;
BEGIN
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

    -- Refresh v_data_coverage_summary
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_data_coverage_summary;
    t4 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r4 := (SELECT COUNT(*) FROM v_data_coverage_summary);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('v_data_coverage_summary', t4::integer, r4, v_trigger);

    -- Refresh mv_scoring_distribution
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_scoring_distribution;
    t5 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r5 := (SELECT COUNT(*) FROM mv_scoring_distribution);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('mv_scoring_distribution', t5::integer, r5, v_trigger);

    RETURN jsonb_build_object(
        'refreshed_at', NOW(),
        'triggered_by', v_trigger,
        'views', jsonb_build_array(
            jsonb_build_object('name', 'mv_ingredient_frequency',
                               'rows', r1, 'ms', t1),
            jsonb_build_object('name', 'v_product_confidence',
                               'rows', r2, 'ms', t2),
            jsonb_build_object('name', 'mv_product_similarity',
                               'rows', r3, 'ms', t3),
            jsonb_build_object('name', 'v_data_coverage_summary',
                               'rows', r4, 'ms', t4),
            jsonb_build_object('name', 'mv_scoring_distribution',
                               'rows', r5, 'ms', t5)
        ),
        'total_ms', t1 + t2 + t3 + t4 + t5
    );
END;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Add to mv_staleness_check()
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.mv_staleness_check()
RETURNS jsonb
LANGUAGE sql
STABLE
AS $function$
    SELECT jsonb_build_object(
        'checked_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object(
                'name', 'mv_ingredient_frequency',
                'mv_rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                'source_rows', (SELECT COUNT(DISTINCT pi.ingredient_id)
                                FROM product_ingredient pi
                                JOIN products p ON p.product_id = pi.product_id
                                WHERE p.is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM mv_ingredient_frequency) !=
                            (SELECT COUNT(DISTINCT pi.ingredient_id)
                             FROM product_ingredient pi
                             JOIN products p ON p.product_id = pi.product_id
                             WHERE p.is_deprecated IS NOT TRUE)
            ),
            jsonb_build_object(
                'name', 'v_product_confidence',
                'mv_rows', (SELECT COUNT(*) FROM v_product_confidence),
                'source_rows', (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM v_product_confidence) !=
                            (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE)
            ),
            jsonb_build_object(
                'name', 'v_data_coverage_summary',
                'mv_rows', (SELECT COUNT(*) FROM v_data_coverage_summary),
                'source_rows', (SELECT COUNT(DISTINCT (country, category))
                                FROM products WHERE is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM v_data_coverage_summary) !=
                            (SELECT COUNT(DISTINCT (country, category))
                             FROM products WHERE is_deprecated IS NOT TRUE)
            ),
            jsonb_build_object(
                'name', 'mv_scoring_distribution',
                'mv_rows', (SELECT COUNT(*) FROM mv_scoring_distribution),
                'source_rows', (SELECT COUNT(DISTINCT (country, category, 
                    CASE
                      WHEN unhealthiness_score BETWEEN  1 AND 20 THEN 'Green'
                      WHEN unhealthiness_score BETWEEN 21 AND 40 THEN 'Yellow'
                      WHEN unhealthiness_score BETWEEN 41 AND 60 THEN 'Orange'
                      WHEN unhealthiness_score BETWEEN 61 AND 80 THEN 'Red'
                      WHEN unhealthiness_score BETWEEN 81 AND 100 THEN 'Dark Red'
                    END))
                                FROM products
                                WHERE is_deprecated IS NOT TRUE
                                  AND unhealthiness_score IS NOT NULL),
                'is_stale', (SELECT COUNT(*) FROM mv_scoring_distribution) !=
                            (SELECT COUNT(DISTINCT (country, category,
                    CASE
                      WHEN unhealthiness_score BETWEEN  1 AND 20 THEN 'Green'
                      WHEN unhealthiness_score BETWEEN 21 AND 40 THEN 'Yellow'
                      WHEN unhealthiness_score BETWEEN 41 AND 60 THEN 'Orange'
                      WHEN unhealthiness_score BETWEEN 61 AND 80 THEN 'Red'
                      WHEN unhealthiness_score BETWEEN 81 AND 100 THEN 'Dark Red'
                    END))
                             FROM products
                             WHERE is_deprecated IS NOT TRUE
                               AND unhealthiness_score IS NOT NULL)
            )
        )
    );
$function$;

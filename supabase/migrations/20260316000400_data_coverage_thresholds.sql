-- Migration: Data coverage summary MV + refresh/staleness updates
-- Issue: #717 — Automated data coverage thresholds and regression detection
-- Rollback: DROP MATERIALIZED VIEW IF EXISTS v_data_coverage_summary;
--           Then re-create refresh_all_materialized_views() and mv_staleness_check()
--           without the v_data_coverage_summary blocks (see previous versions).

-- ═══════════════════════════════════════════════════════════════════════════
-- Phase 1: Create v_data_coverage_summary materialized view
-- ═══════════════════════════════════════════════════════════════════════════

CREATE MATERIALIZED VIEW IF NOT EXISTS v_data_coverage_summary AS
SELECT
    p.country,
    p.category,
    COUNT(*)::integer AS total_products,
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
    ) THEN 1 END)::integer AS with_ingredients,
    ROUND(100.0 * COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
    ) THEN 1 END) / COUNT(*), 1) AS ingredient_pct,
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = p.product_id
    ) THEN 1 END)::integer AS with_allergens,
    ROUND(100.0 * COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = p.product_id
    ) THEN 1 END) / COUNT(*), 1) AS allergen_pct,
    COUNT(CASE WHEN p.ean IS NOT NULL THEN 1 END)::integer AS with_ean,
    ROUND(100.0 * COUNT(CASE WHEN p.ean IS NOT NULL THEN 1 END) / COUNT(*), 1) AS ean_pct,
    ROUND(AVG(p.data_completeness_pct), 1) AS avg_completeness_pct
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country, p.category;

-- Unique index required for REFRESH MATERIALIZED VIEW CONCURRENTLY
CREATE UNIQUE INDEX IF NOT EXISTS idx_data_coverage_summary_uniq
    ON v_data_coverage_summary (country, category);

-- ═══════════════════════════════════════════════════════════════════════════
-- Phase 2: Update refresh_all_materialized_views() to include new MV
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
    r1        bigint;
    r2        bigint;
    r3        bigint;
    r4        bigint;
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

    -- Refresh v_data_coverage_summary
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_data_coverage_summary;
    t4 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));
    r4 := (SELECT COUNT(*) FROM v_data_coverage_summary);
    INSERT INTO mv_refresh_log (mv_name, duration_ms, row_count, triggered_by)
    VALUES ('v_data_coverage_summary', t4::integer, r4, v_trigger);

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
                               'ms',   t3),
            jsonb_build_object('name', 'v_data_coverage_summary',
                               'rows', r4,
                               'ms',   t4)
        ),
        'total_ms', t1 + t2 + t3 + t4
    );
END;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Phase 3: Update mv_staleness_check() to include new MV
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
            )
        )
    );
$function$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Phase 4: Grant read access (anon + authenticated can read the MV)
-- ═══════════════════════════════════════════════════════════════════════════

GRANT SELECT ON v_data_coverage_summary TO anon, authenticated;

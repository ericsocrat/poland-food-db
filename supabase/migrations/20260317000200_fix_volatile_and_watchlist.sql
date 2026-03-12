-- Migration: Fix 6 STABLE functions that contain rate-limit INSERTs + watchlist SQL alias bug
-- Root cause: migration 20260315000400_api_rate_limiting.sql dynamically injected
-- check_api_rate_limit() (VOLATILE, does INSERT) into these functions without
-- changing their volatility from STABLE to VOLATILE. PostgREST routes STABLE
-- functions to read-only transactions, causing INSERT to fail with error 25006.
-- Additionally, api_get_watchlist has an SQL alias bug: ORDER BY w.created_at
-- references alias "w" from an inner subquery that is out of scope at the outer level.
--
-- Rollback: ALTER FUNCTION ... STABLE for the 6 functions below;
--           re-CREATE api_get_watchlist with the old ORDER BY clause.
-- Idempotency: ALTER FUNCTION and CREATE OR REPLACE are idempotent.

-- ═══════════════════════════════════════════════════════════════════
-- FIX 1: Change 6 STABLE functions with rate-limit writes to VOLATILE
-- ═══════════════════════════════════════════════════════════════════

ALTER FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean) VOLATILE;

ALTER FUNCTION public.api_search_autocomplete(text, integer) VOLATILE;

ALTER FUNCTION public.api_product_detail_by_ean(text, text) VOLATILE;

ALTER FUNCTION public.api_get_filter_options(text) VOLATILE;

ALTER FUNCTION public.api_better_alternatives(bigint, boolean, integer, text, text[], boolean, boolean, boolean) VOLATILE;

ALTER FUNCTION public.api_better_alternatives_v2(bigint, boolean, integer, text, text[], boolean, boolean, boolean, boolean, uuid, boolean, integer) VOLATILE;


-- ═══════════════════════════════════════════════════════════════════
-- FIX 2: Fix api_get_watchlist SQL alias bug
--   Bug: ORDER BY w.created_at DESC — "w" only exists inside inner subquery
--   Fix: ORDER BY sub.watched_since DESC — use outer alias "sub" with renamed column
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION api_get_watchlist(
    p_page       int DEFAULT 1,
    p_page_size  int DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_offset  int;
    v_total   int;
    v_items   jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
    END IF;

    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Total count
    SELECT count(*) INTO v_total
    FROM user_watched_products
    WHERE user_id = v_user_id;

    -- Paginated items with product details + latest history
    SELECT COALESCE(jsonb_agg(item ORDER BY sub.watched_since DESC), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            w.watch_id,
            w.product_id,
            w.alert_threshold,
            w.created_at AS watched_since,
            p.product_name,
            p.brand,
            p.category,
            p.unhealthiness_score AS current_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END AS score_band,
            p.nutri_score_label,
            p.nova_classification AS nova_group,
            -- Latest history delta
            (
                SELECT h.score_delta
                FROM product_score_history h
                WHERE h.product_id = w.product_id
                  AND h.score_delta IS NOT NULL
                  AND h.score_delta != 0
                ORDER BY h.recorded_at DESC
                LIMIT 1
            ) AS last_delta,
            -- Trend from last 3 changes
            (
                SELECT
                    CASE
                        WHEN count(*) < 2 THEN 'stable'
                        WHEN every(rh.score_delta > 0) THEN 'worsening'
                        WHEN every(rh.score_delta < 0) THEN 'improving'
                        ELSE 'stable'
                    END
                FROM (
                    SELECT score_delta
                    FROM product_score_history
                    WHERE product_id = w.product_id
                      AND score_delta IS NOT NULL
                      AND score_delta != 0
                    ORDER BY recorded_at DESC
                    LIMIT 3
                ) rh
            ) AS trend,
            -- Reformulation detected
            EXISTS(
                SELECT 1 FROM product_score_history
                WHERE product_id = w.product_id
                  AND ABS(score_delta) >= 10
            ) AS reformulation_detected,
            -- Mini sparkline: last 12 scores
            (
                SELECT jsonb_agg(
                    jsonb_build_object('date', sh.recorded_at, 'score', sh.unhealthiness_score)
                    ORDER BY sh.recorded_at ASC
                )
                FROM (
                    SELECT recorded_at, unhealthiness_score
                    FROM product_score_history
                    WHERE product_id = w.product_id
                    ORDER BY recorded_at DESC
                    LIMIT 12
                ) sh
            ) AS sparkline
        FROM user_watched_products w
        JOIN products p ON p.product_id = w.product_id
        WHERE w.user_id = v_user_id
        ORDER BY w.created_at DESC
        OFFSET v_offset
        LIMIT p_page_size
    ) sub
    CROSS JOIN LATERAL (
        SELECT jsonb_build_object(
            'watch_id',               sub.watch_id,
            'product_id',             sub.product_id,
            'alert_threshold',        sub.alert_threshold,
            'watched_since',          sub.watched_since,
            'product_name',           sub.product_name,
            'brand',                  sub.brand,
            'category',              sub.category,
            'current_score',          sub.current_score,
            'score_band',             sub.score_band,
            'nutri_score',            sub.nutri_score_label,
            'nova_group',             sub.nova_group,
            'last_delta',             sub.last_delta,
            'trend',                  sub.trend,
            'reformulation_detected', sub.reformulation_detected,
            'sparkline',              COALESCE(sub.sparkline, '[]'::jsonb)
        ) AS item
    ) lat;

    RETURN jsonb_build_object(
        'success',    true,
        'items',      v_items,
        'total',      v_total,
        'page',       GREATEST(p_page, 1),
        'page_size',  p_page_size,
        'total_pages', CEIL(v_total::numeric / p_page_size)
    );
END;
$$;

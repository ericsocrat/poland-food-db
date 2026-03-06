-- Migration: Fix CASE type mismatch in api_get_score_history
-- Issue: #620 (discovered during pgTAP test creation)
-- Bug: CASE expression mixed text (->> returns text) with numeric (v_current),
--       causing "CASE types numeric and text cannot be matched" when product has >1 history entry
-- Fix: Explicit ::numeric cast on the ->> branch
-- Rollback: This replaces the function in-place; rolling back requires re-deploying the original
--           CREATE OR REPLACE from 20260220000300_score_history_watchlist.sql (which has the bug)

CREATE OR REPLACE FUNCTION public.api_get_score_history(
    p_product_id bigint,
    p_limit      int DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_history jsonb;
    v_trend   text;
    v_current numeric;
    v_previous numeric;
    v_delta   numeric;
    v_reformulated boolean := false;
BEGIN
    -- Get history entries
    SELECT jsonb_agg(
        jsonb_build_object(
            'date',              h.recorded_at,
            'score',             h.unhealthiness_score,
            'nutri_score',       h.nutri_score_label,
            'nova_group',        h.nova_group,
            'completeness_pct',  h.data_completeness_pct,
            'delta',             h.score_delta,
            'source',            h.trigger_source,
            'reason',            h.change_reason
        ) ORDER BY h.recorded_at DESC
    )
    INTO v_history
    FROM (
        SELECT * FROM product_score_history
        WHERE product_id = p_product_id
        ORDER BY recorded_at DESC
        LIMIT p_limit
    ) h;

    IF v_history IS NULL THEN
        RETURN jsonb_build_object(
            'product_id', p_product_id,
            'trend', 'stable',
            'current_score', NULL,
            'previous_score', NULL,
            'delta', 0,
            'reformulation_detected', false,
            'history', '[]'::jsonb,
            'total_snapshots', 0
        );
    END IF;

    -- Current and previous scores (explicit casts: ->> returns text)
    v_current  := ((v_history->0)->>'score')::numeric;
    v_previous := CASE
        WHEN jsonb_array_length(v_history) > 1
        THEN ((v_history->1)->>'score')::numeric
        ELSE v_current
    END;
    v_delta := v_current - v_previous;

    -- Trend: compare last 3 snapshots
    SELECT
        CASE
            WHEN count(*) < 2 THEN 'stable'
            WHEN every(score_delta > 0) THEN 'worsening'
            WHEN every(score_delta < 0) THEN 'improving'
            ELSE 'stable'
        END
    INTO v_trend
    FROM (
        SELECT score_delta
        FROM product_score_history
        WHERE product_id = p_product_id
          AND score_delta IS NOT NULL
          AND score_delta != 0
        ORDER BY recorded_at DESC
        LIMIT 3
    ) recent;

    -- Reformulation detection: any single delta >= 10
    SELECT EXISTS(
        SELECT 1 FROM product_score_history
        WHERE product_id = p_product_id
          AND ABS(score_delta) >= 10
    ) INTO v_reformulated;

    RETURN jsonb_build_object(
        'product_id',             p_product_id,
        'trend',                  v_trend,
        'current_score',          v_current,
        'previous_score',         v_previous,
        'delta',                  v_delta,
        'reformulation_detected', v_reformulated,
        'history',                v_history,
        'total_snapshots',        jsonb_array_length(v_history)
    );
END;
$$;

-- 20260220000300_score_history_watchlist.sql
-- Issue #38: Product Score History, Watchlist & Reformulation Alerts
--
-- Phase 1: product_score_history table + snapshot trigger + backfill
-- Phase 2: user_watched_products table + watch/unwatch/list RPCs + score history RPC
-- Rollback: DROP TABLE product_score_history CASCADE; DROP TABLE user_watched_products CASCADE;

SET search_path = public;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. PRODUCT SCORE HISTORY TABLE
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS product_score_history (
    history_id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id          bigint NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    recorded_at         date   NOT NULL DEFAULT CURRENT_DATE,
    unhealthiness_score numeric NOT NULL CHECK (unhealthiness_score >= 1 AND unhealthiness_score <= 100),
    nutri_score_label   text,
    nova_group          text,
    data_completeness_pct numeric,
    trigger_source      text   NOT NULL DEFAULT 'pipeline',
    score_delta         numeric,
    change_reason       text,
    UNIQUE (product_id, recorded_at)
);

ALTER TABLE product_score_history ENABLE ROW LEVEL SECURITY;

-- Score history is public read (no user data)
CREATE POLICY "score_history_anon_read" ON product_score_history
    FOR SELECT TO anon, authenticated
    USING (true);

-- Only service_role inserts (via trigger or backfill)
CREATE POLICY "score_history_service_insert" ON product_score_history
    FOR INSERT TO postgres
    WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_score_history_product_date
    ON product_score_history (product_id, recorded_at DESC);

CREATE INDEX IF NOT EXISTS idx_score_history_significant_delta
    ON product_score_history (product_id)
    WHERE ABS(score_delta) >= 5;


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. SNAPSHOT TRIGGER — fires on products.unhealthiness_score changes
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION record_score_change()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.unhealthiness_score IS DISTINCT FROM NEW.unhealthiness_score
       AND NEW.unhealthiness_score IS NOT NULL
    THEN
        INSERT INTO product_score_history (
            product_id, unhealthiness_score, nutri_score_label,
            nova_group, data_completeness_pct, score_delta, trigger_source
        ) VALUES (
            NEW.product_id,
            NEW.unhealthiness_score,
            NEW.nutri_score_label,
            NEW.nova_classification,
            NEW.data_completeness_pct,
            NEW.unhealthiness_score - COALESCE(OLD.unhealthiness_score, NEW.unhealthiness_score),
            'pipeline'
        )
        ON CONFLICT (product_id, recorded_at) DO UPDATE SET
            unhealthiness_score   = EXCLUDED.unhealthiness_score,
            nutri_score_label     = EXCLUDED.nutri_score_label,
            nova_group            = EXCLUDED.nova_group,
            data_completeness_pct = EXCLUDED.data_completeness_pct,
            score_delta           = EXCLUDED.score_delta;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_record_score_change ON products;
CREATE TRIGGER trg_record_score_change
    AFTER UPDATE OF unhealthiness_score ON products
    FOR EACH ROW
    EXECUTE FUNCTION record_score_change();


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. BACKFILL — seed current scores as baseline
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO product_score_history (
    product_id, unhealthiness_score, nutri_score_label,
    nova_group, data_completeness_pct, score_delta, trigger_source
)
SELECT
    product_id,
    unhealthiness_score,
    nutri_score_label,
    nova_classification,
    data_completeness_pct,
    0,
    'backfill'
FROM products
WHERE is_deprecated IS NOT TRUE
  AND unhealthiness_score IS NOT NULL
ON CONFLICT DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. USER WATCHED PRODUCTS TABLE
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS user_watched_products (
    watch_id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id           uuid   NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id        bigint NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    alert_threshold   smallint NOT NULL DEFAULT 5 CHECK (alert_threshold >= 1 AND alert_threshold <= 50),
    notify_on         text[] NOT NULL DEFAULT '{score_change}',
    created_at        timestamptz NOT NULL DEFAULT now(),
    last_alerted_at   timestamptz,
    UNIQUE (user_id, product_id)
);

ALTER TABLE user_watched_products ENABLE ROW LEVEL SECURITY;

-- Users can CRUD only their own watchlist entries
CREATE POLICY "watchlist_user_select" ON user_watched_products
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "watchlist_user_insert" ON user_watched_products
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "watchlist_user_update" ON user_watched_products
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "watchlist_user_delete" ON user_watched_products
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_watched_products_user
    ON user_watched_products (user_id);

CREATE INDEX IF NOT EXISTS idx_watched_products_product
    ON user_watched_products (product_id);


-- ═══════════════════════════════════════════════════════════════════════════
-- 5. API FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- 5a) api_get_score_history — public, returns score history for a product
CREATE OR REPLACE FUNCTION api_get_score_history(
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

    -- Current and previous scores
    v_current  := (v_history->0)->>'score';
    v_previous := CASE
        WHEN jsonb_array_length(v_history) > 1
        THEN (v_history->1)->>'score'
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

GRANT EXECUTE ON FUNCTION api_get_score_history(bigint, int) TO anon, authenticated;


-- 5b) api_watch_product — add product to user's watchlist
CREATE OR REPLACE FUNCTION api_watch_product(
    p_product_id     bigint,
    p_threshold      smallint DEFAULT 5
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_result  jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
    END IF;

    INSERT INTO user_watched_products (user_id, product_id, alert_threshold)
    VALUES (v_user_id, p_product_id, p_threshold)
    ON CONFLICT (user_id, product_id) DO UPDATE SET
        alert_threshold = EXCLUDED.alert_threshold;

    RETURN jsonb_build_object(
        'success',    true,
        'product_id', p_product_id,
        'threshold',  p_threshold,
        'watching',   true
    );
END;
$$;

GRANT EXECUTE ON FUNCTION api_watch_product(bigint, smallint) TO authenticated;
REVOKE EXECUTE ON FUNCTION api_watch_product(bigint, smallint) FROM PUBLIC, anon;


-- 5c) api_unwatch_product — remove product from user's watchlist
CREATE OR REPLACE FUNCTION api_unwatch_product(
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_deleted boolean;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
    END IF;

    DELETE FROM user_watched_products
    WHERE user_id = v_user_id AND product_id = p_product_id;

    v_deleted := FOUND;

    RETURN jsonb_build_object(
        'success',    true,
        'product_id', p_product_id,
        'watching',   false,
        'was_watching', v_deleted
    );
END;
$$;

GRANT EXECUTE ON FUNCTION api_unwatch_product(bigint) TO authenticated;
REVOKE EXECUTE ON FUNCTION api_unwatch_product(bigint) FROM PUBLIC, anon;


-- 5d) api_get_watchlist — paginated list of watched products with latest score + trend
CREATE OR REPLACE FUNCTION api_get_watchlist(
    p_page       int DEFAULT 1,
    p_page_size  int DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql
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
    SELECT COALESCE(jsonb_agg(item ORDER BY w.created_at DESC), '[]'::jsonb)
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

GRANT EXECUTE ON FUNCTION api_get_watchlist(int, int) TO authenticated;
REVOKE EXECUTE ON FUNCTION api_get_watchlist(int, int) FROM PUBLIC, anon;


-- 5e) api_is_watching — check if current user watches a specific product
CREATE OR REPLACE FUNCTION api_is_watching(
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_watching boolean;
    v_threshold smallint;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('watching', false);
    END IF;

    SELECT true, alert_threshold
    INTO v_watching, v_threshold
    FROM user_watched_products
    WHERE user_id = v_user_id AND product_id = p_product_id;

    RETURN jsonb_build_object(
        'watching',   COALESCE(v_watching, false),
        'threshold',  v_threshold
    );
END;
$$;

GRANT EXECUTE ON FUNCTION api_is_watching(bigint) TO authenticated;
REVOKE EXECUTE ON FUNCTION api_is_watching(bigint) FROM PUBLIC, anon;

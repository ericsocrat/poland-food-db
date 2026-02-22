-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: push_notifications
-- Issue:     #143 — Push Notifications for Watchlist Score Changes
-- Purpose:   Add push subscription storage, notification queue, and API
--            functions for Web Push notification management.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Push Subscriptions Table ────────────────────────────────────────────
-- Stores Web Push API subscriptions (one per user per browser/device).

CREATE TABLE IF NOT EXISTS push_subscriptions (
    id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    endpoint   text NOT NULL,
    keys       jsonb NOT NULL,  -- { p256dh, auth }
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, endpoint)
);

ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only manage their own subscriptions
CREATE POLICY "push_sub_select" ON push_subscriptions
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "push_sub_insert" ON push_subscriptions
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "push_sub_delete" ON push_subscriptions
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_push_subscriptions_user
    ON push_subscriptions (user_id);


-- ─── 2. Notification Queue Table ────────────────────────────────────────────
-- Queued push notifications awaiting delivery by Edge Function.

CREATE TABLE IF NOT EXISTS notification_queue (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id   bigint NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    product_name text NOT NULL,
    old_score    numeric NOT NULL,
    new_score    numeric NOT NULL,
    delta        numeric NOT NULL,
    direction    text NOT NULL CHECK (direction IN ('improved', 'worsened')),
    created_at   timestamptz NOT NULL DEFAULT now(),
    sent_at      timestamptz,
    status       text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'no_subscription'))
);

ALTER TABLE notification_queue ENABLE ROW LEVEL SECURITY;

-- Users can read their own notification history
CREATE POLICY "notif_queue_select" ON notification_queue
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

-- Only postgres / service_role can insert/update (from triggers / edge functions)
CREATE POLICY "notif_queue_service_insert" ON notification_queue
    FOR INSERT TO service_role
    WITH CHECK (true);

CREATE POLICY "notif_queue_service_update" ON notification_queue
    FOR UPDATE TO service_role
    USING (true);

CREATE INDEX IF NOT EXISTS idx_notification_queue_pending
    ON notification_queue (status) WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_notification_queue_user
    ON notification_queue (user_id);


-- ─── 3. Score Change → Notification Queue Trigger ───────────────────────────
-- When a new row is inserted into product_score_history, check if any users
-- are watching that product and queue notifications for significant changes.

CREATE OR REPLACE FUNCTION queue_score_change_notifications()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_product_name text;
    v_watcher RECORD;
BEGIN
    -- Only process rows with a meaningful score change
    IF NEW.score_delta IS NULL OR NEW.score_delta = 0 THEN
        RETURN NEW;
    END IF;

    -- Get product name
    SELECT product_name INTO v_product_name
    FROM products
    WHERE product_id = NEW.product_id;

    IF v_product_name IS NULL THEN
        RETURN NEW;
    END IF;

    -- Find all users watching this product whose alert threshold is met
    FOR v_watcher IN
        SELECT user_id, alert_threshold
        FROM user_watched_products
        WHERE product_id = NEW.product_id
          AND 'score_change' = ANY(notify_on)
          AND ABS(NEW.score_delta) >= alert_threshold
    LOOP
        INSERT INTO notification_queue (
            user_id, product_id, product_name,
            old_score, new_score, delta, direction
        ) VALUES (
            v_watcher.user_id,
            NEW.product_id,
            v_product_name,
            NEW.unhealthiness_score - NEW.score_delta,
            NEW.unhealthiness_score,
            NEW.score_delta,
            CASE WHEN NEW.score_delta < 0 THEN 'improved' ELSE 'worsened' END
        );

        -- Update last_alerted_at on the watch entry
        UPDATE user_watched_products
        SET last_alerted_at = now()
        WHERE user_id = v_watcher.user_id
          AND product_id = NEW.product_id;
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_queue_score_notifications ON product_score_history;
CREATE TRIGGER trg_queue_score_notifications
    AFTER INSERT ON product_score_history
    FOR EACH ROW
    EXECUTE FUNCTION queue_score_change_notifications();


-- ─── 4. API Functions ───────────────────────────────────────────────────────

-- 4a) Save a push subscription
CREATE OR REPLACE FUNCTION api_save_push_subscription(
    p_endpoint text,
    p_key_p256dh text,
    p_key_auth text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_uid uuid := auth.uid();
BEGIN
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Authentication required.'
        );
    END IF;

    -- Validate endpoint URL
    IF p_endpoint IS NULL OR p_endpoint = '' OR
       NOT (p_endpoint LIKE 'https://%') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Invalid push endpoint.'
        );
    END IF;

    -- Validate keys
    IF p_key_p256dh IS NULL OR p_key_p256dh = '' OR
       p_key_auth IS NULL OR p_key_auth = '' THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Invalid push subscription keys.'
        );
    END IF;

    INSERT INTO push_subscriptions (user_id, endpoint, keys)
    VALUES (
        v_uid,
        p_endpoint,
        jsonb_build_object('p256dh', p_key_p256dh, 'auth', p_key_auth)
    )
    ON CONFLICT (user_id, endpoint) DO UPDATE SET
        keys = EXCLUDED.keys,
        created_at = now();

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true
    );
END;
$$;

REVOKE ALL ON FUNCTION api_save_push_subscription(text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION api_save_push_subscription(text, text, text) TO authenticated;


-- 4b) Delete a push subscription (unsubscribe)
CREATE OR REPLACE FUNCTION api_delete_push_subscription(
    p_endpoint text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_uid uuid := auth.uid();
    v_deleted boolean;
BEGIN
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Authentication required.'
        );
    END IF;

    DELETE FROM push_subscriptions
    WHERE user_id = v_uid AND endpoint = p_endpoint;

    v_deleted := FOUND;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true,
        'deleted', v_deleted
    );
END;
$$;

REVOKE ALL ON FUNCTION api_delete_push_subscription(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION api_delete_push_subscription(text) TO authenticated;


-- 4c) Get push subscriptions for current user
CREATE OR REPLACE FUNCTION api_get_push_subscriptions()
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_uid uuid := auth.uid();
    v_subs jsonb;
BEGIN
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Authentication required.'
        );
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', id,
            'endpoint', endpoint,
            'created_at', created_at
        )
    ), '[]'::jsonb) INTO v_subs
    FROM push_subscriptions
    WHERE user_id = v_uid;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true,
        'subscriptions', v_subs,
        'count', jsonb_array_length(v_subs)
    );
END;
$$;

REVOKE ALL ON FUNCTION api_get_push_subscriptions() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION api_get_push_subscriptions() TO authenticated;


-- 4d) Process notification queue — called by Edge Function (service_role only)
CREATE OR REPLACE FUNCTION api_get_pending_notifications(
    p_limit int DEFAULT 50
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_notifications jsonb;
BEGIN
    -- This function should only be called by service_role
    -- (Edge Function with service_role key)

    SELECT COALESCE(jsonb_agg(row_to_json(n.*)), '[]'::jsonb)
    INTO v_notifications
    FROM (
        SELECT
            nq.id,
            nq.user_id,
            nq.product_id,
            nq.product_name,
            nq.old_score,
            nq.new_score,
            nq.delta,
            nq.direction,
            nq.created_at,
            jsonb_agg(
                jsonb_build_object(
                    'endpoint', ps.endpoint,
                    'keys', ps.keys
                )
            ) AS subscriptions
        FROM notification_queue nq
        JOIN push_subscriptions ps ON ps.user_id = nq.user_id
        WHERE nq.status = 'pending'
        GROUP BY nq.id
        ORDER BY nq.created_at ASC
        LIMIT p_limit
    ) n;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true,
        'notifications', v_notifications,
        'count', jsonb_array_length(v_notifications)
    );
END;
$$;

REVOKE ALL ON FUNCTION api_get_pending_notifications(int) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION api_get_pending_notifications(int) TO service_role;


-- 4e) Mark notifications as sent — called by Edge Function
CREATE OR REPLACE FUNCTION api_mark_notifications_sent(
    p_notification_ids bigint[],
    p_status text DEFAULT 'sent'
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    IF p_status NOT IN ('sent', 'failed', 'no_subscription') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'success', false,
            'error', 'Invalid status.'
        );
    END IF;

    UPDATE notification_queue
    SET status  = p_status,
        sent_at = CASE WHEN p_status = 'sent' THEN now() ELSE sent_at END
    WHERE id = ANY(p_notification_ids);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true,
        'updated', array_length(p_notification_ids, 1)
    );
END;
$$;

REVOKE ALL ON FUNCTION api_mark_notifications_sent(bigint[], text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION api_mark_notifications_sent(bigint[], text) TO service_role;


-- 4f) Cleanup expired push subscriptions — service_role only
CREATE OR REPLACE FUNCTION api_cleanup_push_subscriptions(
    p_endpoint text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM push_subscriptions WHERE endpoint = p_endpoint;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true,
        'cleaned', FOUND
    );
END;
$$;

REVOKE ALL ON FUNCTION api_cleanup_push_subscriptions(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION api_cleanup_push_subscriptions(text) TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: notification_preferences
-- Issue:     #617 — Push alerts for watchlist product score changes
-- Purpose:   Add notification preference columns to user_preferences,
--            update get/set API functions, add rate limiting (max 5/day)
--            to queue trigger, and respect opt-out preference.
-- Rollback:  ALTER TABLE user_preferences
--              DROP COLUMN IF EXISTS notification_score_changes,
--              DROP COLUMN IF EXISTS notification_frequency;
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─── 1. Add notification columns to user_preferences ────────────────────────

ALTER TABLE public.user_preferences
  ADD COLUMN IF NOT EXISTS notification_score_changes boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS notification_frequency     text    NOT NULL DEFAULT 'immediate';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_notification_frequency'
      AND conrelid = 'public.user_preferences'::regclass
  ) THEN
    ALTER TABLE public.user_preferences
      ADD CONSTRAINT chk_notification_frequency
      CHECK (notification_frequency IN ('immediate', 'daily_digest', 'weekly_digest'));
  END IF;
END $$;


-- ─── 2. Update api_get_user_preferences() — return new fields ───────────────

CREATE OR REPLACE FUNCTION public.api_get_user_preferences()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid  uuid;
  v_row  user_preferences%ROWTYPE;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required.');
  END IF;

  -- Auto-upsert for first-time callers
  INSERT INTO user_preferences (user_id, country)
  VALUES (v_uid, NULL)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO v_row FROM user_preferences WHERE user_id = v_uid;

  RETURN jsonb_build_object(
    'api_version',                '1.0',
    'user_id',                    v_row.user_id,
    'country',                    v_row.country,
    'preferred_language',         v_row.preferred_language,
    'diet_preference',            v_row.diet_preference,
    'avoid_allergens',            COALESCE(v_row.avoid_allergens, '{}'),
    'strict_allergen',            v_row.strict_allergen,
    'strict_diet',                v_row.strict_diet,
    'treat_may_contain_as_unsafe',v_row.treat_may_contain_as_unsafe,
    'health_goals',               COALESCE(v_row.health_goals, '{}'),
    'favorite_categories',        COALESCE(v_row.favorite_categories, '{}'),
    'onboarding_complete',        v_row.onboarding_completed OR v_row.onboarding_skipped,
    'onboarding_completed',       v_row.onboarding_completed,
    'onboarding_skipped',         v_row.onboarding_skipped,
    'notification_score_changes', v_row.notification_score_changes,
    'notification_frequency',     v_row.notification_frequency,
    'created_at',                 v_row.created_at,
    'updated_at',                 v_row.updated_at
  );
END;
$$;


-- ─── 3. Update api_set_user_preferences() — accept new params ───────────────
-- Drop the old 7-param signature to avoid overload confusion, then create
-- a new 9-param version.  The two new params default to NULL so existing
-- callers are unaffected (COALESCE preserves current values on update).

DROP FUNCTION IF EXISTS public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text);

CREATE OR REPLACE FUNCTION public.api_set_user_preferences(
    p_country                     text     DEFAULT NULL,
    p_diet_preference             text     DEFAULT NULL,
    p_avoid_allergens             text[]   DEFAULT NULL,
    p_strict_allergen             boolean  DEFAULT false,
    p_strict_diet                 boolean  DEFAULT false,
    p_treat_may_contain_as_unsafe boolean  DEFAULT false,
    p_preferred_language          text     DEFAULT NULL,
    p_notification_score_changes  boolean  DEFAULT NULL,
    p_notification_frequency      text     DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid uuid;
    v_current_country text;
    v_effective_language text;
    v_country_default_lang text;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Validate country
    IF p_country IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM country_ref
            WHERE country_code = p_country AND is_active = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Country not available: ' || COALESCE(p_country, 'NULL')
            );
        END IF;
    END IF;

    -- Validate diet preference
    IF p_diet_preference IS NOT NULL AND p_diet_preference NOT IN ('none','vegetarian','vegan') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid diet_preference. Use: none, vegetarian, vegan.'
        );
    END IF;

    -- Validate preferred_language
    IF p_preferred_language IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM language_ref
            WHERE code = p_preferred_language AND is_enabled = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Invalid preferred_language. Enabled: ' ||
                    (SELECT string_agg(code, ', ' ORDER BY sort_order)
                     FROM language_ref WHERE is_enabled = true)
            );
        END IF;
    END IF;

    -- Validate notification_frequency
    IF p_notification_frequency IS NOT NULL
       AND p_notification_frequency NOT IN ('immediate', 'daily_digest', 'weekly_digest')
    THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid notification_frequency. Use: immediate, daily_digest, weekly_digest.'
        );
    END IF;

    -- Auto-set language on country change
    IF p_country IS NOT NULL AND p_preferred_language IS NULL THEN
        SELECT country INTO v_current_country
        FROM user_preferences
        WHERE user_id = v_uid;

        IF v_current_country IS NULL OR v_current_country <> p_country THEN
            SELECT default_language INTO v_country_default_lang
            FROM country_ref
            WHERE country_code = p_country;

            IF v_country_default_lang IS NOT NULL THEN
                v_effective_language := v_country_default_lang;
            END IF;
        END IF;
    END IF;

    v_effective_language := COALESCE(p_preferred_language, v_effective_language);

    -- Upsert
    INSERT INTO user_preferences (
        user_id, country, diet_preference, avoid_allergens,
        strict_allergen, strict_diet, treat_may_contain_as_unsafe,
        preferred_language, notification_score_changes, notification_frequency
    ) VALUES (
        v_uid, p_country, p_diet_preference, p_avoid_allergens,
        p_strict_allergen, p_strict_diet, p_treat_may_contain_as_unsafe,
        COALESCE(v_effective_language, 'en'),
        COALESCE(p_notification_score_changes, true),
        COALESCE(p_notification_frequency, 'immediate')
    )
    ON CONFLICT (user_id) DO UPDATE SET
        country                     = COALESCE(EXCLUDED.country, user_preferences.country),
        diet_preference             = EXCLUDED.diet_preference,
        avoid_allergens             = EXCLUDED.avoid_allergens,
        strict_allergen             = EXCLUDED.strict_allergen,
        strict_diet                 = EXCLUDED.strict_diet,
        treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
        preferred_language          = COALESCE(
                                        v_effective_language,
                                        user_preferences.preferred_language
                                    ),
        notification_score_changes  = COALESCE(
                                        p_notification_score_changes,
                                        user_preferences.notification_score_changes
                                    ),
        notification_frequency      = COALESCE(
                                        p_notification_frequency,
                                        user_preferences.notification_frequency
                                    ),
        updated_at                  = now();

    RETURN api_get_user_preferences();
END;
$function$;

COMMENT ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text, boolean, text) IS
'Create or update user preferences.  New notification params (p_notification_score_changes, '
'p_notification_frequency) default to NULL — COALESCE preserves existing values when omitted, '
'so existing callers remain backward-compatible.  When country changes (and no explicit '
'language given), preferred_language auto-resets to the new country''s default_language.';

GRANT EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text, boolean, text)
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text, boolean, text)
    FROM PUBLIC, anon;


-- ─── 4. Update queue trigger — respect opt-out + rate limit (5/day) ─────────

CREATE OR REPLACE FUNCTION queue_score_change_notifications()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_product_name text;
    v_watcher RECORD;
    v_daily_count integer;
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
    -- AND who have not opted out of score change notifications
    FOR v_watcher IN
        SELECT w.user_id, w.alert_threshold
        FROM user_watched_products w
        JOIN user_preferences up ON up.user_id = w.user_id
        WHERE w.product_id = NEW.product_id
          AND 'score_change' = ANY(w.notify_on)
          AND ABS(NEW.score_delta) >= w.alert_threshold
          AND up.notification_score_changes = true
    LOOP
        -- Rate limit: max 5 notifications per user per 24h
        SELECT count(*) INTO v_daily_count
        FROM notification_queue
        WHERE user_id = v_watcher.user_id
          AND created_at > now() - interval '24 hours';

        IF v_daily_count >= 5 THEN
            CONTINUE;
        END IF;

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


-- ─── 5. Update pending notifications query — filter by frequency ────────────
-- The Edge Function (send-push-notification) calls api_get_pending_notifications.
-- For digest users, only return notifications when the digest window has elapsed.

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
        JOIN user_preferences up ON up.user_id = nq.user_id
        WHERE nq.status = 'pending'
          -- Respect notification frequency:
          --   immediate  → always eligible
          --   daily      → only if notification is >24h old (batched by cron)
          --   weekly     → only if notification is >7d old  (batched by cron)
          AND (
              up.notification_frequency = 'immediate'
              OR (up.notification_frequency = 'daily_digest'
                  AND nq.created_at <= now() - interval '24 hours')
              OR (up.notification_frequency = 'weekly_digest'
                  AND nq.created_at <= now() - interval '7 days')
          )
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

COMMIT;

-- ─── pgTAP: Push Notification functions — auth error branches ───────────────
-- Tests the auth-error branch for push notification API functions.
-- Since pgTAP runs without auth.uid(), these all return {error: "Authentication required"}.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(15);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_save_push_subscription — auth error
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_save_push_subscription('https://push.example.com/sub', 'p256dh-key', 'auth-key')$$,
  'api_save_push_subscription does not throw'
);

SELECT is(
  (public.api_save_push_subscription('https://push.example.com/sub', 'p256dh-key', 'auth-key'))->>'error',
  'Authentication required.',
  'api_save_push_subscription requires auth'
);

SELECT is(
  (public.api_save_push_subscription('https://push.example.com/sub', 'p256dh-key', 'auth-key'))->>'api_version',
  '1.0',
  'api_save_push_subscription returns api_version even on error'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_delete_push_subscription — auth error
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_delete_push_subscription('https://push.example.com/sub')$$,
  'api_delete_push_subscription does not throw'
);

SELECT is(
  (public.api_delete_push_subscription('https://push.example.com/sub'))->>'error',
  'Authentication required.',
  'api_delete_push_subscription requires auth'
);

SELECT is(
  (public.api_delete_push_subscription('https://push.example.com/sub'))->>'api_version',
  '1.0',
  'api_delete_push_subscription returns api_version even on error'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_push_subscriptions — auth error
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_push_subscriptions()$$,
  'api_get_push_subscriptions does not throw'
);

SELECT is(
  (public.api_get_push_subscriptions())->>'error',
  'Authentication required.',
  'api_get_push_subscriptions requires auth'
);

SELECT is(
  (public.api_get_push_subscriptions())->>'api_version',
  '1.0',
  'api_get_push_subscriptions returns api_version even on error'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. notification_score_changes column defaults to true
-- ═══════════════════════════════════════════════════════════════════════════

SELECT col_default_is(
  'public', 'user_preferences', 'notification_score_changes', 'true',
  'notification_score_changes defaults to true'
);

SELECT col_not_null(
  'public', 'user_preferences', 'notification_score_changes',
  'notification_score_changes is NOT NULL'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. notification_frequency column defaults to 'immediate'
-- ═══════════════════════════════════════════════════════════════════════════

SELECT col_default_is(
  'public', 'user_preferences', 'notification_frequency', '''immediate''::text',
  'notification_frequency defaults to immediate'
);

SELECT col_not_null(
  'public', 'user_preferences', 'notification_frequency',
  'notification_frequency is NOT NULL'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_set_user_preferences accepts 9 params (new signature with notification)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_set_user_preferences(
      NULL, NULL, NULL, false, false, false, NULL, NULL, NULL
  )$$,
  'api_set_user_preferences with 9 params does not throw'
);

SELECT is(
  (public.api_set_user_preferences(
      NULL, NULL, NULL, false, false, false, NULL, NULL, NULL
  ))->>'error',
  'Authentication required.',
  'api_set_user_preferences 9-param requires auth'
);

SELECT * FROM finish();
ROLLBACK;

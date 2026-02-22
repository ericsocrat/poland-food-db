-- ─── pgTAP: Push Notification functions — auth error branches ───────────────
-- Tests the auth-error branch for push notification API functions.
-- Since pgTAP runs without auth.uid(), these all return {error: "Authentication required"}.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(9);

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

SELECT * FROM finish();
ROLLBACK;

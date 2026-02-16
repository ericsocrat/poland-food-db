-- ─── pgTAP: Personalized Dashboard function tests ────────────────────────────
-- Tests for api_record_product_view, api_get_recently_viewed,
-- api_get_dashboard_data.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(16);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_record_product_view — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_record_product_view(1)$$,
  'api_record_product_view does not throw'
);

SELECT is(
  (public.api_record_product_view(1))->>'api_version',
  '1.0',
  'api_record_product_view returns api_version'
);

SELECT ok(
  (public.api_record_product_view(1)) ? 'error',
  'api_record_product_view returns error when unauthenticated'
);

SELECT is(
  (public.api_record_product_view(1))->>'error',
  'Authentication required',
  'api_record_product_view auth error message is correct'
);

-- NULL product_id still handled gracefully (auth check first)
SELECT lives_ok(
  $$SELECT public.api_record_product_view(NULL)$$,
  'api_record_product_view with NULL product does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_get_recently_viewed — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_recently_viewed()$$,
  'api_get_recently_viewed does not throw with defaults'
);

SELECT lives_ok(
  $$SELECT public.api_get_recently_viewed(5)$$,
  'api_get_recently_viewed does not throw with custom limit'
);

SELECT lives_ok(
  $$SELECT public.api_get_recently_viewed(0)$$,
  'api_get_recently_viewed does not throw with 0 limit (clamped to 1)'
);

SELECT lives_ok(
  $$SELECT public.api_get_recently_viewed(100)$$,
  'api_get_recently_viewed does not throw with 100 limit (clamped to 50)'
);

SELECT is(
  (public.api_get_recently_viewed())->>'api_version',
  '1.0',
  'api_get_recently_viewed returns api_version'
);

SELECT ok(
  (public.api_get_recently_viewed()) ? 'error',
  'api_get_recently_viewed returns error when unauthenticated'
);

SELECT is(
  (public.api_get_recently_viewed())->>'error',
  'Authentication required',
  'api_get_recently_viewed auth error message is correct'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_dashboard_data — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_dashboard_data()$$,
  'api_get_dashboard_data does not throw'
);

SELECT is(
  (public.api_get_dashboard_data())->>'api_version',
  '1.0',
  'api_get_dashboard_data returns api_version'
);

SELECT ok(
  (public.api_get_dashboard_data()) ? 'error',
  'api_get_dashboard_data returns error when unauthenticated'
);

SELECT is(
  (public.api_get_dashboard_data())->>'error',
  'Authentication required',
  'api_get_dashboard_data auth error message is correct'
);

SELECT * FROM finish();
ROLLBACK;

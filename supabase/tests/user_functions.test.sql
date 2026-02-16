-- ─── pgTAP: User / Auth-required API function tests ─────────────────────────
-- Tests the auth-error branch for all functions that require authentication.
-- Since pgTAP runs without auth.uid(), these all return {error: "Authentication required"}.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(29);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. User preferences — auth error branches
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_user_preferences()$$,
  'api_get_user_preferences does not throw'
);

SELECT is(
  (public.api_get_user_preferences())->>'error',
  'Authentication required.',
  'api_get_user_preferences requires auth'
);

SELECT is(
  (public.api_get_user_preferences())->>'api_version',
  '1.0',
  'api_get_user_preferences returns api_version even on error'
);

SELECT lives_ok(
  $$SELECT public.api_set_user_preferences('XX')$$,
  'api_set_user_preferences does not throw'
);

SELECT is(
  (public.api_set_user_preferences('XX'))->>'error',
  'Authentication required.',
  'api_set_user_preferences requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Product submissions — auth error branches
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_submit_product('5901234000001', 'Test')$$,
  'api_submit_product does not throw'
);

SELECT is(
  (public.api_submit_product('5901234000001', 'Test'))->>'error',
  'Authentication required',
  'api_submit_product requires auth'
);

SELECT lives_ok(
  $$SELECT public.api_get_my_submissions()$$,
  'api_get_my_submissions does not throw'
);

SELECT is(
  (public.api_get_my_submissions())->>'error',
  'Authentication required',
  'api_get_my_submissions requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Scan history — auth error branch
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_scan_history()$$,
  'api_get_scan_history does not throw'
);

SELECT is(
  (public.api_get_scan_history())->>'error',
  'Authentication required',
  'api_get_scan_history requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Saved searches — auth error branches
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_save_search('test', 'query')$$,
  'api_save_search does not throw'
);

SELECT is(
  (public.api_save_search('test', 'query'))->>'error',
  'Authentication required',
  'api_save_search requires auth'
);

SELECT lives_ok(
  $$SELECT public.api_get_saved_searches()$$,
  'api_get_saved_searches does not throw'
);

SELECT is(
  (public.api_get_saved_searches())->>'error',
  'Authentication required',
  'api_get_saved_searches requires auth'
);

SELECT is(
  (public.api_delete_saved_search('00000000-0000-0000-0000-000000000000'::uuid))->>'error',
  'Authentication required',
  'api_delete_saved_search requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Product lists — auth error branches
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_lists()$$,
  'api_get_lists does not throw'
);

SELECT is(
  (public.api_get_lists())->>'error',
  'Authentication required',
  'api_get_lists requires auth'
);

SELECT is(
  (public.api_create_list('test'))->>'error',
  'Authentication required',
  'api_create_list requires auth'
);

SELECT is(
  (public.api_add_to_list('00000000-0000-0000-0000-000000000000'::uuid, 1))->>'error',
  'Authentication required',
  'api_add_to_list requires auth'
);

SELECT is(
  (public.api_get_list_items('00000000-0000-0000-0000-000000000000'::uuid))->>'error',
  'Authentication required',
  'api_get_list_items requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Health profiles — auth error branches
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_list_health_profiles()$$,
  'api_list_health_profiles does not throw'
);

SELECT is(
  (public.api_list_health_profiles())->>'error',
  'Authentication required',
  'api_list_health_profiles requires auth'
);

SELECT is(
  (public.api_get_active_health_profile())->>'error',
  'Authentication required',
  'api_get_active_health_profile requires auth'
);

SELECT is(
  (public.api_create_health_profile('test'))->>'error',
  'Authentication required',
  'api_create_health_profile requires auth'
);

SELECT is(
  (public.api_delete_health_profile('00000000-0000-0000-0000-000000000000'::uuid))->>'error',
  'Authentication required',
  'api_delete_health_profile requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Shared list — no auth required but invalid token
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_shared_list('invalid-token')$$,
  'api_get_shared_list does not throw for invalid token'
);

SELECT ok(
  (public.api_get_shared_list('invalid-token')) ? 'error',
  'api_get_shared_list returns error for invalid token'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Product health warnings — auth error branch
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  (public.api_product_health_warnings(1))->>'error',
  'Authentication required',
  'api_product_health_warnings requires auth'
);

SELECT * FROM finish();
ROLLBACK;

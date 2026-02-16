-- ─── pgTAP: Telemetry & Analytics function tests ─────────────────────────────
-- Tests for api_track_event, api_admin_get_event_summary,
-- api_admin_get_top_events, api_admin_get_funnel.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(41);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_track_event — valid events
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_track_event('product_viewed')$$,
  'api_track_event does not throw for valid event'
);

SELECT is(
  (public.api_track_event('product_viewed'))->>'tracked',
  'true',
  'api_track_event returns tracked=true for valid event'
);

SELECT is(
  (public.api_track_event('product_viewed'))->>'api_version',
  '1.0',
  'api_track_event returns api_version'
);

-- With full params
SELECT is(
  (public.api_track_event(
    'search_performed',
    '{"query": "chips", "results_count": 42}'::jsonb,
    'session-abc-123',
    'mobile'
  ))->>'tracked',
  'true',
  'api_track_event works with all params'
);

-- With NULL event_data → defaults to empty object
SELECT is(
  (public.api_track_event('scanner_used', NULL, NULL, NULL))->>'tracked',
  'true',
  'api_track_event handles NULL event_data gracefully'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_track_event — all event name variants accepted
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  (public.api_track_event('filter_applied'))->>'tracked', 'true',
  'filter_applied is accepted'
);

SELECT is(
  (public.api_track_event('compare_opened'))->>'tracked', 'true',
  'compare_opened is accepted'
);

SELECT is(
  (public.api_track_event('list_created'))->>'tracked', 'true',
  'list_created is accepted'
);

SELECT is(
  (public.api_track_event('favorites_added'))->>'tracked', 'true',
  'favorites_added is accepted'
);

SELECT is(
  (public.api_track_event('avoid_added'))->>'tracked', 'true',
  'avoid_added is accepted'
);

SELECT is(
  (public.api_track_event('product_not_found'))->>'tracked', 'true',
  'product_not_found is accepted'
);

SELECT is(
  (public.api_track_event('share_link_opened'))->>'tracked', 'true',
  'share_link_opened is accepted'
);

SELECT is(
  (public.api_track_event('category_viewed'))->>'tracked', 'true',
  'category_viewed is accepted'
);

SELECT is(
  (public.api_track_event('preferences_updated'))->>'tracked', 'true',
  'preferences_updated is accepted'
);

SELECT is(
  (public.api_track_event('onboarding_completed'))->>'tracked', 'true',
  'onboarding_completed is accepted'
);

SELECT is(
  (public.api_track_event('dashboard_viewed'))->>'tracked', 'true',
  'dashboard_viewed is accepted'
);

SELECT is(
  (public.api_track_event('submission_created'))->>'tracked', 'true',
  'submission_created is accepted'
);

SELECT is(
  (public.api_track_event('search_saved'))->>'tracked', 'true',
  'search_saved is accepted'
);

SELECT is(
  (public.api_track_event('list_shared'))->>'tracked', 'true',
  'list_shared is accepted'
);

SELECT is(
  (public.api_track_event('list_item_added'))->>'tracked', 'true',
  'list_item_added is accepted'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_track_event — rejection cases
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (public.api_track_event('nonexistent_event')) ? 'error',
  'api_track_event rejects unknown event name'
);

SELECT matches(
  (public.api_track_event('nonexistent_event'))->>'error',
  'Unknown event name.*',
  'api_track_event error message contains event name info'
);

SELECT ok(
  (public.api_track_event(NULL)) ? 'error',
  'api_track_event rejects NULL event name'
);

SELECT ok(
  (public.api_track_event('product_viewed', '{}'::jsonb, NULL, 'smartwatch')) ? 'error',
  'api_track_event rejects invalid device_type'
);

SELECT matches(
  (public.api_track_event('product_viewed', '{}'::jsonb, NULL, 'smartwatch'))->>'error',
  'Invalid device_type.*',
  'api_track_event device_type error message is descriptive'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_admin_get_event_summary — structure tests
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_get_event_summary()$$,
  'api_admin_get_event_summary does not throw'
);

SELECT is(
  (public.api_admin_get_event_summary())->>'api_version',
  '1.0',
  'api_admin_get_event_summary returns api_version'
);

SELECT ok(
  (public.api_admin_get_event_summary()) ? 'summary',
  'api_admin_get_event_summary returns summary key'
);

SELECT ok(
  (public.api_admin_get_event_summary()) ? 'days',
  'api_admin_get_event_summary returns days key'
);

SELECT ok(
  (public.api_admin_get_event_summary()) ? 'group_by',
  'api_admin_get_event_summary returns group_by key'
);

-- With filter
SELECT lives_ok(
  $$SELECT public.api_admin_get_event_summary('product_viewed', 7, 'day')$$,
  'api_admin_get_event_summary with filter does not throw'
);

-- With week grouping
SELECT lives_ok(
  $$SELECT public.api_admin_get_event_summary(NULL, 30, 'week')$$,
  'api_admin_get_event_summary with week grouping does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_admin_get_top_events — structure tests
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_get_top_events()$$,
  'api_admin_get_top_events does not throw'
);

SELECT is(
  (public.api_admin_get_top_events())->>'api_version',
  '1.0',
  'api_admin_get_top_events returns api_version'
);

SELECT ok(
  (public.api_admin_get_top_events()) ? 'events',
  'api_admin_get_top_events returns events key'
);

SELECT ok(
  (public.api_admin_get_top_events()) ? 'days',
  'api_admin_get_top_events returns days key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_admin_get_funnel — structure tests
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_get_funnel(ARRAY['scanner_used', 'product_not_found', 'submission_created'])$$,
  'api_admin_get_funnel does not throw'
);

SELECT is(
  (public.api_admin_get_funnel(ARRAY['scanner_used', 'product_not_found']))->>'api_version',
  '1.0',
  'api_admin_get_funnel returns api_version'
);

SELECT ok(
  (public.api_admin_get_funnel(ARRAY['scanner_used'])) ? 'funnel',
  'api_admin_get_funnel returns funnel key'
);

-- Empty/null array → error
SELECT ok(
  (public.api_admin_get_funnel(NULL)) ? 'error',
  'api_admin_get_funnel rejects NULL array'
);

SELECT matches(
  (public.api_admin_get_funnel(NULL))->>'error',
  '.*non-empty.*',
  'api_admin_get_funnel NULL error is descriptive'
);

SELECT * FROM finish();
ROLLBACK;

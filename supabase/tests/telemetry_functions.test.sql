-- ─── pgTAP: Telemetry & Analytics function tests ─────────────────────────────
-- Tests for api_track_event (12-param), api_validate_event_schema,
-- api_get_event_schemas, api_admin_get_event_summary (country-scoped),
-- api_admin_get_top_events (country-scoped), api_admin_get_funnel (country-scoped).
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(59);

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

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. api_track_event — extended params (country, consent, anonymous_id)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  (public.api_track_event(
    p_event_name := 'product_viewed',
    p_event_data := '{"product_id": 1}'::jsonb,
    p_country := 'DE'
  ))->>'tracked',
  'true',
  'api_track_event accepts DE country'
);

SELECT is(
  (public.api_track_event(
    p_event_name := 'page_view',
    p_route := '/app/categories'
  ))->>'tracked',
  'true',
  'api_track_event accepts route param'
);

SELECT is(
  (public.api_track_event(
    p_event_name := 'product_viewed',
    p_consent_level := 'full',
    p_app_version := '1.2.0'
  ))->>'tracked',
  'true',
  'api_track_event accepts consent_level and app_version'
);

SELECT is(
  (public.api_track_event(
    p_event_name := 'search_performed',
    p_anonymous_id := gen_random_uuid()
  ))->>'tracked',
  'true',
  'api_track_event accepts anonymous_id'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. api_track_event — consent gating
-- ═══════════════════════════════════════════════════════════════════════════

-- Essential consent blocks non-error events
SELECT is(
  (public.api_track_event(
    p_event_name := 'product_viewed',
    p_consent_level := 'essential'
  ))->>'tracked',
  'false',
  'essential consent blocks non-error events'
);

-- Essential consent allows client_error
SELECT is(
  (public.api_track_event(
    p_event_name := 'client_error',
    p_consent_level := 'essential',
    p_event_data := '{"message": "test error"}'::jsonb
  ))->>'tracked',
  'true',
  'essential consent allows client_error'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. api_validate_event_schema — validation
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_validate_event_schema('product_viewed', '{"product_id": 1}'::jsonb)$$,
  'api_validate_event_schema does not throw'
);

SELECT is(
  (public.api_validate_event_schema('product_viewed', '{"product_id": 1}'::jsonb))->>'valid',
  'true',
  'api_validate_event_schema returns valid=true for correct data'
);

SELECT is(
  (public.api_validate_event_schema('product_viewed', '{"product_id": 1}'::jsonb))->>'api_version',
  '1.0',
  'api_validate_event_schema returns api_version'
);

-- Invalid data (missing required field for v2 schema)
SELECT is(
  (public.api_validate_event_schema('search_performed', '{}'::jsonb, 2))->>'valid',
  'false',
  'api_validate_event_schema returns valid=false for missing required fields'
);

-- Unknown event → error
SELECT ok(
  (public.api_validate_event_schema('nonexistent', '{}'::jsonb)) ? 'error',
  'api_validate_event_schema returns error for unknown event'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. api_get_event_schemas — structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_event_schemas()$$,
  'api_get_event_schemas does not throw'
);

SELECT is(
  (public.api_get_event_schemas())->>'api_version',
  '1.0',
  'api_get_event_schemas returns api_version'
);

SELECT ok(
  (public.api_get_event_schemas()) ? 'schemas',
  'api_get_event_schemas returns schemas key'
);

-- Filter by event type
SELECT ok(
  (public.api_get_event_schemas('product_viewed')) ? 'schemas',
  'api_get_event_schemas filters by event_type'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Admin functions — country scoping
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_get_event_summary(NULL, 7, 'day', 'PL')$$,
  'api_admin_get_event_summary with country filter does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_get_top_events(10, 30, 'DE')$$,
  'api_admin_get_top_events with country filter does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_get_funnel(ARRAY['scanner_used', 'product_not_found'], 30, 'PL')$$,
  'api_admin_get_funnel with country filter does not throw'
);

SELECT * FROM finish();
ROLLBACK;

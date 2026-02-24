-- ─── pgTAP: Business Metrics function tests ─────────────────────────────────
-- Tests for metric_dau, metric_searches_per_day, metric_top_queries,
-- metric_failed_searches, metric_top_products, metric_allergen_distribution,
-- metric_feature_usage, metric_scan_vs_search, metric_onboarding_funnel,
-- metric_category_popularity, aggregate_daily_metrics,
-- api_admin_get_business_metrics.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(32);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. analytics_daily table exists
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'analytics_daily', 'analytics_daily table exists');

SELECT has_column('public', 'analytics_daily', 'date', 'analytics_daily.date exists');
SELECT has_column('public', 'analytics_daily', 'metric', 'analytics_daily.metric exists');
SELECT has_column('public', 'analytics_daily', 'value', 'analytics_daily.value exists');
SELECT has_column('public', 'analytics_daily', 'metadata', 'analytics_daily.metadata exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Metric functions exist and do not throw
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.metric_dau()$$,
  'metric_dau() does not throw'
);

SELECT lives_ok(
  $$SELECT public.metric_dau('2026-01-01'::date)$$,
  'metric_dau(date) does not throw'
);

SELECT lives_ok(
  $$SELECT public.metric_searches_per_day()$$,
  'metric_searches_per_day() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_top_queries()$$,
  'metric_top_queries() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_top_queries('2026-01-01'::date, 5)$$,
  'metric_top_queries(date, limit) does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_failed_searches()$$,
  'metric_failed_searches() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_top_products()$$,
  'metric_top_products() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_allergen_distribution()$$,
  'metric_allergen_distribution() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_feature_usage()$$,
  'metric_feature_usage() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_feature_usage('2026-01-01'::date, '2026-02-01'::date)$$,
  'metric_feature_usage(date, date) does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_scan_vs_search()$$,
  'metric_scan_vs_search() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_onboarding_funnel()$$,
  'metric_onboarding_funnel() does not throw'
);

SELECT lives_ok(
  $$SELECT * FROM public.metric_category_popularity()$$,
  'metric_category_popularity() does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. aggregate_daily_metrics — runs without error and populates data
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.aggregate_daily_metrics('2026-01-15'::date)$$,
  'aggregate_daily_metrics() does not throw'
);

-- After aggregation, analytics_daily should have rows for the target date
SELECT ok(
  (SELECT count(*) FROM public.analytics_daily WHERE date = '2026-01-15') >= 1,
  'aggregate_daily_metrics populates analytics_daily rows'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_admin_get_business_metrics — structure tests
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_get_business_metrics()$$,
  'api_admin_get_business_metrics() does not throw'
);

SELECT is(
  (public.api_admin_get_business_metrics())->>'api_version',
  '1.0',
  'api_admin_get_business_metrics returns api_version'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'dau',
  'api_admin_get_business_metrics returns dau key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'searches',
  'api_admin_get_business_metrics returns searches key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'top_queries',
  'api_admin_get_business_metrics returns top_queries key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'failed_searches',
  'api_admin_get_business_metrics returns failed_searches key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'top_products',
  'api_admin_get_business_metrics returns top_products key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'allergen_distribution',
  'api_admin_get_business_metrics returns allergen_distribution key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'feature_usage',
  'api_admin_get_business_metrics returns feature_usage key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'scan_vs_search',
  'api_admin_get_business_metrics returns scan_vs_search key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'onboarding_funnel',
  'api_admin_get_business_metrics returns onboarding_funnel key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'category_popularity',
  'api_admin_get_business_metrics returns category_popularity key'
);

SELECT ok(
  (public.api_admin_get_business_metrics()) ? 'trend',
  'api_admin_get_business_metrics returns trend key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. New event types are accepted
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  (public.api_track_event('onboarding_step'))->>'tracked', 'true',
  'onboarding_step event is accepted'
);

SELECT is(
  (public.api_track_event('recipe_view'))->>'tracked', 'true',
  'recipe_view event is accepted'
);

SELECT * FROM finish();
ROLLBACK;

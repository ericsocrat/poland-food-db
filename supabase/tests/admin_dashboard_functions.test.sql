-- ─── pgTAP: Admin Governance Dashboard function & view tests ────────────────
-- Tests for 6 admin dashboard views and 7 RPC functions from #206.
-- Views: v_provenance_health, v_scoring_drift, v_search_quality,
--        v_data_freshness_sla, v_migration_audit, v_event_analytics_summary
-- Functions: api_admin_provenance_health, api_admin_scoring_drift,
--            api_admin_search_quality, api_admin_freshness_sla,
--            api_admin_migration_audit, api_admin_event_summary,
--            api_admin_health_overview
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(42);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Views exist and are queryable
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_view('public', 'v_provenance_health',
  'view v_provenance_health exists');

SELECT has_view('public', 'v_scoring_drift',
  'view v_scoring_drift exists');

SELECT has_view('public', 'v_search_quality',
  'view v_search_quality exists');

SELECT has_view('public', 'v_data_freshness_sla',
  'view v_data_freshness_sla exists');

SELECT has_view('public', 'v_migration_audit',
  'view v_migration_audit exists');

SELECT has_view('public', 'v_event_analytics_summary',
  'view v_event_analytics_summary exists');

-- Query each view to prove it does not error
SELECT lives_ok(
  $$SELECT * FROM v_provenance_health$$,
  'v_provenance_health is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_scoring_drift$$,
  'v_scoring_drift is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_search_quality$$,
  'v_search_quality is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_data_freshness_sla$$,
  'v_data_freshness_sla is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_migration_audit$$,
  'v_migration_audit is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_event_analytics_summary$$,
  'v_event_analytics_summary is queryable'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. v_provenance_health returns expected columns & data
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (SELECT count(*) FROM v_provenance_health) >= 1,
  'v_provenance_health returns at least 1 row (PL exists)'
);

SELECT ok(
  EXISTS (SELECT 1 FROM v_provenance_health WHERE country = 'PL'),
  'v_provenance_health includes PL country'
);

SELECT ok(
  (SELECT total_products FROM v_provenance_health WHERE country = 'PL') > 0,
  'PL provenance has positive product count'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. v_scoring_drift returns expected data
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (SELECT count(*) FROM v_scoring_drift) >= 1,
  'v_scoring_drift returns at least 1 model version'
);

SELECT ok(
  EXISTS (SELECT 1 FROM v_scoring_drift WHERE status = 'active'),
  'v_scoring_drift includes an active model version'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. v_data_freshness_sla returns expected columns
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (SELECT count(*) FROM v_data_freshness_sla) >= 1,
  'v_data_freshness_sla returns at least 1 category row'
);

SELECT ok(
  (SELECT sla_status FROM v_data_freshness_sla LIMIT 1) IN ('healthy', 'warning', 'critical'),
  'v_data_freshness_sla sla_status is a valid enum value'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. v_migration_audit returns expected domains
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  EXISTS (SELECT 1 FROM v_migration_audit WHERE domain = 'mv_refresh'),
  'v_migration_audit includes mv_refresh domain'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. RPC functions exist and do not throw
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_admin_provenance_health()$$,
  'api_admin_provenance_health does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_scoring_drift()$$,
  'api_admin_scoring_drift does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_search_quality()$$,
  'api_admin_search_quality does not throw with defaults'
);

SELECT lives_ok(
  $$SELECT public.api_admin_search_quality(7)$$,
  'api_admin_search_quality does not throw with p_days=7'
);

SELECT lives_ok(
  $$SELECT public.api_admin_freshness_sla()$$,
  'api_admin_freshness_sla does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_migration_audit()$$,
  'api_admin_migration_audit does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_admin_event_summary()$$,
  'api_admin_event_summary does not throw with defaults'
);

SELECT lives_ok(
  $$SELECT public.api_admin_event_summary(7)$$,
  'api_admin_event_summary does not throw with p_days=7'
);

SELECT lives_ok(
  $$SELECT public.api_admin_health_overview()$$,
  'api_admin_health_overview does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. RPC return type validation
-- ═══════════════════════════════════════════════════════════════════════════

-- api_admin_provenance_health returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_provenance_health()) = 'array',
  'api_admin_provenance_health returns a JSON array'
);

-- api_admin_scoring_drift returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_scoring_drift()) = 'array',
  'api_admin_scoring_drift returns a JSON array'
);

-- api_admin_search_quality returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_search_quality()) = 'array',
  'api_admin_search_quality returns a JSON array'
);

-- api_admin_freshness_sla returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_freshness_sla()) = 'array',
  'api_admin_freshness_sla returns a JSON array'
);

-- api_admin_migration_audit returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_migration_audit()) = 'array',
  'api_admin_migration_audit returns a JSON array'
);

-- api_admin_event_summary returns valid JSONB array
SELECT ok(
  jsonb_typeof(public.api_admin_event_summary()) = 'array',
  'api_admin_event_summary returns a JSON array'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. api_admin_health_overview response shape
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  jsonb_typeof(public.api_admin_health_overview()) = 'object',
  'api_admin_health_overview returns a JSON object'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'api_version',
  'health overview includes api_version key'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'provenance',
  'health overview includes provenance key'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'scoring',
  'health overview includes scoring key'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'freshness',
  'health overview includes freshness key'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'migration',
  'health overview includes migration key'
);

SELECT ok(
  (public.api_admin_health_overview()) ? 'events',
  'health overview includes events key'
);

SELECT * FROM finish();
ROLLBACK;

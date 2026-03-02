-- ─── pgTAP: Cost Attribution function & view tests ──────────────────────────
-- Tests for #212: Infrastructure Cost Attribution Framework
-- Table:     ci_runtime_log
-- Views:     v_query_cost_by_domain, v_event_volume,
--            v_event_cost_projection, v_ci_runtime_summary
-- Function:  api_admin_cost_attribution
-- Run via:   supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(27);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. ci_runtime_log table exists with expected columns
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'ci_runtime_log',
  'table ci_runtime_log exists');

SELECT has_column('public', 'ci_runtime_log', 'id',
  'ci_runtime_log.id exists');
SELECT has_column('public', 'ci_runtime_log', 'workflow_name',
  'ci_runtime_log.workflow_name exists');
SELECT has_column('public', 'ci_runtime_log', 'job_name',
  'ci_runtime_log.job_name exists');
SELECT has_column('public', 'ci_runtime_log', 'run_id',
  'ci_runtime_log.run_id exists');
SELECT has_column('public', 'ci_runtime_log', 'duration_seconds',
  'ci_runtime_log.duration_seconds exists');
SELECT has_column('public', 'ci_runtime_log', 'status',
  'ci_runtime_log.status exists');
SELECT has_column('public', 'ci_runtime_log', 'recorded_at',
  'ci_runtime_log.recorded_at exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Views exist
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_view('public', 'v_query_cost_by_domain',
  'view v_query_cost_by_domain exists');

SELECT has_view('public', 'v_event_volume',
  'view v_event_volume exists');

SELECT has_view('public', 'v_event_cost_projection',
  'view v_event_cost_projection exists');

SELECT has_view('public', 'v_ci_runtime_summary',
  'view v_ci_runtime_summary exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Views are queryable (no syntax/dependency errors)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT * FROM v_query_cost_by_domain$$,
  'v_query_cost_by_domain is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_event_volume$$,
  'v_event_volume is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_event_cost_projection$$,
  'v_event_cost_projection is queryable'
);

SELECT lives_ok(
  $$SELECT * FROM v_ci_runtime_summary$$,
  'v_ci_runtime_summary is queryable'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_admin_cost_attribution function exists and does not throw
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'api_admin_cost_attribution',
  'function api_admin_cost_attribution exists');

SELECT lives_ok(
  $$SELECT public.api_admin_cost_attribution()$$,
  'api_admin_cost_attribution does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Return type & response shape validation
-- ═══════════════════════════════════════════════════════════════════════════

-- Unauth call returns error (auth.uid() is NULL in test context)
SELECT ok(
  (public.api_admin_cost_attribution()) ? 'error',
  'api_admin_cost_attribution returns error key when unauthenticated'
);

SELECT ok(
  (public.api_admin_cost_attribution()) ? 'api_version',
  'api_admin_cost_attribution returns api_version key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. ci_runtime_log: insert, query, uniqueness
-- ═══════════════════════════════════════════════════════════════════════════

-- Insert test data
SELECT lives_ok(
  $$INSERT INTO ci_runtime_log (workflow_name, job_name, run_id, run_number,
      trigger_event, branch, duration_seconds, status)
    VALUES ('pr-gate', 'build', 12345, 1, 'push', 'main', 120, 'success')$$,
  'can insert into ci_runtime_log'
);

-- Verify queryable after insert
SELECT ok(
  (SELECT count(*) FROM ci_runtime_log WHERE run_id = 12345) = 1,
  'ci_runtime_log has one row after insert'
);

-- Uniqueness constraint (run_id + job_name) — same combo should fail
SELECT throws_ok(
  $$INSERT INTO ci_runtime_log (workflow_name, job_name, run_id, duration_seconds, status)
    VALUES ('pr-gate', 'build', 12345, 60, 'success')$$,
  '23505',
  'duplicate (run_id, job_name) is rejected'
);

-- Status check constraint — invalid status should fail
SELECT throws_ok(
  $$INSERT INTO ci_runtime_log (workflow_name, job_name, duration_seconds, status)
    VALUES ('pr-gate', 'test', 30, 'invalid_status')$$,
  '23514',
  'invalid status value is rejected'
);

-- Negative duration should fail
SELECT throws_ok(
  $$INSERT INTO ci_runtime_log (workflow_name, job_name, duration_seconds, status)
    VALUES ('pr-gate', 'test', -1, 'success')$$,
  '23514',
  'negative duration_seconds is rejected'
);

SELECT * FROM finish();
ROLLBACK;

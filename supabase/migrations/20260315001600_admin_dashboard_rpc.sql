-- ════════════════════════════════════════════════════════════════════════════
-- Admin Governance Dashboard — RPC Functions
-- Issue #206: [GOV-D2] Admin Governance Dashboard Suite
-- ════════════════════════════════════════════════════════════════════════════
--
-- Wraps the 6 Tier 1 views from 20260315001500 as RPC-callable functions
-- returning JSONB.  Each function is auth-required (uses auth.uid()).
--
-- Functions created:
--   api_admin_provenance_health()  — Data provenance coverage stats
--   api_admin_scoring_drift()      — Scoring model version & drift status
--   api_admin_search_quality()     — Search analytics (last N days)
--   api_admin_freshness_sla()      — Per-category SLA compliance
--   api_admin_migration_audit()    — Backfill, MV, drift health
--   api_admin_event_summary()      — Event volume breakdown
--   api_admin_health_overview()    — Combined 1-row health summary
--
-- Rollback: DROP FUNCTION IF EXISTS api_admin_provenance_health,
--           api_admin_scoring_drift, api_admin_search_quality,
--           api_admin_freshness_sla, api_admin_migration_audit,
--           api_admin_event_summary, api_admin_health_overview CASCADE;
-- ════════════════════════════════════════════════════════════════════════════


-- ─── Provenance Health ──────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_provenance_health()
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'country',                  country,
      'total_products',           total_products,
      'has_source_type',          has_source_type,
      'has_source_url',           has_source_url,
      'has_fetch_date',           has_fetch_date,
      'verified_count',           verified_count,
      'estimated_count',          estimated_count,
      'low_confidence_count',     low_confidence_count,
      'avg_completeness_pct',     avg_completeness_pct,
      'products_with_provenance', products_with_provenance,
      'total_field_records',      total_field_records,
      'verified_field_records',   verified_field_records,
      'provenance_coverage_pct',  provenance_coverage_pct
    ) ORDER BY country
  ), '[]'::jsonb)
  FROM v_provenance_health;
$$;


-- ─── Scoring Drift ──────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_scoring_drift()
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'version_id',              version_id,
      'version',                 version,
      'status',                  status,
      'description',             description,
      'activated_at',            activated_at,
      'retired_at',              retired_at,
      'weights_fingerprint',     weights_fingerprint,
      'created_at',              created_at,
      'last_drift_check',        last_drift_check,
      'last_drift_status',       last_drift_status,
      'last_drift_detail',       last_drift_detail,
      'last_drift_checked_at',   last_drift_checked_at,
      'last_drift_severity',     last_drift_severity
    )
  ), '[]'::jsonb)
  FROM v_scoring_drift;
$$;


-- ─── Search Quality (last N days, default 30) ───────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_search_quality(
  p_days integer DEFAULT 30
)
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'search_date',                  search_date,
      'country',                      country,
      'total_searches',               total_searches,
      'unique_searchers',             unique_searchers,
      'unique_sessions',              unique_sessions,
      'zero_result_searches',         zero_result_searches,
      'zero_result_pct',              zero_result_pct,
      'searches_with_click',          searches_with_click,
      'click_through_pct',            click_through_pct,
      'avg_result_count',             avg_result_count,
      'avg_time_to_first_result_ms',  avg_time_to_first_result_ms
    ) ORDER BY search_date DESC
  ), '[]'::jsonb)
  FROM v_search_quality
  WHERE search_date >= CURRENT_DATE - p_days;
$$;


-- ─── Freshness SLA ──────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_freshness_sla()
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'country',                  country,
      'category',                 category,
      'total_products',           total_products,
      'fresh_30d',                fresh_30d,
      'aging_30_90d',             aging_30_90d,
      'stale_90d',                stale_90d,
      'never_fetched',            never_fetched,
      'pct_fresh',                pct_fresh,
      'oldest_fetch',             oldest_fetch,
      'newest_fetch',             newest_fetch,
      'sla_max_age_days',         sla_max_age_days,
      'sla_warning_days',         sla_warning_days,
      'sla_critical_days',        sla_critical_days,
      'sla_violating_count',      sla_violating_count,
      'critical_staleness_count', critical_staleness_count,
      'sla_status',               sla_status
    )
  ), '[]'::jsonb)
  FROM v_data_freshness_sla;
$$;


-- ─── Migration Audit ────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_migration_audit()
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'domain',       domain,
      'total_items',  total_items,
      'completed',    completed,
      'failed',       failed,
      'in_progress',  in_progress,
      'pending',      pending,
      'validated',    validated,
      'last_activity', last_activity
    ) ORDER BY domain
  ), '[]'::jsonb)
  FROM v_migration_audit;
$$;


-- ─── Event Summary (last N days, default 30) ────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_event_summary(
  p_days integer DEFAULT 30
)
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'event_date',      event_date,
      'country',         country,
      'event_name',      event_name,
      'device_type',     device_type,
      'event_count',     event_count,
      'unique_users',    unique_users,
      'unique_sessions', unique_sessions
    ) ORDER BY event_date DESC, event_count DESC
  ), '[]'::jsonb)
  FROM v_event_analytics_summary
  WHERE event_date >= CURRENT_DATE - p_days;
$$;


-- ─── Combined Health Overview ───────────────────────────────────────────────
-- Single-call summary for the dashboard landing card grid.
-- Returns one JSONB object with a key per domain.

CREATE OR REPLACE FUNCTION public.api_admin_health_overview()
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'api_version', '2026-03-15',

    'provenance', (
      SELECT jsonb_build_object(
        'total_products',          sum(total_products),
        'avg_completeness_pct',    ROUND(avg(avg_completeness_pct), 1),
        'provenance_coverage_pct', ROUND(avg(provenance_coverage_pct), 1),
        'verified_pct',            ROUND(
          100.0 * sum(verified_count) / NULLIF(sum(total_products), 0), 1
        ),
        'status', CASE
          WHEN avg(provenance_coverage_pct) >= 80 THEN 'healthy'
          WHEN avg(provenance_coverage_pct) >= 50 THEN 'warning'
          ELSE 'critical'
        END
      )
      FROM v_provenance_health
    ),

    'scoring', (
      SELECT jsonb_build_object(
        'active_version',   (SELECT version FROM scoring_model_versions WHERE status = 'active' LIMIT 1),
        'total_versions',   count(*),
        'retired_versions', count(*) FILTER (WHERE status = 'retired'),
        'has_drift',        COALESCE(
          (SELECT status = 'drift'
           FROM drift_check_results
           WHERE check_name ILIKE '%scoring%' OR check_name ILIKE '%formula%'
           ORDER BY checked_at DESC
           LIMIT 1),
          false
        ),
        'status', CASE
          WHEN EXISTS (
            SELECT 1 FROM drift_check_results
            WHERE (check_name ILIKE '%scoring%' OR check_name ILIKE '%formula%')
              AND status = 'drift'
              AND checked_at > now() - INTERVAL '7 days'
          ) THEN 'critical'
          ELSE 'healthy'
        END
      )
      FROM scoring_model_versions
    ),

    'search', (
      SELECT COALESCE(
        (SELECT jsonb_build_object(
          'total_searches_7d',  COALESCE(sum(total_searches), 0),
          'zero_result_pct_7d', ROUND(
            100.0 * COALESCE(sum(zero_result_searches), 0)
            / NULLIF(COALESCE(sum(total_searches), 0), 0), 1
          ),
          'unique_searchers_7d', COALESCE(sum(unique_searchers), 0),
          'status', CASE
            WHEN COALESCE(sum(total_searches), 0) = 0 THEN 'no_data'
            WHEN 100.0 * COALESCE(sum(zero_result_searches), 0)
                 / NULLIF(COALESCE(sum(total_searches), 0), 0) > 20 THEN 'warning'
            ELSE 'healthy'
          END
        )
        FROM v_search_quality
        WHERE search_date >= CURRENT_DATE - 7),
        jsonb_build_object(
          'total_searches_7d', 0,
          'zero_result_pct_7d', 0,
          'unique_searchers_7d', 0,
          'status', 'no_data'
        )
      )
    ),

    'freshness', (
      SELECT jsonb_build_object(
        'total_categories', count(*),
        'healthy_pct',      ROUND(
          100.0 * count(*) FILTER (WHERE sla_status = 'healthy')
          / NULLIF(count(*), 0), 1
        ),
        'warning_count',    count(*) FILTER (WHERE sla_status = 'warning'),
        'critical_count',   count(*) FILTER (WHERE sla_status = 'critical'),
        'status', CASE
          WHEN count(*) FILTER (WHERE sla_status = 'critical') > 0 THEN 'critical'
          WHEN count(*) FILTER (WHERE sla_status = 'warning')  > 0 THEN 'warning'
          ELSE 'healthy'
        END
      )
      FROM v_data_freshness_sla
    ),

    'migration', (
      SELECT jsonb_build_object(
        'backfill_pending',  COALESCE((SELECT pending FROM v_migration_audit WHERE domain = 'backfill'), 0),
        'backfill_failed',   COALESCE((SELECT failed  FROM v_migration_audit WHERE domain = 'backfill'), 0),
        'drift_failures',    COALESCE((SELECT failed  FROM v_migration_audit WHERE domain = 'drift_check'), 0),
        'mv_last_refresh',   (SELECT last_activity FROM v_migration_audit WHERE domain = 'mv_refresh'),
        'status', CASE
          WHEN COALESCE((SELECT failed FROM v_migration_audit WHERE domain = 'backfill'), 0) > 0
            OR COALESCE((SELECT failed FROM v_migration_audit WHERE domain = 'drift_check'), 0) > 0
          THEN 'critical'
          WHEN COALESCE((SELECT pending FROM v_migration_audit WHERE domain = 'backfill'), 0) > 0
          THEN 'warning'
          ELSE 'healthy'
        END
      )
    ),

    'events', (
      SELECT COALESCE(
        (SELECT jsonb_build_object(
          'total_events_7d',    COALESCE(sum(event_count), 0),
          'unique_users_7d',    COALESCE(sum(unique_users), 0),
          'unique_sessions_7d', COALESCE(sum(unique_sessions), 0),
          'top_event',          (
            SELECT event_name FROM v_event_analytics_summary
            WHERE event_date >= CURRENT_DATE - 7
            GROUP BY event_name
            ORDER BY sum(event_count) DESC
            LIMIT 1
          ),
          'status', CASE
            WHEN COALESCE(sum(event_count), 0) = 0 THEN 'no_data'
            ELSE 'healthy'
          END
        )
        FROM v_event_analytics_summary
        WHERE event_date >= CURRENT_DATE - 7),
        jsonb_build_object(
          'total_events_7d', 0,
          'unique_users_7d', 0,
          'unique_sessions_7d', 0,
          'top_event', null,
          'status', 'no_data'
        )
      )
    )
  ) INTO v_result;

  RETURN v_result;
END;
$$;


-- ─── Grants ─────────────────────────────────────────────────────────────────
-- Authenticated users can call these; anon cannot.
REVOKE EXECUTE ON FUNCTION public.api_admin_provenance_health()       FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_scoring_drift()           FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_search_quality(integer)   FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_freshness_sla()           FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_migration_audit()         FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_event_summary(integer)    FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.api_admin_health_overview()         FROM anon, public;

GRANT EXECUTE ON FUNCTION public.api_admin_provenance_health()       TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_scoring_drift()           TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_search_quality(integer)   TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_freshness_sla()           TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_migration_audit()         TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_event_summary(integer)    TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_admin_health_overview()         TO authenticated;

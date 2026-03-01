-- ════════════════════════════════════════════════════════════════════════════
-- Admin Governance Dashboard — Tier 1 SQL Views
-- Issue #206: [GOV-D2] Admin Governance Dashboard Suite
-- ════════════════════════════════════════════════════════════════════════════
--
-- Creates 6 read-only views that surface operational health metrics for the
-- admin governance dashboard.  These are the "Minimal tier" from #206 —
-- no UI, queryable via Supabase Studio or RPC wrappers.
--
-- Views created:
--   1. v_provenance_health       — Data source coverage & field provenance stats
--   2. v_scoring_drift           — Scoring model version status & drift summary
--   3. v_search_quality          — Search event analytics & zero-result rate
--   4. v_data_freshness_sla      — Per-category freshness vs SLA thresholds
--   5. v_migration_audit         — Backfill status, MV refresh health, drift checks
--   6. v_event_analytics_summary — Top events, device breakdown, daily volume
--
-- Rollback: DROP VIEW IF EXISTS v_provenance_health, v_scoring_drift,
--           v_search_quality, v_data_freshness_sla, v_migration_audit,
--           v_event_analytics_summary CASCADE;
-- ════════════════════════════════════════════════════════════════════════════

-- ─── 1. Provenance Health ───────────────────────────────────────────────────
-- Summarises data source coverage and field-level provenance tracking.
-- One row per country with aggregate stats.

CREATE OR REPLACE VIEW public.v_provenance_health AS
SELECT
  p.country,
  count(*)                                                              AS total_products,
  count(*) FILTER (WHERE p.source_type IS NOT NULL)                     AS has_source_type,
  count(*) FILTER (WHERE p.source_url  IS NOT NULL)                     AS has_source_url,
  count(*) FILTER (WHERE p.last_fetched_at IS NOT NULL)                 AS has_fetch_date,
  count(*) FILTER (WHERE p.confidence = 'verified')                     AS verified_count,
  count(*) FILTER (WHERE p.confidence = 'estimated')                    AS estimated_count,
  count(*) FILTER (WHERE p.confidence = 'low')                          AS low_confidence_count,
  ROUND(avg(p.data_completeness_pct), 1)                                AS avg_completeness_pct,
  -- Field-level provenance coverage (from product_field_provenance)
  COALESCE(prov.products_with_provenance, 0)                            AS products_with_provenance,
  COALESCE(prov.total_field_records, 0)                                 AS total_field_records,
  COALESCE(prov.verified_field_records, 0)                              AS verified_field_records,
  ROUND(
    100.0 * COALESCE(prov.products_with_provenance, 0)
    / NULLIF(count(*), 0), 1
  )                                                                     AS provenance_coverage_pct
FROM public.products p
LEFT JOIN LATERAL (
  SELECT
    count(DISTINCT pfp.product_id) AS products_with_provenance,
    count(*)                       AS total_field_records,
    count(*) FILTER (WHERE pfp.verified_at IS NOT NULL) AS verified_field_records
  FROM public.product_field_provenance pfp
  WHERE pfp.product_id IN (
    SELECT p2.product_id FROM public.products p2
    WHERE p2.country = p.country AND p2.is_deprecated IS NOT TRUE
  )
) prov ON true
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country, prov.products_with_provenance, prov.total_field_records,
         prov.verified_field_records
ORDER BY p.country;


-- ─── 2. Scoring Drift ──────────────────────────────────────────────────────
-- Shows all scoring model versions with their status and the most recent
-- drift check results.

CREATE OR REPLACE VIEW public.v_scoring_drift AS
SELECT
  smv.id                      AS version_id,
  smv.version,
  smv.status,
  smv.description,
  smv.activated_at,
  smv.retired_at,
  smv.weights_fingerprint,
  smv.created_at,
  -- Most recent drift check result
  latest_drift.check_name     AS last_drift_check,
  latest_drift.status         AS last_drift_status,
  latest_drift.detail         AS last_drift_detail,
  latest_drift.checked_at     AS last_drift_checked_at,
  latest_drift.severity       AS last_drift_severity
FROM public.scoring_model_versions smv
LEFT JOIN LATERAL (
  SELECT dcr.check_name, dcr.status, dcr.detail, dcr.checked_at, dcr.severity
  FROM public.drift_check_results dcr
  WHERE dcr.check_name ILIKE '%scoring%' OR dcr.check_name ILIKE '%formula%'
  ORDER BY dcr.checked_at DESC
  LIMIT 1
) latest_drift ON true
ORDER BY
  CASE smv.status
    WHEN 'active'  THEN 1
    WHEN 'shadow'  THEN 2
    WHEN 'draft'   THEN 3
    WHEN 'retired' THEN 4
    ELSE 5
  END,
  smv.created_at DESC;


-- ─── 3. Search Quality ─────────────────────────────────────────────────────
-- Aggregates search performance metrics from analytics_events.
-- Groups by day and country for trend analysis.

CREATE OR REPLACE VIEW public.v_search_quality AS
SELECT
  DATE_TRUNC('day', ae.created_at)::date                                  AS search_date,
  ae.country,
  count(*)                                                                AS total_searches,
  count(DISTINCT ae.user_id)                                              AS unique_searchers,
  count(DISTINCT ae.session_id)                                           AS unique_sessions,
  count(*) FILTER (
    WHERE (ae.event_data ->> 'result_count')::int = 0
  )                                                                       AS zero_result_searches,
  ROUND(
    100.0 * count(*) FILTER (
      WHERE (ae.event_data ->> 'result_count')::int = 0
    ) / NULLIF(count(*), 0), 1
  )                                                                       AS zero_result_pct,
  count(*) FILTER (
    WHERE ae.event_data ->> 'clicked_product_id' IS NOT NULL
  )                                                                       AS searches_with_click,
  ROUND(
    100.0 * count(*) FILTER (
      WHERE ae.event_data ->> 'clicked_product_id' IS NOT NULL
    ) / NULLIF(count(*), 0), 1
  )                                                                       AS click_through_pct,
  ROUND(avg((ae.event_data ->> 'result_count')::numeric), 1)              AS avg_result_count,
  ROUND(avg(
    (ae.event_data ->> 'time_to_first_result_ms')::numeric
  ) FILTER (
    WHERE ae.event_data ->> 'time_to_first_result_ms' IS NOT NULL
  ), 0)                                                                   AS avg_time_to_first_result_ms
FROM public.analytics_events ae
WHERE ae.event_name = 'search_performed'
GROUP BY 1, 2
ORDER BY search_date DESC, ae.country;


-- ─── 4. Data Freshness SLA ─────────────────────────────────────────────────
-- Extends v_data_freshness_summary with SLA threshold evaluation from
-- freshness_policies.  Each row shows whether a category meets its SLA.

CREATE OR REPLACE VIEW public.v_data_freshness_sla AS
SELECT
  fs.country,
  fs.category,
  fs.total_products,
  fs.fresh_30d,
  fs.aging_30_90d,
  fs.stale_90d,
  fs.never_fetched,
  fs.pct_fresh,
  fs.oldest_fetch,
  fs.newest_fetch,
  -- SLA thresholds from freshness_policies (field_group = 'nutrition' as default)
  fp.max_age_days                                                         AS sla_max_age_days,
  fp.warning_age_days                                                     AS sla_warning_days,
  fp.critical_age_days                                                    AS sla_critical_days,
  -- Products violating SLA
  count(*) FILTER (
    WHERE p.last_fetched_at < now() - (COALESCE(fp.max_age_days, 90) || ' days')::interval
  )                                                                       AS sla_violating_count,
  count(*) FILTER (
    WHERE p.last_fetched_at IS NOT NULL
      AND p.last_fetched_at < now() - (COALESCE(fp.critical_age_days, 180) || ' days')::interval
  )                                                                       AS critical_staleness_count,
  -- SLA status
  CASE
    WHEN fs.pct_fresh >= 90 THEN 'healthy'
    WHEN fs.pct_fresh >= 70 THEN 'warning'
    ELSE 'critical'
  END                                                                     AS sla_status
FROM public.v_data_freshness_summary fs
LEFT JOIN public.freshness_policies fp
  ON fp.country = fs.country AND fp.field_group = 'nutrition'
LEFT JOIN public.products p
  ON p.country = fs.country AND p.category = fs.category
  AND p.is_deprecated IS NOT TRUE
GROUP BY
  fs.country, fs.category, fs.total_products, fs.fresh_30d,
  fs.aging_30_90d, fs.stale_90d, fs.never_fetched, fs.pct_fresh,
  fs.oldest_fetch, fs.newest_fetch,
  fp.max_age_days, fp.warning_age_days, fp.critical_age_days
ORDER BY
  CASE
    WHEN fs.pct_fresh >= 90 THEN 3
    WHEN fs.pct_fresh >= 70 THEN 2
    ELSE 1
  END,
  fs.pct_fresh NULLS LAST,
  fs.country, fs.category;


-- ─── 5. Migration Audit ────────────────────────────────────────────────────
-- Combines backfill registry status, MV refresh health, and drift check
-- results into a single operational health view.

CREATE OR REPLACE VIEW public.v_migration_audit AS
WITH backfill_summary AS (
  SELECT
    'backfill'                                                            AS domain,
    count(*)                                                              AS total_items,
    count(*) FILTER (WHERE br.status = 'completed')                       AS completed,
    count(*) FILTER (WHERE br.status = 'failed')                          AS failed,
    count(*) FILTER (WHERE br.status = 'running')                         AS in_progress,
    count(*) FILTER (WHERE br.status = 'pending')                         AS pending,
    count(*) FILTER (WHERE br.validation_passed IS TRUE)                  AS validated,
    max(br.completed_at)                                                  AS last_activity
  FROM public.backfill_registry br
),
mv_summary AS (
  SELECT
    'mv_refresh'                                                          AS domain,
    count(DISTINCT mrl.mv_name)                                           AS total_items,
    count(*)                                                              AS completed,
    0                                                                     AS failed,
    0                                                                     AS in_progress,
    0                                                                     AS pending,
    count(*)                                                              AS validated,
    max(mrl.refreshed_at)                                                 AS last_activity
  FROM public.mv_refresh_log mrl
),
drift_summary AS (
  SELECT
    'drift_check'                                                         AS domain,
    count(DISTINCT dcr.check_name)                                        AS total_items,
    count(*) FILTER (WHERE dcr.status = 'pass')                           AS completed,
    count(*) FILTER (WHERE dcr.status = 'drift')                          AS failed,
    0                                                                     AS in_progress,
    count(*) FILTER (WHERE dcr.status = 'skip')                           AS pending,
    count(*) FILTER (WHERE dcr.status = 'pass')                           AS validated,
    max(dcr.checked_at)                                                   AS last_activity
  FROM public.drift_check_results dcr
  WHERE dcr.checked_at = (
    SELECT max(d2.checked_at) FROM public.drift_check_results d2
    WHERE d2.run_id = dcr.run_id
  )
)
SELECT * FROM backfill_summary
UNION ALL
SELECT * FROM mv_summary
UNION ALL
SELECT * FROM drift_summary
ORDER BY domain;


-- ─── 6. Event Analytics Summary ────────────────────────────────────────────
-- Daily event volume by event type and device, for dashboard charts.

CREATE OR REPLACE VIEW public.v_event_analytics_summary AS
SELECT
  DATE_TRUNC('day', ae.created_at)::date                                  AS event_date,
  ae.country,
  ae.event_name,
  ae.device_type,
  count(*)                                                                AS event_count,
  count(DISTINCT ae.user_id)                                              AS unique_users,
  count(DISTINCT ae.session_id)                                           AS unique_sessions
FROM public.analytics_events ae
GROUP BY 1, 2, 3, 4
ORDER BY event_date DESC, event_count DESC;


-- ─── RLS ────────────────────────────────────────────────────────────────────
-- Dashboard views are read-only and use SECURITY INVOKER (default).
-- No RLS needed on views themselves — they inherit RLS from underlying tables.
-- Admin frontend will restrict access via middleware + RLS on the base tables.

-- ─── Grants ─────────────────────────────────────────────────────────────────
-- Authenticated users can read dashboard views (admin check in app layer).
GRANT SELECT ON public.v_provenance_health       TO authenticated;
GRANT SELECT ON public.v_scoring_drift           TO authenticated;
GRANT SELECT ON public.v_search_quality          TO authenticated;
GRANT SELECT ON public.v_data_freshness_sla      TO authenticated;
GRANT SELECT ON public.v_migration_audit         TO authenticated;
GRANT SELECT ON public.v_event_analytics_summary TO authenticated;

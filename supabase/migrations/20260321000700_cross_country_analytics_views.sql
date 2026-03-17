-- Migration: Cross-country scan and submission analytics views
-- Issue: #932
-- Rollback: DROP VIEW IF EXISTS v_cross_country_scan_analytics, v_cross_country_ean_candidates, v_submission_country_analytics;
-- Idempotency: CREATE OR REPLACE VIEW

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Per-country scan metrics
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW public.v_cross_country_scan_analytics AS
SELECT
  scan_country,
  count(*)                                        AS total_scans,
  count(*) FILTER (WHERE found = true)            AS found_scans,
  count(*) FILTER (WHERE found = false)           AS missed_scans,
  round(100.0 * count(*) FILTER (WHERE found = false)
    / NULLIF(count(*), 0), 1)                     AS miss_rate_pct,
  count(DISTINCT ean)                             AS unique_eans_scanned,
  count(DISTINCT ean) FILTER (WHERE found = false) AS unique_eans_missed
FROM public.scan_history
WHERE scan_country IS NOT NULL
GROUP BY scan_country;

COMMENT ON VIEW public.v_cross_country_scan_analytics IS
  'Per-country scan metrics: total, found, missed, miss rate, unique EANs. Excludes rows with NULL scan_country. Issue #932.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Cross-country EAN candidates (scanned in >1 country)
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW public.v_cross_country_ean_candidates AS
SELECT
  ean,
  array_agg(DISTINCT scan_country ORDER BY scan_country) AS scanned_in_countries,
  count(DISTINCT scan_country)                           AS country_count,
  min(scanned_at)                                        AS first_scanned,
  max(scanned_at)                                        AS last_scanned,
  count(*)                                               AS total_scans
FROM public.scan_history
WHERE scan_country IS NOT NULL
  AND ean IS NOT NULL
GROUP BY ean
HAVING count(DISTINCT scan_country) > 1
ORDER BY total_scans DESC;

COMMENT ON VIEW public.v_cross_country_ean_candidates IS
  'EANs scanned in more than one country — candidates for product_links. Excludes NULL scan_country/ean. Issue #932.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Per-country submission metrics
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW public.v_submission_country_analytics AS
SELECT
  suggested_country,
  count(*)                                                     AS total_submissions,
  count(*) FILTER (WHERE status = 'pending')                   AS pending,
  count(*) FILTER (WHERE status = 'approved')                  AS approved,
  count(*) FILTER (WHERE status = 'rejected')                  AS rejected,
  count(*) FILTER (WHERE status = 'merged')                    AS merged,
  round(100.0 * count(*) FILTER (WHERE status = 'approved' OR status = 'merged')
    / NULLIF(count(*), 0), 1)                                  AS acceptance_rate_pct
FROM public.product_submissions
WHERE suggested_country IS NOT NULL
GROUP BY suggested_country;

COMMENT ON VIEW public.v_submission_country_analytics IS
  'Per-country submission metrics: total, by status, acceptance rate. Excludes rows with NULL suggested_country. Issue #932.';

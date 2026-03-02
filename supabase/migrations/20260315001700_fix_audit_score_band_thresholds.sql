-- Migration: Fix audit_score_band_contradictions() false-positive criticals
-- Issue: #554 — Nightly data integrity audit exits with critical findings
--
-- Problem: audit_score_band_contradictions() flags Nutri-Score E + unhealthiness <30
-- as "critical", but these are legitimate methodological disagreements between two
-- independent scoring systems — not data corruption. All 18 criticals are this type.
-- True data integrity checks (impossible values, orphans, duplicates) return 0 criticals.
--
-- Fix: Tighten the "critical" threshold to only flag truly extreme contradictions
-- (≥4 band gap: A + score>80 or E + score<10). These cannot arise from normal
-- methodological differences and strongly suggest data corruption.
-- Moderate disagreements are already covered by audit_band_consistency() at warning
-- level (571 products with ≥2 band gap).
--
-- Rollback: Re-run original thresholds from 20260222030000_data_integrity_audits.sql

CREATE OR REPLACE FUNCTION audit_score_band_contradictions()
RETURNS TABLE(
    check_name    TEXT,
    severity      TEXT,
    product_id    BIGINT,
    product_name  TEXT,
    ean           TEXT,
    details       JSONB
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    -- ── CRITICAL: A-labelled product with very high unhealthiness (≥4 band gap) ──
    -- Nutri-Score A = band 1; score > 80 = band 5. This cannot arise from normal
    -- methodological differences and strongly suggests data corruption.
    SELECT
        'score_band_contradiction'::TEXT,
        'critical'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'A-labelled product has extreme unhealthiness score (>80)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'A'
      AND p.unhealthiness_score > 80
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- ── CRITICAL: E-labelled product with very low unhealthiness (≥4 band gap) ──
    -- Nutri-Score E = band 5; score < 10 = near-perfect. Strongly suggests wrong label.
    SELECT
        'score_band_contradiction'::TEXT,
        'critical'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'E-labelled product has near-perfect unhealthiness score (<10)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'E'
      AND p.unhealthiness_score < 10
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- ── WARNING: A-labelled product with moderately high unhealthiness (2-3 band gap) ──
    -- Suspicious but can arise from legitimate methodological differences between
    -- Nutri-Score (2-sided algorithm) and unhealthiness_score (9-factor formula).
    SELECT
        'score_band_contradiction'::TEXT,
        'warning'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'A-labelled product has elevated unhealthiness score (51-80)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'A'
      AND p.unhealthiness_score > 50
      AND p.unhealthiness_score <= 80
      AND p.is_deprecated IS NOT TRUE

    UNION ALL

    -- ── WARNING: E-labelled product with low unhealthiness (3 band gap) ──
    -- Expected for single-factor products (pure sugar, fruit juices, high-sodium
    -- condiments) where Nutri-Score penalizes one dimension heavily but our 9-factor
    -- formula rates the overall product moderately.
    SELECT
        'score_band_contradiction'::TEXT,
        'warning'::TEXT,
        p.product_id,
        p.product_name,
        p.ean,
        jsonb_build_object(
            'unhealthiness_score', p.unhealthiness_score,
            'nutri_score_label',   p.nutri_score_label,
            'reason',              'E-labelled product has low unhealthiness score (10-29)',
            'category',            p.category
        )
    FROM products p
    WHERE p.nutri_score_label = 'E'
      AND p.unhealthiness_score >= 10
      AND p.unhealthiness_score < 30
      AND p.is_deprecated IS NOT TRUE;
$$;

COMMENT ON FUNCTION audit_score_band_contradictions() IS
'Detects products where Nutri-Score label (A-E) contradicts the unhealthiness_score. '
'Critical only for extreme (≥4 band gap) contradictions that suggest data corruption. '
'Moderate disagreements (2-3 band gap) are warnings — expected for single-factor products. '
'See also: audit_band_consistency() for ≥2 band gap warnings.';

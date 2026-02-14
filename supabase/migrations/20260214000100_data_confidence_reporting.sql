-- ─── Data Confidence Reporting Views ─────────────────────────────────────────
-- Adds two reporting views for monitoring data completeness and confidence
-- distribution across countries and categories.
--
-- These views support Phase 4 — Data Confidence Upgrade by making gaps
-- visible and trackable over time.

-- ─── 1. Completeness summary by country ─────────────────────────────────────

CREATE OR REPLACE VIEW v_completeness_by_country AS
SELECT
    p.country,
    COUNT(*)                                                      AS total_products,
    ROUND(AVG(p.data_completeness_pct), 1)                        AS avg_completeness_pct,
    COUNT(*) FILTER (WHERE p.confidence = 'verified')             AS verified_count,
    COUNT(*) FILTER (WHERE p.confidence = 'estimated')            AS estimated_count,
    COUNT(*) FILTER (WHERE p.confidence = 'low')                  AS low_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.confidence = 'verified')
          / NULLIF(COUNT(*), 0), 1)                               AS pct_verified,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.confidence = 'low')
          / NULLIF(COUNT(*), 0), 1)                               AS pct_low,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
    ))                                                            AS missing_ingredients,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = p.product_id
    ))                                                            AS missing_allergens
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country
ORDER BY p.country;

-- ─── 2. Confidence distribution by country ──────────────────────────────────

CREATE OR REPLACE VIEW v_confidence_distribution AS
SELECT
    p.country,
    p.confidence                                                  AS confidence_level,
    COUNT(*)                                                      AS product_count,
    ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (PARTITION BY p.country), 0), 1)
                                                                  AS pct_of_country,
    ROUND(AVG(p.data_completeness_pct), 1)                        AS avg_completeness_pct,
    MIN(p.data_completeness_pct)                                  AS min_completeness_pct,
    MAX(p.data_completeness_pct)                                  AS max_completeness_pct
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country, p.confidence
ORDER BY p.country, CASE p.confidence
    WHEN 'verified'  THEN 1
    WHEN 'estimated' THEN 2
    WHEN 'low'       THEN 3
    ELSE 4
END;

-- ─── 3. Data gap summary by category ────────────────────────────────────────

CREATE OR REPLACE VIEW v_data_gap_summary AS
SELECT
    p.country,
    p.category,
    COUNT(*)                                                      AS total_products,
    ROUND(AVG(p.data_completeness_pct), 1)                        AS avg_completeness_pct,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
    ))                                                            AS missing_ingredients,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = p.product_id
    ))                                                            AS missing_allergens,
    COUNT(*) FILTER (WHERE p.confidence = 'low')                  AS low_confidence_count,
    COUNT(*) FILTER (WHERE p.nutri_score_label IN ('UNKNOWN', 'NOT-APPLICABLE')
                     OR p.nutri_score_label IS NULL)               AS missing_nutri_score,
    COUNT(*) FILTER (WHERE p.nova_classification IS NULL)          AS missing_nova
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country, p.category
ORDER BY p.country, p.category;

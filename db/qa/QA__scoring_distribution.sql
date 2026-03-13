-- ═══════════════════════════════════════════════════════════════════════════
-- QA Suite: Scoring Band Distribution Monitoring
-- 12 checks — verifies scoring band health at scale
-- Non-blocking (informational) — thresholds will be calibrated at 10K scale
-- Issue: #865
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══ 1. No single band holds >40% of ALL products (per country) ═══════════

SELECT
    'BAND_CONCENTRATION' AS issue,
    country || ': ' || band || ' has ' || pct || '% of all products' AS detail
FROM (
    SELECT
        country,
        band,
        ROUND(SUM(product_count)::numeric
              / SUM(SUM(product_count)) OVER (PARTITION BY country) * 100, 1) AS pct
    FROM mv_scoring_distribution
    GROUP BY country, band
) sub
WHERE pct > 40;

-- ═══ 2. No band has 0 products per country ════════════════════════════════

SELECT
    'EMPTY_BAND' AS issue,
    cr.country_code || ': band ' || b.band || ' has 0 products' AS detail
FROM country_ref cr
CROSS JOIN (VALUES ('Green'), ('Yellow'), ('Orange'), ('Red'), ('Dark Red')) AS b(band)
WHERE cr.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM mv_scoring_distribution sd
    WHERE sd.country = cr.country_code AND sd.band = b.band
  )
  -- Only flag if the country has scored products at all
  AND EXISTS (
    SELECT 1 FROM products p
    WHERE p.country = cr.country_code
      AND p.is_deprecated IS NOT TRUE
      AND p.unhealthiness_score IS NOT NULL
  );

-- ═══ 3. Per-category stddev >= 3 (formula differentiates within category) ═

SELECT
    'LOW_STDDEV' AS issue,
    country || '/' || category || ' stddev=' || cat_stddev || ' (too uniform)' AS detail
FROM (
    SELECT
        country,
        category,
        ROUND(STDDEV_POP(unhealthiness_score)::numeric, 1) AS cat_stddev,
        COUNT(*) AS cnt
    FROM products
    WHERE is_deprecated IS NOT TRUE
      AND unhealthiness_score IS NOT NULL
    GROUP BY country, category
) sub
WHERE cnt >= 5  -- skip categories with insufficient sample size
  AND cat_stddev < 3;

-- ═══ 4. PL vs DE overall distribution divergence <15% per band ════════════

SELECT
    'COUNTRY_DIVERGENCE' AS issue,
    band || ': PL=' || pl_pct || '% vs DE=' || de_pct || '% (delta=' || ABS(pl_pct - de_pct) || '%)' AS detail
FROM (
    SELECT
        band,
        COALESCE(SUM(CASE WHEN country = 'PL' THEN product_count END), 0)
          ::numeric
          / NULLIF(SUM(CASE WHEN country = 'PL' THEN 1 END)
                   * SUM(CASE WHEN country = 'PL' THEN product_count END), 0)
          AS pl_raw,
        COALESCE(SUM(CASE WHEN country = 'DE' THEN product_count END), 0)
          ::numeric AS de_raw
    FROM mv_scoring_distribution
    GROUP BY band
) raw,
LATERAL (
    SELECT
        ROUND(SUM(CASE WHEN sd.country = 'PL' THEN sd.product_count ELSE 0 END)::numeric
              / NULLIF((SELECT SUM(product_count) FROM mv_scoring_distribution WHERE country = 'PL'), 0) * 100, 1) AS pl_pct,
        ROUND(SUM(CASE WHEN sd.country = 'DE' THEN sd.product_count ELSE 0 END)::numeric
              / NULLIF((SELECT SUM(product_count) FROM mv_scoring_distribution WHERE country = 'DE'), 0) * 100, 1) AS de_pct
    FROM mv_scoring_distribution sd
    WHERE sd.band = raw.band
) pcts
WHERE pl_pct IS NOT NULL
  AND de_pct IS NOT NULL
  AND ABS(pl_pct - de_pct) > 15;

-- ═══ 5. Green band (1-20) has at least 10% of products per country ════════

SELECT
    'GREEN_UNDERREPRESENTED' AS issue,
    country || ': Green band has only ' || pct || '% (minimum 10%)' AS detail
FROM (
    SELECT
        sd.country,
        ROUND(SUM(CASE WHEN sd.band = 'Green' THEN sd.product_count ELSE 0 END)::numeric
              / NULLIF(SUM(sd.product_count), 0) * 100, 1) AS pct
    FROM mv_scoring_distribution sd
    GROUP BY sd.country
) sub
WHERE pct < 10;

-- ═══ 6. Dark Red band (81-100) has fewer than 20% of products ═════════════

SELECT
    'DARK_RED_OVERREPRESENTED' AS issue,
    country || ': Dark Red band has ' || pct || '% (maximum 20%)' AS detail
FROM (
    SELECT
        sd.country,
        ROUND(SUM(CASE WHEN sd.band = 'Dark Red' THEN sd.product_count ELSE 0 END)::numeric
              / NULLIF(SUM(sd.product_count), 0) * 100, 1) AS pct
    FROM mv_scoring_distribution sd
    GROUP BY sd.country
) sub
WHERE pct > 20;

-- ═══ 7. Median unhealthiness score between 20 and 60 (not skewed) ═════════

SELECT
    'SKEWED_MEDIAN' AS issue,
    country || ': median unhealthiness=' || med || ' (expected 20-60)' AS detail
FROM (
    SELECT
        country,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unhealthiness_score)::integer AS med
    FROM products
    WHERE is_deprecated IS NOT TRUE
      AND unhealthiness_score IS NOT NULL
    GROUP BY country
) sub
WHERE med < 20 OR med > 60;

-- ═══ 8. No category has >70% of products in a single band ════════════════

SELECT
    'CATEGORY_BAND_DOMINANCE' AS issue,
    country || '/' || category || ': ' || band || ' has ' || pct_of_category || '%' AS detail
FROM mv_scoring_distribution
WHERE pct_of_category > 70
  AND product_count >= 5;  -- minimum sample

-- ═══ 9. At least 3 of 5 bands populated per category ═════════════════════

SELECT
    'TOO_FEW_BANDS' AS issue,
    country || '/' || category || ': only ' || band_count || ' of 5 bands populated' AS detail
FROM (
    SELECT
        country,
        category,
        COUNT(DISTINCT band) AS band_count,
        SUM(product_count)   AS total
    FROM mv_scoring_distribution
    GROUP BY country, category
) sub
WHERE band_count < 3
  AND total >= 10;  -- skip tiny categories

-- ═══ 10. Score range per category spans at least 20 points ════════════════

SELECT
    'NARROW_SCORE_RANGE' AS issue,
    country || '/' || category || ': range=' || score_range || ' points (minimum 20)' AS detail
FROM (
    SELECT
        country,
        category,
        MAX(unhealthiness_score) - MIN(unhealthiness_score) AS score_range,
        COUNT(*) AS cnt
    FROM products
    WHERE is_deprecated IS NOT TRUE
      AND unhealthiness_score IS NOT NULL
    GROUP BY country, category
) sub
WHERE cnt >= 10  -- sufficient sample
  AND score_range < 20;

-- ═══ 11. Top 5 categories (by product count) have >=4 bands each ══════════

SELECT
    'TOP_CATEGORY_FEW_BANDS' AS issue,
    country || '/' || category || ': only ' || band_count || ' bands (top-5 category, expect >=4)' AS detail
FROM (
    SELECT
        sd.country,
        sd.category,
        COUNT(DISTINCT sd.band)  AS band_count,
        SUM(sd.product_count)    AS total,
        RANK() OVER (PARTITION BY sd.country ORDER BY SUM(sd.product_count) DESC) AS rnk
    FROM mv_scoring_distribution sd
    GROUP BY sd.country, sd.category
) sub
WHERE rnk <= 5
  AND band_count < 4;

-- ═══ 12. New products (last 7 days) don't cluster >60% in one band ═══════

SELECT
    'NEW_PRODUCT_CLUSTERING' AS issue,
    country || ': ' || pct || '% of new products in ' || band || ' band' AS detail
FROM (
    SELECT
        country,
        CASE
          WHEN unhealthiness_score BETWEEN  1 AND 20 THEN 'Green'
          WHEN unhealthiness_score BETWEEN 21 AND 40 THEN 'Yellow'
          WHEN unhealthiness_score BETWEEN 41 AND 60 THEN 'Orange'
          WHEN unhealthiness_score BETWEEN 61 AND 80 THEN 'Red'
          WHEN unhealthiness_score BETWEEN 81 AND 100 THEN 'Dark Red'
        END AS band,
        COUNT(*) AS cnt,
        ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER (PARTITION BY country) * 100, 1) AS pct
    FROM products
    WHERE is_deprecated IS NOT TRUE
      AND unhealthiness_score IS NOT NULL
      AND last_fetched_at >= NOW() - INTERVAL '7 days'
    GROUP BY country, band
) sub
WHERE pct > 60
  AND cnt >= 3;  -- need at least 3 new products to be meaningful

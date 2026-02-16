-- ============================================================
-- QA: Data Confidence Reporting
-- Validates the Phase 4 reporting views and enforces guardrails
-- on overall data quality thresholds.
-- All checks enforce zero violations (blocking).
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. v_completeness_by_country covers every active country WITH products
--    Countries that are active but have no products yet are excluded;
--    those will appear once data pipelines populate them.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. completeness view covers all active countries' AS check_name,
       COUNT(*) AS violations
FROM country_ref cr
WHERE cr.is_active IS TRUE
  AND EXISTS (
    SELECT 1 FROM products p WHERE p.country = cr.country_code AND p.is_deprecated IS NOT TRUE
  )
  AND NOT EXISTS (
    SELECT 1 FROM v_completeness_by_country vc WHERE vc.country = cr.country_code
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. v_completeness_by_country total matches active products per country
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. completeness view counts match active products' AS check_name,
       COUNT(*) AS violations
FROM v_completeness_by_country vc
WHERE vc.total_products != (
    SELECT COUNT(*) FROM products p
    WHERE p.country = vc.country AND p.is_deprecated IS NOT TRUE
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. v_confidence_distribution covers every active country WITH products
--    Countries that are active but have no products yet are excluded.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. confidence distribution covers all active countries' AS check_name,
       COUNT(*) AS violations
FROM country_ref cr
WHERE cr.is_active IS TRUE
  AND EXISTS (
    SELECT 1 FROM products p WHERE p.country = cr.country_code AND p.is_deprecated IS NOT TRUE
  )
  AND NOT EXISTS (
    SELECT 1 FROM v_confidence_distribution cd WHERE cd.country = cr.country_code
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. v_confidence_distribution percentages sum to 100 per country
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. confidence distribution pct sums to 100 per country' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT country, SUM(pct_of_country) AS total_pct
    FROM v_confidence_distribution
    GROUP BY country
    HAVING ABS(SUM(pct_of_country) - 100.0) > 0.5  -- allow rounding tolerance
) x;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. v_data_gap_summary covers every active (country, category) combo
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. gap summary covers all active country-category combos' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT DISTINCT p.country, p.category
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM v_data_gap_summary dgs
    WHERE dgs.country  = expected.country
      AND dgs.category = expected.category
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. No country has >20% low-confidence products (assign_confidence level)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. no country exceeds 20% low confidence' AS check_name,
       COUNT(*) AS violations
FROM v_completeness_by_country
WHERE pct_low > 20;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Average completeness >= 60% per country
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. avg completeness >= 60% per country' AS check_name,
       COUNT(*) AS violations
FROM v_completeness_by_country
WHERE avg_completeness_pct < 60;

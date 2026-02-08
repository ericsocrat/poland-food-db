-- QA: Source coverage & cross-validation checks
-- Run after pipelines to identify products that need additional source verification.
-- Goal: Every product should be traceable to ≥ 2 independent sources.
-- Zero rows in checks 1–4 = pass.  Check 5–7 are informational.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Products with NO source row at all
-- ═══════════════════════════════════════════════════════════════════════════
-- These products have no provenance trail — highest priority to fix.
SELECT p.product_id, p.brand, p.product_name, p.category,
       'NO SOURCE ROW' AS issue,
       'Add a sources entry documenting where this data came from' AS action
FROM products p
LEFT JOIN sources s ON s.brand = p.brand
WHERE s.source_id IS NULL
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand, p.product_name;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Brands sourced ONLY from Open Food Facts (single-source risk)
-- ═══════════════════════════════════════════════════════════════════════════
-- These brands have no label, manufacturer, or government cross-validation.
-- Priority: cross-check against manufacturer PL website or IŻŻ reference ranges.
SELECT s.brand,
       COUNT(DISTINCT s.source_id) AS source_count,
       STRING_AGG(DISTINCT s.source_type, ', ') AS source_types,
       'SINGLE SOURCE: openfoodfacts only' AS issue,
       'Cross-validate against manufacturer website or IŻŻ tables' AS action
FROM sources s
WHERE s.brand IS NOT NULL
GROUP BY s.brand
HAVING COUNT(DISTINCT s.source_type) = 1
   AND MAX(s.source_type) = 'openfoodfacts'
ORDER BY s.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Brands with no 'verified' primary source (label or manufacturer)
-- ═══════════════════════════════════════════════════════════════════════════
-- These brands rely on secondary sources only. Flag for label verification.
SELECT s.brand,
       STRING_AGG(DISTINCT s.source_type, ', ') AS source_types,
       'NO PRIMARY SOURCE' AS issue,
       'Needs label photo or manufacturer website verification' AS action
FROM sources s
WHERE s.brand IS NOT NULL
GROUP BY s.brand
HAVING SUM(CASE WHEN s.source_type IN ('label', 'manufacturer') THEN 1 ELSE 0 END) = 0
ORDER BY s.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Products with 'estimated' confidence but no comment explaining why
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name, p.category,
       sc.confidence,
       'ESTIMATED CONFIDENCE — verify source coverage' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE sc.confidence = 'estimated'
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Source coverage summary by category (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.category,
       COUNT(DISTINCT p.product_id) AS product_count,
       COUNT(DISTINCT s.source_id) AS source_entries,
       STRING_AGG(DISTINCT s.source_type, ', ' ORDER BY s.source_type) AS source_types_used,
       ROUND(
         COUNT(DISTINCT s.source_id)::numeric / NULLIF(COUNT(DISTINCT p.product_id), 0),
         2
       ) AS sources_per_product_avg
FROM products p
LEFT JOIN sources s ON s.brand = p.brand
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.category
ORDER BY sources_per_product_avg ASC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Source type distribution (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT s.source_type,
       COUNT(*) AS entry_count,
       COUNT(DISTINCT s.brand) AS brands_covered,
       COUNT(DISTINCT s.url) FILTER (WHERE s.url IS NOT NULL) AS entries_with_url
FROM sources s
GROUP BY s.source_type
ORDER BY entry_count DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Cross-validation candidates: products to prioritise for fact-checking
-- ═══════════════════════════════════════════════════════════════════════════
-- High-impact products (common brands) that currently have single-source data.
-- Prioritise these for manufacturer website or label verification.
SELECT p.product_id, p.brand, p.product_name, p.category,
       sc.unhealthiness_score,
       sc.confidence,
       CASE p.availability
         WHEN 'widespread' THEN 1
         WHEN 'common'     THEN 2
         WHEN 'regional'   THEN 3
         ELSE 4
       END AS priority_rank,
       'HIGH-IMPACT SINGLE-SOURCE — prioritise for cross-validation' AS action
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
LEFT JOIN sources s ON s.brand = p.brand
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.product_id, p.brand, p.product_name, p.category,
         p.availability, sc.unhealthiness_score, sc.confidence
HAVING COUNT(DISTINCT s.source_type) <= 1
ORDER BY priority_rank ASC, p.category, p.brand;

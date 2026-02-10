-- QA: Source coverage & cross-validation checks (product-level provenance)
-- Run after pipelines to identify products that need additional source verification.
-- Goal: Every product should be traceable to ≥ 2 independent sources.
-- Uses product_sources table (product-level) instead of legacy sources table (category-level).
-- All 8 checks are informational (non-blocking). Blocking provenance checks are in QA__null_checks 33-35.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Products with NO product_sources row at all
-- ═══════════════════════════════════════════════════════════════════════════
-- These products have no provenance trail — highest priority to fix.
SELECT p.product_id, p.brand, p.product_name, p.category,
       'NO PRODUCT SOURCE ROW' AS issue,
       'Add a product_sources entry documenting where this data came from' AS action
FROM products p
LEFT JOIN product_sources ps ON ps.product_id = p.product_id
WHERE ps.product_source_id IS NULL
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand, p.product_name;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Products sourced ONLY from OFF API (single-source risk)
-- ═══════════════════════════════════════════════════════════════════════════
-- These products have no label, manufacturer, or retailer cross-validation.
-- Priority: cross-check against manufacturer PL website or IŻŻ reference ranges.
SELECT p.product_id, p.brand, p.product_name, p.category,
       COUNT(ps.product_source_id) AS source_count,
       STRING_AGG(DISTINCT ps.source_type, ', ') AS source_types,
       'SINGLE SOURCE: off_api only' AS issue,
       'Cross-validate against manufacturer website or product label' AS action
FROM products p
JOIN product_sources ps ON ps.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.product_id, p.brand, p.product_name, p.category
HAVING COUNT(DISTINCT ps.source_type) = 1
   AND MAX(ps.source_type) = 'off_api'
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Products with no verified primary source (label or manufacturer)
-- ═══════════════════════════════════════════════════════════════════════════
-- Products relying on OFF API or manual only. Flag for label verification.
SELECT p.product_id, p.brand, p.product_name, p.category,
       STRING_AGG(DISTINCT ps.source_type, ', ') AS source_types,
       'NO LABEL/RETAILER SOURCE' AS issue,
       'Needs label photo or manufacturer website verification' AS action
FROM products p
JOIN product_sources ps ON ps.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.product_id, p.brand, p.product_name, p.category
HAVING SUM(CASE WHEN ps.source_type IN ('label_scan', 'retailer_api') THEN 1 ELSE 0 END) = 0
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Products with 'estimated' confidence but no comment explaining why
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name, p.category,
       sc.confidence,
       ps.confidence_pct AS source_confidence,
       'ESTIMATED CONFIDENCE — verify source coverage' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
LEFT JOIN product_sources ps ON ps.product_id = p.product_id AND ps.is_primary = true
WHERE sc.confidence = 'estimated'
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Source coverage summary by category (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.category,
       COUNT(DISTINCT p.product_id) AS product_count,
       COUNT(ps.product_source_id) AS source_entries,
       STRING_AGG(DISTINCT ps.source_type, ', ' ORDER BY ps.source_type) AS source_types_used,
       ROUND(
         COUNT(ps.product_source_id)::numeric / NULLIF(COUNT(DISTINCT p.product_id), 0),
         2
       ) AS sources_per_product_avg,
       ROUND(AVG(ps.confidence_pct), 0) AS avg_confidence_pct
FROM products p
LEFT JOIN product_sources ps ON ps.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.category
ORDER BY sources_per_product_avg ASC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Source type distribution (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT ps.source_type,
       COUNT(*) AS entry_count,
       COUNT(DISTINCT p.brand) AS brands_covered,
       COUNT(DISTINCT ps.source_url) FILTER (WHERE ps.source_url IS NOT NULL) AS entries_with_url,
       ROUND(AVG(ps.confidence_pct), 0) AS avg_confidence
FROM product_sources ps
JOIN products p ON p.product_id = ps.product_id
GROUP BY ps.source_type
ORDER BY entry_count DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Cross-validation candidates: products to prioritise for fact-checking
-- ═══════════════════════════════════════════════════════════════════════════
-- High-impact products (score > 40) with single-source data.
-- Prioritise these for manufacturer website or label verification.
SELECT p.product_id, p.brand, p.product_name, p.category,
       sc.unhealthiness_score,
       sc.confidence,
       ps.source_type AS primary_source,
       ps.confidence_pct AS source_confidence,
       'HIGH-IMPACT SINGLE-SOURCE — prioritise for cross-validation' AS action
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
LEFT JOIN product_sources ps ON ps.product_id = p.product_id AND ps.is_primary = true
WHERE p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score > 40
GROUP BY p.product_id, p.brand, p.product_name, p.category,
         sc.unhealthiness_score, sc.confidence, ps.source_type, ps.confidence_pct
HAVING COUNT(DISTINCT ps.source_type) <= 1
ORDER BY sc.unhealthiness_score DESC, p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Ingredients raw text coverage by category (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.category,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE i.ingredients_raw IS NOT NULL AND i.ingredients_raw != '') AS has_ingredients,
       ROUND(100.0 * COUNT(*) FILTER (WHERE i.ingredients_raw IS NOT NULL AND i.ingredients_raw != '') / COUNT(*), 0) AS pct
FROM products p
JOIN ingredients i ON i.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.category
ORDER BY pct ASC, p.category;

-- QA: Source coverage & cross-validation checks (product-level provenance)
-- Run after pipelines to identify products that need additional source verification.
-- Goal: Every product should be traceable to a verified source.
-- Uses source_type / source_url / source_ean columns on products table.
-- All checks are informational (non-blocking).
-- Updated: product_sources table merged into products; scores merged into products.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Products with NO source_type at all
-- ═══════════════════════════════════════════════════════════════════════════
-- These products have no provenance trail — highest priority to fix.
SELECT p.product_id, p.brand, p.product_name, p.category,
       'NO SOURCE TYPE' AS issue,
       'Set source_type to document where this data came from' AS action
FROM products p
WHERE p.source_type IS NULL
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand, p.product_name;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Products sourced ONLY from OFF API (single-source risk)
-- ═══════════════════════════════════════════════════════════════════════════
-- These products have no label, manufacturer, or retailer cross-validation.
-- Priority: cross-check against manufacturer PL website or IŻŻ reference ranges.
SELECT p.product_id, p.brand, p.product_name, p.category,
       p.source_type,
       'SINGLE SOURCE: off_api only' AS issue,
       'Cross-validate against manufacturer website or product label' AS action
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.source_type = 'off_api'
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Products with no verified primary source (label or manufacturer)
-- ═══════════════════════════════════════════════════════════════════════════
-- Products relying on OFF API or manual only. Flag for label verification.
SELECT p.product_id, p.brand, p.product_name, p.category,
       p.source_type,
       'NO LABEL/RETAILER SOURCE' AS issue,
       'Needs label photo or manufacturer website verification' AS action
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.source_type IS NOT NULL
  AND p.source_type NOT IN ('label_scan', 'retailer_api')
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Products with 'estimated' confidence — verify source coverage
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name, p.category,
       p.confidence,
       p.source_type,
       'ESTIMATED CONFIDENCE — verify source coverage' AS issue
FROM products p
WHERE p.confidence = 'estimated'
  AND p.is_deprecated IS NOT TRUE
ORDER BY p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Source coverage summary by category (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.category,
       COUNT(*) AS product_count,
       COUNT(p.source_type) AS with_source,
       STRING_AGG(DISTINCT p.source_type, ', ' ORDER BY p.source_type) AS source_types_used,
       ROUND(
         COUNT(p.source_type)::numeric / NULLIF(COUNT(*), 0),
         2
       ) AS source_coverage_pct
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.category
ORDER BY source_coverage_pct ASC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Source type distribution (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.source_type,
       COUNT(*) AS product_count,
       COUNT(DISTINCT p.brand) AS brands_covered,
       COUNT(p.source_url) FILTER (WHERE p.source_url IS NOT NULL) AS products_with_url
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.source_type IS NOT NULL
GROUP BY p.source_type
ORDER BY product_count DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Cross-validation candidates: products to prioritise for fact-checking
-- ═══════════════════════════════════════════════════════════════════════════
-- High-impact products (score > 40) with off_api-only data.
-- Prioritise these for manufacturer website or label verification.
SELECT p.product_id, p.brand, p.product_name, p.category,
       p.unhealthiness_score,
       p.confidence,
       p.source_type,
       'HIGH-IMPACT SINGLE-SOURCE — prioritise for cross-validation' AS action
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score > 40
  AND p.source_type = 'off_api'
ORDER BY p.unhealthiness_score DESC, p.category, p.brand;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Ingredient junction data coverage by category (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.category,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE pi_cnt > 0) AS has_ingredients,
       ROUND(100.0 * COUNT(*) FILTER (WHERE pi_cnt > 0) / COUNT(*), 0) AS pct
FROM products p
LEFT JOIN (
    SELECT product_id, COUNT(*) AS pi_cnt FROM product_ingredient GROUP BY product_id
) pi ON pi.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.category
ORDER BY pct ASC, p.category;

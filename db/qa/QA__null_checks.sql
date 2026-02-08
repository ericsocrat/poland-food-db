-- QA: null checks
-- Run after pipelines to detect missing or incomplete data.
-- Each query returns rows that need attention. Zero rows = pass.

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Products missing required fields
-- ═══════════════════════════════════════════════════════════════════════════
SELECT product_id, country, brand, product_name,
       'MISSING REQUIRED FIELD' AS issue,
       CASE
         WHEN country IS NULL      THEN 'country is NULL'
         WHEN brand IS NULL        THEN 'brand is NULL'
         WHEN product_name IS NULL THEN 'product_name is NULL'
         WHEN category IS NULL     THEN 'category is NULL'
       END AS detail
FROM products
WHERE country IS NULL
   OR brand IS NULL
   OR product_name IS NULL
   OR category IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Products with no serving row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'NO SERVING ROW' AS issue
FROM products p
LEFT JOIN servings sv ON sv.product_id = p.product_id
WHERE sv.serving_id IS NULL
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Products with no nutrition facts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'NO NUTRITION FACTS' AS issue
FROM products p
LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE nf.product_id IS NULL
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Products with no score row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'NO SCORE ROW' AS issue
FROM products p
LEFT JOIN scores sc ON sc.product_id = p.product_id
WHERE sc.product_id IS NULL
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Nutrition facts with all-NULL core fields (EU mandatory 7)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT nf.product_id, p.brand, p.product_name,
       'ALL CORE NUTRITION NULL' AS issue
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
WHERE nf.calories IS NULL
  AND nf.total_fat_g IS NULL
  AND nf.saturated_fat_g IS NULL
  AND nf.carbs_g IS NULL
  AND nf.sugars_g IS NULL
  AND nf.protein_g IS NULL
  AND nf.salt_g IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Scores missing unhealthiness_score
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id, p.brand, p.product_name,
       'UNHEALTHINESS SCORE NULL' AS issue
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE sc.unhealthiness_score IS NULL
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Scores missing scoring_version
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id, p.brand, p.product_name,
       'SCORING VERSION NULL' AS issue,
       sc.unhealthiness_score
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE sc.scoring_version IS NULL
  AND sc.unhealthiness_score IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Orphaned servings (no matching product)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sv.serving_id, sv.product_id,
       'ORPHANED SERVING' AS issue
FROM servings sv
LEFT JOIN products p ON p.product_id = sv.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Orphaned nutrition_facts (no matching product)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT nf.product_id, nf.serving_id,
       'ORPHANED NUTRITION FACT' AS issue
FROM nutrition_facts nf
LEFT JOIN products p ON p.product_id = nf.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Duplicate products (same country+brand+name — should be impossible)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT country, brand, product_name,
       COUNT(*) AS duplicate_count,
       'DUPLICATE PRODUCT' AS issue
FROM products
GROUP BY country, brand, product_name
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Products with country other than PL (scope violation)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT product_id, country, brand, product_name,
       'NON-PL COUNTRY' AS issue
FROM products
WHERE country != 'PL'
  AND is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Summary counts (informational, not a failure check)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
    (SELECT COUNT(*) FROM products)         AS total_products,
    (SELECT COUNT(*) FROM products WHERE is_deprecated = true) AS deprecated_products,
    (SELECT COUNT(*) FROM servings)         AS total_servings,
    (SELECT COUNT(*) FROM nutrition_facts)  AS total_nutrition_rows,
    (SELECT COUNT(*) FROM scores)           AS total_score_rows,
    (SELECT COUNT(*) FROM ingredients)      AS total_ingredient_rows,
    (SELECT COUNT(*) FROM sources)          AS total_source_rows;

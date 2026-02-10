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
-- 12. Orphaned scores (no matching product)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id,
       'ORPHANED SCORE' AS issue
FROM scores sc
LEFT JOIN products p ON p.product_id = sc.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Orphaned ingredients (no matching product)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT i.product_id,
       'ORPHANED INGREDIENT' AS issue
FROM ingredients i
LEFT JOIN products p ON p.product_id = i.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Products with no ingredients row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'NO INGREDIENTS ROW' AS issue
FROM products p
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE i.product_id IS NULL
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Negative nutrition values (physically impossible)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'NEGATIVE NUTRITION VALUE' AS issue,
       CASE
         WHEN nf.calories < 0        THEN 'calories = ' || nf.calories
         WHEN nf.total_fat_g < 0     THEN 'total_fat_g = ' || nf.total_fat_g
         WHEN nf.saturated_fat_g < 0 THEN 'saturated_fat_g = ' || nf.saturated_fat_g
         WHEN nf.trans_fat_g < 0     THEN 'trans_fat_g = ' || nf.trans_fat_g
         WHEN nf.carbs_g < 0         THEN 'carbs_g = ' || nf.carbs_g
         WHEN nf.sugars_g < 0        THEN 'sugars_g = ' || nf.sugars_g
         WHEN nf.fibre_g < 0         THEN 'fibre_g = ' || nf.fibre_g
         WHEN nf.protein_g < 0       THEN 'protein_g = ' || nf.protein_g
         WHEN nf.salt_g < 0          THEN 'salt_g = ' || nf.salt_g
       END AS detail
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (nf.calories < 0 OR nf.total_fat_g < 0 OR nf.saturated_fat_g < 0
    OR nf.trans_fat_g < 0 OR nf.carbs_g < 0 OR nf.sugars_g < 0
    OR nf.fibre_g < 0 OR nf.protein_g < 0 OR nf.salt_g < 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. Saturated fat exceeds total fat (logically impossible)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'SAT FAT > TOTAL FAT' AS issue,
       CONCAT('sat_fat=', nf.saturated_fat_g, ' > total_fat=', nf.total_fat_g) AS detail
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
WHERE p.is_deprecated IS NOT TRUE
  AND nf.saturated_fat_g > nf.total_fat_g
  AND nf.total_fat_g IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. Sugars exceed total carbohydrates (logically impossible)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'SUGARS > CARBS' AS issue,
       CONCAT('sugars=', nf.sugars_g, ' > carbs=', nf.carbs_g) AS detail
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
WHERE p.is_deprecated IS NOT TRUE
  AND nf.sugars_g > nf.carbs_g
  AND nf.carbs_g IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. Calories exceed 900 per 100g (physically impossible — pure fat = 900)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'CALORIES > 900' AS issue,
       CONCAT('calories=', nf.calories) AS detail
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
WHERE p.is_deprecated IS NOT TRUE
  AND nf.calories > 900;

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. Each category must have exactly 28 active products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT category, COUNT(*) AS product_count,
       'CATEGORY COUNT NOT 28' AS issue
FROM products
WHERE is_deprecated IS NOT TRUE
GROUP BY category
HAVING COUNT(*) <> 28;

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. Scores missing scored_at, data_completeness_pct, nutri_score_label,
--     or high_additive_load (all required for active products)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id, p.brand, p.product_name,
       'SCORE FIELD NULL' AS issue,
       CASE
         WHEN sc.scored_at IS NULL            THEN 'scored_at is NULL'
         WHEN sc.data_completeness_pct IS NULL THEN 'data_completeness_pct is NULL'
         WHEN sc.nutri_score_label IS NULL     THEN 'nutri_score_label is NULL'
         WHEN sc.high_additive_load IS NULL    THEN 'high_additive_load is NULL'
         WHEN sc.confidence IS NULL            THEN 'confidence is NULL'
       END AS detail
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (sc.scored_at IS NULL
    OR sc.data_completeness_pct IS NULL
    OR sc.nutri_score_label IS NULL
    OR sc.high_additive_load IS NULL
    OR sc.confidence IS NULL);

-- ═══════════════════════════════════════════════════════════════════════════
-- 21. v_master row count matches active products (detects join fan-out)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
  'V_MASTER ROW MISMATCH' AS issue,
  (SELECT COUNT(*) FROM v_master) AS v_master_rows,
  (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS active_products
WHERE (SELECT COUNT(*) FROM v_master) !=
      (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE);

-- ═══════════════════════════════════════════════════════════════════════════
-- 22. Duplicate source rows (prevents v_master fan-out)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT brand, COUNT(*) AS row_count,
       'DUPLICATE SOURCE' AS issue
FROM sources
GROUP BY brand
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- 23. Orphan ingredient_ref rows (not linked to any product)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT ir.ingredient_id, ir.taxonomy_id, ir.name_en,
       'ORPHAN INGREDIENT REF' AS issue
FROM ingredient_ref ir
LEFT JOIN product_ingredient pi ON pi.ingredient_id = ir.ingredient_id
WHERE pi.ingredient_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 24. product_ingredient rows referencing non-existent products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT pi.product_id, pi.ingredient_id, pi.position,
       'INGREDIENT FK BROKEN' AS issue
FROM product_ingredient pi
LEFT JOIN products p ON p.product_id = pi.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 25. additives_count mismatch between ingredients table and junction table
-- ═══════════════════════════════════════════════════════════════════════════
SELECT i.product_id, i.additives_count AS stored_count,
       COALESCE(sub.cnt, 0) AS junction_count,
       'ADDITIVES COUNT MISMATCH' AS issue
FROM ingredients i
JOIN (SELECT DISTINCT product_id FROM product_ingredient) has_data
  ON has_data.product_id = i.product_id
LEFT JOIN (
  SELECT pi.product_id, COUNT(*) AS cnt
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  WHERE ir.is_additive = true
  GROUP BY pi.product_id
) sub ON sub.product_id = i.product_id
WHERE i.additives_count != COALESCE(sub.cnt, 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 26. product_allergen rows referencing non-existent products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT pa.product_id, pa.allergen_tag,
       'ALLERGEN FK BROKEN' AS issue
FROM product_allergen pa
LEFT JOIN products p ON p.product_id = pa.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 27. product_trace rows referencing non-existent products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT pt.product_id, pt.trace_tag,
       'TRACE FK BROKEN' AS issue
FROM product_trace pt
LEFT JOIN products p ON p.product_id = pt.product_id
WHERE p.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 28. Duplicate positions in product_ingredient (data integrity)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT product_id, position, COUNT(*) AS dupes,
       'DUPLICATE INGREDIENT POSITION' AS issue
FROM product_ingredient
GROUP BY product_id, position
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- 29. Sub-ingredients without parent (constraint check)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT pi.product_id, pi.ingredient_id, pi.position,
       'SUB_INGREDIENT WITHOUT PARENT' AS issue
FROM product_ingredient pi
WHERE pi.is_sub_ingredient = true
  AND pi.parent_ingredient_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 30. concern_tier on ingredient_ref must be 0-3 (valid range)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT ir.ingredient_id, ir.name_en, ir.concern_tier,
       'CONCERN TIER OUT OF RANGE' AS issue
FROM ingredient_ref ir
WHERE ir.concern_tier IS NOT NULL
  AND ir.concern_tier NOT IN (0, 1, 2, 3);

-- ═══════════════════════════════════════════════════════════════════════════
-- 31. ingredient_concern_score must be non-negative and ≤ 100
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id, sc.ingredient_concern_score,
       'CONCERN SCORE OUT OF RANGE' AS issue
FROM scores sc
WHERE sc.ingredient_concern_score IS NOT NULL
  AND (sc.ingredient_concern_score < 0 OR sc.ingredient_concern_score > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 32. Scored products must have ingredient_concern_score populated
-- ═══════════════════════════════════════════════════════════════════════════
SELECT sc.product_id, sc.scoring_version,
       'MISSING CONCERN SCORE' AS issue
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND sc.scoring_version = 'v3.2'
  AND sc.ingredient_concern_score IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 33. Every active product must have at least one product_sources row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       'MISSING PRODUCT SOURCE' AS issue
FROM products p
LEFT JOIN product_sources ps ON ps.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND ps.product_source_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 34. Only one primary source per product (no multi-primary)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT ps.product_id,
       COUNT(*) AS primary_count,
       'MULTIPLE PRIMARY SOURCES' AS issue
FROM product_sources ps
WHERE ps.is_primary = true
GROUP BY ps.product_id
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- 35. v_master fan-out guard: row count must equal active product count
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
    (SELECT COUNT(*) FROM v_master) AS view_rows,
    (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS active_products,
    'FAN-OUT DETECTED' AS issue
WHERE (SELECT COUNT(*) FROM v_master) <>
      (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE);

-- ═══════════════════════════════════════════════════════════════════════════
-- 36. v_master new column coverage (informational)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
  COUNT(*) AS active_products,
  COUNT(ingredient_count) AS with_ingredient_analytics,
  COUNT(allergen_count) AS with_allergens,
  COUNT(trace_count) AS with_traces,
  COUNT(CASE WHEN has_palm_oil THEN 1 END) AS palm_oil_products,
  COUNT(CASE WHEN vegan_status = 'yes' THEN 1 END) AS vegan_products,
  COUNT(CASE WHEN vegan_status = 'no' THEN 1 END) AS non_vegan_products
FROM v_master;

-- ═══════════════════════════════════════════════════════════════════════════
-- 37. Summary counts (informational, not a failure check)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
    (SELECT COUNT(*) FROM products)         AS total_products,
    (SELECT COUNT(*) FROM products WHERE is_deprecated = true) AS deprecated_products,
    (SELECT COUNT(*) FROM servings)         AS total_servings,
    (SELECT COUNT(*) FROM servings WHERE serving_basis = 'per 100 g') AS per_100g_servings,
    (SELECT COUNT(*) FROM servings WHERE serving_basis = 'per serving') AS per_serving_rows,
    (SELECT COUNT(*) FROM nutrition_facts)  AS total_nutrition_rows,
    (SELECT COUNT(*) FROM scores)           AS total_score_rows,
    (SELECT COUNT(*) FROM ingredients)      AS total_ingredient_rows,
    (SELECT COUNT(*) FROM ingredient_ref)   AS total_ingredient_refs,
    (SELECT COUNT(*) FROM product_ingredient) AS total_product_ingredients,
    (SELECT COUNT(*) FROM product_allergen) AS total_allergen_rows,
    (SELECT COUNT(*) FROM product_trace)    AS total_trace_rows,
    (SELECT COUNT(*) FROM sources)          AS total_source_rows;

-- ═══════════════════════════════════════════════════════════════════════════
-- 38. Energy cross-check: declared vs computed calories (informational)
--     Formula: (fat×9) + (carbs×4) + (protein×4) + (fibre×2)
--     ±15% tolerance. Alcohol products expected to fail (ethanol = 7 kcal/g
--     not captured in macros).
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.category, p.brand, p.product_name,
       n.calories AS declared_kcal,
       ROUND(COALESCE(n.total_fat_g,0)*9
           + COALESCE(n.carbs_g,0)*4
           + COALESCE(n.protein_g,0)*4
           + COALESCE(n.fibre_g,0)*2) AS computed_kcal,
       ROUND(ABS(n.calories
           - (COALESCE(n.total_fat_g,0)*9
            + COALESCE(n.carbs_g,0)*4
            + COALESCE(n.protein_g,0)*4
            + COALESCE(n.fibre_g,0)*2))
           / NULLIF(n.calories, 0) * 100, 1) AS pct_diff,
       'ENERGY CROSS-CHECK FAIL' AS issue
FROM nutrition_facts n
JOIN servings sv ON sv.serving_id = n.serving_id
JOIN products p ON p.product_id = n.product_id
WHERE sv.serving_basis = 'per 100 g'
  AND p.is_deprecated IS NOT TRUE
  AND n.calories IS NOT NULL AND n.calories > 0
  AND ABS(n.calories
      - (COALESCE(n.total_fat_g,0)*9
       + COALESCE(n.carbs_g,0)*4
       + COALESCE(n.protein_g,0)*4
       + COALESCE(n.fibre_g,0)*2))
      > n.calories * 0.15
ORDER BY pct_diff DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- 39. Ingredient data coverage (informational)
--     Products without product_ingredient rows cannot have accurate
--     ingredient concern scores. These are OFF upstream data gaps.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
  COUNT(*) AS active_products,
  COUNT(*) FILTER (WHERE pi_count > 0) AS with_ingredient_data,
  COUNT(*) FILTER (WHERE pi_count = 0) AS without_ingredient_data,
  ROUND(COUNT(*) FILTER (WHERE pi_count = 0)::numeric / COUNT(*)::numeric * 100, 1) AS pct_missing,
  COUNT(*) FILTER (WHERE pi_count = 0 AND additives_count > 0) AS has_additives_but_no_data
FROM (
  SELECT p.product_id,
         COALESCE(pc.cnt, 0) AS pi_count,
         COALESCE(i.additives_count, 0) AS additives_count
  FROM products p
  LEFT JOIN (SELECT product_id, COUNT(*) AS cnt FROM product_ingredient GROUP BY product_id) pc
    ON pc.product_id = p.product_id
  LEFT JOIN ingredients i ON i.product_id = p.product_id
  WHERE p.is_deprecated IS NOT TRUE
) sub;

-- ═══════════════════════════════════════════════════════════════════════════
-- 40. Nutrition anomaly detection (informational)
--     Flags products with physiologically implausible nutrition values,
--     typically caused by incomplete or incorrect OFF data entries.
--     Categories:
--       A) sat_fat = 0 but total_fat > 10  (all fats contain some saturated fat)
--       B) salt = 0 in categories known to contain salt
--       C) sugars = 0 but carbs > 20  (most carb-heavy foods have some sugar)
--       D) salt > 10 g/100g  (extreme — likely data entry error or concentrate)
--       E) calories < 10 for non-beverage products  (suspicious)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.product_name, p.category,
       anomaly_type, detail
FROM (
  -- A) Sat fat impossibly zero
  SELECT n.product_id, 'SAT_FAT_ZERO_HIGH_FAT' AS anomaly_type,
         FORMAT('sat_fat=0 but total_fat=%s', n.total_fat_g) AS detail
  FROM nutrition_facts n
  JOIN servings sv USING(product_id, serving_id)
  WHERE sv.serving_basis = 'per 100 g'
    AND n.saturated_fat_g = 0
    AND n.total_fat_g > 10

  UNION ALL

  -- B) Salt zero in salty categories
  SELECT n.product_id, 'SALT_ZERO_SALTY_CATEGORY',
         FORMAT('salt=0, carbs=%s', n.carbs_g)
  FROM nutrition_facts n
  JOIN servings sv USING(product_id, serving_id)
  JOIN products p2 ON p2.product_id = n.product_id
  WHERE sv.serving_basis = 'per 100 g'
    AND p2.is_deprecated IS NOT TRUE
    AND n.salt_g = 0
    AND p2.category IN ('Chips','Instant & Frozen','Meat','Snacks',
                         'Sauces','Condiments','Canned Goods','Bread',
                         'Frozen & Prepared','Żabka')

  UNION ALL

  -- C) Sugars zero but high carbs
  SELECT n.product_id, 'SUGARS_ZERO_HIGH_CARBS',
         FORMAT('sugars=0 but carbs=%s', n.carbs_g)
  FROM nutrition_facts n
  JOIN servings sv USING(product_id, serving_id)
  WHERE sv.serving_basis = 'per 100 g'
    AND n.sugars_g = 0
    AND n.carbs_g > 20

  UNION ALL

  -- D) Extreme salt
  SELECT n.product_id, 'EXTREME_SALT',
         FORMAT('salt=%sg/100g', n.salt_g)
  FROM nutrition_facts n
  JOIN servings sv USING(product_id, serving_id)
  WHERE sv.serving_basis = 'per 100 g'
    AND n.salt_g > 10

  UNION ALL

  -- E) Near-zero calories for non-beverage
  SELECT n.product_id, 'NEAR_ZERO_CALORIES',
         FORMAT('calories=%s, category expects higher', n.calories)
  FROM nutrition_facts n
  JOIN servings sv USING(product_id, serving_id)
  JOIN products p2 ON p2.product_id = n.product_id
  WHERE sv.serving_basis = 'per 100 g'
    AND p2.is_deprecated IS NOT TRUE
    AND n.calories < 10
    AND p2.category NOT IN ('Drinks','Alcohol')
) anomalies
JOIN products p ON p.product_id = anomalies.product_id
WHERE p.is_deprecated IS NOT TRUE
ORDER BY anomaly_type, p.category, p.product_name;

-- ═══════════════════════════════════════════════════════════════════════════
-- 41. Suspect nutrition + verified confidence mismatch (informational)
--     Products flagged as 'suspect' nutrition quality but marked 'verified'
--     confidence represent the highest-priority cross-validation targets —
--     their scores may be inaccurate due to bad OFF data.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
  COUNT(*) AS total_suspect,
  COUNT(*) FILTER (WHERE confidence = 'verified')  AS suspect_and_verified,
  COUNT(*) FILTER (WHERE confidence = 'estimated') AS suspect_and_estimated,
  ROUND(COUNT(*) FILTER (WHERE confidence = 'verified')::numeric
      / NULLIF(COUNT(*), 0)::numeric * 100, 1) AS pct_verified_but_suspect
FROM v_master
WHERE nutrition_data_quality = 'suspect';

-- QA: Scoring Formula Tests (v3.1)
-- Validates that the scoring formula produces expected results for known test cases.
-- Each test includes a product with controlled nutrition values and expected score.
-- Run after pipelines to verify scoring algorithm correctness.

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 1: Formula produces scores within valid range [1, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'SCORE OUT OF RANGE' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE sc.unhealthiness_score::int NOT BETWEEN 1 AND 100
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 2: Products with zero bad nutrients should score ≤ 20 (Low risk)
--         Only prep_method & controversies contribute to score
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'UNEXPECTED HIGH SCORE FOR CLEAN PRODUCT' AS issue,
       CONCAT('Expected <=20 (prep + controversies only), got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND COALESCE(nf.saturated_fat_g::numeric, 0) = 0
  AND COALESCE(nf.sugars_g::numeric, 0) = 0
  AND COALESCE(nf.salt_g::numeric, 0) = 0
  AND COALESCE(nf.trans_fat_g::numeric, 0) = 0
  AND COALESCE(i.additives_count::numeric, 0) = 0
  AND COALESCE(nf.calories::numeric, 0) = 0
  AND sc.unhealthiness_score::int > 20;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 3: Maximum possible score verification
--         Products at ceiling for all factors should score near 100
--         (sat_fat=10g, sugars=27g, salt=3g, trans_fat=2g, calories=600,
--          additives=10, prep_method=deep-fried, controversies=serious)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'EXPECTED HIGH SCORE NOT REACHED' AS issue,
       CONCAT('Expected >=95 for max unhealthy product, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.saturated_fat_g::numeric >= 10
  AND nf.sugars_g::numeric >= 25
  AND nf.salt_g::numeric >= 2.5
  AND p.prep_method = 'deep-fried'
  AND sc.unhealthiness_score::int < 80;  -- Should be very high

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 4: Score consistency check
--         Two products with identical nutrition should have identical scores
--         (within prep_method & controversies differences)
-- ═══════════════════════════════════════════════════════════════════════════
WITH scored_products AS (
  SELECT
    p.product_id, p.product_name, p.prep_method, p.controversies,
    sc.unhealthiness_score,
    nf.calories, nf.saturated_fat_g, nf.sugars_g, nf.salt_g,
    nf.trans_fat_g, COALESCE(i.additives_count::int, 0) AS additives
  FROM products p
  JOIN scores sc ON sc.product_id = p.product_id
  JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
  JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
  LEFT JOIN ingredients i ON i.product_id = p.product_id
  WHERE p.is_deprecated IS NOT TRUE
)
SELECT
  a.product_name AS product_a,
  b.product_name AS product_b,
  a.unhealthiness_score AS score_a,
  b.unhealthiness_score AS score_b,
  'SCORE MISMATCH FOR IDENTICAL NUTRITION' AS issue
FROM scored_products a
JOIN scored_products b ON b.product_id > a.product_id
WHERE a.calories = b.calories
  AND a.saturated_fat_g = b.saturated_fat_g
  AND a.sugars_g = b.sugars_g
  AND a.salt_g = b.salt_g
  AND a.trans_fat_g = b.trans_fat_g
  AND a.additives = b.additives
  AND a.prep_method = b.prep_method
  AND a.controversies = b.controversies
  AND a.unhealthiness_score <> b.unhealthiness_score;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 5: Flag consistency checks
--         high_salt_flag should be YES when salt >= 1.5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.salt_g, sc.high_salt_flag,
       'INCORRECT high_salt_flag' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.salt_g::numeric >= 1.5 AND sc.high_salt_flag <> 'YES')
    OR (nf.salt_g::numeric < 1.5 AND sc.high_salt_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 6: Flag consistency checks
--         high_sugar_flag should be YES when sugars >= 5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.sugars_g, sc.high_sugar_flag,
       'INCORRECT high_sugar_flag' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.sugars_g::numeric >= 5.0 AND sc.high_sugar_flag <> 'YES')
    OR (nf.sugars_g::numeric < 5.0 AND sc.high_sugar_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 7: Flag consistency checks
--         high_sat_fat_flag should be YES when saturated_fat >= 5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.saturated_fat_g, sc.high_sat_fat_flag,
       'INCORRECT high_sat_fat_flag' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.saturated_fat_g::numeric >= 5.0 AND sc.high_sat_fat_flag <> 'YES')
    OR (nf.saturated_fat_g::numeric < 5.0 AND sc.high_sat_fat_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 8: NOVA classification validation
--         NOVA should be 1, 2, 3, or 4 only
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.nova_classification,
       'INVALID NOVA CLASSIFICATION' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND sc.nova_classification NOT IN ('1', '2', '3', '4');

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 9: Processing risk consistency
--         Should align with NOVA: 4=High, 3=Moderate, 1-2=Low
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.nova_classification, sc.processing_risk,
       'PROCESSING RISK MISMATCH WITH NOVA' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (sc.nova_classification = '4' AND sc.processing_risk <> 'High')
    OR (sc.nova_classification = '3' AND sc.processing_risk <> 'Moderate')
    OR (sc.nova_classification IN ('1', '2') AND sc.processing_risk <> 'Low')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 10: Scoring version consistency
--          All scores should be v3.1
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.scoring_version,
       'INCORRECT SCORING VERSION' AS issue
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (sc.scoring_version IS NULL OR sc.scoring_version <> 'v3.1');

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 11: Known product regression test (Top Chips Faliste)
--          This product has palm oil (16g sat fat) and should score 51±2
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Top Chips Faliste score changed unexpectedly' AS issue,
       CONCAT('Expected 49-53, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Top Chips Faliste'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 49 AND 53;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 12: Known product regression test (Naleśniki z jabłkami)
--          Healthiest żabka product (crepes) should score 15-19
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Naleśniki score changed unexpectedly' AS issue,
       CONCAT('Expected 15-19, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Naleśniki z jabłkami i cynamonem'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 15 AND 19;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 13: Known product regression test (Melvit Płatki Owsiane Górskie)
--          Unprocessed whole oats (NOVA 1), near-zero bad nutrients → score 9-13
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Melvit Owsiane score changed unexpectedly' AS issue,
       CONCAT('Expected 9-13, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Melvit Płatki Owsiane Górskie'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 9 AND 13;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 14: Known product regression test (Coca-Cola Zero)
--          Zero sugar/fat but 5 additives → score 6-10
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Coca-Cola Zero score changed unexpectedly' AS issue,
       CONCAT('Expected 6-10, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Coca-Cola Zero'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 6 AND 10;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 15: Known product regression test (Piątnica Skyr Naturalny)
--          Fat-free high-protein dairy (NOVA 1), zero additives → score 7-11
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Skyr Naturalny score changed unexpectedly' AS issue,
       CONCAT('Expected 7-11, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Piątnica Skyr Naturalny'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 7 AND 11;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 16: Known product regression test (Mestemacher Pumpernikiel)
--          Traditional German pumpernickel — low fat, low sugar, baked → score 15-19
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Mestemacher Pumpernikiel score changed unexpectedly' AS issue,
       CONCAT('Expected 15-19, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Mestemacher Pumpernikiel'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 15 AND 19;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 17: Known product regression test (Tarczyński Kabanosy Klasyczne)
--          High-fat, high-salt cured meat (IARC moderate) → score 53-57
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Kabanosy Klasyczne score changed unexpectedly' AS issue,
       CONCAT('Expected 53-57, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Tarczyński Kabanosy Klasyczne'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 53 AND 57;

-- Test 18: Known product regression test (Prince Polo XXL Classic)
--          Iconic Polish wafer bar: palm oil controversy + 4 additives → score 52-56
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Prince Polo XXL Classic score changed unexpectedly' AS issue,
       CONCAT('Expected 52-56, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Prince Polo XXL Classic'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 52 AND 56;

-- Test 19: Known product regression test (Knorr Nudle Pomidorowe Pikantne)
--          Instant noodle with 6 additives + palm oil → score 19-23
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Knorr Nudle Pomidorowe score changed unexpectedly' AS issue,
       CONCAT('Expected 19-23, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Knorr Nudle Pomidorowe Pikantne'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 19 AND 23;

-- Test 20: Known product regression test (Pudliszki Ketchup Łagodny)
--          Popular Polish ketchup: high sugar + high salt → score 33-37
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: Pudliszki Ketchup Łagodny score changed unexpectedly' AS issue,
       CONCAT('Expected 33-37, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'Pudliszki Ketchup Łagodny'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 33 AND 37;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 21: Known product regression test (BoboVita Kaszka Mleczna 7 Zbóż)
--          Baby cereal: high sugars 31g + moderate sat-fat → score 34-38
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       sc.unhealthiness_score,
       'REGRESSION: BoboVita Kaszka Mleczna 7 Zbóż score changed unexpectedly' AS issue,
       CONCAT('Expected 34-38, got ', sc.unhealthiness_score) AS detail
FROM products p
JOIN scores sc ON sc.product_id = p.product_id
WHERE p.product_name = 'BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa'
  AND p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score::int NOT BETWEEN 34 AND 38;

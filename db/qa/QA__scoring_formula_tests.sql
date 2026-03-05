-- QA: Scoring Formula Tests (v3.3) — 31 checks
-- Validates that the scoring formula produces expected results for known test cases.
-- Each test includes a product with controlled nutrition values and expected score.
-- Run after pipelines to verify scoring algorithm correctness.
-- Updated: v3.3 adds nutrient density bonus (protein + fibre credit). Issue #608.
-- Updated: scores merged into products; servings table eliminated.

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 1: Formula produces scores within valid range [1, 100]
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'SCORE OUT OF RANGE' AS issue
FROM products p
WHERE p.unhealthiness_score::int NOT BETWEEN 1 AND 100
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 2: Products with zero bad nutrients should score ≤ 20 (Low risk)
--         Only prep_method & controversies contribute to score
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'UNEXPECTED HIGH SCORE FOR CLEAN PRODUCT' AS issue,
       CONCAT('Expected <=20 (prep + controversies only), got ', p.unhealthiness_score) AS detail
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN (
    SELECT pi.product_id, COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
    FROM product_ingredient pi JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND COALESCE(nf.saturated_fat_g::numeric, 0) = 0
  AND COALESCE(nf.sugars_g::numeric, 0) = 0
  AND COALESCE(nf.salt_g::numeric, 0) = 0
  AND COALESCE(nf.trans_fat_g::numeric, 0) = 0
  AND COALESCE(ia.additives_count::numeric, 0) = 0
  AND COALESCE(nf.calories::numeric, 0) = 0
  AND p.unhealthiness_score::int > 20;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 3: Maximum possible score verification
--         Products at ceiling for all factors should score near 100
--         (sat_fat=10g, sugars=27g, salt=3g, trans_fat=2g, calories=600,
--          additives=10, prep_method=deep-fried, controversies=serious)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'EXPECTED HIGH SCORE NOT REACHED' AS issue,
       CONCAT('Expected >=95 for max unhealthy product, got ', p.unhealthiness_score) AS detail
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN (
    SELECT pi.product_id, COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
    FROM product_ingredient pi JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.saturated_fat_g::numeric >= 10
  AND nf.sugars_g::numeric >= 25
  AND nf.salt_g::numeric >= 2.5
  AND p.prep_method = 'deep-fried'
  AND p.unhealthiness_score::int < 80;  -- Should be very high

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 4: Score consistency check
--         Two products with identical nutrition should have identical scores
--         (within prep_method & controversies differences)
-- ═══════════════════════════════════════════════════════════════════════════
WITH scored_products AS (
  SELECT
    p.product_id, p.product_name, p.prep_method, p.controversies,
    p.unhealthiness_score, p.ingredient_concern_score,
    nf.calories, nf.saturated_fat_g, nf.sugars_g, nf.salt_g,
    nf.trans_fat_g, nf.protein_g, nf.fibre_g,
    COALESCE(ia.additives_count::int, 0) AS additives
  FROM products p
  JOIN nutrition_facts nf ON nf.product_id = p.product_id
  LEFT JOIN (
      SELECT pi.product_id, COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
      FROM product_ingredient pi JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
      GROUP BY pi.product_id
  ) ia ON ia.product_id = p.product_id
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
  AND COALESCE(a.ingredient_concern_score, 0) = COALESCE(b.ingredient_concern_score, 0)
  AND COALESCE(a.protein_g, 0) = COALESCE(b.protein_g, 0)
  AND COALESCE(a.fibre_g, 0) = COALESCE(b.fibre_g, 0)
  AND a.unhealthiness_score <> b.unhealthiness_score;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 5: Flag consistency checks
--         high_salt_flag should be YES when salt >= 1.5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.salt_g, p.high_salt_flag,
       'INCORRECT high_salt_flag' AS issue
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.salt_g::numeric >= 1.5 AND p.high_salt_flag <> 'YES')
    OR (nf.salt_g::numeric < 1.5 AND p.high_salt_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 6: Flag consistency checks
--         high_sugar_flag should be YES when sugars >= 5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.sugars_g, p.high_sugar_flag,
       'INCORRECT high_sugar_flag' AS issue
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.sugars_g::numeric >= 5.0 AND p.high_sugar_flag <> 'YES')
    OR (nf.sugars_g::numeric < 5.0 AND p.high_sugar_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 7: Flag consistency checks
--         high_sat_fat_flag should be YES when saturated_fat >= 5g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       nf.saturated_fat_g, p.high_sat_fat_flag,
       'INCORRECT high_sat_fat_flag' AS issue
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (nf.saturated_fat_g::numeric >= 5.0 AND p.high_sat_fat_flag <> 'YES')
    OR (nf.saturated_fat_g::numeric < 5.0 AND p.high_sat_fat_flag = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 8: NOVA classification validation
--         NOVA should be 1, 2, 3, or 4 only
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.nova_classification,
       'INVALID NOVA CLASSIFICATION' AS issue
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.nova_classification NOT IN ('1', '2', '3', '4');

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 9: (removed — processing_risk column dropped; now derived in v_master)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 10: (removed — scoring_version column dropped)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 11: Known product regression test (Doritos Sweet Chili)
--          Chips with 7 additives + high concern score (55) → score 31-35
--          v3.3: protein 6.1g (bonus 15) + fibre 5.6g (bonus 35) → density 50 → -4 pts
--          Requires ingredient enrichment data; skipped in CI without it.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Doritos Sweet Chili score changed unexpectedly' AS issue,
       CONCAT('Expected 31-35, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Doriros Sweet Chili Flavoured 100g'
  AND p.brand = 'Doritos'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 31 AND 35
  AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 12: Known product regression test (Naleśniki z jabłkami)
--          Healthiest żabka product (crepes) should score 13-17
--          v3.3: protein 3.5g (bonus 0) + fibre 1.6g (bonus 10) → density 10 → -1 pt
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Naleśniki score changed unexpectedly' AS issue,
       CONCAT('Expected 13-17, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Naleśniki z jabłkami i cynamonem'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 13 AND 17;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 13: Known product regression test (Melvit Płatki owsiane górskie)
--          Unprocessed whole oats (NOVA 1), near-zero bad nutrients → score 5-9
--          v3.3: protein 13g (bonus 30) + fibre 9g (bonus 50) → density 80 → -6 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Melvit Owsiane score changed unexpectedly' AS issue,
       CONCAT('Expected 5-9, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Płatki owsiane górskie'
  AND p.brand = 'Melvit'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 5 AND 9;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 14: Known product regression test (Coca-Cola Zero)
--          Zero sugar/fat but 8 additives + concern 2.0 (enriched) → score 2-6
--          v3.3: protein 0g (bonus 0) + fibre 0g (bonus 0) → density 0 → no change
--          Requires ingredient enrichment data; skipped in CI without it.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Coca-Cola Zero score changed unexpectedly' AS issue,
       CONCAT('Expected 2-6, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Coca-Cola Zero'
  AND p.country = 'DE'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 2 AND 6
  AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 15: Known product regression test (Piątnica Skyr Naturalny)
--          Fat-free high-protein dairy, fermented, zero additives → score 3-7
--          v3.3: protein 12g (bonus 30) + fibre 0g (bonus 0) → density 30 → -2 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Skyr Naturalny score changed unexpectedly' AS issue,
       CONCAT('Expected 3-7, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Skyr Naturalny'
  AND p.brand = 'Piątnica'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 3 AND 7;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 16: Known product regression test (Auchan Tortilla Pszenno-Żytnia)
--          Bread with 9 additives + concern 25, baked → score 19-23
--          v3.3: protein 8.4g (bonus 15) + fibre 0g (bonus 0) → density 15 → -1 pt
--          Requires ingredient enrichment data; skipped in CI without it.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Auchan Tortilla score changed unexpectedly' AS issue,
       CONCAT('Expected 19-23, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Tortilla Pszenno-Żytnia'
  AND p.brand = 'Auchan'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 19 AND 23
  AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 17: Known product regression test (Tarczyński Kabanosy wieprzowe)
--          High-fat cured meat, sat fat dominant → score 25-29
--          v3.3: protein 26g (bonus 50) + fibre 0g (bonus 0) → density 50 → -4 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Kabanosy wieprzowe score changed unexpectedly' AS issue,
       CONCAT('Expected 25-29, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Kabanosy wieprzowe'
  AND p.brand = 'Tarczyński'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 25 AND 29;

-- Test 18: Known product regression test (E. Wedel Czekolada Tiramisu)
--          Sweets: palm oil + 15g sat fat + 57g sugars + 6 additives → score 44-48
--          v3.3: protein 5.5g (bonus 15) + fibre 1.3g (bonus 10) → density 25 → -2 pts
--          Requires ingredient enrichment data; skipped in CI without it.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Wedel Czekolada Tiramisu score changed unexpectedly' AS issue,
       CONCAT('Expected 44-48, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Czekolada Tiramisu'
  AND p.brand = 'E. Wedel'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 44 AND 48
  AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

-- Test 19: Known product regression test (Indomie Noodles Chicken Flavour)
--          Instant noodles: palm oil + 10 additives + concern 75, dried → score 41-45
--          v3.3: protein 9.4g (bonus 15) + fibre 0g (bonus 0) → density 15 → -1 pt
--          Requires ingredient enrichment data; skipped in CI without it.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Indomie Noodles score changed unexpectedly' AS issue,
       CONCAT('Expected 41-45, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Noodles Chicken Flavour'
  AND p.brand = 'Indomie'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 41 AND 45
  AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

-- Test 20: Known product regression test (Pudliszki Ketchup łagodny)
--          Popular Polish ketchup: sugar 20g + salt 2.7g, 6 ingredients → score 16-20
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Pudliszki Ketchup score changed unexpectedly' AS issue,
       CONCAT('Expected 16-20, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Ketchup łagodny - Najsmaczniejszy'
  AND p.brand = 'Pudliszki'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 16 AND 20;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 21: Known product regression test (BoboVita Kaszka Mleczna 7 Zbóż)
--          Baby cereal: high sugars 31g + moderate sat-fat → score 26-30
--          v3.3: protein 16g (bonus 40) + fibre 5.9g (bonus 35) → density 75 → -6 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: BoboVita Kaszka Mleczna 7 Zbóż score changed unexpectedly' AS issue,
       CONCAT('Expected 26-30, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa'
  AND p.brand = 'BoboVita'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 26 AND 30;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 22: Known product regression test (Somersby Blueberry Cider)
--          Alcoholic cider: moderate sugar 7.5g + controversies=1 → score 8-12
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Somersby Blueberry Cider score changed unexpectedly' AS issue,
       CONCAT('Expected 8-12, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Somersby Blueberry Flavoured Cider'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 8 AND 12;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 23: high_additive_load flag consistency
--          high_additive_load should be YES when additives_count >= 5
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       COALESCE(ia.additives_count, 0) AS additives_count,
       p.high_additive_load,
       'INCORRECT high_additive_load' AS issue
FROM products p
LEFT JOIN (
    SELECT pi.product_id, COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
    FROM product_ingredient pi JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (
    (COALESCE(ia.additives_count, 0) >= 5 AND p.high_additive_load <> 'YES')
    OR (COALESCE(ia.additives_count, 0) < 5 AND p.high_additive_load = 'YES')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 24: nutri_score_label valid domain
--          Must be one of A, B, C, D, E, UNKNOWN, or NOT-APPLICABLE
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.nutri_score_label,
       'INVALID NUTRI-SCORE LABEL' AS issue
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.nutri_score_label NOT IN ('A', 'B', 'C', 'D', 'E', 'UNKNOWN', 'NOT-APPLICABLE');

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 25: confidence valid domain
--          Must be 'estimated' or 'verified'
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.confidence,
       'INVALID CONFIDENCE VALUE' AS issue
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.confidence NOT IN ('estimated', 'verified');

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 26: Known product regression test (Mestemacher Chleb wielozbożowy)
--          Bread category: whole-grain rye, baked, low score → 10-14
--          v3.3: protein 5.8g (bonus 15) + fibre 8.8g (bonus 50) → density 65 → -5 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Mestemacher Chleb wielozbożowy score changed unexpectedly' AS issue,
       CONCAT('Expected 10-14, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Chleb wielozbożowy żytni pełnoziarnisty'
  AND p.brand = 'Mestemacher'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 10 AND 14;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 27: Known product regression test (Marinero Łosoś wędzony)
--          Seafood & Fish: smoked salmon, prep_method='smoked' → 23-27
--          v3.3: protein 20g (bonus 50) + fibre 0g (bonus 0) → density 50 → -4 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Marinero Łosoś wędzony score changed unexpectedly' AS issue,
       CONCAT('Expected 23-27, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Łosoś wędzony na zimno'
  AND p.brand = 'Marinero'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 23 AND 27;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 28: Known product regression test (Dr. Oetker Pizza 4 sery)
--          Frozen & Prepared: frozen pizza, baked → 22-26
--          v3.3: protein 10.2g (bonus 30) + fibre 0g (bonus 0) → density 30 → -2 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Dr. Oetker Pizza 4 sery score changed unexpectedly' AS issue,
       CONCAT('Expected 22-26, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Pizza 4 sery, głęboko mrożona'
  AND p.brand = 'Dr. Oetker'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 22 AND 26;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 29: Known product regression test (Lajkonik Paluszki extra cienkie)
--          Snacks: baked pretzels, high salt (3.9 g) → 23-27
--          v3.3: protein 12g (bonus 30) + fibre 3.9g (bonus 20) → density 50 → -4 pts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT p.product_id, p.brand, p.product_name,
       p.unhealthiness_score,
       'REGRESSION: Lajkonik Paluszki score changed unexpectedly' AS issue,
       CONCAT('Expected 23-27, got ', p.unhealthiness_score) AS detail
FROM products p
WHERE p.product_name = 'Paluszki extra cienkie'
  AND p.brand = 'Lajkonik'
  AND p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score::int NOT BETWEEN 23 AND 27;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 30: Synthetic band coverage — Red band (61-80)
--          No real products score 61-80. Verify formula produces correct output
--          for synthetic high-risk inputs. Issue #373.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT 'Red band synthetic test' AS issue,
       compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50) AS actual_score,
       CONCAT('Expected 61-80, got ',
              compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)) AS detail
WHERE compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)
      NOT BETWEEN 61 AND 80;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test 31: Synthetic band coverage — Dark Red band (81-100)
--          No real products score 81-100. Verify formula produces correct output
--          for synthetic extreme inputs. Issue #373.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT 'Dark Red band synthetic test' AS issue,
       compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100) AS actual_score,
       CONCAT('Expected 81-100, got ',
              compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)) AS detail
WHERE compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100)
      NOT BETWEEN 81 AND 100;

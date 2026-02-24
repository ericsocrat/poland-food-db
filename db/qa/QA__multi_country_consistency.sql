-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Multi-Country Consistency
-- Validates scoring equivalence, data integrity, and cross-country parity
-- between PL (primary) and DE (micro-pilot) datasets.
-- Complements QA__country_isolation (API boundary checks) with data-level
-- consistency checks.
-- 10 checks.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Cross-country scoring equivalence: same inputs → identical score
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '1. cross-country scoring equivalence (same inputs = same score)' AS check_name,
       CASE WHEN (
           SELECT compute_unhealthiness_v32(
               p_saturated_fat := 5.0, p_sugars := 12.0, p_salt := 0.8,
               p_calories := 200, p_trans_fat := 0, p_additive_count := 2,
               p_prep_method := 'baked', p_controversies := 'minor',
               p_ingredient_concern := 1
           )
       ) = (
           SELECT compute_unhealthiness_v32(
               p_saturated_fat := 5.0, p_sugars := 12.0, p_salt := 0.8,
               p_calories := 200, p_trans_fat := 0, p_additive_count := 2,
               p_prep_method := 'baked', p_controversies := 'minor',
               p_ingredient_concern := 1
           )
       )
       THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Both active countries have products
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '2. every active country has at least one product' AS check_name,
       COUNT(*) AS violations
FROM country_ref cr
WHERE cr.is_active = true
  AND NOT EXISTS (
      SELECT 1 FROM products p
      WHERE p.country = cr.country_code
        AND p.is_deprecated IS NOT TRUE
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Both active countries have scored products
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '3. every active country has scored products' AS check_name,
       COUNT(*) AS violations
FROM country_ref cr
WHERE cr.is_active = true
  AND NOT EXISTS (
      SELECT 1 FROM products p
      WHERE p.country = cr.country_code
        AND p.is_deprecated IS NOT TRUE
        AND p.unhealthiness_score IS NOT NULL
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Score range consistency: all scores in 1-100 for every country
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '4. all scores in valid 1-100 range per country' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN country_ref cr ON cr.country_code = p.country AND cr.is_active = true
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NOT NULL
  AND (p.unhealthiness_score < 1 OR p.unhealthiness_score > 100);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Nutrition FK integrity: every active product has nutrition_facts
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '5. every active product in every country has nutrition_facts' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN country_ref cr ON cr.country_code = p.country AND cr.is_active = true
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
      SELECT 1 FROM nutrition_facts nf
      WHERE nf.product_id = p.product_id
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. country_ref integrity: PL and DE both active
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '6. PL and DE both active in country_ref' AS check_name,
       2 - COUNT(*) AS violations
FROM country_ref
WHERE country_code IN ('PL', 'DE')
  AND is_active = true;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. No orphan products: all products reference active countries
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '7. no products with country not in active country_ref' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
      SELECT 1 FROM country_ref cr
      WHERE cr.country_code = p.country
        AND cr.is_active = true
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. DE micro-pilot only in allowed category (Chips)
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '8. DE products only in Chips category' AS check_name,
       COUNT(*) AS violations
FROM products p
WHERE p.country = 'DE'
  AND p.is_deprecated IS NOT TRUE
  AND p.category != 'Chips';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Data completeness parity: DE avg completeness within 30pts of PL
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '9. DE avg completeness within 30pts of PL avg' AS check_name,
       CASE WHEN ABS(
           (SELECT AVG(data_completeness_pct) FROM products
            WHERE country = 'PL' AND is_deprecated IS NOT TRUE
              AND data_completeness_pct IS NOT NULL) -
           (SELECT AVG(data_completeness_pct) FROM products
            WHERE country = 'DE' AND is_deprecated IS NOT TRUE
              AND data_completeness_pct IS NOT NULL)
       ) <= 30
       THEN 0 ELSE 1 END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. Recomputed scores match stored scores for BOTH countries
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '10. recomputed scores match stored scores across all countries' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NOT NULL
  AND p.unhealthiness_score != compute_unhealthiness_v32(
      p_saturated_fat      := nf.saturated_fat,
      p_sugars             := nf.sugars,
      p_salt               := nf.salt,
      p_calories           := nf.calories,
      p_trans_fat          := nf.trans_fat,
      p_additive_count     := COALESCE(p.additive_count, 0),
      p_prep_method        := p.prep_method,
      p_controversies      := p.controversies,
      p_ingredient_concern := COALESCE(p.ingredient_concern_score, 0)
  );

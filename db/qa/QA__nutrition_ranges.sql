-- ============================================================
-- QA: Nutrition Ranges & Plausibility
-- Validates that nutrition values fall within physiologically
-- plausible ranges and detects likely decimal point errors.
-- Checks per-100g values only (serving-proportional checks
-- are in QA__data_quality.sql check 15).
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Calories must be in [0, 900] per 100g
--    Pure fat = 900 kcal/100g (theoretical max)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. calories in [0, 900] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.calories IS NOT NULL
  AND (nf.calories::numeric < 0 OR nf.calories::numeric > 900);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Calorie back-calculation: stated calories should roughly match
--    protein×4 + carbs×4 + fat×9 (±35% tolerance for alcohol, fibre,
--    fermented products, organic acids, etc.)
--    Only checks products with calories > 50 to avoid noise from beverages
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. calorie back-calculation within 35%' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.calories IS NOT NULL AND nf.calories::numeric > 50
  AND nf.protein_g IS NOT NULL AND nf.carbs_g IS NOT NULL AND nf.total_fat_g IS NOT NULL
  AND p.category NOT IN ('Alcohol', 'Drinks', 'Condiments', 'Sauces')
  AND ABS(
      nf.calories::numeric
      - (nf.protein_g::numeric * 4 + nf.carbs_g::numeric * 4 + nf.total_fat_g::numeric * 9)
  ) > nf.calories::numeric * 0.35;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Protein must be in [0, 95] per 100g
--    Dried egg white powder ≈ 82g, whey isolate ≈ 90g; 95g gives margin
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. protein in [0, 95] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.protein_g IS NOT NULL
  AND (nf.protein_g::numeric < 0 OR nf.protein_g::numeric > 95);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Total fat must be in [0, 100] per 100g
--    Pure oils = 100g fat/100g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. total_fat in [0, 100] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.total_fat_g IS NOT NULL
  AND (nf.total_fat_g::numeric < 0 OR nf.total_fat_g::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Carbs must be in [0, 100] per 100g
--    Pure sugar = 100g carbs/100g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. carbs in [0, 100] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.carbs_g IS NOT NULL
  AND (nf.carbs_g::numeric < 0 OR nf.carbs_g::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Salt must be in [0, 100] per 100g
--    Pure salt = 100g; most foods < 10g; soy sauce ≈ 14-18g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. salt in [0, 100] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.salt_g IS NOT NULL
  AND (nf.salt_g::numeric < 0 OR nf.salt_g::numeric > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Saturated fat must not exceed total fat (+ 0.5g rounding tolerance)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. saturated_fat <= total_fat + 0.5' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.saturated_fat_g IS NOT NULL AND nf.total_fat_g IS NOT NULL
  AND nf.saturated_fat_g::numeric > nf.total_fat_g::numeric + 0.5;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Sugars must not exceed carbs (+ 0.5g rounding tolerance)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. sugars <= carbs + 0.5' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.sugars_g IS NOT NULL AND nf.carbs_g IS NOT NULL
  AND nf.sugars_g::numeric > nf.carbs_g::numeric + 0.5;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Fibre must be in [0, 60] per 100g
--    Psyllium husk ≈ 85% but most products < 40g; 60g is generous
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. fibre in [0, 60] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.fibre_g IS NOT NULL
  AND (nf.fibre_g::numeric < 0 OR nf.fibre_g::numeric > 60);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Trans fat must be in [0, 30] per 100g
--     Partially hydrogenated oils ≈ 25-30% trans; higher = decimal error
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. trans_fat in [0, 30] per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.trans_fat_g IS NOT NULL
  AND (nf.trans_fat_g::numeric < 0 OR nf.trans_fat_g::numeric > 30);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Likely decimal error: protein ≥ 50g for non-supplement/protein products
--     (excluding categories where this is plausible)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. suspect high protein (possible decimal error)' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.protein_g::numeric >= 50
  AND p.category NOT IN ('Nuts, Seeds & Legumes', 'Seafood & Fish', 'Meat')
  AND p.product_name NOT ILIKE '%protein%'
  AND p.product_name NOT ILIKE '%whey%';

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Likely decimal error: salt ≥ 30g per 100g
--     Seasoning powders/bouillon cubes can reach 22-28g;
--     anything ≥ 30g is suspicious even for condiments
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. suspect high salt (possible decimal error)' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.salt_g IS NOT NULL
  AND nf.salt_g::numeric >= 30;

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Likely decimal error: sugars ≥ 80g for non-candy/confectionery
--     Pure honey = 82g, dried fruit = 70-80g, pure sugar = 100g;
--     Excludes sweetener/condiment/confectionery categories
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. suspect high sugar (possible decimal error)' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.sugars_g IS NOT NULL
  AND nf.sugars_g::numeric >= 80
  AND p.category NOT IN ('Sweets', 'Drinks', 'Condiments', 'Sauces', 'Baby')
  AND p.product_name NOT ILIKE '%cukier%'
  AND p.product_name NOT ILIKE '%sugar%'
  AND p.product_name NOT ILIKE '%sirup%'
  AND p.product_name NOT ILIKE '%syrup%'
  AND p.product_name NOT ILIKE '%honey%'
  AND p.product_name NOT ILIKE '%miod%';

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Zero-calorie products should not have significant macros
--     If calories = 0, macros should sum to < 2g (rounding tolerance)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. zero-cal products have near-zero macros' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.calories IS NOT NULL AND nf.calories::numeric = 0
  AND (COALESCE(nf.total_fat_g::numeric, 0)
     + COALESCE(nf.protein_g::numeric, 0)
     + COALESCE(nf.carbs_g::numeric, 0)) > 2;

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. No negative values in any nutrition field
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. no negative nutrition values' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN products p ON p.product_id = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (nf.calories::numeric < 0
    OR nf.total_fat_g::numeric < 0
    OR nf.saturated_fat_g::numeric < 0
    OR nf.trans_fat_g::numeric < 0
    OR nf.carbs_g::numeric < 0
    OR nf.sugars_g::numeric < 0
    OR nf.fibre_g::numeric < 0
    OR nf.protein_g::numeric < 0
    OR nf.salt_g::numeric < 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. Likely kJ stored as kcal: calories > 400 AND calorie back-calculation
--     shows stated value ≈ 4.184× expected (kJ/kcal conversion factor)
--     Tolerance: ±15% of the kJ→kcal ratio
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. likely kJ stored as kcal' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.calories IS NOT NULL AND nf.calories::numeric > 400
  AND nf.protein_g IS NOT NULL AND nf.carbs_g IS NOT NULL AND nf.total_fat_g IS NOT NULL
  AND (nf.protein_g::numeric * 4 + nf.carbs_g::numeric * 4 + nf.total_fat_g::numeric * 9) > 20
  AND ABS(
      nf.calories::numeric
      - (nf.protein_g::numeric * 4 + nf.carbs_g::numeric * 4 + nf.total_fat_g::numeric * 9) * 4.184
  ) < (nf.protein_g::numeric * 4 + nf.carbs_g::numeric * 4 + nf.total_fat_g::numeric * 9) * 4.184 * 0.15;


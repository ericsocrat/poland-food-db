-- ============================================================
-- QA: Data Quality & Plausibility Checks
-- Validates data hygiene, plausibility bounds, and cross-field
-- consistency that go beyond NULL/orphan checks.
-- All checks are BLOCKING unless marked informational.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Trans fat must not exceed total fat
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. trans_fat <= total_fat' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.trans_fat_g IS NOT NULL
  AND nf.total_fat_g IS NOT NULL
  AND nf.trans_fat_g > nf.total_fat_g;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Total macros per 100g must not exceed 105g
--    (pure oils like coconut oil can reach ~101g; 105g adds safety margin)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. total macros <= 105g per 100g' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (COALESCE(nf.total_fat_g, 0) + COALESCE(nf.carbs_g, 0)
     + COALESCE(nf.protein_g, 0)) > 105;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Individual macro upper bounds per 100g
--    fat/carbs/protein ≤ 100g each, salt ≤ 40g
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. individual macro bounds' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
JOIN products p  ON p.product_id  = nf.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND (nf.total_fat_g > 100 OR nf.carbs_g > 100 OR nf.protein_g > 100
    OR nf.salt_g > 40 OR nf.fibre_g > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. No empty strings where NULL is expected (ean, brand)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. no empty strings in key fields' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT product_id FROM products WHERE ean = ''
    UNION ALL
    SELECT product_id FROM products WHERE brand = ''
) q;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. No leading/trailing whitespace in product names and brands
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. no untrimmed names/brands' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE product_name != TRIM(product_name)
   OR brand != TRIM(brand);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. EAN format: must be exactly 8 or 13 digits (when present)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. EAN format (8 or 13 digits)' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE ean IS NOT NULL
  AND ean !~ '^[0-9]{8}$'
  AND ean !~ '^[0-9]{13}$';

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. (removed — scored_at column dropped)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Deprecated products should have deprecated_reason (when column exists)
--    For now: deprecated products should have is_deprecated = true explicitly
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. deprecated products flagged correctly' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated = true
  AND category IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Duplicate servings per product per basis (must be exactly 1 each)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. no duplicate servings per product per basis' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT product_id, serving_basis, COUNT(*) AS cnt
    FROM servings
    GROUP BY product_id, serving_basis
    HAVING COUNT(*) > 1
) dupes;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. NOVA classification not null for active products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. NOVA not null for active products' AS check_name,
       COUNT(*) AS violations
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND sc.nova_classification IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. (removed — processing_risk column dropped; now derived in v_master)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Per-serving nutrition must have a matching per-100g row
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. per-serving has matching per-100g nutrition' AS check_name,
       COUNT(*) AS violations
FROM servings sv_srv
JOIN nutrition_facts nf_srv ON nf_srv.serving_id = sv_srv.serving_id
WHERE sv_srv.serving_basis NOT IN ('per 100 g', 'per 100 ml')
  AND NOT EXISTS (
      SELECT 1 FROM servings sv100
      JOIN nutrition_facts nf100 ON nf100.serving_id = sv100.serving_id
      WHERE sv100.product_id = sv_srv.product_id
        AND sv100.serving_basis IN ('per 100 g', 'per 100 ml')
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Sat fat ≤ total fat across ALL serving types (not just per-100g)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. sat_fat <= total_fat (all servings)' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
WHERE nf.saturated_fat_g IS NOT NULL
  AND nf.total_fat_g IS NOT NULL
  AND nf.saturated_fat_g > nf.total_fat_g;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Sugars ≤ carbs across ALL serving types
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. sugars <= carbs (all servings)' AS check_name,
       COUNT(*) AS violations
FROM nutrition_facts nf
WHERE nf.sugars_g IS NOT NULL
  AND nf.carbs_g IS NOT NULL
  AND nf.sugars_g > nf.carbs_g;

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Per-serving proportionality: calories should be roughly
--     (per_100g_calories × serving_g / 100) within ±20% tolerance
--     Only checks where per-100g calories > 10 to avoid division issues
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. per-serving calories proportional to per-100g' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id,
           n100.calories AS cal100,
           ns.calories AS cal_srv,
           sv.serving_amount_g_ml AS grams,
           n100.calories * sv.serving_amount_g_ml / 100.0 AS expected_cal
    FROM products p
    JOIN servings sv100 ON sv100.product_id = p.product_id AND sv100.serving_basis = 'per 100 g'
    JOIN nutrition_facts n100 ON n100.product_id = p.product_id AND n100.serving_id = sv100.serving_id
    JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per serving'
    JOIN nutrition_facts ns ON ns.product_id = p.product_id AND ns.serving_id = sv.serving_id
    WHERE p.is_deprecated IS NOT TRUE
      AND n100.calories > 10 AND ns.calories IS NOT NULL AND sv.serving_amount_g_ml > 0
      AND ABS(ns.calories - n100.calories * sv.serving_amount_g_ml / 100.0)
          > n100.calories * sv.serving_amount_g_ml / 100.0 * 0.20
) bad;

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. score_breakdown.final_score must match unhealthiness_score
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. score_breakdown final_score matches stored score' AS check_name,
       COUNT(*) AS violations
FROM v_master
WHERE score_breakdown IS NOT NULL
  AND (score_breakdown->>'final_score')::int != unhealthiness_score;

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. (removed — scoring_version column dropped)
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. MV staleness: v_master and v_product_confidence must be fresh
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '18. materialized views not stale' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT mv_staleness_check() AS staleness
) s
WHERE (s.staleness->>'is_stale')::boolean = true;

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. No products with score but without nutrition facts
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '19. scored products have nutrition' AS check_name,
       COUNT(*) AS violations
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND sc.unhealthiness_score IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM nutrition_facts nf
      JOIN servings sv ON sv.serving_id = nf.serving_id AND sv.serving_basis = 'per 100 g'
      WHERE nf.product_id = sc.product_id
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. product_sources must not have duplicate entries (same product + source_type)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '20. no duplicate product_sources' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT product_id, source_type, COUNT(*) AS cnt
    FROM product_sources
    GROUP BY product_id, source_type
    HAVING COUNT(*) > 1
) dupes;

-- ═══════════════════════════════════════════════════════════════════════════
-- 21. data_completeness_pct in [0, 100] (redundant with CHECK but belt-and-suspenders)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '21. data_completeness_pct in valid range' AS check_name,
       COUNT(*) AS violations
FROM scores
WHERE data_completeness_pct IS NOT NULL
  AND (data_completeness_pct < 0 OR data_completeness_pct > 100);

-- ═══════════════════════════════════════════════════════════════════════════
-- 22. ingredient_data_quality in v_master must be valid enum
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '22. ingredient_data_quality valid enum' AS check_name,
       COUNT(*) AS violations
FROM v_master
WHERE ingredient_data_quality NOT IN ('complete', 'partial', 'missing');

-- ═══════════════════════════════════════════════════════════════════════════
-- 23. nutrition_data_quality in v_master must be valid enum
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '23. nutrition_data_quality valid enum' AS check_name,
       COUNT(*) AS violations
FROM v_master
WHERE nutrition_data_quality NOT IN ('clean', 'suspect');

-- ═══════════════════════════════════════════════════════════════════════════
-- 24. Active products must have prep_method set (not NULL)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '24. prep_method not null for active products' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 25. No orphan product_ingredient rows (ingredient_id must exist in ingredient_ref)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '25. product_ingredient FK to ingredient_ref' AS check_name,
       COUNT(*) AS violations
FROM product_ingredient pi
LEFT JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
WHERE ir.ingredient_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 26. collected_at not in the future (product_sources)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '26. product_sources collected_at not in future' AS check_name,
       COUNT(*) AS violations
FROM product_sources
WHERE collected_at > NOW();

-- ═══════════════════════════════════════════════════════════════════════════
-- 27. product_type not null for active products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '27. product_type not null for active products' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND product_type IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 28. concern_reason populated for all tier 1-3 ingredients
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '28. concern_reason populated for tier 1-3 ingredients' AS check_name,
       COUNT(*) AS violations
FROM ingredient_ref
WHERE concern_tier >= 1
  AND (concern_reason IS NULL OR concern_reason = '');


-- QA: Scoring & Search Determinism (25 checks)
-- Validates deterministic scoring via direct function calls with pinned expected outputs.
-- No dependency on product data — tests computations in isolation.
-- Catches unintended formula changes, rounding drift, and factor-weight misconfiguration.
-- Covers: compute_unhealthiness_v32(), explain_score_v32(), compute_unhealthiness_v33(),
--         explain_score_v33(), stored-vs-recomputed parity.
-- Search determinism stubs included for api_search_products() ordering consistency.
-- Related: QA__scoring_formula_tests.sql (data-based regression); this suite is pure-function.
-- Reference: Issue #202 (GOV-C1), Issue #608 (v3.3), Issue #613 (v3.3 regression)

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Pinned healthy input → expected score 10 (±2)
--    Yogurt profile: sat=1.0, sug=4.0, salt=0.1, cal=56, trans=0,
--    add=0, prep=none, contr=none, concern=0
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. pinned healthy input score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(1.0, 4.0, 0.1, 56, 0, 0, 'none', 'none', 0)
                 BETWEEN 8 AND 12
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Pinned unhealthy input → expected score 87 (±2)
--    Junk profile: sat=15, sug=45, salt=2.5, cal=520, trans=1.5,
--    add=8, prep=deep-fried, contr=serious, concern=4
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. pinned unhealthy input score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(15.0, 45.0, 2.5, 520, 1.5, 8, 'deep-fried', 'serious', 4)
                 BETWEEN 85 AND 89
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Pinned medium input → expected score 20 (±2)
--    Bread profile: sat=0.5, sug=3.0, salt=1.0, cal=250, trans=0,
--    add=2, prep=baked, contr=minor, concern=1
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. pinned medium input score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0.5, 3.0, 1.0, 250, 0, 2, 'baked', 'minor', 1)
                 BETWEEN 18 AND 22
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Pinned palm-oil product → expected score 43 (±2)
--    Chips profile: sat=8.0, sug=1.0, salt=1.5, cal=530, trans=0,
--    add=3, prep=fried, contr=palm oil, concern=2
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. pinned palm oil product score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(8.0, 1.0, 1.5, 530, 0, 3, 'fried', 'palm oil', 2)
                 BETWEEN 41 AND 45
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Pinned minimal (baby-safe) → expected score 6 (±2)
--    Baby profile: sat=0.2, sug=1.0, salt=0.01, cal=30, trans=0,
--    add=0, prep=none, contr=none, concern=0
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. pinned minimal input score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0.2, 1.0, 0.01, 30, 0, 0, 'none', 'none', 0)
                 BETWEEN 4 AND 8
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. All-zero floor → exact score 4
--    Only prep_method contributes (default=50 → 50*0.08=4)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. all-zero floor score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0, 0, 0, 0, 0, 0, 'not-applicable', 'none', 0) = 4
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. All-max ceiling → exact score 100
--    All factors at ceiling: sat=10, sug=27, salt=3, cal=600, trans=2,
--    add=10, prep=deep-fried, contr=serious, concern=100
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. all-max ceiling score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(10, 27, 3, 600, 2, 10, 'deep-fried', 'serious', 100) = 100
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Factor isolation: saturated fat at ceiling → score 21 (±1)
--    Only sat fat + default prep: 100*0.17 + 50*0.08 = 21
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. factor isolation sat fat' AS check_name,
       CASE WHEN compute_unhealthiness_v32(10, 0, 0, 0, 0, 0, 'not-applicable', 'none', 0)
                 BETWEEN 20 AND 22
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Factor isolation: trans fat at ceiling → score 15 (±1)
--    Only trans fat + default prep: 100*0.11 + 50*0.08 = 15
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. factor isolation trans fat' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0, 0, 0, 0, 2, 0, 'not-applicable', 'none', 0)
                 BETWEEN 14 AND 16
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Prep method ordering: air-popped < baked < fried < deep-fried
--     With all other factors zeroed, verifies monotonic increase
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. prep method scoring order' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0,0,0,0,0,0,'air-popped','none',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'baked','none',0)
             AND compute_unhealthiness_v32(0,0,0,0,0,0,'baked','none',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'fried','none',0)
             AND compute_unhealthiness_v32(0,0,0,0,0,0,'fried','none',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'deep-fried','none',0)
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Controversy severity ordering: none < minor < palm oil < moderate < serious
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. controversy scoring order' AS check_name,
       CASE WHEN compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','none',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','minor',0)
             AND compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','minor',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','palm oil',0)
             AND compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','palm oil',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','moderate',0)
             AND compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','moderate',0) <
                 compute_unhealthiness_v32(0,0,0,0,0,0,'not-applicable','serious',0)
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Re-scoring determinism: 100 identical calls → 1 distinct result
--     Verifies no floating-point instability or randomness
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. re-scoring determinism 100x' AS check_name,
       (SELECT COUNT(DISTINCT compute_unhealthiness_v32(
           5.0, 12.0, 0.8, 200, 0.3, 2, 'baked', 'minor', 1
       )) FROM generate_series(1, 100)) - 1 AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. explain_score_v32 final_score matches compute_unhealthiness_v32
--     Both functions must produce identical outputs for same inputs
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '13. explain vs compute parity' AS check_name,
       (SELECT COUNT(*) FROM (
           VALUES
               (5.0, 12.0, 0.8, 200, 0.3, 2, 'baked'::text, 'minor'::text, 1),
               (1.0, 4.0, 0.1, 56, 0, 0, 'none'::text, 'none'::text, 0),
               (15.0, 45.0, 2.5, 520, 1.5, 8, 'deep-fried'::text, 'serious'::text, 4),
               (0, 0, 0, 0, 0, 0, 'not-applicable'::text, 'none'::text, 0),
               (10, 27, 3, 600, 2, 10, 'deep-fried'::text, 'serious'::text, 100)
       ) AS t(sf, sg, sl, ca, tf, ad, pm, co, ic)
       WHERE compute_unhealthiness_v32(sf, sg, sl, ca, tf, ad, pm, co, ic)
          <> (explain_score_v32(sf, sg, sl, ca, tf, ad, pm, co, ic)->>'final_score')::int
       ) AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Stored scores match recomputed via v3.3 for all active products
--     Products are now scored with v3.3 (nutrient density bonus)
--     Any drift = scoring pipeline bug or missed rescore
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '14. stored vs recomputed parity' AS check_name,
       COUNT(*) AS violations
FROM products p
JOIN nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN (
    SELECT pi.product_id,
           COUNT(*) FILTER (WHERE ir.is_additive) AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NOT NULL
  AND p.unhealthiness_score <> compute_unhealthiness_v33(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      COALESCE(ia.additives_count, 0),
      p.prep_method,
      p.controversies,
      COALESCE(p.ingredient_concern_score, 0),
      nf.protein_g,
      nf.fibre_g
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Weight verification: v3.3 has 10 factors
--     9 penalty weights sum to 1.00; nutrient_density weight is -0.08
--     Net sum of all weights = 0.92 (the bonus reduces the total)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. v3.3 factor weights check' AS check_name,
       CASE
         -- 10 factors total
         WHEN (SELECT COUNT(*)
               FROM jsonb_array_elements(
                   (explain_score_v33(5,12,0.8,200,0.3,2,'baked','minor',1,8,3))->'factors'
               )) = 10
         -- 9 penalty weights (positive) sum to 1.00
         AND (SELECT round(SUM((f->>'weight')::numeric), 2)
              FROM jsonb_array_elements(
                  (explain_score_v33(5,12,0.8,200,0.3,2,'baked','minor',1,8,3))->'factors'
              ) AS f
              WHERE (f->>'weight')::numeric > 0) = 1.00
         -- 1 bonus weight is -0.08
         AND (SELECT (f->>'weight')::numeric
              FROM jsonb_array_elements(
                  (explain_score_v33(5,12,0.8,200,0.3,2,'baked','minor',1,8,3))->'factors'
              ) AS f
              WHERE f->>'name' = 'nutrient_density') = -0.08
         THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- Search ranking determinism stubs (ready for expansion)
-- These stubs verify basic search consistency. More comprehensive ordering
-- tests should be added when the search ranking config (#192) is finalized.
-- ═══════════════════════════════════════════════════════════════════════════
-- NOTE: Search tests use api_search_products() which requires pipeline data.
-- They are included here as stubs to be expanded in #204 (multi-country testing).
-- Stub: search("chips") twice → same product_id ordering
-- Stub: search(exact_name) → that product ranks #1
-- Stub: search(brand) → brand products in top results

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. Pinned Red band input → expected score 68 (±2)
--     Red profile: sat=8, sug=20, salt=2.0, cal=450, trans=1.0,
--     add=6, prep=deep-fried, contr=palm oil, concern=50
--     Previously untested band (0 real products score 61-80). Issue #373.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '16. pinned red band input score' AS check_name,
       CASE WHEN compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)
                 BETWEEN 66 AND 70
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. Band coverage matrix — all 5 bands produce scores in expected ranges
--     Synthetic inputs calibrated to land in each band.
--     Violation = any band's representative score falls outside its range.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '17. band coverage matrix' AS check_name,
       (SELECT COUNT(*) FROM (VALUES
           ('Green',    1,  20, compute_unhealthiness_v32(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0)),
           ('Yellow',  21,  40, compute_unhealthiness_v32(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20)),
           ('Orange',  41,  60, compute_unhealthiness_v32(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30)),
           ('Red',     61,  80, compute_unhealthiness_v32(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50)),
           ('DarkRed', 81, 100, compute_unhealthiness_v32(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100))
       ) AS t(band, lo, hi, actual)
       WHERE actual NOT BETWEEN lo AND hi) AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. v3.3 pinned healthy yogurt WITH nutrient density bonus
--     Same penalty inputs as Test 1 (sat=1, sug=4, salt=0.1, cal=56,
--     trans=0, add=0, prep=none, contr=none, concern=0).
--     Protein 8 g → bonus 15, fibre 0.5 g → bonus 0, density_raw = 15.
--     Bonus reduction = 15 × 0.08 = 1.2 points.
--     v3.2 score ≈ 10; v3.3 ≈ 9 (clamped to integer).
--     Issue #608.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '18. v33 pinned yogurt with protein bonus' AS check_name,
       CASE WHEN compute_unhealthiness_v33(1.0, 4.0, 0.1, 56, 0, 0, 'none', 'none', 0, 8.0, 0.5)
                 BETWEEN 7 AND 11
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. v3.3 maximum nutrient density bonus — floor clamp to 1
--     All penalties at minimum (prep=not-applicable gives raw 50 × 0.08 = 4).
--     Protein 25 g → bonus 50, fibre 10 g → bonus 50, density_raw = 100.
--     Bonus reduction = 100 × 0.08 = 8.0 points.
--     Penalty score ≈ 4 → 4 - 8 = -4 → GREATEST(1, -4) = 1.
--     Issue #608.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '19. v33 max nutrient density bonus clamps to 1' AS check_name,
       CASE WHEN compute_unhealthiness_v33(0, 0, 0, 0, 0, 0, 'not-applicable', 'none', 0, 25.0, 10.0) = 1
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. v3.3 explain vs compute parity — 5 input vectors
--     final_score from explain_score_v33 JSONB must equal
--     compute_unhealthiness_v33 integer for every input vector.
--     Issue #608.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '20. v33 explain vs compute parity' AS check_name,
       (SELECT COUNT(*) FROM (VALUES
           (1.0, 4.0, 0.1,  56, 0.0, 0, 'none',           'none',     0,  8.0,  0.5),
           (5.0,12.0, 0.8, 200, 0.3, 2, 'baked',           'none',    10, 15.0,  3.0),
           (8.0,20.0, 2.0, 450, 1.0, 6, 'deep-fried',      'palm oil',50,  0.0,  0.0),
           (0.0, 0.0, 0.0,   0, 0.0, 0, 'not-applicable', 'none',     0, 25.0, 10.0),
           (10.0,27.0,3.0, 600, 2.0,10, 'deep-fried',      'serious',100, 20.0,  8.0)
       ) AS t(sf,sg,sl,ca,tf,ad,pm,co,ic,pr,fi)
       WHERE compute_unhealthiness_v33(sf,sg,sl,ca,tf,ad,pm::text,co::text,ic,pr,fi)
          <> (explain_score_v33(sf,sg,sl,ca,tf,ad,pm::text,co::text,ic,pr,fi)->>'final_score')::int
       ) AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 21. v3.3 determinism — 100 identical calls yield one distinct result
--     Same structure as Test 12 but calls v3.3 with protein/fibre.
--     Issue #608.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '21. v33 determinism 100x' AS check_name,
       CASE WHEN (
           SELECT COUNT(DISTINCT compute_unhealthiness_v33(5, 12, 0.8, 200, 0.3, 2, 'baked', 'none', 10, 12.0, 3.0))
           FROM generate_series(1, 100)
       ) = 1 THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 22. v3.3 nutrient density factor isolation — monotonic decrease
--     All penalty inputs fixed (prep=baked → ~40 × 0.08 = ~3 penalty base).
--     Increasing protein/fibre must monotonically decrease the score.
--     Issue #608.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '22. v33 nutrient density monotonic decrease' AS check_name,
       CASE WHEN
           compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 0.0, 0.0)
         > compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 10.0, 0.0)
       AND compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 10.0, 0.0)
        >= compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 10.0, 5.0)
       AND compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 10.0, 5.0)
        >= compute_unhealthiness_v33(3, 8, 0.5, 150, 0, 1, 'baked', 'none', 5, 20.0, 8.0)
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 23. v3.3 all-zero floor with no nutrient bonus → score 4
--     Only prep_method contributes (default=50 → 50*0.08=4), no bonus
--     Issue #613.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '23. v3.3 all-zero floor score' AS check_name,
       CASE WHEN compute_unhealthiness_v33(0, 0, 0, 0, 0, 0, 'not-applicable', 'none', 0, 0, 0) = 4
            THEN 0 ELSE 1
       END AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 24. v3.3 parity with v3.2 when protein=0, fibre=0
--     v33(inputs, 0, 0) must equal v32(inputs) for all 5 pinned profiles
--     Issue #613.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '24. v3.3 v3.2 parity (no bonus)' AS check_name,
       (SELECT COUNT(*) FROM (
           VALUES
               (1.0, 4.0, 0.1, 56, 0, 0, 'none'::text, 'none'::text, 0),
               (15.0, 45.0, 2.5, 520, 1.5, 8, 'deep-fried'::text, 'serious'::text, 4),
               (0.5, 3.0, 1.0, 250, 0, 2, 'baked'::text, 'minor'::text, 1),
               (0, 0, 0, 0, 0, 0, 'not-applicable'::text, 'none'::text, 0),
               (10, 27, 3, 600, 2, 10, 'deep-fried'::text, 'serious'::text, 100)
       ) AS t(sf, sg, sl, ca, tf, ad, pm, co, ic)
       WHERE compute_unhealthiness_v33(sf, sg, sl, ca, tf, ad, pm, co, ic, 0, 0)
          <> compute_unhealthiness_v32(sf, sg, sl, ca, tf, ad, pm, co, ic)
       ) AS violations;

-- ═══════════════════════════════════════════════════════════════════════════
-- 25. v3.3 band coverage matrix — same inputs as v3.2 + protein=0, fibre=0
--     Verifies v3.3 function covers all 5 scoring bands correctly
--     Issue #613.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '25. v3.3 band coverage matrix' AS check_name,
       (SELECT COUNT(*) FROM (VALUES
           ('Green',    1,  20, compute_unhealthiness_v33(1.0, 3.0, 0.3, 100, 0, 0, 'not-applicable', 'none', 0, 0, 0)),
           ('Yellow',  21,  40, compute_unhealthiness_v33(5.0, 12.0, 1.0, 300, 0.5, 3, 'baked', 'none', 20, 0, 0)),
           ('Orange',  41,  60, compute_unhealthiness_v33(6.0, 15.0, 1.5, 350, 0.5, 4, 'fried', 'none', 30, 0, 0)),
           ('Red',     61,  80, compute_unhealthiness_v33(8.0, 20.0, 2.0, 450, 1.0, 6, 'deep-fried', 'palm oil', 50, 0, 0)),
           ('DarkRed', 81, 100, compute_unhealthiness_v33(10.0, 27.0, 3.0, 600, 2.0, 10, 'deep-fried', 'serious', 100, 0, 0))
       ) AS t(band, lo, hi, actual)
       WHERE actual NOT BETWEEN lo AND hi) AS violations;

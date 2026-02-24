-- QA: Scoring & Search Determinism (15 checks)
-- Validates deterministic scoring via direct function calls with pinned expected outputs.
-- No dependency on product data — tests computations in isolation.
-- Catches unintended formula changes, rounding drift, and factor-weight misconfiguration.
-- Covers: compute_unhealthiness_v32(), explain_score_v32(), stored-vs-recomputed parity.
-- Search determinism stubs included for api_search_products() ordering consistency.
-- Related: QA__scoring_formula_tests.sql (data-based regression); this suite is pure-function.
-- Reference: Issue #202 (GOV-C1)

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
-- 14. Stored scores match recomputed for all active products
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
  AND p.unhealthiness_score <> compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      COALESCE(ia.additives_count, 0),
      p.prep_method,
      p.controversies,
      COALESCE(p.ingredient_concern_score, 0)
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Weight sum verification: all 9 factor weights sum to exactly 1.00
--     Validates via explain_score_v32 factors array
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '15. factor weights sum to 1.00' AS check_name,
       CASE WHEN (
           SELECT round(SUM((f->>'weight')::numeric), 2)
           FROM jsonb_array_elements(
               (explain_score_v32(5,12,0.8,200,0.3,2,'baked','minor',1))->'factors'
           ) AS f
       ) = 1.00
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

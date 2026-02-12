-- Populate ingredient_concern_score and fix palm oil controversies
-- Based on EFSA concern tiers: tier 1 = 15pts, tier 2 = 40pts, tier 3 = 100pts
-- Capped at LEAST(100, SUM(...)) per SCORING_METHODOLOGY.md v3.2
-- Also sets controversies = 'palm oil' for products with palm oil ingredients

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- Step 1: Populate ingredient_concern_score from actual ingredient data
-- ═══════════════════════════════════════════════════════════════

UPDATE products p
SET ingredient_concern_score = COALESCE(concern.score, 0)
FROM (
    SELECT pi.product_id,
           LEAST(100, SUM(
               CASE ir.concern_tier
                   WHEN 1 THEN 15
                   WHEN 2 THEN 40
                   WHEN 3 THEN 100
                   ELSE 0
               END
           ))::int AS score
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.concern_tier > 0
    GROUP BY pi.product_id
) concern
WHERE concern.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE
  AND p.ingredient_concern_score IS DISTINCT FROM COALESCE(concern.score, 0);

-- ═══════════════════════════════════════════════════════════════
-- Step 2: Flag palm oil controversy from actual ingredient data
-- ═══════════════════════════════════════════════════════════════

-- Upgrade: set 'palm oil' for products with palm oil ingredients
-- that currently have 'none' controversy
UPDATE products p
SET controversies = 'palm oil'
FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.from_palm_oil = 'yes'
) palm
WHERE palm.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE
  AND p.controversies = 'none';

-- ═══════════════════════════════════════════════════════════════
-- Step 3: Re-score all products with updated concern/controversy data
-- ═══════════════════════════════════════════════════════════════

UPDATE products p
SET unhealthiness_score = (
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g,
        COALESCE(ia.additives_count, 0)::numeric,
        p.prep_method, p.controversies, p.ingredient_concern_score
    )->>'final_score'
)::int
FROM nutrition_facts nf
LEFT JOIN LATERAL (
    SELECT COUNT(*) FILTER (WHERE ir.is_additive) AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = nf.product_id
) ia ON true
WHERE nf.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════
-- Step 4: Recalculate high_additive_load to stay consistent
-- ═══════════════════════════════════════════════════════════════

UPDATE products p
SET high_additive_load = CASE
    WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES'
    ELSE 'NO'
END
FROM (
    SELECT pi.product_id,
           COUNT(*) FILTER (WHERE ir.is_additive) AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia
WHERE ia.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════
-- Step 5: Refresh materialized views
-- ═══════════════════════════════════════════════════════════════

SELECT refresh_all_materialized_views();

COMMIT;

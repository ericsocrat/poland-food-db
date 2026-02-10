-- Fix: palm oil controversy was not scored (fell through to ELSE 0)
-- palm oil → 40 (between minor=30 and moderate=60)
-- EFSA 2016: process contaminants (3-MCPD, glycidyl esters) in refined palm oil

CREATE OR REPLACE FUNCTION compute_unhealthiness_v32(
    p_saturated_fat_g  numeric,
    p_sugars_g         numeric,
    p_salt_g           numeric,
    p_calories         numeric,
    p_trans_fat_g      numeric,
    p_additives_count  numeric,
    p_prep_method      text,
    p_controversies    text,
    p_concern_score    numeric
)
RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
    SELECT GREATEST(1, LEAST(100, round(
        LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) * 0.17 +
        LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) * 0.17 +
        LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) * 0.10 +
        LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) * 0.11 +
        LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) * 0.07 +
        (CASE p_prep_method
           WHEN 'air-popped'  THEN 20
           WHEN 'steamed'     THEN 30
           WHEN 'baked'       THEN 40
           WHEN 'grilled'     THEN 60
           WHEN 'smoked'      THEN 65
           WHEN 'fried'       THEN 80
           WHEN 'deep-fried'  THEN 100
           ELSE 50
         END) * 0.08 +
        (CASE p_controversies
           WHEN 'none'      THEN 0
           WHEN 'minor'     THEN 30
           WHEN 'palm oil'  THEN 40
           WHEN 'moderate'  THEN 60
           WHEN 'serious'   THEN 100
           ELSE 0
         END) * 0.08 +
        LEAST(100, COALESCE(p_concern_score, 0)) * 0.05
    )))::integer;
$$;

-- Rescore all 18 palm-oil products (score increases by round(40*0.08) = +3)
UPDATE scores sc
SET    unhealthiness_score = compute_unhealthiness_v32(
           nf.saturated_fat_g,
           nf.sugars_g,
           nf.salt_g,
           nf.calories,
           nf.trans_fat_g,
           i.additives_count,
           p.prep_method,
           p.controversies,
           sc.ingredient_concern_score
       ),
       scored_at       = CURRENT_DATE,
       scoring_version = 'v3.2'
FROM   products p
JOIN   servings sv       ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN   nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i  ON i.product_id = p.product_id
WHERE  sc.product_id = p.product_id
  AND  p.is_deprecated IS NOT TRUE
  AND  p.controversies = 'palm oil';

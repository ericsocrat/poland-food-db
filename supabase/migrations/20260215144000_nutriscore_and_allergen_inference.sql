-- Phase 10.2: Nutri-Score computation + Allergen inference from ingredients
-- Fills 98 UNKNOWN Nutri-Score products + 12 NOT-APPLICABLE Snacks/Sauces
-- Infers allergens from ingredient keywords for ~11 products
-- Recalculates data completeness for all affected products

BEGIN;

-------------------------------------------------------------------------------
-- 1. Nutri-Score v1 computation function
--    Based on the EU/Santé publique France algorithm (2017 version)
--    Inputs: nutrition per 100g, is_beverage flag
--    Returns: grade A-E
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION compute_nutri_score_label(
    p_calories    numeric,  -- kcal per 100g
    p_sugars_g    numeric,
    p_sat_fat_g   numeric,
    p_salt_g      numeric,
    p_fibre_g     numeric,
    p_protein_g   numeric,
    p_is_beverage boolean DEFAULT false
)
RETURNS text
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    v_energy_kj numeric;
    v_sodium_mg numeric;
    v_neg_energy int;
    v_neg_sugars int;
    v_neg_satfat int;
    v_neg_sodium int;
    v_pos_fibre  int;
    v_pos_protein int;
    v_negative   int;
    v_positive   int;
    v_score      int;
BEGIN
    -- Convert units
    v_energy_kj := COALESCE(p_calories, 0) * 4.184;
    v_sodium_mg := COALESCE(p_salt_g, 0) * 400;

    IF p_is_beverage THEN
        -----------------------------------------------------------------------
        -- BEVERAGE scoring
        -----------------------------------------------------------------------
        -- Energy (kJ): thresholds 0,30,60,90,120,150,180,210,240,270
        v_neg_energy := CASE
            WHEN v_energy_kj <= 0   THEN 0
            WHEN v_energy_kj <= 30  THEN 1
            WHEN v_energy_kj <= 60  THEN 2
            WHEN v_energy_kj <= 90  THEN 3
            WHEN v_energy_kj <= 120 THEN 4
            WHEN v_energy_kj <= 150 THEN 5
            WHEN v_energy_kj <= 180 THEN 6
            WHEN v_energy_kj <= 210 THEN 7
            WHEN v_energy_kj <= 240 THEN 8
            WHEN v_energy_kj <= 270 THEN 9
            ELSE 10
        END;

        -- Sugars (g): thresholds 0,1.5,3,4.5,6,7.5,9,10.5,12,13.5
        v_neg_sugars := CASE
            WHEN COALESCE(p_sugars_g, 0) <= 0    THEN 0
            WHEN p_sugars_g <= 1.5  THEN 1
            WHEN p_sugars_g <= 3    THEN 2
            WHEN p_sugars_g <= 4.5  THEN 3
            WHEN p_sugars_g <= 6    THEN 4
            WHEN p_sugars_g <= 7.5  THEN 5
            WHEN p_sugars_g <= 9    THEN 6
            WHEN p_sugars_g <= 10.5 THEN 7
            WHEN p_sugars_g <= 12   THEN 8
            WHEN p_sugars_g <= 13.5 THEN 9
            ELSE 10
        END;
    ELSE
        -----------------------------------------------------------------------
        -- SOLID FOOD scoring
        -----------------------------------------------------------------------
        -- Energy (kJ): thresholds 335,670,1005,1340,1675,2010,2345,2680,3015,3350
        v_neg_energy := CASE
            WHEN v_energy_kj <= 335  THEN 0
            WHEN v_energy_kj <= 670  THEN 1
            WHEN v_energy_kj <= 1005 THEN 2
            WHEN v_energy_kj <= 1340 THEN 3
            WHEN v_energy_kj <= 1675 THEN 4
            WHEN v_energy_kj <= 2010 THEN 5
            WHEN v_energy_kj <= 2345 THEN 6
            WHEN v_energy_kj <= 2680 THEN 7
            WHEN v_energy_kj <= 3015 THEN 8
            WHEN v_energy_kj <= 3350 THEN 9
            ELSE 10
        END;

        -- Sugars (g): thresholds 4.5,9,13.5,18,22.5,27,31,36,40,45
        v_neg_sugars := CASE
            WHEN COALESCE(p_sugars_g, 0) <= 4.5  THEN 0
            WHEN p_sugars_g <= 9    THEN 1
            WHEN p_sugars_g <= 13.5 THEN 2
            WHEN p_sugars_g <= 18   THEN 3
            WHEN p_sugars_g <= 22.5 THEN 4
            WHEN p_sugars_g <= 27   THEN 5
            WHEN p_sugars_g <= 31   THEN 6
            WHEN p_sugars_g <= 36   THEN 7
            WHEN p_sugars_g <= 40   THEN 8
            WHEN p_sugars_g <= 45   THEN 9
            ELSE 10
        END;
    END IF;

    -- Saturated fat (g): same for both — thresholds 1,2,3,4,5,6,7,8,9,10
    v_neg_satfat := CASE
        WHEN COALESCE(p_sat_fat_g, 0) <= 1  THEN 0
        WHEN p_sat_fat_g <= 2  THEN 1
        WHEN p_sat_fat_g <= 3  THEN 2
        WHEN p_sat_fat_g <= 4  THEN 3
        WHEN p_sat_fat_g <= 5  THEN 4
        WHEN p_sat_fat_g <= 6  THEN 5
        WHEN p_sat_fat_g <= 7  THEN 6
        WHEN p_sat_fat_g <= 8  THEN 7
        WHEN p_sat_fat_g <= 9  THEN 8
        WHEN p_sat_fat_g <= 10 THEN 9
        ELSE 10
    END;

    -- Sodium (mg): same for both — thresholds 90,180,270,360,450,540,630,720,810,900
    v_neg_sodium := CASE
        WHEN v_sodium_mg <= 90  THEN 0
        WHEN v_sodium_mg <= 180 THEN 1
        WHEN v_sodium_mg <= 270 THEN 2
        WHEN v_sodium_mg <= 360 THEN 3
        WHEN v_sodium_mg <= 450 THEN 4
        WHEN v_sodium_mg <= 540 THEN 5
        WHEN v_sodium_mg <= 630 THEN 6
        WHEN v_sodium_mg <= 720 THEN 7
        WHEN v_sodium_mg <= 810 THEN 8
        WHEN v_sodium_mg <= 900 THEN 9
        ELSE 10
    END;

    v_negative := v_neg_energy + v_neg_sugars + v_neg_satfat + v_neg_sodium;

    -- Fibre (g): thresholds 0.9,1.9,2.8,3.7,4.7
    v_pos_fibre := CASE
        WHEN COALESCE(p_fibre_g, 0) <= 0.9 THEN 0
        WHEN p_fibre_g <= 1.9 THEN 1
        WHEN p_fibre_g <= 2.8 THEN 2
        WHEN p_fibre_g <= 3.7 THEN 3
        WHEN p_fibre_g <= 4.7 THEN 4
        ELSE 5
    END;

    -- Protein (g): thresholds 1.6,3.2,4.8,6.4,8.0
    v_pos_protein := CASE
        WHEN COALESCE(p_protein_g, 0) <= 1.6 THEN 0
        WHEN p_protein_g <= 3.2 THEN 1
        WHEN p_protein_g <= 4.8 THEN 2
        WHEN p_protein_g <= 6.4 THEN 3
        WHEN p_protein_g <= 8.0 THEN 4
        ELSE 5
    END;

    -- Positive points: fibre always counts.
    -- Protein only counts if negative < 11 (no fruit/veg data, so we assume 0%)
    IF v_negative >= 11 THEN
        v_positive := v_pos_fibre;  -- protein excluded when negative >= 11 and fruit% < 80%
    ELSE
        v_positive := v_pos_fibre + v_pos_protein;
    END IF;

    v_score := v_negative - v_positive;

    -- Grade assignment
    IF p_is_beverage THEN
        -- Beverage grades
        RETURN CASE
            WHEN v_score <= 1  THEN 'B'  -- Water = A, other <=1 = B (conservative: we can't detect water)
            WHEN v_score <= 5  THEN 'C'
            WHEN v_score <= 9  THEN 'D'
            ELSE 'E'
        END;
    ELSE
        -- Solid food grades
        RETURN CASE
            WHEN v_score <= -1 THEN 'A'
            WHEN v_score <= 2  THEN 'B'
            WHEN v_score <= 10 THEN 'C'
            WHEN v_score <= 18 THEN 'D'
            ELSE 'E'
        END;
    END IF;
END;
$$;

COMMENT ON FUNCTION compute_nutri_score_label IS
  'Computes Nutri-Score v1 grade (A-E) from nutrition facts per 100g. '
  'Assumes fruit/vegetable/nut % = 0 (conservative). '
  'Phase 10.2 — used to fill UNKNOWN Nutri-Score labels.';

-------------------------------------------------------------------------------
-- 2. Apply Nutri-Score to UNKNOWN products (98 products)
-------------------------------------------------------------------------------
UPDATE products p
SET    nutri_score_label = compute_nutri_score_label(
           nf.calories, nf.sugars_g, nf.saturated_fat_g, nf.salt_g,
           nf.fibre_g, nf.protein_g,
           p.category IN ('Drinks')  -- beverages flag
       )
FROM   nutrition_facts nf
WHERE  nf.product_id = p.product_id
  AND  p.is_deprecated IS NOT TRUE
  AND  p.nutri_score_label = 'UNKNOWN';

-- Log the update
DO $$
DECLARE v_cnt int;
BEGIN
  SELECT count(*) INTO v_cnt
  FROM products WHERE nutri_score_label NOT IN ('UNKNOWN','NOT-APPLICABLE')
    AND is_deprecated IS NOT TRUE;
  RAISE NOTICE 'Nutri-Score: % products now have A-E grades', v_cnt;
END $$;

-------------------------------------------------------------------------------
-- 3. Fix NOT-APPLICABLE Snacks & Sauces (12 products)
--    These are protein bars and sauces that should have Nutri-Score.
--    Baby food and Alcohol remain NOT-APPLICABLE (excluded by regulation).
-------------------------------------------------------------------------------
UPDATE products p
SET    nutri_score_label = compute_nutri_score_label(
           nf.calories, nf.sugars_g, nf.saturated_fat_g, nf.salt_g,
           nf.fibre_g, nf.protein_g,
           false  -- solid food
       )
FROM   nutrition_facts nf
WHERE  nf.product_id = p.product_id
  AND  p.is_deprecated IS NOT TRUE
  AND  p.nutri_score_label = 'NOT-APPLICABLE'
  AND  p.category IN ('Snacks', 'Sauces');

-------------------------------------------------------------------------------
-- 4. Conservative allergen inference from ingredient keywords
--    Only for products that HAVE ingredients but NO allergen data.
--    Uses both underscore-marked allergens (OFF convention) and
--    high-confidence Polish/English keyword matches.
-------------------------------------------------------------------------------

-- 4a. Milk allergen (products with 'Mleko UHT', 'Białka Mleka', etc.)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa WHERE pa.product_id = p.product_id AND pa.tag = 'en:milk')
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa2 WHERE pa2.product_id = p.product_id)
  AND (
    ir.name_en ~* '^_?mleko'           -- Mleko (milk), _Mleko_ (OFF-marked)
    OR ir.name_en ~* 'białk\w* mleka'  -- Białka Mleka (milk protein)
    OR ir.name_en ~* '^_?milk'         -- Milk, _Milk_
    OR ir.name_en ~* '_serwatk'        -- _Serwatka_ (whey)
    OR ir.name_en ~* '_śmietan'        -- _Śmietana_ (cream)
    OR ir.name_en ~* '^mleko'          -- plain Mleko
  )
  AND ir.name_en !~* '(kwas mlekow|fermentacji mlekow|mleczanu|kokosow)'; -- exclude lactic acid, fermentation, lactate, coconut

-- 4b. Gluten allergen (oats, barley, wheat)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa WHERE pa.product_id = p.product_id AND pa.tag = 'en:gluten')
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa2 WHERE pa2.product_id = p.product_id)
  AND (
    ir.name_en ~* '(płatki|otręby|mąka)\s+_?owsian'     -- Płatki/Otręby Owsiane (oat flakes/bran)
    OR ir.name_en ~* '_?owsiane_?\s'                      -- _Owsiane_ (OFF-marked oat)
    OR ir.name_en ~* 'słod\w*\s+jęczmienn'                -- Słody Jęczmienne (barley malt)
    OR ir.name_en ~* '_?jęczmienn'                         -- _Jęczmienny_ (barley)
    OR ir.name_en ~* 'błonnik\s+pszenn'                    -- Błonnik Pszenny (wheat fiber)
    OR ir.name_en ~* '_?pszenn'                            -- _Pszenna_ (wheat)
    OR ir.name_en ~* '\m(barley|wheat|spelt)\M'            -- English: barley, wheat, spelt
    OR ir.name_en ~* '(płatki|otręby)\s+owsiane'          -- Płatki Owsiane without underscore
  )
  -- Exclude 'Sodium Benzoate' matching 'oat' in 'benzoate'
  AND ir.name_en !~* 'benz';

-- 4c. Soybeans allergen
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:soybeans', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa WHERE pa.product_id = p.product_id AND pa.tag = 'en:soybeans')
  AND NOT EXISTS (SELECT 1 FROM product_allergen_info pa2 WHERE pa2.product_id = p.product_id)
  AND (
    ir.name_en ~* '(olej|białko|lecytyna)\s+sojow'  -- Olej/Białko/Lecytyna Sojowa
    OR ir.name_en ~* '_sojow'                         -- OFF-marked
    OR ir.name_en ~* '\msoybean'                       -- English
  );

-------------------------------------------------------------------------------
-- 5. Recalculate scores for all affected categories
--    score_category() recalculates unhealthiness_score, flags,
--    data_completeness_pct, and confidence
-------------------------------------------------------------------------------
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT DISTINCT p.category, p.country
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND (
            p.nutri_score_label IN ('A','B','C','D','E')  -- newly scored
            OR EXISTS (
              SELECT 1 FROM product_allergen_info pa
              WHERE pa.product_id = p.product_id
            )
          )
        ORDER BY p.country, p.category
    LOOP
        RAISE NOTICE 'Rescoring: % / %', rec.country, rec.category;
        CALL score_category(rec.category, 100, rec.country);
    END LOOP;
END $$;

-- 6. Final refresh of materialized views
SELECT refresh_all_materialized_views();

-------------------------------------------------------------------------------
-- 7. Verification queries
-------------------------------------------------------------------------------
DO $$
DECLARE
    v_unknown int;
    v_not_applicable int;
    v_allergen_inferred int;
    v_avg_completeness numeric;
BEGIN
    SELECT count(*) INTO v_unknown
    FROM products WHERE is_deprecated IS NOT TRUE AND nutri_score_label = 'UNKNOWN';

    SELECT count(*) INTO v_not_applicable
    FROM products WHERE is_deprecated IS NOT TRUE AND nutri_score_label = 'NOT-APPLICABLE';

    SELECT count(*) INTO v_allergen_inferred
    FROM product_allergen_info pa
    JOIN products p ON p.product_id = pa.product_id
    WHERE p.is_deprecated IS NOT TRUE;

    SELECT round(avg(data_completeness_pct)::numeric, 1) INTO v_avg_completeness
    FROM products WHERE is_deprecated IS NOT TRUE;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Phase 10.2 Results:';
    RAISE NOTICE '  Remaining UNKNOWN Nutri-Score: %', v_unknown;
    RAISE NOTICE '  Remaining NOT-APPLICABLE: %', v_not_applicable;
    RAISE NOTICE '  Total allergen records: %', v_allergen_inferred;
    RAISE NOTICE '  Avg data completeness: %%%', v_avg_completeness;
    RAISE NOTICE '========================================';
END $$;

COMMIT;

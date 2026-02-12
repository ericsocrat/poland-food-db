-- Fix Baby category miscategorization
-- IDs 3-87 (first OFF import batch) were all assigned "Baby" as a default category.
-- This migration re-categorizes the non-baby products to their correct categories.

BEGIN;

UPDATE public.products SET category = 'Drinks'            WHERE product_id = 3;
UPDATE public.products SET category = 'Condiments'        WHERE product_id = 4;
UPDATE public.products SET category = 'Drinks'            WHERE product_id = 5;
UPDATE public.products SET category = 'Alcohol'           WHERE product_id IN (6,7,8,9,11,12,13,14,15,16,17,18,19,20,21,22,25,26,27,28,29,30,32,33,34,35,36,37,38,39);
UPDATE public.products SET category = 'Condiments'        WHERE product_id IN (10,23,59,74,80,85);
UPDATE public.products SET category = 'Drinks'            WHERE product_id IN (43,50,51,52,58,63,65);
UPDATE public.products SET category = 'Dairy'             WHERE product_id IN (44,49,53,84,31,86);
UPDATE public.products SET category = 'Snacks'            WHERE product_id IN (45,76,79);
UPDATE public.products SET category = 'Sauces'            WHERE product_id IN (54,73);
UPDATE public.products SET category = 'Frozen & Prepared' WHERE product_id = 55;
UPDATE public.products SET category = 'Meat'              WHERE product_id IN (56,64,24,75);
UPDATE public.products SET category = 'Seafood & Fish'    WHERE product_id = 57;
UPDATE public.products SET category = 'Instant & Frozen'  WHERE product_id IN (62,70);
UPDATE public.products SET category = 'Sweets'            WHERE product_id IN (66,78);
UPDATE public.products SET category = 'Chips'             WHERE product_id = 87;

-- After re-categorization, Baby should contain only genuine baby food products:
-- 46 (BoboVita), 47 (BoboVita), 67 (Hipp), 68 (Nestle Gerber, deprecated),
-- 69 (Hipp), 71 (BoboVita), 72 (Hipp), 81 (Sinlac), 82 (Hipp), 83 (GutBio)

REFRESH MATERIALIZED VIEW public.v_product_confidence;

COMMIT;

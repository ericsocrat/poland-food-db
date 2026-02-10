-- Migration: Backfill prep_method for 134 NULL products in 5 categories
-- Created: 2026-02-10
--
-- Categories with NULL prep_method:
--   Bread (27)        → all baked
--   Chips (26)        → default fried, except known baked
--   Frozen & Prepared (27) → mixed (baked for pizzas, not-applicable for frozen veg/ice cream)
--   Seafood & Fish (27)    → smoked/marinated/not-applicable based on product type
--   Snacks (27)       → mixed (baked for crackers/wafers, not-applicable for bars/salads)

-- ──────────────────────────────────────────────────────────────
-- BREAD — all products are baked by definition
-- ──────────────────────────────────────────────────────────────
UPDATE products
SET prep_method = 'baked'
WHERE category = 'Bread'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

-- ──────────────────────────────────────────────────────────────
-- CHIPS — default to 'fried'; Crunchips Pieczone = baked
-- (the 2 already tagged as 'baked' are not NULL, so unaffected)
-- ──────────────────────────────────────────────────────────────

-- Known baked chip products
UPDATE products
SET prep_method = 'baked'
WHERE category = 'Chips'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND (product_name ILIKE '%pieczon%'
       OR product_name ILIKE '%baked%');

-- Everything else in Chips is fried
UPDATE products
SET prep_method = 'fried'
WHERE category = 'Chips'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

-- ──────────────────────────────────────────────────────────────
-- FROZEN & PREPARED — categorize by product type
-- ──────────────────────────────────────────────────────────────

-- Pizzas are baked
UPDATE products
SET prep_method = 'baked'
WHERE category = 'Frozen & Prepared'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND product_name ILIKE '%pizza%';

-- Pierogi are baked/fried but traditional prep is boiled — use 'not-applicable'
-- Frozen vegetables, ice cream, fruit — no cooking method inherent
UPDATE products
SET prep_method = 'not-applicable'
WHERE category = 'Frozen & Prepared'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

-- ──────────────────────────────────────────────────────────────
-- SEAFOOD & FISH — smoked, marinated, or not-applicable
-- ──────────────────────────────────────────────────────────────

-- Smoked fish (wędzony = smoked)
UPDATE products
SET prep_method = 'smoked'
WHERE category = 'Seafood & Fish'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND (product_name ILIKE '%wędzony%'
       OR product_name ILIKE '%wędzon%'
       OR product_name ILIKE '%smoked%');

-- Marinated fish (marynowane = marinated)
UPDATE products
SET prep_method = 'marinated'
WHERE category = 'Seafood & Fish'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND (product_name ILIKE '%marynow%'
       OR product_name ILIKE '%marinated%');

-- Remaining seafood (canned tuna, herrings in sauce, etc.)
UPDATE products
SET prep_method = 'not-applicable'
WHERE category = 'Seafood & Fish'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

-- ──────────────────────────────────────────────────────────────
-- SNACKS — baked for crackers/wafers/pretzels, not-applicable for bars/salads
-- ──────────────────────────────────────────────────────────────

-- Baked snacks: crackers, wafers, pretzels, croissants, bruschette
UPDATE products
SET prep_method = 'baked'
WHERE category = 'Snacks'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND (product_name ILIKE '%wafl%'      -- wafle = wafers
       OR product_name ILIKE '%wafer%'
       OR product_name ILIKE '%paluszki%' -- pretzels
       OR product_name ILIKE '%prezel%'
       OR product_name ILIKE '%pretzel%'
       OR product_name ILIKE '%cracker%'
       OR product_name ILIKE '%croissant%'
       OR product_name ILIKE '%bruschette%'
       OR product_name ILIKE '%słomka%'   -- puff stick pastry
       OR product_name ILIKE '%paleczki%');

-- Remaining snacks (protein bars, fruit bars, salads etc.)
UPDATE products
SET prep_method = 'not-applicable'
WHERE category = 'Snacks'
  AND is_deprecated IS NOT TRUE
  AND prep_method IS NULL;

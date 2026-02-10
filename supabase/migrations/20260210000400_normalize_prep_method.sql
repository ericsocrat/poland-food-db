-- Migration: normalize NULL prep_method → 'not-applicable'
-- Date: 2026-02-10
-- Reason: 526/560 products had NULL prep_method. For 14 categories where
--         preparation method is genuinely not applicable (Alcohol, Baby,
--         Breakfast & Grain-Based, Canned Goods, Cereals, Condiments, Dairy,
--         Drinks, Instant & Frozen, Meat, Nuts/Seeds/Legumes, Plant-Based,
--         Sauces, Sweets), set to 'not-applicable'.
--
--         5 categories retain NULL gaps (Bread, Chips, Frozen & Prepared,
--         Seafood & Fish, Snacks) — these have legitimate prep methods
--         (baked/fried) for some products and need manual data entry.
--
-- Scoring impact: NONE. Both NULL and 'not-applicable' hit the ELSE 50
--         branch in compute_unhealthiness_v31(). This is a data-quality
--         improvement only. A future scoring revision could map
--         'not-applicable' → 0 to remove the 4.5-point default penalty.

BEGIN;

UPDATE products
SET prep_method = 'not-applicable'
WHERE is_deprecated IS NOT TRUE
  AND prep_method IS NULL
  AND category IN (
    'Alcohol', 'Baby', 'Breakfast & Grain-Based', 'Canned Goods',
    'Cereals', 'Condiments', 'Dairy', 'Drinks', 'Instant & Frozen',
    'Meat', 'Nuts, Seeds & Legumes', 'Plant-Based & Alternatives',
    'Sauces', 'Sweets'
  );

COMMIT;

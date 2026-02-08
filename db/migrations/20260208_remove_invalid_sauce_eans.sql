-- Migration: Remove invalid EANs from Sauces category
-- Date: 2026-02-08
-- 
-- Issue: 5 Kotlin products and 1 Targroch product have invalid EAN checksums
-- These are pre-existing erroneous codes that fail GS1 Modulo-10 validation
--
-- Products affected:
--   Kotlin: 5 sauce products (Honey Mustard, Horseradish, Ketchup, Mayonnaise, Pickled Onions)
--   Targroch: 1 product (White Wine Vinegar)
--
-- Action: Set ean = NULL for all invalid codes (conservative data quality approach)
-- Products remain in database with all other attributes intact

\echo 'Removing 6 invalid EANs from Sauces category...'

-- Kotlin products (5 invalid EANs)
UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND product_name = 'Honey Mustard' AND ean = '5901044006413';
UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND product_name = 'Horseradish' AND ean = '5901044007809';
UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND product_name = 'Ketchup Pikantny' AND ean = '5901044006086';
UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND product_name = 'Light Mayonnaise' AND ean = '5901044006239';
UPDATE products SET ean = NULL WHERE brand = 'Kotlin' AND product_name = 'Pickled Onions' AND ean = '5901044007205';

-- Targroch product (1 invalid EAN)
UPDATE products SET ean = NULL WHERE brand = 'Targroch' AND product_name = 'White Wine Vinegar' AND ean = '5903229004518';

\echo 'Migration complete: 6 invalid EANs removed from Sauces category'

-- Migration: Add verified EANs to Meat category
-- Date: 2026-02-08
-- Products: 5 verified EANs (17.9% coverage = 5/28)
--
-- Validation: All EANs verified with GS1 Modulo-10 checksum
-- Note: Low success rate due to limited API coverage for Polish specialty meat brands
-- Success rate by brand:
--   Drosed:      1/1  (100%)
--   Krakus:      1/4  (25%)
--   Morliny:     1/5  (20%)
--   Tarczyński:  2/5  (40%)

\echo 'Adding 5 verified EANs to Meat category...'

UPDATE products SET ean = '5901204000733' WHERE brand = 'Drosed' AND product_name = 'Drosed Pasztet Podlaski' AND category = 'Meat';
UPDATE products SET ean = '0226201603202' WHERE brand = 'Krakus' AND product_name = 'Krakus Szynka Konserwowa' AND category = 'Meat';
UPDATE products SET ean = '5902659896735' WHERE brand = 'Morliny' AND product_name = 'Morliny Boczek Wędzony' AND category = 'Meat';
UPDATE products SET ean = '5908230522208' WHERE brand = 'Tarczyński' AND product_name = 'Tarczyński Kabanosy Exclusive' AND category = 'Meat';
UPDATE products SET ean = '5908230529429' WHERE brand = 'Tarczyński' AND product_name = 'Tarczyński Kabanosy Klasyczne' AND category = 'Meat';

\echo 'Migration complete: 5 EANs added to Meat category'
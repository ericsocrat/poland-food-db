-- Migration: Add verified EANs to Bread category
-- Date: 2026-02-08
-- Products: 20 verified EANs (71.4% coverage = 20/28)
--
-- Validation: All EANs verified with GS1 Modulo-10 checksum
-- Note: 1 invalid EAN removed (Oskroba Chleb Graham - checksum failed)
-- Success rate by brand:
--   Carrefour:   1/2  (50%)
--   Klara:       1/1  (100%)
--   Mestemacher: 5/5  (100%)
--   Oskroba:     5/9  (56%)
--   Pano:        4/4  (100%)
--   Tastino:     1/2  (50%)
--   Wasa:        3/3  (100%)

\echo 'Adding 20 verified EANs to Bread category...'

UPDATE products SET ean = '5905784303253' WHERE brand = 'Carrefour' AND product_name = 'Carrefour Pieczywo Chrupkie Kukurydziane' AND category = 'Bread';
UPDATE products SET ean = '3856016906945' WHERE brand = 'Klara' AND product_name = 'Klara American Sandwich Toast XXL' AND category = 'Bread';
UPDATE products SET ean = '5900585000110' WHERE brand = 'Mestemacher' AND product_name = 'Mestemacher Chleb Razowy' AND category = 'Bread';
UPDATE products SET ean = '5900585000028' WHERE brand = 'Mestemacher' AND product_name = 'Mestemacher Chleb Wielozbożowy Żytni' AND category = 'Bread';
UPDATE products SET ean = '5900585001810' WHERE brand = 'Mestemacher' AND product_name = 'Mestemacher Chleb Ziarnisty' AND category = 'Bread';
UPDATE products SET ean = '5900585000158' WHERE brand = 'Mestemacher' AND product_name = 'Mestemacher Chleb Żytni' AND category = 'Bread';
UPDATE products SET ean = '5900585000059' WHERE brand = 'Mestemacher' AND product_name = 'Mestemacher Pumpernikiel' AND category = 'Bread';
UPDATE products SET ean = '5900340007231' WHERE brand = 'Oskroba' AND product_name = 'Oskroba Chleb Baltonowski' AND category = 'Bread';
UPDATE products SET ean = '5900340000423' WHERE brand = 'Oskroba' AND product_name = 'Oskroba Chleb Litewski' AND category = 'Bread';
UPDATE products SET ean = '5900340000935' WHERE brand = 'Oskroba' AND product_name = 'Oskroba Chleb Pszenno-Żytni' AND category = 'Bread';
UPDATE products SET ean = '5900340015342' WHERE brand = 'Oskroba' AND product_name = 'Oskroba Chleb Żytni Pełnoziarnisty' AND category = 'Bread';
UPDATE products SET ean = '5900340003615' WHERE brand = 'Oskroba' AND product_name = 'Oskroba Chleb Żytni Razowy' AND category = 'Bread';
UPDATE products SET ean = '5900864727806' WHERE brand = 'Pano' AND product_name = 'Pano Bułeczki Śniadaniowe' AND category = 'Bread';
UPDATE products SET ean = '5900928032358' WHERE brand = 'Pano' AND product_name = 'Pano Tortilla' AND category = 'Bread';
UPDATE products SET ean = '5900340003912' WHERE brand = 'Pano' AND product_name = 'Pano Tost Maślany' AND category = 'Bread';
UPDATE products SET ean = '5900340012815' WHERE brand = 'Pano' AND product_name = 'Pano Tost Pełnoziarnisty' AND category = 'Bread';
UPDATE products SET ean = '4056489918202' WHERE brand = 'Tastino' AND product_name = 'Tastino Tortilla Wraps' AND category = 'Bread';
UPDATE products SET ean = '7300400115889' WHERE brand = 'Wasa' AND product_name = 'Wasa Lekkie 7 Ziaren' AND category = 'Bread';
UPDATE products SET ean = '7300400118101' WHERE brand = 'Wasa' AND product_name = 'Wasa Original' AND category = 'Bread';
UPDATE products SET ean = '7300400481441' WHERE brand = 'Wasa' AND product_name = 'Wasa Pieczywo z Błonnikiem' AND category = 'Bread';

\echo 'Migration complete: 20 EANs added to Bread category'
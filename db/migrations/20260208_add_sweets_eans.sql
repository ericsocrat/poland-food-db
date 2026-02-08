-- Migration: Add verified EANs to Sweets category
-- Date: 2026-02-08
-- Products: 21 verified EANs (75% coverage = 21/28)
--
-- Validation: All EANs verified with GS1 Modulo-10 checksum
-- Success rate by brand:
--   Delicje:     1/1  (100%)
--   Goplana:     0/1  (0%)
--   Grześki:     1/2  (50%)
--   Haribo:      1/1  (100%)
--   Kinder:      2/3  (67%)
--   Milka:       2/2  (100%)
--   Prince Polo: 2/2  (100%)
--   Snickers:    1/1  (100%)
--   Twix:        1/1  (100%)
--   Wawel:       5/6  (83%)
--   Wedel:       6/7  (86%)

\echo 'Adding {valid_count} verified EANs to Sweets category...'

UPDATE products SET ean = '5906747308469' WHERE brand = 'Delicje' AND product_name = 'Delicje Szampańskie Wiśniowe' AND category = 'Sweets';
UPDATE products SET ean = '5900394006181' WHERE brand = 'Grześki' AND product_name = 'Grześki Wafer Toffee' AND category = 'Sweets';
UPDATE products SET ean = '8691216020627' WHERE brand = 'Haribo' AND product_name = 'Haribo Goldbären' AND category = 'Sweets';
UPDATE products SET ean = '8000500180709' WHERE brand = 'Kinder' AND product_name = 'Kinder Bueno Mini' AND category = 'Sweets';
UPDATE products SET ean = '8000500269169' WHERE brand = 'Kinder' AND product_name = 'Kinder Cards' AND category = 'Sweets';
UPDATE products SET ean = '7622400883033' WHERE brand = 'Milka' AND product_name = 'Milka Alpenmilch' AND category = 'Sweets';
UPDATE products SET ean = '3045140280902' WHERE brand = 'Milka' AND product_name = 'Milka Trauben-Nuss' AND category = 'Sweets';
UPDATE products SET ean = '7622210309792' WHERE brand = 'Prince Polo' AND product_name = 'Prince Polo XXL Classic' AND category = 'Sweets';
UPDATE products SET ean = '7622210309990' WHERE brand = 'Prince Polo' AND product_name = 'Prince Polo XXL Mleczne' AND category = 'Sweets';
UPDATE products SET ean = '5000159461122' WHERE brand = 'Snickers' AND product_name = 'Snickers Bar' AND category = 'Sweets';
UPDATE products SET ean = '5000159459228' WHERE brand = 'Twix' AND product_name = 'Twix Twin' AND category = 'Sweets';
UPDATE products SET ean = '5900102025473' WHERE brand = 'Wawel' AND product_name = 'Wawel Czekolada Gorzka 70%' AND category = 'Sweets';
UPDATE products SET ean = '5900102009138' WHERE brand = 'Wawel' AND product_name = 'Wawel Kasztanki Nadziewana' AND category = 'Sweets';
UPDATE products SET ean = '5900102022212' WHERE brand = 'Wawel' AND product_name = 'Wawel Mleczna z Rodzynkami i Orzeszkami' AND category = 'Sweets';
UPDATE products SET ean = '5900102021215' WHERE brand = 'Wawel' AND product_name = 'Wawel Tiramisu Nadziewana' AND category = 'Sweets';
UPDATE products SET ean = '5901588018195' WHERE brand = 'Wedel' AND product_name = 'Wedel Czekolada Gorzka 80%' AND category = 'Sweets';
UPDATE products SET ean = '5901588016443' WHERE brand = 'Wedel' AND product_name = 'Wedel Czekolada Mleczna' AND category = 'Sweets';
UPDATE products SET ean = '5901588016443' WHERE brand = 'Wedel' AND product_name = 'Wedel Mleczna Truskawkowa' AND category = 'Sweets';
UPDATE products SET ean = '5901588016740' WHERE brand = 'Wedel' AND product_name = 'Wedel Mleczna z Bakaliami' AND category = 'Sweets';
UPDATE products SET ean = '5901588017990' WHERE brand = 'Wedel' AND product_name = 'Wedel Mleczna z Orzechami' AND category = 'Sweets';
UPDATE products SET ean = '5901588058658' WHERE brand = 'Wedel' AND product_name = 'Wedel Ptasie Mleczko Waniliowe' AND category = 'Sweets';

\echo 'Migration complete: 21 EANs added to Sweets category'
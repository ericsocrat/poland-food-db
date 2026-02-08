-- Migration: Add verified EANs to Nuts, Seeds & Legumes category
-- Date: 2026-02-08
-- Products: 8 verified EANs (29% coverage = 8/27)
--
-- Validation: All EANs verified with GS1 Modulo-10 checksum
-- Note: Limited API coverage for Polish specialty legumes/seeds brands
-- Success rate by brand:
--   Alesto:       2/6  (33%)
--   Bakalland:    2/3  (67%)
--   Fasting:      0/2  (0%)
--   Helio:        0/3  (0%)
--   Naturavena:   2/5  (40%)
--   Sante:        2/4  (50%)
--   Społem:       0/2  (0%)
--   Targroch:     0/2  (0%)

\echo 'Adding 8 verified EANs to Nuts, Seeds & Legumes category...'

UPDATE products SET ean = '4335619141612' WHERE brand = 'Alesto' AND product_name = 'Alesto Migdały' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '4335619141544' WHERE brand = 'Alesto' AND product_name = 'Alesto Orzechy Laskowe' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5900749020091' WHERE brand = 'Bakalland' AND product_name = 'Bakalland Migdały' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5900749020022' WHERE brand = 'Bakalland' AND product_name = 'Bakalland Orzechy Laskowe' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5908445474514' WHERE brand = 'Naturavena' AND product_name = 'Naturavena Ciecierzyca' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5906750251233' WHERE brand = 'Naturavena' AND product_name = 'Naturavena Fasola Czerwona' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5900617016492' WHERE brand = 'Sante' AND product_name = 'Sante Nasiona Chia' AND category = 'Nuts, Seeds & Legumes';
UPDATE products SET ean = '5900617013613' WHERE brand = 'Sante' AND product_name = 'Sante Siemię Lniane' AND category = 'Nuts, Seeds & Legumes';

\echo 'Migration complete: 8 EANs added to Nuts, Seeds & Legumes category'
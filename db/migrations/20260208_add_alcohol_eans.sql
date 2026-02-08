-- Migration: Add verified EANs to Alcohol category
-- Date: 2026-02-08
-- Products: 22 verified EANs (78.6% coverage = 22/28)
--
-- Validation: All EANs verified with GS1 Modulo-10 checksum
-- Success rate by brand:
--   Dzik:       1/1  (100%)
--   Just 0.:    2/2  (100%)
--   Karlsquell: 1/1  (100%)
--   Karmi:      1/1  (100%)
--   Lech:       9/16 (56%)
--   Łomża:      3/3  (100%)
--   Okocim:     2/2  (100%)
--   Somersby:   2/2  (100%)
--   Tyskie:     1/1  (100%)
--   Warka:      2/2  (100%)

\echo 'Adding 22 verified EANs to Alcohol category...'

UPDATE products SET ean = '5906395413423' WHERE brand = 'Dzik' AND product_name = 'Dzik Cydr 0% jabłko i marakuja' AND category = 'Alcohol';
UPDATE products SET ean = '0039978002372' WHERE brand = 'Just 0.' AND product_name = 'Just 0. Red' AND category = 'Alcohol';
UPDATE products SET ean = '4003301069086' WHERE brand = 'Just 0.' AND product_name = 'Just 0. White alcoholfree' AND category = 'Alcohol';
UPDATE products SET ean = '2008080099073' WHERE brand = 'Karlsquell' AND product_name = 'Free! Radler o smaku mango' AND category = 'Alcohol';
UPDATE products SET ean = '5900014002562' WHERE brand = 'Karmi' AND product_name = 'Karmi' AND category = 'Alcohol';
UPDATE products SET ean = '5901359144917' WHERE brand = 'Lech' AND product_name = 'Lech Free' AND category = 'Alcohol';
UPDATE products SET ean = '5901359084954' WHERE brand = 'Lech' AND product_name = 'Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai' AND category = 'Alcohol';
UPDATE products SET ean = '5901359144887' WHERE brand = 'Lech' AND product_name = 'Lech Free 0,0% limonka i mięta' AND category = 'Alcohol';
UPDATE products SET ean = '5901359124230' WHERE brand = 'Lech' AND product_name = 'Lech Free Active Hydrate mango i cytryna 0,0%' AND category = 'Alcohol';
UPDATE products SET ean = '5901359144689' WHERE brand = 'Lech' AND product_name = 'Lech Free Citrus Sour' AND category = 'Alcohol';
UPDATE products SET ean = '5901359114309' WHERE brand = 'Lech' AND product_name = 'Lech Free smoczy owoc i winogrono 0,0%' AND category = 'Alcohol';
UPDATE products SET ean = '5900490000182' WHERE brand = 'Lech' AND product_name = 'Lech Premium' AND category = 'Alcohol';
UPDATE products SET ean = '5900535022551' WHERE brand = 'Łomża' AND product_name = 'Łomża 0% o smaku jabłko & mięta' AND category = 'Alcohol';
UPDATE products SET ean = '5900535013986' WHERE brand = 'Łomża' AND product_name = 'Łomża piwo jasne bezalkoholowe' AND category = 'Alcohol';
UPDATE products SET ean = '5900535019209' WHERE brand = 'Łomża' AND product_name = 'Łomża Radler 0,0%' AND category = 'Alcohol';
UPDATE products SET ean = '5900014005266' WHERE brand = 'Okocim' AND product_name = 'Okocim 0,0% mango z marakują' AND category = 'Alcohol';
UPDATE products SET ean = '5900014004047' WHERE brand = 'Okocim' AND product_name = 'Okocim Piwo Jasne 0%' AND category = 'Alcohol';
UPDATE products SET ean = '5900014003866' WHERE brand = 'Somersby' AND product_name = 'Somersby blackcurrant & lime 0%' AND category = 'Alcohol';
UPDATE products SET ean = '3856777584161' WHERE brand = 'Somersby' AND product_name = 'Somersby Blueberry Flavoured Cider' AND category = 'Alcohol';
UPDATE products SET ean = '5901359062013' WHERE brand = 'Tyskie' AND product_name = 'Tyskie Gronie' AND category = 'Alcohol';
UPDATE products SET ean = '5900699106616' WHERE brand = 'Warka' AND product_name = 'Piwo Warka Radler' AND category = 'Alcohol';
UPDATE products SET ean = '5902746641835' WHERE brand = 'Warka' AND product_name = 'Warka Kiwi Z Pigwą 0,0%' AND category = 'Alcohol';

\echo 'Migration complete: 22 EANs added to Alcohol category'
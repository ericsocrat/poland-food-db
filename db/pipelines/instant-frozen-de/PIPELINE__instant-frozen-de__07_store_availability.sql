-- PIPELINE (Instant & Frozen): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-04

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Davert', 'Noodle Cup - Thailändisch', 'dm'),
    ('Kania', 'Instant Nudeln Gemüse Geschmack', 'Lidl'),
    ('Asia Green Garden', 'Instantnudeln Hühnergeschmack 5er-Pack', 'Aldi'),
    ('Asia Green Garden', 'Udon-Nudeln mit Soja-Ingwer-Soße', 'Aldi'),
    ('Asia Green Garden', 'Bratnudeln - Thailändische Art', 'Aldi'),
    ('Asia Green Garden', 'Instant-Nudeln Beef', 'Aldi'),
    ('Asia Green Garden', 'Udon Noodle Bowl', 'Aldi'),
    ('Asia Green Garden', 'Bratnudeln - Entengeschmack', 'Aldi'),
    ('Asia Green Garden', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 'Aldi'),
    ('Asia Green Garden', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 'REWE'),
    ('Asia Green Garden', 'Bratnudeln - Chili', 'Aldi'),
    ('Unknown', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 'Aldi'),
    ('Knorr', 'Hühnersuppe', 'Edeka'),
    ('Knorr', 'Hühnersuppe', 'REWE'),
    ('Buldak', 'Buldak HOT Chicken Flavour Ramen', 'Lidl'),
    ('Yum Yum', 'Instant Nudeln, Japanese Chicken Flavor', 'REWE'),
    ('Nongshim', 'Soon Veggie Ramyun Noodle', 'REWE'),
    ('Maggi', 'Saucy Noodles Teriyaki', 'Edeka'),
    ('Maggi', 'Saucy Noodles Teriyaki', 'REWE'),
    ('Maggi', 'Saucy Noodles Teriyaki', 'Kaufland'),
    ('Knorr', 'Asia Noodels Beef Taste', 'Netto'),
    ('Maggi', 'Noodle Cup - Chicken Taste', 'Real'),
    ('Knorr', 'Asia Noodles Chicken Taste', 'Netto'),
    ('Buldak', 'Buldak 2x Spicy', 'REWE'),
    ('Buldak', 'Buldak 2x Spicy', 'Netto'),
    ('Maggi', 'Saucy Noodles Sesame Chicken Taste', 'Penny'),
    ('Nissin', 'Soba Cup Noodles', 'Edeka'),
    ('Nissin', 'Soba Cup Noodles', 'REWE'),
    ('Nongshim', 'Nouilles Chapaghetti Nongshim', 'Norma'),
    ('Nissin', 'Cup Noodles Big Soba Wok Style', 'Netto'),
    ('Nissin', 'Cup Noodles Big Soba Wok Style', 'Kaufland'),
    ('Thai Chef', 'Thaisuppe, Curry Huhn', 'REWE'),
    ('Knorr', 'Spaghetteria Spinaci', 'REWE'),
    ('Knorr', 'Spaghetteria Spinaci', 'Penny'),
    ('Maggi', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'Edeka'),
    ('Maggi', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'Kaufland'),
    ('Indomie', 'Noodles', 'Lidl'),
    ('Maggi', 'Asia Noodle Cup Duck', 'REWE'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'Aldi'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'Lidl'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'Edeka'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'REWE'),
    ('Maggi', 'Saucy Noodles Sweet Chili', 'REWE'),
    ('Nongshim', 'Shin Cup Gourmet Spicy Noodle Soup', 'Real'),
    ('Nissin', 'Soba Yakitori Chicken', 'Real'),
    ('Knorr', 'Asia Noodles Currygeschmack', 'Netto')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

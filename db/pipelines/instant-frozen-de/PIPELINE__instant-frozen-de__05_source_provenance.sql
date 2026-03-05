-- PIPELINE (Instant & Frozen): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Davert', 'Noodle Cup - Thailändisch', 'https://world.openfoodfacts.org/product/4019339646052', '4019339646052'),
    ('Kania', 'Instant Nudeln Gemüse Geschmack', 'https://world.openfoodfacts.org/product/4056489915287', '4056489915287'),
    ('Asia Green Garden', 'Instantnudeln Hühnergeschmack 5er-Pack', 'https://world.openfoodfacts.org/product/4061462956621', '4061462956621'),
    ('Asia Green Garden', 'Udon-Nudeln mit Soja-Ingwer-Soße', 'https://world.openfoodfacts.org/product/4061461867683', '4061461867683'),
    ('Asia Green Garden', 'Bratnudeln - Thailändische Art', 'https://world.openfoodfacts.org/product/4061463779526', '4061463779526'),
    ('Davert', 'Noodle Brokkoli Käse Sauce', 'https://world.openfoodfacts.org/product/4019339646014', '4019339646014'),
    ('Asia Green Garden', 'Instant Nudeln Gemüsegeschmack', 'https://world.openfoodfacts.org/product/4061458055352', '4061458055352'),
    ('Asia Green Garden', 'Instant-Reisnudeln mit Hühnerfleischgeschmack', 'https://world.openfoodfacts.org/product/4061462213427', '4061462213427'),
    ('Asia Green Garden', 'Pho Chat Instant-Reisnudeln mit Gemüsegeschmack', 'https://world.openfoodfacts.org/product/4061462213441', '4061462213441'),
    ('Asia Green Garden', 'Udon-Nudel-Bowl mit Sauce nach Kimchi Art Gewürzt', 'https://world.openfoodfacts.org/product/4068706482878', '4068706482878'),
    ('Aldi', 'Green Curry Noodles / Grüne Curry Nudeln', 'https://world.openfoodfacts.org/product/4061459672770', '4061459672770'),
    ('Asia Green Garden', 'Instant-Nudeln Beef', 'https://world.openfoodfacts.org/product/4061462213090', '4061462213090'),
    ('Asia Green Garden', 'Udon Noodle Bowl', 'https://world.openfoodfacts.org/product/4047247979535', '4047247979535'),
    ('Asia Green Garden', 'Bratnudeln - Entengeschmack', 'https://world.openfoodfacts.org/product/4061463779533', '4061463779533'),
    ('Asia Green Garden', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 'https://world.openfoodfacts.org/product/4061461337292', '4061461337292'),
    ('Asia Green Garden', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 'https://world.openfoodfacts.org/product/4061462213403', '4061462213403'),
    ('Asia Green Garden', 'Bratnudeln - Chili', 'https://world.openfoodfacts.org/product/4061463779632', '4061463779632'),
    ('Unknown', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 'https://world.openfoodfacts.org/product/4061461060251', '4061461060251'),
    ('Bamboo Garden', 'Mie Nudeln', 'https://world.openfoodfacts.org/product/4023900545446', '4023900545446'),
    ('Nissin', 'Thai Roasted Chicken', 'https://world.openfoodfacts.org/product/4016810470106', '4016810470106'),
    ('Knorr', 'Hühnersuppe', 'https://world.openfoodfacts.org/product/8712566332137', '8712566332137'),
    ('Davert', 'Noodle Cup No. 11 Linsen Bolognese', 'https://world.openfoodfacts.org/product/4019339646113', '4019339646113'),
    ('Kania', 'Instant Nudeln Rind', 'https://world.openfoodfacts.org/product/4056489915263', '4056489915263'),
    ('Davert', 'Noodle Cup No. 7', 'https://world.openfoodfacts.org/product/4019339646007', '4019339646007'),
    ('Lien Ying Asian-Spirit', 'Eier-Mie-Nudeln', 'https://world.openfoodfacts.org/product/4013200880910', '4013200880910'),
    ('Aldi', 'Asia-Instant-Noodles-Cup - Curry', 'https://world.openfoodfacts.org/product/4061464906334', '4061464906334'),
    ('Reeva', 'Instant Nudeln gebratenes Hähnchen', 'https://world.openfoodfacts.org/product/4820179258561', '4820179258561'),
    ('Buldak', 'Buldak HOT Chicken Flavour Ramen', 'https://world.openfoodfacts.org/product/8801073116467', '8801073116467'),
    ('Yum Yum', 'Instant Nudeln, Japanese Chicken Flavor', 'https://world.openfoodfacts.org/product/8852018101154', '8852018101154'),
    ('Nongshim', 'Soon Veggie Ramyun Noodle', 'https://world.openfoodfacts.org/product/8801043022705', '8801043022705'),
    ('Maggi', 'Saucy Noodles Teriyaki', 'https://world.openfoodfacts.org/product/7613037683660', '7613037683660'),
    ('Knorr', 'Asia Noodels Beef Taste', 'https://world.openfoodfacts.org/product/8720182777294', '8720182777294'),
    ('Maggi', 'Noodle Cup - Chicken Taste', 'https://world.openfoodfacts.org/product/7613036680028', '7613036680028'),
    ('Knorr', 'Asia Noodles Chicken Taste', 'https://world.openfoodfacts.org/product/8720182777225', '8720182777225'),
    ('Buldak', 'Buldak 2x Spicy', 'https://world.openfoodfacts.org/product/8801073113428', '8801073113428'),
    ('Maggi', 'Saucy Noodles Sesame Chicken Taste', 'https://world.openfoodfacts.org/product/7613037683417', '7613037683417'),
    ('Nissin', 'Soba Cup Noodles', 'https://world.openfoodfacts.org/product/5997523313272', '5997523313272'),
    ('Nongshim', 'Nouilles Chapaghetti Nongshim', 'https://world.openfoodfacts.org/product/8801043157728', '8801043157728'),
    ('Nissin', 'Cup Noodles Big Soba Wok Style', 'https://world.openfoodfacts.org/product/5997523315832', '5997523315832'),
    ('Maggi', 'Gebratene Nudeln Ente', 'https://world.openfoodfacts.org/product/7613035897427', '7613035897427'),
    ('Thai Chef', 'Thaisuppe, Curry Huhn', 'https://world.openfoodfacts.org/product/8852523206184', '8852523206184'),
    ('Knorr', 'Spaghetteria Spinaci', 'https://world.openfoodfacts.org/product/8720182406354', '8720182406354'),
    ('Maggi', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'https://world.openfoodfacts.org/product/7613031722594', '7613031722594'),
    ('Indomie', 'Noodles', 'https://world.openfoodfacts.org/product/8994963003173', '8994963003173'),
    ('Maggi', 'Asia Noodle Cup Duck', 'https://world.openfoodfacts.org/product/7613036679978', '7613036679978'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'https://world.openfoodfacts.org/product/8852018511069', '8852018511069'),
    ('Ajinomoto', 'Pork Ramen', 'https://world.openfoodfacts.org/product/5901384504731', '5901384504731'),
    ('Maggi', 'Saucy Noodles Sweet Chili', 'https://world.openfoodfacts.org/product/7613037683608', '7613037683608'),
    ('Nongshim', 'Shin Cup Gourmet Spicy Noodle Soup', 'https://world.openfoodfacts.org/product/8801043031011', '8801043031011'),
    ('Nissin', 'Soba Yakitori Chicken', 'https://world.openfoodfacts.org/product/5997523313234', '5997523313234'),
    ('Knorr', 'Asia Noodles Currygeschmack', 'https://world.openfoodfacts.org/product/8714100679852', '8714100679852')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE;

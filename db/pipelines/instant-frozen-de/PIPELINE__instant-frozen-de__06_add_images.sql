-- PIPELINE (Instant & Frozen): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Instant & Frozen'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Davert', 'Noodle Cup - Thailändisch', 'https://images.openfoodfacts.org/images/products/401/933/964/6052/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019339646052', 'front_4019339646052'),
    ('Kania', 'Instant Nudeln Gemüse Geschmack', 'https://images.openfoodfacts.org/images/products/405/648/991/5287/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489915287', 'front_4056489915287'),
    ('Asia Green Garden', 'Instantnudeln Hühnergeschmack 5er-Pack', 'https://images.openfoodfacts.org/images/products/406/146/295/6621/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462956621', 'front_4061462956621'),
    ('Asia Green Garden', 'Udon-Nudeln mit Soja-Ingwer-Soße', 'https://images.openfoodfacts.org/images/products/406/146/186/7683/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461867683', 'front_4061461867683'),
    ('Asia Green Garden', 'Bratnudeln - Thailändische Art', 'https://images.openfoodfacts.org/images/products/406/146/377/9526/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463779526', 'front_4061463779526'),
    ('Davert', 'Noodle Brokkoli Käse Sauce', 'https://images.openfoodfacts.org/images/products/401/933/964/6014/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019339646014', 'front_4019339646014'),
    ('Asia Green Garden', 'Instant Nudeln Gemüsegeschmack', 'https://images.openfoodfacts.org/images/products/406/145/805/5352/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458055352', 'front_4061458055352'),
    ('Asia Green Garden', 'Instant-Reisnudeln mit Hühnerfleischgeschmack', 'https://images.openfoodfacts.org/images/products/406/146/221/3427/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462213427', 'front_4061462213427'),
    ('Asia Green Garden', 'Pho Chat Instant-Reisnudeln mit Gemüsegeschmack', 'https://images.openfoodfacts.org/images/products/406/146/221/3441/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462213441', 'front_4061462213441'),
    ('Asia Green Garden', 'Udon-Nudel-Bowl mit Sauce nach Kimchi Art Gewürzt', 'https://images.openfoodfacts.org/images/products/406/870/648/2878/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706482878', 'front_4068706482878'),
    ('Aldi', 'Green Curry Noodles / Grüne Curry Nudeln', 'https://images.openfoodfacts.org/images/products/406/145/967/2770/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459672770', 'front_4061459672770'),
    ('Asia Green Garden', 'Instant-Nudeln Beef', 'https://images.openfoodfacts.org/images/products/406/146/221/3090/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462213090', 'front_4061462213090'),
    ('Asia Green Garden', 'Udon Noodle Bowl', 'https://images.openfoodfacts.org/images/products/404/724/797/9535/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247979535', 'front_4047247979535'),
    ('Asia Green Garden', 'Bratnudeln - Entengeschmack', 'https://images.openfoodfacts.org/images/products/406/146/377/9533/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463779533', 'front_4061463779533'),
    ('Asia Green Garden', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 'https://images.openfoodfacts.org/images/products/406/146/133/7292/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461337292', 'front_4061461337292'),
    ('Asia Green Garden', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 'https://images.openfoodfacts.org/images/products/406/146/221/3403/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462213403', 'front_4061462213403'),
    ('Asia Green Garden', 'Bratnudeln - Chili', 'https://images.openfoodfacts.org/images/products/406/146/377/9632/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463779632', 'front_4061463779632'),
    ('Unknown', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 'https://images.openfoodfacts.org/images/products/406/146/106/0251/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461060251', 'front_4061461060251'),
    ('Bamboo Garden', 'Mie Nudeln', 'https://images.openfoodfacts.org/images/products/402/390/054/5446/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023900545446', 'front_4023900545446'),
    ('Nissin', 'Thai Roasted Chicken', 'https://images.openfoodfacts.org/images/products/401/681/047/0106/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016810470106', 'front_4016810470106'),
    ('Knorr', 'Hühnersuppe', 'https://images.openfoodfacts.org/images/products/871/256/633/2137/front_de.75.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712566332137', 'front_8712566332137'),
    ('Davert', 'Noodle Cup No. 11 Linsen Bolognese', 'https://images.openfoodfacts.org/images/products/401/933/964/6113/front_en.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019339646113', 'front_4019339646113'),
    ('Kania', 'Instant Nudeln Rind', 'https://images.openfoodfacts.org/images/products/405/648/991/5263/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489915263', 'front_4056489915263'),
    ('Davert', 'Noodle Cup No. 7', 'https://images.openfoodfacts.org/images/products/401/933/964/6007/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019339646007', 'front_4019339646007'),
    ('Lien Ying Asian-Spirit', 'Eier-Mie-Nudeln', 'https://images.openfoodfacts.org/images/products/401/320/088/0910/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013200880910', 'front_4013200880910'),
    ('Reeva', 'Instant Nudeln gebratenes Hähnchen', 'https://images.openfoodfacts.org/images/products/482/017/925/8561/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4820179258561', 'front_4820179258561'),
    ('Buldak', 'Buldak HOT Chicken Flavour Ramen', 'https://images.openfoodfacts.org/images/products/880/107/311/6467/front_en.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801073116467', 'front_8801073116467'),
    ('Yum Yum', 'Instant Nudeln, Japanese Chicken Flavor', 'https://images.openfoodfacts.org/images/products/885/201/810/1154/front_en.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 8852018101154', 'front_8852018101154'),
    ('Nongshim', 'Soon Veggie Ramyun Noodle', 'https://images.openfoodfacts.org/images/products/880/104/302/2705/front_en.105.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043022705', 'front_8801043022705'),
    ('Maggi', 'Saucy Noodles Teriyaki', 'https://images.openfoodfacts.org/images/products/761/303/768/3660/front_en.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037683660', 'front_7613037683660'),
    ('Knorr', 'Asia Noodels Beef Taste', 'https://images.openfoodfacts.org/images/products/872/018/277/7294/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720182777294', 'front_8720182777294'),
    ('Maggi', 'Noodle Cup - Chicken Taste', 'https://images.openfoodfacts.org/images/products/761/303/668/0028/front_de.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036680028', 'front_7613036680028'),
    ('Knorr', 'Asia Noodles Chicken Taste', 'https://images.openfoodfacts.org/images/products/872/018/277/7225/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720182777225', 'front_8720182777225'),
    ('Buldak', 'Buldak 2x Spicy', 'https://images.openfoodfacts.org/images/products/880/107/311/3428/front_en.150.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801073113428', 'front_8801073113428'),
    ('Maggi', 'Saucy Noodles Sesame Chicken Taste', 'https://images.openfoodfacts.org/images/products/761/303/768/3417/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037683417', 'front_7613037683417'),
    ('Nissin', 'Soba Cup Noodles', 'https://images.openfoodfacts.org/images/products/599/752/331/3272/front_en.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 5997523313272', 'front_5997523313272'),
    ('Nongshim', 'Nouilles Chapaghetti Nongshim', 'https://images.openfoodfacts.org/images/products/880/104/315/7728/front_en.120.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043157728', 'front_8801043157728'),
    ('Nissin', 'Cup Noodles Big Soba Wok Style', 'https://images.openfoodfacts.org/images/products/599/752/331/5832/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5997523315832', 'front_5997523315832'),
    ('Maggi', 'Gebratene Nudeln Ente', 'https://images.openfoodfacts.org/images/products/761/303/589/7427/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613035897427', 'front_7613035897427'),
    ('Thai Chef', 'Thaisuppe, Curry Huhn', 'https://images.openfoodfacts.org/images/products/885/252/320/6184/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 8852523206184', 'front_8852523206184'),
    ('Knorr', 'Spaghetteria Spinaci', 'https://images.openfoodfacts.org/images/products/872/018/240/6354/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720182406354', 'front_8720182406354'),
    ('Maggi', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'https://images.openfoodfacts.org/images/products/761/303/172/2594/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613031722594', 'front_7613031722594'),
    ('Indomie', 'Noodles', 'https://images.openfoodfacts.org/images/products/899/496/300/3173/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 8994963003173', 'front_8994963003173'),
    ('Maggi', 'Asia Noodle Cup Duck', 'https://images.openfoodfacts.org/images/products/761/303/667/9978/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036679978', 'front_7613036679978'),
    ('Yum Yum', 'Nouilles instantanées au goût de légumes, pack de 5', 'https://images.openfoodfacts.org/images/products/885/201/851/1069/front_fr.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 8852018511069', 'front_8852018511069'),
    ('Ajinomoto', 'Pork Ramen', 'https://images.openfoodfacts.org/images/products/590/138/450/4731/front_en.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384504731', 'front_5901384504731'),
    ('Maggi', 'Saucy Noodles Sweet Chili', 'https://images.openfoodfacts.org/images/products/761/303/768/3608/front_en.193.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037683608', 'front_7613037683608'),
    ('Nongshim', 'Shin Cup Gourmet Spicy Noodle Soup', 'https://images.openfoodfacts.org/images/products/880/104/303/1011/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043031011', 'front_8801043031011'),
    ('Nissin', 'Soba Yakitori Chicken', 'https://images.openfoodfacts.org/images/products/599/752/331/3234/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 5997523313234', 'front_5997523313234'),
    ('Knorr', 'Asia Noodles Currygeschmack', 'https://images.openfoodfacts.org/images/products/871/410/067/9852/front_fr.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 8714100679852', 'front_8714100679852')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

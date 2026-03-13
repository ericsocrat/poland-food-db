-- PIPELINE (Spices & Seasonings): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Spices & Seasonings'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', 'https://images.openfoodfacts.org/images/products/590/113/504/6749/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135046749', 'front_5901135046749'),
    ('Donatello', 'Antipasti - papryczki czereśniowe nadziewane serkiem', 'https://images.openfoodfacts.org/images/products/590/747/653/3863/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907476533863', 'front_5907476533863'),
    ('Prymat', 'Przyprawa do gulaszu i dań kuchni węgierskiej', 'https://images.openfoodfacts.org/images/products/590/113/500/0062/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135000062', 'front_5901135000062'),
    ('Kamis', 'Przyprawa kuchni włoskiej', 'https://images.openfoodfacts.org/images/products/590/008/418/8012/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084188012', 'front_5900084188012'),
    ('Donatello', 'Antipasti nadziewane serkiem wiśniowe papryczki', 'https://images.openfoodfacts.org/images/products/590/419/490/8683/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194908683', 'front_5904194908683'),
    ('Kamis', 'Przyprawa do dań z ziemniaków', 'https://images.openfoodfacts.org/images/products/590/008/407/9013/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084079013', 'front_5900084079013'),
    ('Planteon', 'Pieprz ziołowy', 'https://images.openfoodfacts.org/images/products/590/260/522/4124/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902605224124', 'front_5902605224124'),
    ('Prymat', 'Przyprawa do kurczaka złocista skórka', 'https://images.openfoodfacts.org/images/products/590/113/501/5233/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135015233', 'front_5901135015233'),
    ('Kucharek', 'Przyprawa do mięs', 'https://images.openfoodfacts.org/images/products/590/113/505/0302/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135050302', 'front_5901135050302'),
    ('Prymat', 'Przyprawa do mięs', 'https://images.openfoodfacts.org/images/products/590/113/503/0731/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135030731', 'front_5901135030731'),
    ('Promienie Słońca', 'Papryka słodka wędzona', 'https://images.openfoodfacts.org/images/products/590/376/614/2166/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903766142166', 'front_5903766142166'),
    ('Perla', 'Pełna dobra papryczkę czerwone i pepperoni', 'https://images.openfoodfacts.org/images/products/590/419/490/7808/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194907808', 'front_5904194907808'),
    ('Herbapol', 'Mięta', 'https://images.openfoodfacts.org/images/products/590/095/600/2309/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900956002309', 'front_5900956002309'),
    ('Knorr', 'Przyprawa do mięs', 'https://images.openfoodfacts.org/images/products/590/030/054/3717/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900300543717', 'front_5900300543717'),
    ('Kamis', 'Przyprawa do gyrosa', 'https://images.openfoodfacts.org/images/products/590/008/420/4873/front_pl.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084204873', 'front_5900084204873'),
    ('Prymat', 'Przyprawa do sałatek sosów i dipów', 'https://images.openfoodfacts.org/images/products/590/113/500/0338/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135000338', 'front_5901135000338'),
    ('Culineo', 'Cebulka zapiekana', 'https://images.openfoodfacts.org/images/products/590/202/077/9018/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902020779018', 'front_5902020779018'),
    ('Sainsbury''s', 'Black Peppercorns', 'https://images.openfoodfacts.org/images/products/590/086/221/3530/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900862213530', 'front_5900862213530'),
    ('Casa de mexico', 'Papryka zielona krojona', 'https://images.openfoodfacts.org/images/products/590/175/270/3971/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752703971', 'front_5901752703971'),
    ('Kamis', 'Curry', 'https://images.openfoodfacts.org/images/products/590/008/423/5136/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084235136', 'front_5900084235136'),
    ('Prymat', 'Przyprawa do kurczaka', 'https://images.openfoodfacts.org/images/products/590/113/500/0321/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135000321', 'front_5901135000321'),
    ('Kamis', 'Seasoning for fish', 'https://images.openfoodfacts.org/images/products/590/008/423/5198/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084235198', 'front_5900084235198'),
    ('Kamis', 'Cynamon', 'https://images.openfoodfacts.org/images/products/590/008/427/4074/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084274074', 'front_5900084274074'),
    ('Prymat', 'Grill klasyczny', 'https://images.openfoodfacts.org/images/products/590/113/500/0383/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135000383', 'front_5901135000383'),
    ('Prymat', 'Kebab gyros', 'https://images.openfoodfacts.org/images/products/590/113/501/2522/front_en.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135012522', 'front_5901135012522'),
    ('Casa del sur', 'Pepperoni pepper imp', 'https://images.openfoodfacts.org/images/products/590/289/882/2458/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902898822458', 'front_5902898822458'),
    ('Prymat', 'Przyprawa Kebab Gyros klasyczna', 'https://images.openfoodfacts.org/images/products/590/113/502/1814/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135021814', 'front_5901135021814'),
    ('Kamis', 'Przyprawa do spaghetti bolognese', 'https://images.openfoodfacts.org/images/products/590/008/423/8144/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900084238144', 'front_5900084238144'),
    ('Planteon', 'Papryka ostra mielona 60 ASTA', 'https://images.openfoodfacts.org/images/products/590/260/522/0980/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902605220980', 'front_5902605220980'),
    ('El Toro Rojo', 'Kapary w zalewie', 'https://images.openfoodfacts.org/images/products/590/437/864/4192/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378644192', 'front_5904378644192'),
    ('Lidl', 'Papryka Żółta Z Nadzieniem Z Serka Śmietankowego', 'https://images.openfoodfacts.org/images/products/433/561/916/5502/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619165502', 'front_4335619165502'),
    ('Dr. Oetker', 'Wanilia bourbon z Madagaskaru z ziarenkami wanilii', 'https://images.openfoodfacts.org/images/products/590/043/708/2677/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900437082677', 'front_5900437082677'),
    ('El Tequito', 'Jalapeños', 'https://images.openfoodfacts.org/images/products/000/002/048/4804/front_en.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 20484804', 'front_20484804'),
    ('Lidl', 'Ground chili peppers in olive oil', 'https://images.openfoodfacts.org/images/products/000/002/042/2103/front_en.683.400.jpg', 'off_api', 'front', true, 'Front — EAN 20422103', 'front_20422103'),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'https://images.openfoodfacts.org/images/products/405/648/912/3651/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123651', 'front_4056489123651'),
    ('Eridanous', 'Gyros', 'https://images.openfoodfacts.org/images/products/405/648/964/4286/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489644286', 'front_4056489644286'),
    ('Knorr', 'Czosnek', 'https://images.openfoodfacts.org/images/products/872/270/025/5710/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8722700255710', 'front_8722700255710'),
    ('Vilgain', 'Koření na pizzu', 'https://images.openfoodfacts.org/images/products/859/571/770/0418/front_cs.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 8595717700418', 'front_8595717700418'),
    ('All Seasons', 'Papryka konserwowa', 'https://images.openfoodfacts.org/images/products/406/505/900/3194/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4065059003194', 'front_4065059003194')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spices & Seasonings' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

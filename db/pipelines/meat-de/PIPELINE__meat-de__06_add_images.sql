-- PIPELINE (Meat): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Meat'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Herta', 'Hähnchenbrust', 'https://images.openfoodfacts.org/images/products/400/058/237/0597/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582370597', 'front_4000582370597'),
    ('Frosta', 'Hähnchen Paella', 'https://images.openfoodfacts.org/images/products/400/836/600/8704/front_de.84.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366008704', 'front_4008366008704'),
    ('Gut Drei Eichen', 'Herzhafte Edelsalami, geräuchert', 'https://images.openfoodfacts.org/images/products/406/145/801/5219/front_de.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458015219', 'front_4061458015219'),
    ('Güldenhof', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 'https://images.openfoodfacts.org/images/products/406/146/178/6533/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461786533', 'front_4061461786533'),
    ('Allfein Feinkost', 'Hähnchen-Knusper-Dinos', 'https://images.openfoodfacts.org/images/products/406/145/918/7557/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459187557', 'front_4061459187557'),
    ('Güldenhof', 'Mini-Wiener - Geflügel', 'https://images.openfoodfacts.org/images/products/406/145/801/5851/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458015851', 'front_4061458015851'),
    ('Güldenhof', 'Geflügel-Paprikalyoner', 'https://images.openfoodfacts.org/images/products/406/145/801/4410/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014410', 'front_4061458014410'),
    ('Adler Schwarzwald', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 'https://images.openfoodfacts.org/images/products/406/145/801/6377/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458016377', 'front_4061458016377'),
    ('Bio', 'Bio-Salami - geräuchert mit grünem Pfeffer', 'https://images.openfoodfacts.org/images/products/406/145/801/3024/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458013024', 'front_4061458013024'),
    ('Güldenhof', 'Geflügel-Mortadella', 'https://images.openfoodfacts.org/images/products/406/145/801/4458/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014458', 'front_4061458014458'),
    ('Böklunder', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 'https://images.openfoodfacts.org/images/products/406/145/801/5035/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458015035', 'front_4061458015035'),
    ('Dulano', 'Geflügel Wiener', 'https://images.openfoodfacts.org/images/products/405/648/920/5234/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489205234', 'front_4056489205234'),
    ('Familie Wein', 'Schwarzwälder Schinken', 'https://images.openfoodfacts.org/images/products/400/341/902/5790/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003419025790', 'front_4003419025790'),
    ('Zimmermann', 'Weißwurst', 'https://images.openfoodfacts.org/images/products/400/615/311/6007/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006153116007', 'front_4006153116007'),
    ('Rügenwalder Mühle', 'Mühlen Frikadellen 100% Geflügel', 'https://images.openfoodfacts.org/images/products/400/040/500/2605/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405002605', 'front_4000405002605'),
    ('Gut Drei Eichen', 'Katenschinken-Würfel', 'https://images.openfoodfacts.org/images/products/406/145/801/6315/front_de.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458016315', 'front_4061458016315'),
    ('Bernard Matthews Oldenburg', 'Hähnchen Filetstreifen', 'https://images.openfoodfacts.org/images/products/400/299/307/1100/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002993071100', 'front_4002993071100'),
    ('Gut Drei Eichen', 'Münchner Weißwurst', 'https://images.openfoodfacts.org/images/products/406/145/801/5905/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458015905', 'front_4061458015905'),
    ('Gutfried', 'Geflügelwurst', 'https://images.openfoodfacts.org/images/products/400/317/100/3692/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003171003692', 'front_4003171003692'),
    ('Ferdi Fuchs', 'Wurst Ferdi Fuchs Mini Würstschen', 'https://images.openfoodfacts.org/images/products/400/663/907/0397/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006639070397', 'front_4006639070397'),
    ('Reinert', 'Bärchenwurst', 'https://images.openfoodfacts.org/images/products/400/622/901/5579/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006229015579', 'front_4006229015579'),
    ('Meine Metzgerei', 'Puten-Hackfleisch Frisch; gewürzt; zum Braten Aus der Frischetruhe Dauertiefpreis 2.49€ 400g Packung 1kg 6.23€', 'https://images.openfoodfacts.org/images/products/406/145/813/1315/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458131315', 'front_4061458131315'),
    ('Gutfried', 'Hähnchenbrust', 'https://images.openfoodfacts.org/images/products/400/317/109/6175/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003171096175', 'front_4003171096175'),
    ('Meica', 'Geflügelwürstchen', 'https://images.openfoodfacts.org/images/products/400/050/314/8502/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000503148502', 'front_4000503148502'),
    ('Dulano', 'Delikatess Hähnchenbrust', 'https://images.openfoodfacts.org/images/products/405/648/964/0158/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489640158', 'front_4056489640158'),
    ('Reinert', 'Bärchen SchlaWiener', 'https://images.openfoodfacts.org/images/products/400/622/901/9041/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006229019041', 'front_4006229019041'),
    ('Sprehe Feinkost', 'Hähnchen-Brustfiletstreifen', 'https://images.openfoodfacts.org/images/products/406/145/804/1232/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458041232', 'front_4061458041232'),
    ('Reinert', 'Bärchen-Wurst', 'https://images.openfoodfacts.org/images/products/400/622/971/0214/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006229710214', 'front_4006229710214'),
    ('Gutfried', 'Gutfried - Hähnchen-Salami', 'https://images.openfoodfacts.org/images/products/400/317/104/7146/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003171047146', 'front_4003171047146'),
    ('Meica', 'Meica Geflügel-Wiener 4000503148601 Geflügel-Wiener im Saitling', 'https://images.openfoodfacts.org/images/products/400/050/314/8601/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000503148601', 'front_4000503148601'),
    ('Dulano', 'Wurst - Geflügel-Leberwurst', 'https://images.openfoodfacts.org/images/products/405/648/961/9642/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489619642', 'front_4056489619642'),
    ('Aldi Meine Metzgerei', 'Hähnchenbrust', 'https://images.openfoodfacts.org/images/products/406/145/801/0627/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458010627', 'front_4061458010627'),
    ('Herta', 'FARMERSCHINKEN mit Honig verfeinert und über Buchenholz geräuchert, gegart', 'https://images.openfoodfacts.org/images/products/400/058/230/9290/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582309290', 'front_4000582309290'),
    ('Gutfried', 'Hähnchenbrust Kirschpaprika', 'https://images.openfoodfacts.org/images/products/400/317/102/0088/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003171020088', 'front_4003171020088'),
    ('Kupfer', 'Original Nürnberger Rostbratwürste', 'https://images.openfoodfacts.org/images/products/401/870/307/0479/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018703070479', 'front_4018703070479'),
    ('Kamar', 'Geflügelbratwurst', 'https://images.openfoodfacts.org/images/products/400/846/026/6741/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008460266741', 'front_4008460266741'),
    ('Meica', 'Zutat: Würstchen - Wiener Art', 'https://images.openfoodfacts.org/images/products/400/050/310/2306/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000503102306', 'front_4000503102306'),
    ('Gutfried', 'Hähnchenbrust, gepökelt und gebraten', 'https://images.openfoodfacts.org/images/products/400/317/102/0057/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003171020057', 'front_4003171020057'),
    ('Herta', 'Schinken', 'https://images.openfoodfacts.org/images/products/400/058/218/5290/front_de.94.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582185290', 'front_4000582185290'),
    ('Gut Drei Eichen', 'Schinken-Lyoner', 'https://images.openfoodfacts.org/images/products/406/145/801/5516/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458015516', 'front_4061458015516'),
    ('Herta', 'Schinken gegart ofengegrillt', 'https://images.openfoodfacts.org/images/products/400/058/218/5498/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582185498', 'front_4000582185498'),
    ('Nestlé', 'Saftschinken', 'https://images.openfoodfacts.org/images/products/400/058/230/9993/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582309993', 'front_4000582309993'),
    ('Ponnath Die Meistermetzger', 'Delikatess Prosciutto Cotto', 'https://images.openfoodfacts.org/images/products/400/093/058/5048/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000930585048', 'front_4000930585048'),
    ('Bio', 'Bio-Salami - luftgetrocknet', 'https://images.openfoodfacts.org/images/products/406/145/801/2973/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458012973', 'front_4061458012973'),
    ('Abraham', 'Jamón Serrano Schinken', 'https://images.openfoodfacts.org/images/products/406/145/801/6568/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458016568', 'front_4061458016568'),
    ('Zimbo', 'Schinken Zwiebelmettwurst fettreduziert', 'https://images.openfoodfacts.org/images/products/406/376/154/0068/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063761540068', 'front_4063761540068'),
    ('K-Classic', 'Kochhinterschinken', 'https://images.openfoodfacts.org/images/products/406/336/722/5079/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367225079', 'front_4063367225079'),
    ('Herta', 'Schinken Belem Pfeffer', 'https://images.openfoodfacts.org/images/products/400/058/218/5399/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000582185399', 'front_4000582185399'),
    ('Steinhaus', 'Bergische Salami', 'https://images.openfoodfacts.org/images/products/400/933/777/9333/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009337779333', 'front_4009337779333'),
    ('Meica', 'Curryking fix & fertig', 'https://images.openfoodfacts.org/images/products/400/050/328/0004/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000503280004', 'front_4000503280004'),
    ('Reinert', 'Schinken Nuggets', 'https://images.openfoodfacts.org/images/products/400/622/969/0219/front_en.73.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006229690219', 'front_4006229690219')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Meat' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

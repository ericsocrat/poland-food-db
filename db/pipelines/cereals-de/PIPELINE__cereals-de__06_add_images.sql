-- PIPELINE (Cereals): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Cereals'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Kölln', 'Haferflocken Blütenzart', 'https://images.openfoodfacts.org/images/products/400/054/000/0108/front_de.273.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540000108', 'front_4000540000108'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 'https://images.openfoodfacts.org/images/products/400/054/001/1050/front_de.66.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540011050', 'front_4000540011050'),
    ('Lorenz', 'Erdnußlocken Classic', 'https://images.openfoodfacts.org/images/products/401/807/700/6203/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077006203', 'front_4018077006203'),
    ('Kölln', 'Kernige Haferflocken', 'https://images.openfoodfacts.org/images/products/400/054/000/0306/front_de.127.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540000306', 'front_4000540000306'),
    ('Nippon', 'Puffreis mit Schokolade', 'https://images.openfoodfacts.org/images/products/402/170/090/0021/front_en.105.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021700900021', 'front_4021700900021'),
    ('Golden Bridge', 'Zarte Haferflocken', 'https://images.openfoodfacts.org/images/products/406/146/491/1895/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464911895', 'front_4061464911895'),
    ('Kölln', 'Bio-Haferflocken zart', 'https://images.openfoodfacts.org/images/products/400/054/000/0641/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540000641', 'front_4000540000641'),
    ('Crownfield', 'Bio Haferflocken zart', 'https://images.openfoodfacts.org/images/products/405/648/966/5519/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489665519', 'front_4056489665519'),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'https://images.openfoodfacts.org/images/products/400/054/000/5028/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540005028', 'front_4000540005028'),
    ('Kölln', 'Vollkorn Haferfleks', 'https://images.openfoodfacts.org/images/products/400/054/001/1081/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540011081', 'front_4000540011081'),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', 'https://images.openfoodfacts.org/images/products/406/145/967/4101/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459674101', 'front_4061459674101'),
    ('Nur Nur Natur', 'Haferflocken zart', 'https://images.openfoodfacts.org/images/products/406/146/384/5337/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463845337', 'front_4061463845337'),
    ('Kölln', 'Knusprige Haferfleks Schoko', 'https://images.openfoodfacts.org/images/products/400/054/009/1069/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540091069', 'front_4000540091069'),
    ('Golden Bridge', 'Haferflocken kernig', 'https://images.openfoodfacts.org/images/products/406/146/491/2014/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464912014', 'front_4061464912014'),
    ('EDEKA Bio', 'Cornflakes ungesüßt', 'https://images.openfoodfacts.org/images/products/431/150/104/3646/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501043646', 'front_4311501043646'),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', 'https://images.openfoodfacts.org/images/products/433/725/637/9519/front_fr.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256379519', 'front_4337256379519'),
    ('Dm Bio', 'Dinkel Gepufft', 'https://images.openfoodfacts.org/images/products/406/779/600/1839/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796001839', 'front_4067796001839'),
    ('Ja', 'Haferflocken', 'https://images.openfoodfacts.org/images/products/433/725/641/5965/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256415965', 'front_4337256415965'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 'https://images.openfoodfacts.org/images/products/761/303/321/2949/front_en.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613033212949', 'front_7613033212949'),
    ('Crownfield', 'Flocons d''Avoine', 'https://images.openfoodfacts.org/images/products/000/002/000/3166/front_en.478.400.jpg', 'off_api', 'front', true, 'Front — EAN 20003166', 'front_20003166'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'https://images.openfoodfacts.org/images/products/426/058/296/1519/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260582961519', 'front_4260582961519'),
    ('Nestlé', 'FITNESS Cerealien', 'https://images.openfoodfacts.org/images/products/338/739/033/9499/front_en.211.400.jpg', 'off_api', 'front', true, 'Front — EAN 3387390339499', 'front_3387390339499'),
    ('Gut & Günstig', 'Nougat Bits', 'https://images.openfoodfacts.org/images/products/431/150/172/0073/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501720073', 'front_4311501720073'),
    ('REWE Bio', 'Rewe Bio Haferflocken zart', 'https://images.openfoodfacts.org/images/products/433/725/678/3132/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256783132', 'front_4337256783132'),
    ('REWE Bio', 'Dinkel Flakes', 'https://images.openfoodfacts.org/images/products/433/725/673/9689/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256739689', 'front_4337256739689'),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', 'https://images.openfoodfacts.org/images/products/433/725/643/6649/front_en.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256436649', 'front_4337256436649'),
    ('Edeka', 'Haferflocken extra zart', 'https://images.openfoodfacts.org/images/products/431/150/149/2246/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501492246', 'front_4311501492246'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 'https://images.openfoodfacts.org/images/products/761/328/743/3633/front_en.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613287433633', 'front_7613287433633'),
    ('Alpro', 'Hafer Milch', 'https://images.openfoodfacts.org/images/products/541/118/812/4689/front_en.455.400.jpg', 'off_api', 'front', true, 'Front — EAN 5411188124689', 'front_5411188124689'),
    ('Oatly!', 'Haferdrink Barista Bio', 'https://images.openfoodfacts.org/images/products/739/437/662/1680/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 7394376621680', 'front_7394376621680'),
    ('Oatly!', 'Hafer Barista light', 'https://images.openfoodfacts.org/images/products/739/437/662/1703/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 7394376621703', 'front_7394376621703'),
    ('Alnatura', 'Dinkel Crunchy', 'https://images.openfoodfacts.org/images/products/410/442/025/4756/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420254756', 'front_4104420254756'),
    ('Oatly!', 'Oatly Hafer Barista Edition', 'https://images.openfoodfacts.org/images/products/739/437/661/7904/front_en.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 7394376617904', 'front_7394376617904'),
    ('Weetabix', 'Weetabix produit à base de blé complet 100%', 'https://images.openfoodfacts.org/images/products/501/002/900/0023/front_en.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 5010029000023', 'front_5010029000023'),
    ('Alnatura', 'Schoko Hafer Crunchy', 'https://images.openfoodfacts.org/images/products/410/442/023/8244/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420238244', 'front_4104420238244')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Cereals' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

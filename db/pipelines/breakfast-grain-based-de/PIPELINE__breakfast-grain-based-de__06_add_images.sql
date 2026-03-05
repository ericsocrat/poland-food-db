-- PIPELINE (Breakfast & Grain-Based): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Breakfast & Grain-Based'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Dr. Oetker', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'https://images.openfoodfacts.org/images/products/400/052/166/2103/front_de.77.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521662103', 'front_4000521662103'),
    ('Kölln', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 'https://images.openfoodfacts.org/images/products/400/054/000/3260/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003260', 'front_4000540003260'),
    ('Kölln', 'Knusper Honig-Nuss Müsli', 'https://images.openfoodfacts.org/images/products/400/054/002/3169/front_de.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540023169', 'front_4000540023169'),
    ('Dm', 'Bio Schokomüsli ohne Rosinen', 'https://images.openfoodfacts.org/images/products/406/644/752/4413/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447524413', 'front_4066447524413'),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'https://images.openfoodfacts.org/images/products/400/054/000/3222/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003222', 'front_4000540003222'),
    ('Kölln', 'Zartes Bircher Müsli', 'https://images.openfoodfacts.org/images/products/400/054/001/1517/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540011517', 'front_4000540011517'),
    ('Seitenbacher', 'Kakao-Düsis', 'https://images.openfoodfacts.org/images/products/400/839/121/2145/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008391212145', 'front_4008391212145'),
    ('Dr. Oetker Vitalis', 'Vitalis Weniger süß Knusper Himbeere', 'https://images.openfoodfacts.org/images/products/400/052/101/0423/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521010423', 'front_4000521010423'),
    ('Kölln', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3130/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003130', 'front_4000540003130'),
    ('Kölln', 'Hafer Müsli Beere Apfel', 'https://images.openfoodfacts.org/images/products/400/054/000/1501/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540001501', 'front_4000540001501'),
    ('Dr. Oetker', 'Schoko Müsli klassisch', 'https://images.openfoodfacts.org/images/products/400/052/104/1991/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521041991', 'front_4000521041991'),
    ('Dr. Oetker', 'Vitalis Knusper Schoko Müsli', 'https://images.openfoodfacts.org/images/products/400/052/104/0628/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521040628', 'front_4000521040628'),
    ('Golden Bridge', 'Trauben-Nuss Müsli Vollkorn', 'https://images.openfoodfacts.org/images/products/406/146/483/5504/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464835504', 'front_4061464835504'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli PLUS Nussmischung', 'https://images.openfoodfacts.org/images/products/400/052/102/1894/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521021894', 'front_4000521021894'),
    ('Dr. Oetker', 'Vitalis Müsli Joghurt', 'https://images.openfoodfacts.org/images/products/400/052/166/3407/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521663407', 'front_4000521663407'),
    ('Kölln', 'Crunchy Berry Hafer-Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3314/front_en.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003314', 'front_4000540003314'),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 'https://images.openfoodfacts.org/images/products/400/054/001/1364/front_de.107.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540011364', 'front_4000540011364'),
    ('Seitenbacher', 'Müsli 205 Für Sportliche', 'https://images.openfoodfacts.org/images/products/400/839/100/8205/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008391008205', 'front_4008391008205'),
    ('Dr. Oetker', 'Vitalis Knusper müsli Honeys', 'https://images.openfoodfacts.org/images/products/400/052/166/1304/front_de.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521661304', 'front_4000521661304'),
    ('Golden Bridge', 'Schoko-Müsli mit 30 % weniger Zucker', 'https://images.openfoodfacts.org/images/products/406/146/483/3838/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464833838', 'front_4061464833838'),
    ('Golden Bridge', 'Früchte-Müsli', 'https://images.openfoodfacts.org/images/products/406/146/483/3845/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464833845', 'front_4061464833845'),
    ('DmBio', 'Beeren Müsli', 'https://images.openfoodfacts.org/images/products/406/644/760/7567/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447607567', 'front_4066447607567'),
    ('Dr. Oetker', 'Vitalis Knusper Müsli klassisch', 'https://images.openfoodfacts.org/images/products/400/052/166/1205/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521661205', 'front_4000521661205'),
    ('Crownfield', 'Schoko Müsli', 'https://images.openfoodfacts.org/images/products/405/648/925/5499/front_en.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489255499', 'front_4056489255499'),
    ('Dr. Oetker', 'Knusper Schoko Müsli', 'https://images.openfoodfacts.org/images/products/400/052/104/0680/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521040680', 'front_4000521040680'),
    ('GUT Bio', 'Basis Müsli 5-Kornmix', 'https://images.openfoodfacts.org/images/products/406/146/483/6297/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464836297', 'front_4061464836297'),
    ('Kölln', 'Crunchy Mango-Maracuja Hafer-Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3956/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003956', 'front_4000540003956'),
    ('Aldi', 'Bio-Müsli - Urkorn-Früchte', 'https://images.openfoodfacts.org/images/products/406/145/959/5079/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459595079', 'front_4061459595079'),
    ('Dr. Oetker', 'Müsli Schoko weniger süss', 'https://images.openfoodfacts.org/images/products/400/052/104/1977/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521041977', 'front_4000521041977'),
    ('Kölln', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 'https://images.openfoodfacts.org/images/products/400/054/004/3587/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540043587', 'front_4000540043587'),
    ('GUT bio', 'Bio Knusper-Müsli Schoko-Amaranth', 'https://images.openfoodfacts.org/images/products/406/145/818/1266/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458181266', 'front_4061458181266'),
    ('Seitenbacher', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 'https://images.openfoodfacts.org/images/products/400/839/104/1479/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008391041479', 'front_4008391041479'),
    ('Golden Bridge', 'Früchte-Müsli Vollkorn', 'https://images.openfoodfacts.org/images/products/406/146/483/5580/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464835580', 'front_4061464835580'),
    ('Kölln', 'Crunchy Hazel Hafer-Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3192/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003192', 'front_4000540003192'),
    ('Kölln', 'Früchte Hafer-Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/1341/front_de.107.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540001341', 'front_4000540001341'),
    ('Kölln kölln', 'Schoko Müsli', 'https://images.openfoodfacts.org/images/products/400/054/005/3869/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540053869', 'front_4000540053869'),
    ('Kölln', 'Knusper Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3468/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003468', 'front_4000540003468'),
    ('Kölln', 'Hafer Müsli', 'https://images.openfoodfacts.org/images/products/400/054/006/3868/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540063868', 'front_4000540063868'),
    ('Kölln', 'Früchte Müsli ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/400/054/000/1334/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540001334', 'front_4000540001334'),
    ('DmBio', 'Müsli Nuss', 'https://images.openfoodfacts.org/images/products/406/779/605/7089/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796057089', 'front_4067796057089'),
    ('DmBio', 'Paleo Müsli', 'https://images.openfoodfacts.org/images/products/406/779/606/6760/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796066760', 'front_4067796066760'),
    ('Golden Bridge', 'Premium Müsli', 'https://images.openfoodfacts.org/images/products/406/146/483/5757/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464835757', 'front_4061464835757'),
    ('Dr. Oetker', 'Vitalis Müsli Knusper Schoko ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/400/052/103/5686/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521035686', 'front_4000521035686'),
    ('DmBio', 'Basismüsli ohne Rosinen', 'https://images.openfoodfacts.org/images/products/406/644/760/7598/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447607598', 'front_4066447607598'),
    ('Kölln', 'Knusper Schoko & Keks Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3246/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003246', 'front_4000540003246'),
    ('Kölln', 'Knusper Joghurt Himbeer Müsli', 'https://images.openfoodfacts.org/images/products/400/054/000/3567/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540003567', 'front_4000540003567'),
    ('Seitenbacher', 'Müsli 508 Dinos Frühstück', 'https://images.openfoodfacts.org/images/products/400/839/105/1508/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008391051508', 'front_4008391051508'),
    ('Dr. Oetker', 'Paula Müslispaß Schoko', 'https://images.openfoodfacts.org/images/products/400/052/102/7032/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521027032', 'front_4000521027032'),
    ('DmBio', 'Früchte müsli', 'https://images.openfoodfacts.org/images/products/406/644/752/4772/front_hr.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447524772', 'front_4066447524772'),
    ('Bauck Mühle', 'Schoko+Flakes Hafer Müsli Bio', 'https://images.openfoodfacts.org/images/products/401/563/701/8799/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015637018799', 'front_4015637018799'),
    ('Brüggen', 'Schoko-Müsli', 'https://images.openfoodfacts.org/images/products/406/146/483/3821/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464833821', 'front_4061464833821')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Breakfast & Grain-Based' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

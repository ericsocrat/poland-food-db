-- PIPELINE (Snacks): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-11

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Snacks'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Pom-Bär', 'POM-BÄR Original', 'https://images.openfoodfacts.org/images/products/400/052/210/5210/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000522105210', 'front_4000522105210'),
    ('Huober', 'Original schwäbische Knusper Brezel', 'https://images.openfoodfacts.org/images/products/400/038/100/3030/front_en.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000381003030', 'front_4000381003030'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'https://images.openfoodfacts.org/images/products/401/180/052/3312/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800523312', 'front_4011800523312'),
    ('Leicht & Cross', 'Leicht & Cross Vollkorn Knäckebrot', 'https://images.openfoodfacts.org/images/products/400/151/810/4064/front_de.90.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001518104064', 'front_4001518104064'),
    ('Corny', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'https://images.openfoodfacts.org/images/products/401/180/052/3213/front_de.103.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800523213', 'front_4011800523213'),
    ('Leicht & Cross', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'https://images.openfoodfacts.org/images/products/400/151/800/6450/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001518006450', 'front_4001518006450'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'https://images.openfoodfacts.org/images/products/401/710/070/6004/front_en.140.400.jpg', 'off_api', 'front', true, 'Front — EAN 4017100706004', 'front_4017100706004'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 'https://images.openfoodfacts.org/images/products/401/180/059/3810/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800593810', 'front_4011800593810'),
    ('Lorenz', 'Clubs Cracker', 'https://images.openfoodfacts.org/images/products/401/807/762/0003/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077620003', 'front_4018077620003'),
    ('Seeberger', 'Nuts''n Berries', 'https://images.openfoodfacts.org/images/products/400/825/805/1030/front_de.101.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008258051030', 'front_4008258051030'),
    ('Corny', 'Nussvoll Nuss &Traube', 'https://images.openfoodfacts.org/images/products/401/180/054/9411/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800549411', 'front_4011800549411'),
    ('Corny', 'Milch Classic', 'https://images.openfoodfacts.org/images/products/401/180/056/2212/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800562212', 'front_4011800562212'),
    ('Rivercote', 'Knusperbrot Weizen', 'https://images.openfoodfacts.org/images/products/405/648/970/3990/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489703990', 'front_4056489703990'),
    ('Corny', 'CORNY Schoko', 'https://images.openfoodfacts.org/images/products/401/180/052/1219/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800521219', 'front_4011800521219'),
    ('Corny', 'Corny - Schoko-Banane', 'https://images.openfoodfacts.org/images/products/401/180/052/3220/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011800523220', 'front_4011800523220'),
    ('DmBio', 'Schoko Reiswaffeln Zartbitter', 'https://images.openfoodfacts.org/images/products/406/779/614/0309/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796140309', 'front_4067796140309'),
    ('Leicht & Cross', 'Knusperbrot Goldweizen', 'https://images.openfoodfacts.org/images/products/400/840/400/1001/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008404001001', 'front_4008404001001'),
    ('DmBio', 'Dinkel Mini brezeln', 'https://images.openfoodfacts.org/images/products/406/644/759/9466/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447599466', 'front_4066447599466'),
    ('Tuc', 'Tuc Original', 'https://images.openfoodfacts.org/images/products/541/004/100/1204/front_en.520.400.jpg', 'off_api', 'front', true, 'Front — EAN 5410041001204', 'front_5410041001204'),
    ('Pågen', 'Gifflar Cannelle', 'https://images.openfoodfacts.org/images/products/731/107/034/6916/front_en.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 7311070346916', 'front_7311070346916'),
    ('Alnatura', 'Linsenwaffeln', 'https://images.openfoodfacts.org/images/products/410/442/023/1658/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420231658', 'front_4104420231658'),
    ('Alesto', 'Cruspies Paprika', 'https://images.openfoodfacts.org/images/products/000/002/000/5702/front_en.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 20005702', 'front_20005702'),
    ('Snack Day', 'Erdnuss Flips', 'https://images.openfoodfacts.org/images/products/000/002/004/5852/front_de.128.400.jpg', 'off_api', 'front', true, 'Front — EAN 20045852', 'front_20045852'),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', 'https://images.openfoodfacts.org/images/products/426/065/478/9119/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260654789119', 'front_4260654789119'),
    ('KoRo', 'Protein Bar Deluxe', 'https://images.openfoodfacts.org/images/products/426/071/829/5884/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260718295884', 'front_4260718295884'),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', 'https://images.openfoodfacts.org/images/products/433/725/672/3923/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256723923', 'front_4337256723923'),
    ('Mondelez', 'Paprika', 'https://images.openfoodfacts.org/images/products/541/004/106/6005/front_en.112.400.jpg', 'off_api', 'front', true, 'Front — EAN 5410041066005', 'front_5410041066005'),
    ('ESN', 'Designer Protein Bar', 'https://images.openfoodfacts.org/images/products/425/051/964/6527/front_en.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250519646527', 'front_4250519646527'),
    ('Maretti', 'Bruschette', 'https://images.openfoodfacts.org/images/products/380/020/587/2924/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 3800205872924', 'front_3800205872924')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

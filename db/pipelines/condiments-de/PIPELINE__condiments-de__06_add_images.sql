-- PIPELINE (Condiments): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Condiments'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Hela', 'Gewürzketchup Curry', 'https://images.openfoodfacts.org/images/products/402/740/014/8008/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148008', 'front_4027400148008'),
    ('Aldi', 'Curry-Gewürzketchup - delikat', 'https://images.openfoodfacts.org/images/products/406/145/808/4185/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458084185', 'front_4061458084185'),
    ('Werder', 'Gewürz Ketchup', 'https://images.openfoodfacts.org/images/products/440/013/900/0241/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139000241', 'front_4400139000241'),
    ('Delikato', 'Curry-Gewürzketchup - scharf', 'https://images.openfoodfacts.org/images/products/406/145/808/4192/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458084192', 'front_4061458084192'),
    ('American', 'Würzsauce 2 in 1 - Ketchup & Senf', 'https://images.openfoodfacts.org/images/products/406/145/803/2070/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032070', 'front_4061458032070'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'https://images.openfoodfacts.org/images/products/402/740/007/0361/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400070361', 'front_4027400070361'),
    ('Hela', 'Gewürz Ketchup Curry', 'https://images.openfoodfacts.org/images/products/402/740/014/8343/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148343', 'front_4027400148343'),
    ('Hela', 'Gewürz Ketchup Curry Delikat 30%', 'https://images.openfoodfacts.org/images/products/402/740/014/8244/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148244', 'front_4027400148244'),
    ('Hela', 'Soße Curry Ketchup', 'https://images.openfoodfacts.org/images/products/402/740/014/8596/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148596', 'front_4027400148596'),
    ('Develey', 'VW Ketchup Gewürz', 'https://images.openfoodfacts.org/images/products/400/682/499/8819/front_en.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006824998819', 'front_4006824998819'),
    ('Hela', 'Gewürz Ketchup Curry Leicht Scharf', 'https://images.openfoodfacts.org/images/products/402/740/014/8398/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148398', 'front_4027400148398'),
    ('Hela', 'Gewürzketchup Tomate', 'https://images.openfoodfacts.org/images/products/402/740/014/8121/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148121', 'front_4027400148121'),
    ('Hela', 'Hela Schaschlik Gewürz- Ketchup', 'https://images.openfoodfacts.org/images/products/402/740/014/8091/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148091', 'front_4027400148091'),
    ('Hela', 'Gewürz Ketchup Curry Extra Scharf', 'https://images.openfoodfacts.org/images/products/402/740/014/8060/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400148060', 'front_4027400148060'),
    ('Delikato', 'Tomatenketchup', 'https://images.openfoodfacts.org/images/products/406/146/372/1204/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463721204', 'front_4061463721204'),
    ('Kania', 'Ketchup', 'https://images.openfoodfacts.org/images/products/405/648/913/9393/front_pt.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489139393', 'front_4056489139393'),
    ('DmBio', 'Jemný kečup', 'https://images.openfoodfacts.org/images/products/405/817/228/7459/front_cs.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172287459', 'front_4058172287459'),
    ('Kania', 'Tomato Ketchup', 'https://images.openfoodfacts.org/images/products/405/648/961/7181/front_en.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489617181', 'front_4056489617181'),
    ('Werder', 'Tomatenketchup von Werder', 'https://images.openfoodfacts.org/images/products/440/013/900/0067/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139000067', 'front_4400139000067'),
    ('Jütro', 'Tomaten Ketchup', 'https://images.openfoodfacts.org/images/products/405/648/960/4471/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489604471', 'front_4056489604471'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Klassik', 'https://images.openfoodfacts.org/images/products/406/145/941/6329/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459416329', 'front_4061459416329'),
    ('Delikato', 'Tomatenketchup Light', 'https://images.openfoodfacts.org/images/products/406/146/234/2639/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462342639', 'front_4061462342639'),
    ('Kania', 'Kečup', 'https://images.openfoodfacts.org/images/products/405/648/964/0585/front_cs.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489640585', 'front_4056489640585'),
    ('La Vialla', 'Premium Tomatenketchup', 'https://images.openfoodfacts.org/images/products/440/013/900/0647/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139000647', 'front_4400139000647'),
    ('Werder', 'Barbecue Sauce', 'https://images.openfoodfacts.org/images/products/440/013/900/6540/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139006540', 'front_4400139006540'),
    ('Bio Zentrale', 'Tomaten Ketchup', 'https://images.openfoodfacts.org/images/products/400/500/910/1303/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005009101303', 'front_4005009101303'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Curry', 'https://images.openfoodfacts.org/images/products/406/145/941/6176/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459416176', 'front_4061459416176'),
    ('Gourmet Finest Cuisine', 'Steakhouse-Ketchup mit Fleur de Sel', 'https://images.openfoodfacts.org/images/products/406/146/350/2391/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463502391', 'front_4061463502391'),
    ('Hela', 'Curry Ketchup', 'https://images.openfoodfacts.org/images/products/402/740/016/8105/front_en.167.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400168105', 'front_4027400168105'),
    ('Dennree', 'Gewürz Ketchup', 'https://images.openfoodfacts.org/images/products/402/185/155/7242/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021851557242', 'front_4021851557242'),
    ('Develey', 'Ketchup - Tomaten Ketchup', 'https://images.openfoodfacts.org/images/products/400/682/400/3551/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006824003551', 'front_4006824003551'),
    ('Werder', 'Tomatenketchup ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/440/013/900/6045/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139006045', 'front_4400139006045'),
    ('Bautz''ner', 'Ketchup', 'https://images.openfoodfacts.org/images/products/401/286/000/4582/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012860004582', 'front_4012860004582'),
    ('Hela', 'Tomaten-Ketchup', 'https://images.openfoodfacts.org/images/products/402/740/010/2116/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400102116', 'front_4027400102116'),
    ('Werder', 'Tomaten Ketchup', 'https://images.openfoodfacts.org/images/products/440/013/900/0838/front_fr.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139000838', 'front_4400139000838'),
    ('K-Bio', 'Tomatenketchup', 'https://images.openfoodfacts.org/images/products/406/336/753/7813/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367537813', 'front_4063367537813'),
    ('Delikato', 'Tomatenketchup Hot Chili', 'https://images.openfoodfacts.org/images/products/406/146/234/2448/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462342448', 'front_4061462342448'),
    ('Byodo', 'Kinder ketchup', 'https://images.openfoodfacts.org/images/products/401/846/215/7701/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018462157701', 'front_4018462157701'),
    ('K-Classic', 'Tomatenketchup', 'https://images.openfoodfacts.org/images/products/406/336/750/8011/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367508011', 'front_4063367508011'),
    ('Curry36', 'Tomatenketchup', 'https://images.openfoodfacts.org/images/products/440/013/901/8536/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139018536', 'front_4400139018536'),
    ('Tomatenketchup', 'Tomatenketchup Original Bio', 'https://images.openfoodfacts.org/images/products/402/740/010/2055/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400102055', 'front_4027400102055'),
    ('Born', 'Tomatenketchup', 'https://images.openfoodfacts.org/images/products/440/019/106/1563/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400191061563', 'front_4400191061563'),
    ('Kaufland Classic', 'Ketchup', 'https://images.openfoodfacts.org/images/products/400/244/282/0815/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002442820815', 'front_4002442820815'),
    ('Born', 'Tomaten Ketchup', 'https://images.openfoodfacts.org/images/products/440/019/105/0017/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400191050017', 'front_4400191050017'),
    ('Bio-Zentrale', 'Biokids Tomatenketchup', 'https://images.openfoodfacts.org/images/products/400/500/910/6759/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005009106759', 'front_4005009106759'),
    ('Hela', 'Ketchup', 'https://images.openfoodfacts.org/images/products/402/740/017/2805/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027400172805', 'front_4027400172805'),
    ('Zwergenwiese', 'Tomatensauce', 'https://images.openfoodfacts.org/images/products/401/973/600/3748/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019736003748', 'front_4019736003748'),
    ('Develey', 'Ketchup develey', 'https://images.openfoodfacts.org/images/products/400/682/400/2639/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006824002639', 'front_4006824002639'),
    ('K-Classic', 'Curry Gewürz Ketchup scharf', 'https://images.openfoodfacts.org/images/products/433/718/575/2339/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337185752339', 'front_4337185752339'),
    ('Werder', 'Kinder Bio Ketchup', 'https://images.openfoodfacts.org/images/products/440/013/901/8178/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400139018178', 'front_4400139018178'),
    ('Dennree', 'Ketchup', 'https://images.openfoodfacts.org/images/products/402/185/155/6603/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021851556603', 'front_4021851556603')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Condiments' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

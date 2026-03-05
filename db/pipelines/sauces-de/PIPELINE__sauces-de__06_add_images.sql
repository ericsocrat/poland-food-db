-- PIPELINE (Sauces): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Sauces'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('DmBio', 'Tomatensoße Klassik', 'https://images.openfoodfacts.org/images/products/405/817/294/3591/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172943591', 'front_4058172943591'),
    ('Hengstenberg', 'Tomaten stückig mit Kräutern', 'https://images.openfoodfacts.org/images/products/400/810/016/8473/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008100168473', 'front_4008100168473'),
    ('Bautz''ner', 'Fix Tomatensoße', 'https://images.openfoodfacts.org/images/products/401/286/000/3424/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012860003424', 'front_4012860003424'),
    ('DmBio', 'Tomatensoße Arrabbiata', 'https://images.openfoodfacts.org/images/products/405/817/281/4327/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172814327', 'front_4058172814327'),
    ('InnFood Organic', 'Bio-Tomatensauce - Gemüse und Parmesan', 'https://images.openfoodfacts.org/images/products/406/146/358/3413/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463583413', 'front_4061463583413'),
    ('DmBio', 'Tomatensauce Kräuter', 'https://images.openfoodfacts.org/images/products/406/779/606/1901/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796061901', 'front_4067796061901'),
    ('Aldi', 'Passierte Tomaten', 'https://images.openfoodfacts.org/images/products/406/146/146/1508/front_de.142.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461461508', 'front_4061461461508'),
    ('DmBio', 'Tomatensauce - Ricotta Pecorino', 'https://images.openfoodfacts.org/images/products/406/644/726/5330/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447265330', 'front_4066447265330'),
    ('King''s Crown', 'Passata', 'https://images.openfoodfacts.org/images/products/406/146/366/0800/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463660800', 'front_4061463660800'),
    ('Oro Di Parma', 'Pizzasauce Oregano', 'https://images.openfoodfacts.org/images/products/400/810/016/8220/front_en.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008100168220', 'front_4008100168220'),
    ('InnFood Organic', 'Bio-Tomatensauce - Basilikum', 'https://images.openfoodfacts.org/images/products/406/146/358/3062/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463583062', 'front_4061463583062'),
    ('DmBio', 'Tomatensauce - gegrillte Paprika', 'https://images.openfoodfacts.org/images/products/406/644/726/5316/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447265316', 'front_4066447265316'),
    ('InnFood Organic', 'Bio-Tomatensauce - Arrabiata', 'https://images.openfoodfacts.org/images/products/406/146/358/3390/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463583390', 'front_4061463583390'),
    ('Clama', 'Tomate Frito', 'https://images.openfoodfacts.org/images/products/406/146/201/8237/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462018237', 'front_4061462018237'),
    ('Cucina', 'Pasta-Sauce Arrabbiata', 'https://images.openfoodfacts.org/images/products/406/146/102/4680/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461024680', 'front_4061461024680'),
    ('Mars', 'Pastasauce Miracoli Klassiker', 'https://images.openfoodfacts.org/images/products/400/235/900/6029/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002359006029', 'front_4002359006029'),
    ('Alnatura', 'Passata', 'https://images.openfoodfacts.org/images/products/000/004/004/5122/front_en.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 40045122', 'front_40045122'),
    ('Oro', 'Pastasauce Classico', 'https://images.openfoodfacts.org/images/products/400/810/016/8466/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008100168466', 'front_4008100168466'),
    ('Cucina', 'Pasta-Sauce - Napoletana', 'https://images.openfoodfacts.org/images/products/406/145/956/6789/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459566789', 'front_4061459566789'),
    ('REWE Bio', 'Tomatensauce Kräuter', 'https://images.openfoodfacts.org/images/products/433/725/637/7331/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256377331', 'front_4337256377331'),
    ('Allos', 'Olivers Olive Tomate', 'https://images.openfoodfacts.org/images/products/401/624/913/2354/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016249132354', 'front_4016249132354'),
    ('Barilla', 'Toscana Kräuter', 'https://images.openfoodfacts.org/images/products/807/680/952/3561/front_en.119.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809523561', 'front_8076809523561'),
    ('Kaufland Bio', 'Tomatensauce Classic', 'https://images.openfoodfacts.org/images/products/406/336/743/3108/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367433108', 'front_4063367433108'),
    ('Knorr', 'Tomaten passiert', 'https://images.openfoodfacts.org/images/products/403/870/011/7373/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 4038700117373', 'front_4038700117373'),
    ('Alnatura', 'Tomatensauce Kräuter', 'https://images.openfoodfacts.org/images/products/410/442/021/3517/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420213517', 'front_4104420213517'),
    ('Nestlé', 'Tomaten Sauce', 'https://images.openfoodfacts.org/images/products/400/550/033/1407/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500331407', 'front_4005500331407'),
    ('REWE Beste Wahl', 'Stückige Tomaten', 'https://images.openfoodfacts.org/images/products/433/725/637/6709/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256376709', 'front_4337256376709'),
    ('Rewe', 'Kräuter Knoblauch Saucenbasis', 'https://images.openfoodfacts.org/images/products/433/725/678/5396/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256785396', 'front_4337256785396'),
    ('Alnatura', 'Tomatensauce Gegrilltes Gemüse 350M', 'https://images.openfoodfacts.org/images/products/410/442/021/3555/front_en.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420213555', 'front_4104420213555'),
    ('Ppura', 'Kinder Tomatensoße', 'https://images.openfoodfacts.org/images/products/764/014/367/4138/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 7640143674138', 'front_7640143674138'),
    ('Ppura', 'Kinder Tomatensoße mit verstecktem Gemüse', 'https://images.openfoodfacts.org/images/products/764/014/367/4145/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 7640143674145', 'front_7640143674145'),
    ('Barilla', 'Basilico 400g eu', 'https://images.openfoodfacts.org/images/products/807/680/951/3722/front_fr.1016.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809513722', 'front_8076809513722'),
    ('Baresa', 'Tomatenmark', 'https://images.openfoodfacts.org/images/products/000/002/000/4125/front_fi.178.400.jpg', 'off_api', 'front', true, 'Front — EAN 20004125', 'front_20004125'),
    ('Baresa', 'Passierte Tomate', 'https://images.openfoodfacts.org/images/products/000/002/088/4260/front_en.168.400.jpg', 'off_api', 'front', true, 'Front — EAN 20884260', 'front_20884260'),
    ('Gut & Günstig', 'Passierte Tomaten', 'https://images.openfoodfacts.org/images/products/431/159/644/0429/front_de.160.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311596440429', 'front_4311596440429'),
    ('Mutti', 'Triplo concentrato di pomodoro', 'https://images.openfoodfacts.org/images/products/800/511/014/0013/front_en.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 8005110140013', 'front_8005110140013'),
    ('Barilla', 'Arrabbiata', 'https://images.openfoodfacts.org/images/products/807/680/951/3388/front_en.191.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809513388', 'front_8076809513388'),
    ('EDEKA Bio', 'Passata, passierte Tomaten - Bio', 'https://images.openfoodfacts.org/images/products/431/150/165/0578/front_de.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501650578', 'front_4311501650578'),
    ('Ppura', 'Vegane Bolognese', 'https://images.openfoodfacts.org/images/products/764/014/367/4114/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 7640143674114', 'front_7640143674114'),
    ('Barilla', 'Napoletana', 'https://images.openfoodfacts.org/images/products/807/680/951/3692/front_en.204.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809513692', 'front_8076809513692'),
    ('Barilla', 'Ricotta', 'https://images.openfoodfacts.org/images/products/807/680/952/1543/front_en.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809521543', 'front_8076809521543'),
    ('Combino', 'Bolognese', 'https://images.openfoodfacts.org/images/products/000/002/000/3937/front_en.107.400.jpg', 'off_api', 'front', true, 'Front — EAN 20003937', 'front_20003937'),
    ('Baresa', 'Passierte Tomaten', 'https://images.openfoodfacts.org/images/products/000/002/016/4034/front_en.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 20164034', 'front_20164034'),
    ('Ja!', 'Tomatensauce mit Basilikum', 'https://images.openfoodfacts.org/images/products/433/725/694/6070/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256946070', 'front_4337256946070'),
    ('Mutti', 'Pizzasauce Aromatica', 'https://images.openfoodfacts.org/images/products/800/511/055/1215/front_en.131.400.jpg', 'off_api', 'front', true, 'Front — EAN 8005110551215', 'front_8005110551215'),
    ('Combino', 'Arrabbiata', 'https://images.openfoodfacts.org/images/products/000/002/030/0623/front_en.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 20300623', 'front_20300623'),
    ('REWE Bio', 'Passata Tomaten', 'https://images.openfoodfacts.org/images/products/433/725/634/3107/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256343107', 'front_4337256343107'),
    ('Barilla', 'Verdure mediterranee 400g eu cross', 'https://images.openfoodfacts.org/images/products/807/680/958/3749/front_fr.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809583749', 'front_8076809583749'),
    ('REWE Bio', 'Tomatensauce Ricotta', 'https://images.openfoodfacts.org/images/products/433/725/638/0669/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256380669', 'front_4337256380669'),
    ('Alnatura', 'Tomatensauce Toscana', 'https://images.openfoodfacts.org/images/products/410/442/003/1081/front_en.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420031081', 'front_4104420031081'),
    ('Rewe', 'Tomate Ricotta mit Basilikum', 'https://images.openfoodfacts.org/images/products/433/725/679/4176/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256794176', 'front_4337256794176')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Sauces' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

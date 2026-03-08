-- PIPELINE (Oils & Vinegars): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-08

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Oils & Vinegars'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Bellasan', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/406/146/215/0685/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462150685', 'front_4061462150685'),
    ('Primadonna', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/405/648/901/7479/front_en.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489017479', 'front_4056489017479'),
    ('DmBio', 'Natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/406/779/607/0255/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796070255', 'front_4067796070255'),
    ('Lyttos', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/406/146/262/6883/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462626883', 'front_4061462626883'),
    ('DmBio', 'Bratolivenöl', 'https://images.openfoodfacts.org/images/products/406/644/725/8936/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447258936', 'front_4066447258936'),
    ('Camaletti', 'Camaletti Olivenöl', 'https://images.openfoodfacts.org/images/products/402/885/601/4978/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4028856014978', 'front_4028856014978'),
    ('Gut Bio', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/406/145/802/9650/front_en.77.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458029650', 'front_4061458029650'),
    ('Lyttos', 'Griechisches natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/406/936/510/6273/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4069365106273', 'front_4069365106273'),
    ('Primadonna', 'Brat Olivenöl', 'https://images.openfoodfacts.org/images/products/405/648/901/7493/front_en.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489017493', 'front_4056489017493'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'https://images.openfoodfacts.org/images/products/405/648/995/7652/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489957652', 'front_4056489957652'),
    ('Aldi', 'Griechisches natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/406/145/806/3074/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458063074', 'front_4061458063074'),
    ('Bellasan', 'Oliven Öl', 'https://images.openfoodfacts.org/images/products/404/724/794/9293/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247949293', 'front_4047247949293'),
    ('K-Classic', 'Natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/402/885/601/5272/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4028856015272', 'front_4028856015272'),
    ('Lidl', 'Natives Olivenöl extra aus Griechenland', 'https://images.openfoodfacts.org/images/products/405/648/941/2472/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489412472', 'front_4056489412472'),
    ('DmBio', 'Natives Olivenöl extra naturtrüb', 'https://images.openfoodfacts.org/images/products/405/817/277/7400/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172777400', 'front_4058172777400'),
    ('Cucina Nobile', 'Natives Olivenöl', 'https://images.openfoodfacts.org/images/products/406/145/806/3470/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458063470', 'front_4061458063470'),
    ('Aldi Bellasan', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 'https://images.openfoodfacts.org/images/products/404/724/794/9286/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247949286', 'front_4047247949286'),
    ('Bellasan', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/409/920/002/3526/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4099200023526', 'front_4099200023526'),
    ('Aldi', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/406/145/913/8856/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459138856', 'front_4061459138856'),
    ('Primadonna', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/405/648/916/6856/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489166856', 'front_4056489166856'),
    ('Rapunzel', 'Ö-Kreta Olivenöl nativ extra-10,48€/29.6.22', 'https://images.openfoodfacts.org/images/products/400/604/000/2062/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040002062', 'front_4006040002062'),
    ('Ener Bio', 'Griechisches natives Olivenöl e', 'https://images.openfoodfacts.org/images/products/406/813/406/0273/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068134060273', 'front_4068134060273'),
    ('Deluxe', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/405/648/979/8552/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489798552', 'front_4056489798552'),
    ('K Favorites', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/406/336/700/0614/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367000614', 'front_4063367000614'),
    ('Rapunzel', 'Olivenöl fruchtig', 'https://images.openfoodfacts.org/images/products/400/604/019/6518/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040196518', 'front_4006040196518'),
    ('Rapunzel', 'Olivenöl nativ extra mild', 'https://images.openfoodfacts.org/images/products/400/604/020/5548/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040205548', 'front_4006040205548'),
    ('Rapunzel', 'Ölivenöl Finca la Torre', 'https://images.openfoodfacts.org/images/products/400/604/011/2327/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040112327', 'front_4006040112327'),
    ('Biozentrsle', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/400/500/910/3048/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005009103048', 'front_4005009103048'),
    ('Deluxe', 'Öl - Olivenöl Extra G.G.A. Chania Kritis', 'https://images.openfoodfacts.org/images/products/405/648/963/9817/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489639817', 'front_4056489639817'),
    ('Dennree', 'Olivenöl nativ extra', 'https://images.openfoodfacts.org/images/products/402/185/158/5139/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021851585139', 'front_4021851585139'),
    ('Rapunzel', 'Rapunzel Olivenöl Fruchtig, Nativ Extra, 0,5 LTR Flasche', 'https://images.openfoodfacts.org/images/products/400/604/020/5111/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040205111', 'front_4006040205111'),
    ('Bertolli', 'Natives Olivenöl Originale', 'https://images.openfoodfacts.org/images/products/800/247/003/1944/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 8002470031944', 'front_8002470031944'),
    ('Rewe', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/433/725/641/4371/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256414371', 'front_4337256414371'),
    ('Edeka Bio', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 'https://images.openfoodfacts.org/images/products/431/150/163/5773/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501635773', 'front_4311501635773'),
    ('Alnatura', 'Olivenöl', 'https://images.openfoodfacts.org/images/products/410/442/024/8823/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420248823', 'front_4104420248823'),
    ('Gut & Günstig', 'Olivenöl Extra Natives', 'https://images.openfoodfacts.org/images/products/431/159/642/1626/front_de.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311596421626', 'front_4311596421626'),
    ('D.O.P. Terra Di Bari Castel Del Monte', 'Italienisches natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/433/725/602/1654/front_hr.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256021654', 'front_4337256021654'),
    ('Bertolli', 'Olivenöl Natives Extra Gentile SANFT', 'https://images.openfoodfacts.org/images/products/800/247/003/1937/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 8002470031937', 'front_8002470031937'),
    ('BioBio', 'Natives Bio-Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/431/626/857/6161/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268576161', 'front_4316268576161'),
    ('EDEKA Bio', 'Natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/431/150/131/1943/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501311943', 'front_4311501311943'),
    ('Rewe beste Wahl', 'Olivenöl ideal für warme Speisen', 'https://images.openfoodfacts.org/images/products/433/725/607/9792/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256079792', 'front_4337256079792'),
    ('Ja!', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/433/725/662/5784/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256625784', 'front_4337256625784'),
    ('La Espaniola', 'Natives Ölivenöl extra', 'https://images.openfoodfacts.org/images/products/841/066/010/1153/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 8410660101153', 'front_8410660101153'),
    ('Las Cuarenta', 'Spanisches Natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/431/626/851/0738/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268510738', 'front_4316268510738'),
    ('Natur Gut', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/000/002/159/6278/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 21596278', 'front_21596278'),
    ('Bio', 'Bio natives Olivenöl', 'https://images.openfoodfacts.org/images/products/800/280/210/3288/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 8002802103288', 'front_8002802103288'),
    ('Primadonna', 'Bio natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/433/561/911/0694/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619110694', 'front_4335619110694'),
    ('Vegola', 'Natives Olivenöl extra', 'https://images.openfoodfacts.org/images/products/431/626/839/3478/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268393478', 'front_4316268393478'),
    ('Fiore', 'Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/800/846/000/4332/front_en.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 8008460004332', 'front_8008460004332'),
    ('REWE Feine Welt', 'Natives Olivenöl Extra Lesvos g.g.A.', 'https://images.openfoodfacts.org/images/products/433/725/687/6872/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256876872', 'front_4337256876872'),
    ('Edeka', 'Griechisches Natives Olivenöl Extra', 'https://images.openfoodfacts.org/images/products/431/150/149/0884/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501490884', 'front_4311501490884')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Oils & Vinegars' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

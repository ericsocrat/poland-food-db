-- PIPELINE (Alcohol): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Alcohol'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'https://images.openfoodfacts.org/images/products/590/001/400/5716/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014005716', 'front_5900014005716'),
    ('Harnaś', 'Harnaś jasne pełne', 'https://images.openfoodfacts.org/images/products/590/001/400/4245/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014004245', 'front_5900014004245'),
    ('Van Pur S.A.', 'Łomża piwo jasne bezalkoholowe', 'https://images.openfoodfacts.org/images/products/590/053/501/3986/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900535013986', 'front_5900535013986'),
    ('Karmi', 'Karmi o smaku żurawina', 'https://images.openfoodfacts.org/images/products/590/001/400/2562/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014002562', 'front_5900014002562'),
    ('Żywiec', 'Limonż 0%', 'https://images.openfoodfacts.org/images/products/590/069/910/6388/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900699106388', 'front_5900699106388'),
    ('Lomża', 'Łomża jasne', 'https://images.openfoodfacts.org/images/products/590/353/890/0628/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903538900628', 'front_5903538900628'),
    ('Kompania Piwowarska', 'Kozel cerny', 'https://images.openfoodfacts.org/images/products/590/135/907/4290/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359074290', 'front_5901359074290'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'https://images.openfoodfacts.org/images/products/590/270/961/5323/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902709615323', 'front_5902709615323'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'https://images.openfoodfacts.org/images/products/590/135/907/4269/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359074269', 'front_5901359074269'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'https://images.openfoodfacts.org/images/products/590/135/906/2013/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359062013', 'front_5901359062013'),
    ('Książęce', 'Książęce czerwony lager', 'https://images.openfoodfacts.org/images/products/590/135/901/4784/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359014784', 'front_5901359014784'),
    ('Lech', 'Lech Premium', 'https://images.openfoodfacts.org/images/products/590/049/000/0182/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900490000182', 'front_5900490000182'),
    ('Kompania Piwowarska', 'Lech free', 'https://images.openfoodfacts.org/images/products/590/135/912/2021/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359122021', 'front_5901359122021'),
    ('Zatecky', 'Zatecky 0%', 'https://images.openfoodfacts.org/images/products/590/001/400/5105/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014005105', 'front_5900014005105'),
    ('Łomża', 'Radler 0,0%', 'https://images.openfoodfacts.org/images/products/590/053/501/9209/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900535019209', 'front_5900535019209'),
    ('Łomża', 'Bière sans alcool', 'https://images.openfoodfacts.org/images/products/590/053/501/5171/front_it.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900535015171', 'front_5900535015171'),
    ('Warka', 'Piwo Warka Radler', 'https://images.openfoodfacts.org/images/products/590/069/910/6463/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900699106463', 'front_5900699106463'),
    ('Lech', 'Lech Free Lime Mint', 'https://images.openfoodfacts.org/images/products/590/135/914/4917/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359144917', 'front_5901359144917'),
    ('Carlsberg', 'Pilsner 0.0%', 'https://images.openfoodfacts.org/images/products/590/001/400/3569/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900014003569', 'front_5900014003569'),
    ('Amber', 'Amber IPA zero', 'https://images.openfoodfacts.org/images/products/590/659/100/2520/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906591002520', 'front_5906591002520'),
    ('Unknown', 'Lech Free Citrus Sour', 'https://images.openfoodfacts.org/images/products/590/135/914/4689/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901359144689', 'front_5901359144689'),
    ('Shroom', 'Shroom power', 'https://images.openfoodfacts.org/images/products/590/571/898/3308/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905718983308', 'front_5905718983308'),
    ('Heineken', 'Heineken Beer', 'https://images.openfoodfacts.org/images/products/871/200/090/0045/front_fr.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712000900045', 'front_8712000900045'),
    ('Choya', 'Silver', 'https://images.openfoodfacts.org/images/products/490/584/696/0050/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4905846960050', 'front_4905846960050'),
    ('Ikea', 'Glühwein', 'https://images.openfoodfacts.org/images/products/170/431/483/0009/front_en.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 1704314830009', 'front_1704314830009'),
    ('Just 0.', 'Just 0 White alcoholfree', 'https://images.openfoodfacts.org/images/products/400/330/106/9086/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003301069086', 'front_4003301069086'),
    ('Just 0.', 'Just 0. Red', 'https://images.openfoodfacts.org/images/products/400/330/106/9048/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003301069048', 'front_4003301069048'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'https://images.openfoodfacts.org/images/products/460/072/102/1566/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4600721021566', 'front_4600721021566'),
    ('Carlo Rossi', 'Vin carlo rossi', 'https://images.openfoodfacts.org/images/products/008/500/002/4683/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 0085000024683', 'front_0085000024683'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 'https://images.openfoodfacts.org/images/products/385/677/758/4161/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 3856777584161', 'front_3856777584161')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

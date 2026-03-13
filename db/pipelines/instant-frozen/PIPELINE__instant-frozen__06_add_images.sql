-- PIPELINE (Instant & Frozen): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Instant & Frozen'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 'https://images.openfoodfacts.org/images/products/590/188/231/3927/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882313927', 'front_5901882313927'),
    ('Ajinomoto', 'Oyakata w stylu japoński klasyczny', 'https://images.openfoodfacts.org/images/products/590/138/450/2751/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384502751', 'front_5901384502751'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'https://images.openfoodfacts.org/images/products/590/750/100/1404/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501001404', 'front_5907501001404'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', 'https://images.openfoodfacts.org/images/products/590/188/231/3941/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882313941', 'front_5901882313941'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 'https://images.openfoodfacts.org/images/products/590/511/801/3384/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905118013384', 'front_5905118013384'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'https://images.openfoodfacts.org/images/products/590/511/801/3391/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905118013391', 'front_5905118013391'),
    ('Vifon', 'Korean Hot Beef', 'https://images.openfoodfacts.org/images/products/590/188/231/5075/front_en.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882315075', 'front_5901882315075'),
    ('Vifon', 'Kimchi', 'https://images.openfoodfacts.org/images/products/590/188/211/0298/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882110298', 'front_5901882110298'),
    ('Goong', 'Curry Noodles', 'https://images.openfoodfacts.org/images/products/590/750/100/1428/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501001428', 'front_5907501001428'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', 'https://images.openfoodfacts.org/images/products/590/511/804/0816/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905118040816', 'front_5905118040816'),
    ('Vifon', 'Ramen Soy Souce', 'https://images.openfoodfacts.org/images/products/590/188/201/8563/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882018563', 'front_5901882018563'),
    ('Vifon', 'Ramen Tonkotsu', 'https://images.openfoodfacts.org/images/products/590/188/231/5051/front_pl.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882315051', 'front_5901882315051'),
    ('Sam Smak', 'Pomidorowa', 'https://images.openfoodfacts.org/images/products/590/138/450/8043/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384508043', 'front_5901384508043'),
    ('Oyakata', 'Ramen Miso et Légumes', 'https://images.openfoodfacts.org/images/products/590/138/450/6636/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384506636', 'front_5901384506636'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 'https://images.openfoodfacts.org/images/products/590/138/450/6681/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384506681', 'front_5901384506681'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 'https://images.openfoodfacts.org/images/products/590/138/450/6582/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384506582', 'front_5901384506582'),
    ('Oyakata', 'Nouilles de blé', 'https://images.openfoodfacts.org/images/products/590/138/450/6650/front_fr.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384506650', 'front_5901384506650'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 'https://images.openfoodfacts.org/images/products/590/138/450/6629/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384506629', 'front_5901384506629'),
    ('Oyakata', 'Ramen Barbecue', 'https://images.openfoodfacts.org/images/products/590/138/450/1051/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384501051', 'front_5901384501051'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 'https://images.openfoodfacts.org/images/products/482/017/925/6871/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4820179256871', 'front_4820179256871'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 'https://images.openfoodfacts.org/images/products/482/017/925/4761/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4820179254761', 'front_4820179254761'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', 'https://images.openfoodfacts.org/images/products/590/138/450/8074/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384508074', 'front_5901384508074'),
    ('Ajinomoto', 'Tomato soup', 'https://images.openfoodfacts.org/images/products/590/138/450/5646/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384505646', 'front_5901384505646'),
    ('Ajinomoto', 'Mushrood soup', 'https://images.openfoodfacts.org/images/products/590/138/450/5653/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901384505653', 'front_5901384505653'),
    ('Vifon', 'Zupka hińska', 'https://images.openfoodfacts.org/images/products/000/000/815/3825/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 08153825', 'front_08153825'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'https://images.openfoodfacts.org/images/products/880/104/305/7752/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043057752', 'front_8801043057752'),
    ('Nongshim', 'Kimchi Bowl Noodles', 'https://images.openfoodfacts.org/images/products/880/104/305/7776/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043057776', 'front_8801043057776'),
    ('Nongshim', 'Super Spicy Red Shin', 'https://images.openfoodfacts.org/images/products/880/104/305/3167/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043053167', 'front_8801043053167'),
    ('Indomie', 'Noodles Chicken Flavour', 'https://images.openfoodfacts.org/images/products/899/496/300/2824/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 8994963002824', 'front_8994963002824'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 'https://images.openfoodfacts.org/images/products/482/017/925/6581/front_en.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4820179256581', 'front_4820179256581'),
    ('NongshimSamyang', 'Ramen kimchi', 'https://images.openfoodfacts.org/images/products/007/460/300/3287/front_en.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 0074603003287', 'front_0074603003287'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'https://images.openfoodfacts.org/images/products/885/098/715/0098/front_en.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 8850987150098', 'front_8850987150098'),
    ('มาม่า', 'Mala Beef Instant Noodle', 'https://images.openfoodfacts.org/images/products/885/098/715/1279/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 8850987151279', 'front_8850987151279'),
    ('Mama', 'Mama salted egg', 'https://images.openfoodfacts.org/images/products/885/098/714/8651/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8850987148651', 'front_8850987148651'),
    ('Reeva', 'Zupa o smaku sera i boczku', 'https://images.openfoodfacts.org/images/products/482/017/925/6895/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4820179256895', 'front_4820179256895'),
    ('Knorr', 'Nudle Pieczony kurczak', 'https://images.openfoodfacts.org/images/products/871/410/066/6630/front_pl.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 8714100666630', 'front_8714100666630'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', 'https://images.openfoodfacts.org/images/products/502/375/100/0339/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5023751000339', 'front_5023751000339'),
    ('Unknown', 'Chicken flavour', 'https://images.openfoodfacts.org/images/products/871/997/920/3672/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8719979203672', 'front_8719979203672'),
    ('Nongshim', 'Shin Kimchi Noodles', 'https://images.openfoodfacts.org/images/products/880/104/302/8158/front_en.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 8801043028158', 'front_8801043028158'),
    ('Ko-Lee', 'Instant noodles curry flavour', 'https://images.openfoodfacts.org/images/products/502/375/100/0322/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5023751000322', 'front_5023751000322'),
    ('Namdong', 'Beef Jjigae k-noodles', 'https://images.openfoodfacts.org/images/products/872/131/771/3040/front_es.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8721317713040', 'front_8721317713040'),
    ('Knorr', 'Makaron ser z bekonem', 'https://images.openfoodfacts.org/images/products/871/242/301/9461/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 8712423019461', 'front_8712423019461'),
    ('Knorr', 'Makaron 4 sery', 'https://images.openfoodfacts.org/images/products/872/018/200/1641/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8720182001641', 'front_8720182001641')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

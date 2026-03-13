-- PIPELINE (Instant & Frozen): source provenance
-- Generated: 2026-03-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 'https://world.openfoodfacts.org/product/5901882313927', '5901882313927'),
    ('Ajinomoto', 'Oyakata w stylu japoński klasyczny', 'https://world.openfoodfacts.org/product/5901384502751', '5901384502751'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'https://world.openfoodfacts.org/product/5907501001404', '5907501001404'),
    ('Vifon', 'Mie Goreng łagodne w stylu indonezyjskim', 'https://world.openfoodfacts.org/product/5901882313941', '5901882313941'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 'https://world.openfoodfacts.org/product/5905118013384', '5905118013384'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'https://world.openfoodfacts.org/product/5905118013391', '5905118013391'),
    ('Vifon', 'Korean Hot Beef', 'https://world.openfoodfacts.org/product/5901882315075', '5901882315075'),
    ('Vifon', 'Kimchi', 'https://world.openfoodfacts.org/product/5901882110298', '5901882110298'),
    ('Goong', 'Curry Noodles', 'https://world.openfoodfacts.org/product/5907501001428', '5907501001428'),
    ('Asia Style', 'VeggieMeal Thai Spicy Ramen', 'https://world.openfoodfacts.org/product/5905118040816', '5905118040816'),
    ('Vifon', 'Ramen Soy Souce', 'https://world.openfoodfacts.org/product/5901882018563', '5901882018563'),
    ('Vifon', 'Ramen Tonkotsu', 'https://world.openfoodfacts.org/product/5901882315051', '5901882315051'),
    ('Sam Smak', 'Pomidorowa', 'https://world.openfoodfacts.org/product/5901384508043', '5901384508043'),
    ('Oyakata', 'Ramen Miso et Légumes', 'https://world.openfoodfacts.org/product/5901384506636', '5901384506636'),
    ('Ajinomoto', 'Ramen nouille de blé saveur poulet shio', 'https://world.openfoodfacts.org/product/5901384506681', '5901384506681'),
    ('Ajinomoto', 'Nouilles de blé poulet teriyaki', 'https://world.openfoodfacts.org/product/5901384506582', '5901384506582'),
    ('Oyakata', 'Nouilles de blé', 'https://world.openfoodfacts.org/product/5901384506650', '5901384506650'),
    ('Oyakata', 'Yakisoba saveur Poulet pad thaï', 'https://world.openfoodfacts.org/product/5901384506629', '5901384506629'),
    ('Oyakata', 'Ramen Barbecue', 'https://world.openfoodfacts.org/product/5901384501051', '5901384501051'),
    ('Reeva', 'Zupa błyskawiczna o smaku kurczaka', 'https://world.openfoodfacts.org/product/4820179256871', '4820179256871'),
    ('Rollton', 'Zupa błyskawiczna o smaku gulaszu', 'https://world.openfoodfacts.org/product/4820179254761', '4820179254761'),
    ('Unknown', 'SamSmak o smaku serowa 4 sery', 'https://world.openfoodfacts.org/product/5901384508074', '5901384508074'),
    ('Ajinomoto', 'Tomato soup', 'https://world.openfoodfacts.org/product/5901384505646', '5901384505646'),
    ('Ajinomoto', 'Mushrood soup', 'https://world.openfoodfacts.org/product/5901384505653', '5901384505653'),
    ('Vifon', 'Zupka hińska', 'https://world.openfoodfacts.org/product/08153825', '08153825'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'https://world.openfoodfacts.org/product/8801043057752', '8801043057752'),
    ('Nongshim', 'Kimchi Bowl Noodles', 'https://world.openfoodfacts.org/product/8801043057776', '8801043057776'),
    ('Nongshim', 'Super Spicy Red Shin', 'https://world.openfoodfacts.org/product/8801043053167', '8801043053167'),
    ('Indomie', 'Noodles Chicken Flavour', 'https://world.openfoodfacts.org/product/8994963002824', '8994963002824'),
    ('Reeva', 'REEVA Vegetable flavour Instant noodles', 'https://world.openfoodfacts.org/product/4820179256581', '4820179256581'),
    ('NongshimSamyang', 'Ramen kimchi', 'https://world.openfoodfacts.org/product/0074603003287', '0074603003287'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'https://world.openfoodfacts.org/product/8850987150098', '8850987150098'),
    ('มาม่า', 'Mala Beef Instant Noodle', 'https://world.openfoodfacts.org/product/8850987151279', '8850987151279'),
    ('Mama', 'Mama salted egg', 'https://world.openfoodfacts.org/product/8850987148651', '8850987148651'),
    ('Reeva', 'Zupa o smaku sera i boczku', 'https://world.openfoodfacts.org/product/4820179256895', '4820179256895'),
    ('Knorr', 'Nudle Pieczony kurczak', 'https://world.openfoodfacts.org/product/8714100666630', '8714100666630'),
    ('Ko-Lee', 'Instant Noodles Tomato Flavour', 'https://world.openfoodfacts.org/product/5023751000339', '5023751000339'),
    ('Unknown', 'Chicken flavour', 'https://world.openfoodfacts.org/product/8719979203672', '8719979203672'),
    ('Nongshim', 'Shin Kimchi Noodles', 'https://world.openfoodfacts.org/product/8801043028158', '8801043028158'),
    ('Ko-Lee', 'Instant noodles curry flavour', 'https://world.openfoodfacts.org/product/5023751000322', '5023751000322'),
    ('Namdong', 'Beef Jjigae k-noodles', 'https://world.openfoodfacts.org/product/8721317713040', '8721317713040'),
    ('Knorr', 'Makaron ser z bekonem', 'https://world.openfoodfacts.org/product/8712423019461', '8712423019461'),
    ('Knorr', 'Makaron 4 sery', 'https://world.openfoodfacts.org/product/8720182001641', '8720182001641')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE;

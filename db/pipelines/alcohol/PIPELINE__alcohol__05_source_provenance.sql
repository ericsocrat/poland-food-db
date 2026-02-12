-- PIPELINE (Alcohol): source provenance
-- Generated: 2026-02-12

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Amber', 'Amber IPA zero', 'https://world.openfoodfacts.org/product/5906591002520', '5906591002520'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'https://world.openfoodfacts.org/product/5902709615323', '5902709615323'),
    ('Carlo Rossi', 'Vin carlo rossi', 'https://world.openfoodfacts.org/product/0085000024683', '0085000024683'),
    ('Carlsberg', 'Pilsner 0.0%', 'https://world.openfoodfacts.org/product/5900014003569', '5900014003569'),
    ('Choya', 'Silver', 'https://world.openfoodfacts.org/product/4905846960050', '4905846960050'),
    ('Christkindl', 'Christkindl Glühwein', 'https://world.openfoodfacts.org/product/4304493261709', '4304493261709'),
    ('Harnaś', 'Harnaś jasne pełne', 'https://world.openfoodfacts.org/product/5900014004245', '5900014004245'),
    ('Heineken', 'Heineken Beer', 'https://world.openfoodfacts.org/product/8712000900045', '8712000900045'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'https://world.openfoodfacts.org/product/4600721021566', '4600721021566'),
    ('Ikea', 'Glühwein', 'https://world.openfoodfacts.org/product/1704314830009', '1704314830009'),
    ('Just 0', 'Just 0 White alcoholfree', 'https://world.openfoodfacts.org/product/4003301069086', '4003301069086'),
    ('Just 0', 'Just 0. Red', 'https://world.openfoodfacts.org/product/4003301069048', '4003301069048'),
    ('Karmi', 'Karmi o smaku żurawina', 'https://world.openfoodfacts.org/product/5900014002562', '5900014002562'),
    ('Kompania Piwowarska', 'Kozel cerny', 'https://world.openfoodfacts.org/product/5901359074290', '5901359074290'),
    ('Kompania Piwowarska', 'Lech free', 'https://world.openfoodfacts.org/product/5901359122021', '5901359122021'),
    ('Książęce', 'Książęce czerwony lager', 'https://world.openfoodfacts.org/product/5901359014784', '5901359014784'),
    ('Lech', 'Lech Free Lime Mint', 'https://world.openfoodfacts.org/product/5901359144917', '5901359144917'),
    ('Lech', 'Lech Premium', 'https://world.openfoodfacts.org/product/5900490000182', '5900490000182'),
    ('Łomża', 'Bière sans alcool', 'https://world.openfoodfacts.org/product/5900535015171', '5900535015171'),
    ('Łomża', 'Łomża jasne', 'https://world.openfoodfacts.org/product/5903538900628', '5903538900628'),
    ('Łomża', 'Radler 0,0%', 'https://world.openfoodfacts.org/product/5900535019209', '5900535019209'),
    ('Seth & Riley''S Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'https://world.openfoodfacts.org/product/5900014005716', '5900014005716'),
    ('Shroom', 'Shroom power', 'https://world.openfoodfacts.org/product/5905718983308', '5905718983308'),
    ('Somersby', 'Somersby Blueberry Flavoured Cider', 'https://world.openfoodfacts.org/product/3856777584161', '3856777584161'),
    ('Tyskie', 'Bier "Tyskie Gronie"', 'https://world.openfoodfacts.org/product/5901359062013', '5901359062013'),
    ('Van Pur S.A', 'Łomża piwo jasne bezalkoholowe', 'https://world.openfoodfacts.org/product/5900535013986', '5900535013986'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'https://world.openfoodfacts.org/product/5901359074269', '5901359074269'),
    ('Warka', 'Piwo Warka Radler', 'https://world.openfoodfacts.org/product/5900699106463', '5900699106463'),
    ('Zatecky', 'Zatecky 0%', 'https://world.openfoodfacts.org/product/5900014005105', '5900014005105'),
    ('Żywiec', 'Limonż 0%', 'https://world.openfoodfacts.org/product/5900699106388', '5900699106388')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;

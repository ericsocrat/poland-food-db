-- PIPELINE (Alcohol): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'https://world.openfoodfacts.org/product/5900014005716', '5900014005716'),
    ('Harnaś', 'Harnaś jasne pełne', 'https://world.openfoodfacts.org/product/5900014004245', '5900014004245'),
    ('Van Pur S.A.', 'Łomża piwo jasne bezalkoholowe', 'https://world.openfoodfacts.org/product/5900535013986', '5900535013986'),
    ('Karmi', 'Karmi o smaku żurawina', 'https://world.openfoodfacts.org/product/5900014002562', '5900014002562'),
    ('Żywiec', 'Limonż 0%', 'https://world.openfoodfacts.org/product/5900699106388', '5900699106388'),
    ('Lomża', 'Łomża jasne', 'https://world.openfoodfacts.org/product/5903538900628', '5903538900628'),
    ('Kompania Piwowarska', 'Kozel cerny', 'https://world.openfoodfacts.org/product/5901359074290', '5901359074290'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'https://world.openfoodfacts.org/product/5902709615323', '5902709615323'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'https://world.openfoodfacts.org/product/5901359074269', '5901359074269'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'https://world.openfoodfacts.org/product/5901359062013', '5901359062013'),
    ('Lech', 'Lech Premium', 'https://world.openfoodfacts.org/product/5900490000182', '5900490000182'),
    ('Kompania Piwowarska', 'Lech free', 'https://world.openfoodfacts.org/product/5901359122021', '5901359122021'),
    ('Zatecky', 'Zatecky 0%', 'https://world.openfoodfacts.org/product/5900014005105', '5900014005105'),
    ('Łomża', 'Radler 0,0%', 'https://world.openfoodfacts.org/product/5900535019209', '5900535019209'),
    ('Lech', 'Lech Free Lime Mint', 'https://world.openfoodfacts.org/product/5901359144917', '5901359144917'),
    ('Carlsberg', 'Pilsner 0.0%', 'https://world.openfoodfacts.org/product/5900014003569', '5900014003569'),
    ('Amber', 'Amber IPA zero', 'https://world.openfoodfacts.org/product/5906591002520', '5906591002520'),
    ('Christkindl', 'Christkindl Glühwein', 'https://world.openfoodfacts.org/product/4304493261709', '4304493261709'),
    ('Heineken', 'Heineken Beer', 'https://world.openfoodfacts.org/product/8712000900045', '8712000900045'),
    ('Choya', 'Silver', 'https://world.openfoodfacts.org/product/4905846960050', '4905846960050'),
    ('Ikea', 'Glühwein', 'https://world.openfoodfacts.org/product/1704314830009', '1704314830009'),
    ('Just 0.', 'Just 0 White alcoholfree', 'https://world.openfoodfacts.org/product/4003301069086', '4003301069086'),
    ('Just 0.', 'Just 0. Red', 'https://world.openfoodfacts.org/product/4003301069048', '4003301069048'),
    ('Hoegaarden', 'Hoegaarden hveteøl, 4,9%', 'https://world.openfoodfacts.org/product/4600721021566', '4600721021566'),
    ('Carlo Rossi', 'Vin carlo rossi', 'https://world.openfoodfacts.org/product/0085000024683', '0085000024683')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE;

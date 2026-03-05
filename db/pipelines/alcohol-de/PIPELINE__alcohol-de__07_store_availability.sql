-- PIPELINE (Alcohol): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-04

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Franziskaner', 'Franziskaner Premium Weissbier Naturtrüb', 'REWE'),
    ('Hauser Weinimport', 'Glühwein rot', 'Aldi'),
    ('Köstritzer', 'Köstritzer Schwarzbier', 'REWE'),
    ('Bayreuther Brauhaus', 'Bayreuther', 'REWE'),
    ('Pülleken', 'Veltins', 'Penny'),
    ('Veltins', 'Bier - Veltins Pilsener', 'Edeka'),
    ('Rotkäppchen', 'Sekt halbtrocken', 'Edeka'),
    ('Rotkäppchen', 'Sekt halbtrocken', 'REWE'),
    ('Rotkäppchen', 'Sekt halbtrocken', 'Norma'),
    ('Berliner', 'Berliner Pilsner', 'Edeka'),
    ('Berliner', 'Berliner Pilsner', 'Penny'),
    ('Jever', 'Jever Pilsener', 'REWE'),
    ('0 Original', '5,0 Original Pils', 'REWE'),
    ('Mönchshof', 'Natur Radler', 'Edeka'),
    ('Störtebeker', 'Atlantik Ale', 'REWE'),
    ('Nordbrand Nordhausen', 'Pfefferminz', 'REWE'),
    ('Nordbrand Nordhausen', 'Pfefferminz', 'Netto'),
    ('Nordbrand Nordhausen', 'Pfefferminz', 'Kaufland'),
    ('Warsteiner', 'Radler alkoholfrei', 'Edeka'),
    ('Warsteiner', 'Pilsener', 'Aldi'),
    ('Warsteiner', 'Pilsener', 'Kaufland'),
    ('Rothaus', 'Tannenzäpfle', 'Edeka'),
    ('Christkindl', 'Christkindl Glühwein', 'Lidl'),
    ('Gösser', 'Natur Radler', 'Aldi'),
    ('Budweiser', 'Budvar', 'REWE'),
    ('Budweiser', 'Budvar', 'Kaufland'),
    ('Unknown', 'Pilsner Urquell', 'REWE'),
    ('Unknown', 'Pilsner Urquell', 'Penny'),
    ('Carlsberg', 'Apple Cider', 'REWE'),
    ('Cerveceria Modelio', 'Corona Extra', 'Real'),
    ('Cerveceria Modelio', 'Corona Extra', 'Norma')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

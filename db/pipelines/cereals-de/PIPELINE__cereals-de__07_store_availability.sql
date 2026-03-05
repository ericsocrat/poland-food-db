-- PIPELINE (Cereals): store availability
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
    ('Kölln', 'Haferflocken Blütenzart', 'Edeka'),
    ('Kölln', 'Haferflocken Blütenzart', 'REWE'),
    ('Kölln', 'Haferflocken Blütenzart', 'Tegut'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 'Aldi'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 'Edeka'),
    ('Lorenz', 'Erdnußlocken Classic', 'Aldi'),
    ('Lorenz', 'Erdnußlocken Classic', 'Lidl'),
    ('Lorenz', 'Erdnußlocken Classic', 'Edeka'),
    ('Lorenz', 'Erdnußlocken Classic', 'REWE'),
    ('Lorenz', 'Erdnußlocken Classic', 'Penny'),
    ('Lorenz', 'Erdnußlocken Classic', 'Netto'),
    ('Lorenz', 'Erdnußlocken Classic', 'Kaufland'),
    ('Lorenz', 'Erdnußlocken Classic', 'Norma'),
    ('Kölln', 'Kernige Haferflocken', 'REWE'),
    ('Nippon', 'Puffreis mit Schokolade', 'Lidl'),
    ('Golden Bridge', 'Zarte Haferflocken', 'Aldi'),
    ('Kölln', 'Bio-Haferflocken zart', 'Aldi'),
    ('Kölln', 'Bio-Haferflocken zart', 'Edeka'),
    ('Kölln', 'Bio-Haferflocken zart', 'REWE'),
    ('Kölln', 'Bio-Haferflocken zart', 'Netto'),
    ('Crownfield', 'Bio Haferflocken zart', 'Lidl'),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'Penny'),
    ('Kölln', 'Vollkorn Haferfleks', 'Edeka'),
    ('Kölln', 'Vollkorn Haferfleks', 'Real'),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', 'Aldi'),
    ('EDEKA Bio', 'Cornflakes ungesüßt', 'Edeka'),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', 'REWE'),
    ('Ja', 'Haferflocken', 'REWE'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 'Edeka'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 'REWE'),
    ('Crownfield', 'Flocons d''Avoine', 'Lidl'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'Aldi'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'Edeka'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'REWE'),
    ('Nestlé', 'FITNESS Cerealien', 'REWE'),
    ('Gut & Günstig', 'Nougat Bits', 'Edeka'),
    ('REWE Bio', 'Rewe Bio Haferflocken zart', 'REWE'),
    ('REWE Bio', 'Dinkel Flakes', 'REWE'),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', 'REWE'),
    ('Edeka', 'Haferflocken extra zart', 'Edeka'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 'Lidl'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 'REWE')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Cereals' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

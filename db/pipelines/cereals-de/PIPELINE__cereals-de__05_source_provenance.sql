-- PIPELINE (Cereals): source provenance
-- Generated: 2026-03-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Kölln', 'Haferflocken, Blütenzarte Köllnflocken', 'https://world.openfoodfacts.org/product/4000540000108', '4000540000108'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 'https://world.openfoodfacts.org/product/4000540011050', '4000540011050'),
    ('Lorenz', 'Erdnußlocken Classic', 'https://world.openfoodfacts.org/product/4018077006203', '4018077006203'),
    ('Kölln', 'Kernige Haferflocken', 'https://world.openfoodfacts.org/product/4000540000306', '4000540000306'),
    ('Nippon', 'Puffreis mit Schokolade', 'https://world.openfoodfacts.org/product/4021700900021', '4021700900021'),
    ('Golden Bridge', 'Zarte Haferflocken', 'https://world.openfoodfacts.org/product/4061464911895', '4061464911895'),
    ('Kölln', 'Bio-Haferflocken zart', 'https://world.openfoodfacts.org/product/4000540000641', '4000540000641'),
    ('Crownfield', 'Bio Haferflocken zart', 'https://world.openfoodfacts.org/product/4056489665519', '4056489665519'),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'https://world.openfoodfacts.org/product/4000540005028', '4000540005028'),
    ('Kölln', 'Vollkorn Haferfleks', 'https://world.openfoodfacts.org/product/4000540011081', '4000540011081'),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', 'https://world.openfoodfacts.org/product/4061459674101', '4061459674101'),
    ('Nur Nur Natur', 'Haferflocken zart', 'https://world.openfoodfacts.org/product/4061463845337', '4061463845337'),
    ('Kölln', 'Knusprige Haferfleks Schoko', 'https://world.openfoodfacts.org/product/4000540091069', '4000540091069'),
    ('Golden Bridge', 'Haferflocken kernig', 'https://world.openfoodfacts.org/product/4061464912014', '4061464912014'),
    ('EDEKA Bio', 'Cornflakes ungesüßt', 'https://world.openfoodfacts.org/product/4311501043646', '4311501043646'),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', 'https://world.openfoodfacts.org/product/4337256379519', '4337256379519'),
    ('EnerBiO', 'Dinkel Gepufft', 'https://world.openfoodfacts.org/product/4067796001839', '4067796001839'),
    ('DmBio', 'Fruchtringe', 'https://world.openfoodfacts.org/product/4066447663075', '4066447663075'),
    ('Ja', 'Haferflocken', 'https://world.openfoodfacts.org/product/4337256415965', '4337256415965'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 'https://world.openfoodfacts.org/product/7613033212949', '7613033212949'),
    ('Crownfield', 'Flocons d''Avoine', 'https://world.openfoodfacts.org/product/20003166', '20003166'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'https://world.openfoodfacts.org/product/4260582961519', '4260582961519'),
    ('Nestlé', 'FITNESS Cerealien', 'https://world.openfoodfacts.org/product/3387390339499', '3387390339499'),
    ('Gut & Günstig', 'Nougat Bits', 'https://world.openfoodfacts.org/product/4311501720073', '4311501720073'),
    ('Rewe Bio', 'Rewe Bio Haferflocken zart', 'https://world.openfoodfacts.org/product/4337256783132', '4337256783132'),
    ('Rewe Bio', 'Dinkel Flakes', 'https://world.openfoodfacts.org/product/4337256739689', '4337256739689'),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', 'https://world.openfoodfacts.org/product/4337256436649', '4337256436649'),
    ('Edeka', 'Haferflocken extra zart', 'https://world.openfoodfacts.org/product/4311501492246', '4311501492246'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 'https://world.openfoodfacts.org/product/7613287433633', '7613287433633'),
    ('Kellogg''s', 'Kellogg''s Smacks', 'https://world.openfoodfacts.org/product/5059319023670', '5059319023670'),
    ('Ja!', 'Chico Chips', 'https://world.openfoodfacts.org/product/4337256782531', '4337256782531'),
    ('Oat-Ly!', 'Hafer Barista light', 'https://world.openfoodfacts.org/product/7394376621703', '7394376621703'),
    ('Alnatura', 'Dinkel Crunchy', 'https://world.openfoodfacts.org/product/4104420254756', '4104420254756'),
    ('Oatly!', 'Oatly Hafer Barista Edition', 'https://world.openfoodfacts.org/product/7394376617904', '7394376617904'),
    ('Weetabix', 'Weetabix produit à base de blé complet 100%', 'https://world.openfoodfacts.org/product/5010029000023', '5010029000023'),
    ('Alnatura', 'Schoko Hafer Crunchy', 'https://world.openfoodfacts.org/product/4104420238244', '4104420238244')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Cereals' AND p.is_deprecated IS NOT TRUE;

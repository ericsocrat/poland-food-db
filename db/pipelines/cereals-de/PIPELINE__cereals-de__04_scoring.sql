-- PIPELINE (Cereals): scoring
-- Generated: 2026-03-04

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
    ('Kölln', 'Haferflocken Blütenzart', 'A'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 'C'),
    ('Lorenz', 'Erdnußlocken Classic', 'D'),
    ('Kölln', 'Kernige Haferflocken', 'A'),
    ('Nippon', 'Puffreis mit Schokolade', 'E'),
    ('Golden Bridge', 'Zarte Haferflocken', 'A'),
    ('Kölln', 'Bio-Haferflocken zart', 'A'),
    ('Crownfield', 'Bio Haferflocken zart', 'A'),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'D'),
    ('Kölln', 'Vollkorn Haferfleks', 'C'),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', 'B'),
    ('Nur Nur Natur', 'Haferflocken zart', 'A'),
    ('Kölln', 'Knusprige Haferfleks Schoko', 'D'),
    ('Golden Bridge', 'Haferflocken kernig', 'A'),
    ('EDEKA Bio', 'Cornflakes ungesüßt', 'B'),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', 'B'),
    ('Dm Bio', 'Dinkel Gepufft', 'B'),
    ('Ja', 'Haferflocken', 'A'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 'C'),
    ('Crownfield', 'Flocons d''Avoine', 'A'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 'C'),
    ('Nestlé', 'FITNESS Cerealien', 'A'),
    ('Gut & Günstig', 'Nougat Bits', 'D'),
    ('REWE Bio', 'Rewe Bio Haferflocken zart', 'A'),
    ('REWE Bio', 'Dinkel Flakes', 'A'),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', 'E'),
    ('Edeka', 'Haferflocken extra zart', 'A'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 'C'),
    ('Alpro', 'Hafer Milch', 'A'),
    ('Oatly!', 'Haferdrink Barista Bio', 'A'),
    ('Oatly!', 'Hafer Barista light', 'A'),
    ('Alnatura', 'Dinkel Crunchy', 'C'),
    ('Oatly!', 'Oatly Hafer Barista Edition', 'A'),
    ('Weetabix', 'Weetabix produit à base de blé complet 100%', 'A'),
    ('Alnatura', 'Schoko Hafer Crunchy', 'C')
) as d(brand, product_name, ns)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
    ('Kölln', 'Haferflocken Blütenzart', '1'),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', '4'),
    ('Lorenz', 'Erdnußlocken Classic', '4'),
    ('Kölln', 'Kernige Haferflocken', '1'),
    ('Nippon', 'Puffreis mit Schokolade', '4'),
    ('Golden Bridge', 'Zarte Haferflocken', '1'),
    ('Kölln', 'Bio-Haferflocken zart', '1'),
    ('Crownfield', 'Bio Haferflocken zart', '1'),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', '4'),
    ('Kölln', 'Vollkorn Haferfleks', '4'),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', '3'),
    ('Nur Nur Natur', 'Haferflocken zart', '4'),
    ('Kölln', 'Knusprige Haferfleks Schoko', '4'),
    ('Golden Bridge', 'Haferflocken kernig', '1'),
    ('EDEKA Bio', 'Cornflakes ungesüßt', '4'),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', '3'),
    ('Dm Bio', 'Dinkel Gepufft', '3'),
    ('Ja', 'Haferflocken', '1'),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', '4'),
    ('Crownfield', 'Flocons d''Avoine', '1'),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', '3'),
    ('Nestlé', 'FITNESS Cerealien', '4'),
    ('Gut & Günstig', 'Nougat Bits', '4'),
    ('REWE Bio', 'Rewe Bio Haferflocken zart', '1'),
    ('REWE Bio', 'Dinkel Flakes', '3'),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', '4'),
    ('Edeka', 'Haferflocken extra zart', '1'),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', '4'),
    ('Alpro', 'Hafer Milch', '4'),
    ('Oatly!', 'Haferdrink Barista Bio', '3'),
    ('Oatly!', 'Hafer Barista light', '3'),
    ('Alnatura', 'Dinkel Crunchy', '3'),
    ('Oatly!', 'Oatly Hafer Barista Edition', '3'),
    ('Weetabix', 'Weetabix produit à base de blé complet 100%', '3'),
    ('Alnatura', 'Schoko Hafer Crunchy', '3')
) as d(brand, product_name, nova)
where p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category('Cereals', 100, 'DE');

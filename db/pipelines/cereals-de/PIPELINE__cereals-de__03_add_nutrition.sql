-- PIPELINE (Cereals): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Cereals'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Kölln', 'Haferflocken Blütenzart', 361.0, 6.7, 1.3, 0, 56.0, 1.2, 11.0, 14.0, 0.0),
    ('Kölln', 'E Knusprige Haferfleks Klassik Kölln', 392.0, 5.4, 1.1, 0, 72.0, 17.0, 7.5, 9.7, 1.1),
    ('Lorenz', 'Erdnußlocken Classic', 499.0, 25.0, 3.0, 0, 52.0, 2.3, 4.9, 14.0, 2.0),
    ('Kölln', 'Kernige Haferflocken', 361.0, 6.7, 1.3, 0, 56.0, 1.2, 11.0, 14.0, 0.0),
    ('Nippon', 'Puffreis mit Schokolade', 533.0, 30.0, 21.0, 0, 50.0, 40.0, 0, 5.6, 0.2),
    ('Golden Bridge', 'Zarte Haferflocken', 375.0, 7.0, 1.3, 0, 59.0, 0.7, 10.0, 14.0, 0.0),
    ('Kölln', 'Bio-Haferflocken zart', 364.0, 6.4, 1.2, 0, 59.0, 1.2, 9.2, 13.0, 0.0),
    ('Crownfield', 'Bio Haferflocken zart', 371.0, 6.7, 1.1, 0, 59.5, 0.8, 9.7, 13.2, 0.0),
    ('Kölln', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 423.0, 13.0, 3.5, 0, 64.0, 28.0, 8.7, 8.3, 0.9),
    ('Kölln', 'Vollkorn Haferfleks', 390.0, 5.4, 1.1, 0, 72.0, 17.0, 7.5, 9.5, 1.1),
    ('DE-VAU-GE Gesundkostwerk', 'Cornflakes', 376.0, 0.6, 0.2, 0, 83.0, 3.0, 4.5, 7.4, 0.8),
    ('Nur Nur Natur', 'Haferflocken zart', 372.0, 7.0, 1.3, 0, 58.7, 0.7, 10.0, 13.5, 0.0),
    ('Kölln', 'Knusprige Haferfleks Schoko', 394.0, 5.2, 1.7, 0, 73.0, 27.0, 6.8, 10.0, 1.0),
    ('Golden Bridge', 'Haferflocken kernig', 375.0, 7.0, 1.3, 0, 59.0, 0.7, 10.0, 14.0, 0.0),
    ('EDEKA Bio', 'Cornflakes ungesüßt', 388.0, 1.5, 0.3, 0, 84.6, 0.6, 0, 7.5, 0.0),
    ('REWE Bio', 'Dinkel gepufft mit Honig gesüßt', 381.0, 3.0, 0.5, 0, 73.0, 20.0, 7.0, 12.0, 0.0),
    ('Dm Bio', 'Dinkel Gepufft', 377.9, 2.2, 0.3, 0, 75.0, 24.0, 6.8, 10.0, 0.1),
    ('Ja', 'Haferflocken', 371.0, 6.7, 1.1, 0, 59.5, 0.8, 9.7, 13.2, 0.0),
    ('Nestlé', 'NESTLE NESQUIK Cerealien', 376.7, 3.0, 0.7, 0, 74.6, 22.1, 9.3, 8.7, 0.2),
    ('Crownfield', 'Flocons d''Avoine', 372.0, 7.0, 1.3, 0, 58.7, 0.7, 10.0, 13.5, 0.0),
    ('Wholey', 'Chillo Pillows - Bio-Kakaokissen', 372.0, 4.9, 1.0, 0, 65.0, 15.0, 10.0, 12.0, 0.8),
    ('Nestlé', 'FITNESS Cerealien', 366.0, 2.1, 0.6, 0, 72.2, 8.8, 10.7, 9.4, 0.6),
    ('Gut & Günstig', 'Nougat Bits', 480.0, 22.0, 6.3, 0, 61.0, 27.0, 4.9, 7.0, 0.3),
    ('REWE Bio', 'Rewe Bio Haferflocken zart', 364.0, 6.6, 1.3, 0, 59.0, 1.2, 9.4, 13.0, 0.0),
    ('REWE Bio', 'Dinkel Flakes', 367.0, 2.5, 0.4, 0, 69.0, 6.4, 8.3, 13.0, 0.9),
    ('De-Vau-Ge', 'Cornflakes - Nougat Bits', 478.0, 21.8, 6.3, 0, 61.1, 27.0, 4.5, 7.0, 0.8),
    ('Edeka', 'Haferflocken extra zart', 372.0, 7.0, 1.3, 0, 58.7, 0.7, 10.0, 13.5, 0.0),
    ('Nestlé', 'NESTLE NESQUIK WAVES Cerealien', 389.0, 4.8, 1.3, 0, 73.6, 22.4, 7.7, 8.9, 0.2),
    ('Alpro', 'Hafer Milch', 44.0, 1.5, 0.2, 0, 6.4, 0.0, 0.7, 0.8, 0.1),
    ('Oatly!', 'Haferdrink Barista Bio', 59.0, 3.2, 0.3, 0, 6.3, 2.2, 0.7, 1.0, 0.1),
    ('Oatly!', 'Hafer Barista light', 52.0, 2.1, 0.2, 0, 7.0, 3.4, 0.8, 1.1, 0.1),
    ('Alnatura', 'Dinkel Crunchy', 437.0, 13.0, 0.7, 0, 66.0, 18.0, 6.2, 11.0, 0.2),
    ('Oatly!', 'Oatly Hafer Barista Edition', 61.0, 3.0, 0.3, 0, 7.1, 3.4, 0.8, 1.1, 0.1),
    ('Weetabix', 'Weetabix produit à base de blé complet 100%', 194.3, 2.1, 0.5, 0, 69.1, 4.3, 10.1, 12.0, 0.3),
    ('Alnatura', 'Schoko Hafer Crunchy', 439.0, 14.0, 3.2, 0, 64.0, 21.0, 8.6, 10.0, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Cereals' and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;

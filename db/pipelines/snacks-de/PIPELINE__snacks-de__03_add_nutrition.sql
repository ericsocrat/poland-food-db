-- PIPELINE (Snacks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Snacks'
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
    ('Pom-Bär', 'POM-BÄR Original', 516.0, 27.0, 2.8, 0, 62.0, 2.2, 4.9, 3.0, 1.5),
    ('Huober', 'Original schwäbische Knusper Brezel', 397.0, 6.2, 3.0, 0, 72.3, 2.6, 3.4, 11.3, 4.8),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 409.0, 14.0, 8.6, 0, 59.4, 24.9, 5.4, 8.3, 0.2),
    ('Leicht & Cross', 'Leicht & Cross Vollkorn Knäckebrot', 352.0, 3.6, 0.4, 0, 63.0, 3.9, 14.0, 10.0, 1.2),
    ('Corny', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 434.0, 14.7, 9.8, 0, 67.9, 33.0, 3.8, 5.6, 0.4),
    ('Leicht & Cross', 'Knäckebrot Vital: Vitamine und Mehrkorn', 364.0, 2.5, 0.3, 0, 70.0, 1.0, 8.8, 11.0, 1.3),
    ('Lorenz', 'Lorenz Saltletts Sticks', 392.0, 5.9, 0.8, 0, 71.0, 2.4, 3.0, 12.0, 3.8),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 337.0, 10.6, 6.3, 0, 62.3, 0.3, 6.3, 7.7, 0.1),
    ('Lorenz', 'Clubs Cracker', 485.0, 22.0, 1.8, 0, 61.0, 7.9, 2.4, 9.6, 1.7),
    ('Seeberger', 'Nuts''n Berries', 478.0, 27.0, 3.5, 0, 44.0, 36.0, 0, 11.0, 0.0),
    ('Corny', 'Nussvoll Nuss &Traube', 507.0, 31.0, 3.2, 0, 40.0, 23.0, 5.5, 14.0, 0.3),
    ('Corny', 'Milch Classic', 447.0, 18.7, 15.8, 0, 60.7, 26.8, 6.2, 6.1, 0.7),
    ('Rivercote', 'Knusperbrot Weizen', 388.8, 4.0, 0.5, 0, 70.0, 3.5, 8.4, 13.0, 1.2),
    ('Corny', 'CORNY Schoko', 433.0, 15.7, 8.4, 0, 64.7, 29.6, 3.4, 6.5, 0.5),
    ('Corny', 'Corny - Schoko-Banane', 436.0, 14.8, 9.9, 0, 68.4, 36.7, 3.7, 5.1, 0.4),
    ('DmBio', 'Schoko Reiswaffeln Zartbitter', 488.0, 23.0, 13.0, 0, 61.0, 28.0, 5.0, 6.6, 0.0),
    ('Leicht & Cross', 'Knusperbrot Goldweizen', 385.0, 4.0, 0.5, 0, 70.0, 3.5, 1.6, 13.0, 1.2),
    ('DmBio', 'Dinkel Mini brezeln', 421.0, 9.3, 4.2, 0, 71.0, 1.0, 4.4, 12.0, 2.7),
    ('Tuc', 'Tuc Original', 482.0, 19.0, 9.0, 0, 67.0, 7.1, 2.4, 8.3, 1.7),
    ('Pågen', 'Gifflar Cannelle', 373.0, 14.0, 2.8, 0, 52.0, 19.0, 0.0, 7.3, 0.0),
    ('Alnatura', 'Linsenwaffeln', 360.0, 1.0, 0.2, 0, 58.0, 1.5, 5.4, 27.0, 0.5),
    ('Alesto', 'Cruspies Paprika', 561.0, 35.0, 4.0, 0, 44.0, 7.5, 4.8, 15.0, 2.2),
    ('Snack Day', 'Erdnuss Flips', 501.0, 24.1, 3.5, 0, 54.5, 2.5, 6.1, 13.5, 1.6),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', 425.5, 16.7, 8.7, 0, 36.4, 0.0, 13.3, 23.6, 0.6),
    ('KoRo', 'Protein Bar Deluxe', 397.0, 20.0, 8.5, 0, 37.0, 4.2, 8.5, 25.0, 0.8),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', 453.3, 25.0, 3.3, 0, 40.0, 36.7, 6.0, 14.0, 0.3),
    ('Mondelez', 'Paprika', 495.0, 23.0, 10.0, 0, 63.0, 4.8, 2.5, 7.8, 2.1),
    ('ESN', 'Designer Protein Bar', 377.8, 10.9, 0.0, 0.0, 30.9, 1.8, 0.0, 31.1, 0.4),
    ('Maretti', 'Bruschette', 453.0, 14.0, 1.2, 0, 71.0, 5.5, 3.3, 9.1, 2.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Snacks' and p.is_deprecated is not true
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

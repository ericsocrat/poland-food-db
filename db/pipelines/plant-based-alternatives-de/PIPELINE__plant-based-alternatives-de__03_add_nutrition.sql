-- PIPELINE (Plant-Based & Alternatives): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Plant-Based & Alternatives'
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
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 122.0, 9.2, 0.8, 0, 3.9, 2.4, 7.4, 2.2, 2.3),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 209.0, 11.0, 0.9, 0, 13.0, 0.6, 5.0, 12.0, 1.5),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 224.0, 11.0, 0.9, 0, 14.0, 1.2, 6.4, 14.0, 1.4),
    ('Mühlenbauer', 'Vegane Bratwürste', 170.0, 12.0, 1.0, 0, 6.4, 0.8, 3.2, 7.1, 1.8),
    ('Eberswalder', 'Vegetarios Würstchen', 216.0, 18.0, 1.2, 0, 2.8, 1.1, 1.5, 10.0, 2.7),
    ('Vemondo', 'Bio Tofu geräuchert', 154.0, 10.0, 1.3, 0, 0.7, 0.4, 2.5, 14.0, 0.6),
    ('Rügenwalder Mühle', 'Vegane Mühlen Crispies', 231.0, 10.0, 0.8, 0, 20.0, 1.3, 6.5, 12.0, 1.9),
    ('Gut Bio', 'Griechische Bio-Oliven, grün', 140.0, 14.0, 1.9, 0, 0.9, 0.8, 0, 1.2, 2.7),
    ('Jerg', 'Vegane Genießerscheiben würzig', 273.0, 21.4, 18.8, 0, 19.0, 0.3, 0.5, 1.0, 3.2),
    ('Rügenwalder Mühle', 'Vegane Mühlen Bratwurst', 175.0, 12.0, 1.0, 0, 8.0, 1.0, 4.4, 8.2, 1.9),
    ('Rügenwalder Mühle', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 233.0, 8.0, 0.6, 0, 9.5, 2.3, 3.5, 29.0, 2.8),
    ('My Vay', 'Bio-Tofu Geräuchert', 150.0, 9.1, 1.4, 0, 0.4, 0.0, 1.6, 15.8, 0.9),
    ('DmBio', 'Tomaten Stücke', 26.0, 0.2, 0.0, 0, 4.0, 4.0, 0.9, 1.5, 0.1),
    ('Taifun', 'Räuchertofu Mandel-Sesam', 198.0, 12.0, 1.9, 0, 1.5, 0.5, 0, 19.0, 1.7),
    ('Henglein', 'Gnocchi Kartoffel-Klößchen', 149.0, 1.0, 0.3, 0, 31.0, 4.0, 0, 2.8, 0.0),
    ('DmBio', 'Maiswaffeln', 384.0, 1.4, 0.2, 0, 85.0, 0.2, 1.7, 7.0, 0.0),
    ('Vemondo', 'Tofu Natur', 149.0, 9.0, 1.5, 0, 0.7, 0.5, 0.8, 16.0, 0.0),
    ('Rügenwalder Mühle', 'Veganer Schinken Spicker Bunter Pfeffer', 116.0, 9.0, 0.7, 0, 3.1, 1.5, 7.0, 2.2, 2.3),
    ('DmBio', 'Mais Waffeln gesalzen', 382.0, 1.4, 0.2, 0, 85.0, 0.5, 1.7, 7.0, 0.0),
    ('Rügenwalder Mühle', 'Vegan Curry aufschnitt', 92.0, 3.6, 0.3, 0, 3.4, 0.5, 6.4, 8.4, 2.0),
    ('Gut Bio', 'Bio-Linsenwaffeln - Meersalz', 373.1, 1.5, 0.4, 0, 55.2, 1.4, 7.2, 29.9, 0.5),
    ('Kühne', 'Rotkohl', 49.0, 0.1, 0.1, 0, 9.0, 7.3, 2.5, 1.3, 1.2),
    ('Harry', 'Steinofenbrot, Harry 1688', 220.0, 1.5, 0.3, 0, 42.0, 1.7, 5.2, 7.1, 1.0),
    ('Better Plant', 'Vegane Creme', 290.0, 30.0, 27.3, 0, 2.0, 1.8, 0, 2.7, 0.4),
    ('REWE Bio +vegan', 'Räucher-Tofu', 188.0, 11.0, 1.8, 0, 1.3, 0.6, 2.5, 21.0, 0.8),
    ('Rewe', 'Falafel bällchen', 210.0, 8.7, 0.9, 0, 19.0, 0.5, 7.3, 11.0, 1.3),
    ('Taifun', 'Tofu fumé', 84.5, 9.0, 1.6, 0.0, 2.5, 0.5, 0.0, 19.0, 0.0),
    ('Rewe Beste Wahl', 'Milde Genießer Scheiben', 285.0, 21.0, 18.0, 0, 24.0, 0.0, 0, 0.0, 1.6),
    ('Simply V', 'Würzig verfeinert mit Mandelöl', 251.0, 18.0, 12.0, 0, 19.0, 0.5, 0, 0.5, 2.5),
    ('Plant Republic', 'Räucher-Tofu', 146.0, 8.5, 1.3, 0, 1.9, 0.5, 1.0, 15.0, 0.9),
    ('K-take it veggie', 'Bio Tofu geräuchert', 186.0, 10.6, 1.8, 0, 1.3, 0.6, 2.5, 20.7, 1.2),
    ('No-Name', 'Bananen süß & samtig', 96.0, 0.2, 0.1, 0, 22.0, 17.2, 2.0, 1.1, 0.0),
    ('Taifun', 'Filets de tofu à la japonaise', 205.0, 13.0, 2.0, 0, 2.4, 0.3, 0, 19.0, 1.4),
    ('EDEKA Bio', 'My Veggie Tofu geräuchert', 188.0, 10.6, 1.8, 0, 1.3, 0.6, 0, 20.7, 0.8),
    ('Taifun', 'Tofu natur', 123.0, 6.7, 1.2, 0, 1.3, 0.5, 0, 14.0, 0.0),
    ('Like Meat', 'Like Grilled Chicken', 116.0, 1.7, 0.2, 0, 1.1, 0.0, 8.0, 20.0, 2.0),
    ('Like Meat', 'Like Chicken', 104.0, 1.7, 0.2, 0, 1.1, 0.0, 5.9, 18.0, 1.8),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 88.0, 0.3, 0.1, 0, 13.4, 13.4, 3.6, 4.5, 0.5),
    ('Freshona', 'Cornichons Gurken', 35.0, 0.3, 0.1, 0, 5.5, 4.1, 1.4, 1.2, 1.2),
    ('Rewe Bio', 'Tofu Natur', 129.0, 7.5, 1.0, 0, 1.8, 0.5, 0, 13.0, 0.2),
    ('Baresa', 'Tomaten passiert', 25.0, 0.2, 0.1, 0, 3.8, 3.8, 1.0, 1.6, 0.4),
    ('Garden Gourmet', 'Sensational Burger aus Sojaprotein', 176.1, 11.0, 0.7, 0, 3.9, 1.3, 5.9, 12.4, 0.9),
    ('Sondey', 'Mais Waffeln mit Meersalz Bio', 382.4, 1.2, 0.3, 0, 85.9, 0.5, 0, 6.9, 0.3),
    ('Greenforce', 'Pflanzliche Mini-Frika', 238.0, 16.0, 2.0, 0, 7.0, 1.0, 5.0, 14.0, 1.9),
    ('Ja', 'Tomaten passiert', 27.0, 0.5, 0.1, 0, 3.8, 3.8, 1.0, 1.8, 0.3),
    ('REWE Bio', 'Sojasahne', 181.0, 17.1, 2.1, 0, 2.7, 0.9, 0, 3.6, 0.1),
    ('Simply V', 'Gerieben Pizza', 285.0, 20.0, 14.0, 0, 23.0, 0.5, 0, 3.2, 2.0),
    ('Ja!', 'Cherry-Roma Tomaten Klasse 1', 18.0, 0.2, 0.1, 0, 3.5, 1.9, 1.3, 0.9, 0.0),
    ('EDEKA Bio', 'My Veggie Tofu Natur', 138.0, 8.0, 1.4, 0, 0.7, 0.4, 0, 15.4, 0.0),
    ('REWE Bio', 'Linsenwaffeln', 378.0, 2.2, 0.4, 0, 59.0, 2.4, 11.0, 25.0, 0.5),
    ('Nestlé', 'Vegane Filet-Streifen', 233.0, 12.4, 1.0, 0, 3.2, 2.8, 8.5, 22.9, 0.8),
    ('Greenforce', 'Pflanzliche Cevapcici', 238.0, 16.0, 2.0, 0, 7.0, 2.0, 5.0, 14.0, 2.0),
    ('EnerBiO', 'Veggie Hack', 383.0, 8.8, 2.1, 0, 1.9, 0.0, 5.7, 71.0, 1.7),
    ('Edeka Bio', 'Tomatenmark 2-fach konzentriert', 95.0, 0.3, 0.1, 0, 15.0, 15.0, 3.5, 4.8, 0.2),
    ('Rewe', 'Tofu Natur', 138.0, 8.0, 1.4, 0, 0.7, 0.5, 0, 15.4, 0.0),
    ('Like Meat', 'Like Beef Strips', 120.0, 2.4, 0.3, 0, 5.8, 2.8, 5.6, 16.0, 1.8),
    ('Rama', 'Kochcreme', 159.0, 15.0, 6.0, 0, 4.8, 1.5, 0, 0.6, 0.1),
    ('Edeka', 'My Veggie Tofu Classic', 146.0, 8.5, 1.3, 0, 1.8, 0.5, 0, 15.0, 0.0),
    ('Alnatura', 'Linsen Waffeln', 360.0, 1.0, 0.2, 0, 58.0, 1.5, 5.4, 27.0, 0.5)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Plant-Based & Alternatives' and p.is_deprecated is not true
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

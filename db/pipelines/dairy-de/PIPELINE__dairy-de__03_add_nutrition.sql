-- PIPELINE (Dairy): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Dairy'
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
    ('Milsani', 'Frischkäse natur', 241.0, 23.0, 16.1, 0, 2.9, 2.9, 0, 5.5, 0.7),
    ('Gervais', 'Hüttenkäse Original', 86.5, 3.2, 2.1, 0, 1.5, 1.5, 0, 12.3, 0.8),
    ('Milsani', 'Körniger Frischkäse, Halbfettstufe', 103.0, 4.6, 3.0, 0, 2.7, 2.7, 0.0, 12.2, 0.6),
    ('Almette', 'Almette Kräuter', 251.0, 23.0, 15.0, 0, 4.7, 3.2, 0, 5.4, 1.1),
    ('Bergader', 'Bergbauern mild nussig Käse', 343.0, 27.0, 18.0, 0, 0.1, 0.1, 0, 25.0, 1.2),
    ('DOVGAN Family', 'Körniger Frischkäse 33 % Fett', 177.0, 9.0, 6.0, 0, 4.0, 4.0, 0, 20.0, 0.2),
    ('BMI Biobauern', 'Bio-Landkäse mild-nussig', 361.0, 28.0, 18.2, 0, 0.1, 0.1, 0.0, 26.5, 1.4),
    ('Dr. Oetker', 'High Protein Pudding Grieß', 81.0, 1.5, 0.9, 0, 9.1, 4.4, 0, 7.5, 0.2),
    ('Milsan', 'Grießpudding High-Protein - Zimt', 79.2, 1.5, 1.0, 0, 8.6, 4.7, 0, 7.6, 0.1),
    ('Milram', 'Frühlingsquark Original', 142.0, 10.0, 6.9, 0, 3.7, 3.7, 0, 8.8, 0.8),
    ('DMK', 'Müritzer original', 386.0, 33.0, 22.8, 0, 0.1, 0.1, 0, 21.0, 1.8),
    ('Milsani', 'Körniger Frischkäse - Magerstufe', 71.0, 0.4, 0.3, 0, 2.0, 1.9, 0, 11.0, 0.5),
    ('AF Deutschland', 'Hirtenkäse', 255.0, 19.8, 12.6, 0, 0.6, 0.6, 0, 17.4, 2.5),
    ('Grünländer', 'Grünländer Mild & Nussig', 364.0, 29.0, 19.0, 0, 0.5, 0.5, 0, 25.0, 0.8),
    ('Grünländer', 'Grünländer Leicht', 280.0, 17.0, 11.0, 0, 0.5, 0.5, 0.0, 31.0, 0.8),
    ('Gazi', 'Grill- und Pfannenkäse', 323.0, 25.0, 16.7, 0, 1.0, 1.0, 0, 23.5, 2.4),
    ('Bio', 'ALDI GUT BIO Milch Frische Bio-Milch 1.5 % Fett Aus der Kühlung 1l 1.15€ Fettarme Milch', 47.0, 1.5, 0.9, 0, 4.9, 4.9, 0, 3.5, 0.0),
    ('Milsani', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 65.0, 0.2, 0.1, 0, 4.4, 4.4, 0, 11.0, 0.1),
    ('Karwendel', 'Exquisa Balance Frischkäse', 91.0, 4.0, 2.8, 0, 3.1, 3.1, 0.0, 10.0, 0.4),
    ('Weihenstephan', 'H-Milch 3,5%', 64.0, 3.5, 2.3, 0, 4.7, 4.7, 0, 3.5, 0.1),
    ('Milbona', 'Skyr', 62.0, 0.2, 0.1, 0, 4.0, 4.0, 0.0, 11.0, 0.1),
    ('Arla', 'Skyr Natur', 61.0, 0.2, 0.1, 0, 4.0, 4.0, 0, 10.0, 0.1),
    ('Milsani', 'H-Vollmilch 3,5 % Fett', 64.0, 3.5, 2.3, 0, 4.8, 4.8, 0, 3.3, 0.1),
    ('Elinas', 'Joghurt Griechischer Art', 116.0, 9.4, 6.3, 0, 3.9, 3.9, 0, 3.3, 0.1),
    ('Alpenhain', 'Obazda klassisch', 328.0, 29.0, 19.0, 0, 3.0, 1.5, 0, 13.0, 1.7),
    ('Ehrmann', 'High Protein Chocolate Pudding', 76.0, 1.5, 1.0, 0.0, 5.5, 4.0, 0.0, 10.0, 0.0),
    ('Bio', 'Frische Bio-Vollmilch 3,8 % Fett', 68.0, 3.9, 2.6, 0, 4.8, 4.8, 0, 3.4, 0.1),
    ('Milsani', 'Haltbare Fettarme Milch', 47.0, 1.5, 1.1, 0, 5.0, 5.0, 0, 3.4, 0.1),
    ('Arla', 'Skyr Bourbon Vanille', 73.0, 0.2, 0.1, 0, 8.6, 7.5, 0, 8.6, 0.1),
    ('Milbona', 'High Protein Chocolate Flavour Pudding', 76.0, 1.5, 1.0, 0, 5.2, 4.0, 0, 10.0, 0.1),
    ('Milsani', 'Joghurt mild 3,5 % Fett', 70.0, 3.5, 2.4, 0, 4.8, 4.8, 0, 4.3, 0.1),
    ('Schwarzwaldmilch', 'Protein Milch', 51.0, 0.1, 0.0, 0, 5.0, 5.0, 0.0, 7.5, 0.1),
    ('Bresso', 'Bresso', 237.0, 21.0, 14.0, 0, 4.9, 2.8, 0, 7.1, 1.2),
    ('Milsani', 'Milch', 47.0, 1.5, 1.0, 0, 4.9, 4.9, 0, 3.5, 0.1),
    ('Bergader', 'Bavaria Blu', 392.0, 37.5, 24.4, 0, 0.1, 0.1, 0, 13.6, 1.8),
    ('Aldi', 'Milch, haltbar, 1,5 %, Bio', 46.0, 1.5, 1.0, 0, 4.8, 4.8, 0, 3.3, 0.1),
    ('Aldi', 'A/Joghurt mild 3,5% Fett', 69.0, 3.5, 2.4, 0, 4.8, 4.8, 0, 4.0, 0.1),
    ('Patros', 'Patros Natur', 282.0, 24.0, 16.0, 0, 0.7, 0.7, 0, 15.0, 2.7),
    ('Ehrmann', 'High-Protein-Pudding - Vanilla', 76.0, 1.5, 1.0, 0, 5.5, 4.0, 0, 10.0, 0.0),
    ('Patros', 'Feta (Schaf- & Ziegenmilch)', 288.0, 24.0, 17.0, 0, 0.5, 0.5, 0, 18.0, 2.4),
    ('Milsani', 'Frische Vollmilch 3,5%', 64.0, 3.5, 2.3, 0, 4.8, 4.8, 0, 3.4, 0.1),
    ('Milram', 'Benjamin', 238.7, 29.0, 20.0, 0, 0.1, 0.1, 0, 23.0, 1.8),
    ('Milbona', 'Bio Fettarmer Joghurt mild', 54.0, 1.8, 1.2, 0, 3.8, 3.8, 0.0, 4.8, 0.2),
    ('Bauer', 'Kirsche', 88.0, 2.9, 2.0, 0, 12.2, 11.4, 0, 3.2, 0.0),
    ('Milbona', 'Skyr Vanilla', 53.6, 0.2, 0.1, 0, 4.1, 3.3, 0.1, 8.8, 0.1),
    ('Weihenstephan', 'Joghurt Natur 3,5 % Fett', 72.0, 3.5, 2.4, 0, 5.1, 5.1, 0, 4.4, 0.1),
    ('Cucina Nobile', 'Mozzarella', 246.4, 19.0, 12.0, 0, 1.0, 1.0, 0, 18.0, 0.5),
    ('Bio', 'Bio-Feta', 276.0, 23.0, 16.0, 0, 0.7, 0.7, 0, 16.5, 2.5),
    ('Ein gutes Stück Bayern', 'Haltbare Bio Vollmilch', 67.0, 3.9, 2.6, 0, 4.8, 4.8, 0.0, 3.2, 0.1),
    ('Lyttos', 'Griechischer Joghurt', 117.0, 9.2, 6.1, 0, 4.5, 4.5, 0, 4.1, 0.1),
    ('AF Deutschland', 'Fettarme Milch (laktosefrei; 1,5% Fett)', 47.0, 1.5, 1.0, 0, 4.8, 4.8, 0, 3.4, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Dairy' and p.is_deprecated is not true
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

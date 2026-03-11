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
    ('Bürger', 'Maultaschen traditionell schwäbisch', 198.0, 9.1, 3.4, 0, 19.0, 2.0, 1.9, 9.1, 1.6),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 224.0, 11.0, 0.9, 0, 14.0, 1.2, 6.4, 14.0, 1.4),
    ('Rügenwalder Mühle', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 233.0, 8.0, 0.6, 0, 9.5, 2.3, 3.5, 29.0, 2.8),
    ('DmBio', 'Maiswaffeln', 384.0, 1.4, 0.2, 0, 85.0, 0.2, 1.7, 7.0, 0.0),
    ('Vemondo', 'Tofu Natur', 149.0, 9.0, 1.5, 0, 0.7, 0.5, 0.8, 16.0, 0.0),
    ('REWE Bio +vegan', 'Räucher-Tofu', 188.0, 11.0, 1.8, 0, 1.3, 0.6, 2.5, 21.0, 0.8),
    ('Rewe', 'Falafel bällchen', 210.0, 8.7, 0.9, 0, 19.0, 0.5, 7.3, 11.0, 1.3),
    ('Like Meat', 'Like Grilled Chicken', 116.0, 1.7, 0.2, 0, 1.1, 0.0, 8.0, 20.0, 2.0),
    ('Like Meat', 'Like Chicken', 104.0, 1.7, 0.2, 0, 1.1, 0.0, 5.9, 18.0, 1.8),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 88.0, 0.3, 0.1, 0, 13.4, 13.4, 3.6, 4.5, 0.5),
    ('Freshona', 'Cornichons Gurken', 35.0, 0.3, 0.1, 0, 5.5, 4.5, 1.4, 1.2, 1.2),
    ('Rewe Bio', 'Tofu Natur', 129.0, 7.5, 1.0, 0, 1.8, 0.5, 0, 13.0, 0.2),
    ('Baresa', 'Tomaten passiert', 25.0, 0.2, 0.1, 0, 3.8, 3.8, 1.0, 1.6, 0.4),
    ('Garden Gourmet', 'Sensational Burger aus Sojaprotein', 176.1, 11.0, 0.7, 0, 3.9, 1.3, 5.9, 12.4, 0.9),
    ('Sondey', 'Mais Waffeln mit Meersalz Bio', 382.4, 1.2, 0.3, 0, 85.9, 0.5, 0, 6.9, 0.3),
    ('Barilla', 'Fusilli 98', 359.0, 2.0, 0.5, 0, 71.0, 3.5, 3.0, 13.0, 0.0),
    ('Barilla', 'Spaghetti n5', 359.0, 2.0, 0.5, 0, 71.0, 3.5, 3.0, 13.0, 0.0)
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

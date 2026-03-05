-- PIPELINE (Breakfast & Grain-Based): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Breakfast & Grain-Based'
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
    ('Dr. Oetker', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 435.0, 15.0, 1.7, 0, 57.0, 13.0, 14.0, 11.0, 0.4),
    ('Kölln', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 434.0, 17.0, 5.9, 0, 52.0, 8.0, 17.0, 9.9, 0.4),
    ('Kölln', 'Knusper Honig-Nuss Müsli', 454.0, 18.0, 5.4, 0, 61.0, 19.0, 5.8, 9.9, 0.4),
    ('Dm', 'Bio Schokomüsli ohne Rosinen', 396.0, 9.5, 4.4, 0, 62.0, 12.0, 8.4, 11.0, 0.1),
    ('Kölln', 'Kellogs, Hafer-Müsli, Schoko und Keks', 444.0, 15.0, 6.3, 0, 65.0, 21.0, 5.6, 10.0, 0.2),
    ('Kölln', 'Zartes Bircher Müsli', 361.0, 6.3, 1.0, 0, 60.0, 17.0, 11.0, 11.0, 0.1),
    ('Seitenbacher', 'Kakao-Düsis', 377.0, 3.0, 1.0, 0, 62.0, 4.0, 12.0, 17.0, 0.0),
    ('Dr. Oetker Vitalis', 'Vitalis Weniger süß Knusper Himbeere', 431.0, 15.0, 1.7, 0.0, 71.0, 13.0, 14.0, 11.0, 0.0),
    ('Kölln', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 459.8, 17.0, 7.7, 0, 65.0, 23.0, 5.0, 8.4, 0.2),
    ('Kölln', 'Hafer Müsli Beere Apfel', 359.0, 4.7, 0.9, 0, 66.0, 14.0, 7.6, 9.6, 0.1),
    ('Dr. Oetker', 'Schoko Müsli klassisch', 414.0, 12.0, 4.8, 0, 61.0, 20.0, 8.3, 11.0, 0.1),
    ('Dr. Oetker', 'Vitalis Knusper Schoko Müsli', 435.0, 15.0, 2.6, 0, 57.0, 14.0, 14.0, 11.0, 0.1),
    ('Golden Bridge', 'Trauben-Nuss Müsli Vollkorn', 379.0, 11.0, 2.9, 0, 54.0, 12.0, 10.0, 11.0, 0.1),
    ('Dr. Oetker', 'Vitalis Knusper Müsli PLUS Nussmischung', 489.0, 23.0, 2.5, 0, 55.0, 18.0, 7.1, 11.0, 0.4),
    ('Dr. Oetker', 'Vitalis Müsli Joghurt', 414.0, 12.0, 4.4, 0, 62.0, 14.0, 7.3, 11.0, 0.3),
    ('Kölln', 'Crunchy Berry Hafer-Müsli', 446.0, 15.0, 5.8, 0, 65.0, 19.0, 6.3, 9.0, 0.2),
    ('Kölln', 'Kölln Müsli Nuss & Krokant', 406.0, 13.0, 1.8, 0, 57.0, 7.7, 8.4, 12.0, 0.1),
    ('Seitenbacher', 'Müsli 205 Für Sportliche', 380.0, 10.0, 2.0, 0, 65.0, 17.0, 9.0, 12.0, 0.2),
    ('Dr. Oetker', 'Vitalis Knusper müsli Honeys', 443.0, 14.0, 3.4, 0, 67.0, 22.0, 8.0, 9.3, 0.3),
    ('Golden Bridge', 'Schoko-Müsli mit 30 % weniger Zucker', 386.0, 8.6, 2.2, 0, 60.2, 7.3, 9.0, 12.5, 0.1),
    ('Golden Bridge', 'Früchte-Müsli', 338.0, 4.0, 1.7, 0, 63.0, 24.0, 8.4, 8.2, 0.1),
    ('DmBio', 'Beeren Müsli', 350.0, 5.8, 1.0, 0, 60.0, 18.0, 9.2, 9.5, 0.0),
    ('Dr. Oetker', 'Vitalis Knusper Müsli klassisch', 450.0, 16.0, 1.8, 0, 62.0, 21.0, 7.7, 11.0, 0.5),
    ('Crownfield', 'Schoko Müsli', 414.0, 12.8, 5.2, 0, 58.6, 14.8, 8.6, 11.7, 0.0),
    ('Dr. Oetker', 'Knusper Schoko Müsli', 442.0, 14.0, 2.4, 0, 65.0, 20.0, 8.2, 9.6, 0.5),
    ('GUT Bio', 'Basis Müsli 5-Kornmix', 370.0, 7.5, 1.2, 0, 57.0, 1.6, 11.0, 13.0, 0.1),
    ('Kölln', 'Crunchy Mango-Maracuja Hafer-Müsli', 436.0, 14.0, 5.0, 0, 66.0, 18.0, 6.1, 9.2, 0.2),
    ('Aldi', 'Bio-Müsli - Urkorn-Früchte', 350.0, 5.0, 0.5, 0, 61.1, 15.0, 8.9, 10.7, 0.0),
    ('Dr. Oetker', 'Müsli Schoko weniger süss', 405.0, 12.0, 4.0, 0, 59.0, 13.0, 9.2, 12.0, 0.0),
    ('Kölln', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 444.0, 16.0, 5.5, 0, 64.0, 22.0, 6.8, 8.5, 0.2),
    ('GUT bio', 'Bio Knusper-Müsli Schoko-Amaranth', 440.0, 15.0, 5.6, 0, 62.0, 17.0, 8.6, 10.0, 0.3),
    ('Seitenbacher', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 490.0, 28.0, 4.0, 0, 38.0, 3.0, 11.0, 16.0, 0),
    ('Golden Bridge', 'Früchte-Müsli Vollkorn', 348.0, 5.5, 1.8, 0, 61.0, 20.0, 9.4, 9.0, 0.1),
    ('Kölln', 'Crunchy Hazel Hafer-Müsli', 464.0, 19.0, 5.8, 0, 61.0, 18.0, 6.1, 9.9, 0.2),
    ('Kölln', 'Früchte Hafer-Müsli', 364.0, 6.0, 2.8, 0, 64.0, 22.0, 7.8, 9.5, 0.1),
    ('Kölln kölln', 'Schoko Müsli', 400.0, 11.5, 4.5, 0, 60.0, 11.5, 9.0, 11.0, 0.2),
    ('Kölln', 'Knusper Müsli', 442.0, 15.0, 5.5, 0, 64.0, 18.0, 6.9, 8.4, 0.2),
    ('Kölln', 'Hafer Müsli', 400.0, 11.5, 4.5, 0, 60.0, 11.5, 9.0, 11.0, 0.2),
    ('Kölln', 'Früchte Müsli ohne Zuckerzusatz', 364.0, 6.0, 2.8, 0, 64.1, 21.9, 7.8, 9.5, 0.1),
    ('DmBio', 'Müsli Nuss', 463.0, 18.0, 2.1, 0, 60.0, 15.0, 8.4, 11.0, 0.1),
    ('DmBio', 'Paleo Müsli', 489.0, 29.0, 3.4, 0, 36.0, 1.8, 7.2, 17.0, 0.0),
    ('Golden Bridge', 'Premium Müsli', 444.0, 16.0, 6.4, 0, 61.0, 17.0, 8.2, 10.0, 0.0),
    ('Dr. Oetker', 'Vitalis Müsli Knusper Schoko ohne Zuckerzusatz', 417.0, 16.0, 4.1, 0, 58.0, 1.3, 11.0, 11.0, 0.2),
    ('DmBio', 'Basismüsli ohne Rosinen', 383.0, 9.8, 1.6, 0, 56.0, 1.6, 11.0, 12.0, 0.0),
    ('Kölln', 'Knusper Schoko & Keks Müsli', 449.0, 17.0, 6.8, 0, 63.0, 22.0, 7.0, 8.7, 0.4),
    ('Kölln', 'Knusper Joghurt Himbeer Müsli', 412.0, 9.9, 3.8, 0, 67.0, 21.0, 7.7, 10.0, 0.5),
    ('Seitenbacher', 'Müsli 508 Dinos Frühstück', 413.0, 11.0, 4.0, 0, 65.0, 28.0, 7.0, 10.0, 0.0),
    ('Dr. Oetker', 'Paula Müslispaß Schoko', 412.0, 11.0, 3.0, 0, 60.0, 13.0, 15.0, 9.9, 0.3),
    ('DmBio', 'Früchte müsli', 346.0, 4.2, 0.7, 0, 65.0, 32.0, 9.7, 7.4, 0.0),
    ('Bauck Mühle', 'Schoko+Flakes Hafer Müsli Bio', 392.0, 10.0, 3.2, 0, 58.0, 4.1, 9.6, 12.0, 0.1),
    ('Brüggen', 'Schoko-Müsli', 408.0, 11.5, 5.0, 0, 61.3, 17.0, 6.8, 11.3, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Breakfast & Grain-Based' and p.is_deprecated is not true
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

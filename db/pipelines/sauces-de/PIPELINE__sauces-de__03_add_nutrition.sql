-- PIPELINE (Sauces): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Sauces'
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
    ('DmBio', 'Tomatensoße Klassik', 96.0, 5.4, 0.6, 0, 8.0, 7.0, 3.6, 2.1, 1.2),
    ('Hengstenberg', 'Tomaten stückig mit Kräutern', 28.0, 0.5, 0.1, 0, 3.5, 3.5, 2.3, 1.3, 0.8),
    ('Bautz''ner', 'Fix Tomatensoße', 103.0, 4.3, 0.3, 0, 14.6, 11.1, 0, 0.9, 2.4),
    ('DmBio', 'Tomatensoße Arrabbiata', 81.0, 2.9, 0.4, 0, 7.4, 6.5, 2.8, 2.1, 1.2),
    ('InnFood Organic', 'Bio-Tomatensauce - Gemüse und Parmesan', 76.0, 3.1, 0.8, 0, 8.0, 6.7, 1.6, 3.1, 0.8),
    ('DmBio', 'Tomatensauce Kräuter', 57.0, 2.9, 0.4, 0, 5.6, 4.5, 1.1, 1.6, 0.9),
    ('Aldi', 'Passierte Tomaten', 26.0, 0.5, 0.1, 0, 3.8, 3.7, 0, 1.5, 0.4),
    ('DmBio', 'Tomatensauce - Ricotta Pecorino', 71.0, 3.0, 1.6, 0, 7.5, 5.2, 1.2, 2.8, 1.5),
    ('King''s Crown', 'Passata', 36.0, 0.5, 0.1, 0, 6.5, 4.5, 0, 1.6, 1.1),
    ('Oro Di Parma', 'Pizzasauce Oregano', 50.0, 0.5, 0.1, 0, 7.6, 7.5, 2.7, 2.1, 1.3),
    ('InnFood Organic', 'Bio-Tomatensauce - Basilikum', 60.0, 2.6, 0.1, 0, 6.6, 5.3, 1.1, 1.9, 0.8),
    ('DmBio', 'Tomatensauce - gegrillte Paprika', 48.0, 2.3, 0.5, 0, 5.0, 3.4, 1.2, 1.3, 1.2),
    ('InnFood Organic', 'Bio-Tomatensauce - Arrabiata', 58.0, 2.3, 0.1, 0, 6.9, 5.5, 1.2, 1.9, 0.8),
    ('Clama', 'Tomate Frito', 68.0, 3.7, 0.4, 0, 6.4, 4.3, 0, 1.3, 0.8),
    ('Cucina', 'Pasta-Sauce Arrabbiata', 60.0, 3.1, 0.4, 0, 6.0, 4.7, 1.1, 1.4, 0.9),
    ('Mars', 'Pastasauce Miracoli Klassiker', 40.0, 0.5, 0.1, 0, 7.3, 4.9, 1.5, 1.7, 1.1),
    ('Alnatura', 'Passata', 20.0, 0.5, 0.1, 0, 3.3, 3.3, 0.9, 1.2, 0.3),
    ('Oro', 'Pastasauce Classico', 44.0, 1.7, 0.5, 0, 4.7, 4.6, 0, 1.4, 1.0),
    ('Cucina', 'Pasta-Sauce - Napoletana', 73.0, 4.2, 0.6, 0, 6.7, 4.7, 1.4, 1.5, 1.0),
    ('REWE Bio', 'Tomatensauce Kräuter', 68.0, 3.5, 0.6, 0, 6.5, 5.5, 0, 1.5, 0.9),
    ('Allos', 'Olivers Olive Tomate', 214.0, 17.0, 2.1, 0, 10.0, 6.8, 2.8, 3.9, 1.4),
    ('Barilla', 'Toscana Kräuter', 68.0, 4.0, 0.3, 0, 5.9, 5.0, 1.5, 1.4, 1.0),
    ('Kaufland Bio', 'Tomatensauce Classic', 66.0, 2.6, 0.2, 0, 8.4, 6.2, 0.8, 1.8, 1.0),
    ('Knorr', 'Tomaten passiert', 39.0, 0.8, 0.1, 0, 6.1, 4.8, 1.0, 1.2, 1.2),
    ('Alnatura', 'Tomatensauce Kräuter', 50.0, 2.1, 0.3, 0, 5.7, 4.4, 1.1, 1.6, 0.8),
    ('Nestlé', 'Tomaten Sauce', 64.0, 2.8, 1.6, 0, 7.4, 3.4, 0, 1.4, 1.4),
    ('REWE Beste Wahl', 'Stückige Tomaten', 22.0, 0.3, 0.0, 0, 3.0, 3.0, 0, 1.2, 0.1),
    ('Rewe', 'Kräuter Knoblauch Saucenbasis', 42.0, 0.9, 0.1, 0, 6.1, 4.5, 1.3, 1.6, 0.7),
    ('Alnatura', 'Tomatensauce Gegrilltes Gemüse 350M', 57.0, 2.4, 0.4, 0, 6.2, 5.6, 1.9, 1.9, 1.1),
    ('Ppura', 'Kinder Tomatensoße', 67.0, 3.5, 1.4, 0, 5.3, 4.9, 2.0, 1.5, 1.0),
    ('Ppura', 'Kinder Tomatensoße mit verstecktem Gemüse', 45.0, 1.8, 0.3, 0, 5.1, 4.6, 2.1, 1.1, 0.9),
    ('Barilla', 'Basilico 400g eu', 64.0, 2.6, 0.3, 0, 7.6, 5.9, 1.9, 1.6, 0.9),
    ('Baresa', 'Tomatenmark', 111.0, 0.7, 0.1, 0, 17.8, 17.8, 2.6, 5.5, 0.8),
    ('Baresa', 'Passierte Tomate', 35.0, 0.3, 0.0, 0, 4.9, 4.0, 1.1, 1.7, 0.6),
    ('Gut & Günstig', 'Passierte Tomaten', 32.0, 0.2, 0.0, 0, 4.8, 4.1, 0, 1.5, 0.0),
    ('Mutti', 'Triplo concentrato di pomodoro', 127.0, 0.2, 0.1, 0.0, 23.0, 16.0, 0.0, 5.7, 0.5),
    ('Barilla', 'Arrabbiata', 60.0, 3.1, 0.3, 0, 5.5, 5.0, 2.2, 1.4, 1.0),
    ('EDEKA Bio', 'Passata, passierte Tomaten - Bio', 31.0, 0.1, 0.0, 0, 4.9, 4.2, 0.0, 1.3, 0.0),
    ('Ppura', 'Vegane Bolognese', 76.0, 2.8, 0.4, 0, 10.0, 5.3, 2.2, 3.4, 1.2),
    ('Barilla', 'Napoletana', 67.0, 3.7, 0.4, 0, 6.2, 5.2, 1.8, 1.4, 1.0),
    ('Barilla', 'Ricotta', 87.0, 5.0, 1.7, 0, 6.3, 4.8, 2.0, 3.3, 1.0),
    ('Combino', 'Bolognese', 82.0, 4.3, 1.8, 0, 6.3, 4.6, 1.4, 3.9, 0.8),
    ('Baresa', 'Passierte Tomaten', 41.0, 0.2, 0.1, 0, 6.6, 4.4, 1.3, 2.1, 0.0),
    ('Ja!', 'Tomatensauce mit Basilikum', 29.0, 0.4, 0, 0, 5.0, 5.0, 0.8, 1.7, 1.0),
    ('Mutti', 'Pizzasauce Aromatica', 36.0, 0.5, 0.1, 0, 5.4, 4.2, 0, 1.6, 0.7),
    ('Combino', 'Arrabbiata', 49.0, 2.1, 0.3, 0, 5.4, 4.8, 1.6, 1.3, 0.8),
    ('REWE Bio', 'Passata Tomaten', 24.4, 0.1, 0.0, 0, 3.4, 3.4, 0, 1.5, 0.0),
    ('Barilla', 'Verdure mediterranee 400g eu cross', 74.0, 4.2, 0.5, 0, 6.6, 4.8, 2.1, 1.5, 0.8),
    ('REWE Bio', 'Tomatensauce Ricotta', 56.0, 3.1, 1.0, 0, 3.4, 3.2, 1.2, 2.2, 1.5),
    ('Alnatura', 'Tomatensauce Toscana', 30.0, 0.2, 0.1, 0, 5.4, 4.0, 1.7, 1.3, 1.1),
    ('Rewe', 'Tomate Ricotta mit Basilikum', 78.0, 3.7, 1.3, 0, 7.8, 5.9, 1.1, 2.8, 1.6)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Sauces' and p.is_deprecated is not true
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

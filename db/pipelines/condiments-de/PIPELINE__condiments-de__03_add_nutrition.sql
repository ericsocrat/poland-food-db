-- PIPELINE (Condiments): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Condiments'
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
    ('Hela', 'Gewürzketchup Curry', 134.0, 0.3, 0.0, 0, 31.1, 28.8, 0, 0.7, 2.0),
    ('Aldi', 'Curry-Gewürzketchup - delikat', 166.0, 0.5, 0.1, 0, 39.0, 34.0, 0, 0.6, 2.3),
    ('Werder', 'Gewürz Ketchup', 88.0, 0.1, 0.1, 0, 19.0, 16.0, 0, 1.5, 1.8),
    ('Delikato', 'Curry-Gewürzketchup - scharf', 168.0, 0.5, 0.1, 0, 39.0, 34.0, 0, 0.6, 2.3),
    ('American', 'Würzsauce 2 in 1 - Ketchup & Senf', 114.0, 1.7, 0.2, 0, 20.0, 17.0, 0, 2.8, 1.4),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 137.0, 0.3, 0.1, 0, 30.8, 29.4, 0, 0.8, 2.2),
    ('Hela', 'Gewürz Ketchup Curry', 134.0, 0.3, 0, 0, 31.3, 28.8, 0, 0.7, 2.0),
    ('Hela', 'Gewürz Ketchup Curry Delikat 30%', 104.0, 0.3, 0.0, 0, 23.8, 20.9, 0, 0.8, 2.2),
    ('Hela', 'Soße Curry Ketchup', 104.0, 0.3, 0.0, 0, 23.8, 20.9, 0, 0.8, 5.5),
    ('Develey', 'VW Ketchup Gewürz', 152.0, 0.2, 0.1, 0, 36.0, 29.0, 0.0, 1.2, 1.9),
    ('Hela', 'Gewürz Ketchup Curry Leicht Scharf', 135.0, 0.3, 0.0, 0, 31.5, 29.0, 0, 0.8, 2.0),
    ('Hela', 'Gewürzketchup Tomate', 127.0, 0.1, 0.0, 0, 30.2, 27.6, 0, 0.5, 1.7),
    ('Hela', 'Hela Schaschlik Gewürz- Ketchup', 138.0, 0.3, 0.1, 0, 32.1, 29.2, 0, 0.7, 2.3),
    ('Hela', 'Gewürz Ketchup Curry Extra Scharf', 136.0, 0.3, 0.1, 0, 31.5, 29.0, 0, 0.8, 2.0),
    ('Delikato', 'Tomatenketchup', 94.0, 0.5, 0.1, 0, 18.9, 17.8, 1.0, 19.0, 1.6),
    ('Kania', 'Ketchup', 97.0, 0.4, 0, 0, 19.8, 18.0, 1.6, 1.7, 1.8),
    ('DmBio', 'Jemný kečup', 78.0, 0.4, 0.1, 0, 16.0, 12.0, 1.5, 2.2, 1.4),
    ('Kania', 'Tomato Ketchup', 38.0, 0.1, 0.0, 0, 6.7, 4.5, 1.5, 1.7, 0.0),
    ('Werder', 'Tomatenketchup von Werder', 92.0, 0.2, 0.1, 0, 20.0, 17.0, 0, 1.6, 2.0),
    ('Jütro', 'Tomaten Ketchup', 99.0, 0.5, 0.1, 0, 20.3, 18.4, 0, 1.8, 1.8),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Klassik', 75.0, 0.2, 0.1, 0, 14.0, 12.0, 0, 2.5, 1.3),
    ('Delikato', 'Tomatenketchup Light', 62.0, 0.1, 0.0, 0, 11.4, 10.2, 0, 1.6, 1.0),
    ('Kania', 'Kečup', 110.0, 0.5, 0.1, 0, 23.5, 18.0, 0, 1.7, 2.6),
    ('La Vialla', 'Premium Tomatenketchup', 95.0, 0.2, 0.1, 0, 20.0, 18.0, 0, 2.1, 1.8),
    ('Werder', 'Barbecue Sauce', 94.0, 0.1, 0.1, 0, 21.0, 18.0, 0, 1.4, 2.0),
    ('Bio Zentrale', 'Tomaten Ketchup', 108.0, 0.1, 0.1, 0, 23.0, 23.0, 0, 1.2, 2.8),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Curry', 77.0, 0.4, 0.1, 0, 14.0, 12.0, 0, 2.6, 1.3),
    ('Gourmet Finest Cuisine', 'Steakhouse-Ketchup mit Fleur de Sel', 120.0, 0.2, 0.1, 0, 25.4, 23.0, 1.9, 1.8, 2.1),
    ('Hela', 'Curry Ketchup', 135.0, 0.3, 0.1, 0, 30.6, 29.2, 0, 0.8, 2.2),
    ('Dennree', 'Gewürz Ketchup', 129.0, 0.3, 0.1, 0, 29.6, 24.4, 0, 0.9, 2.8),
    ('Develey', 'Ketchup - Tomaten Ketchup', 103.0, 0.2, 0.1, 0, 21.5, 17.1, 0, 1.9, 2.2),
    ('Werder', 'Tomatenketchup ohne Zuckerzusatz', 42.0, 0.1, 0.1, 0, 8.5, 5.1, 0, 0.8, 2.0),
    ('Bautz''ner', 'Ketchup', 143.0, 0.1, 0.1, 0, 32.6, 24.6, 0.0, 1.4, 2.4),
    ('Hela', 'Tomaten-Ketchup', 62.0, 0.4, 0.1, 0, 10.9, 5.3, 0.0, 2.0, 1.4),
    ('Werder', 'Tomaten Ketchup', 92.0, 0.2, 0.1, 0, 20.0, 17.0, 0, 1.6, 2.0),
    ('K-Bio', 'Tomatenketchup', 87.0, 0.5, 0.1, 0, 18.0, 16.0, 0, 1.6, 1.2),
    ('Delikato', 'Tomatenketchup Hot Chili', 97.0, 0.2, 0.0, 0, 19.7, 18.4, 0, 1.7, 1.8),
    ('Byodo', 'Kinder ketchup', 82.0, 0.5, 0.1, 0, 16.0, 16.0, 0, 2.2, 1.4),
    ('K-Classic', 'Tomatenketchup', 95.0, 0.5, 0.1, 0, 19.0, 17.0, 0.8, 1.6, 1.8),
    ('Curry36', 'Tomatenketchup', 84.0, 0.5, 0.1, 0, 18.0, 13.0, 0, 2.4, 0.9),
    ('Tomatenketchup', 'Tomatenketchup Original Bio', 86.0, 0.0, 0.0, 0, 19.8, 17.2, 0, 0.0, 0.0),
    ('Born', 'Tomatenketchup', 94.0, 0.2, 0.1, 0, 20.2, 14.8, 0, 1.7, 1.6),
    ('Kaufland Classic', 'Ketchup', 98.0, 0.5, 0.1, 0, 20.0, 18.0, 1.0, 1.8, 1.8),
    ('Born', 'Tomaten Ketchup', 94.0, 0.2, 0.1, 0, 20.1, 14.7, 0, 1.7, 1.5),
    ('Bio-Zentrale', 'Biokids Tomatenketchup', 85.0, 0.5, 0.1, 0, 18.0, 15.0, 0, 1.8, 1.8),
    ('Hela', 'Ketchup', 103.0, 0.4, 0.1, 0, 21.7, 16.5, 0, 1.7, 1.4),
    ('Zwergenwiese', 'Tomatensauce', 109.0, 5.5, 0.5, 0, 11.0, 9.6, 2.4, 2.5, 1.0),
    ('Develey', 'Ketchup develey', 134.0, 0.2, 0.1, 0, 29.8, 27.1, 0, 1.6, 2.3),
    ('K-Classic', 'Curry Gewürz Ketchup scharf', 169.0, 0.5, 0.1, 0, 40.0, 34.0, 0.8, 0.6, 0.0),
    ('Werder', 'Kinder Bio Ketchup', 94.0, 0.3, 0.1, 0, 20.0, 17.0, 0, 2.6, 1.3),
    ('Dennree', 'Ketchup', 102.0, 0.7, 0.2, 0, 20.0, 20.0, 0, 2.0, 2.4)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Condiments' and p.is_deprecated is not true
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

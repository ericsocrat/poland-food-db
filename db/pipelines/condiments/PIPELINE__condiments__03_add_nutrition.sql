-- PIPELINE (Condiments): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Condiments'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Kotlin', 'Ketchup Łagodny', '97.0', '0.5', '0.1', '0', '21.0', '18.0', '0', '1.4', '2.0'),
    ('Heinz', 'Ketchup łagodny', '102.0', '0.1', '0.1', '0', '23.2', '22.8', '0', '1.2', '1.8'),
    ('Go Vege', 'Majonez sałatkowy wegański', '312.0', '30.0', '0', '0', '9.2', '0', '0', '0.0', '0'),
    ('Pudliszki', 'Ketchup łagodny', '116.0', '0.0', '0.0', '0', '27.0', '20.0', '1.0', '1.6', '2.6'),
    ('Kotlin', 'Ketchup łagodny', '45.0', '0.5', '0.1', '0', '8.2', '8.2', '0', '1.4', '2.0'),
    ('Winiary', 'Majonez Dekoracyjny', '704.0', '76.3', '5.3', '0', '2.9', '2.3', '0', '1.5', '0.6'),
    ('Kamis', 'Musztarda sarepska ostra', '101.0', '5.1', '0.3', '0', '8.3', '6.9', '0', '3.7', '2.5'),
    ('Winiary', 'Mayonnaise Decorative', '704.0', '76.3', '5.3', '0', '2.9', '2.3', '0', '1.5', '0.6'),
    ('Kotlin', 'Ketchup hot', '97.0', '0.5', '0.1', '0', '21.0', '18.0', '0', '1.3', '2.2'),
    ('Społem Kielce', 'Majonez Kielecki', '631.0', '68.0', '5.3', '0', '2.3', '2.0', '0', '1.9', '1.0'),
    ('Roleski', 'Moutarde Dijon', '174.0', '11.0', '0.5', '0', '8.4', '4.6', '0', '7.7', '6.1'),
    ('Krakus', 'Chrzan', '157.0', '9.8', '0.7', '0', '12.0', '9.5', '0', '2.7', '1.4'),
    ('Madero', 'Majonez', '702.0', '76.0', '5.7', '0', '3.7', '3.7', '0', '0.9', '0.1'),
    ('Nestlé', 'Przyprawa Maggi', '20.0', '0.0', '0.0', '0', '2.2', '0.9', '0.0', '2.8', '22.8'),
    ('Heinz', 'Heinz Zero Sel Ajoute', '44.0', '0.1', '0.0', '0', '5.4', '4.4', '0', '1.6', '0.1'),
    ('Kielecki', 'Mayonnaise Kielecki', '631.0', '68.0', '5.3', '0', '2.2', '1.9', '0', '1.9', '1.0'),
    ('Pudliszki', 'ketchup pikantny', '144.0', '0.1', '0.0', '0', '34.0', '29.0', '1.1', '1.1', '3.3'),
    ('Pudliszki', 'Ketchup pikantny', '107.0', '0.0', '0.0', '0', '25.3', '22.0', '1.3', '2.0', '3.3'),
    ('Prymat', 'Musztarda sarepska ostra', '117.0', '6.3', '0.2', '0', '8.8', '5.7', '0', '4.9', '2.2'),
    ('Kamis', 'Musztarda delikatesowa', '100.0', '4.4', '0.3', '0', '10.0', '8.7', '0', '3.3', '2.5'),
    ('Pudliszki', 'Ketchup Lagodny', '116.0', '0.0', '0.0', '0', '27.0', '20.0', '1.0', '1.6', '2.6'),
    ('Madero', 'Sos czosnkowy', '408.0', '41.0', '3.1', '0', '8.1', '6.5', '0', '1.0', '1.5'),
    ('Barilla', 'Pesto alla Genovese', '492.0', '47.0', '5.3', '0', '11.0', '5.0', '3.0', '4.7', '3.2'),
    ('Heinz', 'Tomato Ketchup', '102.0', '0.1', '0.0', '0', '23.2', '22.8', '0', '1.2', '1.8'),
    ('Kikkoman', 'Kikkoman Sojasauce', '77.0', '0.0', '0.0', '0', '3.2', '0.6', '0.0', '10.0', '16.9'),
    ('Kikkoman', 'Teriyakisauce', '99.0', '0.0', '0.0', '0', '12.0', '11.0', '0', '6.7', '10.2'),
    ('Italiamo', 'Sugo al pomodoro con basilico', '36.0', '0.1', '0.0', '0', '6.4', '5.7', '0', '1.7', '0.5'),
    ('Heinz', 'Heinz Mayonesa', '633.4', '70.0', '5.3', '0', '30.0', '1.5', '0.0', '0.8', '1.0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Condiments' and p.is_deprecated is not true
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;

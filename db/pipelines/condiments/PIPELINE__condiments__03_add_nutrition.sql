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
    ('Pudliszki', 'Ketchup łagodny - Najsmaczniejszy', '113.3', '0.0', '0.0', '0.0', '30.0', '20.0', '2.7', '2.7', '0.0'),
    ('Roleski', 'Ketchup łagodny markowy', '107.0', '0.5', '0.1', '0', '24.0', '23.0', '0', '1.7', '2.3'),
    ('Pudliszki', 'Ketchup Łagodny Premium', '113.0', '0.1', '0.1', '0', '26.0', '22.0', '1.0', '1.5', '2.4'),
    ('Kamis', 'Ketchup włoski', '91.0', '0.0', '0.0', '0', '20.0', '18.0', '0', '1.4', '2.5'),
    ('Pudliszki', 'Ketchup łagodny', '116.0', '0.0', '0.0', '0', '27.0', '20.0', '1.0', '1.6', '2.6'),
    ('Kotlin', 'Ketchup łagodny', '45.0', '0.5', '0.1', '0', '8.2', '8.2', '0', '1.4', '2.0'),
    ('Roleski', 'Ketchup Premium Łagodny', '46.0', '0.5', '0.1', '0', '7.2', '5.3', '0', '2.2', '1.5'),
    ('Madero', 'Ketchup Łagodny', '98.0', '0.5', '0.1', '0', '20.0', '19.0', '2.8', '2.1', '2.1'),
    ('Roleski', 'Musztarda Stołowa', '127.0', '4.6', '0.2', '0', '16.0', '12.0', '0', '4.0', '2.0'),
    ('Kotlin', 'Ketchup hot', '97.0', '0.5', '0.1', '0', '21.0', '18.0', '0', '1.3', '2.2'),
    ('Madero', 'Ketchup junior', '103.0', '0.5', '0.1', '0', '22.0', '19.0', '0', '1.7', '2.3'),
    ('Madero', 'Ketchup pikantny', '131.0', '0.5', '0.2', '0', '31.0', '30.0', '1.3', '1.1', '2.7'),
    ('Roleski', 'Ketchup Premium', '123.0', '0.4', '0.1', '0', '27.0', '25.0', '0', '1.9', '2.3'),
    ('Roleski', 'Ketchup premium Pikantny', '123.0', '0.5', '0.1', '0', '27.0', '25.0', '0', '1.9', '2.3'),
    ('Madero', 'Premium ketchup pikantny', '113.0', '0.2', '0.1', '0', '23.7', '20.7', '1.9', '1.9', '1.9'),
    ('Kamis', 'Musztarda sarepska ostra', '101.0', '5.1', '0.3', '0', '8.3', '6.9', '0', '3.7', '2.5'),
    ('Firma Roleski', 'Mutarde', '195.0', '4.4', '0.2', '0', '32.0', '31.0', '0.0', '4.6', '1.6'),
    ('Spolem', 'Spo?e Musztarda Delikatesowa 190Ml', '117.0', '4.2', '0.4', '0', '12.0', '9.6', '0', '5.0', '1.7'),
    ('Unknown', 'Musztarda stołowa', '110.0', '5.0', '1.0', '0', '7.0', '7.0', '4.0', '5.0', '5.8'),
    ('Heinz', 'Heinz Zero Sel Ajoute', '44.0', '0.1', '0.0', '0', '5.4', '4.4', '0', '1.6', '0.1'),
    ('Pudliszki', 'ketchup pikantny', '144.0', '0.1', '0.0', '0', '34.0', '29.0', '1.1', '1.1', '3.3'),
    ('Pudliszki', 'Ketchup pikantny', '107.0', '0.0', '0.0', '0', '25.3', '22.0', '1.3', '2.0', '3.3'),
    ('Pudliszki', 'Ketchup Lagodny', '116.0', '0.0', '0.0', '0', '27.0', '20.0', '1.0', '1.6', '2.6'),
    ('Roleski', 'Ketchup premium sycylijski KETO do pizzy', '41.0', '0.5', '0.1', '0', '6.2', '4.5', '0', '2.0', '2.3'),
    ('Heinz', 'Ketchup pikantny', '23.7', '0.0', '0', '0', '5.6', '5.1', '0', '0.3', '0'),
    ('Wloclawek', 'Wloclawek Mild Tomato Ketchup', '106.0', '0.5', '0.1', '0', '23.0', '23.0', '0', '1.7', '1.6')
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

-- PIPELINE (Breakfast & Grain-Based): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Breakfast & Grain-Based'
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
    ('Vitanella', 'Granola - Musli Prażone (Czekoladowe)', '457.0', '17.3', '3.6', '0', '63.0', '24.0', '6.5', '8.7', '0.2'),
    ('Bakalland', 'Ba! Granola Z Żurawiną', '385.0', '9.2', '1.3', '0', '64.0', '27.0', '7.2', '7.9', '0.1'),
    ('Go on', 'Granola proteinowa brownie & cherry', '408.0', '13.0', '2.4', '0', '46.0', '2.7', '18.0', '21.0', '0.4'),
    ('Bakalland', 'Ba! Granola 5 bakalii', '379.0', '9.0', '1.2', '0', '63.0', '28.0', '7.1', '7.9', '0'),
    ('Unknown', 'Étcsokis granola málnával', '410.0', '8.4', '2.2', '0', '65.2', '10.1', '10.2', '12.5', '0'),
    ('All nutrition', 'F**king delicious Granola', '482.0', '22.0', '2.9', '0', '52.0', '21.0', '8.0', '15.0', '0'),
    ('Unknown', 'Gyümölcsös granola', '395.0', '8.4', '1.3', '0', '62.9', '15.4', '10.3', '11.3', '0'),
    ('All  nutrition', 'F**king delicious granola fruity', '448.0', '16.0', '1.8', '0', '58.0', '22.0', '8.1', '14.0', '0'),
    ('Unknown', 'Granola with Fruits', '458.0', '26.0', '6.0', '0', '44.0', '22.0', '0', '16.0', '0'),
    ('One Day More', 'Winter Granola', '404.0', '8.4', '1.0', '0', '67.8', '17.8', '7.0', '10.2', '0.2'),
    ('One Day More', 'Protein Granola Caramel Nuts & Chocolate', '438.0', '17.2', '3.0', '0', '52.5', '16.3', '7.5', '22.1', '0.4'),
    ('Sante', 'Granola o smaku rumu', '462.0', '16.0', '2.5', '0', '68.0', '22.0', '5.8', '8.6', '0.2'),
    ('Vitanella', 'Granola Z Ciasteczkami', '433.0', '13.3', '3.9', '0', '64.4', '20.6', '7.9', '9.9', '0.4'),
    ('Vitanella', 'Cherry granola', '408.0', '10.7', '2.4', '0', '63.7', '19.4', '0', '8.1', '0.3')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Breakfast & Grain-Based' and p.is_deprecated is not true
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

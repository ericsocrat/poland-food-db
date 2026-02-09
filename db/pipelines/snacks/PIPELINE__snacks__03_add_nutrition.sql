-- PIPELINE (Snacks): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Snacks'
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
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', '422.0', '13.0', '8.1', '0', '72.0', '36.0', '2.6', '3.7', '0.3'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', '416.0', '17.0', '9.2', '0', '44.0', '29.0', '9.4', '20.0', '0.0'),
    ('Sante', 'Vitamin coconut bar', '481.0', '27.0', '21.0', '0', '55.0', '39.0', '6.8', '3.5', '0.3'),
    ('nakd', 'Blueberry Muffin Myrtilles', '374.0', '11.1', '1.7', '0', '57.1', '48.6', '9.4', '6.6', '0.0'),
    ('Carrefour', 'Toast crock'' céréales complètes', '359.0', '3.1', '0.7', '0', '67.0', '3.6', '13.0', '9.9', '1.3'),
    ('Milka', 'Cake & Chock', '428.0', '21.0', '4.1', '0', '56.0', '30.0', '1.4', '5.5', '0.6'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', '453.0', '14.0', '1.2', '0', '71.0', '5.5', '3.3', '9.1', '2.5')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Snacks' and p.is_deprecated is not true
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

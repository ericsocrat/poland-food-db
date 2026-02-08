-- PIPELINE (Alcohol): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Alcohol'
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
    ('Harnaś', 'Harnaś jasne pełne', '43.0', '0.0', '0.0', '0', '0.0', '0.0', '0', '0.0', '0.0'),
    ('Karmi', 'Karmi o smaku żurawina', '42.0', '0.0', '0.0', '0', '9.8', '8.9', '0.0', '0.3', '0.0'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', '40.0', '0.0', '0.0', '0', '3.3', '0.2', '0', '0.2', '0.0'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', '43.0', '0.0', '0.0', '0', '3.0', '0.2', '0', '0.5', '0.0'),
    ('Lomża', 'Łomża jasne', '43.0', '0.0', '0', '0', '3.6', '0', '0', '0.4', '0'),
    ('Lech', 'Lech Premium', '41.0', '0.1', '0.1', '0', '2.8', '0.8', '0', '0.6', '0.1'),
    ('Łomża', 'Bière sans alcool', '32.0', '0.0', '0.0', '0', '7.5', '2.8', '0.0', '0.5', '0.0'),
    ('Carlsberg', 'Pilsner 0.0%', '15.0', '0.0', '0', '0', '3.2', '0', '0', '0.0', '0.0'),
    ('Lech', 'Lech Free Lime Mint', '28.0', '0.0', '0', '0', '7.8', '5.8', '0', '0.0', '0'),
    ('Christkindl', 'Christkindl Glühwein', '82.0', '0.5', '0.1', '0', '9.0', '8.5', '0.0', '0.5', '0.0'),
    ('Heineken', 'Heineken Beer', '42.0', '0.0', '0.0', '0', '3.2', '0.0', '0', '0.0', '0.0'),
    ('Ikea', 'Glühwein', '77.0', '0.0', '0.0', '0', '19.0', '19.0', '0.0', '0.0', '0.0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

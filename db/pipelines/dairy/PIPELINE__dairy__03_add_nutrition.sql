-- PIPELINE (Dairy): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Dairy'
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
    ('Mlekpol', 'Łaciate 3,2%', 60.0, 3.2, 2.0, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Mleczna Dolina', 'Masło ekstra', 746.0, 82.0, 54.0, 0, 1.0, 1.0, 0, 1.0, 0.2),
    ('PIĄTNICA', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 115.0, 4.0, 2.4, 0, 3.8, 3.8, 0, 16.0, 0.1),
    ('Piatnica', 'Serek Wiejski wysokobiałkowy', 92.5, 3.0, 2.0, 0, 2.4, 2.0, 0, 14.0, 0.7),
    ('Łaciate', 'Łaciaty serek śmietankowy', 249.0, 23.0, 16.0, 0, 4.8, 3.7, 0, 5.8, 0.7),
    ('Piątnica', 'Twój Smak Serek śmietankowy', 243.0, 23.0, 15.0, 0, 3.0, 3.0, 0.0, 6.0, 0.7),
    ('Łaciate', 'Masło extra Łaciate', 753.0, 83.0, 54.0, 0, 0.8, 0.8, 0, 0.6, 0.0),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 66.0, 0.0, 0, 0, 3.8, 3.8, 0, 12.0, 0.1),
    ('Piątnica', 'Śmietana 18%', 191.0, 18.0, 11.0, 0, 4.8, 3.6, 0.0, 2.5, 0.1),
    ('Sierpc', 'Ser królewski', 352.0, 27.0, 18.0, 0, 1.2, 0.0, 0, 26.0, 1.4),
    ('Almette', 'Serek Almette z ziołami', 238.0, 22.0, 15.0, 0, 3.1, 3.0, 0, 7.0, 0.6),
    ('Piątnica', 'Mleko wieskie świeże 2%', 50.0, 2.0, 1.3, 0, 4.8, 4.8, 0, 3.2, 0.1),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 50.0, 2.0, 1.3, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('PIĄTNICA', 'SEREK WIEJSKI', 97.0, 5.0, 3.5, 0, 2.0, 1.5, 0, 11.0, 0.7),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 60.0, 3.2, 2.1, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 78.0, 1.5, 1.1, 0, 9.5, 9.0, 0, 6.5, 0.1),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 82.0, 0.0, 0.0, 0, 11.0, 11.0, 0, 9.6, 0.1),
    ('Favita', 'Favita', 230.0, 18.0, 11.0, 0, 4.0, 4.0, 0, 10.0, 3.0),
    ('Mleczna Dolina', 'mleko UHT 3,2%', 60.0, 3.2, 2.0, 0, 4.8, 4.8, 0, 3.0, 0.1),
    ('MLEKOVITA', 'Butter', 746.0, 82.0, 54.0, 0, 1.0, 1.0, 0, 1.0, 0.0),
    ('Almette', 'Hochland Almette Soft Cheese 150G', 256.0, 24.0, 17.0, 0, 3.2, 3.2, 0, 6.7, 0.6),
    ('Piątnica', 'Serek homogenizowany waniliowy', 138.0, 6.3, 4.4, 0, 13.0, 13.0, 0, 7.2, 0.1),
    ('Piątnica', 'Skyr jogurt pitny Naturalny', 64.0, 1.8, 1.3, 0, 4.3, 3.9, 0, 7.6, 0.1),
    ('Mlekovita', 'hleko', 60.0, 3.2, 2.0, 0, 4.7, 4.7, 0, 3.2, 0.1),
    ('Pilos', 'Mleko zagęszczone 7,5%', 132.0, 7.5, 5.3, 0, 10.2, 10.2, 0, 6.0, 0.3),
    ('Piątnica', 'Skyr jogurt pitny', 80.0, 1.5, 1.1, 0, 10.0, 10.0, 0, 6.5, 0.1),
    ('Piątnica', 'Skyr - jogurt typu islandzkiego z truskawkami', 78.0, 0.0, 0.0, 0, 10.0, 10.0, 0.0, 9.6, 0.1),
    ('Fruvita', 'Jogurt Grecki', 124.0, 10.0, 6.5, 0, 5.0, 5.0, 0, 3.6, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

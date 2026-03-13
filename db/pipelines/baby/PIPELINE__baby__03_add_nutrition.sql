-- PIPELINE (Baby): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Baby'
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
    ('Diamant', 'Cukier Biały', 400.0, 0.0, 0.0, 0, 100.0, 100.0, 0.0, 0.0, 0.0),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 51.0, 0.5, 0.1, 0, 13.0, 11.0, 1.3, 0.5, 0.0),
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 428.0, 12.0, 2.7, 0, 61.0, 31.0, 5.9, 16.0, 0.3),
    ('Piątnica', 'Koktajl z białkiem serwatkowym', 88.0, 1.2, 0.7, 0, 9.0, 9.0, 0, 10.2, 0.1),
    ('Hipp', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 80.0, 3.1, 0.6, 0, 10.1, 3.0, 0, 0.1, 0.0),
    ('Nestle Gerber', 'Owoce jabłka z truskawkami i jagodami', 51.1, 0.1, 0.0, 0, 11.6, 6.9, 1.1, 0.3, 0.0),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 70.0, 2.4, 0.7, 0, 9.0, 2.3, 1.5, 2.4, 0.2),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 42.0, 0.2, 0, 0, 8.7, 8.3, 2.0, 0.4, 0),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 78.0, 3.0, 1.4, 0, 10.7, 4.8, 0.4, 1.9, 0.1),
    ('Nestlé', 'Nestle Sinlac', 431.0, 11.5, 0.9, 0, 64.6, 4.5, 3.8, 15.3, 0.1),
    ('Hipp', 'Dynia z indykiem', 59.0, 2.5, 0.4, 0, 5.7, 2.9, 0, 2.9, 0.1),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 63.0, 0.5, 0.1, 0, 13.0, 12.0, 0, 0.6, 0.0)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Baby' and p.is_deprecated is not true
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

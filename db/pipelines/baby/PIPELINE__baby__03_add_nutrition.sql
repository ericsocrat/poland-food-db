-- PIPELINE (Baby): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Baby'
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
    ('BoboVita', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 428.0, 12.0, 2.7, 0, 61.0, 31.0, 5.9, 16.0, 0.3),
    ('Nutricia', 'Kaszka zbożowa jabłko, śliwka.', 369.0, 2.1, 0.0, 0, 73.0, 18.0, 11.0, 9.4, 0.0),
    ('Bobovita', 'Pomidorowa z kurczakiem i ryżem', 56.0, 1.8, 0.2, 0, 6.3, 2.8, 1.1, 3.1, 0.1),
    ('Bobovita', 'Kaszka ryżowa bobovita', 387.0, 1.0, 0.6, 0, 87.0, 9.4, 1.8, 6.9, 0.0),
    ('Bobovita', 'Kaszka zbożowa Jabłko Śliwka', 375.0, 2.2, 0.3, 0, 74.0, 19.0, 9.6, 9.6, 0),
    ('Bobovita', 'Kaszka Mleczna Ryżowa Kakao', 425.0, 11.0, 2.5, 0, 65.0, 30.0, 3.5, 15.0, 0),
    ('BoboVita', 'Kaszka Ryżowa Banan', 387.0, 1.0, 0.4, 0, 87.0, 9.4, 1.8, 6.9, 0),
    ('bobovita', 'kaszka mleczno-ryżowa straciatella', 443.0, 13.0, 0, 0, 68.0, 29.0, 1.2, 13.0, 0),
    ('Bobovita', 'Delikatne jabłka z bananem', 52.0, 0.1, 0.0, 0, 12.0, 8.4, 1.0, 0.4, 0.0),
    ('BoboVita', 'Kaszka Mleczna Ryżowa 3 Owoce', 428.0, 9.8, 2.4, 0, 71.0, 31.0, 1.0, 13.0, 0.3),
    ('Hipp', 'Kaszka mleczna z biszkoptami i jabłkami', 78.0, 3.0, 1.4, 0, 10.7, 4.8, 0.4, 1.9, 0.1),
    ('Bobovita', 'Kaszka manna', 680.0, 11.5, 2.5, 0, 65.0, 30.0, 27.5, 16.0, 0),
    ('BoboVita', 'BoboVita Jabłka z marchewka', 42.0, 0.2, 0, 0, 8.7, 8.3, 2.0, 0.4, 0),
    ('Nestlé', 'Bobovita', 416.0, 9.0, 3.9, 0, 71.0, 34.0, 0.9, 12.0, 0),
    ('Bobovita', 'Kaszka Ryzowa Malina', 388.0, 1.0, 0.4, 0, 87.0, 8.4, 1.7, 7.0, 0),
    ('Bobovita', 'Kasza Manna', 432.0, 12.0, 2.6, 0, 64.0, 27.0, 2.3, 17.0, 0),
    ('Nestle Gerber', 'owoce jabłka z truskawkami i jagodami', 51.1, 0.1, 0.0, 0, 11.6, 6.9, 1.1, 0.3, 0.0),
    ('Nestlé', 'Leczo z mozzarellą i kluseczkami', 70.0, 2.4, 0.7, 0, 9.0, 2.3, 1.5, 2.4, 0.2),
    ('Gerber organic', 'Krakersy z pomidorem po 12 miesiącu', 440.0, 12.0, 9.0, 0, 71.0, 8.0, 2.0, 11.0, 0.1),
    ('Gerber', 'Pełnia Zbóż Owsianka 5 Zbóż', 97.0, 2.6, 0.3, 0, 14.5, 6.5, 0.8, 3.6, 0.1),
    ('Gerber', 'Bukiet warzyw z łososiem w sosie pomidorowym', 44.0, 1.4, 0.2, 0, 5.0, 9.0, 1.4, 2.1, 0.1),
    ('dada baby food', 'bio mus kokos', 88.0, 2.8, 2.6, 0, 13.0, 11.0, 3.4, 1.0, 0.0),
    ('Gerber', 'Warzywa  z delikatnym indykiem w pomidorach', 55.0, 1.9, 0.3, 0, 6.1, 3.3, 1.7, 2.5, 0.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Baby' and p.is_deprecated is not true
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

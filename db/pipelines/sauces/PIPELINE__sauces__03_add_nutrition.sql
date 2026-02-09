-- PIPELINE (Sauces): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Sauces'
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
    ('Dawtona', 'Sos słodko-kwaśny z ananasem', '85.0', '0.5', '0.0', '0', '19.0', '16.0', '0.7', '0.7', '0.8'),
    ('Fanex', 'Sos meksykański', '88.0', '0.5', '0.1', '0', '20.0', '18.0', '0', '1.2', '1.3'),
    ('Łowicz', 'Sos Boloński', '42.0', '1.1', '0.1', '0', '6.5', '6.0', '0', '0.9', '0.0'),
    ('Sottile Gusto', 'Passata', '30.9', '0.5', '0.1', '0', '4.3', '4.2', '0', '1.7', '0.2'),
    ('Międzychód', 'Sos pomidorowy', '60.0', '0.9', '0.1', '0', '12.0', '8.5', '0', '1.3', '1.1'),
    ('ŁOWICZ', 'Sos Spaghetti', '81.0', '2.0', '0.2', '0', '14.0', '12.0', '0', '1.6', '1.1'),
    ('Dawtona', 'Passata rustica', '34.0', '0.2', '0.1', '0', '5.5', '3.8', '2.0', '1.3', '0.3'),
    ('Pudliszki', 'Sos Do Spaghetti Oryginalny', '59.0', '1.0', '0.1', '0', '9.0', '7.1', '0', '1.7', '1.0'),
    ('Łowicz', 'Sos Spaghetti', '81.0', '2.0', '0.2', '0', '14.0', '12.0', '0', '1.6', '0.9'),
    ('Italiamo', 'Sugo al pomodoro con basilico', '36.0', '0.1', '0.0', '0', '6.4', '5.7', '0', '1.7', '0.5'),
    ('Mutti', 'Sauce Tomate aux légumes grillés', '51.0', '2.3', '0.4', '0', '5.5', '4.7', '1.3', '1.3', '0.9'),
    ('Combino', 'Sauce tomate bio à la napolitaine', '51.0', '0.9', '0.2', '0', '8.4', '6.6', '0', '1.3', '1.6'),
    ('mondo italiano', 'passierte Tomaten', '29.0', '0.2', '0.0', '0', '4.6', '2.9', '0.0', '1.2', '0.0'),
    ('Mutti', 'Passierte Tomaten', '36.0', '0.5', '0.1', '0', '5.1', '4.5', '0', '1.6', '0.5'),
    ('Polli', 'Pesto alla calabrese poivrons et ricotta', '301.0', '27.0', '4.4', '0', '10.0', '5.9', '1.5', '3.8', '2.8'),
    ('gustobello', 'Passata', '28.0', '0.1', '0', '0', '4.1', '3.5', '1.8', '1.4', '0.0'),
    ('Baresa', 'Tomato Passata With Garlic', '39.0', '0.3', '0.0', '0', '5.8', '4.2', '0', '1.8', '0.0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Sauces' and p.is_deprecated is not true
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

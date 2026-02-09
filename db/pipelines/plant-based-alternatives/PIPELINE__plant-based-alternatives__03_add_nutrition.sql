-- PIPELINE (Plant-Based & Alternatives): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
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
    ('Sante', 'Masło orzechowe', '616.0', '50.0', '8.8', '0', '14.0', '9.0', '6.9', '24.0', '0.7'),
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', '900.0', '100.0', '7.5', '0', '0.0', '0.0', '0.0', '0.0', '0.0'),
    ('GO ON', 'Peanut Butter Smooth', '603.0', '48.0', '6.4', '0', '12.0', '6.7', '7.6', '27.0', '0.0'),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', '87.0', '0.2', '0.0', '0', '13.6', '4.7', '4.3', '5.4', '0.6'),
    ('Go On', 'Peanut Butter Crunchy', '603.0', '48.0', '6.4', '0', '12.0', '6.7', '7.6', '27.0', '0.0'),
    ('Lidl', 'Doce Extra Fresa Morango', '241.0', '0.3', '0.1', '0', '57.8', '57.7', '1.2', '0.0', '3.9'),
    ('Carrefour BIO', 'Huile d''olive vierge extra', '823.0', '91.0', '13.0', '0', '0.0', '0.0', '0', '0.0', '0.0'),
    ('Batts', 'Crispy Fried Onions', '590.0', '44.0', '21.0', '0', '40.0', '9.0', '5.0', '6.0', '1.2'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', '359.0', '2.0', '0.5', '0', '71.0', '3.5', '3.0', '13.0', '0.0'),
    ('ITALIAMO', 'Paradizniki suseni lidl', '138.0', '0.7', '0.2', '0.0', '20.0', '17.0', '6.0', '7.0', '6.6'),
    ('DONAU SOJA', 'Tofu smoked', '134.0', '8.0', '1.1', '0', '2.4', '0.5', '1.0', '13.0', '1.0'),
    ('Lidl Baresa', 'Aurinkokuivattuja tomaatteja', '131.0', '9.2', '1.1', '0', '7.2', '4.9', '5.0', '2.3', '2.2'),
    ('Vitasia', 'Rice Noodles', '358.0', '1.3', '0.2', '0', '78.0', '0.1', '1.8', '7.5', '0.1'),
    ('IKEA', 'Lingonberry jam, organic', '173.0', '0.0', '0.0', '0', '42.0', '39.0', '0', '0.0', '0.0'),
    ('ALDI Zespri', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', '79.0', '0.3', '0.0', '0.0', '15.8', '12.3', '1.4', '1.0', '0.0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Plant-Based & Alternatives' and p.is_deprecated is not true
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

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
    ('Kujawski', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 900.0, 100.0, 7.5, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('HEINZ', '5 rodzajów fasoli w sosie pomidorowym', 87.0, 0.2, 0.0, 0, 13.6, 4.7, 4.3, 5.4, 0.6),
    ('Carrefour BIO', 'Huile d''olive vierge extra', 823.0, 91.0, 13.0, 0, 0.0, 0.0, 0, 0.0, 0.0),
    ('Batts', 'Crispy Fried Onions', 590.0, 44.0, 21.0, 0, 40.0, 9.0, 5.0, 6.0, 1.2),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 359.0, 2.0, 0.5, 0, 71.0, 3.5, 3.0, 13.0, 0.0),
    ('DONAU SOJA', 'Tofu smoked', 134.0, 8.0, 1.1, 0, 2.4, 0.5, 1.0, 13.0, 1.0),
    ('Vitasia', 'Rice Noodles', 358.0, 1.3, 0.2, 0, 78.0, 0.1, 1.8, 7.5, 0.1),
    ('LIDL', 'ground chili peppers in olive oil', 332.0, 35.0, 6.0, 0, 2.5, 0.5, 3.4, 1.0, 2.8),
    ('Carrefour BIO', 'Galettes épeautre', 361.0, 1.9, 0.4, 0, 61.0, 0.8, 11.0, 20.0, 0.2),
    ('Baresa', 'Lasagnes', 350.0, 1.2, 0.3, 0, 70.5, 3.2, 3.5, 12.5, 0.1),
    ('Vemondo', 'Tofu naturalne', 125.0, 7.5, 1.0, 0, 2.3, 0.5, 0.1, 12.0, 0.2),
    ('Lidl', 'Avocados', 190.0, 19.5, 4.1, 0, 1.9, 0.5, 3.4, 1.9, 0.1),
    ('Vemondo', 'Tofu basil Bio', 129.0, 7.5, 1.0, 0, 1.8, 0.5, 1.0, 13.0, 1.0),
    ('Carrefour BIO', 'Galettes 4 Céréales', 384.0, 2.6, 0.7, 0, 80.0, 0.7, 4.2, 8.0, 0.2),
    ('Vita D''or', 'Rapsöl', 83.0, 9.2, 0.6, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ('Driscoll''s', 'Framboises', 52.0, 0.7, 0.0, 0, 11.9, 4.4, 6.5, 1.2, 0.0),
    ('Lidl', 'Kalamata olive paste', 250.0, 25.0, 0, 0, 6.2, 0, 0, 0.0, 21.5),
    ('Carrefour', 'Spaghetti', 355.0, 1.9, 0.3, 0, 70.0, 4.5, 3.0, 13.0, 0.0),
    ('ALDI Zespri', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', 79.0, 0.3, 0.0, 0.0, 15.8, 12.3, 1.4, 1.0, 0.0)
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

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
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 471.0, 19.0, 12.0, 0, 65.0, 24.0, 3.5, 8.2, 0.1),
    ('Sante A. Kowalski sp. j.', 'Crunchy Cranberry & Raspberry - Santé', 422.0, 13.0, 8.1, 0, 72.0, 36.0, 2.6, 3.7, 0.3),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 416.0, 17.0, 9.2, 0, 44.0, 29.0, 9.4, 20.0, 0.0),
    ('Sante', 'Vitamin coconut bar', 481.0, 27.0, 21.0, 0, 55.0, 39.0, 6.8, 3.5, 0.3),
    ('Go On Nutrition', 'Protein 33% Caramel', 390.0, 19.0, 9.4, 0, 21.0, 2.8, 14.0, 33.0, 0.9),
    ('Lajkonik', 'prezel', 409.0, 7.3, 0.7, 0, 72.0, 0.7, 3.1, 3.6, 0.0),
    ('Nestlé', 'Cocoa fitness bar', 330.0, 9.5, 2.0, 0, 41.0, 2.5, 26.5, 12.0, 0.5),
    ('nakd', 'Blueberry Muffin Myrtilles', 374.0, 11.1, 1.7, 0, 57.1, 48.6, 9.4, 6.6, 0.0),
    ('Carrefour', 'Toast crock'' céréales complètes', 359.0, 3.1, 0.7, 0, 67.0, 3.6, 13.0, 9.9, 1.3),
    ('7 DAYS', 'Croissant with Cocoa Filling', 453.0, 28.0, 14.0, 0, 43.0, 17.0, 1.9, 5.6, 1.5),
    ('Favorina', 'Coeurs pain d''épices chocolat noir', 362.0, 9.0, 5.4, 0, 63.3, 37.8, 3.8, 4.5, 0.3),
    ('Crownfield', 'Muesli Bars Chocolate & Banana', 448.0, 16.8, 7.2, 0, 65.6, 31.6, 4.0, 6.8, 0.3),
    ('Carrefour BIO', 'Tartines craquantes Au blé complet', 389.0, 1.8, 0.6, 0, 79.0, 4.3, 7.9, 10.0, 0.6),
    ('Carrefour', 'Barre patissière', 346.0, 11.0, 1.2, 0.0, 55.0, 29.0, 1.1, 4.8, 1.3),
    ('Chabrior', 'Barres de céréales aux noisettes x6 - 126g', 444.0, 16.9, 1.5, 0, 63.6, 19.5, 4.7, 6.9, 0.4),
    ('Milka', 'Cake & Chock', 428.0, 21.0, 4.1, 0, 56.0, 30.0, 1.4, 5.5, 0.6),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 453.0, 14.0, 1.2, 0, 71.0, 5.5, 3.3, 9.1, 2.5),
    ('Milka', 'Choco brownie', 467.0, 27.0, 12.0, 0, 50.0, 38.0, 1.7, 5.0, 0.4),
    ('Pilos', 'Barretta al quark gusto Nocciola', 388.0, 24.0, 17.0, 0, 28.0, 22.0, 0, 15.0, 0.1),
    ('Happy Creations', 'Cracker Mix Classic', 507.0, 27.0, 11.0, 0, 58.0, 6.0, 3.0, 7.9, 3.5)
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

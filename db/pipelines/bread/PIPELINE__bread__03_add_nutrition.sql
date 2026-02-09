-- PIPELINE (Bread): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Bread'
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
    ('Lajkonik', 'Paluszki słone', 379.0, 4.0, 0.4, 0, 72.0, 2.7, 3.4, 12.0, 3.0),
    ('Gursz', 'Chleb Pszenno-Żytni', 245.0, 1.3, 0.3, 0, 49.3, 1.7, 2.8, 7.6, 1.3),
    ('Pano', 'Tost pełnoziarnisty', 240.0, 2.0, 0.4, 0, 43.0, 2.2, 5.6, 10.0, 1.1),
    ('Pano', 'Tost  maślany', 267.0, 3.2, 1.7, 0, 50.0, 2.9, 0, 8.6, 1.2),
    ('Sonko', 'Lekkie żytnie', 363.0, 1.6, 0.4, 0, 74.5, 0.7, 8.8, 8.2, 1.1),
    ('Aksam', 'Beskidzkie paluszki z solą', 390.0, 5.5, 0.6, 0, 73.0, 2.2, 2.1, 11.0, 3.7),
    ('Melvit', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 434.0, 20.0, 3.0, 0, 58.0, 9.0, 13.0, 12.0, 2.7),
    ('Pano', 'Chleb żytni', 198.0, 1.4, 0.2, 0, 36.0, 3.0, 9.3, 5.6, 1.1),
    ('Pano', 'Tortilla', 300.0, 6.7, 1.3, 0, 49.0, 4.4, 4.7, 8.8, 1.1),
    ('Pano', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 218.0, 5.2, 0.7, 0, 31.7, 3.3, 12.0, 5.3, 1.2),
    ('Pano', 'Pieczywo kukurydziane chrupkie', 376.0, 0.9, 0.2, 0, 83.0, 1.1, 3.5, 7.8, 0.9),
    ('Dijo', 'Fresh Wraps Grill Barbecue x4', 313.0, 7.4, 1.4, 0, 54.0, 3.4, 0, 7.6, 1.6),
    ('Pano', 'tosty pszenny', 244.0, 1.4, 0.3, 0, 49.0, 2.9, 0, 7.9, 1.2),
    ('Sonko', 'Pieczywo Sonko Lekkie 7 Ziaren', 367.0, 1.5, 0.2, 0, 76.8, 3.5, 5.8, 8.6, 1.4),
    ('Pano', 'Chleb Wiejski', 232.0, 1.2, 0.3, 0, 47.0, 2.9, 3.2, 6.8, 1.4),
    ('Dan Cake', 'Toast bread', 281.0, 3.9, 0.4, 0, 52.0, 5.6, 0, 8.8, 1.3),
    ('Wasa', 'Pieczywo z pełnoziarnistej mąki żytniej', 344.0, 1.5, 0.3, 0, 65.0, 2.0, 17.0, 9.0, 0.9),
    ('Pano', 'Wraps lo-carb whole wheat tortilla', 303.0, 6.7, 1.7, 0, 48.3, 0, 5.2, 9.0, 1.2),
    ('Lestello', 'Chickpea cakes', 380.0, 3.2, 0.6, 0, 73.0, 1.9, 6.0, 12.0, 0.9),
    ('TOP', 'Paluszki solone', 394.0, 5.7, 0.7, 0, 72.0, 3.7, 0, 12.0, 3.0),
    ('Piekarnia w sercu Lidla', 'Chleb Tostowy Z Mąką Pełnoziarnistą', 250.0, 2.1, 0.4, 0, 45.0, 1.7, 6.9, 9.5, 1.2),
    ('Carrefour', 'Petits pains grilles', 408.0, 10.0, 0.9, 0, 66.0, 4.2, 6.9, 10.0, 1.0),
    ('Carrefour', 'biscottes braisées', 370.0, 5.6, 0.7, 0, 59.0, 3.8, 14.0, 14.0, 0.9),
    ('Carrefour', 'Biscottes sans sel ajouté', 401.0, 5.1, 0.6, 0, 75.0, 7.3, 3.9, 12.0, 0.0),
    ('Carrefour', 'Biscottes Blé complet', 366.0, 4.9, 0.5, 0, 62.0, 5.5, 12.0, 12.0, 1.5),
    ('Chabrior', 'Biscottes complètes x36', 375.0, 4.8, 0.5, 0, 63.0, 6.4, 10.0, 15.0, 1.4),
    ('Italiamo', 'Piada sfogliata', 311.0, 9.4, 3.9, 0, 48.0, 3.1, 0, 7.4, 1.6),
    ('Carrefour', 'Biscuits Nature', 393.0, 5.0, 0.7, 0, 74.0, 6.5, 4.0, 11.0, 1.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

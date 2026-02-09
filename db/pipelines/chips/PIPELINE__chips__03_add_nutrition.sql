-- PIPELINE (Chips): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Chips'
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
    ('Intersnack', 'Prażynki solone', 540.0, 32.0, 2.5, 0, 61.0, 0.5, 0.8, 1.3, 1.8),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 529.0, 33.0, 2.5, 0, 50.0, 2.6, 4.4, 5.8, 1.3),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o.', 'Wiejskie ziemniaczki - smak masło z solą', 537.0, 34.0, 2.9, 0, 50.0, 1.7, 4.3, 5.7, 1.5),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 479.0, 19.0, 1.5, 0, 69.0, 3.7, 2.7, 6.7, 1.5),
    ('Star', 'Maczugi', 493.0, 24.0, 2.1, 0, 62.0, 6.0, 1.7, 6.0, 1.6),
    ('Przysnacki', 'Chrupki o smaku keczupu', 466.0, 16.0, 1.2, 0, 73.0, 6.3, 0, 6.8, 1.9),
    ('Lorenz', 'Crunchips Sticks Ketchup', 510.0, 29.0, 2.2, 0, 54.0, 2.6, 4.6, 5.9, 0.8),
    ('Lay''s', 'Fromage flavoured chips', 525.0, 32.0, 2.6, 0, 50.0, 2.1, 4.4, 6.8, 0.0),
    ('Lay''s', 'Lays solone', 526.0, 32.0, 2.4, 0, 51.0, 0.7, 4.5, 6.6, 1.1),
    ('Lay''s', 'Lay''s green onion flavoured', 524.0, 32.0, 2.4, 0, 51.0, 3.0, 4.4, 6.7, 1.6),
    ('Lay''s', 'Lays Papryka', 518.0, 30.5, 0, 0, 52.6, 0, 0, 6.2, 0),
    ('Lay''s', 'Lays strong', 517.0, 30.0, 3.1, 0, 52.0, 2.1, 4.6, 6.8, 1.2),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 496.0, 25.0, 2.7, 0, 59.0, 5.7, 5.6, 6.1, 3.2),
    ('Lay’s', 'Lay''s Oven Baked Grilled Paprika', 442.0, 15.0, 1.3, 0, 70.0, 7.4, 5.0, 5.5, 0.8),
    ('Doritos', 'Flamingo Hot', 480.0, 22.0, 1.9, 0, 60.0, 3.3, 5.7, 6.9, 0),
    ('Doritos', 'Hot Corn', 496.0, 25.0, 2.7, 0, 58.0, 4.4, 5.9, 6.2, 1.3),
    ('Lay''s', 'Lays gr. priesk. zolel. sk.', 525.0, 32.0, 2.6, 0, 50.0, 2.1, 4.4, 6.8, 1.7),
    ('Cheetos', 'Cheetos Flamin Hot', 467.0, 19.0, 1.7, 0, 66.0, 4.7, 2.1, 6.6, 1.1),
    ('Lay''s', 'Cheetos Cheese', 481.0, 23.0, 2.1, 0, 62.0, 7.6, 0, 6.1, 3.1),
    ('Crunchips', 'Potato crisps with paprika flavour.', 538.0, 34.0, 2.5, 0, 50.0, 2.4, 4.4, 5.7, 1.5),
    ('Lay''s', 'Lays MAXX cheese & onion', 524.0, 32.0, 2.4, 0, 51.0, 3.0, 4.4, 6.7, 1.6),
    ('Top', 'Chipsy smak serek Fromage', 539.0, 35.0, 3.0, 0, 48.0, 1.6, 4.5, 5.7, 1.2),
    ('Lay''s', 'Lays Green Onion', 525.0, 35.0, 13.6, 0, 46.0, 0.7, 4.8, 7.4, 0.4),
    ('Lorenz', 'Crunchips X-CUT Chakalaka', 515.0, 31.0, 2.3, 0, 51.0, 1.7, 4.7, 5.7, 1.6),
    ('zdrowidło', 'Loopeas light o smaku papryki', 400.0, 8.3, 0.8, 0, 63.0, 2.1, 3.4, 17.0, 1.9),
    ('Lay''s', 'Flamin'' Hot', 516.7, 30.3, 2.3, 0.0, 58.0, 2.3, 4.7, 7.0, 0.0),
    ('Lay''s', 'Oven Baked Chanterelles in a cream sauce flavoured', 441.0, 14.0, 1.4, 0.0, 73.8, 6.1, 4.8, 5.7, 0.0),
    ('Lay''s', 'Chips', 526.0, 32.0, 2.4, 0, 51.0, 0.7, 4.5, 6.6, 2.8)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

-- PIPELINE (Chips): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'PL' and p.category = 'Chips'
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select distinct on (p.product_id)
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    ('Intersnack', 'Prażynki solone', 540.0, 32.0, 2.5, 0, 61.0, 0.5, 0.8, 1.3, 1.8),
    ('Lorenz', 'Crunchips Pieczone Żeberka', 529.0, 33.0, 2.5, 0, 50.0, 2.6, 4.4, 5.8, 1.3),
    ('Miami', 'Pałeczki kukurydziane', 383.0, 2.8, 0.4, 0, 80.0, 0.5, 2.9, 8.1, 0),
    ('The Lorenz Bahlsen Snack-World Sp. z o.o', 'Wiejskie ziemniaczki - smak masło z solą', 537.0, 34.0, 2.9, 0, 50.0, 1.7, 4.3, 5.7, 1.5),
    ('Przysnacki', 'Prażynki bekonowe', 492.0, 24.0, 2.1, 0, 59.0, 4.3, 2.4, 8.1, 2.3),
    ('Przysnacki', 'Chipsy w kotle prażone', 497.0, 28.0, 2.6, 0, 53.0, 0.6, 4.5, 6.0, 1.2),
    ('Przysnacki', 'Przysnacki Chipsy w kotle prażone', 505.0, 28.0, 2.8, 0, 54.0, 3.6, 4.5, 6.3, 0.9),
    ('Erosnack', 'Prażynki o smaku aromatyczny fromage', 508.0, 27.0, 1.9, 0, 61.0, 3.8, 1.8, 5.2, 2.7),
    ('Star', 'Maczugi', 493.0, 24.0, 2.1, 0, 62.0, 6.0, 1.7, 6.0, 1.6),
    ('Przysnacki', 'Chrupki o smaku zielona cebulka', 479.0, 19.0, 1.5, 0, 69.0, 3.7, 2.7, 6.7, 1.5),
    ('Przysnacki', 'Chrupki o smaku keczupu', 466.0, 16.0, 1.2, 0, 73.0, 6.3, 0, 6.8, 1.9),
    ('Crunchips', 'Crunchips X-CUT, Papryka', 516.0, 31.0, 2.3, 0, 51.0, 1.0, 4.6, 6.0, 1.8),
    ('Lorenz', 'Crunchips Sticks Ketchup', 510.0, 29.0, 2.2, 0, 54.0, 2.6, 4.6, 5.9, 0.8),
    ('Lorenz', 'Crunchips X-cut Chakalaka', 514.0, 31.0, 2.5, 0, 51.0, 1.7, 4.3, 5.5, 1.6),
    ('Top', 'Tortilla', 472.0, 22.0, 1.3, 0, 58.0, 0.0, 5.7, 7.3, 0.9),
    ('Crunchips', 'Crunchips o smaku zielona cebulka', 528.0, 34.0, 2.3, 0, 48.0, 1.5, 4.2, 5.5, 1.7),
    ('Miami', 'Chrupki kukurydziane', 383.0, 2.7, 0.4, 0, 80.0, 0.6, 3.3, 8.1, 0.0),
    ('Top', 'Sticks smak ketchup', 519.0, 31.0, 3.0, 0, 52.0, 3.9, 4.5, 5.8, 1.1),
    ('Curly', 'Curly Mexican style', 470.0, 21.0, 2.6, 0, 55.0, 2.9, 4.5, 13.0, 2.8),
    ('Lay''s', 'Oven Baked Grilled paprika flavoured', 441.0, 14.0, 1.2, 0, 70.0, 7.5, 4.1, 5.9, 3.0),
    ('Sunny Family', 'Trips kukurydziane', 378.0, 0.9, 0.2, 0, 82.6, 0.2, 3.6, 8.2, 1.4),
    ('Lay''s', 'Chipsy ziemniaczane o smaku papryki', 525.0, 31.0, 2.7, 0, 52.0, 2.2, 4.7, 6.2, 1.7),
    ('Top', 'Top Sticks', 516.0, 31.0, 2.9, 0, 51.0, 0.6, 4.7, 5.9, 1.1),
    ('Lay''s', 'Chipsy ziemniaczane solone', 549.0, 34.0, 4.2, 0, 53.0, 0.5, 4.4, 6.1, 1.1),
    ('Go Vege', 'Tortilla Chips Buraczane', 495.0, 24.0, 2.4, 0, 60.0, 4.7, 6.3, 6.3, 0.7),
    ('Top', 'Chrupki ziemniaczane o smaku paprykowym', 536.0, 30.0, 2.2, 0, 62.0, 2.4, 0, 3.2, 1.7),
    ('Lay''s', 'Karbowane Papryka', 525.0, 31.0, 2.6, 0, 52.0, 2.2, 4.7, 6.2, 1.7),
    ('Unknown', 'Na Maxa Chrupki kukurydziane orzechowe', 506.0, 27.0, 7.0, 0, 49.0, 2.2, 0, 14.0, 1.5),
    ('Lay''s', 'Lay''s green onion flavoured', 524.0, 32.0, 2.4, 0, 51.0, 3.0, 4.4, 6.7, 1.6),
    ('Lay''s', 'Fromage flavoured chips', 525.0, 32.0, 2.6, 0, 50.0, 2.1, 4.4, 6.8, 0.0),
    ('Lay''s', 'Lay''s Oven Baked Grilled Paprika', 442.0, 15.0, 1.3, 0, 70.0, 7.4, 5.0, 5.5, 0.8),
    ('Lay''s', 'Lays Papryka', 518.0, 30.5, 0, 0, 52.6, 0, 0, 6.2, 0),
    ('Top', 'Chipsy smak serek Fromage', 539.0, 35.0, 3.0, 0, 48.0, 1.6, 4.5, 5.7, 1.2),
    ('Zdrowidło', 'Loopeas light o smaku papryki', 400.0, 8.3, 0.8, 0, 63.0, 2.1, 3.4, 17.0, 1.9),
    ('Lay''s', 'Lays strong', 517.0, 30.0, 3.1, 0, 52.0, 2.1, 4.6, 6.8, 1.2),
    ('Lay''s', 'Lays solone', 526.0, 32.0, 2.4, 0, 51.0, 0.7, 4.5, 6.6, 1.1),
    ('Doritos', 'Hot Corn', 496.0, 25.0, 2.7, 0, 58.0, 4.4, 5.9, 6.2, 1.3),
    ('Lay''s', 'Oven Baked krakersy', 451.0, 17.0, 1.4, 0, 64.0, 15.0, 6.3, 8.2, 1.4),
    ('Sonko', 'Chipsy z ciecierzycy', 408.0, 9.3, 1.4, 0, 68.0, 3.7, 4.2, 11.0, 2.5),
    ('Crunchips', 'Potato crisps with paprika flavour', 538.0, 34.0, 2.5, 0, 50.0, 2.4, 4.4, 5.7, 1.5),
    ('PepsiCo Inc', 'Lays Mini Zielona Cebulka Chipsy', 526.0, 31.0, 2.6, 0, 53.0, 3.1, 0, 6.1, 1.7),
    ('Doritos', 'Doriros Sweet Chili Flavoured 100g', 496.0, 25.0, 2.7, 0, 59.0, 5.7, 5.6, 6.1, 3.2),
    ('Eurosnack', 'Chrupki kukurydziane Pufuleti Sea salt', 396.0, 11.0, 1.1, 0, 68.0, 1.5, 0, 5.3, 1.5),
    ('Crunchips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 528.0, 33.0, 2.5, 0, 50.0, 2.8, 4.4, 5.5, 1.5),
    ('Cheetos', 'Cheetos Flamin Hot', 467.0, 19.0, 1.7, 0, 66.0, 4.7, 2.1, 6.6, 1.1),
    ('Lay''s', 'Flamin'' Hot', 516.7, 30.3, 2.3, 0.0, 58.0, 2.3, 4.7, 7.0, 0.0),
    ('Lorenz', 'Peppies Bacon Flavour', 493.0, 24.0, 2.5, 0, 56.0, 2.4, 2.0, 5.6, 2.8),
    ('Lorenz', 'Monster Munch Mr BIG', 531.0, 29.0, 2.7, 0, 63.0, 6.4, 1.8, 3.7, 2.8),
    ('Lorenz', 'Wiejskie Ziemniaczki Cebulka', 530.0, 33.0, 2.5, 0, 50.0, 1.7, 4.5, 5.9, 1.2)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = 'Chips' and p.is_deprecated is not true
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

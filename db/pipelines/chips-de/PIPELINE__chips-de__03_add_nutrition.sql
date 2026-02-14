-- PIPELINE (Chips): add nutrition facts
-- Source: Open Food Facts verified per-100g data
-- Generated: 2026-02-13

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = 'DE' and p.category = 'Chips'
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
    ('Tyrrell''s', 'Lightly sea salted crisps', 476.0, 27.0, 2.4, 0, 49.0, 0.6, 5.5, 6.2, 0.8),
    ('Kellogg''s', 'Pringles Original', 530.0, 31.0, 3.0, 1.0, 55.0, 0.9, 3.5, 6.1, 1.0),
    ('Pringles', 'Pringles', 534.0, 31.0, 6.6, 0, 56.0, 1.4, 3.5, 5.9, 1.1),
    ('Tyrrells', 'Sea salt & cider vinegar chips', 467.0, 25.0, 2.2, 0, 51.0, 2.5, 5.1, 5.8, 1.8),
    ('Pringles', 'Sour Cream & Onion', 525.0, 30.0, 6.4, 0, 56.0, 2.7, 3.4, 6.0, 1.3),
    ('Pringles', 'Pringles Original', 534.0, 31.0, 6.6, 0, 56.0, 1.4, 3.5, 5.9, 1.1),
    ('Pringles', 'Sour Cream & Onion chips', 517.0, 29.0, 2.9, 0, 56.0, 2.1, 3.5, 6.3, 1.2),
    ('Pringles', 'Pringles sour cream & onion', 515.0, 30.0, 2.9, 0, 54.0, 2.0, 4.0, 6.3, 1.1),
    ('Pringles', 'Pringles Sour Cream', 517.0, 29.0, 2.9, 0, 56.0, 2.1, 3.5, 6.3, 1.2),
    ('Pringles', 'Texas BBQ Sauce', 517.0, 29.0, 2.9, 0, 56.0, 4.1, 3.5, 6.3, 1.1),
    ('Old El Paso', 'Tortilla Nachips Original', 490.0, 23.7, 2.3, 0, 59.0, 0.7, 6.0, 7.7, 0.5),
    ('Pringles', 'Pringles hot & spicy', 487.0, 29.0, 3.0, 0, 50.0, 2.7, 3.7, 6.7, 1.2),
    ('Pringles', 'Pringles Paprika', 522.0, 30.0, 2.8, 0.0, 54.0, 3.2, 4.4, 6.7, 0.0),
    ('Tyrrell’s', 'Chips sel de mer et poivre noir', 469.0, 26.0, 2.3, 0, 50.0, 1.2, 5.4, 6.4, 1.0),
    ('Tyrrell’s', 'Tyrrell''s Sweet Chilli & Red Pepper', 503.0, 27.3, 0.7, 0, 54.1, 4.9, 6.6, 7.0, 0.3),
    ('Tyrell''s', 'Mature Cheddar & Chive', 505.0, 27.8, 0.8, 0, 52.9, 3.6, 6.5, 7.5, 0.4),
    ('Walkers', 'Baked Sea Salt', 438.0, 13.0, 1.4, 0, 73.0, 5.4, 6.3, 5.9, 0.8),
    ('Brets', 'Chips saveur Poulet Braisé', 522.0, 31.0, 2.6, 0, 52.0, 0.8, 4.8, 6.3, 1.4),
    ('Lidl', 'Lightly salted tortilla', 474.0, 19.8, 1.8, 0, 65.5, 1.0, 4.3, 6.2, 0.7),
    ('Funny-frisch', 'Chipsfrisch ungarisch', 533.0, 33.0, 3.0, 0, 49.0, 2.5, 4.5, 6.0, 1.5),
    ('Pringles', 'Pringles Salt & Vinegar', 518.0, 30.0, 2.8, 0, 54.0, 1.9, 3.9, 6.0, 0.4),
    ('Barcel', 'Takis Fuego', 486.0, 27.0, 11.0, 0, 51.0, 2.2, 8.5, 5.2, 1.8),
    ('General Mills', 'Tortilla chips', 485.0, 22.6, 2.0, 0, 59.1, 1.5, 6.5, 8.0, 0.4),
    ('Gran Pavesi', 'Gpav cracker salato pav 560 gr', 436.0, 14.0, 2.1, 0, 64.0, 3.2, 5.2, 11.0, 2.2),
    ('Zweifel vaya', 'Bean Salt Snack', 424.0, 13.0, 1.1, 0, 57.0, 1.3, 6.6, 17.0, 1.7),
    ('Harvest Basket', 'Potato Wedges sült krumpli', 127.0, 3.3, 0.6, 0, 21.0, 0.5, 2.3, 2.2, 0.6),
    ('Arvid Nordquist Norge AS', 'Curvies original gluten free', 495.0, 25.0, 1.8, 0, 61.0, 5.1, 4.4, 4.7, 1.3),
    ('Funny-frisch', 'Linsen Chips Paprika Style', 453.0, 18.0, 2.0, 0, 57.0, 3.9, 5.4, 13.0, 1.6),
    ('Pringles', 'Hot & Spicy', 515.0, 29.0, 2.9, 0, 55.0, 2.5, 3.8, 6.5, 1.2),
    ('Pringles', 'Pringles Hot Smokin’ BBQ Ribs Flavour', 522.0, 30.0, 2.9, 0, 55.0, 4.0, 3.8, 6.1, 0.6),
    ('Mister Free''d', 'Tortilla Chips Avocado Guacamole Flavour', 522.0, 24.0, 3.7, 0, 67.0, 1.6, 4.7, 7.1, 1.0),
    ('Lorenz', 'Crunchips Paprika', 538.0, 34.0, 2.6, 0, 50.0, 2.4, 4.4, 5.7, 1.5),
    ('Snack Day', 'Nature Tortilla', 472.0, 20.0, 2.0, 0, 64.4, 0.8, 4.0, 6.6, 0.9),
    ('Suzi Wan', 'Chips à la crevette', 507.6, 19.0, 1.9, 0, 73.0, 12.0, 1.7, 1.1, 2.1),
    ('Eat Real', 'Veggie Straws - With Kale, Tomato & Spinach', 540.0, 31.3, 2.5, 0, 60.5, 1.1, 2.3, 2.9, 1.4),
    ('Barcel', 'Takis Queso Volcano 100g', 517.0, 30.0, 10.0, 0, 53.0, 3.3, 8.5, 5.5, 1.6),
    ('Pringles', 'Pringles Cheese & onion', 516.3, 29.0, 6.3, 0.0, 56.0, 2.9, 3.5, 6.1, 1.4),
    ('Takis', 'Takis Dragon Sweet chilli', 536.0, 28.6, 8.9, 0, 60.7, 3.6, 3.6, 7.1, 1.6),
    ('Doritos', 'Doritos Sweet Chilli Pepper Flavour', 477.0, 22.0, 2.0, 0, 60.0, 4.5, 5.5, 6.4, 1.1),
    ('Wasa', 'Sans gluten et sans lactose', 398.0, 8.0, 1.0, 0, 73.0, 2.0, 7.0, 5.0, 1.1),
    ('Funny-frisch', 'Chipsfrisch Peperoni', 532.0, 33.0, 3.0, 0, 49.0, 1.9, 4.4, 5.9, 1.4),
    ('Pringles', 'Pringles hot cheese', 521.0, 30.0, 2.9, 0, 54.0, 3.4, 4.1, 6.6, 0.6),
    ('Pringles', 'Original', 536.0, 31.0, 6.6, 0.0, 56.0, 1.4, 3.5, 5.9, 1.1),
    ('Asia Green Garden', 'Prawn Crackers', 542.0, 32.0, 2.6, 0.0, 61.5, 6.4, 0.8, 1.5, 1.5),
    ('Tyrrell’s', 'Furrows Sea Salt & Vinegar', 508.0, 28.8, 3.1, 0, 54.1, 1.4, 0, 6.1, 1.8),
    ('Pringles', 'Hot Kickin'' Sour Cream Flavour', 523.0, 30.0, 3.0, 0, 55.0, 2.2, 3.9, 6.4, 0.6),
    ('Funny-Frisch', 'Chipsfrisch Oriental', 532.0, 33.0, 2.9, 0, 50.0, 2.8, 4.2, 5.6, 1.3),
    ('Elephant', 'Baked squeezed pretzels with tomatoes and herbs', 430.0, 12.0, 0.8, 0, 70.0, 8.1, 0, 9.9, 2.0),
    ('Finn Crisp', 'Finn Crisp Snacks', 399.0, 12.0, 1.1, 0, 55.0, 3.4, 17.0, 9.2, 1.4),
    ('Funny-frisch', 'Chipsfrisch gesalzen', 539.0, 34.0, 3.0, 0, 49.0, 0.6, 4.2, 5.6, 1.4),
    ('Mister Free''d', 'Blue Maize Tortilla Chips', 481.0, 21.0, 2.0, 0, 63.0, 0.6, 5.7, 7.1, 1.1)
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'DE' and p.brand = d.brand and p.product_name = d.product_name
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

-- PIPELINE (CHIPS): add nutrition facts
-- PIPELINE__chips__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-07
--
-- Fiber values marked (est.) are category-typical estimates where OFF had no data.

-- 1) Remove existing nutrition for PL Chips so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Chips'
);

-- 2) Insert verified per-SKU nutrition
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- brand,               product_name,                         kcal,  fat, sat, trans, carbs, sugar, fiber, prot, salt
    ('Lay''s',              'Lay''s Solone',                      '526','32','2.4','0',  '51', '0.7', '4.5', '6.6', '1.08'),
    ('Lay''s',              'Lay''s Fromage',                     '546','34','4.3','0',  '52', '1.9', '4.2', '6.3', '1.7'),
    ('Lay''s',              'Lay''s Oven Baked Grilled Paprika',  '442','15','1.3','0',  '70', '7.4', '5.0', '5.5', '0.83'),
    ('Pringles',            'Pringles Original',                  '530','32','3.0','0',  '55', '2.0', '3.5', '6.1', '1.3'),
    ('Pringles',            'Pringles Paprika',                   '522','30','3.0','0',  '54', '4.0', '4.4', '6.7', '1.8'),
    ('Crunchips',           'Crunchips X-Cut Papryka',            '516','31','2.3','0',  '51', '1.0', '4.6', '6.0', '1.8'),
    ('Crunchips',           'Crunchips Pieczone Żeberka',         '529','33','2.5','0',  '50', '2.6', '4.4', '5.8', '1.3'),
    ('Crunchips',           'Crunchips Chakalaka',                '515','31','2.3','0',  '51', '1.7', '4.7', '5.7', '1.6'),
    ('Doritos',             'Doritos Hot Corn',                   '496','25','2.7','0',  '58', '4.4', '5.9', '6.2', '1.3'),
    ('Doritos',             'Doritos BBQ',                        '496','25','3.6','0',  '59', '3.5', '3.6', '6.5', '1.3'),
    ('Cheetos',             'Cheetos Flamin Hot',                 '467','19','1.7','0',  '66', '4.7', '2.1', '6.6', '1.08'),
    ('Cheetos',             'Cheetos Cheese',                     '480','23','2.1','0',  '62', '7.5', '2.0', '6.1', '3.2'),  -- fiber: est.
    ('Cheetos',             'Cheetos Hamburger',                  '495','24','2.1','0',  '62', '5.5', '2.1', '6.4', '1.6'),
    ('Top Chips (Biedronka)','Top Chips Fromage',                 '539','35','3.0','0',  '48', '1.6', '4.5', '5.7', '1.2'),
    ('Top Chips (Biedronka)','Top Chips Faliste',                 '542','35','16.0','0', '49', '2.3', '4.0', '5.7', '1.5'), -- fiber: est.; 16g sat fat from palm oil
    ('Snack Day (Lidl)',    'Snack Day Chipsy Solone',            '542','35','3.2','0',  '49', '0.6', '4.0', '5.5', '1.1')  -- fiber: est.
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

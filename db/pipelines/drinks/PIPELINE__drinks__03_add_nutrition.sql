-- PIPELINE (DRINKS): add nutrition facts
-- PIPELINE__drinks__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g ≈ per 100 ml) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Drinks so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Drinks'
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
    -- brand,      product_name,                        kcal,  fat,  sat, trans, carbs, sugar, fiber, prot, salt
    -- ── Colas & sodas ──────────────────────────────────────────────────
    ('Coca-Cola', 'Coca-Cola Original',                 '42',  '0',  '0', '0',  '10.6','10.6','0',   '0', '0'),
    ('Coca-Cola', 'Coca-Cola Zero',                     '0.2', '0',  '0', '0',  '0',   '0',   '0',   '0', '0.02'),
    ('Fanta',     'Fanta Orange',                        '27',  '0',  '0', '0',  '6.5', '6.5', '0',   '0', '0'),
    ('Pepsi',     'Pepsi',                               '43',  '0',  '0', '0',  '11',  '11',  '0',   '0', '0.03'),
    -- ── Energy drinks ──────────────────────────────────────────────────
    ('Tiger',     'Tiger Energy Drink',                  '21',  '0',  '0', '0',  '4.9', '4.9', '0',   '0', '0.17'),
    ('Tiger',     'Tiger Energy Drink Classic',          '46',  '0',  '0', '0',  '11',  '11',  '0',   '0', '0.17'),
    ('4Move',     '4Move Activevitamin',                 '11',  '0',  '0', '0',  '2',   '2',   '0',   '0', '0'),
    -- ── Juices ─────────────────────────────────────────────────────────
    ('Tymbark',   'Tymbark Sok 100% Pomarańczowy',       '44',  '0',  '0', '0',  '10',  '10',  '0',  '0.6','0'),
    ('Tymbark',   'Tymbark Sok 100% Jabłkowy',           '43',  '0',  '0', '0',  '11',  '11',  '0',   '0', '0'),
    ('Tymbark',   'Tymbark Multiwitamina',               '51',  '0',  '0', '0',  '12',  '12',  '0',   '0', '0.01'),
    ('Tymbark',   'Tymbark Cactus',                      '20',  '0',  '0', '0',  '4.8', '4.8', '0',   '0', '0.01'),
    ('Hortex',    'Hortex Sok Jabłkowy 100%',            '44',  '0',  '0', '0',  '10.3','10.3','0',  '0.2','0'),
    ('Hortex',    'Hortex Sok Pomarańczowy 100%',        '45',  '0',  '0', '0',  '10.5','10.5','0',  '0.6','0'),
    ('Cappy',     'Cappy 100% Orange',                   '43',  '0',  '0', '0',  '8.9', '8.9', '0',  '0.7','0'),
    ('Dawtona',   'Dawtona Sok Pomidorowy',              '19',  '0',  '0', '0',  '3.1', '3.1', '0',   '1', '0.4'),
    -- ── Dairy ──────────────────────────────────────────────────────────
    ('Mlekovita', 'Mlekovita Mleko 3.2%',                '60',  '3.2','2.1','0', '4.7', '4.7', '0',  '3.2','0.1'),
    -- ── Energy drinks (new) ─────────────────────────────────────────────────
    ('Red Bull',  'Red Bull Energy Drink',                '46',  '0',  '0', '0',  '11',  '11',  '0',   '0', '0.1'),
    ('Monster',   'Monster Energy Mango Loco',             '47',  '0',  '0', '0',  '12',  '11',  '0',   '0', '0.05'),
    -- ── Sodas (new) ────────────────────────────────────────────────────────
    ('Sprite',    'Sprite',                                '42',  '0',  '0', '0',  '10.3','10.3','0',   '0', '0.01'),
    ('7UP',       '7UP',                                   '42',  '0',  '0', '0',  '10.5','10.5','0',   '0', '0.02'),
    ('Mountain Dew','Mountain Dew',                         '48',  '0',  '0', '0',  '12',  '12',  '0',   '0', '0.02'),
    ('Mirinda',   'Mirinda Orange',                        '44',  '0',  '0', '0',  '10.5','10.5','0',   '0', '0.01'),
    -- ── Iced teas (new) ────────────────────────────────────────────────────
    ('Lipton',    'Lipton Ice Tea Lemon',                  '30',  '0',  '0', '0',  '7.2', '6.9', '0',   '0', '0.02'),
    ('Fuze Tea',  'Fuze Tea Peach Hibiscus',               '21',  '0',  '0', '0',  '5',   '4.8', '0',   '0', '0.01'),
    -- ── Juice / flavored water (new) ───────────────────────────────────────
    ('Kubuś',     'Kubuś Play Marchew-Jabłko',              '40',  '0',  '0', '0',  '8.5', '8.5', '0.5','0.3','0.02'),
    ('Żywiec Zdrój','Żywiec Zdrój Smako-łyk Truskawka',     '10',  '0',  '0', '0',  '2.3', '2.3', '0',   '0', '0.01'),
    -- ── Dairy (new) ────────────────────────────────────────────────────────
    ('Łaciate',   'Łaciate Mleko 2%',                       '50',  '2',  '1.3','0', '4.8', '4.8', '0',  '3.4','0.1'),
    -- ── RTD Coffee (new) ───────────────────────────────────────────────────
    ('Costa Coffee','Costa Coffee Latte',                  '47',  '1.5','1', '0',  '5.8', '5.5', '0.3','1.7','0.08')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

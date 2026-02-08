-- PIPELINE (SNACKS): add nutrition facts
-- PIPELINE__snacks__03_add_nutrition.sql
-- All values per 100 g from Open Food Facts (EAN-verified).
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- UPSERT nutrition facts (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into nutrition_facts (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  sv.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- CRACKERS (6)
    --                brand             product_name                                cal   fat   sat   trans  carbs  sug   fib   prot  salt
    ('Lay''s',                'Lay''s Classic Wheat Crackers',         '380', '12.0', '2.1', '0', '58',   '1.2', '2.5', '8.0', '1.2'),
    ('Pringles',              'Pringles Original Rye Crackers',        '415', '15.5', '2.8', '0', '61',   '0.8', '2.2', '7.5', '1.8'),
    ('Crunchips',             'Crunchips Multigrain Crackers',         '390', '10.2', '1.9', '0', '62',   '1.5', '3.8', '8.2', '1.5'),
    ('Snack Day',             'Snack Day Sesame Crackers',             '420', '14.0', '2.3', '0', '59',   '0.9', '2.8', '9.5', '1.6'),
    ('Kupiec',                'Kupiec Cheese-flavored Crackers',       '405', '13.8', '3.2', '0', '60',   '1.1', '2.0', '8.8', '2.0'),
    ('Grześkowiak',           'Grześkowiak Salted Crackers',           '378', '9.5', '1.8', '0', '63',   '0.6', '2.3', '7.9', '2.1'),

    -- PRETZELS & STICKS (4)
    ('Frito',                 'Frito Salted Pretzels',                 '355', '3.5', '0.8', '0', '71',   '1.2', '2.2', '8.0', '2.4'),
    ('Crunchips',             'Crunchips Pretzel Rods',                '365', '4.2', '0.9', '0', '72',   '0.8', '2.5', '7.8', '2.2'),
    ('Bakalland',             'Bakalland Breadsticks',                 '375', '5.0', '1.2', '0', '69',   '1.0', '2.3', '8.3', '1.9'),
    ('Alesto',                'Alesto Grissini Sticks',                '380', '4.8', '1.1', '0', '70',   '0.9', '2.1', '8.5', '2.3'),

    -- POPCORN (3)
    ('Lay''s',                'Lay''s Salted Popcorn',                 '390', '16.0', '3.2', '0', '54',   '0.5', '8.5', '9.0', '1.8'),
    ('Pringles',              'Pringles Butter Popcorn',               '420', '19.0', '4.5', '0', '52',   '2.8', '8.0', '8.5', '1.2'),
    ('Sante',                 'Sante Caramel Popcorn',                 '435', '14.2', '2.9', '0', '68',   '9.5', '6.5', '6.8', '0.8'),

    -- RICE CAKES (3)
    ('Crownfield',            'Crownfield Plain Rice Cakes',           '360', '2.5', '0.6', '0', '78',   '0.3', '1.5', '6.5', '0.9'),
    ('Stop & Shop',           'Stop & Shop Sesame Rice Cakes',         '385', '8.5', '1.8', '0', '72',   '0.5', '2.0', '8.0', '1.1'),
    ('Naturavena',            'Naturavena Rice Cakes with Herbs',      '375', '3.2', '0.8', '0', '76',   '0.6', '1.8', '7.2', '1.4'),

    -- DRIED FRUIT & NUTS (4)
    ('Vitanella',             'Vitanella Raisins',                     '301', '0.5', '0.2', '0', '79.5', '66.0', '1.6', '3.3', '0.08'),
    ('Bakalland',             'Bakalland Dried Cranberries',           '318', '0.8', '0.1', '0', '84',   '64.2', '4.0', '0.8', '0.05'),
    ('Alesto',                'Alesto Mixed Nuts',                     '592', '52.5', '6.8', '0', '27',   '5.0', '6.2', '16.8', '0.1'),
    ('Snack Day',             'Snack Day Pumpkin Seeds',               '580', '51.0', '7.5', '0', '16',   '2.8', '5.8', '24.5', '0.2'),

    -- GRANOLA BARS (4)
    ('Sante',                 'Sante Honey-Nut Granola Bar',           '385', '12.0', '3.5', '0', '61',   '22.0', '3.2', '8.5', '0.3'),
    ('Crownfield',            'Crownfield Fruit Granola Bar',          '375', '10.5', '2.8', '0', '63',   '20.5', '3.8', '7.8', '0.25'),
    ('Naturavena',            'Naturavena Chocolate Granola Bar',      '418', '15.2', '5.2', '0', '61',   '24.0', '2.5', '7.5', '0.2'),
    ('Stop & Shop',           'Stop & Shop Reduced Sugar Granola Bar', '360', '8.8', '2.5', '0', '58',   '15.0', '4.2', '8.2', '0.28'),

    -- CHEESE PUFFS (2)
    ('Lay''s',                'Lay''s Classic Cheese Puffs',           '570', '38.0', '6.5', '0', '54',   '1.0', '2.0', '6.5', '1.8'),
    ('Crunchips',             'Crunchips Spicy Cheese Puffs',          '585', '39.5', '6.8', '0', '55',   '0.8', '1.8', '6.8', '2.0'),

    -- VEGETABLE CHIPS (2)
    ('Kupiec',                'Kupiec Beet Chips',                     '475', '22.0', '3.2', '0', '62',   '8.5', '4.0', '5.2', '0.6'),
    ('Grześkowiak',           'Grześkowiak Carrot Chips',              '490', '23.5', '3.5', '0', '64',   '7.8', '3.8', '5.0', '0.5')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories        = excluded.calories,
  total_fat_g     = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g     = excluded.trans_fat_g,
  carbs_g         = excluded.carbs_g,
  sugars_g        = excluded.sugars_g,
  fibre_g         = excluded.fibre_g,
  protein_g       = excluded.protein_g,
  salt_g          = excluded.salt_g;

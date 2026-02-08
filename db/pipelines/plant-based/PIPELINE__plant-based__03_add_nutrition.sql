-- PIPELINE (PLANT-BASED): add nutrition facts
-- PIPELINE__plant-based__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g/100 ml) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- Last updated: 2026-02-08
--
-- Note: Plant-based products generally have low/zero cholesterol and favorable fatty acid profiles.

-- 1) Remove existing nutrition for PL Plant-Based products so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
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
    -- brand,               product_name,                                kcal,  fat, sat, trans, carbs, sugar, fiber, prot, salt
    -- ── ALPRO (Plant Milks & Yogurts) ───────────────────────────────────────
    ('Alpro',              'Alpro Napój Sojowy Naturalny',             '33', '1.8','0.3','0',  '0.1', '0',   '0.8', '3.3', '0.08'),
    ('Alpro',              'Alpro Napój Owsiany Naturalny',            '42', '1.5','0.2','0',  '6.5', '4.1', '0.8', '0.3', '0.09'),
    ('Alpro',              'Alpro Jogurt Sojowy Naturalny',            '51', '2.3','0.4','0',  '3.5', '2.8', '1.8', '3.9', '0.13'),
    ('Alpro',              'Alpro Napój Migdałowy Niesłodzony',        '24', '1.1','0.1','0',  '3.0', '0',   '0.4', '0.5', '0.11'),
    
    -- ── GARDEN GOURMET (Vegan Meat Alternatives) ─────────────────────────────
    ('Garden Gourmet',     'Garden Gourmet Sensational Burger',        '234','14', '6.0','0',  '9.0', '1.0', '6.5', '19',  '1.08'),
    ('Garden Gourmet',     'Garden Gourmet Vegan Nuggets',             '221','11', '1.0','0',  '17',  '1.1', '4.0', '15',  '1.37'),
    ('Garden Gourmet',     'Garden Gourmet Vegan Mince',               '118','3.8','0.5','0',  '5.0', '1.9', '5.5', '16',  '0.95'),
    ('Garden Gourmet',     'Garden Gourmet Vegan Schnitzel',           '186','8.0','0.7','0',  '13',  '0.8', '3.5', '16',  '1.20'),
    
    -- ── VIOLIFE (Vegan Cheese) ──────────────────────────────────────────────
    ('Violife',            'Violife Original Block',                   '270','23', '20', '0',  '7.0', '0',   '0',   '0.1', '1.75'),
    ('Violife',            'Violife Mozzarella Style Shreds',          '263','22', '19', '0',  '8.0', '0',   '0',   '0.1', '1.45'),
    ('Violife',            'Violife Cheddar Slices',                   '275','24', '20', '0',  '6.5', '0',   '0',   '0.1', '1.88'),
    
    -- ── TAIFUN (Tofu) ───────────────────────────────────────────────────────
    ('Taifun',             'Taifun Tofu Natural',                      '144','8.6','1.2','0',  '0.7', '0.7', '2.0', '15',  '0.01'),
    ('Taifun',             'Taifun Tofu Smoked',                       '152','9.3','1.3','0',  '1.0', '0.8', '2.1', '15',  '1.35'),
    ('Taifun',             'Taifun Tofu Rosso',                        '167','10', '1.5','0',  '3.5', '2.0', '2.6', '14',  '0.98'),
    
    -- ── LIKEMEAT (Plant-Based Meat) ─────────────────────────────────────────
    ('LikeMeat',           'LikeMeat Like Chicken Pieces',             '188','9.0','0.9','0',  '9.5', '0.5', '4.5', '18',  '1.25'),
    ('LikeMeat',           'LikeMeat Like Kebab',                      '195','10', '1.1','0',  '11',  '1.0', '3.8', '17',  '1.33'),
    
    -- ── SOJASUN (Soy Yogurt) ────────────────────────────────────────────────
    ('Sojasun',            'Sojasun Jogurt Sojowy Naturalny',          '48', '2.0','0.4','0',  '3.2', '2.8', '1.5', '4.0', '0.10'),
    ('Sojasun',            'Sojasun Jogurt Sojowy Waniliowy',          '68', '2.2','0.4','0',  '9.5', '8.5', '1.4', '3.8', '0.13'),
    
    -- ── KUPIEC (Polish Tofu) ────────────────────────────────────────────────
    ('Kupiec',             'Kupiec Ser Tofu Naturalny',                '127','7.0','1.0','0',  '1.5', '1.0', '1.8', '13',  '0.02'),
    ('Kupiec',             'Kupiec Ser Tofu Wędzony',                  '135','7.5','1.1','0',  '2.0', '1.2', '1.9', '13',  '1.15'),
    
    -- ── BEYOND MEAT (Premium Vegan Burgers) ─────────────────────────────────
    ('Beyond Meat',        'Beyond Meat Beyond Burger',                '251','18', '5.0','0',  '5.0', '0.5', '3.0', '20',  '1.01'),
    ('Beyond Meat',        'Beyond Meat Beyond Sausage',               '224','15', '5.5','0',  '7.5', '0.8', '2.5', '15',  '1.44'),
    
    -- ── NATURALNIE (Polish Plant Milks) ─────────────────────────────────────
    ('Naturalnie',         'Naturalnie Napój Owsiany Klasyczny',       '46', '1.5','0.2','0',  '7.5', '4.5', '1.0', '0.5', '0.10'),
    ('Naturalnie',         'Naturalnie Napój Kokosowy',                '22', '1.5','1.3','0',  '2.0', '1.2', '0',   '0.1', '0.08'),
    
    -- ── SIMPLY V (Vegan Cream Cheese) ───────────────────────────────────────
    ('Simply V',           'Simply V Ser Kremowy Naturalny',           '245','23', '3.5','0',  '5.0', '1.0', '3.0', '2.5', '1.15'),
    
    -- ── GREEN LEGEND (Ready Meals) ──────────────────────────────────────────
    ('Green Legend',       'Green Legend Kotlet Sojowy',               '208','11', '1.2','0',  '12',  '1.5', '5.0', '17',  '1.18'),
    
    -- ── TEMPEH (Fermented Soy) ──────────────────────────────────────────────
    ('Taifun',             'Taifun Tempeh Natural',                    '192','10', '2.0','0',  '7.5', '0.5', '5.0', '19',  '0.01')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g';

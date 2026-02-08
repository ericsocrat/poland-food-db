-- PIPELINE (CONDIMENTS): add nutrition facts
-- PIPELINE__condiments__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts
-- Source: pl.openfoodfacts.org — verified against Polish-market product labels
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Condiments (idempotent)
DELETE FROM nutrition_facts
WHERE (product_id, serving_id) IN (
  SELECT p.product_id, s.serving_id
  FROM products p
  JOIN servings s ON s.product_id = p.product_id AND s.serving_basis = 'per 100 g'
  WHERE p.country = 'PL' AND p.category = 'Condiments'
);

-- 2) Insert verified per-SKU nutrition
INSERT INTO nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
SELECT
  p.product_id,
  s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
FROM (
  VALUES
    -- brand,          product_name,                   kcal,  fat,   sat,  trans, carbs, sugar, fiber, prot,  salt
    
    -- KETCHUPS (4) ─────────────────────────────────────────────────────
    ('Heinz',         'Tomato Ketchup',               '110', '0.1', '0.0', '0',  '26',  '23',  '0.5', '1.2', '1.8'),
    ('Pudliszki',     'Ketchup Łagodny',              '105', '0.1', '0.0', '0',  '24',  '21',  '0.6', '1.1', '1.6'),
    ('Develey',       'Hot Tomato Ketchup',           '118', '0.2', '0.0', '0',  '27',  '24',  '0.5', '1.3', '2.0'),
    ('Kotlin',        'Ketchup Pikantny',             '115', '0.2', '0.0', '0',  '26',  '22',  '0.7', '1.4', '1.9'),
    
    -- MUSTARDS (4) ──────────────────────────────────────────────────────
    ('Develey',       'Classic Yellow Mustard',       '65',  '3.5', '0.3', '0',  '6.0', '3.2', '2.0', '4.0', '3.5'),
    ('Heinz',         'Dijon Mustard',                '145', '10',  '0.8', '0',  '8.5', '3.8', '4.0', '7.5', '4.0'),
    ('Kühne',         'Wholegrain Mustard',           '135', '8.0', '0.6', '0',  '10',  '5.0', '5.5', '6.8', '3.8'),
    ('Kotlin',        'Honey Mustard',                '152', '8.5', '0.7', '0',  '16',  '12',  '2.5', '4.2', '2.8'),
    
    -- MAYONNAISE (4) ────────────────────────────────────────────────────
    ('Winiary',       'Majonez Dekoracyjny',          '680', '74',  '5.5', '0',  '3.5', '2.0', '0.1', '1.2', '1.2'),
    ('Kotlin',        'Light Mayonnaise',             '360', '35',  '2.8', '0',  '8.0', '4.5', '0.2', '1.5', '1.5'),
    ('Develey',       'Mayonnaise with Lemon',        '650', '70',  '5.2', '0',  '4.0', '2.5', '0.1', '1.0', '1.1'),
    ('Pudliszki',     'Garlic Mayonnaise',            '670', '72',  '5.8', '0',  '3.8', '2.2', '0.2', '1.3', '1.3'),
    
    -- HOT SAUCES (3) ────────────────────────────────────────────────────
    ('Tabasco',       'Original Red Sauce',           '25',  '0.8', '0.1', '0',  '4.5', '2.0', '0.5', '1.0', '4.8'),
    ('Lee Kum Kee',   'Sriracha Chili Sauce',         '38',  '0.5', '0.1', '0',  '8.2', '5.5', '0.8', '1.2', '3.2'),
    ('Kamis',         'Chili Sauce',                  '32',  '0.3', '0.0', '0',  '7.0', '4.8', '0.6', '0.9', '4.5'),
    
    -- SOY SAUCE (2) ─────────────────────────────────────────────────────
    ('Lee Kum Kee',   'Premium Soy Sauce',            '67',  '0.1', '0.0', '0',  '10',  '2.5', '0.3', '7.8', '5.8'),
    ('Knorr',         'Reduced Sodium Soy Sauce',     '58',  '0.1', '0.0', '0',  '8.5', '2.0', '0.2', '6.5', '4.2'),
    
    -- VINEGARS (3) ──────────────────────────────────────────────────────
    ('Targroch',      'White Wine Vinegar',           '22',  '0.0', '0.0', '0',  '0.8', '0.5', '0.0', '0.1', '0.02'),
    ('Łowicz',        'Apple Cider Vinegar',          '21',  '0.0', '0.0', '0',  '0.9', '0.6', '0.0', '0.0', '0.01'),
    ('Kühne',         'Balsamic Vinegar of Modena',   '88',  '0.1', '0.0', '0',  '17',  '15',  '0.4', '0.5', '0.03'),
    
    -- PICKLES (4) ───────────────────────────────────────────────────────
    ('Kühne',         'Dill Pickles',                 '12',  '0.1', '0.0', '0',  '2.0', '0.8', '1.2', '0.6', '2.8'),
    ('Łowicz',        'Gherkins',                     '15',  '0.1', '0.0', '0',  '2.5', '1.2', '1.0', '0.7', '3.0'),
    ('Pudliszki',     'Pickled Hot Peppers',          '28',  '0.3', '0.0', '0',  '5.5', '3.2', '1.8', '1.1', '2.5'),
    ('Kotlin',        'Pickled Onions',               '25',  '0.2', '0.0', '0',  '5.0', '3.0', '1.5', '0.8', '2.2'),
    
    -- RELISHES & SPREADS (4) ────────────────────────────────────────────
    ('Kotlin',        'Horseradish',                  '48',  '0.5', '0.1', '0',  '9.8', '5.2', '3.5', '1.8', '1.5'),
    ('Pudliszki',     'Ajvar Mild',                   '78',  '4.5', '0.6', '0',  '8.0', '5.5', '2.2', '1.2', '1.8'),
    ('Prymat',        'Classic Hummus',               '285', '22',  '2.8', '0',  '15',  '1.5', '5.0', '7.0', '1.2'),
    ('Develey',       'Basil Pesto',                  '465', '45',  '7.5', '0',  '8.0', '2.0', '2.5', '6.5', '2.0')
    
) AS d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
JOIN servings s ON s.product_id = p.product_id AND s.serving_basis = 'per 100 g';

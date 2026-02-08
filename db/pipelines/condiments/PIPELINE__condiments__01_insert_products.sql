-- =====================================================================
-- PIPELINE: Condiments - Step 1: Insert Products
-- =====================================================================
-- Purpose: Insert 28 condiment products available in Poland
-- Categories: Ketchup, mustard, mayonnaise, hot sauces, soy sauce, 
--            vinegar, pickles, relishes & spreads
-- Last Updated: 2026-02-08
-- =====================================================================

-- =====================================================================
-- Section 0: Deprecate Old Products with Incorrect Country Code
-- =====================================================================
UPDATE products 
SET is_deprecated = true,
    deprecated_reason = 'Country code migration: Poland -> PL'
WHERE country = 'Poland' 
  AND category = 'Condiments';

-- =====================================================================
-- Section 1: Insert 28 Condiment Products
-- =====================================================================
INSERT INTO products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean) 
VALUES
    -- Ketchups (4 products)
    ('PL', 'Heinz', 'Ketchup', 'Condiments', 'Tomato Ketchup', NULL, 'Biedronka, Carrefour, Lidl, Auchan', NULL, '8715700110004'),
    ('PL', 'Pudliszki', 'Ketchup', 'Condiments', 'Ketchup Łagodny', NULL, 'Biedronka, Żabka, Carrefour', NULL, '5900783002213'),
    ('PL', 'Develey', 'Ketchup', 'Condiments', 'Hot Tomato Ketchup', NULL, 'Lidl, Kaufland, Auchan', NULL, '4001743931503'),
    ('PL', 'Kotlin', 'Ketchup', 'Condiments', 'Ketchup Pikantny', NULL, 'Biedronka, Carrefour', NULL, '5901044006086'),

    -- Mustards (4 products)
    ('PL', 'Develey', 'Mustard', 'Condiments', 'Classic Yellow Mustard', NULL, 'Lidl, Kaufland, Auchan', NULL, '4001743930001'),
    ('PL', 'Heinz', 'Mustard', 'Condiments', 'Dijon Mustard', NULL, 'Carrefour, Auchan, Tesco', NULL, '8715700421001'),
    ('PL', 'Kühne', 'Mustard', 'Condiments', 'Wholegrain Mustard', NULL, 'Lidl, Carrefour, Auchan', NULL, '4012200039915'),
    ('PL', 'Kotlin', 'Mustard', 'Condiments', 'Honey Mustard', NULL, 'Biedronka, Żabka, Carrefour', NULL, '5901044006413'),

    -- Mayonnaise (4 products)
    ('PL', 'Winiary', 'Mayonnaise', 'Condiments', 'Majonez Dekoracyjny', NULL, 'Biedronka, Żabka, Carrefour, Lidl', NULL, '5900085005226'),
    ('PL', 'Kotlin', 'Mayonnaise', 'Condiments', 'Light Mayonnaise', NULL, 'Biedronka, Carrefour', NULL, '5901044006239'),
    ('PL', 'Develey', 'Mayonnaise', 'Condiments', 'Mayonnaise with Lemon', NULL, 'Lidl, Kaufland, Auchan', NULL, '4001743926509'),
    ('PL', 'Pudliszki', 'Mayonnaise', 'Condiments', 'Garlic Mayonnaise', NULL, 'Biedronka, Carrefour, Auchan', NULL, '5900783004217'),

    -- Hot Sauces (3 products)
    ('PL', 'Tabasco', 'Hot Sauce', 'Condiments', 'Original Red Sauce', NULL, 'Carrefour, Auchan, Tesco', NULL, '0011210003002'),
    ('PL', 'Lee Kum Kee', 'Hot Sauce', 'Condiments', 'Sriracha Chili Sauce', NULL, 'Carrefour, Auchan, Tesco', NULL, '0078895140514'),
    ('PL', 'Kamis', 'Hot Sauce', 'Condiments', 'Chili Sauce', NULL, 'Biedronka, Żabka, Carrefour, Lidl', NULL, '5900084231435'),

    -- Soy Sauce (2 products)
    ('PL', 'Lee Kum Kee', 'Soy Sauce', 'Condiments', 'Premium Soy Sauce', NULL, 'Carrefour, Auchan, Tesco', NULL, '0078895348026'),
    ('PL', 'Knorr', 'Soy Sauce', 'Condiments', 'Reduced Sodium Soy Sauce', NULL, 'Biedronka, Carrefour, Lidl', NULL, '8712100853456'),

    -- Vinegars (3 products)
    ('PL', 'Targroch', 'Vinegar', 'Condiments', 'White Wine Vinegar', NULL, 'Carrefour, Auchan, Tesco', NULL, '5903229004518'),
    ('PL', 'Łowicz', 'Vinegar', 'Condiments', 'Apple Cider Vinegar', NULL, 'Biedronka, Carrefour, Lidl', NULL, '5900437014326'),
    ('PL', 'Kühne', 'Vinegar', 'Condiments', 'Balsamic Vinegar of Modena', NULL, 'Lidl, Carrefour, Auchan', NULL, '4012200042014'),

    -- Pickles (4 products)
    ('PL', 'Kühne', 'Pickles', 'Condiments', 'Dill Pickles', NULL, 'Lidl, Carrefour, Auchan', NULL, '4012200039007'),
    ('PL', 'Łowicz', 'Pickles', 'Condiments', 'Gherkins', NULL, 'Biedronka, Carrefour, Lidl', NULL, '5900437006246'),
    ('PL', 'Pudliszki', 'Pickles', 'Condiments', 'Pickled Hot Peppers', NULL, 'Biedronka, Carrefour, Auchan', NULL, '5900783005214'),
    ('PL', 'Kotlin', 'Pickles', 'Condiments', 'Pickled Onions', NULL, 'Biedronka, Carrefour', NULL, '5901044007205'),

    -- Relishes & Spreads (4 products)
    ('PL', 'Kotlin', 'Relish', 'Condiments', 'Horseradish', NULL, 'Biedronka, Żabka, Carrefour, Lidl', NULL, '5901044007809'),
    ('PL', 'Pudliszki', 'Spread', 'Condiments', 'Ajvar Mild', NULL, 'Biedronka, Carrefour, Auchan', NULL, '5900783006518'),
    ('PL', 'Prymat', 'Spread', 'Condiments', 'Classic Hummus', NULL, 'Biedronka, Carrefour, Lidl', NULL, '5901135001526'),
    ('PL', 'Develey', 'Spread', 'Condiments', 'Basil Pesto', NULL, 'Lidl, Kaufland, Auchan', NULL, '4001743927506')

ON CONFLICT (country, brand, product_name)
DO UPDATE SET
  product_type        = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies,
  ean                 = excluded.ean;

-- =====================================================================
-- Section 2: Deprecate Removed Products
-- =====================================================================
-- Mark products that are no longer in the pipeline as deprecated
UPDATE products
SET is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
WHERE country='PL' AND category='Condiments'
  AND is_deprecated IS NOT TRUE
  AND product_name NOT IN (
    'Tomato Ketchup',
    'Ketchup Łagodny',
    'Hot Tomato Ketchup',
    'Ketchup Pikantny',
    'Classic Yellow Mustard',
    'Dijon Mustard',
    'Wholegrain Mustard',
    'Honey Mustard',
    'Majonez Dekoracyjny',
    'Light Mayonnaise',
    'Mayonnaise with Lemon',
    'Garlic Mayonnaise',
    'Original Red Sauce',
    'Sriracha Chili Sauce',
    'Chili Sauce',
    'Premium Soy Sauce',
    'Reduced Sodium Soy Sauce',
    'White Wine Vinegar',
    'Apple Cider Vinegar',
    'Balsamic Vinegar of Modena',
    'Dill Pickles',
    'Gherkins',
    'Pickled Hot Peppers',
    'Pickled Onions',
    'Horseradish',
    'Ajvar Mild',
    'Classic Hummus',
    'Basil Pesto'
  );

-- PIPELINE (CONDIMENTS): scoring updates
-- PIPELINE__condiments__04_scoring.sql
-- Formula-based v3.1 scoring (replaces v2.2 hardcoded placeholders)
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
--    (safety net — also covered by 00_ensure_scores.sql)
-- ═════════════════════════════════════════════════════════════════════════

INSERT INTO scores (product_id)
SELECT p.product_id
FROM products p
LEFT JOIN scores sc ON sc.product_id = p.product_id
WHERE p.country = 'PL' AND p.category = 'Condiments'
  AND p.is_deprecated IS NOT TRUE
  AND sc.product_id IS NULL;

INSERT INTO ingredients (product_id)
SELECT p.product_id
FROM products p
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.country = 'PL' AND p.category = 'Condiments'
  AND p.is_deprecated IS NOT TRUE
  AND i.product_id IS NULL;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

UPDATE ingredients i SET
  additives_count = d.cnt
FROM (
  VALUES
    -- brand,          product_name,                   cnt
    
    -- KETCHUPS: 2-3 additives (preservatives, citric acid, natural flavors)
    ('Heinz',         'Tomato Ketchup',               '3'),
    ('Pudliszki',     'Ketchup Łagodny',              '2'),
    ('Develey',       'Hot Tomato Ketchup',           '3'),
    ('Kotlin',        'Ketchup Pikantny',             '3'),
    
    -- MUSTARDS: 1-2 additives
    ('Develey',       'Classic Yellow Mustard',       '2'),
    ('Heinz',         'Dijon Mustard',                '1'),
    ('Kühne',         'Wholegrain Mustard',           '1'),
    ('Kotlin',        'Honey Mustard',                '2'),
    
    -- MAYONNAISE: 2-3 additives (emulsifiers, preservatives)
    ('Winiary',       'Majonez Dekoracyjny',          '3'),
    ('Kotlin',        'Light Mayonnaise',             '3'),
    ('Develey',       'Mayonnaise with Lemon',        '2'),
    ('Pudliszki',     'Garlic Mayonnaise',            '3'),
    
    -- HOT SAUCES: 2-3 additives (preservatives, thickeners)
    ('Tabasco',       'Original Red Sauce',           '2'),
    ('Lee Kum Kee',   'Sriracha Chili Sauce',         '3'),
    ('Kamis',         'Chili Sauce',                  '2'),
    
    -- SOY SAUCE: 1-2 additives
    ('Lee Kum Kee',   'Premium Soy Sauce',            '1'),
    ('Knorr',         'Reduced Sodium Soy Sauce',     '2'),
    
    -- VINEGARS: 0 additives (pure)
    ('Targroch',      'White Wine Vinegar',           '0'),
    ('Łowicz',        'Apple Cider Vinegar',          '0'),
    ('Kühne',         'Balsamic Vinegar of Modena',   '0'),
    
    -- PICKLES: 0-1 additives (preservatives)
    ('Kühne',         'Dill Pickles',                 '1'),
    ('Łowicz',        'Gherkins',                     '0'),
    ('Pudliszki',     'Pickled Hot Peppers',          '1'),
    ('Kotlin',        'Pickled Onions',               '1'),
    
    -- RELISHES & SPREADS: 1-4 additives (preservatives, citric acid, antioxidants)
    ('Kotlin',        'Horseradish',                  '1'),
    ('Pudliszki',     'Ajvar Mild',                   '2'),
    ('Prymat',        'Classic Hummus',               '3'),
    ('Develey',       'Basil Pesto',                  '4')
    
) AS d(brand, product_name, cnt)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
WHERE i.product_id = p.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. COMPUTE unhealthiness_score (v3.1 formula)
-- ═════════════════════════════════════════════════════════════════════════

UPDATE scores sc SET
  unhealthiness_score = compute_unhealthiness_v31(
      nf.saturated_fat_g::numeric,
      nf.sugars_g::numeric,
      nf.salt_g::numeric,
      nf.calories::numeric,
      nf.trans_fat_g::numeric,
      i.additives_count::numeric,
      p.prep_method,
      p.controversies
  )::text,
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
FROM products p
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.product_id = sc.product_id
  AND p.country = 'PL' AND p.category = 'Condiments'
  AND p.is_deprecated IS NOT TRUE;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

UPDATE scores sc SET
  nutri_score_label = d.ns
FROM (
  VALUES
    -- brand,          product_name,                   ns
    
    -- VINEGARS: B-C (low calories but minimal salt)
    ('Targroch',      'White Wine Vinegar',           'B'),
    ('Łowicz',        'Apple Cider Vinegar',          'B'),
    ('Kühne',         'Balsamic Vinegar of Modena',   'C'),
    
    -- HOT SAUCES: B-C (low calories but high salt)
    ('Tabasco',       'Original Red Sauce',           'B'),
    ('Lee Kum Kee',   'Sriracha Chili Sauce',         'C'),
    ('Kamis',         'Chili Sauce',                  'C'),
    
    -- PICKLES: B-C (low calories, high salt)
    ('Kühne',         'Dill Pickles',                 'C'),
    ('Łowicz',        'Gherkins',                     'B'),
    ('Pudliszki',     'Pickled Hot Peppers',          'C'),
    ('Kotlin',        'Pickled Onions',               'C'),
    
    -- MUSTARDS: C-D (high salt)
    ('Develey',       'Classic Yellow Mustard',       'C'),
    ('Heinz',         'Dijon Mustard',                'D'),
    ('Kühne',         'Wholegrain Mustard',           'D'),
    ('Kotlin',        'Honey Mustard',                'D'),
    
    -- KETCHUPS: C-D (high sugar + salt)
    ('Heinz',         'Tomato Ketchup',               'C'),
    ('Pudliszki',     'Ketchup Łagodny',              'C'),
    ('Develey',       'Hot Tomato Ketchup',           'D'),
    ('Kotlin',        'Ketchup Pikantny',             'D'),
    
    -- SOY SAUCE: C-D (high salt)
    ('Lee Kum Kee',   'Premium Soy Sauce',            'D'),
    ('Knorr',         'Reduced Sodium Soy Sauce',     'C'),
    
    -- SPREADS: C-D
    ('Kotlin',        'Horseradish',                  'C'),
    ('Pudliszki',     'Ajvar Mild',                   'C'),
    ('Prymat',        'Classic Hummus',               'D'),
    
    -- LIGHT MAYO: D (high fat but reduced)
    ('Kotlin',        'Light Mayonnaise',             'D'),
    
    -- REGULAR MAYO/AIOLI: E (very high fat)
    ('Winiary',       'Majonez Dekoracyjny',          'E'),
    ('Develey',       'Mayonnaise with Lemon',        'E'),
    ('Pudliszki',     'Garlic Mayonnaise',            'E'),
    
    -- PESTO: E (very high fat from oil/nuts)
    ('Develey',       'Basil Pesto',                  'E')
    
) AS d(brand, product_name, ns)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
WHERE p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
-- ═════════════════════════════════════════════════════════════════════════

UPDATE scores sc SET
  nova_classification = d.nova,
  processing_risk = CASE d.nova
    WHEN '4' THEN 'High'
    WHEN '3' THEN 'Moderate'
    ELSE 'Low'
  END
FROM (
  VALUES
    -- brand,          product_name,                   nova
    
    -- NOVA 1 (Low): Plain vinegars (unprocessed)
    ('Targroch',      'White Wine Vinegar',           '1'),
    ('Łowicz',        'Apple Cider Vinegar',          '1'),
    ('Kühne',         'Balsamic Vinegar of Modena',   '1'),
    
    -- NOVA 3 (Moderate): Simple pickles, basic mustards, horseradish
    ('Kühne',         'Dill Pickles',                 '3'),
    ('Łowicz',        'Gherkins',                     '3'),
    ('Pudliszki',     'Pickled Hot Peppers',          '3'),
    ('Kotlin',        'Pickled Onions',               '3'),
    ('Heinz',         'Dijon Mustard',                '3'),
    ('Kühne',         'Wholegrain Mustard',           '3'),
    ('Kotlin',        'Horseradish',                  '3'),
    ('Pudliszki',     'Ajvar Mild',                   '3'),
    
    -- NOVA 4 (High): Ketchups, flavored mayo, hot sauces with additives, hummus/pesto
    ('Heinz',         'Tomato Ketchup',               '4'),
    ('Pudliszki',     'Ketchup Łagodny',              '4'),
    ('Develey',       'Hot Tomato Ketchup',           '4'),
    ('Kotlin',        'Ketchup Pikantny',             '4'),
    ('Develey',       'Classic Yellow Mustard',       '4'),
    ('Kotlin',        'Honey Mustard',                '4'),
    ('Winiary',       'Majonez Dekoracyjny',          '4'),
    ('Kotlin',        'Light Mayonnaise',             '4'),
    ('Develey',       'Mayonnaise with Lemon',        '4'),
    ('Pudliszki',     'Garlic Mayonnaise',            '4'),
    ('Tabasco',       'Original Red Sauce',           '4'),
    ('Lee Kum Kee',   'Sriracha Chili Sauce',         '4'),
    ('Kamis',         'Chili Sauce',                  '4'),
    ('Lee Kum Kee',   'Premium Soy Sauce',            '4'),
    ('Knorr',         'Reduced Sodium Soy Sauce',     '4'),
    ('Prymat',        'Classic Hummus',               '4'),
    ('Develey',       'Basil Pesto',                  '4')
    
) AS d(brand, product_name, nova)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
WHERE p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
-- ═════════════════════════════════════════════════════════════════════════

UPDATE scores sc SET
  high_salt_flag = CASE WHEN nf.salt_g::numeric >= 1.5 THEN 'YES' ELSE 'NO' END,
  high_sugar_flag = CASE WHEN nf.sugars_g::numeric >= 5.0 THEN 'YES' ELSE 'NO' END,
  high_sat_fat_flag = CASE WHEN nf.saturated_fat_g::numeric >= 5.0 THEN 'YES' ELSE 'NO' END,
  high_additive_load = CASE WHEN COALESCE(i.additives_count::numeric, 0) >= 5 THEN 'YES' ELSE 'NO' END,
  data_completeness_pct = 100  -- all 8 scoring factors have real data
FROM products p
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.product_id = sc.product_id
  AND p.country = 'PL' AND p.category = 'Condiments'
  AND p.is_deprecated IS NOT TRUE;

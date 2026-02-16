-- ============================================================
-- Reference Data Seed — 001_reference_data.sql
-- ============================================================
-- Populates reference/lookup tables that are prerequisites for
-- the product data pipelines.
--
-- Safe to run repeatedly (all INSERTs use ON CONFLICT DO NOTHING
-- or ON CONFLICT DO UPDATE).
--
-- Run AFTER migrations have been applied, BEFORE product pipelines.
-- ============================================================

BEGIN;

-- ────────────────────────────────────────────────────────────
-- 1. country_ref
-- ────────────────────────────────────────────────────────────
INSERT INTO country_ref (country_code, country_name, native_name, currency_code, is_active, notes) VALUES
    ('PL', 'Poland',  'Polska',      'PLN', true,  'Primary market. Full dataset.'),
    ('DE', 'Germany', 'Deutschland', 'EUR', true,  'Micro-pilot: 51 Chips products.')
ON CONFLICT (country_code) DO UPDATE SET
    country_name  = EXCLUDED.country_name,
    native_name   = EXCLUDED.native_name,
    currency_code = EXCLUDED.currency_code,
    is_active     = EXCLUDED.is_active,
    notes         = EXCLUDED.notes;

-- ────────────────────────────────────────────────────────────
-- 2. category_ref
-- ────────────────────────────────────────────────────────────
INSERT INTO category_ref (category, slug, display_name, description, sort_order, icon_emoji, target_per_category) VALUES
    ('Alcohol',                    'alcohol',                   'Alcohol',                    'Beer, wine, spirits, and alcoholic beverages',              1,  '🍺', 28),
    ('Baby',                       'baby',                      'Baby Food',                  'Baby formula, purees, snacks, and child nutrition',         2,  '👶', 28),
    ('Bread',                      'bread',                     'Bread',                      'Bread loaves, rolls, and bakery products',                 3,  '🍞', 28),
    ('Breakfast & Grain-Based',    'breakfast-grain-based',     'Breakfast & Grain-Based',    'Granola, muesli, porridge, pancakes, and breakfast bars',   4,  '🥣', 28),
    ('Canned Goods',               'canned-goods',              'Canned Goods',               'Canned vegetables, beans, soups, and preserves',           5,  '🥫', 28),
    ('Cereals',                    'cereals',                   'Cereals',                    'Breakfast cereals, flakes, and puffed grains',              6,  '🥣', 28),
    ('Chips',                      'chips',                     'Chips',                      'Potato chips, crisps, and extruded snacks',                7,  '🍟', 28),
    ('Condiments',                 'condiments',                'Condiments',                 'Mustard, ketchup, mayonnaise, vinegar, and pickles',       8,  '🫙', 28),
    ('Dairy',                      'dairy',                     'Dairy',                      'Milk, yogurt, cheese, butter, and cream',                  9,  '🧀', 28),
    ('Drinks',                     'drinks',                    'Drinks',                     'Soft drinks, juices, energy drinks, and water',            10, '🥤', 28),
    ('Frozen & Prepared',          'frozen-prepared',           'Frozen & Prepared',          'Frozen meals, pizza, dumplings, and prepared foods',       11, '🧊', 28),
    ('Instant & Frozen',           'instant-frozen',            'Instant & Frozen',           'Instant noodles, soups, frozen convenience foods',         12, '🍜', 28),
    ('Meat',                       'meat',                      'Meat',                       'Fresh meat, deli, sausages, and cured meats',              13, '🥩', 28),
    ('Nuts, Seeds & Legumes',      'nuts-seeds-legumes',        'Nuts, Seeds & Legumes',      'Nuts, seeds, dried legumes, and nut butters',              14, '🥜', 28),
    ('Plant-Based & Alternatives', 'plant-based-alternatives',  'Plant-Based & Alternatives', 'Tofu, tempeh, plant milk, meat alternatives',             15, '🌱', 28),
    ('Sauces',                     'sauces',                    'Sauces',                     'Pasta sauces, cooking sauces, and dressings',              16, '🫗', 28),
    ('Seafood & Fish',             'seafood-fish',              'Seafood & Fish',             'Fresh fish, canned fish, seafood, and fish products',      17, '🐟', 28),
    ('Snacks',                     'snacks',                    'Snacks',                     'Crackers, pretzels, popcorn, and mixed snacks',            18, '🍿', 28),
    ('Sweets',                     'sweets',                    'Sweets',                     'Chocolate, candy, gummies, and confectionery',             19, '🍫', 28),
    ('Żabka',                      'zabka',                     'Żabka Convenience',          'Ready meals and snacks from Żabka convenience stores',    20, '🏪', 28)
ON CONFLICT (category) DO UPDATE SET
    slug                = EXCLUDED.slug,
    display_name        = EXCLUDED.display_name,
    description         = EXCLUDED.description,
    sort_order          = EXCLUDED.sort_order,
    icon_emoji          = EXCLUDED.icon_emoji,
    target_per_category = EXCLUDED.target_per_category;

-- ────────────────────────────────────────────────────────────
-- 3. nutri_score_ref
-- ────────────────────────────────────────────────────────────
INSERT INTO nutri_score_ref (label, display_name, description, color_hex, sort_order, score_range_min, score_range_max) VALUES
    ('A',              'Nutri-Score A', 'Highest nutritional quality',                     '#038141', 1, -15, -1),
    ('B',              'Nutri-Score B', 'Good nutritional quality',                        '#85BB2F', 2,   0,  2),
    ('C',              'Nutri-Score C', 'Average nutritional quality',                     '#FECB02', 3,   3, 10),
    ('D',              'Nutri-Score D', 'Below average nutritional quality',               '#EE8100', 4,  11, 18),
    ('E',              'Nutri-Score E', 'Lowest nutritional quality',                      '#E63E11', 5,  19, 40),
    ('UNKNOWN',        'Unknown',       'Nutri-Score could not be computed',               '#999999', 6, NULL, NULL),
    ('NOT-APPLICABLE', 'N/A',           'Product exempt from Nutri-Score (e.g. alcohol)',  '#CCCCCC', 7, NULL, NULL)
ON CONFLICT (label) DO UPDATE SET
    display_name    = EXCLUDED.display_name,
    description     = EXCLUDED.description,
    color_hex       = EXCLUDED.color_hex,
    sort_order      = EXCLUDED.sort_order,
    score_range_min = EXCLUDED.score_range_min,
    score_range_max = EXCLUDED.score_range_max;

-- ────────────────────────────────────────────────────────────
-- 4. concern_tier_ref
-- ────────────────────────────────────────────────────────────
INSERT INTO concern_tier_ref (tier, tier_name, description, score_impact, example_ingredients, efsa_guidance) VALUES
    (0, 'No concern',       'Generally recognized as safe; no adverse EFSA findings',
     'No penalty (0 points)', 'Water, salt, sugar, flour, olive oil, milk, eggs',
     'EFSA panel: no safety concerns at typical dietary levels'),
    (1, 'Low concern',      'Minor flags in literature; safe at normal intake levels',
     'Minimal penalty (+0.5 per ingredient)', 'Lecithins (E322), citric acid (E330), pectin (E440), ascorbic acid (E300)',
     'EFSA re-evaluation: acceptable daily intake established, no reduction needed'),
    (2, 'Moderate concern', 'EFSA has identified potential risks at high intake; ADI established',
     'Moderate penalty (+1.5 per ingredient)', 'Carrageenan (E407), sodium nitrite (E250), potassium sorbate (E202), BHA (E320)',
     'EFSA re-evaluation: ADI set; concerns at levels exceeding ADI in vulnerable populations'),
    (3, 'High concern',     'EFSA has flagged for re-evaluation or reduced ADI; avoid where possible',
     'High penalty (+3.0 per ingredient)', 'Titanium dioxide (E171), azodicarbonamide, partially hydrogenated oils',
     'EFSA 2021: E171 no longer considered safe as food additive; banned in EU from 2022')
ON CONFLICT (tier) DO UPDATE SET
    tier_name           = EXCLUDED.tier_name,
    description         = EXCLUDED.description,
    score_impact        = EXCLUDED.score_impact,
    example_ingredients = EXCLUDED.example_ingredients,
    efsa_guidance       = EXCLUDED.efsa_guidance;

COMMIT;

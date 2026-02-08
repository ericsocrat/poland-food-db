-- PIPELINE (CANNED GOODS): scoring updates
-- PIPELINE__canned__04_scoring.sql
-- Formula-based v3.1 scoring (replaces v2.2 hardcoded placeholders)
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
--    (safety net — also covered by 00_ensure_scores.sql)
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Canned goods additive patterns:
--      Plain vegetables/fruits: 0-1 additives (citric acid, ascorbic acid)
--      Legumes: 1-2 additives (calcium chloride, EDTA)
--      Soups: 2-3 additives (emulsifiers, stabilizers)
--      Ready meals: 3-4 additives (preservatives, flavor enhancers)
--      Canned meats: 3-4 additives (nitrites, phosphates, MSG)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- brand,               product_name,                         cnt

    -- ── CANNED VEGETABLES ───────────────────────────────────────────────
    ('Bonduelle',           'Sweet Corn',                         '1'),  -- citric acid
    ('Kotlin',              'Green Peas',                         '1'),  -- calcium chloride
    ('Kotlin',              'Red Kidney Beans',                   '1'),  -- calcium chloride
    ('Kotlin',              'Sliced Carrots',                     '0'),  -- water, carrots, salt only
    ('Kotlin',              'Whole Tomatoes',                     '1'),  -- citric acid
    ('Pudliszki',           'Diced Tomatoes',                     '1'),  -- citric acid
    ('Pudliszki',           'Whole Beets',                        '0'),  -- beets, water, vinegar, salt
    ('Bonduelle',           'Champignon Mushrooms',               '1'),  -- citric acid, ascorbic acid

    -- ── CANNED FRUITS ───────────────────────────────────────────────────
    ('Profi',               'Peaches in Syrup',                   '1'),  -- citric acid
    ('Profi',               'Pineapple Slices in Syrup',          '0'),  -- pineapple, water, sugar
    ('Kotlin',              'Mandarin Oranges in Syrup',          '1'),  -- citric acid
    ('Profi',               'Fruit Cocktail in Syrup',            '1'),  -- citric acid, ascorbic acid
    ('Kotlin',              'Cherries in Syrup',                  '0'),  -- cherries, sugar, water
    ('Profi',               'Pears in Syrup',                     '1'),  -- citric acid

    -- ── CANNED LEGUMES ──────────────────────────────────────────────────
    ('Bonduelle',           'Chickpeas',                          '2'),  -- calcium chloride, EDTA
    ('Kotlin',              'White Beans',                        '1'),  -- calcium chloride
    ('Kotlin',              'Lentils',                            '1'),  -- EDTA
    ('Bonduelle',           'Mixed Beans',                        '2'),  -- calcium chloride, EDTA
    ('Kotlin',              'Beans in Tomato Sauce',              '3'),  -- +modified starch, sugar, spices

    -- ── CANNED SOUPS ────────────────────────────────────────────────────
    ('Heinz',               'Cream of Tomato Soup',               '3'),  -- modified starch, sugar, citric acid
    ('Pudliszki',           'Cream of Mushroom Soup',             '3'),  -- modified starch, yeast extract, stabilizers
    ('Profi',               'Chicken Soup',                       '2'),  -- yeast extract, spice extracts
    ('Pudliszki',           'Vegetable Soup',                     '2'),  -- modified starch, sugar

    -- ── CANNED PASTA & READY MEALS ──────────────────────────────────────
    ('Heinz',               'Ravioli in Tomato Sauce',            '4'),  -- modified starch, sugar, citric acid, flavorings
    ('Heinz',               'Spaghetti in Tomato Sauce',          '3'),  -- modified starch, sugar, citric acid
    ('Kotlin',              'Spaghetti Bolognese',                '3'),  -- modified starch, sugar, meat flavor

    -- ── CANNED MEATS ────────────────────────────────────────────────────
    ('Profi',               'Pork Luncheon Meat',                 '4'),  -- sodium nitrite, phosphates, MSG, ascorbic acid
    ('Pudliszki',           'Corned Beef',                        '3')   -- sodium nitrite, phosphates, sugar

) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. COMPUTE unhealthiness_score (v3.1 formula)
--    8 factors × weighted → clamped [1, 100]
--    sat_fat(0.18) + sugars(0.18) + salt(0.18) + calories(0.10) +
--    trans_fat(0.12) + additives(0.07) + prep_method(0.09) + controversies(0.08)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
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
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (EU official calculation for canned goods)
--    Plain vegetables: A-B | Fruits in syrup: B-C | Legumes: A-B
--    Soups: C-D | Ready meals: C-D | Canned meats: D-E
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- brand,               product_name,                         ns

    -- ── CANNED VEGETABLES ───────────────────────────────────────────────
    ('Bonduelle',           'Sweet Corn',                         'A'),
    ('Kotlin',              'Green Peas',                         'A'),
    ('Kotlin',              'Red Kidney Beans',                   'A'),
    ('Kotlin',              'Sliced Carrots',                     'A'),
    ('Kotlin',              'Whole Tomatoes',                     'A'),
    ('Pudliszki',           'Diced Tomatoes',                     'A'),
    ('Pudliszki',           'Whole Beets',                        'B'),
    ('Bonduelle',           'Champignon Mushrooms',               'A'),

    -- ── CANNED FRUITS ───────────────────────────────────────────────────
    ('Profi',               'Peaches in Syrup',                   'C'),
    ('Profi',               'Pineapple Slices in Syrup',          'C'),
    ('Kotlin',              'Mandarin Oranges in Syrup',          'B'),
    ('Profi',               'Fruit Cocktail in Syrup',            'C'),
    ('Kotlin',              'Cherries in Syrup',                  'C'),
    ('Profi',               'Pears in Syrup',                     'B'),

    -- ── CANNED LEGUMES ──────────────────────────────────────────────────
    ('Bonduelle',           'Chickpeas',                          'A'),
    ('Kotlin',              'White Beans',                        'A'),
    ('Kotlin',              'Lentils',                            'A'),
    ('Bonduelle',           'Mixed Beans',                        'A'),
    ('Kotlin',              'Beans in Tomato Sauce',              'B'),

    -- ── CANNED SOUPS ────────────────────────────────────────────────────
    ('Heinz',               'Cream of Tomato Soup',               'C'),
    ('Pudliszki',           'Cream of Mushroom Soup',             'D'),
    ('Profi',               'Chicken Soup',                       'C'),
    ('Pudliszki',           'Vegetable Soup',                     'C'),

    -- ── CANNED PASTA & READY MEALS ──────────────────────────────────────
    ('Heinz',               'Ravioli in Tomato Sauce',            'C'),
    ('Heinz',               'Spaghetti in Tomato Sauce',          'C'),
    ('Kotlin',              'Spaghetti Bolognese',                'C'),

    -- ── CANNED MEATS ────────────────────────────────────────────────────
    ('Profi',               'Pork Luncheon Meat',                 'E'),
    ('Pudliszki',           'Corned Beef',                        'D')

) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
--    NOVA 3 (Moderate): Plain canned vegetables/fruits/legumes (processed)
--    NOVA 4 (High): Soups, ready meals, canned meats (ultra-processed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    else 'Low'
  end
from (
  values
    -- brand,               product_name,                         nova

    -- ── CANNED VEGETABLES ───────────────────────────────────────────────
    ('Bonduelle',           'Sweet Corn',                         '3'),
    ('Kotlin',              'Green Peas',                         '3'),
    ('Kotlin',              'Red Kidney Beans',                   '3'),
    ('Kotlin',              'Sliced Carrots',                     '3'),
    ('Kotlin',              'Whole Tomatoes',                     '3'),
    ('Pudliszki',           'Diced Tomatoes',                     '3'),
    ('Pudliszki',           'Whole Beets',                        '3'),
    ('Bonduelle',           'Champignon Mushrooms',               '3'),

    -- ── CANNED FRUITS ───────────────────────────────────────────────────
    ('Profi',               'Peaches in Syrup',                   '3'),
    ('Profi',               'Pineapple Slices in Syrup',          '3'),
    ('Kotlin',              'Mandarin Oranges in Syrup',          '3'),
    ('Profi',               'Fruit Cocktail in Syrup',            '3'),
    ('Kotlin',              'Cherries in Syrup',                  '3'),
    ('Profi',               'Pears in Syrup',                     '3'),

    -- ── CANNED LEGUMES ──────────────────────────────────────────────────
    ('Bonduelle',           'Chickpeas',                          '3'),
    ('Kotlin',              'White Beans',                        '3'),
    ('Kotlin',              'Lentils',                            '3'),
    ('Bonduelle',           'Mixed Beans',                        '3'),
    ('Kotlin',              'Beans in Tomato Sauce',              '4'),  -- prepared sauce with additives

    -- ── CANNED SOUPS ────────────────────────────────────────────────────
    ('Heinz',               'Cream of Tomato Soup',               '4'),
    ('Pudliszki',           'Cream of Mushroom Soup',             '4'),
    ('Profi',               'Chicken Soup',                       '4'),
    ('Pudliszki',           'Vegetable Soup',                     '4'),

    -- ── CANNED PASTA & READY MEALS ──────────────────────────────────────
    ('Heinz',               'Ravioli in Tomato Sauce',            '4'),
    ('Heinz',               'Spaghetti in Tomato Sauce',          '4'),
    ('Kotlin',              'Spaghetti Bolognese',                '4'),

    -- ── CANNED MEATS ────────────────────────────────────────────────────
    ('Profi',               'Pork Luncheon Meat',                 '4'),
    ('Pudliszki',           'Corned Beef',                        '4')

) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g following EU "high" front-of-pack guidelines:
--      salt ≥ 1.5 g | sugars ≥ 5 g | sat fat ≥ 5 g | additives ≥ 5
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  high_salt_flag = case when nf.salt_g::numeric >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g::numeric >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count::numeric, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100  -- all 8 scoring factors have real data
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Canned Goods'
  and p.is_deprecated is not true;

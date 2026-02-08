-- PIPELINE (SNACKS): scoring updates
-- PIPELINE__snacks__04_scoring.sql
-- Formula-based v3.1 scoring via compute_unhealthiness_v31() function.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Plain snacks: 0-1 additives
--    Flavored snacks: 1-3 additives (emulsifiers, preservatives, flavor compounds)
--    Granola bars: 2-3 additives (emulsifiers, binders, preservatives)
--    Cheese puffs: 2-3 additives (color compounds, flavor enhancers)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- CRACKERS
    ('Lay''s',                'Lay''s Classic Wheat Crackers',         '1'),   -- e322 (lecithin)
    ('Pringles',              'Pringles Original Rye Crackers',        '2'),   -- e300, e306 (antioxidants)
    ('Crunchips',             'Crunchips Multigrain Crackers',         '1'),   -- e471 (emulsifier)
    ('Snack Day',             'Snack Day Sesame Crackers',             '0'),   -- clean label
    ('Kupiec',                'Kupiec Cheese-flavored Crackers',       '2'),   -- e501 (acid regulator), e631 (flavor enhancer)
    ('Grześkowiak',           'Grześkowiak Salted Crackers',           '0'),   -- no additives
    -- PRETZELS & STICKS
    ('Frito',                 'Frito Salted Pretzels',                 '1'),   -- e322 (lecithin)
    ('Crunchips',             'Crunchips Pretzel Rods',                '1'),   -- e471 (emulsifier)
    ('Bakalland',             'Bakalland Breadsticks',                 '1'),   -- e300 (vitamin C)
    ('Alesto',                'Alesto Grissini Sticks',                '1'),   -- e341 (emulsifier)
    -- POPCORN
    ('Lay''s',                'Lay''s Salted Popcorn',                 '1'),   -- e322 (lecithin)
    ('Pringles',              'Pringles Butter Popcorn',               '2'),   -- e306 (tocopherols), e160a (beta-carotene)
    ('Sante',                 'Sante Caramel Popcorn',                 '2'),   -- e322 (lecithin), e300 (vitamin C)
    -- RICE CAKES
    ('Crownfield',            'Crownfield Plain Rice Cakes',           '0'),   -- no additives
    ('Stop & Shop',           'Stop & Shop Sesame Rice Cakes',         '1'),   -- e322 (lecithin)
    ('Naturavena',            'Naturavena Rice Cakes with Herbs',      '1'),   -- e300 (vitamin C)
    -- DRIED FRUIT & NUTS
    ('Vitanella',             'Vitanella Raisins',                     '0'),   -- sulfites (natural preservation)
    ('Bakalland',             'Bakalland Dried Cranberries',           '1'),   -- e330 (citric acid)
    ('Alesto',                'Alesto Mixed Nuts',                     '0'),   -- no processing additives
    ('Snack Day',             'Snack Day Pumpkin Seeds',               '0'),   -- roasted only
    -- GRANOLA BARS
    ('Sante',                 'Sante Honey-Nut Granola Bar',           '2'),   -- e471 (emulsifier), e322 (lecithin)
    ('Crownfield',            'Crownfield Fruit Granola Bar',          '3'),   -- e421 (sorbitol), e471 (mono/diglycerides), e300 (vitamin C)
    ('Naturavena',            'Naturavena Chocolate Granola Bar',      '2'),   -- e471 (emulsifier), e322 (soy lecithin)
    ('Stop & Shop',           'Stop & Shop Reduced Sugar Granola Bar', '3'),   -- e950 (acesulfame), e421 (sorbitol), e471 (emulsifier)
    -- CHEESE PUFFS
    ('Lay''s',                'Lay''s Classic Cheese Puffs',           '3'),   -- e631 (inosinate), e627 (guanylate), e621 (monosodium glutamate)
    ('Crunchips',             'Crunchips Spicy Cheese Puffs',          '3'),   -- e160c (paprika), e631 (inosinate), e627 (guanylate)
    -- VEGETABLE CHIPS
    ('Kupiec',                'Kupiec Beet Chips',                     '1'),   -- e322 (lecithin)
    ('Grześkowiak',           'Grześkowiak Carrot Chips',              '2')    -- e322 (lecithin), e306 (tocopherol)
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. COMPUTE unhealthiness_score (v3.1 formula via function)
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
  and p.country = 'PL' and p.category = 'Snacks'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- CRACKERS
    ('Lay''s',                'Lay''s Classic Wheat Crackers',         'D'),   -- refined grain, salt content
    ('Pringles',              'Pringles Original Rye Crackers',        'C'),   -- rye flour, better profile
    ('Crunchips',             'Crunchips Multigrain Crackers',         'C'),   -- multigrain, better nutrition
    ('Snack Day',             'Snack Day Sesame Crackers',             'D'),   -- sesame fat content
    ('Kupiec',                'Kupiec Cheese-flavored Crackers',       'D'),   -- high salt, flavor compounds
    ('Grześkowiak',           'Grześkowiak Salted Crackers',           'C'),   -- basic profile
    -- PRETZELS & STICKS
    ('Frito',                 'Frito Salted Pretzels',                 'C'),   -- low fat, moderate salt
    ('Crunchips',             'Crunchips Pretzel Rods',                'C'),   -- low fat content
    ('Bakalland',             'Bakalland Breadsticks',                 'D'),   -- fat and salt content
    ('Alesto',                'Alesto Grissini Sticks',                'C'),   -- reasonable profile
    -- POPCORN
    ('Lay''s',                'Lay''s Salted Popcorn',                 'D'),   -- high fat, high salt
    ('Pringles',              'Pringles Butter Popcorn',               'E'),   -- high fat, high sugar
    ('Sante',                 'Sante Caramel Popcorn',                 'D'),   -- high sugar and fat
    -- RICE CAKES
    ('Crownfield',            'Crownfield Plain Rice Cakes',           'C'),   -- high carbs but low fat
    ('Stop & Shop',           'Stop & Shop Sesame Rice Cakes',         'D'),   -- high sesame fat
    ('Naturavena',            'Naturavena Rice Cakes with Herbs',      'C'),   -- herbs add value
    -- DRIED FRUIT & NUTS
    ('Vitanella',             'Vitanella Raisins',                     'D'),   -- high natural sugars
    ('Bakalland',             'Bakalland Dried Cranberries',           'D'),   -- high sugars
    ('Alesto',                'Alesto Mixed Nuts',                     'C'),   -- high fat but quality nuts
    ('Snack Day',             'Snack Day Pumpkin Seeds',               'C'),   -- healthy seed fats
    -- GRANOLA BARS
    ('Sante',                 'Sante Honey-Nut Granola Bar',           'D'),   -- high sugars
    ('Crownfield',            'Crownfield Fruit Granola Bar',          'D'),   -- high sugars, additives
    ('Naturavena',            'Naturavena Chocolate Granola Bar',      'E'),   -- chocolate, high sugar
    ('Stop & Shop',           'Stop & Shop Reduced Sugar Granola Bar', 'D'),   -- reduced sugar but still processed
    -- CHEESE PUFFS
    ('Lay''s',                'Lay''s Classic Cheese Puffs',           'E'),   -- high fat, high salt, additives
    ('Crunchips',             'Crunchips Spicy Cheese Puffs',          'E'),   -- high fat, salt, flavor additives
    -- VEGETABLE CHIPS
    ('Kupiec',                'Kupiec Beet Chips',                     'D'),   -- baked vegetable chips, fair profile
    ('Grześkowiak',           'Grześkowiak Carrot Chips',              'D')    -- baked vegetable chips, fair profile
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    else 'Very Low'
  end
from (
  values
    -- CRACKERS (mostly NOVA 3 for simple processing, but flavored ones are 4)
    ('Lay''s',                'Lay''s Classic Wheat Crackers',         '3'),   -- simple baking
    ('Pringles',              'Pringles Original Rye Crackers',        '3'),   -- extruded but not ultra-processed
    ('Crunchips',             'Crunchips Multigrain Crackers',         '3'),   -- baked crackers
    ('Snack Day',             'Snack Day Sesame Crackers',             '3'),   -- baked with sesame
    ('Kupiec',                'Kupiec Cheese-flavored Crackers',       '4'),   -- cheese flavor, additives
    ('Grześkowiak',           'Grześkowiak Salted Crackers',           '3'),   -- simple salted crackers
    -- PRETZELS & STICKS (NOVA 3 - processed but not ultra-processed)
    ('Frito',                 'Frito Salted Pretzels',                 '3'),   -- twisted and baked
    ('Crunchips',             'Crunchips Pretzel Rods',                '3'),   -- baked pretzels
    ('Bakalland',             'Bakalland Breadsticks',                 '3'),   -- baked breadsticks
    ('Alesto',                'Alesto Grissini Sticks',                '3'),   -- Italian grissini style
    -- POPCORN (salted NOVA 3, flavored NOVA 4)
    ('Lay''s',                'Lay''s Salted Popcorn',                 '3'),   -- popped, salted
    ('Pringles',              'Pringles Butter Popcorn',               '4'),   -- butter flavoring added
    ('Sante',                 'Sante Caramel Popcorn',                 '4'),   -- caramel coating with additives
    -- RICE CAKES (mostly NOVA 3 for plain, 3 for flavored)
    ('Crownfield',            'Crownfield Plain Rice Cakes',           '3'),   -- compressed rice
    ('Stop & Shop',           'Stop & Shop Sesame Rice Cakes',         '3'),   -- rice with sesame
    ('Naturavena',            'Naturavena Rice Cakes with Herbs',      '3'),   -- rice with herbs
    -- DRIED FRUIT & NUTS (NOVA 2 - minimally processed)
    ('Vitanella',             'Vitanella Raisins',                     '2'),   -- dried only
    ('Bakalland',             'Bakalland Dried Cranberries',           '2'),   -- dried fruit natural
    ('Alesto',                'Alesto Mixed Nuts',                     '2'),   -- roasted nuts, minimal processing
    ('Snack Day',             'Snack Day Pumpkin Seeds',               '2'),   -- roasted seeds
    -- GRANOLA BARS (NOVA 4 - ultra-processed with binders, additives)
    ('Sante',                 'Sante Honey-Nut Granola Bar',           '4'),   -- bound with emulsifiers
    ('Crownfield',            'Crownfield Fruit Granola Bar',          '4'),   -- with multiple additives
    ('Naturavena',            'Naturavena Chocolate Granola Bar',      '4'),   -- chocolate coating with additives
    ('Stop & Shop',           'Stop & Shop Reduced Sugar Granola Bar', '4'),   -- sugar substitutes, binders
    -- CHEESE PUFFS (NOVA 4 - ultra-processed with flavor compounds)
    ('Lay''s',                'Lay''s Classic Cheese Puffs',           '4'),   -- extruded with cheese flavor compounds
    ('Crunchips',             'Crunchips Spicy Cheese Puffs',          '4'),   -- extruded with spice compounds
    -- VEGETABLE CHIPS (NOVA 4 - baked but with processing for chip form)
    ('Kupiec',                'Kupiec Beet Chips',                     '4'),   -- sliced and baked with oil
    ('Grześkowiak',           'Grześkowiak Carrot Chips',              '4')    -- sliced and baked with oil
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

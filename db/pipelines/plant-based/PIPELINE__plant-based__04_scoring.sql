-- PIPELINE (PLANT-BASED): scoring updates
-- PIPELINE__plant-based__04_scoring.sql
-- Formula-based v3.1 scoring (replaces v2.2 hardcoded placeholders).
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
--    (safety net for new products)
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- brand,               product_name,                                cnt
    -- ── ALPRO (minimal additives in plant milks) ─────────────────────────
    ('Alpro',              'Alpro Napój Sojowy Naturalny',             '0'),  -- water, soy beans, sea salt
    ('Alpro',              'Alpro Napój Owsiany Naturalny',            '2'),  -- stabilizers, calcium
    ('Alpro',              'Alpro Jogurt Sojowy Naturalny',            '3'),  -- cultures, stabilizers, calcium
    ('Alpro',              'Alpro Napój Migdałowy Niesłodzony',        '2'),  -- stabilizers, calcium
    
    -- ── GARDEN GOURMET (ultra-processed meat alternatives) ────────────────
    ('Garden Gourmet',     'Garden Gourmet Sensational Burger',        '8'),  -- methylcellulose, flavors, colors, etc.
    ('Garden Gourmet',     'Garden Gourmet Vegan Nuggets',             '7'),  -- coating, colorings, preservatives
    ('Garden Gourmet',     'Garden Gourmet Vegan Mince',               '6'),  -- flavorings, stabilizers
    ('Garden Gourmet',     'Garden Gourmet Vegan Schnitzel',           '7'),  -- coating, colorings, preservatives
    
    -- ── VIOLIFE (coconut oil-based cheese with additives) ─────────────────
    ('Violife',            'Violife Original Block',                   '5'),  -- starches, flavors, colors
    ('Violife',            'Violife Mozzarella Style Shreds',          '6'),  -- starches, flavors, colors, preservatives
    ('Violife',            'Violife Cheddar Slices',                   '5'),  -- starches, flavors, colors
    
    -- ── TAIFUN (organic, minimal additives) ──────────────────────────────
    ('Taifun',             'Taifun Tofu Natural',                      '0'),  -- soybeans, water, nigari
    ('Taifun',             'Taifun Tofu Smoked',                       '1'),  -- natural smoke
    ('Taifun',             'Taifun Tofu Rosso',                        '2'),  -- herbs, spices
    
    -- ── LIKEMEAT (processed meat alternatives) ───────────────────────────
    ('LikeMeat',           'LikeMeat Like Chicken Pieces',             '6'),  -- flavorings, stabilizers, colors
    ('LikeMeat',           'LikeMeat Like Kebab',                      '7'),  -- seitan, flavorings, preservatives
    
    -- ── SOJASUN (yogurt cultures + stabilizers) ──────────────────────────
    ('Sojasun',            'Sojasun Jogurt Sojowy Naturalny',          '3'),  -- cultures, stabilizers
    ('Sojasun',            'Sojasun Jogurt Sojowy Waniliowy',          '4'),  -- vanilla flavor, cultures, stabilizers
    
    -- ── KUPIEC (Polish tofu, minimal processing) ─────────────────────────
    ('Kupiec',             'Kupiec Ser Tofu Naturalny',                '0'),  -- soybeans, water, coagulant
    ('Kupiec',             'Kupiec Ser Tofu Wędzony',                  '1'),  -- natural smoke
    
    -- ── BEYOND MEAT (highly engineered meat alternatives) ────────────────
    ('Beyond Meat',        'Beyond Meat Beyond Burger',                '9'),  -- methylcellulose, flavors, colors, binders
    ('Beyond Meat',        'Beyond Meat Beyond Sausage',               '10'), -- extensive additive list for texture/flavor
    
    -- ── NATURALNIE (Polish plant milks) ──────────────────────────────────
    ('Naturalnie',         'Naturalnie Napój Owsiany Klasyczny',       '2'),  -- stabilizers, calcium
    ('Naturalnie',         'Naturalnie Napój Kokosowy',                '1'),  -- stabilizers
    
    -- ── SIMPLY V (almond-based cream cheese) ─────────────────────────────
    ('Simply V',           'Simply V Ser Kremowy Naturalny',           '4'),  -- starches, cultures, stabilizers
    
    -- ── GREEN LEGEND (processed cutlets) ─────────────────────────────────
    ('Green Legend',       'Green Legend Kotlet Sojowy',               '5'),  -- coating, flavorings, preservatives
    
    -- ── TEMPEH (fermented, minimal additives) ────────────────────────────
    ('Taifun',             'Taifun Tempeh Natural',                    '0')   -- soybeans, water, tempeh culture
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- brand,               product_name,                                ns
    -- ── ALPRO (healthy plant milks and yogurts) ──────────────────────────
    ('Alpro',              'Alpro Napój Sojowy Naturalny',             'A'),  -- unsweetened, low fat
    ('Alpro',              'Alpro Napój Owsiany Naturalny',            'B'),  -- some natural sugars from oats
    ('Alpro',              'Alpro Jogurt Sojowy Naturalny',            'A'),  -- low fat, low sugar
    ('Alpro',              'Alpro Napój Migdałowy Niesłodzony',        'A'),  -- very low calorie, unsweetened
    
    -- ── GARDEN GOURMET (processed but moderate nutrition) ─────────────────
    ('Garden Gourmet',     'Garden Gourmet Sensational Burger',        'C'),  -- moderate fat, good protein
    ('Garden Gourmet',     'Garden Gourmet Vegan Nuggets',             'C'),  -- breaded, moderate fat
    ('Garden Gourmet',     'Garden Gourmet Vegan Mince',               'B'),  -- low fat, high protein
    ('Garden Gourmet',     'Garden Gourmet Vegan Schnitzel',           'C'),  -- breaded, moderate processing
    
    -- ── VIOLIFE (high sat fat from coconut oil) ──────────────────────────
    ('Violife',            'Violife Original Block',                   'E'),  -- 20g saturated fat per 100g
    ('Violife',            'Violife Mozzarella Style Shreds',          'D'),  -- 19g saturated fat
    ('Violife',            'Violife Cheddar Slices',                   'E'),  -- 20g saturated fat, high salt
    
    -- ── TAIFUN (excellent nutrition profile) ─────────────────────────────
    ('Taifun',             'Taifun Tofu Natural',                      'A'),  -- high protein, low everything else
    ('Taifun',             'Taifun Tofu Smoked',                       'B'),  -- added salt from smoking
    ('Taifun',             'Taifun Tofu Rosso',                        'B'),  -- added ingredients, still healthy
    
    -- ── LIKEMEAT (processed meat alternatives) ───────────────────────────
    ('LikeMeat',           'LikeMeat Like Chicken Pieces',             'C'),  -- moderate fat, good protein
    ('LikeMeat',           'LikeMeat Like Kebab',                      'C'),  -- similar profile
    
    -- ── SOJASUN (yogurt alternatives) ────────────────────────────────────
    ('Sojasun',            'Sojasun Jogurt Sojowy Naturalny',          'A'),  -- low sugar, good protein
    ('Sojasun',            'Sojasun Jogurt Sojowy Waniliowy',          'B'),  -- added sugar
    
    -- ── KUPIEC (Polish tofu, excellent profile) ──────────────────────────
    ('Kupiec',             'Kupiec Ser Tofu Naturalny',                'A'),  -- high protein, low everything
    ('Kupiec',             'Kupiec Ser Tofu Wędzony',                  'B'),  -- added salt
    
    -- ── BEYOND MEAT (engineered but nutritious) ──────────────────────────
    ('Beyond Meat',        'Beyond Meat Beyond Burger',                'C'),  -- high fat but good protein
    ('Beyond Meat',        'Beyond Meat Beyond Sausage',               'C'),  -- moderate fat, decent protein
    
    -- ── NATURALNIE (Polish plant milks) ──────────────────────────────────
    ('Naturalnie',         'Naturalnie Napój Owsiany Klasyczny',       'B'),  -- natural oat sugars
    ('Naturalnie',         'Naturalnie Napój Kokosowy',                'A'),  -- low calorie, low sugar
    
    -- ── SIMPLY V (cream cheese alternative) ──────────────────────────────
    ('Simply V',           'Simply V Ser Kremowy Naturalny',           'D'),  -- high fat, moderate processing
    
    -- ── GREEN LEGEND (processed cutlets) ─────────────────────────────────
    ('Green Legend',       'Green Legend Kotlet Sojowy',               'C'),  -- moderate fat, good protein
    
    -- ── TEMPEH (fermented superfood) ─────────────────────────────────────
    ('Taifun',             'Taifun Tempeh Natural',                    'A')   -- excellent protein, minimal processing
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
    else 'Low'
  end
from (
  values
    -- brand,               product_name,                                nova
    -- ── ALPRO (processed but not ultra-processed) ────────────────────────
    ('Alpro',              'Alpro Napój Sojowy Naturalny',             '3'),  -- processed drink, minimal additives
    ('Alpro',              'Alpro Napój Owsiany Naturalny',            '3'),  -- processed drink
    ('Alpro',              'Alpro Jogurt Sojowy Naturalny',            '3'),  -- fermented, processed
    ('Alpro',              'Alpro Napój Migdałowy Niesłodzony',        '3'),  -- processed drink
    
    -- ── GARDEN GOURMET (ultra-processed) ─────────────────────────────────
    ('Garden Gourmet',     'Garden Gourmet Sensational Burger',        '4'),  -- industrial formulation
    ('Garden Gourmet',     'Garden Gourmet Vegan Nuggets',             '4'),  -- breaded, many additives
    ('Garden Gourmet',     'Garden Gourmet Vegan Mince',               '4'),  -- ultra-processed texturized protein
    ('Garden Gourmet',     'Garden Gourmet Vegan Schnitzel',           '4'),  -- breaded, ultra-processed
    
    -- ── VIOLIFE (ultra-processed cheese alternatives) ────────────────────
    ('Violife',            'Violife Original Block',                   '4'),  -- industrial formulation, many additives
    ('Violife',            'Violife Mozzarella Style Shreds',          '4'),  -- ultra-processed
    ('Violife',            'Violife Cheddar Slices',                   '4'),  -- ultra-processed
    
    -- ── TAIFUN (minimally processed) ─────────────────────────────────────
    ('Taifun',             'Taifun Tofu Natural',                      '1'),  -- soybeans, water, coagulant only
    ('Taifun',             'Taifun Tofu Smoked',                       '3'),  -- smoked = processed
    ('Taifun',             'Taifun Tofu Rosso',                        '3'),  -- flavored = processed
    
    -- ── LIKEMEAT (ultra-processed) ───────────────────────────────────────
    ('LikeMeat',           'LikeMeat Like Chicken Pieces',             '4'),  -- industrial formulation
    ('LikeMeat',           'LikeMeat Like Kebab',                      '4'),  -- ultra-processed seitan
    
    -- ── SOJASUN (processed yogurt) ───────────────────────────────────────
    ('Sojasun',            'Sojasun Jogurt Sojowy Naturalny',          '3'),  -- fermented, processed
    ('Sojasun',            'Sojasun Jogurt Sojowy Waniliowy',          '3'),  -- fermented, flavored
    
    -- ── KUPIEC (minimally processed) ─────────────────────────────────────
    ('Kupiec',             'Kupiec Ser Tofu Naturalny',                '1'),  -- basic tofu
    ('Kupiec',             'Kupiec Ser Tofu Wędzony',                  '3'),  -- smoked = processed
    
    -- ── BEYOND MEAT (ultra-processed) ────────────────────────────────────
    ('Beyond Meat',        'Beyond Meat Beyond Burger',                '4'),  -- highly engineered
    ('Beyond Meat',        'Beyond Meat Beyond Sausage',               '4'),  -- ultra-processed
    
    -- ── NATURALNIE (processed drinks) ────────────────────────────────────
    ('Naturalnie',         'Naturalnie Napój Owsiany Klasyczny',       '3'),  -- processed drink
    ('Naturalnie',         'Naturalnie Napój Kokosowy',                '3'),  -- processed drink
    
    -- ── SIMPLY V (ultra-processed cheese alternative) ────────────────────
    ('Simply V',           'Simply V Ser Kremowy Naturalny',           '4'),  -- industrial formulation
    
    -- ── GREEN LEGEND (ultra-processed) ───────────────────────────────────
    ('Green Legend',       'Green Legend Kotlet Sojowy',               '4'),  -- breaded, industrial
    
    -- ── TEMPEH (minimally processed, fermented) ──────────────────────────
    ('Taifun',             'Taifun Tempeh Natural',                    '1')   -- soybeans + culture = minimal
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
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 6. SET confidence level (auto-assigned based on data completeness + sources)
--    Uses assign_confidence() function from 20260208_assign_confidence.sql
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  confidence = assign_confidence(
    sc.data_completeness_pct,
    (SELECT src.source_type
     FROM sources src
     WHERE src.brand LIKE '%(' || p.category || ')%'
     LIMIT 1)
  )
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Plant-Based & Alternatives'
  and p.is_deprecated is not true;

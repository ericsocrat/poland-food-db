-- PIPELINE (INSTANT & FROZEN): scoring updates
-- PIPELINE__instant__04_scoring.sql
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
where p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Instant products tend to have many additives (MSG, flavour enhancers).
--    Frozen pierogi are often clean-label.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- INSTANT NOODLES / SOUPS
    ('Knorr',           'Knorr Nudle Pomidorowe Pikantne',      '6'),   -- e100, e14xx, e392, e621, e627, e631
    ('Knorr',           'Knorr Nudle Pieczony Kurczak',         '6'),   -- e100, e14xx, e392, e621, e627, e631
    ('Knorr',           'Knorr Nudle Ser w Ziołach',            '6'),   -- e100, e14xx, e330, e621, e627, e631
    ('Amino',           'Amino Barszcz Czerwony',               '5'),   -- e14xx, e330, e621, e627, e631
    ('Amino',           'Amino Rosół z Makaronem',              '9'),   -- e14xx, e150c, e304, e306, e330, e392, e621, e627, e631
    ('Amino',           'Amino Żurek po Śląsku',                '5'),   -- e14xx, e330, e621, e627, e631
    ('Vifon',           'Vifon Kurczak Złocisty',               '7'),   -- e150c, e330, e412, e551, e621, e627, e631
    -- FROZEN PIZZA
    ('Iglotex',         'Iglotex Pizza Kurczak ze Szpinakiem',   '3'),   -- e14xx, e300, e440
    ('Iglotex',         'Iglotex Pizza Cztery Sery',             '3'),   -- e14xx, e300, e440
    ('Iglotex',         'Iglotex Pizza Szynka z Pieczarkami',    '5'),   -- e14xx, e250, e300, e301, e331
    ('Iglotex',         'Iglotex Pizza z Szynką Wieprzową',      '8'),   -- e160b, e202, e250, e300, e301, e331, e451, e452
    ('Dr. Oetker',      'Guseppe Pizza Quattro Formaggi',        '2'),   -- e472e, e300
    ('Proste Historie', 'Proste Historie Pizza Warzywna',        '3'),   -- e14xx, e160a, e300
    ('Dr. Oetker',      'Feliciana Pizza Prosciutto e Funghi',   '10'),  -- e14xx, e160a, e160c, e202, e250, e300, e301, e331, e412, e621
    -- FROZEN PIEROGI
    ('Swojska Chata',   'Swojska Chata Pierogi Ruskie',          '1'),   -- e202 (potassium sorbate)
    ('Nasze Smaki',     'Nasze Smaki Pierogi Ruskie z Cebulką',  '0'),   -- clean label
    ('Virtu',           'Virtu Pierogi Ruskie',                  '0'),   -- clean label
    ('Virtu',           'Virtu Pierogi z Kapustą i Grzybami',    '0'),   -- clean label
    ('Virtu',           'Virtu Pierogi z Serem',                 '1'),   -- e202
    ('Virtu',           'Virtu Pierogi z Mięsem',                '1'),   -- e202
    ('Virtu',           'Virtu Pierogi Wegańskie a''la Mięsne',  '2'),   -- e150c, e202
    -- FROZEN READY MEALS
    ('FRoSTA',          'FRoSTA Złoty Mintaj',                   '0'),   -- MSC-certified, clean label
    ('Iglotex',         'Iglotex Paluszki Rybne',                '3'),   -- e412, e415, e450
    -- CUP SOUPS
    ('Knorr',           'Gorący Kubek Ogórkowa z Grzankami',     '2'),   -- e330, e392
    ('Knorr',           'Gorący Kubek Cebulowa z Grzankami',     '3'),   -- e330, e392, e471
    ('Knorr',           'Gorący Kubek Żurek z Grzankami',        '3'),   -- e330, e392, e621
    ('Frużel',          'Frużel Instant Żurek',                 '4'),   -- e14xx, e330, e621, e627
    ('Maggi',           'Maggi Cup Mushroom',                    '2')    -- e330, e392
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
  and p.country = 'PL' and p.category = 'Instant & Frozen'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- INSTANT NOODLES / SOUPS
    ('Knorr',           'Knorr Nudle Pomidorowe Pikantne',      'C'),
    ('Knorr',           'Knorr Nudle Pieczony Kurczak',         'C'),
    ('Knorr',           'Knorr Nudle Ser w Ziołach',            'C'),
    ('Amino',           'Amino Barszcz Czerwony',               'C'),
    ('Amino',           'Amino Rosół z Makaronem',              'C'),
    ('Amino',           'Amino Żurek po Śląsku',                'C'),
    ('Vifon',           'Vifon Kurczak Złocisty',               'C'),
    -- FROZEN PIZZA
    ('Iglotex',         'Iglotex Pizza Kurczak ze Szpinakiem',   'C'),
    ('Iglotex',         'Iglotex Pizza Cztery Sery',             'D'),
    ('Iglotex',         'Iglotex Pizza Szynka z Pieczarkami',    'C'),
    ('Iglotex',         'Iglotex Pizza z Szynką Wieprzową',      'C'),
    ('Dr. Oetker',      'Guseppe Pizza Quattro Formaggi',        'D'),
    ('Proste Historie', 'Proste Historie Pizza Warzywna',        'C'),
    ('Dr. Oetker',      'Feliciana Pizza Prosciutto e Funghi',   'D'),
    -- FROZEN PIEROGI
    ('Swojska Chata',   'Swojska Chata Pierogi Ruskie',          'C'),
    ('Nasze Smaki',     'Nasze Smaki Pierogi Ruskie z Cebulką',  'C'),
    ('Virtu',           'Virtu Pierogi Ruskie',                  'C'),
    ('Virtu',           'Virtu Pierogi z Kapustą i Grzybami',    'B'),
    ('Virtu',           'Virtu Pierogi z Serem',                 'B'),
    ('Virtu',           'Virtu Pierogi z Mięsem',                'C'),
    ('Virtu',           'Virtu Pierogi Wegańskie a''la Mięsne',  'C'),
    -- FROZEN READY MEALS
    ('FRoSTA',          'FRoSTA Złoty Mintaj',                   'B'),
    ('Iglotex',         'Iglotex Paluszki Rybne',                'C'),
    -- CUP SOUPS
    ('Knorr',           'Gorący Kubek Ogórkowa z Grzankami',     'C'),
    ('Knorr',           'Gorący Kubek Cebulowa z Grzankami',     'C'),
    ('Knorr',           'Gorący Kubek Żurek z Grzankami',        'C'),
    ('Frużel',          'Frużel Instant Żurek',                 'C'),
    ('Maggi',           'Maggi Cup Mushroom',                    'C')
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
    else 'Low'
  end
from (
  values
    -- INSTANT NOODLES / SOUPS (all NOVA 4: flavour enhancers, MSG, palm oil)
    ('Knorr',           'Knorr Nudle Pomidorowe Pikantne',      '4'),
    ('Knorr',           'Knorr Nudle Pieczony Kurczak',         '4'),
    ('Knorr',           'Knorr Nudle Ser w Ziołach',            '4'),
    ('Amino',           'Amino Barszcz Czerwony',               '4'),
    ('Amino',           'Amino Rosół z Makaronem',              '4'),
    ('Amino',           'Amino Żurek po Śląsku',                '4'),
    ('Vifon',           'Vifon Kurczak Złocisty',               '4'),
    -- FROZEN PIZZA (all NOVA 4: multiple processing stages + additives)
    ('Iglotex',         'Iglotex Pizza Kurczak ze Szpinakiem',   '4'),
    ('Iglotex',         'Iglotex Pizza Cztery Sery',             '4'),
    ('Iglotex',         'Iglotex Pizza Szynka z Pieczarkami',    '4'),
    ('Iglotex',         'Iglotex Pizza z Szynką Wieprzową',      '4'),
    ('Dr. Oetker',      'Guseppe Pizza Quattro Formaggi',        '4'),
    ('Proste Historie', 'Proste Historie Pizza Warzywna',        '4'),
    ('Dr. Oetker',      'Feliciana Pizza Prosciutto e Funghi',   '4'),
    -- FROZEN PIEROGI (NOVA 3: processed foods with recognizable ingredients)
    ('Swojska Chata',   'Swojska Chata Pierogi Ruskie',          '3'),
    ('Nasze Smaki',     'Nasze Smaki Pierogi Ruskie z Cebulką',  '3'),
    ('Virtu',           'Virtu Pierogi Ruskie',                  '3'),
    ('Virtu',           'Virtu Pierogi z Kapustą i Grzybami',    '3'),
    ('Virtu',           'Virtu Pierogi z Serem',                 '3'),
    ('Virtu',           'Virtu Pierogi z Mięsem',                '4'),   -- modified starch + collagen
    ('Virtu',           'Virtu Pierogi Wegańskie a''la Mięsne',  '4'),   -- textured protein + e150c
    -- FROZEN READY MEALS
    ('FRoSTA',          'FRoSTA Złoty Mintaj',                   '3'),   -- breaded fish, clean-label
    ('Iglotex',         'Iglotex Paluszki Rybne',                '4'),   -- multiple additives + stabilisers
    -- CUP SOUPS (all NOVA 4: instant powder + additives)
    ('Knorr',           'Gorący Kubek Ogórkowa z Grzankami',     '4'),
    ('Knorr',           'Gorący Kubek Cebulowa z Grzankami',     '4'),
    ('Knorr',           'Gorący Kubek Żurek z Grzankami',        '4'),
    ('Frużel',          'Frużel Instant Żurek',                 '4'),
    ('Maggi',           'Maggi Cup Mushroom',                    '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g (EU Reg. 1169/2011 Annex XIII):
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
  and p.country = 'PL' and p.category = 'Instant & Frozen'
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
  and p.country = 'PL' and p.category = 'Instant'
  and p.is_deprecated is not true;

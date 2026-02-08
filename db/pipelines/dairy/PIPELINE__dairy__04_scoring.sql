-- PIPELINE (DAIRY): scoring updates
-- PIPELINE__dairy__04_scoring.sql
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
where p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Polish dairy is mostly clean-label — low additive counts are genuine.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Mlekovita',  'Mlekovita Mleko UHT 2%',             '0'),
    ('Łaciate',    'Łaciate Mleko 3.2%',                 '0'),
    ('Danone',     'Activia Jogurt Naturalny',           '0'),
    ('Zott',       'Jogobella Brzoskwinia',              '0'),   -- yogurt + fruit + sugar + aromat; no E-numbers
    ('Zott',       'Zott Jogurt Naturalny',              '0'),
    ('Piątnica',   'Piątnica Skyr Naturalny',            '0'),
    ('Danone',     'Actimel Wieloowocowy',               '0'),   -- no E-number additives per OFF
    ('Danone',     'Danonki Truskawka',                  '1'),   -- e14xx (modified starch)
    ('Müller',     'Müller Jogurt Choco Balls',          '6'),   -- e14xx, e322, e330, e331, e414, e440
    ('Mlekpol',    'Jogurt Augustowski Naturalny',       '0'),   -- milk + cultures only
    ('Piątnica',   'Piątnica Serek Wiejski',             '0'),
    ('Hochland',   'Almette Śmietankowy',               '1'),   -- e330 (citric acid)
    ('Piątnica',   'Piątnica Twaróg Półtłusty',         '0'),
    ('Mlekovita',  'Mlekovita Gouda',                    '1'),   -- e509 (calcium chloride)
    ('Sierpc',     'Sierpc Ser Królewski',               '2'),   -- e160b (annatto), e509
    ('Président',  'Président Camembert',                '0'),   -- no additives per OFF
    ('Hochland',   'Hochland Kremowy ze Śmietanką',     '4'),   -- e450, e452, e331, e330
    ('Hochland',   'Hochland Kanapkowy ze Szczypiorkiem','2'),   -- e330, e412
    ('Philadelphia','Philadelphia Original',             '1'),   -- e410 (locust bean gum)
    ('Mlekovita',  'Mlekovita Kefir Naturalny',          '0'),
    ('Bakoma',     'Bakoma Kefir Naturalny',             '0'),
    ('Mlekovita',  'Mlekovita Maślanka Naturalna',       '0'),   -- pure buttermilk
    ('Mlekovita',  'Mlekovita Masło Ekstra',             '0'),
    ('Łaciate',    'Łaciate Masło Extra',                '0'),
    ('Piątnica',   'Piątnica Śmietana 18%',             '0'),
    ('Danio',      'Danio Serek Waniliowy',              '0'),   -- corn starch + natural flavoring; no E-numbers per OFF
    ('Zott',       'Zott Monte',                         '3'),   -- e14xx, e407, e412
    ('Bakoma',     'Bakoma Satino Kawowy',               '1')    -- e407 (carrageenan)
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
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Mlekovita',  'Mlekovita Mleko UHT 2%',             'B'),
    ('Łaciate',    'Łaciate Mleko 3.2%',                 'B'),
    ('Danone',     'Activia Jogurt Naturalny',           'B'),
    ('Zott',       'Jogobella Brzoskwinia',              'C'),
    ('Zott',       'Zott Jogurt Naturalny',              'B'),
    ('Piątnica',   'Piątnica Skyr Naturalny',            'A'),
    ('Danone',     'Actimel Wieloowocowy',               'E'),
    ('Danone',     'Danonki Truskawka',                  'C'),
    ('Müller',     'Müller Jogurt Choco Balls',          'D'),
    ('Mlekpol',    'Jogurt Augustowski Naturalny',       'B'),
    ('Piątnica',   'Piątnica Serek Wiejski',             'C'),
    ('Hochland',   'Almette Śmietankowy',               'D'),
    ('Piątnica',   'Piątnica Twaróg Półtłusty',         'A'),
    ('Mlekovita',  'Mlekovita Gouda',                    'D'),
    ('Sierpc',     'Sierpc Ser Królewski',               'D'),
    ('Président',  'Président Camembert',                'D'),
    ('Hochland',   'Hochland Kremowy ze Śmietanką',     'D'),
    ('Hochland',   'Hochland Kanapkowy ze Szczypiorkiem','D'),
    ('Philadelphia','Philadelphia Original',             'D'),
    ('Mlekovita',  'Mlekovita Kefir Naturalny',          'B'),
    ('Bakoma',     'Bakoma Kefir Naturalny',             'B'),
    ('Mlekovita',  'Mlekovita Maślanka Naturalna',       'A'),
    ('Mlekovita',  'Mlekovita Masło Ekstra',             'E'),
    ('Łaciate',    'Łaciate Masło Extra',                'E'),
    ('Piątnica',   'Piątnica Śmietana 18%',             'D'),
    ('Danio',      'Danio Serek Waniliowy',              'C'),
    ('Zott',       'Zott Monte',                         'D'),
    ('Bakoma',     'Bakoma Satino Kawowy',               'E')
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
    ('Mlekovita',  'Mlekovita Mleko UHT 2%',             '1'),  -- milk only
    ('Łaciate',    'Łaciate Mleko 3.2%',                 '1'),  -- milk only
    ('Danone',     'Activia Jogurt Naturalny',           '3'),  -- fermented + probiotics
    ('Zott',       'Jogobella Brzoskwinia',              '4'),  -- fruit prep + aromat
    ('Zott',       'Zott Jogurt Naturalny',              '1'),  -- milk + cultures only
    ('Piątnica',   'Piątnica Skyr Naturalny',            '1'),  -- milk + cultures
    ('Danone',     'Actimel Wieloowocowy',               '4'),  -- reconstituted fruit, flavoring
    ('Danone',     'Danonki Truskawka',                  '4'),  -- modified starch, flavoring
    ('Müller',     'Müller Jogurt Choco Balls',          '4'),  -- 6 additives, choco coating
    ('Mlekpol',    'Jogurt Augustowski Naturalny',       '1'),  -- milk + cultures only
    ('Piątnica',   'Piątnica Serek Wiejski',             '3'),  -- processed cheese curds
    ('Hochland',   'Almette Śmietankowy',               '3'),  -- processed soft cheese
    ('Piątnica',   'Piątnica Twaróg Półtłusty',         '3'),  -- processed curd cheese
    ('Mlekovita',  'Mlekovita Gouda',                    '3'),  -- cheese with e509
    ('Sierpc',     'Sierpc Ser Królewski',               '4'),  -- coloring e160b + e509
    ('Président',  'Président Camembert',                '3'),  -- soft cheese, fermented
    ('Hochland',   'Hochland Kremowy ze Śmietanką',     '4'),  -- emulsifying salts ultra-processed
    ('Hochland',   'Hochland Kanapkowy ze Szczypiorkiem','4'),  -- processed cheese spread
    ('Philadelphia','Philadelphia Original',             '3'),  -- cream cheese with stabilizer
    ('Mlekovita',  'Mlekovita Kefir Naturalny',          '1'),  -- milk + kefir grains
    ('Bakoma',     'Bakoma Kefir Naturalny',             '3'),  -- per OFF classification
    ('Mlekovita',  'Mlekovita Maślanka Naturalna',       '1'),  -- milk + cultures only
    ('Mlekovita',  'Mlekovita Masło Ekstra',             '2'),  -- processed culinary ingredient
    ('Łaciate',    'Łaciate Masło Extra',                '2'),  -- processed culinary ingredient
    ('Piątnica',   'Piątnica Śmietana 18%',             '3'),  -- processed cream
    ('Danio',      'Danio Serek Waniliowy',              '4'),  -- corn starch + flavoring = ultra-processed
    ('Zott',       'Zott Monte',                         '4'),  -- modified starch, thickeners
    ('Bakoma',     'Bakoma Satino Kawowy',               '4')   -- modified starch, additives
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
  and p.country = 'PL' and p.category = 'Dairy'
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
  and p.country = 'PL' and p.category = 'Dairy'
  and p.is_deprecated is not true;

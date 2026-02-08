-- PIPELINE (ALCOHOL): scoring updates
-- PIPELINE__alcohol__04_scoring.sql
-- Formula-based v3.1 scoring via compute_unhealthiness_v31() function.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- NOTE: Nutri-Score is marked 'not-applicable' for all alcohol products
--       (EU regulation excludes alcoholic beverages from Nutri-Score).
--       Non-alcoholic variants also marked not-applicable for consistency.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- BEER — alcoholic
    ('Lech',           'Lech Premium',                                                       '0'),
    ('Tyskie',         'Tyskie Gronie',                                                      '0'),
    -- RADLER — alcoholic
    ('Warka',          'Piwo Warka Radler',                                                  '4'),   -- e290, e330, e414, e960a
    -- CIDER — alcoholic
    ('Somersby',       'Somersby Blueberry Flavoured Cider',                                  '0'),
    -- NON-ALCOHOLIC BEER
    ('Karmi',          'Karmi',                                                              '0'),
    ('Łomża',          'Łomża piwo jasne bezalkoholowe',                                     '0'),
    ('Lech',           'Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai',          '0'),
    ('Lech',           'Lech Free smoczy owoc i winogrono 0,0%',                              '0'),
    ('Lech',           'Lech Free',                                                          '0'),
    ('Okocim',         'Okocim Piwo Jasne 0%',                                               '0'),
    ('Lech',           'Lech Free Active Hydrate mango i cytryna 0,0%',                       '2'),   -- e330, e414
    ('Łomża',          'Łomża 0% o smaku jabłko & mięta',                                    '0'),
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku grejpfruta i guawy',        '0'),
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku arbuz mięta',               '0'),
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku jeżyny i wiśni',            '0'),
    ('Lech',           'Lech Free Citrus Sour',                                              '0'),
    ('Lech',           'Lech Free 0,0% limonka i mięta',                                     '0'),
    ('Lech',           'Lech Free 0,0% piwo o smaku yuzu i pomelo',                           '0'),
    -- NON-ALCOHOLIC RADLER
    ('Karlsquell',     'Free! Radler o smaku mango',                                         '2'),   -- e290, e330
    ('Warka',          'Warka Kiwi Z Pigwą 0,0%',                                            '3'),   -- e330, e414, e960
    ('Okocim',         'Okocim 0,0% mango z marakują',                                       '0'),
    ('Łomża',          'Łomża Radler 0,0%',                                                  '2'),   -- e290, e330
    -- NON-ALCOHOLIC RTD
    ('Somersby',       'Somersby blackcurrant & lime 0%',                                     '0'),
    -- NON-ALCOHOLIC CIDER
    ('Dzik',           'Dzik Cydr 0% jabłko i marakuja',                                      '0'),
    -- NON-ALCOHOLIC WINE
    ('Just 0.',        'Just 0. White alcoholfree',                                           '3'),   -- e220, e290, e300
    ('Just 0.',        'Just 0. Red',                                                         '1')    -- e220 (sulphites)
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
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label
--    EU regulations exclude alcoholic beverages from Nutri-Score.
--    Non-alcoholic variants also marked not-applicable for consistency.
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = 'not-applicable'
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '1' then 'Low'
    else 'Low'
  end
from (
  values
    -- BEER — alcoholic
    ('Lech',           'Lech Premium',                                                       '3'),   -- OFF NOVA 3
    ('Tyskie',         'Tyskie Gronie',                                                      '3'),   -- OFF NOVA 3
    -- RADLER — alcoholic
    ('Warka',          'Piwo Warka Radler',                                                  '4'),   -- OFF NOVA 4 (4 additives)
    -- CIDER — alcoholic
    ('Somersby',       'Somersby Blueberry Flavoured Cider',                                  '4'),   -- estimated NOVA 4
    -- NON-ALCOHOLIC BEER
    ('Karmi',          'Karmi',                                                              '3'),   -- OFF NOVA 3
    ('Łomża',          'Łomża piwo jasne bezalkoholowe',                                     '4'),   -- OFF NOVA 4
    ('Lech',           'Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai',          '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free smoczy owoc i winogrono 0,0%',                              '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free',                                                          '4'),   -- OFF NOVA 4
    ('Okocim',         'Okocim Piwo Jasne 0%',                                               '3'),   -- estimated NOVA 3
    ('Lech',           'Lech Free Active Hydrate mango i cytryna 0,0%',                       '4'),   -- OFF NOVA 4
    ('Łomża',          'Łomża 0% o smaku jabłko & mięta',                                    '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku grejpfruta i guawy',        '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku arbuz mięta',               '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku jeżyny i wiśni',            '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free Citrus Sour',                                              '3'),   -- OFF NOVA 3
    ('Lech',           'Lech Free 0,0% limonka i mięta',                                     '4'),   -- estimated NOVA 4
    ('Lech',           'Lech Free 0,0% piwo o smaku yuzu i pomelo',                           '4'),   -- estimated NOVA 4
    -- NON-ALCOHOLIC RADLER
    ('Karlsquell',     'Free! Radler o smaku mango',                                         '4'),   -- OFF NOVA 4
    ('Warka',          'Warka Kiwi Z Pigwą 0,0%',                                            '4'),   -- OFF NOVA 4
    ('Okocim',         'Okocim 0,0% mango z marakują',                                       '4'),   -- estimated NOVA 4
    ('Łomża',          'Łomża Radler 0,0%',                                                  '4'),   -- OFF NOVA 4
    -- NON-ALCOHOLIC RTD
    ('Somersby',       'Somersby blackcurrant & lime 0%',                                     '4'),   -- estimated NOVA 4
    -- NON-ALCOHOLIC CIDER
    ('Dzik',           'Dzik Cydr 0% jabłko i marakuja',                                      '4'),   -- estimated NOVA 4
    -- NON-ALCOHOLIC WINE
    ('Just 0.',        'Just 0. White alcoholfree',                                           '4'),   -- OFF NOVA 4
    ('Just 0.',        'Just 0. Red',                                                         '3')    -- OFF NOVA 3
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
  and p.country = 'PL' and p.category = 'Alcohol'
  and p.is_deprecated is not true;

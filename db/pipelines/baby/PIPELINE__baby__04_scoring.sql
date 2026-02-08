-- PIPELINE (BABY): scoring updates
-- PIPELINE__baby__04_scoring.sql
-- Formula-based v3.1 scoring.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- NOTE: Nutri-Score is marked 'not-applicable' for baby foods (EU regulation
--       excludes foods for infants/toddlers from Nutri-Score).
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- BABY CEREAL
    ('BoboVita',        'BoboVita Kaszka Zbożowa Jabłko Śliwka',                     '0'),
    ('BoboVita',        'BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa',   '0'),
    ('BoboVita',        'BoboVita Kaszka Mleczna Ryżowa 3 Owoce',                   '0'),
    ('HiPP',           'HiPP Kaszka mleczna z biszkoptami i jabłkami',               '0'),
    ('Nestlé',         'Nestlé Sinlac',                                              '2'),   -- e322, e472c
    ('Gerber',         'Gerber Pełnia Zbóż Owsianka 5 Zbóż',                        '0'),
    -- BABY PUREE — FRUIT
    ('BoboVita',        'BoboVita Delikatne jabłka z bananem',                       '0'),
    ('Gerber',         'Gerber owoce jabłka z truskawkami i jagodami',               '0'),
    ('GutBio',         'GutBio Puré de Frutas Manzana y Plátano',                   '0'),
    ('Tymbark',        'Tymbark Mus gruszka jabłko',                                '0'),
    ('dada baby food', 'dada baby food bio mus kokos',                              '0'),
    ('Bobo Frut',      'Bobo Frut Jabłko marchew',                                  '1'),   -- e330 (citric acid)
    ('OWOLOVO',        'OWOLOVO Siła & Moc Mus Jabłkowo-Buraczany',                 '0'),
    -- BABY PUREE — DINNER
    ('Gerber',         'Gerber Krem jarzynowy ze schabem',                           '0'),
    ('Gerber',         'Gerber Leczo z mozzarellą i kluseczkami',                    '0'),
    ('Gerber',         'Gerber Warzywa z delikatnym indykiem w pomidorach',           '0'),
    ('Gerber',         'Gerber Bukiet warzyw z łososiem w sosie pomidorowym',         '0'),
    ('BoboVita',       'BoboVita Pomidorowa z kurczakiem i ryżem',                   '0'),
    ('HiPP',          'HiPP Dynia z indykiem',                                      '0'),
    ('HiPP',          'HiPP Spaghetti z pomidorami i mozzarellą',                   '0'),
    -- BABY SNACK
    ('Gerber',         'Gerber organic Krakersy z pomidorem po 12 miesiącu',         '0'),
    -- TODDLER POUCH
    ('OWOLOVO',        'OWOLOVO MORELOWO',                                           '0'),
    ('OWOLOVO',        'OWOLOVO Truskawkowo Mus jabłkowo-truskawkowy',               '0'),
    ('OWOLOVO',        'OWOLOVO Ananasowo',                                          '0'),
    ('OWOLOVO',        'OWOLOVO Mus jabłkowo-wiśniowy',                              '0'),
    ('OWOLOVO',        'OWOLOVO Smoothie tropikalne Jabłko Morela Pomarańcza',       '0')
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
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label
--    EU regulations exclude baby food from Nutri-Score labeling.
--    All baby food products are marked 'not-applicable'.
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = 'not-applicable'
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Baby'
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
    -- BABY CEREAL
    ('BoboVita',        'BoboVita Kaszka Zbożowa Jabłko Śliwka',                     '4'),   -- OFF NOVA 4
    ('BoboVita',        'BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa',   '3'),   -- OFF NOVA 3
    ('BoboVita',        'BoboVita Kaszka Mleczna Ryżowa 3 Owoce',                   '3'),   -- no NOVA on OFF → estimated 3
    ('HiPP',           'HiPP Kaszka mleczna z biszkoptami i jabłkami',               '4'),   -- OFF NOVA 4
    ('Nestlé',         'Nestlé Sinlac',                                              '4'),   -- OFF NOVA 4
    ('Gerber',         'Gerber Pełnia Zbóż Owsianka 5 Zbóż',                        '3'),   -- no NOVA on OFF → estimated 3
    -- BABY PUREE — FRUIT
    ('BoboVita',        'BoboVita Delikatne jabłka z bananem',                       '1'),   -- no NOVA → estimated 1 (pure fruit)
    ('Gerber',         'Gerber owoce jabłka z truskawkami i jagodami',               '3'),   -- OFF NOVA 3
    ('GutBio',         'GutBio Puré de Frutas Manzana y Plátano',                   '1'),   -- no NOVA → estimated 1 (pure fruit)
    ('Tymbark',        'Tymbark Mus gruszka jabłko',                                '1'),   -- OFF NOVA 1
    ('dada baby food', 'dada baby food bio mus kokos',                              '1'),   -- no NOVA → estimated 1 (organic fruit)
    ('Bobo Frut',      'Bobo Frut Jabłko marchew',                                  '1'),   -- OFF NOVA 1
    ('OWOLOVO',        'OWOLOVO Siła & Moc Mus Jabłkowo-Buraczany',                 '1'),   -- OFF NOVA 1
    -- BABY PUREE — DINNER
    ('Gerber',         'Gerber Krem jarzynowy ze schabem',                           '3'),   -- OFF NOVA 3
    ('Gerber',         'Gerber Leczo z mozzarellą i kluseczkami',                    '3'),   -- OFF NOVA 3
    ('Gerber',         'Gerber Warzywa z delikatnym indykiem w pomidorach',           '3'),   -- no NOVA → estimated 3
    ('Gerber',         'Gerber Bukiet warzyw z łososiem w sosie pomidorowym',         '3'),   -- no NOVA → estimated 3
    ('BoboVita',       'BoboVita Pomidorowa z kurczakiem i ryżem',                   '3'),   -- OFF NOVA 3
    ('HiPP',          'HiPP Dynia z indykiem',                                      '1'),   -- OFF NOVA 1
    ('HiPP',          'HiPP Spaghetti z pomidorami i mozzarellą',                   '3'),   -- OFF NOVA 3
    -- BABY SNACK
    ('Gerber',         'Gerber organic Krakersy z pomidorem po 12 miesiącu',         '3'),   -- OFF NOVA 3
    -- TODDLER POUCH
    ('OWOLOVO',        'OWOLOVO MORELOWO',                                           '1'),   -- OFF NOVA 1
    ('OWOLOVO',        'OWOLOVO Truskawkowo Mus jabłkowo-truskawkowy',               '1'),   -- OFF NOVA 1
    ('OWOLOVO',        'OWOLOVO Ananasowo',                                          '1'),   -- OFF NOVA 1
    ('OWOLOVO',        'OWOLOVO Mus jabłkowo-wiśniowy',                              '1'),   -- OFF NOVA 1
    ('OWOLOVO',        'OWOLOVO Smoothie tropikalne Jabłko Morela Pomarańcza',       '1')    -- OFF NOVA 1
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
  and p.country = 'PL' and p.category = 'Baby'
  and p.is_deprecated is not true;

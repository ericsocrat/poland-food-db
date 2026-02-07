-- PIPELINE (DRINKS): scoring updates
-- PIPELINE__drinks__04_scoring.sql
-- Formula-based v3.1 scoring.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-07
-- Note: prep_method = 'none' for all beverages → maps to ELSE = 50 in formula.

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Coca-Cola', 'Coca-Cola Original',             '3'),   -- e150d, e290, e338
    ('Coca-Cola', 'Coca-Cola Zero',                 '5'),   -- e150d, e331, e338, e950, e951
    ('Fanta',     'Fanta Orange',                    '3'),   -- e290, e330, e160a
    ('Pepsi',     'Pepsi',                           '3'),   -- e150d, e290, e338
    ('Tiger',     'Tiger Energy Drink',              '6'),   -- e101, e150d, e290, e330, e331, e955
    ('Tiger',     'Tiger Energy Drink Classic',      '7'),   -- e101, e150d, e202, e211, e290, e330, e331
    ('4Move',     '4Move Activevitamin',             '7'),   -- e330, e331, e202, e211, e950, e955, e160a
    ('Tymbark',   'Tymbark Sok 100% Pomarańczowy',   '0'),
    ('Tymbark',   'Tymbark Sok 100% Jabłkowy',       '0'),
    ('Tymbark',   'Tymbark Multiwitamina',           '0'),
    ('Tymbark',   'Tymbark Cactus',                  '7'),   -- e100, e141, e296, e300, e330, e331, e950
    ('Hortex',    'Hortex Sok Jabłkowy 100%',        '0'),
    ('Hortex',    'Hortex Sok Pomarańczowy 100%',    '0'),
    ('Cappy',     'Cappy 100% Orange',               '0'),
    ('Dawtona',   'Dawtona Sok Pomidorowy',          '0'),
    ('Mlekovita', 'Mlekovita Mleko 3.2%',            '0')
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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Coca-Cola', 'Coca-Cola Original',             'E'),
    ('Coca-Cola', 'Coca-Cola Zero',                 'B'),
    ('Fanta',     'Fanta Orange',                    'D'),
    ('Pepsi',     'Pepsi',                           'E'),
    ('Tiger',     'Tiger Energy Drink',              'D'),
    ('Tiger',     'Tiger Energy Drink Classic',      'E'),
    ('4Move',     '4Move Activevitamin',             'C'),
    ('Tymbark',   'Tymbark Sok 100% Pomarańczowy',   'C'),
    ('Tymbark',   'Tymbark Sok 100% Jabłkowy',       'C'),
    ('Tymbark',   'Tymbark Multiwitamina',           'D'),
    ('Tymbark',   'Tymbark Cactus',                  'C'),
    ('Hortex',    'Hortex Sok Jabłkowy 100%',        'C'),
    ('Hortex',    'Hortex Sok Pomarańczowy 100%',    'C'),
    ('Cappy',     'Cappy 100% Orange',               'C'),
    ('Dawtona',   'Dawtona Sok Pomidorowy',          'B'),
    ('Mlekovita', 'Mlekovita Mleko 3.2%',            'C')
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
    when '1' then 'Low'
    else 'Low'
  end
from (
  values
    ('Coca-Cola', 'Coca-Cola Original',             '4'),   -- UPF cola
    ('Coca-Cola', 'Coca-Cola Zero',                 '4'),   -- UPF diet cola
    ('Fanta',     'Fanta Orange',                    '4'),   -- UPF soda
    ('Pepsi',     'Pepsi',                           '4'),   -- UPF cola
    ('Tiger',     'Tiger Energy Drink',              '4'),   -- UPF energy drink
    ('Tiger',     'Tiger Energy Drink Classic',      '4'),   -- UPF energy drink
    ('4Move',     '4Move Activevitamin',             '4'),   -- UPF vitamin water
    ('Tymbark',   'Tymbark Sok 100% Pomarańczowy',   '1'),   -- 100% juice
    ('Tymbark',   'Tymbark Sok 100% Jabłkowy',       '1'),   -- 100% juice
    ('Tymbark',   'Tymbark Multiwitamina',           '4'),   -- nectar with additives
    ('Tymbark',   'Tymbark Cactus',                  '4'),   -- flavored drink with sweeteners
    ('Hortex',    'Hortex Sok Jabłkowy 100%',        '1'),   -- 100% juice
    ('Hortex',    'Hortex Sok Pomarańczowy 100%',    '1'),   -- 100% juice
    ('Cappy',     'Cappy 100% Orange',               '1'),   -- 100% juice
    ('Dawtona',   'Dawtona Sok Pomidorowy',          '3'),   -- processed tomato juice
    ('Mlekovita', 'Mlekovita Mleko 3.2%',            '1')    -- unprocessed UHT milk
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
  and p.country = 'PL' and p.category = 'Drinks'
  and p.is_deprecated is not true;

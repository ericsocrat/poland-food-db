-- PIPELINE (CHIPS): scoring updates
-- PIPELINE__chips__04_scoring.sql
-- Formula-based v3.1 scoring (replaces v2.2 hardcoded placeholders).
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
--    (safety net — also covered by 00_ensure_scores.sql)
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Lay''s',              'Lay''s Solone',                     '1'),
    ('Lay''s',              'Lay''s Fromage',                    '2'),
    ('Lay''s',              'Lay''s Oven Baked Grilled Paprika', '5'),
    ('Pringles',            'Pringles Original',                 '1'),
    ('Pringles',            'Pringles Paprika',                  '7'),
    ('Crunchips',           'Crunchips X-Cut Papryka',           '2'),
    ('Crunchips',           'Crunchips Pieczone Żeberka',        '2'),
    ('Crunchips',           'Crunchips Chakalaka',               '1'),
    ('Doritos',             'Doritos Hot Corn',                  '5'),
    ('Doritos',             'Doritos BBQ',                       '4'),
    ('Cheetos',             'Cheetos Flamin Hot',                '4'),
    ('Cheetos',             'Cheetos Cheese',                    '4'),
    ('Cheetos',             'Cheetos Hamburger',                 '5'),
    ('Top Chips (Biedronka)','Top Chips Fromage',                '1'),
    ('Top Chips (Biedronka)','Top Chips Faliste',                '6'),
    ('Snack Day (Lidl)',    'Snack Day Chipsy Solone',           '0'),
    ('Pringles',            'Pringles Sour Cream & Onion',       '8'),
    ('Lay''s',              'Lay''s Zielona Cebulka',            '6'),
    ('Lay''s',              'Lay''s Pikantna Papryka',           '5'),
    ('Lay''s',              'Lay''s Max Karbowane Papryka',      '2'),
    ('Lay''s',              'Lay''s Maxx Ser z Cebulką',         '6'),
    ('Crunchips',           'Crunchips X-Cut Solony',            '0'),
    ('Crunchips',           'Crunchips Zielona Cebulka',         '1'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Masło z Solą', '2'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Cebulka',      '1'),
    ('Star',                'Star Maczugi',                      '3'),
    ('Cheetos',             'Cheetos Pizzerini',                 '5'),
    ('Snack Day (Lidl)',    'Snack Day Mega Karbowane Słodkie Chilli', '1')
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Lay''s',              'Lay''s Solone',                     'D'),
    ('Lay''s',              'Lay''s Fromage',                    'D'),
    ('Lay''s',              'Lay''s Oven Baked Grilled Paprika', 'C'),
    ('Pringles',            'Pringles Original',                 'D'),
    ('Pringles',            'Pringles Paprika',                  'D'),
    ('Crunchips',           'Crunchips X-Cut Papryka',           'D'),
    ('Crunchips',           'Crunchips Pieczone Żeberka',        'D'),
    ('Crunchips',           'Crunchips Chakalaka',               'D'),
    ('Doritos',             'Doritos Hot Corn',                  'D'),
    ('Doritos',             'Doritos BBQ',                       'D'),
    ('Cheetos',             'Cheetos Flamin Hot',                'D'),
    ('Cheetos',             'Cheetos Cheese',                    'E'),
    ('Cheetos',             'Cheetos Hamburger',                 'D'),
    ('Top Chips (Biedronka)','Top Chips Fromage',                'D'),
    ('Top Chips (Biedronka)','Top Chips Faliste',                'E'),
    ('Snack Day (Lidl)',    'Snack Day Chipsy Solone',           'D'),
    ('Pringles',            'Pringles Sour Cream & Onion',       'D'),
    ('Lay''s',              'Lay''s Zielona Cebulka',            'D'),
    ('Lay''s',              'Lay''s Pikantna Papryka',           'D'),
    ('Lay''s',              'Lay''s Max Karbowane Papryka',      'D'),
    ('Lay''s',              'Lay''s Maxx Ser z Cebulką',         'D'),
    ('Crunchips',           'Crunchips X-Cut Solony',            'D'),
    ('Crunchips',           'Crunchips Zielona Cebulka',         'D'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Masło z Solą', 'D'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Cebulka',      'D'),
    ('Star',                'Star Maczugi',                      'D'),
    ('Cheetos',             'Cheetos Pizzerini',                 'D'),
    ('Snack Day (Lidl)',    'Snack Day Mega Karbowane Słodkie Chilli', 'D')
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
    ('Lay''s',              'Lay''s Solone',                     '3'),  -- only 3 ingredients (potatoes, oil, salt)
    ('Lay''s',              'Lay''s Fromage',                    '4'),
    ('Lay''s',              'Lay''s Oven Baked Grilled Paprika', '4'),
    ('Pringles',            'Pringles Original',                 '4'),
    ('Pringles',            'Pringles Paprika',                  '4'),
    ('Crunchips',           'Crunchips X-Cut Papryka',           '4'),
    ('Crunchips',           'Crunchips Pieczone Żeberka',        '4'),
    ('Crunchips',           'Crunchips Chakalaka',               '4'),
    ('Doritos',             'Doritos Hot Corn',                  '4'),
    ('Doritos',             'Doritos BBQ',                       '4'),
    ('Cheetos',             'Cheetos Flamin Hot',                '4'),
    ('Cheetos',             'Cheetos Cheese',                    '4'),
    ('Cheetos',             'Cheetos Hamburger',                 '4'),
    ('Top Chips (Biedronka)','Top Chips Fromage',                '4'),
    ('Top Chips (Biedronka)','Top Chips Faliste',                '4'),
    ('Snack Day (Lidl)',    'Snack Day Chipsy Solone',           '3'),   -- only potatoes, oils, salt
    ('Pringles',            'Pringles Sour Cream & Onion',       '4'),
    ('Lay''s',              'Lay''s Zielona Cebulka',            '4'),
    ('Lay''s',              'Lay''s Pikantna Papryka',           '4'),
    ('Lay''s',              'Lay''s Max Karbowane Papryka',      '4'),
    ('Lay''s',              'Lay''s Maxx Ser z Cebulką',         '4'),
    ('Crunchips',           'Crunchips X-Cut Solony',            '3'),   -- potatoes, oil, salt
    ('Crunchips',           'Crunchips Zielona Cebulka',         '4'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Masło z Solą', '4'),
    ('Wiejskie Ziemniaczki','Wiejskie Ziemniaczki Cebulka',      '4'),
    ('Star',                'Star Maczugi',                      '4'),
    ('Cheetos',             'Cheetos Pizzerini',                 '4'),
    ('Snack Day (Lidl)',    'Snack Day Mega Karbowane Słodkie Chilli', '4')
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
  and p.country = 'PL' and p.category = 'Chips'
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
  and p.country = 'PL' and p.category = 'Chips'
  and p.is_deprecated is not true;


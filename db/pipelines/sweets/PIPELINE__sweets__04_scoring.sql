-- PIPELINE (SWEETS): scoring updates
-- PIPELINE__sweets__04_scoring.sql
-- Formula-based v3.1 scoring via compute_unhealthiness_v31() function.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-07

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Sweets range from 1 additive (lecithin only) to 5+ for complex bars.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- CHOCOLATE TABLETS
    ('Wawel',                  'Wawel Czekolada Gorzka 70%',             '1'),   -- e322 (lecithin)
    ('Wawel',                  'Wawel Mleczna z Rodzynkami i Orzeszkami', '1'),   -- e322
    ('Wedel',                  'Wedel Czekolada Gorzka 80%',             '1'),   -- e322
    ('Wedel',                  'Wedel Czekolada Mleczna',                '1'),   -- e322
    ('Wedel',                  'Wedel Mleczna z Bakaliami',              '1'),   -- e322
    ('Wedel',                  'Wedel Mleczna z Orzechami',              '1'),   -- e322
    ('Milka',                  'Milka Alpenmilch',                       '2'),   -- e322, e476
    ('Milka',                  'Milka Trauben-Nuss',                     '2'),   -- e322, e476
    -- FILLED CHOCOLATES / PRALINES
    ('Wawel',                  'Wawel Tiki Taki Kokosowo-Orzechowe',     '3'),   -- e322, e476, e471
    ('Wawel',                  'Wawel Tiramisu Nadziewana',              '3'),   -- e322, e476, e471
    ('Wawel',                  'Wawel Czekolada Karmelowe',              '3'),   -- e322, e476, e471
    ('Wawel',                  'Wawel Kasztanki Nadziewana',             '2'),   -- e322, e476
    ('Wedel',                  'Wedel Mleczna Truskawkowa',              '3'),   -- e322, e476, e330
    ('Solidarność',            'Solidarność Śliwki w Czekoladzie',       '2'),   -- e322, e414
    -- WAFER BARS
    ('Prince Polo',            'Prince Polo XXL Classic',                '4'),   -- e322, e476, e471, e503
    ('Prince Polo',            'Prince Polo XXL Mleczne',               '4'),   -- e322, e476, e471, e503
    ('Grześki',                'Grześki Mini Chocolate',                 '3'),   -- e322, e476, e471
    ('Grześki',                'Grześki Wafer Toffee',                   '3'),   -- e322, e476, e471
    ('Kinder',                 'Kinder Bueno Mini',                      '4'),   -- e322, e500, e503, vanillin
    -- CHOCOLATE BARS
    ('Kinder',                 'Kinder Chocolate Bar',                   '2'),   -- e322, vanillin
    ('Snickers',               'Snickers Bar',                           '2'),   -- e322, e471
    ('Twix',                   'Twix Twin',                              '3'),   -- e322, e471, e500
    -- BISCUITS / COOKIES
    ('Kinder',                 'Kinder Cards',                           '5'),   -- e322, e503, e500, e471, vanillin
    ('Goplana',                'Goplana Jeżyki Cherry',                  '4'),   -- e322, e471, e476, e330
    ('Delicje',                'Delicje Szampańskie Wiśniowe',            '5'),   -- e322, e471, e330, e500, e440
    -- MARSHMALLOW / CONFECTIONERY
    ('Wedel',                  'Wedel Ptasie Mleczko Waniliowe',         '1'),   -- e322
    ('Wedel',                  'Wedel Ptasie Mleczko Gorzka 80%',        '1'),   -- e322
    -- GUMMY CANDY
    ('Haribo',                 'Haribo Goldbären',                       '4')    -- e270, e330, e901, e903
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- CHOCOLATE TABLETS
    ('Wawel',                  'Wawel Czekolada Gorzka 70%',             'E'),
    ('Wawel',                  'Wawel Mleczna z Rodzynkami i Orzeszkami', 'E'),
    ('Wedel',                  'Wedel Czekolada Gorzka 80%',             'E'),
    ('Wedel',                  'Wedel Czekolada Mleczna',                'E'),
    ('Wedel',                  'Wedel Mleczna z Bakaliami',              'E'),
    ('Wedel',                  'Wedel Mleczna z Orzechami',              'E'),
    ('Milka',                  'Milka Alpenmilch',                       'E'),
    ('Milka',                  'Milka Trauben-Nuss',                     'E'),
    -- FILLED CHOCOLATES / PRALINES
    ('Wawel',                  'Wawel Tiki Taki Kokosowo-Orzechowe',     'E'),
    ('Wawel',                  'Wawel Tiramisu Nadziewana',              'E'),
    ('Wawel',                  'Wawel Czekolada Karmelowe',              'E'),
    ('Wawel',                  'Wawel Kasztanki Nadziewana',             'E'),
    ('Wedel',                  'Wedel Mleczna Truskawkowa',              'E'),
    ('Solidarność',            'Solidarność Śliwki w Czekoladzie',       'E'),
    -- WAFER BARS
    ('Prince Polo',            'Prince Polo XXL Classic',                'E'),
    ('Prince Polo',            'Prince Polo XXL Mleczne',               'E'),
    ('Grześki',                'Grześki Mini Chocolate',                 'E'),
    ('Grześki',                'Grześki Wafer Toffee',                   'E'),
    ('Kinder',                 'Kinder Bueno Mini',                      'E'),
    -- CHOCOLATE BARS
    ('Kinder',                 'Kinder Chocolate Bar',                   'E'),
    ('Snickers',               'Snickers Bar',                           'D'),
    ('Twix',                   'Twix Twin',                              'E'),
    -- BISCUITS / COOKIES
    ('Kinder',                 'Kinder Cards',                           'E'),
    ('Goplana',                'Goplana Jeżyki Cherry',                  'E'),
    ('Delicje',                'Delicje Szampańskie Wiśniowe',            'D'),
    -- MARSHMALLOW / CONFECTIONERY
    ('Wedel',                  'Wedel Ptasie Mleczko Waniliowe',         'E'),
    ('Wedel',                  'Wedel Ptasie Mleczko Gorzka 80%',        'E'),
    -- GUMMY CANDY
    ('Haribo',                 'Haribo Goldbären',                       'D')
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
    -- CHOCOLATE TABLETS  (all NOVA 4: added emulsifiers/lecithin + flavoring)
    ('Wawel',                  'Wawel Czekolada Gorzka 70%',             '4'),
    ('Wawel',                  'Wawel Mleczna z Rodzynkami i Orzeszkami', '4'),
    ('Wedel',                  'Wedel Czekolada Gorzka 80%',             '4'),
    ('Wedel',                  'Wedel Czekolada Mleczna',                '4'),
    ('Wedel',                  'Wedel Mleczna z Bakaliami',              '4'),
    ('Wedel',                  'Wedel Mleczna z Orzechami',              '4'),
    ('Milka',                  'Milka Alpenmilch',                       '4'),
    ('Milka',                  'Milka Trauben-Nuss',                     '4'),
    -- FILLED CHOCOLATES / PRALINES (all NOVA 4: fillings + emulsifiers)
    ('Wawel',                  'Wawel Tiki Taki Kokosowo-Orzechowe',     '4'),
    ('Wawel',                  'Wawel Tiramisu Nadziewana',              '4'),
    ('Wawel',                  'Wawel Czekolada Karmelowe',              '4'),
    ('Wawel',                  'Wawel Kasztanki Nadziewana',             '4'),
    ('Wedel',                  'Wedel Mleczna Truskawkowa',              '4'),
    ('Solidarność',            'Solidarność Śliwki w Czekoladzie',       '4'),
    -- WAFER BARS (all NOVA 4: multiple additives + layers)
    ('Prince Polo',            'Prince Polo XXL Classic',                '4'),
    ('Prince Polo',            'Prince Polo XXL Mleczne',               '4'),
    ('Grześki',                'Grześki Mini Chocolate',                 '4'),
    ('Grześki',                'Grześki Wafer Toffee',                   '4'),
    ('Kinder',                 'Kinder Bueno Mini',                      '4'),
    -- CHOCOLATE BARS (all NOVA 4: ultra-processed confectionery)
    ('Kinder',                 'Kinder Chocolate Bar',                   '4'),
    ('Snickers',               'Snickers Bar',                           '4'),
    ('Twix',                   'Twix Twin',                              '4'),
    -- BISCUITS / COOKIES (all NOVA 4: baked + coated + additives)
    ('Kinder',                 'Kinder Cards',                           '4'),
    ('Goplana',                'Goplana Jeżyki Cherry',                  '4'),
    ('Delicje',                'Delicje Szampańskie Wiśniowe',            '4'),
    -- MARSHMALLOW / CONFECTIONERY (NOVA 4: whipped confections + coating)
    ('Wedel',                  'Wedel Ptasie Mleczko Waniliowe',         '4'),
    ('Wedel',                  'Wedel Ptasie Mleczko Gorzka 80%',        '4'),
    -- GUMMY CANDY (NOVA 4: moulded candy + colorants)
    ('Haribo',                 'Haribo Goldbären',                       '4')
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
  and p.country = 'PL' and p.category = 'Sweets'
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
  and p.country = 'PL' and p.category = 'Sweets'
  and p.is_deprecated is not true;

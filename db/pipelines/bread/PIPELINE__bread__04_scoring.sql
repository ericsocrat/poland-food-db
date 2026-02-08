-- PIPELINE (BREAD): scoring updates
-- PIPELINE__bread__04_scoring.sql
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
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Most traditional breads have 0 additives; wraps/tortillas have more.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Oskroba',               'Oskroba Chleb Baltonowski',              '0'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni',            '0'),
    ('Oskroba',               'Oskroba Chleb Graham',                   '0'),
    ('Oskroba',               'Oskroba Chleb Żytni Wieloziarnisty',     '0'),
    ('Oskroba',               'Oskroba Chleb Litewski',                 '0'),
    ('Oskroba',               'Oskroba Chleb Żytni Pełnoziarnisty',     '0'),
    ('Oskroba',               'Oskroba Chleb Żytni Razowy',             '0'),
    ('Mestemacher',            'Mestemacher Pumpernikiel',                '0'),
    ('Mestemacher',            'Mestemacher Chleb Wielozbożowy Żytni',    '1'),   -- e330 (citric acid)
    ('Mestemacher',            'Mestemacher Chleb Razowy',                '0'),
    ('Mestemacher',            'Mestemacher Chleb Ziarnisty',             '0'),
    ('Mestemacher',            'Mestemacher Chleb Żytni',                 '0'),
    ('Schulstad',              'Schulstad Toast Pszenny',                 '0'),
    ('Klara',                  'Klara American Sandwich Toast XXL',       '1'),   -- e471 (mono/diglycerides)
    ('Pano',                   'Pano Tost Maślany',                      '0'),
    ('Wasa',                   'Wasa Original',                           '0'),
    ('Wasa',                   'Wasa Pieczywo z Błonnikiem',              '0'),
    ('Wasa',                   'Wasa Lekkie 7 Ziaren',                   '0'),
    ('Sonko',                  'Sonko Pieczywo Chrupkie Ryżowe',          '0'),
    ('Carrefour',              'Carrefour Pieczywo Chrupkie Kukurydziane','0'),
    ('Tastino',                'Tastino Tortilla Wraps',                  '7'),   -- e412,e415,e466,e471,e472e,e322,e282
    ('Tastino',                'Tastino Wholegrain Wraps',                '6'),   -- e412,e415,e466,e471,e472e,e322
    ('Pano',                   'Pano Tortilla',                           '8'),   -- e412,e415,e466,e471,e472e,e322,e282,e300
    ('Oskroba',               'Oskroba Bułki Hamburgerowe',              '0'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni z Ziarnami', '0'),
    ('Pano',                   'Pano Bułeczki Śniadaniowe',              '3')    -- e471,e472e,e300
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
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Oskroba',               'Oskroba Chleb Baltonowski',              'A'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni',            'C'),
    ('Oskroba',               'Oskroba Chleb Graham',                   'C'),
    ('Oskroba',               'Oskroba Chleb Żytni Wieloziarnisty',     'C'),
    ('Oskroba',               'Oskroba Chleb Litewski',                 'C'),
    ('Oskroba',               'Oskroba Chleb Żytni Pełnoziarnisty',     'C'),
    ('Oskroba',               'Oskroba Chleb Żytni Razowy',             'C'),
    ('Mestemacher',            'Mestemacher Pumpernikiel',                'A'),
    ('Mestemacher',            'Mestemacher Chleb Wielozbożowy Żytni',    'B'),
    ('Mestemacher',            'Mestemacher Chleb Razowy',                'A'),
    ('Mestemacher',            'Mestemacher Chleb Ziarnisty',             'B'),
    ('Mestemacher',            'Mestemacher Chleb Żytni',                 'A'),
    ('Schulstad',              'Schulstad Toast Pszenny',                 'B'),
    ('Klara',                  'Klara American Sandwich Toast XXL',       'B'),
    ('Pano',                   'Pano Tost Maślany',                      'A'),
    ('Wasa',                   'Wasa Original',                           'A'),
    ('Wasa',                   'Wasa Pieczywo z Błonnikiem',              'A'),
    ('Wasa',                   'Wasa Lekkie 7 Ziaren',                   'B'),
    ('Sonko',                  'Sonko Pieczywo Chrupkie Ryżowe',          'A'),
    ('Carrefour',              'Carrefour Pieczywo Chrupkie Kukurydziane','A'),
    ('Tastino',                'Tastino Tortilla Wraps',                  'C'),
    ('Tastino',                'Tastino Wholegrain Wraps',                'B'),
    ('Pano',                   'Pano Tortilla',                           'D'),
    ('Oskroba',               'Oskroba Bułki Hamburgerowe',              'D'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni z Ziarnami', 'B'),
    ('Pano',                   'Pano Bułeczki Śniadaniowe',              'C')
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
    ('Oskroba',               'Oskroba Chleb Baltonowski',              '3'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni',            '3'),
    ('Oskroba',               'Oskroba Chleb Graham',                   '3'),
    ('Oskroba',               'Oskroba Chleb Żytni Wieloziarnisty',     '3'),
    ('Oskroba',               'Oskroba Chleb Litewski',                 '3'),
    ('Oskroba',               'Oskroba Chleb Żytni Pełnoziarnisty',     '3'),
    ('Oskroba',               'Oskroba Chleb Żytni Razowy',             '3'),
    ('Mestemacher',            'Mestemacher Pumpernikiel',                '3'),
    ('Mestemacher',            'Mestemacher Chleb Wielozbożowy Żytni',    '3'),
    ('Mestemacher',            'Mestemacher Chleb Razowy',                '3'),
    ('Mestemacher',            'Mestemacher Chleb Ziarnisty',             '3'),
    ('Mestemacher',            'Mestemacher Chleb Żytni',                 '3'),
    ('Schulstad',              'Schulstad Toast Pszenny',                 '4'),   -- industrial toast
    ('Klara',                  'Klara American Sandwich Toast XXL',       '3'),
    ('Pano',                   'Pano Tost Maślany',                      '3'),
    ('Wasa',                   'Wasa Original',                           '3'),
    ('Wasa',                   'Wasa Pieczywo z Błonnikiem',              '3'),
    ('Wasa',                   'Wasa Lekkie 7 Ziaren',                   '3'),
    ('Sonko',                  'Sonko Pieczywo Chrupkie Ryżowe',          '3'),
    ('Carrefour',              'Carrefour Pieczywo Chrupkie Kukurydziane','3'),
    ('Tastino',                'Tastino Tortilla Wraps',                  '4'),   -- ultra-processed wraps
    ('Tastino',                'Tastino Wholegrain Wraps',                '4'),
    ('Pano',                   'Pano Tortilla',                           '4'),
    ('Oskroba',               'Oskroba Bułki Hamburgerowe',              '3'),
    ('Oskroba',               'Oskroba Chleb Pszenno-Żytni z Ziarnami', '3'),
    ('Pano',                   'Pano Bułeczki Śniadaniowe',              '4')    -- emulsifiers + flavoring
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
  and p.country = 'PL' and p.category = 'Bread'
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
  and p.country = 'PL' and p.category = 'Bread'
  and p.is_deprecated is not true;

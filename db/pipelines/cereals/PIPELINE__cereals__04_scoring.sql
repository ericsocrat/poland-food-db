-- PIPELINE (CEREALS): scoring updates
-- PIPELINE__cereals__04_scoring.sql
-- Formula-based v3.1 scoring.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-07

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Nestlé',                  'Nestlé Corn Flakes',                      '1'),   -- e101
    ('Nestlé',                  'Nestlé Chocapic',                         '1'),   -- e322
    ('Nestlé',                  'Nestlé Cini Minis',                       '0'),
    ('Nestlé',                  'Nestlé Cheerios Owsiany',                 '3'),   -- e101, e306, e340iii
    ('Nestlé',                  'Nestlé Lion Caramel & Chocolate',         '0'),
    ('Nestlé',                  'Nestlé Ciniminis Churros',                '1'),   -- e306
    ('Nesquik',                 'Nesquik Mix',                             '0'),
    ('Sante',                   'Sante Gold Granola',                      '2'),   -- e322, e322i
    ('Sante',                   'Sante Fit Granola Truskawka & Wiśnia',    '1'),   -- e965
    ('Vitanella (Biedronka)',   'Vitanella Miami Hopki',                   '0'),
    ('Vitanella (Biedronka)',   'Vitanella Choki',                         '0'),
    ('Vitanella (Biedronka)',   'Vitanella Orito Kakaowe',                 '2'),   -- e322, e500
    ('Crownfield (Lidl)',       'Crownfield Goldini',                      '1'),   -- e471
    ('Crownfield (Lidl)',       'Crownfield Choco Muszelki',               '0'),
    ('Melvit',                  'Melvit Płatki Owsiane Górskie',           '0'),
    ('Lubella',                 'Lubella Corn Flakes Pełne Ziarno',        '3')    -- e150a, e160a, e306
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
  unhealthiness_score = GREATEST(1, LEAST(100, round(
      LEAST(100, COALESCE(nf.saturated_fat_g::numeric, 0) / 10.0 * 100) * 0.18 +
      LEAST(100, COALESCE(nf.sugars_g::numeric, 0)        / 27.0 * 100) * 0.18 +
      LEAST(100, COALESCE(nf.salt_g::numeric, 0)           / 3.0  * 100) * 0.18 +
      LEAST(100, COALESCE(nf.calories::numeric, 0)         / 600.0 * 100) * 0.10 +
      LEAST(100, COALESCE(nf.trans_fat_g::numeric, 0)      / 2.0  * 100) * 0.12 +
      LEAST(100, COALESCE(i.additives_count::numeric, 0)   / 10.0 * 100) * 0.07 +
      (CASE p.prep_method
         WHEN 'air-popped' THEN 20 WHEN 'baked' THEN 40
         WHEN 'fried' THEN 80 WHEN 'deep-fried' THEN 100 ELSE 50
       END) * 0.09 +
      (CASE p.controversies
         WHEN 'none' THEN 0 WHEN 'minor' THEN 30
         WHEN 'moderate' THEN 60 WHEN 'serious' THEN 100 ELSE 0
       END) * 0.08
  )))::text,
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Nestlé',                  'Nestlé Corn Flakes',                      'C'),
    ('Nestlé',                  'Nestlé Chocapic',                         'C'),
    ('Nestlé',                  'Nestlé Cini Minis',                       'D'),
    ('Nestlé',                  'Nestlé Cheerios Owsiany',                 'B'),
    ('Nestlé',                  'Nestlé Lion Caramel & Chocolate',         'D'),
    ('Nestlé',                  'Nestlé Ciniminis Churros',                'D'),
    ('Nesquik',                 'Nesquik Mix',                             'C'),
    ('Sante',                   'Sante Gold Granola',                      'C'),
    ('Sante',                   'Sante Fit Granola Truskawka & Wiśnia',    'B'),
    ('Vitanella (Biedronka)',   'Vitanella Miami Hopki',                   'C'),
    ('Vitanella (Biedronka)',   'Vitanella Choki',                         'C'),
    ('Vitanella (Biedronka)',   'Vitanella Orito Kakaowe',                 'E'),
    ('Crownfield (Lidl)',       'Crownfield Goldini',                      'D'),
    ('Crownfield (Lidl)',       'Crownfield Choco Muszelki',               'C'),
    ('Melvit',                  'Melvit Płatki Owsiane Górskie',           'A'),
    ('Lubella',                 'Lubella Corn Flakes Pełne Ziarno',        'C')
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
    ('Nestlé',                  'Nestlé Corn Flakes',                      '4'),
    ('Nestlé',                  'Nestlé Chocapic',                         '4'),
    ('Nestlé',                  'Nestlé Cini Minis',                       '4'),
    ('Nestlé',                  'Nestlé Cheerios Owsiany',                 '4'),
    ('Nestlé',                  'Nestlé Lion Caramel & Chocolate',         '4'),
    ('Nestlé',                  'Nestlé Ciniminis Churros',                '4'),
    ('Nesquik',                 'Nesquik Mix',                             '4'),
    ('Sante',                   'Sante Gold Granola',                      '4'),
    ('Sante',                   'Sante Fit Granola Truskawka & Wiśnia',    '4'),
    ('Vitanella (Biedronka)',   'Vitanella Miami Hopki',                   '4'),
    ('Vitanella (Biedronka)',   'Vitanella Choki',                         '4'),
    ('Vitanella (Biedronka)',   'Vitanella Orito Kakaowe',                 '4'),
    ('Crownfield (Lidl)',       'Crownfield Goldini',                      '4'),
    ('Crownfield (Lidl)',       'Crownfield Choco Muszelki',               '4'),
    ('Melvit',                  'Melvit Płatki Owsiane Górskie',           '1'),  -- unprocessed whole oats
    ('Lubella',                 'Lubella Corn Flakes Pełne Ziarno',        '4')
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
  and p.country = 'PL' and p.category = 'Cereals'
  and p.is_deprecated is not true;

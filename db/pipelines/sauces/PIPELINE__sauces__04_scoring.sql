-- PIPELINE (SAUCES): scoring updates
-- PIPELINE__sauces__04_scoring.sql
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
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Tomato pastes/passata are mostly clean-label (NOVA 1).
--    Sauces and dressings contain stabilisers, acidifiers.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- KETCHUP / BBQ
    ('Heinz',          'Heinz Tomato Ketchup',                      '0'),   -- clean-label ketchup
    ('Heinz',          'Heinz Ketchup Zero',                        '2'),   -- e296 (malic acid), e955 (sucralose)
    ('Pudliszki',      'Pudliszki Ketchup Łagodny',                 '0'),   -- no E-numbers
    ('Kotlin',         'Kotlin Ketchup Łagodny',                    '2'),   -- e14xx (modified starch), e330 (citric acid)
    ('Heinz',          'Heinz Sos Barbecue',                        '2'),   -- e150c, e150d (caramel colours)
    -- MUSTARD
    ('Kamis',          'Kamis Musztarda Sarepska Ostra',             '1'),   -- e100 (curcumin)
    ('Kamis',          'Kamis Musztarda Delikatesowa',               '1'),   -- e100
    ('Roleski',        'Roleski Musztarda Sarepska',                 '1'),   -- e100
    ('Roleski',        'Roleski Musztarda Delikatesowa',             '1'),   -- e100
    ('Roleski',        'Roleski Musztarda Stołowa',                  '0'),   -- clean-label
    -- MAYONNAISE
    ('Winiary',        'Winiary Majonez Dekoracyjny',                '2'),   -- e330, e385 (EDTA)
    ('Społem Kielce',  'Majonez Kielecki',                           '0'),   -- clean-label
    ('Hellmann''s',    'Hellmann''s Majonez Babuni',                  '3'),   -- e14xx, e160a, e385
    -- TOMATO SAUCE / PASSATA
    ('Pudliszki',      'Pudliszki Koncentrat Pomidorowy',            '0'),   -- tomatoes only
    ('Pudliszki',      'Pudliszki Pomidory Krojone',                 '1'),   -- e330 (citric acid)
    ('Łowicz',         'Łowicz Przecier Pomidorowy',                  '0'),   -- tomatoes only
    ('Dawtona',        'Dawtona Przecier z Polskimi Ziołami',         '0'),   -- tomatoes + herbs only
    -- SOY / ASIAN SAUCE
    ('Kikkoman',       'Kikkoman Sos Sojowy',                         '0'),   -- naturally brewed, no additives
    ('Kikkoman',       'Kikkoman Sos Teriyaki',                       '1'),   -- e220 (sodium metabisulphite) — preservative in mirin
    -- HOT SAUCE
    ('Flying Goose',   'Flying Goose Sriracha',                       '5'),   -- e202, e260, e330, e415, e621
    -- HORSERADISH
    ('Krakus',         'Krakus Chrzan',                               '2'),   -- e223 (sodium metabisulphite), e330
    ('Prymat',         'Prymat Chrzan Tarty',                         '4'),   -- e223, e300, e330, e415
    ('Motyl',          'Motyl Chrzan Staropolski',                    '3'),   -- e330, e412, e415
    ('Polonaise',      'Polonaise Chrzan Tarty',                      '2'),   -- e223, e330
    -- DRESSING / GARLIC SAUCE
    ('Develey',        'Develey Sos 1000 Wysp Madero',                '2'),   -- e330, e415
    ('Develey',        'Develey Sos 1000 Wysp',                       '1'),   -- e415
    ('Develey',        'Develey Sos Czosnkowy',                       '2')    -- e330, e415
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
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- KETCHUP / BBQ
    ('Heinz',          'Heinz Tomato Ketchup',                      'D'),
    ('Heinz',          'Heinz Ketchup Zero',                        'A'),
    ('Pudliszki',      'Pudliszki Ketchup Łagodny',                 'D'),
    ('Kotlin',         'Kotlin Ketchup Łagodny',                    'D'),
    ('Heinz',          'Heinz Sos Barbecue',                        'E'),
    -- MUSTARD
    ('Kamis',          'Kamis Musztarda Sarepska Ostra',             'D'),
    ('Kamis',          'Kamis Musztarda Delikatesowa',               'D'),
    ('Roleski',        'Roleski Musztarda Sarepska',                 'D'),
    ('Roleski',        'Roleski Musztarda Delikatesowa',             'D'),
    ('Roleski',        'Roleski Musztarda Stołowa',                  'D'),
    -- MAYONNAISE
    ('Winiary',        'Winiary Majonez Dekoracyjny',                'D'),
    ('Społem Kielce',  'Majonez Kielecki',                           'D'),
    ('Hellmann''s',    'Hellmann''s Majonez Babuni',                  'D'),
    -- TOMATO SAUCE / PASSATA
    ('Pudliszki',      'Pudliszki Koncentrat Pomidorowy',            'A'),
    ('Pudliszki',      'Pudliszki Pomidory Krojone',                 'A'),
    ('Łowicz',         'Łowicz Przecier Pomidorowy',                  'A'),
    ('Dawtona',        'Dawtona Przecier z Polskimi Ziołami',         'A'),
    -- SOY / ASIAN SAUCE
    ('Kikkoman',       'Kikkoman Sos Sojowy',                         'E'),
    ('Kikkoman',       'Kikkoman Sos Teriyaki',                       'E'),
    -- HOT SAUCE
    ('Flying Goose',   'Flying Goose Sriracha',                       'C'),
    -- HORSERADISH
    ('Krakus',         'Krakus Chrzan',                               'C'),
    ('Prymat',         'Prymat Chrzan Tarty',                         'C'),
    ('Motyl',          'Motyl Chrzan Staropolski',                    'C'),
    ('Polonaise',      'Polonaise Chrzan Tarty',                      'C'),
    -- DRESSING / GARLIC SAUCE
    ('Develey',        'Develey Sos 1000 Wysp Madero',                'C'),
    ('Develey',        'Develey Sos 1000 Wysp',                       'D'),
    ('Develey',        'Develey Sos Czosnkowy',                       'D')
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
    -- KETCHUP / BBQ
    ('Heinz',          'Heinz Tomato Ketchup',                      '3'),   -- processed food, no ultra-processing
    ('Heinz',          'Heinz Ketchup Zero',                        '4'),   -- sucralose (e955) = ultra-processed
    ('Pudliszki',      'Pudliszki Ketchup Łagodny',                 '4'),   -- per OFF classification
    ('Kotlin',         'Kotlin Ketchup Łagodny',                    '4'),   -- modified starch
    ('Heinz',          'Heinz Sos Barbecue',                        '4'),   -- caramel colours + flavourings
    -- MUSTARD
    ('Kamis',          'Kamis Musztarda Sarepska Ostra',             '4'),   -- curcumin colourant
    ('Kamis',          'Kamis Musztarda Delikatesowa',               '4'),   -- curcumin colourant
    ('Roleski',        'Roleski Musztarda Sarepska',                 '4'),   -- curcumin colourant
    ('Roleski',        'Roleski Musztarda Delikatesowa',             '4'),   -- curcumin colourant
    ('Roleski',        'Roleski Musztarda Stołowa',                  '3'),   -- clean-label mustard
    -- MAYONNAISE
    ('Winiary',        'Winiary Majonez Dekoracyjny',                '4'),   -- EDTA (e385)
    ('Społem Kielce',  'Majonez Kielecki',                           '3'),   -- traditional recipe
    ('Hellmann''s',    'Hellmann''s Majonez Babuni',                  '4'),   -- modified starch + EDTA
    -- TOMATO SAUCE / PASSATA
    ('Pudliszki',      'Pudliszki Koncentrat Pomidorowy',            '1'),   -- tomatoes only
    ('Pudliszki',      'Pudliszki Pomidory Krojone',                 '1'),   -- tomatoes + citric acid
    ('Łowicz',         'Łowicz Przecier Pomidorowy',                  '1'),   -- tomatoes only
    ('Dawtona',        'Dawtona Przecier z Polskimi Ziołami',         '3'),   -- tomatoes + herbs
    -- SOY / ASIAN SAUCE
    ('Kikkoman',       'Kikkoman Sos Sojowy',                         '3'),   -- naturally brewed
    ('Kikkoman',       'Kikkoman Sos Teriyaki',                       '3'),   -- naturally brewed + sugar
    -- HOT SAUCE
    ('Flying Goose',   'Flying Goose Sriracha',                       '4'),   -- MSG + preservatives
    -- HORSERADISH
    ('Krakus',         'Krakus Chrzan',                               '3'),   -- processed horseradish
    ('Prymat',         'Prymat Chrzan Tarty',                         '4'),   -- multiple additives
    ('Motyl',          'Motyl Chrzan Staropolski',                    '4'),   -- stabilisers
    ('Polonaise',      'Polonaise Chrzan Tarty',                      '3'),   -- simple recipe
    -- DRESSING / GARLIC SAUCE
    ('Develey',        'Develey Sos 1000 Wysp Madero',                '4'),   -- emulsifiers + stabilisers
    ('Develey',        'Develey Sos 1000 Wysp',                       '4'),   -- emulsifiers + stabilisers
    ('Develey',        'Develey Sos Czosnkowy',                       '4')    -- stabilisers + flavourings
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
  and p.country = 'PL' and p.category = 'Sauces'
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
  and p.country = 'PL' and p.category = 'Sauces'
  and p.is_deprecated is not true;

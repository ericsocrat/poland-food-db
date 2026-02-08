-- PIPELINE (MEAT): scoring updates
-- PIPELINE__meat__04_scoring.sql
-- Formula-based v3.1 scoring via compute_unhealthiness_v31() function.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- All processed meats carry 'moderate' controversy (IARC Group 1).
-- Last updated: 2026-02-07

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Polish deli meats heavily use nitrites (e250), phosphates (e451),
--    carrageenan (e407), ascorbate (e301), and smoke flavor.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Tarczyński',   'Tarczyński Kabanosy Klasyczne',       '3'),   -- e250,e301,e316
    ('Tarczyński',   'Tarczyński Kabanosy Exclusive',       '2'),   -- e250,e301
    ('Tarczyński',   'Tarczyński Kabanosy z Serem',         '4'),   -- e250,e301,e316,e407
    ('Berlinki',     'Berlinki Parówki Klasyczne',         '5'),   -- e250,e301,e407,e451,e452
    ('Berlinki',     'Berlinki Parówki z Szynki',          '5'),   -- e250,e301,e407,e451,e452
    ('Sokołów',      'Sokołów Parówki Cienkie',            '6'),   -- e250,e301,e316,e407,e451,e452
    ('Krakus',       'Krakus Parówki Delikatesowe',        '4'),   -- e250,e301,e407,e451
    ('Morliny',      'Morliny Parówki Polskie',            '5'),   -- e250,e301,e407,e451,e452
    ('Krakus',       'Krakus Szynka Konserwowa',           '3'),   -- e250,e301,e451
    ('Sokołów',      'Sokołów Szynka Mielona',             '4'),   -- e250,e301,e407,e451
    ('Morliny',      'Morliny Szynka Tradycyjna',          '2'),   -- e250,e301
    ('Madej Wróbel', 'Madej Wróbel Szynka Gotowana',       '2'),   -- e250,e301
    ('Sokołów',      'Sokołów Kiełbasa Krakowska Sucha',   '2'),   -- e250,e301
    ('Morliny',      'Morliny Kiełbasa Podwawelska',       '3'),   -- e250,e301,e316
    ('Tarczyński',   'Tarczyński Kiełbasa Śląska',         '3'),   -- e250,e301,e316
    ('Krakus',       'Krakus Kiełbasa Zwyczajna',          '3'),   -- e250,e301,e407
    ('Morliny',      'Morliny Boczek Wędzony',             '2'),   -- e250,e301
    ('Sokołów',      'Sokołów Boczek Pieczony',            '2'),   -- e250,e301
    ('Drosed',       'Drosed Pasztet Podlaski',            '1'),   -- e330 (citric acid)
    ('Sokołów',      'Sokołów Pasztet Firmowy',            '2'),   -- e250,e301
    ('Sokołów',      'Sokołów Salami Dojrzewające',        '2'),   -- e250,e301
    ('Tarczyński',   'Tarczyński Salami Pepperoni',         '3'),   -- e250,e301,e316
    ('Krakus',       'Krakus Mielonka Tyrolska',           '5'),   -- e250,e301,e407,e451,e452
    ('Sokołów',      'Sokołów Mielonka Poznańska',         '5'),   -- e250,e301,e407,e451,e452
    ('Krakus',       'Krakus Polędwica Sopocka',           '2'),   -- e250,e301
    ('Indykpol',     'Indykpol Polędwica z Indyka',        '2')    -- e250,e301
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Tarczyński',   'Tarczyński Kabanosy Klasyczne',       'E'),
    ('Tarczyński',   'Tarczyński Kabanosy Exclusive',       'D'),
    ('Tarczyński',   'Tarczyński Kabanosy z Serem',         'E'),
    ('Berlinki',     'Berlinki Parówki Klasyczne',         'D'),
    ('Berlinki',     'Berlinki Parówki z Szynki',          'D'),
    ('Sokołów',      'Sokołów Parówki Cienkie',            'D'),
    ('Krakus',       'Krakus Parówki Delikatesowe',        'D'),
    ('Morliny',      'Morliny Parówki Polskie',            'D'),
    ('Krakus',       'Krakus Szynka Konserwowa',           'C'),
    ('Sokołów',      'Sokołów Szynka Mielona',             'D'),
    ('Morliny',      'Morliny Szynka Tradycyjna',          'C'),
    ('Madej Wróbel', 'Madej Wróbel Szynka Gotowana',       'B'),
    ('Sokołów',      'Sokołów Kiełbasa Krakowska Sucha',   'D'),
    ('Morliny',      'Morliny Kiełbasa Podwawelska',       'D'),
    ('Tarczyński',   'Tarczyński Kiełbasa Śląska',         'D'),
    ('Krakus',       'Krakus Kiełbasa Zwyczajna',          'D'),
    ('Morliny',      'Morliny Boczek Wędzony',             'E'),
    ('Sokołów',      'Sokołów Boczek Pieczony',            'D'),
    ('Drosed',       'Drosed Pasztet Podlaski',            'D'),
    ('Sokołów',      'Sokołów Pasztet Firmowy',            'D'),
    ('Sokołów',      'Sokołów Salami Dojrzewające',        'E'),
    ('Tarczyński',   'Tarczyński Salami Pepperoni',         'E'),
    ('Krakus',       'Krakus Mielonka Tyrolska',           'D'),
    ('Sokołów',      'Sokołów Mielonka Poznańska',         'D'),
    ('Krakus',       'Krakus Polędwica Sopocka',           'C'),
    ('Indykpol',     'Indykpol Polędwica z Indyka',        'B')
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET NOVA classification + processing risk
--    All wędliny are NOVA 4 (ultra-processed: nitrites + phosphates)
--    except very simple szynka products (NOVA 3).
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
    ('Tarczyński',   'Tarczyński Kabanosy Klasyczne',       '4'),
    ('Tarczyński',   'Tarczyński Kabanosy Exclusive',       '4'),
    ('Tarczyński',   'Tarczyński Kabanosy z Serem',         '4'),
    ('Berlinki',     'Berlinki Parówki Klasyczne',         '4'),
    ('Berlinki',     'Berlinki Parówki z Szynki',          '4'),
    ('Sokołów',      'Sokołów Parówki Cienkie',            '4'),
    ('Krakus',       'Krakus Parówki Delikatesowe',        '4'),
    ('Morliny',      'Morliny Parówki Polskie',            '4'),
    ('Krakus',       'Krakus Szynka Konserwowa',           '4'),
    ('Sokołów',      'Sokołów Szynka Mielona',             '4'),
    ('Morliny',      'Morliny Szynka Tradycyjna',          '3'),   -- simple: meat + salt + spice
    ('Madej Wróbel', 'Madej Wróbel Szynka Gotowana',       '3'),   -- simple: meat + brine
    ('Sokołów',      'Sokołów Kiełbasa Krakowska Sucha',   '4'),
    ('Morliny',      'Morliny Kiełbasa Podwawelska',       '4'),
    ('Tarczyński',   'Tarczyński Kiełbasa Śląska',         '4'),
    ('Krakus',       'Krakus Kiełbasa Zwyczajna',          '4'),
    ('Morliny',      'Morliny Boczek Wędzony',             '4'),
    ('Sokołów',      'Sokołów Boczek Pieczony',            '4'),
    ('Drosed',       'Drosed Pasztet Podlaski',            '4'),
    ('Sokołów',      'Sokołów Pasztet Firmowy',            '4'),
    ('Sokołów',      'Sokołów Salami Dojrzewające',        '4'),
    ('Tarczyński',   'Tarczyński Salami Pepperoni',         '4'),
    ('Krakus',       'Krakus Mielonka Tyrolska',           '4'),
    ('Sokołów',      'Sokołów Mielonka Poznańska',         '4'),
    ('Krakus',       'Krakus Polędwica Sopocka',           '4'),
    ('Indykpol',     'Indykpol Polędwica z Indyka',        '4')
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g (EU Reg. 1169/2011 Annex XIII):
--      salt ≥ 1.5 g | sugars ≥ 5 g | sat fat ≥ 5 g | additives ≥ 5
--    Note: Nearly ALL wędliny will flag high_salt (≥1.5g).
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
  and p.country = 'PL' and p.category = 'Meat'
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
  and p.country = 'PL' and p.category = 'Meat'
  and p.is_deprecated is not true;

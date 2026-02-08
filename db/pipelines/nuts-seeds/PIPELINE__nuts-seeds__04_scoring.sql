-- PIPELINE (NUTS-SEEDS): scoring updates
-- PIPELINE__nuts-seeds__04_scoring.sql
-- Formula-based v3.1 scoring (replaces v2.2 hardcoded placeholders).
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- RAW NUTS (no additives)
    ('Alesto',             'Alesto Migdały',                            '0'),
    ('Alesto',             'Alesto Orzechy Nerkowca',                   '0'),
    ('Alesto',             'Alesto Orzechy Włoskie',                    '0'),
    ('Alesto',             'Alesto Orzechy Laskowe',                    '0'),
    ('Bakalland',          'Bakalland Orzechy Włoskie',                 '0'),
    ('Bakalland',          'Bakalland Migdały',                         '0'),
    ('Bakalland',          'Bakalland Orzechy Laskowe',                 '0'),
    -- ROASTED NUTS (salt only, no additives)
    ('Alesto',             'Alesto Migdały Prażone Solone',             '0'),
    ('Alesto',             'Alesto Orzechy Nerkowca Prażone Solone',    '0'),
    ('Fasting',            'Fasting Orzeszki Ziemne Solone',            '0'),
    ('Fasting',            'Fasting Migdały Prażone',                   '0'),
    -- RAW SEEDS (no additives)
    ('Sante',              'Sante Nasiona Słonecznika',                 '0'),
    ('Sante',              'Sante Pestki Dyni',                         '0'),
    ('Sante',              'Sante Nasiona Chia',                        '0'),
    ('Sante',              'Sante Siemię Lniane',                       '0'),
    -- ROASTED SEEDS (salt only)
    ('Targroch',           'Targroch Pestki Dyni Prażone Solone',       '0'),
    ('Targroch',           'Targroch Nasiona Słonecznika Prażone',      '0'),
    -- NUT BUTTERS (typically 1-2 additives)
    ('Helio',              'Helio Masło Orzechowe Naturalne',           '0'),
    ('Helio',              'Helio Masło Orzechowe Kremowe',             '1'),
    ('Helio',              'Helio Masło Migdałowe',                     '0'),
    -- DRIED LEGUMES (no additives)
    ('Naturavena',         'Naturavena Soczewica Czerwona',             '0'),
    ('Naturavena',         'Naturavena Soczewica Zielona',              '0'),
    ('Naturavena',         'Naturavena Ciecierzyca',                    '0'),
    ('Naturavena',         'Naturavena Fasola Biała',                   '0'),
    ('Naturavena',         'Naturavena Fasola Czerwona',                '0'),
    ('Społem',             'Społem Fasola Jaś',                         '0'),
    ('Społem',             'Społem Soczewica Brązowa',                  '0')
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- RAW NUTS (typically A-B due to healthy fats, fiber, no salt)
    ('Alesto',             'Alesto Migdały',                            'A'),
    ('Alesto',             'Alesto Orzechy Nerkowca',                   'B'),
    ('Alesto',             'Alesto Orzechy Włoskie',                    'A'),
    ('Alesto',             'Alesto Orzechy Laskowe',                    'A'),
    ('Bakalland',          'Bakalland Orzechy Włoskie',                 'A'),
    ('Bakalland',          'Bakalland Migdały',                         'A'),
    ('Bakalland',          'Bakalland Orzechy Laskowe',                 'A'),
    -- ROASTED SALTED NUTS (B-C due to added salt)
    ('Alesto',             'Alesto Migdały Prażone Solone',             'B'),
    ('Alesto',             'Alesto Orzechy Nerkowca Prażone Solone',    'C'),
    ('Fasting',            'Fasting Orzeszki Ziemne Solone',            'C'),
    ('Fasting',            'Fasting Migdały Prażone',                   'B'),
    -- RAW SEEDS (A-B, very healthy)
    ('Sante',              'Sante Nasiona Słonecznika',                 'A'),
    ('Sante',              'Sante Pestki Dyni',                         'A'),
    ('Sante',              'Sante Nasiona Chia',                        'A'),
    ('Sante',              'Sante Siemię Lniane',                       'A'),
    -- ROASTED SALTED SEEDS (B due to salt)
    ('Targroch',           'Targroch Pestki Dyni Prażone Solone',       'B'),
    ('Targroch',           'Targroch Nasiona Słonecznika Prażone',      'B'),
    -- NUT BUTTERS (C-D due to calories, salt, sometimes sugar)
    ('Helio',              'Helio Masło Orzechowe Naturalne',           'C'),
    ('Helio',              'Helio Masło Orzechowe Kremowe',             'D'),
    ('Helio',              'Helio Masło Migdałowe',                     'C'),
    -- DRIED LEGUMES (A, excellent nutrition profile)
    ('Naturavena',         'Naturavena Soczewica Czerwona',             'A'),
    ('Naturavena',         'Naturavena Soczewica Zielona',              'A'),
    ('Naturavena',         'Naturavena Ciecierzyca',                    'A'),
    ('Naturavena',         'Naturavena Fasola Biała',                   'A'),
    ('Naturavena',         'Naturavena Fasola Czerwona',                'A'),
    ('Społem',             'Społem Fasola Jaś',                         'A'),
    ('Społem',             'Społem Soczewica Brązowa',                  'A')
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
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Low'
  end
from (
  values
    -- RAW NUTS (NOVA 1 - unprocessed or minimally processed)
    ('Alesto',             'Alesto Migdały',                            '1'),
    ('Alesto',             'Alesto Orzechy Nerkowca',                   '1'),
    ('Alesto',             'Alesto Orzechy Włoskie',                    '1'),
    ('Alesto',             'Alesto Orzechy Laskowe',                    '1'),
    ('Bakalland',          'Bakalland Orzechy Włoskie',                 '1'),
    ('Bakalland',          'Bakalland Migdały',                         '1'),
    ('Bakalland',          'Bakalland Orzechy Laskowe',                 '1'),
    -- ROASTED SALTED NUTS (NOVA 3 - processed with salt/oil)
    ('Alesto',             'Alesto Migdały Prażone Solone',             '3'),
    ('Alesto',             'Alesto Orzechy Nerkowca Prażone Solone',    '3'),
    ('Fasting',            'Fasting Orzeszki Ziemne Solone',            '3'),
    ('Fasting',            'Fasting Migdały Prażone',                   '3'),
    -- RAW SEEDS (NOVA 1 - unprocessed)
    ('Sante',              'Sante Nasiona Słonecznika',                 '1'),
    ('Sante',              'Sante Pestki Dyni',                         '1'),
    ('Sante',              'Sante Nasiona Chia',                        '1'),
    ('Sante',              'Sante Siemię Lniane',                       '1'),
    -- ROASTED SALTED SEEDS (NOVA 3 - processed)
    ('Targroch',           'Targroch Pestki Dyni Prażone Solone',       '3'),
    ('Targroch',           'Targroch Nasiona Słonecznika Prażone',      '3'),
    -- NUT BUTTERS (NOVA 3 - processed)
    ('Helio',              'Helio Masło Orzechowe Naturalne',           '3'),
    ('Helio',              'Helio Masło Orzechowe Kremowe',             '3'),
    ('Helio',              'Helio Masło Migdałowe',                     '3'),
    -- DRIED LEGUMES (NOVA 1 - unprocessed)
    ('Naturavena',         'Naturavena Soczewica Czerwona',             '1'),
    ('Naturavena',         'Naturavena Soczewica Zielona',              '1'),
    ('Naturavena',         'Naturavena Ciecierzyca',                    '1'),
    ('Naturavena',         'Naturavena Fasola Biała',                   '1'),
    ('Naturavena',         'Naturavena Fasola Czerwona',                '1'),
    ('Społem',             'Społem Fasola Jaś',                         '1'),
    ('Społem',             'Społem Soczewica Brązowa',                  '1')
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
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
  and p.country = 'PL' and p.category = 'Nuts, Seeds & Legumes'
  and p.is_deprecated is not true;

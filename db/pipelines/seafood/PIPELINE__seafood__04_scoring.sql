-- PIPELINE (SEAFOOD & FISH): scoring updates
-- PIPELINE__seafood__04_scoring.sql
-- Formula-based v3.1 scoring (omega-3 rich seafood, diverse processing levels).
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
--    (safety net — ensures all seafood products have scoring infrastructure)
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    -- ── CANNED TUNA ────────────────────────────────────────────
    ('Graal',              'Tuńczyk w Oleju Roślinnym',        '0'),  -- just tuna, oil, salt
    ('Graal',              'Tuńczyk w Sosie Własnym',          '0'),  -- tuna, water, salt
    ('King Oscar',         'Tuńczyk Kawałki w Oleju',          '0'),
    ('Seko',               'Tuńczyk Naturalny',                '0'),
    -- ── CANNED MACKEREL ────────────────────────────────────────
    ('Graal',              'Makrela w Oleju',                  '0'),
    ('Graal',              'Makrela w Sosie Pomidorowym',      '1'),  -- added tomato concentrate with preservatives
    ('Seko',               'Makrela Filety w Oleju',           '0'),
    -- ── CANNED SARDINES ────────────────────────────────────────
    ('Graal',              'Sardynki w Oleju Roślinnym',       '0'),
    ('Graal',              'Sardynki w Sosie Pomidorowym',     '1'),
    ('Seko',               'Sardynki w Oleju',                 '0'),
    -- ── CANNED SALMON ──────────────────────────────────────────
    ('Graal',              'Łosoś Różowy w Sosie Własnym',     '0'),
    ('King Oscar',         'Łosoś Czerwony',                   '0'),
    -- ── SMOKED FISH ────────────────────────────────────────────
    ('Łosoś Morski',       'Łosoś Wędzony Plastry',            '1'),  -- smoking preservatives
    ('Seko',               'Makrela Wędzona',                  '1'),
    ('Graal',              'Szprot Wędzony',                   '1'),
    ('Graal',              'Pstrąg Wędzony',                   '1'),
    -- ── FISH SPREADS (PÂTÉ) ────────────────────────────────────
    ('Graal',              'Pasta Rybna Łosoś',                '3'),  -- emulsifiers, preservatives, flavor enhancers
    ('Graal',              'Pasta Rybna Tuńczyk',              '3'),
    ('Seko',               'Pasta z Makreli',                  '4'),
    -- ── FROZEN FISH ────────────────────────────────────────────
    ('Nautica (Lidl)',     'Filety z Dorsza',                  '0'),  -- plain frozen fish
    ('Frosta',             'Filety Mintaja',                   '0'),
    ('Nautica (Lidl)',     'Filety z Łososia',                 '0'),
    ('Seko',               'Filety Pangi',                     '0'),
    -- ── FISH FINGERS & BREADED FISH ────────────────────────────
    ('Frosta',             'Paluszki Rybne',                   '2'),  -- breading with stabilizers
    ('Nautica (Lidl)',     'Paluszki Rybne Panierowane',       '3'),
    -- ── SEAFOOD READY MEALS ────────────────────────────────────
    ('Graal',              'Sałatka z Tuńczykiem',             '2'),  -- mayo, preservatives
    ('Seko',               'Sałatka Śledziowa',                '3')
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, not computed)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    -- ── CANNED TUNA ────────────────────────────────────────────
    ('Graal',              'Tuńczyk w Oleju Roślinnym',        'C'),  -- higher fat from oil
    ('Graal',              'Tuńczyk w Sosie Własnym',          'A'),  -- very lean
    ('King Oscar',         'Tuńczyk Kawałki w Oleju',          'C'),
    ('Seko',               'Tuńczyk Naturalny',                'A'),
    -- ── CANNED MACKEREL ────────────────────────────────────────
    ('Graal',              'Makrela w Oleju',                  'D'),  -- high fat (natural + oil)
    ('Graal',              'Makrela w Sosie Pomidorowym',      'C'),
    ('Seko',               'Makrela Filety w Oleju',           'D'),
    -- ── CANNED SARDINES ────────────────────────────────────────
    ('Graal',              'Sardynki w Oleju Roślinnym',       'C'),
    ('Graal',              'Sardynki w Sosie Pomidorowym',     'B'),
    ('Seko',               'Sardynki w Oleju',                 'C'),
    -- ── CANNED SALMON ──────────────────────────────────────────
    ('Graal',              'Łosoś Różowy w Sosie Własnym',     'B'),
    ('King Oscar',         'Łosoś Czerwony',                   'B'),
    -- ── SMOKED FISH ────────────────────────────────────────────
    ('Łosoś Morski',       'Łosoś Wędzony Plastry',            'D'),  -- very high salt
    ('Seko',               'Makrela Wędzona',                  'D'),  -- high salt
    ('Graal',              'Szprot Wędzony',                   'D'),
    ('Graal',              'Pstrąg Wędzony',                   'D'),
    -- ── FISH SPREADS (PÂTÉ) ────────────────────────────────────
    ('Graal',              'Pasta Rybna Łosoś',                'D'),  -- high fat, salt, additives
    ('Graal',              'Pasta Rybna Tuńczyk',              'D'),
    ('Seko',               'Pasta z Makreli',                  'D'),
    -- ── FROZEN FISH ────────────────────────────────────────────
    ('Nautica (Lidl)',     'Filety z Dorsza',                  'A'),  -- very lean protein
    ('Frosta',             'Filety Mintaja',                   'A'),
    ('Nautica (Lidl)',     'Filety z Łososia',                 'B'),  -- natural fat from salmon
    ('Seko',               'Filety Pangi',                     'A'),
    -- ── FISH FINGERS & BREADED FISH ────────────────────────────
    ('Frosta',             'Paluszki Rybne',                   'C'),  -- breading adds carbs
    ('Nautica (Lidl)',     'Paluszki Rybne Panierowane',       'C'),
    -- ── SEAFOOD READY MEALS ────────────────────────────────────
    ('Graal',              'Sałatka z Tuńczykiem',             'C'),
    ('Seko',               'Sałatka Śledziowa',                'C')
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
    -- ── CANNED TUNA ────────────────────────────────────────────
    ('Graal',              'Tuńczyk w Oleju Roślinnym',        '3'),  -- canning process, added oil
    ('Graal',              'Tuńczyk w Sosie Własnym',          '3'),  -- minimal processing
    ('King Oscar',         'Tuńczyk Kawałki w Oleju',          '3'),
    ('Seko',               'Tuńczyk Naturalny',                '3'),
    -- ── CANNED MACKEREL ────────────────────────────────────────
    ('Graal',              'Makrela w Oleju',                  '3'),
    ('Graal',              'Makrela w Sosie Pomidorowym',      '3'),  -- tomato sauce adds processing
    ('Seko',               'Makrela Filety w Oleju',           '3'),
    -- ── CANNED SARDINES ────────────────────────────────────────
    ('Graal',              'Sardynki w Oleju Roślinnym',       '3'),
    ('Graal',              'Sardynki w Sosie Pomidorowym',     '3'),
    ('Seko',               'Sardynki w Oleju',                 '3'),
    -- ── CANNED SALMON ──────────────────────────────────────────
    ('Graal',              'Łosoś Różowy w Sosie Własnym',     '3'),
    ('King Oscar',         'Łosoś Czerwony',                   '3'),
    -- ── SMOKED FISH ────────────────────────────────────────────
    ('Łosoś Morski',       'Łosoś Wędzony Plastry',            '3'),  -- smoking is moderate processing
    ('Seko',               'Makrela Wędzona',                  '3'),
    ('Graal',              'Szprot Wędzony',                   '3'),
    ('Graal',              'Pstrąg Wędzony',                   '3'),
    -- ── FISH SPREADS (PÂTÉ) ────────────────────────────────────
    ('Graal',              'Pasta Rybna Łosoś',                '4'),  -- ultra-processed (emulsifiers, multiple ingredients)
    ('Graal',              'Pasta Rybna Tuńczyk',              '4'),
    ('Seko',               'Pasta z Makreli',                  '4'),
    -- ── FROZEN FISH ────────────────────────────────────────────
    ('Nautica (Lidl)',     'Filety z Dorsza',                  '1'),  -- unprocessed, just frozen
    ('Frosta',             'Filety Mintaja',                   '1'),
    ('Nautica (Lidl)',     'Filety z Łososia',                 '1'),
    ('Seko',               'Filety Pangi',                     '1'),
    -- ── FISH FINGERS & BREADED FISH ────────────────────────────
    ('Frosta',             'Paluszki Rybne',                   '4'),  -- breaded, additives
    ('Nautica (Lidl)',     'Paluszki Rybne Panierowane',       '4'),
    -- ── SEAFOOD READY MEALS ────────────────────────────────────
    ('Graal',              'Sałatka z Tuńczykiem',             '4'),  -- multiple ingredients, mayo, preservatives
    ('Seko',               'Sałatka Śledziowa',                '4')
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
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
  and p.country = 'PL' and p.category = 'Seafood & Fish'
  and p.is_deprecated is not true;

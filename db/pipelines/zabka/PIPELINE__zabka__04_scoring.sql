-- PIPELINE (ŻABKA): scoring updates
-- PIPELINE__zabka__04_scoring.sql
-- Formula-based v3.1 scoring for Żabka convenience store products.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Counts marked (est.) are food-scientist estimates where OFF lacked data.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Żabka',            'Meksykaner',                            11),  -- e14xx,e160b,e262,e300,e301,e330,e331,e415,e472e,e481,e509
    ('Żabka',            'Kurczaker',                             12),  -- e14xx,e160b,e160c,e202,e223,e300,e330,e331,e412,e415,e450,e500
    ('Żabka',            'Wołowiner Ser Kozi',                    11),  -- e14xx,e160a,e202,e250,e300,e316,e407,e415,e451,e472e,e481
    ('Żabka',            'Burger Kibica',                         7),   -- e14xx,e160b,e202,e300,e330,e415,e471
    ('Żabka',            'Falafel Rollo',                         6),   -- e14xx,e202,e211,e330,e412,e415
    ('Żabka',            'Kajzerka Kebab',                        5),   -- est. (kebab sauce + processed meat)
    ('Żabka',            'Panini z serem cheddar',                10),  -- e100,e14xx,e160b,e202,e270,e300,e385,e412,e415,e509
    ('Żabka',            'Panini z kurczakiem',                   10),  -- e141,e14xx,e160a,e160c,e202,e211,e300,e330,e412,e415
    ('Żabka',            'Kulki owsiane z czekoladą',             1),   -- e322 (lecithin — from chocolate)
    ('Tomcio Paluch',    'Szynka & Jajko',                        9),   -- e14xx,e160a,e250,e316,e407a,e415,e450,e451,e482
    ('Tomcio Paluch',    'Pieczony bekon, sałata, jajko',         6),   -- e14xx,e160a,e250,e300,e412,e415
    ('Tomcio Paluch',    'Bajgiel z salami',                      5),   -- est. (cured salami + bread additives)
    ('Szamamm',          'Naleśniki z jabłkami i cynamonem',       0),
    ('Szamamm',          'Placki ziemniaczane',                   0),
    ('Szamamm',          'Penne z kurczakiem',                    3),   -- est. (ready-meal pasta, moderate processing)
    ('Szamamm',          'Kotlet de Volaille',                    0),
    -- ── Batch 2 — new products ────────────────────────────────────────────────────────────────────────
    ('Żabka',            'Wegger',                                8),   -- est. (vegan patty: emulsifiers, stabilizers, colors)
    ('Żabka',            'Bao Burger',                            6),   -- est. (bao bun + processed meat filling)
    ('Żabka',            'Wieprzowiner',                          9),   -- est. (processed pork burger, Żabka hot-snack line)
    ('Tomcio Paluch',    'Kanapka Cezar',                         6),   -- est. (caesar dressing + processed meat)
    ('Tomcio Paluch',    'Kebab z kurczaka',                      5),   -- est. (kebab sauce + processed chicken)
    ('Tomcio Paluch',    'BBQ Strips',                            14),  -- e101,e14xx,e150a,e160c,e202,e300,e322,e330,e385,e412,e415,e450,e451,e500
    ('Tomcio Paluch',    'Pasta jajeczna, por, jajko gotowane',   4),   -- est. (egg paste sandwich, moderate processing)
    ('Tomcio Paluch',    'High 24g protein',                      6),   -- e250,e263,e316,e471,e472e,e482
    ('Szamamm',          'Pierogi ruskie ze smażoną cebulką',     2),   -- est. (simple pierogi, minimal processing)
    ('Szamamm',          'Gnocchi z kurczakiem',                  3),   -- est. (ready-meal gnocchi)
    ('Szamamm',          'Panierowane skrzydełka z kurczaka',     6),   -- est. (breaded + fried chicken wings)
    ('Szamamm',          'Kotlet Drobiowy',                       3)    -- est. (breaded chicken cutlet)
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
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.1'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts where available)
--    Products marked (est.) are inferred from nutrition-score-fr value.
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Żabka',            'Meksykaner',                            'D'),
    ('Żabka',            'Kurczaker',                             'C'),
    ('Żabka',            'Wołowiner Ser Kozi',                    'D'),
    ('Żabka',            'Burger Kibica',                         'D'),
    ('Żabka',            'Falafel Rollo',                         'C'),
    ('Żabka',            'Kajzerka Kebab',                        'D'),
    ('Żabka',            'Panini z serem cheddar',                'D'),
    ('Żabka',            'Panini z kurczakiem',                   'C'),  -- est. from nutrition profile
    ('Żabka',            'Kulki owsiane z czekoladą',             'D'),
    ('Tomcio Paluch',    'Szynka & Jajko',                        'C'),
    ('Tomcio Paluch',    'Pieczony bekon, sałata, jajko',         'D'),
    ('Tomcio Paluch',    'Bajgiel z salami',                      'D'),
    ('Szamamm',          'Naleśniki z jabłkami i cynamonem',       'C'),
    ('Szamamm',          'Placki ziemniaczane',                   'C'),
    ('Szamamm',          'Penne z kurczakiem',                    'C'),
    ('Szamamm',          'Kotlet de Volaille',                    'C'),
    -- batch 2
    ('Żabka',            'Wegger',                                'C'),   -- est. from nutrition profile
    ('Żabka',            'Bao Burger',                            'D'),   -- est. (very high salt 2.75g)
    ('Żabka',            'Wieprzowiner',                          'D'),   -- est. (high sugars 7.8g + salt 1.57g)
    ('Tomcio Paluch',    'Kanapka Cezar',                         'C'),
    ('Tomcio Paluch',    'Kebab z kurczaka',                      'D'),
    ('Tomcio Paluch',    'BBQ Strips',                            'D'),
    ('Tomcio Paluch',    'Pasta jajeczna, por, jajko gotowane',   'C'),
    ('Tomcio Paluch',    'High 24g protein',                      'C'),
    ('Szamamm',          'Pierogi ruskie ze smażoną cebulką',     'C'),   -- est. from nutrition profile
    ('Szamamm',          'Gnocchi z kurczakiem',                  'B'),   -- est. (low cal/fat/salt)
    ('Szamamm',          'Panierowane skrzydełka z kurczaka',     'C'),   -- est. from nutrition profile
    ('Szamamm',          'Kotlet Drobiowy',                       'B')    -- est. (very low cal/fat)
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
    ('Żabka',            'Meksykaner',                            4),
    ('Żabka',            'Kurczaker',                             4),
    ('Żabka',            'Wołowiner Ser Kozi',                    4),
    ('Żabka',            'Burger Kibica',                         4),
    ('Żabka',            'Falafel Rollo',                         4),
    ('Żabka',            'Kajzerka Kebab',                        4),  -- est. (processed kebab + sauces)
    ('Żabka',            'Panini z serem cheddar',                4),
    ('Żabka',            'Panini z kurczakiem',                   4),
    ('Żabka',            'Kulki owsiane z czekoladą',             4),
    ('Tomcio Paluch',    'Szynka & Jajko',                        4),
    ('Tomcio Paluch',    'Pieczony bekon, sałata, jajko',         4),
    ('Tomcio Paluch',    'Bajgiel z salami',                      4),  -- est. (processed cured meat)
    ('Szamamm',          'Naleśniki z jabłkami i cynamonem',       4),
    ('Szamamm',          'Placki ziemniaczane',                   3),  -- simple: potatoes, oil, onion, flour, salt
    ('Szamamm',          'Penne z kurczakiem',                    3),  -- est. (basic pasta dish, moderate processing)
    ('Szamamm',          'Kotlet de Volaille',                    4),
    -- batch 2
    ('Żabka',            'Wegger',                                4),  -- est. (processed vegan patty with additives)
    ('Żabka',            'Bao Burger',                            4),  -- est. (processed bao + filling)
    ('Żabka',            'Wieprzowiner',                          4),  -- est. (processed pork hot snack)
    ('Tomcio Paluch',    'Kanapka Cezar',                         4),  -- est. (sandwich with processed dressing)
    ('Tomcio Paluch',    'Kebab z kurczaka',                      4),  -- est. (processed kebab meat)
    ('Tomcio Paluch',    'BBQ Strips',                            4),  -- confirmed NOVA 4 from OFF
    ('Tomcio Paluch',    'Pasta jajeczna, por, jajko gotowane',   4),  -- est. (processed sandwich)
    ('Tomcio Paluch',    'High 24g protein',                      4),  -- confirmed NOVA 4 from OFF
    ('Szamamm',          'Pierogi ruskie ze smażoną cebulką',     3),  -- est. (simple pierogi, fried onion)
    ('Szamamm',          'Gnocchi z kurczakiem',                  4),  -- est. (ready-meal gnocchi)
    ('Szamamm',          'Panierowane skrzydełka z kurczaka',     4),  -- est. (breaded + fried wings)
    ('Szamamm',          'Kotlet Drobiowy',                       4)   -- est. (breaded cutlet)
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g following EU "high" front-of-pack guidelines:
--      salt ≥ 1.5 g | sugars ≥ 5 g | sat fat ≥ 5 g | additives ≥ 5
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = case
    -- Products with all data from OFF: 100%
    -- Products with some estimated fields: 90%
    when p.product_name in ('Kajzerka Kebab','Bajgiel z salami','Penne z kurczakiem') then 90
    when p.product_name in ('Meksykaner','Kurczaker','Pieczony bekon, sałata, jajko') then 95  -- fiber est.
    -- batch 2: estimated fields
    when p.product_name in ('Wegger','Panierowane skrzydełka z kurczaka') then 95  -- salt est.
    when p.product_name in ('Kanapka Cezar','High 24g protein','Gnocchi z kurczakiem','Kotlet Drobiowy') then 95  -- fiber est.
    when p.product_name in ('Bao Burger','Wieprzowiner','Kebab z kurczaka','BBQ Strips','Pasta jajeczna, por, jajko gotowane','Pierogi ruskie ze smażoną cebulką') then 100
    else 100
  end
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = 'Żabka'
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
  and p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true;

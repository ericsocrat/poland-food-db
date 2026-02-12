-- PIPELINE (ŻABKA): scoring updates
-- PIPELINE__zabka__04_scoring.sql
-- Formula-based v3.2 scoring for Żabka convenience store products.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. DEFAULT concern score for products without ingredient data
-- ═════════════════════════════════════════════════════════════════════════

update products set ingredient_concern_score = 0
where country = 'PL' and category = 'Żabka'
  and is_deprecated is not true
  and ingredient_concern_score is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
--    9 factors × weighted → clamped [1, 100]
--    sat_fat(0.17) + sugars(0.17) + salt(0.17) + calories(0.10) +
--    trans_fat(0.11) + additives(0.07) + prep_method(0.08) +
--    controversies(0.08) + concern(0.05)
-- ═════════════════════════════════════════════════════════════════════════

update products p set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      ia.additives_count,
      p.prep_method,
      p.controversies,
      p.ingredient_concern_score
  )
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. SET Nutri-Score label (from Open Food Facts where available)
--    Products marked (est.) are inferred from nutrition-score-fr value.
-- ═════════════════════════════════════════════════════════════════════════

update products p set
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
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET NOVA classification
-- ═════════════════════════════════════════════════════════════════════════

update products p set
  nova_classification = d.nova
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
where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SET health-risk flags (derived from nutrition facts)
--    Thresholds per 100 g following EU "high" front-of-pack guidelines:
--      salt ≥ 1.5 g | sugars ≥ 5 g | sat fat ≥ 5 g | additives ≥ 5
-- ═════════════════════════════════════════════════════════════════════════

update products p set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(ia.additives_count, 0) >= 5 then 'YES' else 'NO' end,
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
from nutrition_facts nf
left join (
    select pi.product_id, count(*) filter (where ir.is_additive)::int as additives_count
    from product_ingredient pi join ingredient_ref ir on ir.ingredient_id = pi.ingredient_id
    group by pi.product_id
) ia on ia.product_id = nf.product_id
where nf.product_id = p.product_id
  and p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 5. SET confidence level
-- ═════════════════════════════════════════════════════════════════════════

update products p set
  confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
where p.country = 'PL' and p.category = 'Żabka'
  and p.is_deprecated is not true;

-- PIPELINE (ŻABKA): scoring updates
-- PIPELINE__zabka__04_scoring.sql
-- Formula-based v3.2 scoring for Żabka convenience store products.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-13

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

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
-- score_category() now computes data_completeness_pct dynamically via
-- compute_data_completeness() — no manual patches needed.
CALL score_category('Żabka');

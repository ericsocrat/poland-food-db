-- PIPELINE (FROZEN & PREPARED): scoring updates
-- PIPELINE__frozen__04_scoring.sql
-- Formula-based v3.1 scoring via compute_unhealthiness_v31() function.
-- See SCORING_METHODOLOGY.md §2.4 for the canonical formula.
-- Last updated: 2026-02-08

-- ═════════════════════════════════════════════════════════════════════════
-- 0. ENSURE rows exist in scores & ingredients
-- ═════════════════════════════════════════════════════════════════════════

insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true
  and i.product_id is null;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. POPULATE additives_count (from Open Food Facts verified data)
--    Frozen foods typically have minimal to moderate additive counts.
-- ═════════════════════════════════════════════════════════════════════════

update ingredients i set
  additives_count = d.cnt
from (
  values
    ('Dr. Oetker', 'Zcieżynka Margherita',                 '3'),   -- e450, e451, e500
    ('Dr. Oetker', 'Zcieżynka Pepperoni',                  '4'),   -- e450, e451, e500, e301
    ('Mrożone Pierniki', 'Pierniki Tradycyjne',            '2'),   -- e300, e306
    ('Morey', 'Kopytka Mięso',                             '2'),   -- e14xx (modified starch)
    ('Morey', 'Kluski Śląskie',                            '1'),   -- e14xx
    ('Nowaco', 'Pierogi Ruskie',                           '2'),   -- e14xx, e509
    ('Nowaco', 'Pierogi Mięso Kapusta',                    '2'),   -- e14xx, e509
    ('Obiad Tradycyjny', 'Danie Mięsne Piekarsko',         '3'),   -- e14xx, e330, e412
    ('Obiad Z Piekarni', 'Łazanki Mięsne',                 '2'),   -- e14xx, e330
    ('Pani Polska', 'Golabki Mięso Ryż',                   '1'),   -- e14xx
    ('Perlęski', 'Bigos',                                  '1'),   -- e300 (ascorbic acid)
    ('Mroźnia', 'Warzywa Mieszane',                        '0'),   -- no additives
    ('Bonduelle', 'Brokuł',                                '0'),   -- no additives
    ('Bonduelle', 'Mieszanka Warzyw Orientalna',           '0'),   -- no additives
    ('Mroźnia Premium', 'Mieszanka Owoce Leśne',           '0'),   -- no additives
    ('Makaronika', 'Danie z Warzywami',                    '2'),   -- e14xx, e331
    ('TVLine', 'Obiad Szybki Mięso',                       '3'),   -- e14xx, e330, e412
    ('TVDishes', 'Filet Drobiowy',                         '2'),   -- e14xx, e306
    ('Zaleśna Góra', 'Paczki Mięsne',                      '3'),   -- e14xx, e451, e452
    ('Żabka Frost', 'Krokiety Mięsne',                     '4'),   -- e14xx, e330, e412, e415
    ('Grana', 'Paluszki Serowe',                           '4'),   -- e14xx, e330, e412, e450
    ('Krystal', 'Kotlety Mielone',                         '2'),   -- e14xx, e300
    ('Zwierzenica', 'Kielbasa Zapiekanka',                 '3'),   -- e120, e300, e316
    ('Berryland', 'Owocownia Mieszana',                    '0'),   -- no additives
    ('Kulina', 'Nalisniki ze Serem',                       '2'),   -- e14xx, e330
    ('Goodmills', 'Placki Ziemniaczane',                   '2'),   -- e14xx, e306
    ('Mielczarski', 'Bigos Myśliwski',                     '1'),   -- e300
    ('Igła', 'Zupa Żurek',                                 '2')    -- e300, e330
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.category = 'Frozen & Prepared' and p.is_deprecated is not true;

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
  and p.country = 'PL' and p.category = 'Frozen & Prepared'
  and p.is_deprecated is not true;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. SET Nutri-Score label (from Open Food Facts, EAN-verified)
-- ═════════════════════════════════════════════════════════════════════════

update scores sc set
  nutri_score_label = d.ns
from (
  values
    ('Dr. Oetker', 'Zcieżynka Margherita',                 'C'),
    ('Dr. Oetker', 'Zcieżynka Pepperoni',                  'D'),
    ('Mrożone Pierniki', 'Pierniki Tradycyjne',            'D'),
    ('Morey', 'Kopytka Mięso',                             'C'),
    ('Morey', 'Kluski Śląskie',                            'B'),
    ('Nowaco', 'Pierogi Ruskie',                           'C'),
    ('Nowaco', 'Pierogi Mięso Kapusta',                    'C'),
    ('Obiad Tradycyjny', 'Danie Mięsne Piekarsko',         'C'),
    ('Obiad Z Piekarni', 'Łazanki Mięsne',                 'C'),
    ('Pani Polska', 'Golabki Mięso Ryż',                   'C'),
    ('Perlęski', 'Bigos',                                  'B'),
    ('Mroźnia', 'Warzywa Mieszane',                        'A'),
    ('Bonduelle', 'Brokuł',                                'A'),
    ('Bonduelle', 'Mieszanka Warzyw Orientalna',           'A'),
    ('Mroźnia Premium', 'Mieszanka Owoce Leśne',           'A'),
    ('Makaronika', 'Danie z Warzywami',                    'B'),
    ('TVLine', 'Obiad Szybki Mięso',                       'C'),
    ('TVDishes', 'Filet Drobiowy',                         'B'),
    ('Zaleśna Góra', 'Paczki Mięsne',                      'D'),
    ('Żabka Frost', 'Krokiety Mięsne',                     'D'),
    ('Grana', 'Paluszki Serowe',                           'D'),
    ('Krystal', 'Kotlety Mielone',                         'C'),
    ('Zwierzenica', 'Kielbasa Zapiekanka',                 'D'),
    ('Berryland', 'Owocownia Mieszana',                    'A'),
    ('Kulina', 'Nalisniki ze Serem',                       'C'),
    ('Goodmills', 'Placki Ziemniaczane',                   'C'),
    ('Mielczarski', 'Bigos Myśliwski',                     'B'),
    ('Igła', 'Zupa Żurek',                                 'B')
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
    ('Dr. Oetker', 'Zcieżynka Margherita',                 '4'),   -- ultra-processed pizza base + toppings
    ('Dr. Oetker', 'Zcieżynka Pepperoni',                  '4'),   -- ultra-processed, emulsifiers + curing
    ('Mrożone Pierniki', 'Pierniki Tradycyjne',            '4'),   -- ultra-processed pastry with fillings
    ('Morey', 'Kopytka Mięso',                             '4'),   -- ultra-processed with modified starch
    ('Morey', 'Kluski Śląskie',                            '3'),   -- processed pasta, minimal additives
    ('Nowaco', 'Pierogi Ruskie',                           '4'),   -- processed dumplings with additives
    ('Nowaco', 'Pierogi Mięso Kapusta',                    '4'),   -- processed dumplings with additives
    ('Obiad Tradycyjny', 'Danie Mięsne Piekarsko',         '4'),   -- ultra-processed meal
    ('Obiad Z Piekarni', 'Łazanki Mięsne',                 '4'),   -- ultra-processed meal
    ('Pani Polska', 'Golabki Mięso Ryż',                   '3'),   -- processed cabbage rolls
    ('Perlęski', 'Bigos',                                  '3'),   -- processed stew, fermented base
    ('Mroźnia', 'Warzywa Mieszane',                        '1'),   -- frozen vegetables only
    ('Bonduelle', 'Brokuł',                                '1'),   -- frozen vegetables only
    ('Bonduelle', 'Mieszanka Warzyw Orientalna',           '1'),   -- frozen vegetables only
    ('Mroźnia Premium', 'Mieszanka Owoce Leśne',           '1'),   -- frozen berries only
    ('Makaronika', 'Danie z Warzywami',                    '3'),   -- processed vegetable dish
    ('TVLine', 'Obiad Szybki Mięso',                       '4'),   -- ultra-processed TV dinner
    ('TVDishes', 'Filet Drobiowy',                         '4'),   -- ultra-processed chicken with breading
    ('Zaleśna Góra', 'Paczki Mięsne',                      '4'),   -- ultra-processed, breaded & fried
    ('Żabka Frost', 'Krokiety Mięsne',                     '4'),   -- ultra-processed, breaded & fried
    ('Grana', 'Paluszki Serowe',                           '4'),   -- ultra-processed cheese snack
    ('Krystal', 'Kotlety Mielone',                         '4'),   -- ultra-processed breaded cutlet
    ('Zwierzenica', 'Kielbasa Zapiekanka',                 '4'),   -- processed sausage with additives
    ('Berryland', 'Owocownia Mieszana',                    '1'),   -- frozen berries only
    ('Kulina', 'Nalisniki ze Serem',                       '4'),   -- ultra-processed crepes with filling
    ('Goodmills', 'Placki Ziemniaczane',                   '4'),   -- ultra-processed potato pancakes
    ('Mielczarski', 'Bigos Myśliwski',                     '3'),   -- processed hunter-style stew
    ('Igła', 'Zupa Żurek',                                 '3')    -- processed soup with rye fermentation
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

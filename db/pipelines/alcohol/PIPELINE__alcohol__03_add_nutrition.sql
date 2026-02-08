-- PIPELINE (ALCOHOL): add nutrition facts
-- PIPELINE__alcohol__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 ml) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- 28 products across beer, radler, cider, rtd, non_alcoholic_beer, wine.
-- Missing fiber/trans_fat values defaulted to '0' per project rules.
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Alcohol so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, sv.serving_id
  from products p
  join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Alcohol'
);

-- 2) Insert verified per-SKU nutrition
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  sv.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- ═══════════════════════════════════════════════════════════════════════
    -- BEER — alcoholic (4)
    -- ═══════════════════════════════════════════════════════════════════════
    --              brand             product_name                                                       cal    fat    sat    trans  carbs  sug    fib    prot   salt
    -- EAN 5900490000182 — Lech Premium (5% ABV)
    ('Lech',           'Lech Premium',                                                       '41',  '0.1', '0.1', '0',   '2.8', '0.8', '0',   '0.6', '0.1'),
    -- EAN 5901359062013 — Tyskie Gronie (5.2% ABV)
    ('Tyskie',         'Tyskie Gronie',                                                      '43',  '0',   '0',   '0',   '3',   '0.2', '0',   '0.5', '0'),
    -- EAN 5901359001000 — Żubr Premium (5% ABV)
    ('Żubr',           'Żubr Premium',                                                       '41',  '0',   '0',   '0',   '2.6', '0.5', '0',   '0.7', '0'),
    -- EAN 5901359009232 — Zywiec Full (5.6% ABV)
    ('Zywiec',         'Zywiec Full',                                                        '44',  '0',   '0',   '0',   '3.2', '0.3', '0',   '0.5', '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- RADLER — alcoholic (1)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5900699106463 — Piwo Warka Radler (2% ABV)
    ('Warka',          'Piwo Warka Radler',                                                  '26',  '0',   '0',   '0',   '6.4', '4.5', '0',   '0',   '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- CIDER — alcoholic (1)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 3856777584161 — Somersby Blueberry (4.5% ABV)
    ('Somersby',       'Somersby Blueberry Flavoured Cider',                                  '57',  '0',   '0',   '0',   '7.7', '7.5', '0',   '0',   '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- NON-ALCOHOLIC BEER (14)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5900014002227 — Karmi (0.5% ABV)
    ('Karmi',          'Karmi',                                                              '36',  '0',   '0',   '0',   '8.4', '7',   '0',   '0.3', '0'),
    -- EAN 5900535013986 — Łomża bezalkoholowe (0.0% ABV)
    ('Łomża',          'Łomża piwo jasne bezalkoholowe',                                     '24',  '0',   '0',   '0',   '5.5', '3.3', '0',   '0.5', '0.01'),
    -- EAN 5901359084954 — Lech Free granat i acai
    ('Lech',           'Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai',          '27',  '0',   '0',   '0',   '7.1', '6',   '0',   '0',   '0'),
    -- EAN 5901359114309 — Lech Free smoczy owoc i winogrono
    ('Lech',           'Lech Free smoczy owoc i winogrono 0,0%',                              '22',  '0',   '0',   '0',   '5.7', '4.6', '0',   '0',   '0'),
    -- EAN 5901359122021 — Lech Free classic
    ('Lech',           'Lech Free',                                                          '22',  '0',   '0',   '0',   '5.5', '3',   '0',   '0',   '0'),
    -- EAN 5900014003293 — Okocim 0%
    ('Okocim',         'Okocim Piwo Jasne 0%',                                               '10',  '0',   '0',   '0',   '2.5', '0',   '0',   '0',   '0'),
    -- EAN 5901359124230 — Lech Free Active Hydrate mango & cytryna
    ('Lech',           'Lech Free Active Hydrate mango i cytryna 0,0%',                       '21',  '0',   '0',   '0',   '5.4', '4.3', '0',   '0',   '0.17'),
    -- EAN 5900535022551 — Łomża 0% jabłko & mięta
    ('Łomża',          'Łomża 0% o smaku jabłko & mięta',                                    '26',  '0',   '0',   '0',   '6',   '4.7', '0',   '0.5', '0.01'),
    -- EAN 5901359154794 — Lech Free grejpfrut i guawa
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku grejpfruta i guawy',        '12',  '0',   '0',   '0',   '3.1', '1.7', '0',   '0',   '0'),
    -- EAN 5901359144627 — Lech Free arbuz mięta
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku arbuz mięta',               '22',  '0',   '0',   '0',   '5.7', '4.3', '0',   '0',   '0'),
    -- EAN 5901359144818 — Lech Free jeżyna i wiśnia
    ('Lech',           'Lech Free 0,0% piwo bezalkoholowe o smaku jeżyny i wiśni',            '24',  '0',   '0',   '0',   '6',   '4.8', '0',   '0',   '0'),
    -- EAN 5901359144689 — Lech Free Citrus Sour
    ('Lech',           'Lech Free Citrus Sour',                                              '21',  '0',   '0',   '0',   '5.4', '4.1', '0',   '0',   '0'),
    -- EAN 5901359144887 — Lech Free limonka i mięta
    ('Lech',           'Lech Free 0,0% limonka i mięta',                                     '28',  '0',   '0',   '0',   '7.4', '5.8', '0',   '0',   '0'),
    -- EAN 5901359154831 — Lech Free yuzu i pomelo
    ('Lech',           'Lech Free 0,0% piwo o smaku yuzu i pomelo',                           '23',  '0',   '0',   '0',   '5.8', '4.6', '0',   '0',   '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- NON-ALCOHOLIC RADLER (4)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 2008080099073 — Free! Radler mango (Karlsquell / Van Pur)
    ('Karlsquell',     'Free! Radler o smaku mango',                                         '23',  '0',   '0',   '0',   '5.3', '4.1', '0',   '0.5', '0.01'),
    -- EAN 5902746641835 — Warka Kiwi Z Pigwą 0,0%
    ('Warka',          'Warka Kiwi Z Pigwą 0,0%',                                            '24',  '0',   '0',   '0',   '6',   '4.3', '0',   '0',   '0'),
    -- EAN 5900014003620 — Okocim 0,0% mango z marakują
    ('Okocim',         'Okocim 0,0% mango z marakują',                                       '23',  '0',   '0',   '0',   '5.6', '4.4', '0',   '0',   '0'),
    -- EAN 5900535019209 — Łomża Radler 0,0%
    ('Łomża',          'Łomża Radler 0,0%',                                                  '26',  '0',   '0',   '0',   '6.1', '4.8', '0',   '0.5', '0.01'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- NON-ALCOHOLIC RTD (1)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5900014005587 — Somersby blackcurrant & lime 0%
    ('Somersby',       'Somersby blackcurrant & lime 0%',                                     '29',  '0',   '0',   '0',   '6.8', '5.8', '0',   '0',   '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- NON-ALCOHOLIC CIDER (1)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5906395413423 — Dzik Cydr 0% jabłko i marakuja
    ('Dzik',           'Dzik Cydr 0% jabłko i marakuja',                                      '29',  '0',   '0',   '0',   '7',   '7',   '0',   '0',   '0'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- NON-ALCOHOLIC WINE (2)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 4003301069086 — Just 0. White alcoholfree
    ('Just 0.',        'Just 0. White alcoholfree',                                           '29',  '0',   '0',   '0',   '6.8', '6.3', '0',   '0',   '0'),
    -- EAN 4003301069048 — Just 0. Red
    ('Just 0.',        'Just 0. Red',                                                         '22',  '0',   '0',   '0',   '4.9', '4.3', '0',   '0',   '0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g';

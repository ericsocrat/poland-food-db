-- PIPELINE (BABY): add nutrition facts
-- PIPELINE__baby__03_add_nutrition.sql
-- Real per-SKU nutrition data (per 100 g) from Open Food Facts.
-- Source: openfoodfacts.org — verified against Polish-market product labels.
-- 26 products across baby_cereal, baby_puree_fruit, baby_puree_dinner, baby_snack, toddler_pouch.
-- Missing fiber/trans_fat values defaulted to '0' per project rules.
-- Last updated: 2026-02-08

-- 1) Remove existing nutrition for PL Baby so this step is fully idempotent
delete from nutrition_facts
where (product_id, serving_id) in (
  select p.product_id, sv.serving_id
  from products p
  join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = 'Baby'
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
    -- BABY CEREAL (6)
    -- ═══════════════════════════════════════════════════════════════════════
    -- brand,            product_name,                                                kcal,   fat,   sat,  trans, carbs, sugar, fiber, prot,  salt
    -- EAN 5900852999383 — BoboVita Kaszka Zbożowa Jabłko Śliwka
    ('BoboVita',        'BoboVita Kaszka Zbożowa Jabłko Śliwka',                     '369', '2.1', '0',   '0',  '73',  '18',  '11',  '9.4', '0.01'),
    -- EAN 5900852041129 — BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa
    ('BoboVita',        'BoboVita Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa',   '428', '12',  '2.7', '0',  '61',  '31',  '5.9', '16',  '0.29'),
    -- EAN 5900852038112 — BoboVita Kaszka Mleczna Ryżowa 3 Owoce
    ('BoboVita',        'BoboVita Kaszka Mleczna Ryżowa 3 Owoce',                   '428', '9.8', '2.4', '0',  '71',  '31',  '1',   '13',  '0.255'),
    -- EAN 4062300279773 — HiPP Kaszka mleczna z biszkoptami i jabłkami
    ('HiPP',           'HiPP Kaszka mleczna z biszkoptami i jabłkami',               '78',  '3',   '1.4', '0',  '10.7','4.8', '0.4', '1.9', '0.05'),
    -- EAN 7613287666819 — Nestlé Sinlac
    ('Nestlé',         'Nestlé Sinlac',                                              '431', '11.5','0.9', '0',  '64.6','4.5', '3.8', '15.3','0.1'),
    -- EAN 7613287173997 — Gerber Pełnia Zbóż Owsianka 5 Zbóż
    ('Gerber',         'Gerber Pełnia Zbóż Owsianka 5 Zbóż',                        '97',  '2.6', '0.3', '0',  '14.5','6.5', '0.8', '3.6', '0.06'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- BABY PUREE — FRUIT (7)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5900852068812 — BoboVita Delikatne jabłka z bananem
    ('BoboVita',        'BoboVita Delikatne jabłka z bananem',                       '52',  '0.1', '0',   '0',  '12',  '8.4', '1',   '0.4', '0'),
    -- EAN 8591119253934 — BoboVita Jabłka i banana
    ('BoboVita',        'BoboVita Jabłka i banana',                                 '52',  '0.1', '0',   '0',  '12',  '8.5', '1',   '0.4', '0'),
    -- EAN 7613033629303 — Gerber owoce jabłka z truskawkami i jagodami
    ('Gerber',         'Gerber owoce jabłka z truskawkami i jagodami',               '51.1','0.105','0',  '0',  '11.6','6.89','1.11','0.316','0'),
    -- EAN 22009326 — GutBio Puré de Frutas Manzana y Plátano
    ('GutBio',         'GutBio Puré de Frutas Manzana y Plátano',                   '63',  '0.5', '0.1', '0',  '13',  '12',  '0',   '0.6', '0.01'),
    -- EAN 5900334003935 — Tymbark Mus gruszka jabłko
    ('Tymbark',        'Tymbark Mus gruszka jabłko',                                '66',  '0.5', '0.1', '0',  '14',  '13',  '1.5', '0.7', '0.01'),
    -- EAN 8436550903003 — dada baby food bio mus kokos
    ('dada baby food', 'dada baby food bio mus kokos',                              '88',  '2.8', '2.6', '0',  '13',  '11',  '3.4', '1',   '0.01'),
    -- EAN 8445290594334 — Bobo Frut Jabłko marchew
    ('Bobo Frut',      'Bobo Frut Jabłko marchew',                                  '29',  '0.2', '0',   '0',  '6',   '6',   '1',   '0.4', '0.03'),
    -- EAN 5901958612404 — OWOLOVO Siła & Moc Mus Jabłkowo-Buraczany
    ('OWOLOVO',        'OWOLOVO Siła & Moc Mus Jabłkowo-Buraczany',                 '75',  '0',   '0',   '0',  '17',  '16',  '1.4', '1',   '0.08'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- BABY PUREE — DINNER (7)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 7613033512353 — Gerber Krem jarzynowy ze schabem
    ('Gerber',         'Gerber Krem jarzynowy ze schabem',                           '57',  '1.7', '0.3', '0',  '7.1', '1.9', '1.5', '2.6', '0.05'),
    -- EAN 7613035507142 — Gerber Leczo z mozzarellą i kluseczkami
    ('Gerber',         'Gerber Leczo z mozzarellą i kluseczkami',                    '70',  '2.4', '0.7', '0',  '9',   '2.3', '1.5', '2.4', '0.21'),
    -- EAN 8445291546967 — Gerber Warzywa z delikatnym indykiem w pomidorach
    ('Gerber',         'Gerber Warzywa z delikatnym indykiem w pomidorach',           '55',  '1.9', '0.3', '0',  '6.1', '3.3', '1.7', '2.5', '0.07'),
    -- EAN 8445291546851 — Gerber Bukiet warzyw z łososiem w sosie pomidorowym
    ('Gerber',         'Gerber Bukiet warzyw z łososiem w sosie pomidorowym',         '44',  '1.4', '0.2', '0',  '5',   '9',   '1.4', '2.1', '0.06'),
    -- EAN 5900852150005 — BoboVita Pomidorowa z kurczakiem i ryżem
    ('BoboVita',       'BoboVita Pomidorowa z kurczakiem i ryżem',                   '56',  '1.8', '0.2', '0',  '6.3', '2.8', '1.1', '3.1', '0.08'),
    -- EAN 9062300109365 — HiPP Dynia z indykiem (fiber missing on OFF → 0)
    ('HiPP',          'HiPP Dynia z indykiem',                                      '59',  '2.5', '0.4', '0',  '5.7', '2.9', '0',   '2.9', '0.05'),
    -- EAN 9062300130833 — HiPP Spaghetti z pomidorami i mozzarellą (fiber missing on OFF → 0)
    ('HiPP',          'HiPP Spaghetti z pomidorami i mozzarellą',                   '75',  '3',   '0.7', '0',  '8.2', '3.1', '0',   '3.2', '0.1'),
    -- EAN 9062300126638 — HiPP Ziemniaki z buraczkami, jabłkiem i wołowiną
    ('HiPP',          'HiPP Ziemniaki z buraczkami, jabłkiem i wołowiną',           '45',  '1.2', '0.4', '0',  '5.5', '1.8', '0.9', '2.6', '0.08'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- BABY SNACK (1)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 8000300435351 — Gerber organic Krakersy z pomidorem po 12 miesiącu
    ('Gerber',         'Gerber organic Krakersy z pomidorem po 12 miesiącu',         '440', '12',  '9',   '0',  '71',  '8',   '2',   '11',  '0.05'),

    -- ═══════════════════════════════════════════════════════════════════════
    -- TODDLER POUCH (5)
    -- ═══════════════════════════════════════════════════════════════════════
    -- EAN 5901958612381 — OWOLOVO MORELOWO
    ('OWOLOVO',        'OWOLOVO MORELOWO',                                           '48',  '0',   '0',   '0',  '11',  '11',  '1.2', '0.5', '0'),
    -- EAN 5901958612367 — OWOLOVO Truskawkowo Mus jabłkowo-truskawkowy
    ('OWOLOVO',        'OWOLOVO Truskawkowo Mus jabłkowo-truskawkowy',               '51',  '0.5', '0.1', '0',  '13',  '11',  '1.3', '0.5', '0.01'),
    -- EAN 5901958614408 — OWOLOVO Ananasowo
    ('OWOLOVO',        'OWOLOVO Ananasowo',                                          '46',  '0',   '0',   '0',  '10',  '9.5', '1.7', '0.5', '0'),
    -- EAN 5901958612640 — OWOLOVO Mus jabłkowo-wiśniowy
    ('OWOLOVO',        'OWOLOVO Mus jabłkowo-wiśniowy',                              '55',  '0',   '0',   '0',  '13',  '13',  '1.5', '0.5', '0.01'),
    -- EAN 5901958614996 — OWOLOVO Smoothie tropikalne Jabłko Morela Pomarańcza
    ('OWOLOVO',        'OWOLOVO Smoothie tropikalne Jabłko Morela Pomarańcza',       '45',  '0',   '0',   '0',  '11',  '9.2', '0.7', '0.5', '0')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g';

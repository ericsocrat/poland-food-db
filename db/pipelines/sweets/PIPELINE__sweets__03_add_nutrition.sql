-- PIPELINE (SWEETS): add nutrition facts
-- PIPELINE__sweets__03_add_nutrition.sql
-- All values per 100 g from Open Food Facts (EAN-verified).
-- Last updated: 2026-02-07

-- ═══════════════════════════════════════════════════════════════════
-- UPSERT nutrition facts (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into nutrition_facts (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  sv.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
    -- CHOCOLATE TABLETS
    --              brand             product_name                                 cal    fat    sat    trans  carbs   sug    fib    prot   salt
    ('Wawel',                  'Wawel Czekolada Gorzka 70%',             '576', '43',   '27',   '0', '32',   '28',   '0',   '9.8',  '0.02'),
    ('Wawel',                  'Wawel Mleczna z Rodzynkami i Orzeszkami', '539', '33',   '18',   '0', '52',   '46',   '0',   '7',    '0.15'),
    ('Wedel',                  'Wedel Czekolada Gorzka 80%',             '558', '45',   '27',   '0', '21',   '16',   '16',  '10',   '0.02'),
    ('Wedel',                  'Wedel Czekolada Mleczna',                '530', '30',   '19',   '0', '58',   '57',   '2.5', '6',    '0.25'),
    ('Wedel',                  'Wedel Mleczna z Bakaliami',              '502', '27',   '12',   '0', '56',   '55',   '0',   '8',    '0.16'),
    ('Wedel',                  'Wedel Mleczna z Orzechami',              '576', '38',   '16',   '0', '50',   '48',   '0',   '7.8',  '0.21'),
    ('Milka',                  'Milka Alpenmilch',                       '539', '31',   '19',   '0', '57',   '55',   '2.3', '6.5',  '0.28'),
    ('Milka',                  'Milka Trauben-Nuss',                     '508', '28',   '15',   '0', '57',   '53',   '3',   '6.2',  '0.22'),
    -- FILLED CHOCOLATES / PRALINES
    ('Wawel',                  'Wawel Tiki Taki Kokosowo-Orzechowe',     '564', '37',   '22',   '0', '47',   '45',   '0',   '8.1',  '0.09'),
    ('Wawel',                  'Wawel Tiramisu Nadziewana',              '521', '30',   '19',   '0', '55',   '50',   '0',   '6.3',  '0.16'),
    ('Wawel',                  'Wawel Czekolada Karmelowe',              '499', '28',   '17',   '0', '56',   '49',   '0',   '4',    '0.05'),
    ('Wawel',                  'Wawel Kasztanki Nadziewana',             '537', '31',   '21',   '0', '57',   '50',   '0',   '5.3',  '0.08'),
    ('Wedel',                  'Wedel Mleczna Truskawkowa',              '499', '26',   '13',   '0', '62',   '59',   '1.6', '4.6',  '0.15'),
    ('Solidarność',            'Solidarność Śliwki w Czekoladzie',       '434', '18',   '11',   '0', '62',   '60',   '0',   '3.6',  '0.04'),
    -- WAFER BARS
    ('Prince Polo',            'Prince Polo XXL Classic',                '526', '29',   '16',   '0', '58',   '39',   '3.8', '5.6',  '0.32'),
    ('Prince Polo',            'Prince Polo XXL Mleczne',               '526', '28',   '15',   '0', '63',   '41',   '2',   '5.1',  '0.23'),
    ('Grześki',                'Grześki Mini Chocolate',                 '530', '30',   '18',   '0', '54',   '35',   '0',   '9.4',  '0.3'),
    ('Grześki',                'Grześki Wafer Toffee',                   '530', '29',   '18',   '0', '58',   '35',   '0',   '7.8',  '0.32'),
    ('Kinder',                 'Kinder Bueno Mini',                      '572', '36.6', '17.6', '0', '49.2', '40.6', '0',   '8.37', '0.27'),
    -- CHOCOLATE BARS
    ('Kinder',                 'Kinder Chocolate Bar',                   '566', '35',   '22.6', '0', '53.5', '53.5', '0',   '8.7',  '0.31'),
    ('Snickers',               'Snickers Bar',                           '481', '22.5', '7.9',  '0', '60.5', '51.8', '4.3', '8.6',  '0.629'),
    ('Twix',                   'Twix Twin',                              '492', '23.6', '14',   '0', '64',   '49.2', '1.6', '4.4',  '0.4'),
    -- BISCUITS / COOKIES
    ('Kinder',                 'Kinder Cards',                           '510', '26.3', '13.5', '0', '55.9', '42.9', '0',   '11.5', '0.45'),
    ('Goplana',                'Goplana Jeżyki Cherry',                  '470', '20',   '12',   '0', '66',   '45',   '0',   '4.3',  '0.27'),
    ('Delicje',                'Delicje Szampańskie Wiśniowe',            '360', '7.1',  '3.3',  '0', '70',   '51',   '1.3', '3.3',  '0.24'),
    -- MARSHMALLOW / CONFECTIONERY
    ('Wedel',                  'Wedel Ptasie Mleczko Waniliowe',         '442', '22',   '14',   '0', '57',   '48',   '2.8', '2.8',  '0.07'),
    ('Wedel',                  'Wedel Ptasie Mleczko Gorzka 80%',        '451', '26',   '16',   '0', '47',   '37',   '5.4', '4.5',  '0.08'),
    -- GUMMY CANDY
    ('Haribo',                 'Haribo Goldbären',                       '340', '0.5',  '0.1',  '0', '77',   '46',   '0',   '6.9',  '0.07')
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
  calories        = excluded.calories,
  total_fat_g     = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g     = excluded.trans_fat_g,
  carbs_g         = excluded.carbs_g,
  sugars_g        = excluded.sugars_g,
  fibre_g         = excluded.fibre_g,
  protein_g       = excluded.protein_g,
  salt_g          = excluded.salt_g;

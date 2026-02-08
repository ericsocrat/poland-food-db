-- PIPELINE (SAUCES): add nutrition facts
-- PIPELINE__sauces__03_add_nutrition.sql
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
    -- KETCHUP / BBQ
    --              brand             product_name                                 cal    fat    sat    trans  carbs   sug    fib    prot   salt
    ('Heinz',          'Heinz Tomato Ketchup',                      '102', '0.1',  '0',    '0', '23.2', '22.8', '0',   '1.2',  '1.8'),
    ('Heinz',          'Heinz Ketchup Zero',                        '44',  '0.1',  '0',    '0', '5.4',  '4.4',  '0',   '1.6',  '0.06'),
    ('Pudliszki',      'Pudliszki Ketchup Łagodny',                 '109', '0.1',  '0.1',  '0', '25',   '22',   '0',   '1.7',  '2.36'),
    ('Kotlin',         'Kotlin Ketchup Łagodny',                    '97',  '0.5',  '0.1',  '0', '21',   '18',   '0',   '1.4',  '1.97'),
    ('Heinz',          'Heinz Sos Barbecue',                        '142', '0.2',  '0',    '0', '34',   '30',   '0',   '0.8',  '2.4'),
    -- MUSTARD
    ('Kamis',          'Kamis Musztarda Sarepska Ostra',             '101', '5.1',  '0.3',  '0', '8.3',  '6.9',  '0',   '3.7',  '2.52'),
    ('Kamis',          'Kamis Musztarda Delikatesowa',               '100', '4.4',  '0.3',  '0', '10',   '8.7',  '0',   '3.3',  '2.52'),
    ('Roleski',        'Roleski Musztarda Sarepska',                 '141', '5.9',  '0.2',  '0', '16',   '12',   '0',   '4.6',  '1.9'),
    ('Roleski',        'Roleski Musztarda Delikatesowa',             '104', '4.2',  '0.2',  '0', '11',   '9.5',  '0',   '4.8',  '2.1'),
    ('Roleski',        'Roleski Musztarda Stołowa',                  '127', '4.6',  '0.2',  '0', '16',   '12',   '0',   '4',    '2'),
    -- MAYONNAISE
    ('Winiary',        'Winiary Majonez Dekoracyjny',                '704', '76.3', '5.3',  '0', '2.9',  '2.3',  '0',   '1.5',  '0.59'),
    ('Społem Kielce',  'Majonez Kielecki',                           '631', '68',   '5.3',  '0', '2.3',  '2',    '0',   '1.9',  '1'),
    ('Hellmann''s',    'Hellmann''s Majonez Babuni',                  '604', '64',   '5.1',  '0', '4.6',  '4',    '0',   '0.8',  '0.99'),
    -- TOMATO SAUCE / PASSATA
    ('Pudliszki',      'Pudliszki Koncentrat Pomidorowy',            '105', '0.5',  '0.1',  '0', '19',   '15',   '3.6', '4.7',  '0.06'),
    ('Pudliszki',      'Pudliszki Pomidory Krojone',                 '18',  '0.2',  '0.1',  '0', '2.9',  '2.9',  '0.8', '0.7',  '0.04'),
    ('Łowicz',         'Łowicz Przecier Pomidorowy',                  '24',  '0.25', '0.04', '0', '3.75', '3.75', '0',   '1.25', '0.15'),
    ('Dawtona',        'Dawtona Przecier z Polskimi Ziołami',         '22',  '0',    '0',    '0', '3.8',  '3.8',  '0.9', '1.3',  '0.65'),
    -- SOY / ASIAN SAUCE
    ('Kikkoman',       'Kikkoman Sos Sojowy',                         '77',  '0',    '0',    '0', '3.2',  '0.6',  '0',   '10',   '16.9'),
    ('Kikkoman',       'Kikkoman Sos Teriyaki',                       '99',  '0',    '0',    '0', '12',   '11',   '0',   '6.7',  '10.2'),
    -- HOT SAUCE (salt corrected from OFF error 0.02→1.8; salt is 3rd ingredient)
    ('Flying Goose',   'Flying Goose Sriracha',                       '139', '1.2',  '0.2',  '0', '28',   '22',   '3.1', '2.3',  '1.8'),
    -- HORSERADISH
    ('Krakus',         'Krakus Chrzan',                               '157', '9.8',  '0.7',  '0', '12',   '9.5',  '0',   '2.7',  '1.4'),
    ('Prymat',         'Prymat Chrzan Tarty',                         '126', '5.5',  '0.5',  '0', '14',   '13',   '0',   '2.2',  '0.5'),
    ('Motyl',          'Motyl Chrzan Staropolski',                    '147', '6.4',  '0.5',  '0', '17',   '9',    '0',   '3',    '0.94'),
    ('Polonaise',      'Polonaise Chrzan Tarty',                      '102', '0.7',  '0.1',  '0', '18',   '18',   '0',   '2.7',  '0.67'),
    -- DRESSING / GARLIC SAUCE
    ('Develey',        'Develey Sos 1000 Wysp Madero',                '271', '25',   '1.9',  '0', '11',   '9',    '0.6', '0.7',  '1'),
    ('Develey',        'Develey Sos 1000 Wysp',                       '332', '30',   '2.3',  '0', '13',   '11',   '0',   '0.6',  '0.73'),
    ('Develey',        'Develey Sos Czosnkowy',                       '224', '20',   '1.5',  '0', '8.9',  '5',    '0',   '0.8',  '1.6'),
    -- SWEET & SOUR SAUCE
    ('Pudliszki',      'Pudliszki Sos Słodko-Kwaśny',                 '85',  '0',    '0',    '0', '20',   '13',   '0',   '0.5',  '1.5')
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

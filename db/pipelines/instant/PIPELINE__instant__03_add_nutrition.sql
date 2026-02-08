-- PIPELINE (INSTANT & FROZEN): add nutrition facts
-- PIPELINE__instant__03_add_nutrition.sql
-- Instant noodles/soups: values per 100 g prepared (as labeled in PL).
-- Frozen products: values per 100 g (as packaged).
-- All from Open Food Facts (EAN-verified).
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
    -- INSTANT NOODLES / SOUPS (per 100 g prepared)
    --              brand             product_name                                 cal    fat    sat    trans  carbs   sug    fib    prot   salt
    ('Knorr',           'Knorr Nudle Pomidorowe Pikantne',      '90',  '4.0',  '1.9',  '0', '11',   '1.5',  '0.5', '2.0',  '1.0'),
    ('Knorr',           'Knorr Nudle Pieczony Kurczak',         '90',  '4.0',  '1.9',  '0', '11',   '0.6',  '0.5', '1.9',  '0.88'),
    ('Knorr',           'Knorr Nudle Ser w Ziołach',            '94',  '4.8',  '2.5',  '0', '10',   '0.6',  '0.5', '1.8',  '0.98'),
    ('Amino',           'Amino Barszcz Czerwony',               '78',  '3.5',  '1.5',  '0', '10',   '1.6',  '0.5', '1.3',  '0.71'),
    ('Amino',           'Amino Rosół z Makaronem',              '61',  '2.75', '1.3',  '0', '8',    '0.2',  '0.5', '1.2',  '1.0'),
    ('Amino',           'Amino Żurek po Śląsku',                '85',  '3.7',  '1.8',  '0', '11',   '1.2',  '0.5', '1.7',  '1.0'),
    ('Vifon',           'Vifon Kurczak Złocisty',               '85',  '3.5',  '1.5',  '0', '11',   '0.8',  '0.5', '2.0',  '1.1'),
    -- FROZEN PIZZA (per 100 g)
    ('Iglotex',         'Iglotex Pizza Kurczak ze Szpinakiem',   '213', '8.3',  '2.4',  '0', '24',   '2.7',  '1.5', '9.3',  '1.2'),
    ('Iglotex',         'Iglotex Pizza Cztery Sery',             '241', '11',   '3.9',  '0', '26',   '2.8',  '1.5', '9.3',  '1.1'),
    ('Iglotex',         'Iglotex Pizza Szynka z Pieczarkami',    '191', '6.1',  '2.1',  '0', '24',   '2.8',  '1.5', '8.4',  '0.95'),
    ('Iglotex',         'Iglotex Pizza z Szynką Wieprzową',      '170', '3.3',  '1.6',  '0', '26',   '1.6',  '1.5', '7.7',  '1.2'),
    ('Dr. Oetker',      'Guseppe Pizza Quattro Formaggi',        '285', '12.5', '5.37', '0', '33',   '2.99', '1.52','9.55', '0.97'),
    ('Proste Historie', 'Proste Historie Pizza Warzywna',        '181', '6.4',  '3.2',  '0', '26',   '2.7',  '1.5', '4.1',  '1.0'),
    ('Dr. Oetker',      'Feliciana Pizza Prosciutto e Funghi',   '238', '7.3',  '3.5',  '0', '33',   '3.0',  '1.5', '9.6',  '1.2'),
    -- FROZEN PIEROGI (per 100 g)
    ('Swojska Chata',   'Swojska Chata Pierogi Ruskie',          '164', '4.1',  '0.7',  '0', '25',   '1.4',  '2.3', '5.7',  '0.98'),
    ('Nasze Smaki',     'Nasze Smaki Pierogi Ruskie z Cebulką',  '175', '4.6',  '0.7',  '0', '26',   '3.1',  '1.7', '6.1',  '1.3'),
    ('Virtu',           'Virtu Pierogi Ruskie',                  '179', '3.7',  '0.5',  '0', '29.1', '2.8',  '1.5', '6.2',  '1.25'),
    ('Virtu',           'Virtu Pierogi z Kapustą i Grzybami',    '165', '4.2',  '0.6',  '0', '26',   '1.3',  '1.5', '5.3',  '1.1'),
    ('Virtu',           'Virtu Pierogi z Serem',                 '187', '2.2',  '0.9',  '0', '32.1', '8.8',  '1.0', '8.8',  '0.3'),
    ('Virtu',           'Virtu Pierogi z Mięsem',                '185', '5.7',  '2.1',  '0', '24',   '2.2',  '1.0', '7.8',  '1.2'),
    ('Virtu',           'Virtu Pierogi Wegańskie a''la Mięsne',  '198', '4.9',  '0.4',  '0', '28',   '0.9',  '1.5', '9.4',  '1.0'),
    -- FROZEN READY MEALS (per 100 g)
    ('FRoSTA',          'FRoSTA Złoty Mintaj',                   '189', '6.8',  '0.7',  '0', '19',   '1.2',  '1.0', '13.1', '0.7'),
    ('Iglotex',         'Iglotex Paluszki Rybne',                '210', '10',   '1.2',  '0', '20',   '1.0',  '1.5', '11',   '0.8'),
    -- CUP SOUPS (per 100 g prepared)
    ('Knorr',           'Gorący Kubek Ogórkowa z Grzankami',     '23',  '0.6',  '0.3',  '0', '3.8',  '0.9',  '0.5', '0.5',  '1.1'),
    ('Knorr',           'Gorący Kubek Cebulowa z Grzankami',     '33',  '1.0',  '0.5',  '0', '5.2',  '1.0',  '0.5', '0.6',  '0.87'),
    ('Knorr',           'Gorący Kubek Żurek z Grzankami',        '30',  '0.9',  '0.4',  '0', '4.5',  '0.8',  '0.3', '0.5',  '0.9'),
    ('Frużel',          'Frużel Instant Żurek',                 '88',  '3.2',  '1.6',  '0', '12',   '1.1',  '0.5', '1.8',  '1.05'),
    ('Maggi',           'Maggi Cup Mushroom',                   '35',  '1.2',  '0.6',  '0', '5.5',  '1.2',  '0.5', '0.7',  '0.95')
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

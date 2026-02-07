-- PIPELINE (DAIRY): add nutrition facts
-- PIPELINE__dairy__03_add_nutrition.sql
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
    -- MILKS
    --          brand        product_name                           cal   fat   sat   trans  carbs  sug   fib   prot  salt
    ('Mlekovita',  'Mlekovita Mleko UHT 2%',             '50',  '2.0', '1.3', '0',  '4.7', '4.7', '0', '3.2', '0.1'),
    ('Łaciate',    'Łaciate Mleko 3.2%',                 '60',  '3.2', '2.0', '0',  '4.7', '4.7', '0', '3.2', '0.1'),
    ('Łaciate',    'Łaciate Mleko 2%',                   '50',  '2.0', '1.2', '0',  '4.8', '4.8', '0', '3.3', '0.1'),
    -- YOGURTS
    ('Danone',     'Activia Jogurt Naturalny',           '74',  '3.6', '2.4', '0',  '5.7', '5.7', '0', '3.4', '0.17'),
    ('Zott',       'Jogobella Brzoskwinia',              '91',  '2.7', '1.8', '0', '12.2','11.7', '0', '3.5', '0.14'),
    ('Zott',       'Zott Jogurt Naturalny',              '67',  '3.1', '2.1', '0',  '4.0', '4.0', '0', '4.8', '0.17'),
    ('Piątnica',   'Piątnica Skyr Naturalny',            '64',  '0',   '0',   '0',  '4.1', '4.1', '0','12.0', '0.1'),
    -- CHEESE / TWARÓG
    ('Piątnica',   'Piątnica Serek Wiejski',             '97',  '5.0', '3.5', '0',  '2.0', '1.5', '0','11.0', '0.69'),
    ('Hochland',   'Almette Śmietankowy',               '256','24.0','17.0', '0',  '3.2', '3.2', '0', '6.7', '0.61'),
    ('Piątnica',   'Piątnica Twaróg Półtłusty',         '115', '4.0', '2.4', '0',  '3.8', '3.8', '0','16.0', '0.11'),
    -- KEFIR
    ('Mlekovita',  'Mlekovita Kefir Naturalny',          '48',  '1.5', '0.9', '0',  '4.9', '4.9', '0', '3.8', '0.1'),
    ('Bakoma',     'Bakoma Kefir Naturalny',             '56',  '2.5', '1.7', '0',  '4.9', '4.9', '0', '3.6', '0.1'),
    -- BUTTER
    ('Mlekovita',  'Mlekovita Masło Ekstra',            '746','82.0','54.0', '0',  '1.0', '1.0', '0', '1.0', '0.02'),
    ('Łaciate',    'Łaciate Masło Extra',                '753','83.0','54.0', '0',  '0.8', '0.8', '0', '0.6', '0'),
    -- CREAM
    ('Piątnica',   'Piątnica Śmietana 18%',             '191','18.0','11.0', '0',  '4.8', '3.6', '0', '2.5', '0.1'),
    -- DESSERT
    ('Danio',      'Danio Serek Waniliowy',              '99',  '2.9', '1.9', '0', '12.8','11.6', '0', '5.3', '0.08')
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

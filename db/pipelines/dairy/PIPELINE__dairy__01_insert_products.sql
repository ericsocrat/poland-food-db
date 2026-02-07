-- PIPELINE (DAIRY): insert products
-- PIPELINE__dairy__01_insert_products.sql
-- 16 Polish dairy products verified via Open Food Facts.
-- Categories: milk, yogurt, cheese/twaróg, kefir, butter, cream, dessert.
-- Last updated: 2026-02-07

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- MILKS (3)
  ('PL', 'Mlekovita',  'milk',       'Dairy', 'Mlekovita Mleko UHT 2%',             'none', 'widespread',     'none'),
  ('PL', 'Łaciate',    'milk',       'Dairy', 'Łaciate Mleko 3.2%',                 'none', 'widespread',     'none'),
  ('PL', 'Łaciate',    'milk',       'Dairy', 'Łaciate Mleko 2%',                   'none', 'widespread',     'none'),
  -- YOGURTS (4)
  ('PL', 'Danone',     'yogurt',     'Dairy', 'Activia Jogurt Naturalny',           'none', 'widespread',     'none'),
  ('PL', 'Zott',       'yogurt',     'Dairy', 'Jogobella Brzoskwinia',              'none', 'widespread',     'none'),
  ('PL', 'Zott',       'yogurt',     'Dairy', 'Zott Jogurt Naturalny',              'none', 'widespread',     'none'),
  ('PL', 'Piątnica',   'yogurt',     'Dairy', 'Piątnica Skyr Naturalny',            'none', 'widespread',     'none'),
  -- CHEESE / TWARÓG (3)
  ('PL', 'Piątnica',   'cheese',     'Dairy', 'Piątnica Serek Wiejski',             'none', 'widespread',     'none'),
  ('PL', 'Hochland',   'cheese',     'Dairy', 'Almette Śmietankowy',               'none', 'widespread',     'none'),
  ('PL', 'Piątnica',   'cheese',     'Dairy', 'Piątnica Twaróg Półtłusty',         'none', 'widespread',     'none'),
  -- KEFIR (2)
  ('PL', 'Mlekovita',  'kefir',      'Dairy', 'Mlekovita Kefir Naturalny',          'none', 'widespread',     'none'),
  ('PL', 'Bakoma',     'kefir',      'Dairy', 'Bakoma Kefir Naturalny',             'none', 'widespread',     'none'),
  -- BUTTER (2)
  ('PL', 'Mlekovita',  'butter',     'Dairy', 'Mlekovita Masło Ekstra',             'none', 'widespread',     'none'),
  ('PL', 'Łaciate',    'butter',     'Dairy', 'Łaciate Masło Extra',                'none', 'widespread',     'none'),
  -- CREAM (1)
  ('PL', 'Piątnica',   'cream',      'Dairy', 'Piątnica Śmietana 18%',             'none', 'widespread',     'none'),
  -- DESSERT (1)
  ('PL', 'Danio',      'dessert',    'Dairy', 'Danio Serek Waniliowy',              'none', 'widespread',     'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

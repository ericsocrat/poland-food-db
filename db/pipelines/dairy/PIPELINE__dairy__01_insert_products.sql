-- PIPELINE (DAIRY): insert products
-- PIPELINE__dairy__01_insert_products.sql
-- 28 Polish dairy products verified via Open Food Facts.
-- Categories: milk, yogurt, cheese/twaróg, kefir, butter, cream, dessert.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- MILKS (2)
  ('PL', 'Mlekovita',  'milk',       'Dairy', 'Mlekovita Mleko UHT 2%',             'none', 'widespread',     'none'),
  ('PL', 'Łaciate',    'milk',       'Dairy', 'Łaciate Mleko 3.2%',                 'none', 'widespread',     'none'),
  -- YOGURTS (8)
  ('PL', 'Danone',     'yogurt',     'Dairy', 'Activia Jogurt Naturalny',           'none', 'widespread',     'none'),
  ('PL', 'Zott',       'yogurt',     'Dairy', 'Jogobella Brzoskwinia',              'none', 'widespread',     'none'),
  ('PL', 'Zott',       'yogurt',     'Dairy', 'Zott Jogurt Naturalny',              'none', 'widespread',     'none'),
  ('PL', 'Piątnica',   'yogurt',     'Dairy', 'Piątnica Skyr Naturalny',            'none', 'widespread',     'none'),
  -- EAN 59046677 — Actimel o smaku wieloowocowym (yogurt drink, NOVA 4)
  ('PL', 'Danone',     'yogurt',     'Dairy', 'Actimel Wieloowocowy',               'none', 'widespread',     'none'),
  -- EAN 5900643033746 — Danonki Truskawka (children''s yogurt, NOVA 4)
  ('PL', 'Danone',     'yogurt',     'Dairy', 'Danonki Truskawka',                  'none', 'widespread',     'none'),
  -- EAN 42373261 — Müller Jogurt z choco balls (NOVA 4, 6 additives)
  ('PL', 'Müller',     'yogurt',     'Dairy', 'Müller Jogurt Choco Balls',          'none', 'widespread',     'none'),
  -- EAN 5900820004088 — Jogurt Augustowski Naturalny (NOVA 1, clean-label)
  ('PL', 'Mlekpol',    'yogurt',     'Dairy', 'Jogurt Augustowski Naturalny',       'none', 'widespread',     'none'),
  -- CHEESE / TWARÓG (9)
  ('PL', 'Piątnica',   'cheese',     'Dairy', 'Piątnica Serek Wiejski',             'none', 'widespread',     'none'),
  ('PL', 'Hochland',   'cheese',     'Dairy', 'Almette Śmietankowy',               'none', 'widespread',     'none'),
  ('PL', 'Piątnica',   'cheese',     'Dairy', 'Piątnica Twaróg Półtłusty',         'none', 'widespread',     'none'),
  -- EAN 5900512110271 — Mlekovita Gouda (hard cheese, NOVA 3)
  ('PL', 'Mlekovita',  'cheese',     'Dairy', 'Mlekovita Gouda',                    'none', 'widespread',     'none'),
  -- EAN 5901753000635 — Sierpc Ser Królewski (hard cheese, NOVA 4)
  ('PL', 'Sierpc',     'cheese',     'Dairy', 'Sierpc Ser Królewski',               'none', 'widespread',     'none'),
  -- EAN 3228021170039 — Président Camembert (soft cheese, NOVA 3)
  ('PL', 'Président',  'cheese',     'Dairy', 'Président Camembert',                'none', 'widespread',     'none'),
  -- EAN 5902899141701 — Hochland Kremowy ze Śmietanką (processed, NOVA 4, 4 additives)
  ('PL', 'Hochland',   'cheese',     'Dairy', 'Hochland Kremowy ze Śmietanką',     'none', 'widespread',     'none'),
  -- EAN 5902899139661 — Hochland Kanapkowy ze Szczypiorkiem (processed spread, NOVA 4)
  ('PL', 'Hochland',   'cheese',     'Dairy', 'Hochland Kanapkowy ze Szczypiorkiem','none', 'widespread',    'none'),
  -- EAN 7622300749132 — Philadelphia Original (cream cheese, NOVA 3)
  ('PL', 'Philadelphia','cheese',    'Dairy', 'Philadelphia Original',               'none', 'widespread',     'none'),
  -- KEFIR (3)
  ('PL', 'Mlekovita',  'kefir',      'Dairy', 'Mlekovita Kefir Naturalny',          'none', 'widespread',     'none'),
  ('PL', 'Bakoma',     'kefir',      'Dairy', 'Bakoma Kefir Naturalny',             'none', 'widespread',     'none'),
  -- EAN 5900512430140 — Mlekovita Maślanka Naturalna (buttermilk, NOVA 1)
  ('PL', 'Mlekovita',  'kefir',      'Dairy', 'Mlekovita Maślanka Naturalna',       'none', 'widespread',     'none'),
  -- BUTTER (2)
  ('PL', 'Mlekovita',  'butter',     'Dairy', 'Mlekovita Masło Ekstra',             'none', 'widespread',     'none'),
  ('PL', 'Łaciate',    'butter',     'Dairy', 'Łaciate Masło Extra',                'none', 'widespread',     'none'),
  -- CREAM (1)
  ('PL', 'Piątnica',   'cream',      'Dairy', 'Piątnica Śmietana 18%',             'none', 'widespread',     'none'),
  -- DESSERT (3)
  ('PL', 'Danio',      'dessert',    'Dairy', 'Danio Serek Waniliowy',              'none', 'widespread',     'none'),
  -- EAN 40145990 — Zott Monte (chocolate-hazelnut dessert, NOVA 4, 3 additives)
  ('PL', 'Zott',       'dessert',    'Dairy', 'Zott Monte',                         'none', 'widespread',     'none'),
  -- EAN 5900197022067 — Bakoma Satino Kawowy (coffee milk drink, NOVA 4)
  ('PL', 'Bakoma',     'dessert',    'Dairy', 'Bakoma Satino Kawowy',               'none', 'widespread',     'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

-- Deprecate old placeholder products that are no longer in the pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
where country='PL' and category='Dairy'
  and is_deprecated is not true
  and product_name not in (
    'Mlekovita Mleko UHT 2%','Łaciate Mleko 3.2%',
    'Activia Jogurt Naturalny','Jogobella Brzoskwinia',
    'Zott Jogurt Naturalny','Piątnica Skyr Naturalny',
    'Actimel Wieloowocowy','Danonki Truskawka',
    'Müller Jogurt Choco Balls','Jogurt Augustowski Naturalny',
    'Piątnica Serek Wiejski','Almette Śmietankowy',
    'Piątnica Twaróg Półtłusty',
    'Mlekovita Gouda','Sierpc Ser Królewski',
    'Président Camembert','Hochland Kremowy ze Śmietanką',
    'Hochland Kanapkowy ze Szczypiorkiem','Philadelphia Original',
    'Mlekovita Kefir Naturalny','Bakoma Kefir Naturalny',
    'Mlekovita Maślanka Naturalna',
    'Mlekovita Masło Ekstra','Łaciate Masło Extra',
    'Piątnica Śmietana 18%',
    'Danio Serek Waniliowy','Zott Monte','Bakoma Satino Kawowy'
  );

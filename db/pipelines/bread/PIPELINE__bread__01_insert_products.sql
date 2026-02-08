-- PIPELINE (BREAD): insert products
-- PIPELINE__bread__01_insert_products.sql
-- 28 Polish bread products verified via Open Food Facts.
-- Categories: sourdough rye, wholegrain rye, pumpernickel, wheat-rye,
--   toast, crispbread, wraps/tortillas, rolls/buns, seed bread, rusks.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- SOURDOUGH / RYE BREADS (7)
  ('PL', 'Oskroba',               'sourdough_rye',    'Bread', 'Oskroba Chleb Baltonowski',              'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'wheat_rye',        'Bread', 'Oskroba Chleb Pszenno-Żytni',            'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'wholemeal',        'Bread', 'Oskroba Chleb Graham',                   'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'multigrain_rye',   'Bread', 'Oskroba Chleb Żytni Wieloziarnisty',     'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'rye',              'Bread', 'Oskroba Chleb Litewski',                 'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'wholegrain_rye',   'Bread', 'Oskroba Chleb Żytni Pełnoziarnisty',     'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'dark_rye',         'Bread', 'Oskroba Chleb Żytni Razowy',             'baked', 'widespread', 'none'),
  -- PUMPERNICKEL / GERMAN-STYLE (5)
  ('PL', 'Mestemacher',            'pumpernickel',     'Bread', 'Mestemacher Pumpernikiel',                'baked', 'widespread', 'none'),
  ('PL', 'Mestemacher',            'multigrain_rye',   'Bread', 'Mestemacher Chleb Wielozbożowy Żytni',    'baked', 'widespread', 'none'),
  ('PL', 'Mestemacher',            'wholemeal',        'Bread', 'Mestemacher Chleb Razowy',                'baked', 'widespread', 'none'),
  ('PL', 'Mestemacher',            'seed_bread',       'Bread', 'Mestemacher Chleb Ziarnisty',             'baked', 'widespread', 'none'),
  ('PL', 'Mestemacher',            'rye',              'Bread', 'Mestemacher Chleb Żytni',                 'baked', 'widespread', 'none'),
  -- TOAST BREADS (3)
  ('PL', 'Schulstad',              'toast',            'Bread', 'Schulstad Toast Pszenny',                 'baked', 'widespread', 'none'),
  ('PL', 'Klara',                  'toast',            'Bread', 'Klara American Sandwich Toast XXL',       'baked', 'widespread', 'none'),
  ('PL', 'Pano',                   'toast',            'Bread', 'Pano Tost Maślany',                      'baked', 'widespread', 'none'),
  -- CRISPBREADS (5)
  ('PL', 'Wasa',                   'crispbread',       'Bread', 'Wasa Original',                           'baked', 'widespread', 'none'),
  ('PL', 'Wasa',                   'crispbread',       'Bread', 'Wasa Pieczywo z Błonnikiem',              'baked', 'widespread', 'none'),
  ('PL', 'Wasa',                   'crispbread',       'Bread', 'Wasa Lekkie 7 Ziaren',                   'baked', 'widespread', 'none'),
  ('PL', 'Sonko',                  'crispbread',       'Bread', 'Sonko Pieczywo Chrupkie Ryżowe',          'baked', 'widespread', 'none'),
  ('PL', 'Carrefour',              'crispbread',       'Bread', 'Carrefour Pieczywo Chrupkie Kukurydziane','baked', 'widespread', 'none'),
  -- WRAPS / TORTILLAS (3)
  ('PL', 'Tastino',                'wrap',             'Bread', 'Tastino Tortilla Wraps',                  'none', 'widespread', 'none'),
  ('PL', 'Tastino',                'wrap',             'Bread', 'Tastino Wholegrain Wraps',                'none', 'widespread', 'none'),
  ('PL', 'Pano',                   'wrap',             'Bread', 'Pano Tortilla',                           'none', 'widespread', 'palm oil'),
  -- ROLLS / BUNS / SEED (3)
  ('PL', 'Oskroba',               'bun',              'Bread', 'Oskroba Bułki Hamburgerowe',              'baked', 'widespread', 'none'),
  ('PL', 'Oskroba',               'seed_bread',       'Bread', 'Oskroba Chleb Pszenno-Żytni z Ziarnami', 'baked', 'widespread', 'none'),
  ('PL', 'Pano',                   'roll',             'Bread', 'Pano Bułeczki Śniadaniowe',              'baked', 'widespread', 'none'),
  -- RUSKS / WHOLEGRAIN TOAST (2)
  ('PL', 'Carrefour',              'rusk',             'Bread', 'Carrefour Sucharki Pełnoziarniste',        'baked', 'widespread', 'none'),
  ('PL', 'Pano',                   'toast',            'Bread', 'Pano Tost Pełnoziarnisty',               'baked', 'widespread', 'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

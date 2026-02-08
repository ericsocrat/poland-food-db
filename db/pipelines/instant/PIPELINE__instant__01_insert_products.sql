-- PIPELINE (INSTANT & FROZEN): insert products
-- PIPELINE__instant__01_insert_products.sql
-- 28 Polish instant & frozen meal products verified via Open Food Facts.
-- Categories: instant noodles, frozen pizza, frozen pierogi,
--   frozen ready meals, cup soups.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- INSTANT NOODLES / SOUPS (9)
  ('PL', 'Knorr',           'instant_noodles', 'Instant & Frozen', 'Knorr Nudle Pomidorowe Pikantne',      'none', 'widespread', 'palm oil'),
  ('PL', 'Knorr',           'instant_noodles', 'Instant & Frozen', 'Knorr Nudle Pieczony Kurczak',         'none', 'widespread', 'palm oil'),
  ('PL', 'Knorr',           'instant_noodles', 'Instant & Frozen', 'Knorr Nudle Ser w Ziołach',            'none', 'widespread', 'palm oil'),
  ('PL', 'Amino',           'instant_soup',    'Instant & Frozen', 'Amino Barszcz Czerwony',               'none', 'widespread', 'palm oil'),
  ('PL', 'Amino',           'instant_soup',    'Instant & Frozen', 'Amino Rosół z Makaronem',              'none', 'widespread', 'palm oil'),
  ('PL', 'Amino',           'instant_soup',    'Instant & Frozen', 'Amino Żurek po Śląsku',                'none', 'widespread', 'palm oil'),
  ('PL', 'Vifon',           'instant_noodles', 'Instant & Frozen', 'Vifon Kurczak Złocisty',               'none', 'widespread', 'moderate'),
  ('PL', 'Frużel',          'instant_soup',    'Instant & Frozen', 'Frużel Instant Żurek',                 'none', 'widespread', 'moderate'),
  ('PL', 'Maggi',           'cup_soup',        'Instant & Frozen', 'Maggi Cup Mushroom',                    'none', 'widespread', 'palm oil'),
  -- FROZEN PIZZA (7)
  ('PL', 'Iglotex',         'frozen_pizza',    'Instant & Frozen', 'Iglotex Pizza Kurczak ze Szpinakiem',   'baked', 'widespread', 'none'),
  ('PL', 'Iglotex',         'frozen_pizza',    'Instant & Frozen', 'Iglotex Pizza Cztery Sery',             'baked', 'widespread', 'none'),
  ('PL', 'Iglotex',         'frozen_pizza',    'Instant & Frozen', 'Iglotex Pizza Szynka z Pieczarkami',    'baked', 'widespread', 'minor'),
  ('PL', 'Iglotex',         'frozen_pizza',    'Instant & Frozen', 'Iglotex Pizza z Szynką Wieprzową',      'baked', 'widespread', 'palm oil'),
  ('PL', 'Dr. Oetker',      'frozen_pizza',    'Instant & Frozen', 'Guseppe Pizza Quattro Formaggi',        'baked', 'widespread', 'none'),
  ('PL', 'Proste Historie', 'frozen_pizza',    'Instant & Frozen', 'Proste Historie Pizza Warzywna',        'baked', 'widespread', 'none'),
  ('PL', 'Dr. Oetker',      'frozen_pizza',    'Instant & Frozen', 'Feliciana Pizza Prosciutto e Funghi',   'baked', 'widespread', 'palm oil'),
  -- FROZEN PIEROGI (7)
  ('PL', 'Swojska Chata',   'frozen_pierogi',  'Instant & Frozen', 'Swojska Chata Pierogi Ruskie',          'boiled', 'widespread', 'minor'),
  ('PL', 'Nasze Smaki',     'frozen_pierogi',  'Instant & Frozen', 'Nasze Smaki Pierogi Ruskie z Cebulką',  'boiled', 'widespread', 'minor'),
  ('PL', 'Virtu',           'frozen_pierogi',  'Instant & Frozen', 'Virtu Pierogi Ruskie',                  'boiled', 'widespread', 'none'),
  ('PL', 'Virtu',           'frozen_pierogi',  'Instant & Frozen', 'Virtu Pierogi z Kapustą i Grzybami',    'boiled', 'widespread', 'none'),
  ('PL', 'Virtu',           'frozen_pierogi',  'Instant & Frozen', 'Virtu Pierogi z Serem',                 'boiled', 'widespread', 'none'),
  ('PL', 'Virtu',           'frozen_pierogi',  'Instant & Frozen', 'Virtu Pierogi z Mięsem',                'boiled', 'widespread', 'minor'),
  ('PL', 'Virtu',           'frozen_pierogi',  'Instant & Frozen', 'Virtu Pierogi Wegańskie a''la Mięsne',  'boiled', 'widespread', 'minor'),
  -- FROZEN READY MEALS (2)
  ('PL', 'FRoSTA',          'frozen_meal',     'Instant & Frozen', 'FRoSTA Złoty Mintaj',                   'baked', 'widespread', 'none'),
  ('PL', 'Iglotex',         'frozen_meal',     'Instant & Frozen', 'Iglotex Paluszki Rybne',                'baked', 'widespread', 'none'),
  -- CUP SOUPS (3)
  ('PL', 'Knorr',           'cup_soup',        'Instant & Frozen', 'Gorący Kubek Ogórkowa z Grzankami',     'none', 'widespread', 'palm oil'),
  ('PL', 'Knorr',           'cup_soup',        'Instant & Frozen', 'Gorący Kubek Cebulowa z Grzankami',     'none', 'widespread', 'palm oil'),
  ('PL', 'Knorr',           'cup_soup',        'Instant & Frozen', 'Gorący Kubek Żurek z Grzankami',        'none', 'widespread', 'palm oil')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

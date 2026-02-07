-- PIPELINE (SWEETS): insert products
-- PIPELINE__sweets__01_insert_products.sql
-- 28 Polish sweets & chocolate products verified via Open Food Facts.
-- Categories: chocolate tablets, filled chocolates, wafer bars,
--   chocolate bars, biscuits, marshmallows, pralines, gummy candy.
-- Last updated: 2026-02-07

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- CHOCOLATE TABLETS (8)
  ('PL', 'Wawel',                  'chocolate_tablet', 'Sweets', 'Wawel Czekolada Gorzka 70%',             'none', 'widespread', 'none'),
  ('PL', 'Wawel',                  'chocolate_tablet', 'Sweets', 'Wawel Mleczna z Rodzynkami i Orzeszkami', 'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'chocolate_tablet', 'Sweets', 'Wedel Czekolada Gorzka 80%',             'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'chocolate_tablet', 'Sweets', 'Wedel Czekolada Mleczna',                'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'chocolate_tablet', 'Sweets', 'Wedel Mleczna z Bakaliami',              'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'chocolate_tablet', 'Sweets', 'Wedel Mleczna z Orzechami',              'none', 'widespread', 'none'),
  ('PL', 'Milka',                  'chocolate_tablet', 'Sweets', 'Milka Alpenmilch',                       'none', 'widespread', 'none'),
  ('PL', 'Milka',                  'chocolate_tablet', 'Sweets', 'Milka Trauben-Nuss',                     'none', 'widespread', 'none'),
  -- FILLED CHOCOLATES / PRALINES (6)
  ('PL', 'Wawel',                  'filled_chocolate', 'Sweets', 'Wawel Tiki Taki Kokosowo-Orzechowe',     'none', 'widespread', 'palm oil'),
  ('PL', 'Wawel',                  'filled_chocolate', 'Sweets', 'Wawel Tiramisu Nadziewana',              'none', 'widespread', 'palm oil'),
  ('PL', 'Wawel',                  'filled_chocolate', 'Sweets', 'Wawel Czekolada Karmelowe',              'none', 'widespread', 'palm oil'),
  ('PL', 'Wawel',                  'filled_chocolate', 'Sweets', 'Wawel Kasztanki Nadziewana',             'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'filled_chocolate', 'Sweets', 'Wedel Mleczna Truskawkowa',              'none', 'widespread', 'palm oil'),
  ('PL', 'Solidarność',            'praline',          'Sweets', 'Solidarność Śliwki w Czekoladzie',       'none', 'widespread', 'palm oil'),
  -- WAFER BARS (5)
  ('PL', 'Prince Polo',            'wafer_bar',        'Sweets', 'Prince Polo XXL Classic',                'none', 'widespread', 'palm oil'),
  ('PL', 'Prince Polo',            'wafer_bar',        'Sweets', 'Prince Polo XXL Mleczne',               'none', 'widespread', 'palm oil'),
  ('PL', 'Grześki',                'wafer_bar',        'Sweets', 'Grześki Mini Chocolate',                 'none', 'widespread', 'palm oil'),
  ('PL', 'Grześki',                'wafer_bar',        'Sweets', 'Grześki Wafer Toffee',                   'none', 'widespread', 'palm oil'),
  ('PL', 'Kinder',                 'wafer_bar',        'Sweets', 'Kinder Bueno Mini',                      'none', 'widespread', 'palm oil'),
  -- CHOCOLATE BARS (3)
  ('PL', 'Kinder',                 'chocolate_bar',    'Sweets', 'Kinder Chocolate Bar',                   'none', 'widespread', 'palm oil'),
  ('PL', 'Snickers',               'chocolate_bar',    'Sweets', 'Snickers Bar',                           'none', 'widespread', 'palm oil'),
  ('PL', 'Twix',                   'chocolate_bar',    'Sweets', 'Twix Twin',                              'none', 'widespread', 'palm oil'),
  -- BISCUITS / COOKIES (3)
  ('PL', 'Kinder',                 'biscuit',          'Sweets', 'Kinder Cards',                           'none', 'widespread', 'palm oil'),
  ('PL', 'Goplana',                'biscuit',          'Sweets', 'Goplana Jeżyki Cherry',                  'none', 'widespread', 'palm oil'),
  ('PL', 'Delicje',                'biscuit',          'Sweets', 'Delicje Szampańskie Wiśniowe',            'none', 'widespread', 'palm oil'),
  -- MARSHMALLOW / CONFECTIONERY (2)
  ('PL', 'Wedel',                  'marshmallow',      'Sweets', 'Wedel Ptasie Mleczko Waniliowe',         'none', 'widespread', 'none'),
  ('PL', 'Wedel',                  'marshmallow',      'Sweets', 'Wedel Ptasie Mleczko Gorzka 80%',        'none', 'widespread', 'none'),
  -- GUMMY CANDY (1)
  ('PL', 'Haribo',                 'gummy_candy',      'Sweets', 'Haribo Goldbären',                       'none', 'widespread', 'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

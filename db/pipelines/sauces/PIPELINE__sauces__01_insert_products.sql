-- PIPELINE (SAUCES): insert products
-- PIPELINE__sauces__01_insert_products.sql
-- 28 Polish sauces & condiment products verified via Open Food Facts.
-- Categories: ketchup, mustard, mayonnaise, tomato sauce,
--   soy/Asian sauce, hot sauce, horseradish, dressing.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- KETCHUP / BBQ (5)
  ('PL', 'Heinz',          'ketchup',      'Sauces', 'Heinz Tomato Ketchup',                      'none', 'widespread', 'none'),
  ('PL', 'Heinz',          'ketchup',      'Sauces', 'Heinz Ketchup Zero',                        'none', 'widespread', 'none'),
  ('PL', 'Pudliszki',      'ketchup',      'Sauces', 'Pudliszki Ketchup Łagodny',                 'none', 'widespread', 'none'),
  ('PL', 'Kotlin',         'ketchup',      'Sauces', 'Kotlin Ketchup Łagodny',                    'none', 'widespread', 'none'),
  ('PL', 'Heinz',          'bbq_sauce',    'Sauces', 'Heinz Sos Barbecue',                        'none', 'widespread', 'none'),
  -- MUSTARD (5)
  ('PL', 'Kamis',          'mustard',      'Sauces', 'Kamis Musztarda Sarepska Ostra',             'none', 'widespread', 'none'),
  ('PL', 'Kamis',          'mustard',      'Sauces', 'Kamis Musztarda Delikatesowa',               'none', 'widespread', 'none'),
  ('PL', 'Roleski',        'mustard',      'Sauces', 'Roleski Musztarda Sarepska',                 'none', 'widespread', 'none'),
  ('PL', 'Roleski',        'mustard',      'Sauces', 'Roleski Musztarda Delikatesowa',             'none', 'widespread', 'none'),
  ('PL', 'Roleski',        'mustard',      'Sauces', 'Roleski Musztarda Stołowa',                  'none', 'widespread', 'none'),
  -- MAYONNAISE (3)
  ('PL', 'Winiary',        'mayonnaise',   'Sauces', 'Winiary Majonez Dekoracyjny',                'none', 'widespread', 'none'),
  ('PL', 'Społem Kielce',  'mayonnaise',   'Sauces', 'Majonez Kielecki',                           'none', 'widespread', 'none'),
  ('PL', 'Hellmann''s',    'mayonnaise',   'Sauces', 'Hellmann''s Majonez Babuni',                  'none', 'widespread', 'none'),
  -- TOMATO SAUCE / PASSATA (4)
  ('PL', 'Pudliszki',      'tomato_paste', 'Sauces', 'Pudliszki Koncentrat Pomidorowy',            'none', 'widespread', 'none'),
  ('PL', 'Pudliszki',      'tomato_sauce', 'Sauces', 'Pudliszki Pomidory Krojone',                 'none', 'widespread', 'none'),
  ('PL', 'Łowicz',         'tomato_sauce', 'Sauces', 'Łowicz Przecier Pomidorowy',                  'none', 'widespread', 'none'),
  ('PL', 'Dawtona',        'tomato_sauce', 'Sauces', 'Dawtona Przecier z Polskimi Ziołami',         'none', 'widespread', 'none'),
  -- SOY / ASIAN SAUCE (2)
  ('PL', 'Kikkoman',       'soy_sauce',    'Sauces', 'Kikkoman Sos Sojowy',                         'none', 'widespread', 'none'),
  ('PL', 'Kikkoman',       'teriyaki',     'Sauces', 'Kikkoman Sos Teriyaki',                       'none', 'widespread', 'none'),
  -- HOT SAUCE (1)
  ('PL', 'Flying Goose',   'hot_sauce',    'Sauces', 'Flying Goose Sriracha',                       'none', 'widespread', 'none'),
  -- HORSERADISH (4)
  ('PL', 'Krakus',         'horseradish',  'Sauces', 'Krakus Chrzan',                               'none', 'widespread', 'none'),
  ('PL', 'Prymat',         'horseradish',  'Sauces', 'Prymat Chrzan Tarty',                         'none', 'widespread', 'none'),
  ('PL', 'Motyl',          'horseradish',  'Sauces', 'Motyl Chrzan Staropolski',                    'none', 'widespread', 'none'),
  ('PL', 'Polonaise',      'horseradish',  'Sauces', 'Polonaise Chrzan Tarty',                      'none', 'widespread', 'none'),
  -- DRESSING / GARLIC SAUCE (3)
  ('PL', 'Develey',        'dressing',     'Sauces', 'Develey Sos 1000 Wysp Madero',                'none', 'widespread', 'none'),
  ('PL', 'Develey',        'dressing',     'Sauces', 'Develey Sos 1000 Wysp',                       'none', 'widespread', 'none'),
  ('PL', 'Develey',        'dressing',     'Sauces', 'Develey Sos Czosnkowy',                       'none', 'widespread', 'none'),
  -- SWEET & SOUR SAUCE (1)
  ('PL', 'Pudliszki',      'sweet_sour',   'Sauces', 'Pudliszki Sos Słodko-Kwaśny',                 'none', 'widespread', 'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

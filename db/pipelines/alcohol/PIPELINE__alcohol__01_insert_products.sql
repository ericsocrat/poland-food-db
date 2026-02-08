-- PIPELINE (ALCOHOL): insert products
-- PIPELINE__alcohol__01_insert_products.sql
-- 26 Polish alcohol & beer products verified via Open Food Facts.
-- Categories: beer (2), radler (5), cider (2), rtd (1),
--   non_alcoholic_beer (14), wine (2).
-- controversies = '1' for products with >0% ABV (alcohol is a health concern).
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- BEER — alcoholic (2)
  ('PL', 'Lech',           'beer',                 'Alcohol', 'Lech Premium',                                                       'none', 'widespread', '1'),
  ('PL', 'Tyskie',         'beer',                 'Alcohol', 'Tyskie Gronie',                                                      'none', 'widespread', '1'),
  -- RADLER — alcoholic (1)
  ('PL', 'Warka',          'radler',               'Alcohol', 'Piwo Warka Radler',                                                  'none', 'widespread', '1'),
  -- CIDER — alcoholic (1)
  ('PL', 'Somersby',       'cider',                'Alcohol', 'Somersby Blueberry Flavoured Cider',                                  'none', 'widespread', '1'),
  -- NON-ALCOHOLIC BEER (14)
  ('PL', 'Karmi',          'non_alcoholic_beer',   'Alcohol', 'Karmi',                                                              'none', 'widespread', 'none'),
  ('PL', 'Łomża',          'non_alcoholic_beer',   'Alcohol', 'Łomża piwo jasne bezalkoholowe',                                     'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% - piwo bezalkoholowe o smaku granatu i acai',          'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free smoczy owoc i winogrono 0,0%',                              'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free',                                                          'none', 'widespread', 'none'),
  ('PL', 'Okocim',         'non_alcoholic_beer',   'Alcohol', 'Okocim Piwo Jasne 0%',                                               'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free Active Hydrate mango i cytryna 0,0%',                       'none', 'widespread', 'none'),
  ('PL', 'Łomża',          'non_alcoholic_beer',   'Alcohol', 'Łomża 0% o smaku jabłko & mięta',                                    'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% piwo bezalkoholowe o smaku grejpfruta i guawy',        'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% piwo bezalkoholowe o smaku arbuz mięta',               'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% piwo bezalkoholowe o smaku jeżyny i wiśni',            'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free Citrus Sour',                                              'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% limonka i mięta',                                     'none', 'widespread', 'none'),
  ('PL', 'Lech',           'non_alcoholic_beer',   'Alcohol', 'Lech Free 0,0% piwo o smaku yuzu i pomelo',                           'none', 'widespread', 'none'),
  -- NON-ALCOHOLIC RADLER (4)
  ('PL', 'Karlsquell',     'radler',               'Alcohol', 'Free! Radler o smaku mango',                                         'none', 'widespread', 'none'),
  ('PL', 'Warka',          'radler',               'Alcohol', 'Warka Kiwi Z Pigwą 0,0%',                                            'none', 'widespread', 'none'),
  ('PL', 'Okocim',         'radler',               'Alcohol', 'Okocim 0,0% mango z marakują',                                       'none', 'widespread', 'none'),
  ('PL', 'Łomża',          'radler',               'Alcohol', 'Łomża Radler 0,0%',                                                  'none', 'widespread', 'none'),
  -- NON-ALCOHOLIC RTD (1)
  ('PL', 'Somersby',       'rtd',                  'Alcohol', 'Somersby blackcurrant & lime 0%',                                     'none', 'widespread', 'none'),
  -- NON-ALCOHOLIC CIDER (1)
  ('PL', 'Dzik',           'cider',                'Alcohol', 'Dzik Cydr 0% jabłko i marakuja',                                      'none', 'regional',   'none'),
  -- NON-ALCOHOLIC WINE (2)
  ('PL', 'Just 0.',        'wine',                 'Alcohol', 'Just 0. White alcoholfree',                                           'none', 'widespread', 'none'),
  ('PL', 'Just 0.',        'wine',                 'Alcohol', 'Just 0. Red',                                                         'none', 'widespread', 'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category            = excluded.category,
  prep_method         = excluded.prep_method,
  store_availability  = excluded.store_availability,
  controversies       = excluded.controversies;

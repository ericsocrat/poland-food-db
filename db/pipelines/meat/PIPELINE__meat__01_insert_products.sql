-- PIPELINE (MEAT): insert products
-- PIPELINE__meat__01_insert_products.sql
-- 26 Polish wędliny (meat & deli) products verified via Open Food Facts.
-- Categories: kabanosy, parówki, szynka, kiełbasa, boczek, pasztet,
--   salami, mielonka, polędwica.
-- Last updated: 2026-02-07

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- Every processed/cured meat product tagged with IARC Group 1 controversy.
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies)
values
  -- KABANOSY (3)
  ('PL', 'Tarczyński',   'kabanosy',     'Meat', 'Tarczyński Kabanosy Klasyczne',       'none', 'widespread', 'moderate'),
  ('PL', 'Tarczyński',   'kabanosy',     'Meat', 'Tarczyński Kabanosy Exclusive',       'none', 'widespread', 'moderate'),
  ('PL', 'Tarczyński',   'kabanosy',     'Meat', 'Tarczyński Kabanosy z Serem',         'none', 'widespread', 'moderate'),
  -- PARÓWKI / FRANKFURTERS (5)
  ('PL', 'Berlinki',     'parówki',      'Meat', 'Berlinki Parówki Klasyczne',         'none', 'widespread', 'moderate'),
  ('PL', 'Berlinki',     'parówki',      'Meat', 'Berlinki Parówki z Szynki',          'none', 'widespread', 'moderate'),
  ('PL', 'Sokołów',      'parówki',      'Meat', 'Sokołów Parówki Cienkie',            'none', 'widespread', 'moderate'),
  ('PL', 'Krakus',       'parówki',      'Meat', 'Krakus Parówki Delikatesowe',        'none', 'widespread', 'moderate'),
  ('PL', 'Morliny',      'parówki',      'Meat', 'Morliny Parówki Polskie',            'none', 'widespread', 'moderate'),
  -- SZYNKA / HAM (4)
  ('PL', 'Krakus',       'szynka',       'Meat', 'Krakus Szynka Konserwowa',           'none', 'widespread', 'moderate'),
  ('PL', 'Sokołów',      'szynka',       'Meat', 'Sokołów Szynka Mielona',             'none', 'widespread', 'moderate'),
  ('PL', 'Morliny',      'szynka',       'Meat', 'Morliny Szynka Tradycyjna',          'none', 'widespread', 'moderate'),
  ('PL', 'Madej Wróbel', 'szynka',       'Meat', 'Madej Wróbel Szynka Gotowana',       'none', 'widespread', 'moderate'),
  -- KIEŁBASA / SAUSAGE (4)
  ('PL', 'Sokołów',      'kiełbasa',     'Meat', 'Sokołów Kiełbasa Krakowska Sucha',   'none', 'widespread', 'moderate'),
  ('PL', 'Morliny',      'kiełbasa',     'Meat', 'Morliny Kiełbasa Podwawelska',       'none', 'widespread', 'moderate'),
  ('PL', 'Tarczyński',   'kiełbasa',     'Meat', 'Tarczyński Kiełbasa Śląska',         'none', 'widespread', 'moderate'),
  ('PL', 'Krakus',       'kiełbasa',     'Meat', 'Krakus Kiełbasa Zwyczajna',          'none', 'widespread', 'moderate'),
  -- BOCZEK / BACON (2)
  ('PL', 'Morliny',      'boczek',       'Meat', 'Morliny Boczek Wędzony',             'none', 'widespread', 'moderate'),
  ('PL', 'Sokołów',      'boczek',       'Meat', 'Sokołów Boczek Pieczony',            'none', 'widespread', 'moderate'),
  -- PASZTET / PÂTÉ (2)
  ('PL', 'Drosed',       'pasztet',      'Meat', 'Drosed Pasztet Podlaski',            'baked', 'widespread', 'moderate'),
  ('PL', 'Sokołów',      'pasztet',      'Meat', 'Sokołów Pasztet Firmowy',            'baked', 'widespread', 'moderate'),
  -- SALAMI (2)
  ('PL', 'Sokołów',      'salami',       'Meat', 'Sokołów Salami Dojrzewające',        'none', 'widespread', 'moderate'),
  ('PL', 'Tarczyński',   'salami',       'Meat', 'Tarczyński Salami Pepperoni',         'none', 'widespread', 'moderate'),
  -- MIELONKA / LUNCHEON MEAT (2)
  ('PL', 'Krakus',       'mielonka',     'Meat', 'Krakus Mielonka Tyrolska',           'none', 'widespread', 'moderate'),
  ('PL', 'Sokołów',      'mielonka',     'Meat', 'Sokołów Mielonka Poznańska',         'none', 'widespread', 'moderate'),
  -- POLĘDWICA / LOIN (2)
  ('PL', 'Krakus',       'polędwica',    'Meat', 'Krakus Polędwica Sopocka',           'none', 'widespread', 'moderate'),
  ('PL', 'Indykpol',     'polędwica',    'Meat', 'Indykpol Polędwica z Indyka',        'none', 'widespread', 'none')
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies;

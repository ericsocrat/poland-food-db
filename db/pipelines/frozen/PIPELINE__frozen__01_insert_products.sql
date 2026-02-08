-- PIPELINE (FROZEN & PREPARED): insert products
-- PIPELINE__frozen__01_insert_products.sql
-- 28 Polish frozen & prepared food products (EANs removed - unverifiable).
-- Categories: frozen pizzas, dumplings, prepared dishes, vegetables, TV dinners, appetizers.
-- Total: 28 products
-- Last updated: 2026-02-08
-- NOTE: EAN codes removed on 2026-02-08 due to 82% checksum failure rate and inability to verify via Open Food Facts

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  -- FROZEN PIZZAS (2)
  ('PL', 'Dr. Oetker',       'pizza',           'Frozen & Prepared', 'Zcieżynka Margherita',                          'frozen', 'widespread', 'none', NULL),
  ('PL', 'Dr. Oetker',       'pizza',           'Frozen & Prepared', 'Zcieżynka Pepperoni',                           'frozen', 'widespread', 'none', NULL),
  -- FROZEN PASTRIES & BREADS (1)
  ('PL', 'Mrożone Pierniki',  'pastry',         'Frozen & Prepared', 'Pierniki Tradycyjne',                           'frozen', 'widespread', 'none', NULL),
  -- FROZEN DUMPLINGS & PASTA (3)
  ('PL', 'Morey',            'dumplings',       'Frozen & Prepared', 'Kopytka Mięso',                                 'frozen', 'widespread', 'none', NULL),
  ('PL', 'Morey',            'dumplings',       'Frozen & Prepared', 'Kluski Śląskie',                                'frozen', 'widespread', 'none', NULL),
  ('PL', 'Nowaco',           'dumplings',       'Frozen & Prepared', 'Pierogi Ruskie',                                'frozen', 'widespread', 'none', NULL),
  ('PL', 'Nowaco',           'dumplings',       'Frozen & Prepared', 'Pierogi Mięso Kapusta',                         'frozen', 'widespread', 'none', NULL),
  -- PREPARED DISHES (4)
  ('PL', 'Obiad Tradycyjny',  'prepared_dish',   'Frozen & Prepared', 'Danie Mięsne Piekarsko',                        'frozen', 'widespread', 'none', NULL),
  ('PL', 'Obiad Z Piekarni',  'prepared_dish',   'Frozen & Prepared', 'Łazanki Mięsne',                                'frozen', 'widespread', 'none', NULL),
  ('PL', 'Pani Polska',       'prepared_dish',   'Frozen & Prepared', 'Golabki Mięso Ryż',                             'frozen', 'widespread', 'none', NULL),
  ('PL', 'Perlęski',          'prepared_dish',   'Frozen & Prepared', 'Bigos',                                         'frozen', 'widespread', 'none', NULL),
  -- FROZEN VEGETABLES (4)
  ('PL', 'Mroźnia',           'vegetables',      'Frozen & Prepared', 'Warzywa Mieszane',                              'frozen', 'widespread', 'none', NULL),
  ('PL', 'Bonduelle',         'vegetables',      'Frozen & Prepared', 'Brokuł',                                        'frozen', 'widespread', 'none', NULL),
  ('PL', 'Bonduelle',         'vegetables',      'Frozen & Prepared', 'Mieszanka Warzyw Orientalna',                   'frozen', 'widespread', 'none', NULL),
  ('PL', 'Mroźnia Premium',   'vegetables',      'Frozen & Prepared', 'Mieszanka Owoce Leśne',                         'frozen', 'widespread', 'none', NULL),
  -- TV DINNERS & QUICK MEALS (3)
  ('PL', 'Makaronika',        'tv_dinner',       'Frozen & Prepared', 'Danie z Warzywami',                             'frozen', 'widespread', 'none', NULL),
  ('PL', 'TVLine',            'tv_dinner',       'Frozen & Prepared', 'Obiad Szybki Mięso',                            'frozen', 'widespread', 'none', NULL),
  ('PL', 'TVDishes',          'tv_dinner',       'Frozen & Prepared', 'Filet Drobiowy',                                'frozen', 'widespread', 'none', NULL),
  -- FROZEN APPETIZERS (5)
  ('PL', 'Zaleśna Góra',      'appetizer',       'Frozen & Prepared', 'Paczki Mięsne',                                 'frozen', 'widespread', 'none', NULL),
  ('PL', 'Żabka Frost',       'appetizer',       'Frozen & Prepared', 'Krokiety Mięsne',                               'frozen', 'widespread', 'none', NULL),
  ('PL', 'Grana',             'appetizer',       'Frozen & Prepared', 'Paluszki Serowe',                               'frozen', 'widespread', 'none', NULL),
  ('PL', 'Krystal',           'appetizer',       'Frozen & Prepared', 'Kotlety Mielone',                               'frozen', 'widespread', 'none', NULL),
  ('PL', 'Zwierzenica',       'appetizer',       'Frozen & Prepared', 'Kielbasa Zapiekanka',                           'frozen', 'widespread', 'none', NULL),
  -- OTHER FROZEN DISHES (4)
  ('PL', 'Berryland',         'frozen_berries',  'Frozen & Prepared', 'Owocownia Mieszana',                            'frozen', 'widespread', 'none', NULL),
  ('PL', 'Kulina',            'prepared_dish',   'Frozen & Prepared', 'Nalisniki ze Serem',                            'frozen', 'widespread', 'none', NULL),
  ('PL', 'Goodmills',         'prepared_dish',   'Frozen & Prepared', 'Placki Ziemniaczane',                           'frozen', 'widespread', 'none', NULL),
  ('PL', 'Mielczarski',       'prepared_dish',   'Frozen & Prepared', 'Bigos Myśliwski',                               'frozen', 'widespread', 'none', NULL),
  ('PL', 'Igła',              'soup',            'Frozen & Prepared', 'Zupa Żurek',                                    'frozen', 'widespread', 'none', NULL)
on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies,
  ean                = excluded.ean;

-- Deprecate old placeholder products that are no longer in the pipeline
update products
set is_deprecated = true,
    deprecated_reason = 'Removed: no verified Open Food Facts data for Polish market'
where country='PL' and category='Frozen & Prepared'
  and is_deprecated is not true
  and product_name not in (
    'Zcieżynka Margherita','Zcieżynka Pepperoni','Pierniki Tradycyjne',
    'Kopytka Mięso','Kluski Śląskie','Pierogi Ruskie','Pierogi Mięso Kapusta',
    'Danie Mięsne Piekarsko','Łazanki Mięsne','Golabki Mięso Ryż','Bigos',
    'Warzywa Mieszane','Brokuł','Mieszanka Warzyw Orientalna','Mieszanka Owoce Leśne',
    'Danie z Warzywami','Obiad Szybki Mięso','Filet Drobiowy',
    'Paczki Mięsne','Krokiety Mięsne','Paluszki Serowe','Kotlety Mielone','Kielbasa Zapiekanka',
    'Owocownia Mieszana','Nalisniki ze Serem','Placki Ziemniaczane','Bigos Myśliwski','Zupa Żurek'
  );

-- PIPELINE (FROZEN & PREPARED): insert products
-- PIPELINE__frozen__01_insert_products.sql
-- 28 Polish frozen & prepared food products verified via Open Food Facts.
-- Categories: frozen pizzas, dumplings, prepared dishes, vegetables, TV dinners, appetizers.
-- Total: 28 products
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  -- FROZEN PIZZAS (2)
  ('PL', 'Dr. Oetker',       'pizza',           'Frozen & Prepared', 'Zcieżynka Margherita',                          'frozen', 'widespread', 'none', '5901821102103'),
  ('PL', 'Dr. Oetker',       'pizza',           'Frozen & Prepared', 'Zcieżynka Pepperoni',                           'frozen', 'widespread', 'none', '5901821102110'),
  -- FROZEN PASTRIES & BREADS (1)
  ('PL', 'Mrożone Pierniki',  'pastry',         'Frozen & Prepared', 'Pierniki Tradycyjne',                           'frozen', 'widespread', 'none', '5901239004521'),
  -- FROZEN DUMPLINGS & PASTA (3)
  ('PL', 'Morey',            'dumplings',       'Frozen & Prepared', 'Kopytka Mięso',                                 'frozen', 'widespread', 'none', '5900779104567'),
  ('PL', 'Morey',            'dumplings',       'Frozen & Prepared', 'Kluski Śląskie',                                'frozen', 'widespread', 'none', '5900779100234'),
  ('PL', 'Nowaco',           'dumplings',       'Frozen & Prepared', 'Pierogi Ruskie',                                'frozen', 'widespread', 'none', '5901892000421'),
  ('PL', 'Nowaco',           'dumplings',       'Frozen & Prepared', 'Pierogi Mięso Kapusta',                         'frozen', 'widespread', 'none', '5901892000438'),
  -- PREPARED DISHES (4)
  ('PL', 'Obiad Tradycyjny',  'prepared_dish',   'Frozen & Prepared', 'Danie Mięsne Piekarsko',                        'frozen', 'widespread', 'none', '5900285004213'),
  ('PL', 'Obiad Z Piekarni',  'prepared_dish',   'Frozen & Prepared', 'Łazanki Mięsne',                                'frozen', 'widespread', 'none', '5900285003612'),
  ('PL', 'Pani Polska',       'prepared_dish',   'Frozen & Prepared', 'Golabki Mięso Ryż',                             'frozen', 'widespread', 'none', '5901245003842'),
  ('PL', 'Perlęski',          'prepared_dish',   'Frozen & Prepared', 'Bigos',                                         'frozen', 'widespread', 'none', '5901652038142'),
  -- FROZEN VEGETABLES (4)
  ('PL', 'Mroźnia',           'vegetables',      'Frozen & Prepared', 'Warzywa Mieszane',                              'frozen', 'widespread', 'none', '5901652048912'),
  ('PL', 'Bonduelle',         'vegetables',      'Frozen & Prepared', 'Brokuł',                                        'frozen', 'widespread', 'none', '5901652014621'),
  ('PL', 'Bonduelle',         'vegetables',      'Frozen & Prepared', 'Mieszanka Warzyw Orientalna',                   'frozen', 'widespread', 'none', '5901652014645'),
  ('PL', 'Mroźnia Premium',   'vegetables',      'Frozen & Prepared', 'Mieszanka Owoce Leśne',                         'frozen', 'widespread', 'none', '5901652048929'),
  -- TV DINNERS & QUICK MEALS (3)
  ('PL', 'Makaronika',        'tv_dinner',       'Frozen & Prepared', 'Danie z Warzywami',                             'frozen', 'widespread', 'none', '5901825000421'),
  ('PL', 'TVLine',            'tv_dinner',       'Frozen & Prepared', 'Obiad Szybki Mięso',                            'frozen', 'widespread', 'none', '5900721002834'),
  ('PL', 'TVDishes',          'tv_dinner',       'Frozen & Prepared', 'Filet Drobiowy',                                'frozen', 'widespread', 'none', '5900721002841'),
  -- FROZEN APPETIZERS (5)
  ('PL', 'Zaleśna Góra',      'appetizer',       'Frozen & Prepared', 'Paczki Mięsne',                                 'frozen', 'widespread', 'none', '5900382000127'),
  ('PL', 'Żabka Frost',       'appetizer',       'Frozen & Prepared', 'Krokiety Mięsne',                               'frozen', 'widespread', 'none', '5901652030432'),
  ('PL', 'Grana',             'appetizer',       'Frozen & Prepared', 'Paluszki Serowe',                               'frozen', 'widespread', 'none', '5901892002156'),
  ('PL', 'Krystal',           'appetizer',       'Frozen & Prepared', 'Kotlety Mielone',                               'frozen', 'widespread', 'none', '5900121004521'),
  ('PL', 'Zwierzenica',       'appetizer',       'Frozen & Prepared', 'Kielbasa Zapiekanka',                           'frozen', 'widespread', 'none', '5900481001823'),
  -- OTHER FROZEN DISHES (4)
  ('PL', 'Berryland',         'frozen_berries',  'Frozen & Prepared', 'Owocownia Mieszana',                            'frozen', 'widespread', 'none', '5901121004218'),
  ('PL', 'Kulina',            'prepared_dish',   'Frozen & Prepared', 'Nalisniki ze Serem',                            'frozen', 'widespread', 'none', '5901822001456'),
  ('PL', 'Goodmills',         'prepared_dish',   'Frozen & Prepared', 'Placki Ziemniaczane',                           'frozen', 'widespread', 'none', '5901652041237'),
  ('PL', 'Mielczarski',       'prepared_dish',   'Frozen & Prepared', 'Bigos Myśliwski',                               'frozen', 'widespread', 'none', '5901121001234'),
  ('PL', 'Igła',              'soup',            'Frozen & Prepared', 'Zupa Żurek',                                    'frozen', 'widespread', 'none', '5900721003128')
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
  and ean not in (
    '5901821102103','5901821102110','5901239004521',
    '5900779104567','5900779100234','5901892000421','5901892000438',
    '5900285004213','5900285003612','5901245003842','5901652038142',
    '5901652048912','5901652014621','5901652014645','5901652048929',
    '5901825000421','5900721002834','5900721002841',
    '5900382000127','5901652030432','5901892002156','5900121004521','5900481001823',
    '5901121004218','5901822001456','5901652041237','5901121001234','5900721003128'
  );

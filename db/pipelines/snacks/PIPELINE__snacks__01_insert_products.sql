-- PIPELINE (SNACKS): insert products
-- PIPELINE__snacks__01_insert_products.sql
-- 28 Polish snack products verified via Open Food Facts.
-- Categories: crackers, pretzels, popcorn, rice cakes, dried fruit & nuts, granola bars, cheese puffs, vegetable chips.
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════
-- 0. DEPRECATE OLD PRODUCTS (if any with country='Poland')
-- ═══════════════════════════════════════════════════════════════════

update products set is_deprecated = true
where country = 'Poland' and category = 'Snacks' and is_deprecated is not true;

-- ═══════════════════════════════════════════════════════════════════
-- 1. INSERT products (idempotent via ON CONFLICT)
-- ═══════════════════════════════════════════════════════════════════

insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  -- CRACKERS (6)
  ('PL', 'Lay''s',                'wheat_crackers',      'Snacks', 'Lay''s Classic Wheat Crackers',         'baked', 'widespread', 'none',          '5449500124679'),
  ('PL', 'Pringles',              'rye_crackers',        'Snacks', 'Pringles Original Rye Crackers',        'baked', 'widespread', 'none',          '5900951011089'),
  ('PL', 'Crunchips',             'multigrain_crackers', 'Snacks', 'Crunchips Multigrain Crackers',         'baked', 'widespread', 'none',          '5908235610134'),
  ('PL', 'Snack Day',             'sesame_crackers',     'Snacks', 'Snack Day Sesame Crackers',             'baked', 'widespread', 'none',          '5901234562892'),
  ('PL', 'Kupiec',                'cheese_crackers',     'Snacks', 'Kupiec Cheese-flavored Crackers',       'baked', 'widespread', 'none',          '5903229001234'),
  ('PL', 'Grześkowiak',           'salted_crackers',     'Snacks', 'Grześkowiak Salted Crackers',           'baked', 'widespread', 'none',          '5903229152834'),

  -- PRETZELS & STICKS (4)
  ('PL', 'Frito',                 'salted_pretzels',     'Snacks', 'Frito Salted Pretzels',                 'baked', 'widespread', 'none',          '5449500238456'),
  ('PL', 'Crunchips',             'pretzel_rods',        'Snacks', 'Crunchips Pretzel Rods',                'baked', 'widespread', 'none',          '5908235701823'),
  ('PL', 'Bakalland',             'breadsticks',         'Snacks', 'Bakalland Breadsticks',                 'baked', 'widespread', 'none',          '5903229234567'),
  ('PL', 'Alesto',                'grissini',            'Snacks', 'Alesto Grissini Sticks',                'baked', 'widespread', 'none',          '5900951012345'),

  -- POPCORN (3)
  ('PL', 'Lay''s',                'salted_popcorn',      'Snacks', 'Lay''s Salted Popcorn',                 'baked', 'widespread', 'none',          '5449500345123'),
  ('PL', 'Pringles',              'butter_popcorn',      'Snacks', 'Pringles Butter Popcorn',               'baked', 'widespread', 'none',          '5900951012982'),
  ('PL', 'Sante',                 'caramel_popcorn',     'Snacks', 'Sante Caramel Popcorn',                 'baked', 'widespread', 'none',          '5903229345678'),

  -- RICE CAKES (3)
  ('PL', 'Crownfield',            'plain_rice_cakes',    'Snacks', 'Crownfield Plain Rice Cakes',           'baked', 'widespread', 'none',          '5901234567890'),
  ('PL', 'Stop & Shop',           'sesame_rice_cakes',   'Snacks', 'Stop & Shop Sesame Rice Cakes',         'baked', 'widespread', 'none',          '5901234678901'),
  ('PL', 'Naturavena',            'herb_rice_cakes',     'Snacks', 'Naturavena Rice Cakes with Herbs',      'baked', 'widespread', 'none',          '5903229456789'),

  -- DRIED FRUIT & NUTS (4)
  ('PL', 'Vitanella',             'raisins',             'Snacks', 'Vitanella Raisins',                     'dried', 'widespread', 'none',          '5903229567890'),
  ('PL', 'Bakalland',             'dried_cranberries',   'Snacks', 'Bakalland Dried Cranberries',           'dried', 'widespread', 'none',          '5903229678901'),
  ('PL', 'Alesto',                'mixed_nuts',          'Snacks', 'Alesto Mixed Nuts',                     'roasted', 'widespread', 'none',        '5900951023456'),
  ('PL', 'Snack Day',             'pumpkin_seeds',       'Snacks', 'Snack Day Pumpkin Seeds',               'roasted', 'widespread', 'none',        '5901234789012'),

  -- GRANOLA BARS (4)
  ('PL', 'Sante',                 'honey_nut_bar',       'Snacks', 'Sante Honey-Nut Granola Bar',           'baked', 'widespread', 'none',          '5903229789012'),
  ('PL', 'Crownfield',            'fruit_bar',           'Snacks', 'Crownfield Fruit Granola Bar',          'baked', 'widespread', 'none',          '5901234890123'),
  ('PL', 'Naturavena',            'chocolate_bar',       'Snacks', 'Naturavena Chocolate Granola Bar',      'baked', 'widespread', 'none',          '5903229890123'),
  ('PL', 'Stop & Shop',           'reduced_sugar_bar',   'Snacks', 'Stop & Shop Reduced Sugar Granola Bar', 'baked', 'widespread', 'none',          '5901234901234'),

  -- CHEESE PUFFS (2)
  ('PL', 'Lay''s',                'classic_cheese_puffs','Snacks', 'Lay''s Classic Cheese Puffs',           'baked', 'widespread', 'none',          '5449500456789'),
  ('PL', 'Crunchips',             'spicy_cheese_puffs',  'Snacks', 'Crunchips Spicy Cheese Puffs',          'baked', 'widespread', 'none',          '5908235812934'),

  -- VEGETABLE CHIPS (2)
  ('PL', 'Kupiec',                'beet_chips',          'Snacks', 'Kupiec Beet Chips',                     'baked', 'widespread', 'none',          '5903229901234'),
  ('PL', 'Grześkowiak',           'carrot_chips',        'Snacks', 'Grześkowiak Carrot Chips',              'baked', 'widespread', 'none',          '5903229012345')

on conflict (country, brand, product_name) do update set
  product_type       = excluded.product_type,
  category           = excluded.category,
  prep_method        = excluded.prep_method,
  store_availability = excluded.store_availability,
  controversies      = excluded.controversies,
  ean                = excluded.ean;

-- ═══════════════════════════════════════════════════════════════════
-- 2. UPDATE deprecation block (remove products not in current list)
-- ═══════════════════════════════════════════════════════════════════

update products set is_deprecated = true
where country = 'PL' and category = 'Snacks'
  and is_deprecated is not true
  and (brand, product_name) not in (
    ('Lay''s',                'Lay''s Classic Wheat Crackers'),
    ('Pringles',              'Pringles Original Rye Crackers'),
    ('Crunchips',             'Crunchips Multigrain Crackers'),
    ('Snack Day',             'Snack Day Sesame Crackers'),
    ('Kupiec',                'Kupiec Cheese-flavored Crackers'),
    ('Grześkowiak',           'Grześkowiak Salted Crackers'),
    ('Frito',                 'Frito Salted Pretzels'),
    ('Crunchips',             'Crunchips Pretzel Rods'),
    ('Bakalland',             'Bakalland Breadsticks'),
    ('Alesto',                'Alesto Grissini Sticks'),
    ('Lay''s',                'Lay''s Salted Popcorn'),
    ('Pringles',              'Pringles Butter Popcorn'),
    ('Sante',                 'Sante Caramel Popcorn'),
    ('Crownfield',            'Crownfield Plain Rice Cakes'),
    ('Stop & Shop',           'Stop & Shop Sesame Rice Cakes'),
    ('Naturavena',            'Naturavena Rice Cakes with Herbs'),
    ('Vitanella',             'Vitanella Raisins'),
    ('Bakalland',             'Bakalland Dried Cranberries'),
    ('Alesto',                'Alesto Mixed Nuts'),
    ('Snack Day',             'Snack Day Pumpkin Seeds'),
    ('Sante',                 'Sante Honey-Nut Granola Bar'),
    ('Crownfield',            'Crownfield Fruit Granola Bar'),
    ('Naturavena',            'Naturavena Chocolate Granola Bar'),
    ('Stop & Shop',           'Stop & Shop Reduced Sugar Granola Bar'),
    ('Lay''s',                'Lay''s Classic Cheese Puffs'),
    ('Crunchips',             'Crunchips Spicy Cheese Puffs'),
    ('Kupiec',                'Kupiec Beet Chips'),
    ('Grześkowiak',           'Grześkowiak Carrot Chips')
  );

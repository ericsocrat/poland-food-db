-- ============================================================
-- Migration: product_type_ref table + seed data
-- Issue: #354 Phase 1 — Product type taxonomy
-- Purpose: Create a controlled vocabulary for product sub-types
--          within each category. Currently product_type has only
--          2 values ('Grocery', 'Ready-to-eat') across 1,281
--          products. This table enables meaningful sub-type
--          classification (yogurt, cheese, beer, etc.).
-- Rollback: DROP TABLE IF EXISTS product_type_ref CASCADE;
-- ============================================================

-- ─── 1. Create product_type_ref table ────────────────────────
CREATE TABLE IF NOT EXISTS public.product_type_ref (
    product_type    text PRIMARY KEY,
    category        text NOT NULL REFERENCES category_ref(category),
    display_name    text NOT NULL,
    icon_emoji      text,
    sort_order      integer NOT NULL DEFAULT 0,
    is_active       boolean NOT NULL DEFAULT true
);

COMMENT ON TABLE public.product_type_ref IS
  'Controlled vocabulary of product sub-types within each category. '
  'FK target for products.product_type. Issue #354.';

COMMENT ON COLUMN public.product_type_ref.product_type IS
  'Unique slug identifier, e.g. yogurt, beer, crispbread.';
COMMENT ON COLUMN public.product_type_ref.category IS
  'Parent category from category_ref.';
COMMENT ON COLUMN public.product_type_ref.display_name IS
  'Human-readable English display name.';

-- ─── 2. Indexes ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_product_type_ref_category
    ON product_type_ref(category);

-- ─── 3. RLS ──────────────────────────────────────────────────
ALTER TABLE public.product_type_ref ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'product_type_ref'
      AND policyname = 'product_type_ref_read_all'
  ) THEN
    CREATE POLICY product_type_ref_read_all
      ON public.product_type_ref FOR SELECT
      USING (true);
  END IF;
END $$;

GRANT SELECT ON public.product_type_ref TO anon, authenticated, service_role;

-- ─── 4. Seed data ────────────────────────────────────────────
-- Legacy values (backward-compatible with existing data)
INSERT INTO public.product_type_ref (product_type, category, display_name, sort_order) VALUES
  ('Grocery',      'Chips',    'Grocery (legacy)', 999),
  ('Ready-to-eat', 'Żabka',    'Ready-to-eat (legacy)', 999)
ON CONFLICT (product_type) DO NOTHING;

-- Alcohol
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('beer',           'Alcohol', 'Beer',           '🍺', 1),
  ('wine',           'Alcohol', 'Wine',           '🍷', 2),
  ('cider',          'Alcohol', 'Cider',          '🍏', 3),
  ('spirit',         'Alcohol', 'Spirit',         '🥃', 4),
  ('liqueur',        'Alcohol', 'Liqueur',        '🍸', 5),
  ('other-alcohol',  'Alcohol', 'Other Alcohol',  NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Baby
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('baby-cereal',    'Baby', 'Baby Cereal',    '🥣', 1),
  ('baby-puree',     'Baby', 'Baby Purée',     '🍼', 2),
  ('baby-snack',     'Baby', 'Baby Snack',     '🍪', 3),
  ('infant-formula', 'Baby', 'Infant Formula', '🍶', 4),
  ('baby-drink',     'Baby', 'Baby Drink',     '🧃', 5),
  ('other-baby',     'Baby', 'Other Baby',     NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Bread
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('whole-wheat',    'Bread', 'Whole Wheat Bread', '🌾', 1),
  ('white-bread',    'Bread', 'White Bread',       '🍞', 2),
  ('rye-bread',      'Bread', 'Rye Bread',         '🫘', 3),
  ('crispbread',     'Bread', 'Crispbread',        '🥖', 4),
  ('multigrain',     'Bread', 'Multigrain Bread',  '🥐', 5),
  ('tortilla',       'Bread', 'Tortilla / Wrap',   '🌯', 6),
  ('other-bread',    'Bread', 'Other Bread',       NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Breakfast & Grain-Based
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('oatmeal',        'Breakfast & Grain-Based', 'Oatmeal / Porridge', '🥣', 1),
  ('muesli',         'Breakfast & Grain-Based', 'Muesli',             '🥄', 2),
  ('granola',        'Breakfast & Grain-Based', 'Granola',            '🫘', 3),
  ('jam',            'Breakfast & Grain-Based', 'Jam / Preserve',     '🍓', 4),
  ('honey',          'Breakfast & Grain-Based', 'Honey',              '🍯', 5),
  ('pancake-mix',    'Breakfast & Grain-Based', 'Pancake Mix',        '🥞', 6),
  ('spread',         'Breakfast & Grain-Based', 'Spread',             '🧈', 7),
  ('other-breakfast','Breakfast & Grain-Based', 'Other Breakfast',    NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Canned Goods
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('canned-vegetables', 'Canned Goods', 'Canned Vegetables', '🥫', 1),
  ('canned-fish',       'Canned Goods', 'Canned Fish',       '🐟', 2),
  ('canned-meat',       'Canned Goods', 'Canned Meat',       '🥩', 3),
  ('canned-beans',      'Canned Goods', 'Canned Beans',      '🫘', 4),
  ('canned-fruit',      'Canned Goods', 'Canned Fruit',      '🍑', 5),
  ('canned-soup',       'Canned Goods', 'Canned Soup',       '🍲', 6),
  ('other-canned',      'Canned Goods', 'Other Canned',      NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Cereals
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('cereal-flakes',  'Cereals', 'Cereal Flakes',  '🥣', 1),
  ('cereal-rings',   'Cereals', 'Cereal Rings',   '⭕', 2),
  ('puffed-cereal',  'Cereals', 'Puffed Cereal',  '🫧', 3),
  ('cereal-bar',     'Cereals', 'Cereal Bar',      '🍫', 4),
  ('other-cereal',   'Cereals', 'Other Cereal',    NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Chips
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('potato-chips',    'Chips', 'Potato Chips',     '🥔', 1),
  ('corn-chips',      'Chips', 'Corn Chips',       '🌽', 2),
  ('vegetable-chips', 'Chips', 'Vegetable Chips',  '🥕', 3),
  ('tortilla-chips',  'Chips', 'Tortilla Chips',   '🌮', 4),
  ('stacked-chips',   'Chips', 'Stacked Chips',    '📦', 5),
  ('other-chips',     'Chips', 'Other Chips',      NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Condiments
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('ketchup',       'Condiments', 'Ketchup',        '🍅', 1),
  ('mustard',       'Condiments', 'Mustard',         '🟡', 2),
  ('mayonnaise',    'Condiments', 'Mayonnaise',      '🥚', 3),
  ('vinegar',       'Condiments', 'Vinegar',         '🫗', 4),
  ('horseradish',   'Condiments', 'Horseradish',     '🌿', 5),
  ('dressing',      'Condiments', 'Dressing',        '🥗', 6),
  ('other-condiment','Condiments','Other Condiment',  NULL, 99)
ON CONFLICT (product_type) DO NOTHING;

-- Dairy
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('yogurt',       'Dairy', 'Yogurt',        '🥛', 1),
  ('cheese',       'Dairy', 'Cheese',        '🧀', 2),
  ('butter',       'Dairy', 'Butter',        '🧈', 3),
  ('cream',        'Dairy', 'Cream',         '🥄', 4),
  ('milk',         'Dairy', 'Milk',          '🥛', 5),
  ('kefir',        'Dairy', 'Kefir',         '🫗', 6),
  ('quark',        'Dairy', 'Quark',         '🍶', 7),
  ('cottage-cheese','Dairy','Cottage Cheese', '🥣', 8),
  ('other-dairy',  'Dairy', 'Other Dairy',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Drinks
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('water',         'Drinks', 'Water',         '💧', 1),
  ('juice',         'Drinks', 'Juice',         '🧃', 2),
  ('soda',          'Drinks', 'Soda',          '🥤', 3),
  ('energy-drink',  'Drinks', 'Energy Drink',  '⚡', 4),
  ('tea',           'Drinks', 'Tea',           '🍵', 5),
  ('coffee',        'Drinks', 'Coffee',        '☕', 6),
  ('sports-drink',  'Drinks', 'Sports Drink',  '🏃', 7),
  ('other-drink',   'Drinks', 'Other Drink',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Frozen & Prepared
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('frozen-pizza',      'Frozen & Prepared', 'Frozen Pizza',      '🍕', 1),
  ('frozen-meal',       'Frozen & Prepared', 'Frozen Meal',       '🍱', 2),
  ('frozen-vegetables', 'Frozen & Prepared', 'Frozen Vegetables', '🥦', 3),
  ('frozen-dumplings',  'Frozen & Prepared', 'Frozen Dumplings',  '🥟', 4),
  ('frozen-fries',      'Frozen & Prepared', 'Frozen Fries',      '🍟', 5),
  ('other-frozen',      'Frozen & Prepared', 'Other Frozen',      NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Instant & Frozen
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('instant-noodles', 'Instant & Frozen', 'Instant Noodles', '🍜', 1),
  ('instant-soup',    'Instant & Frozen', 'Instant Soup',    '🍲', 2),
  ('instant-meal',    'Instant & Frozen', 'Instant Meal',    '🍛', 3),
  ('other-instant',   'Instant & Frozen', 'Other Instant',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Meat
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('sausage',      'Meat', 'Sausage',       '🌭', 1),
  ('ham',          'Meat', 'Ham',           '🥩', 2),
  ('cured-meat',   'Meat', 'Cured Meat',   '🥓', 3),
  ('pate',         'Meat', 'Pâté',         '🫕', 4),
  ('poultry',      'Meat', 'Poultry',      '🍗', 5),
  ('minced-meat',  'Meat', 'Minced Meat',  '🥩', 6),
  ('other-meat',   'Meat', 'Other Meat',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Nuts, Seeds & Legumes
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('nuts',         'Nuts, Seeds & Legumes', 'Nuts',        '🥜', 1),
  ('seeds',        'Nuts, Seeds & Legumes', 'Seeds',       '🌻', 2),
  ('legumes',      'Nuts, Seeds & Legumes', 'Legumes',     '🫘', 3),
  ('nut-butter',   'Nuts, Seeds & Legumes', 'Nut Butter',  '🥜', 4),
  ('trail-mix',    'Nuts, Seeds & Legumes', 'Trail Mix',   '🥜', 5),
  ('other-nuts',   'Nuts, Seeds & Legumes', 'Other',       NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Plant-Based & Alternatives
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('tofu',          'Plant-Based & Alternatives', 'Tofu',          '🫘', 1),
  ('plant-milk',    'Plant-Based & Alternatives', 'Plant Milk',    '🥛', 2),
  ('plant-meat',    'Plant-Based & Alternatives', 'Plant Meat',    '🌱', 3),
  ('plant-cheese',  'Plant-Based & Alternatives', 'Plant Cheese',  '🧀', 4),
  ('plant-yogurt',  'Plant-Based & Alternatives', 'Plant Yogurt',  '🥣', 5),
  ('other-plant',   'Plant-Based & Alternatives', 'Other Plant-Based', NULL, 99)
ON CONFLICT (product_type) DO NOTHING;

-- Sauces
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('pasta-sauce',   'Sauces', 'Pasta Sauce',   '🍝', 1),
  ('tomato-sauce',  'Sauces', 'Tomato Sauce',  '🍅', 2),
  ('pesto',         'Sauces', 'Pesto',         '🌿', 3),
  ('hot-sauce',     'Sauces', 'Hot Sauce',     '🌶️', 4),
  ('soy-sauce',     'Sauces', 'Soy Sauce',     '🫗', 5),
  ('bbq-sauce',     'Sauces', 'BBQ Sauce',     '🔥', 6),
  ('cooking-sauce', 'Sauces', 'Cooking Sauce', '🫕', 7),
  ('other-sauce',   'Sauces', 'Other Sauce',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Seafood & Fish
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('smoked-fish',   'Seafood & Fish', 'Smoked Fish',   '🐟', 1),
  ('canned-seafood','Seafood & Fish', 'Canned Seafood','🥫', 2),
  ('fresh-fish',    'Seafood & Fish', 'Fresh Fish',    '🐠', 3),
  ('fish-sticks',   'Seafood & Fish', 'Fish Sticks',   '🍤', 4),
  ('shellfish',     'Seafood & Fish', 'Shellfish',     '🦐', 5),
  ('other-seafood', 'Seafood & Fish', 'Other Seafood', NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Snacks
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('crackers',     'Snacks', 'Crackers',      '🍘', 1),
  ('pretzel',      'Snacks', 'Pretzel',       '🥨', 2),
  ('popcorn',      'Snacks', 'Popcorn',       '🍿', 3),
  ('rice-cakes',   'Snacks', 'Rice Cakes',    '🍙', 4),
  ('breadsticks',  'Snacks', 'Breadsticks',   '🥖', 5),
  ('other-snack',  'Snacks', 'Other Snack',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Sweets
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('chocolate',     'Sweets', 'Chocolate',     '🍫', 1),
  ('cookies',       'Sweets', 'Cookies',       '🍪', 2),
  ('candy',         'Sweets', 'Candy',         '🍬', 3),
  ('wafer',         'Sweets', 'Wafer',         '🧇', 4),
  ('gummies',       'Sweets', 'Gummies',       '🐻', 5),
  ('pastry',        'Sweets', 'Pastry',        '🥐', 6),
  ('other-sweet',   'Sweets', 'Other Sweet',   NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- Żabka
INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order) VALUES
  ('sandwich',     'Żabka', 'Sandwich',        '🥪', 1),
  ('wrap',         'Żabka', 'Wrap',            '🌯', 2),
  ('salad',        'Żabka', 'Salad',           '🥗', 3),
  ('hot-dog',      'Żabka', 'Hot Dog',         '🌭', 4),
  ('baked-good',   'Żabka', 'Baked Good',      '🥐', 5),
  ('ready-meal',   'Żabka', 'Ready Meal',      '🍱', 6),
  ('other-zabka',  'Żabka', 'Other Żabka',     NULL,  99)
ON CONFLICT (product_type) DO NOTHING;

-- ─── 5. Update QA check: product_type domain via ref table ───
-- The existing QA check #8 in QA__data_consistency.sql validates
-- product_type IN ('Grocery', 'Ready-to-eat'). After this
-- migration, the ref table is the source of truth for valid
-- product_type values. The QA check will be updated separately.

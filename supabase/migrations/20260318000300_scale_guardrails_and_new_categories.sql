-- Migration: Raise scale guardrails for 10K product expansion + add 7 new food categories
-- Issue: #858
-- Rollback: DELETE FROM category_ref WHERE category IN (
--             'Pasta & Rice','Soups','Coffee & Tea','Frozen Vegetables',
--             'Ready Meals','Desserts & Ice Cream','Spices & Seasonings');
--           Revert check_table_ceilings() ceilings manually
-- Idempotency: All INSERTs use ON CONFLICT DO UPDATE; function is CREATE OR REPLACE

-- ══════════════════════════════════════════════════════════════════════════════
-- 1. Add 7 new food categories to category_ref
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.category_ref (category, display_name, description, icon_emoji, sort_order, slug)
VALUES
  ('Pasta & Rice',           'Pasta & Rice',           'Pasta, rice, noodles, couscous and other grain-based staples',   '🍝', 23, 'pasta-rice'),
  ('Soups',                  'Soups',                  'Soups, broths, bouillons and stews',                             '🍲', 24, 'soups'),
  ('Coffee & Tea',           'Coffee & Tea',           'Coffee, tea, herbal infusions and hot beverages',                '☕', 25, 'coffee-tea'),
  ('Frozen Vegetables',      'Frozen Vegetables',      'Frozen vegetables, fruits, berries and mixed packs',             '🥦', 26, 'frozen-vegetables'),
  ('Ready Meals',            'Ready Meals',            'Complete prepared meals, meal kits and heat-and-eat dishes',      '🍱', 27, 'ready-meals'),
  ('Desserts & Ice Cream',   'Desserts & Ice Cream',   'Desserts, ice cream, puddings and sweet treats',                 '🍨', 28, 'desserts-ice-cream'),
  ('Spices & Seasonings',    'Spices & Seasonings',    'Spices, seasonings, herbs and flavoring blends',                 '🌿', 29, 'spices-seasonings')
ON CONFLICT (category) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description  = EXCLUDED.description,
  icon_emoji   = EXCLUDED.icon_emoji,
  sort_order   = EXCLUDED.sort_order,
  slug         = EXCLUDED.slug;

-- ══════════════════════════════════════════════════════════════════════════════
-- 2. Seed product_type_ref for 7 new categories (subtypes + "other" fallback)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.product_type_ref (product_type, category, display_name, icon_emoji, sort_order, is_active)
VALUES
  -- Pasta & Rice
  ('pasta',               'Pasta & Rice',         'Pasta',              '🍝', 1, true),
  ('rice',                'Pasta & Rice',         'Rice',               '🍚', 2, true),
  ('noodles',             'Pasta & Rice',         'Noodles',            '🍜', 3, true),
  ('couscous',            'Pasta & Rice',         'Couscous',           '🫘', 4, true),
  ('other-pasta-rice',    'Pasta & Rice',         'Other Pasta & Rice', '🍝', 99, true),

  -- Soups
  ('soup-ready',          'Soups',                'Ready Soup',         '🍲', 1, true),
  ('soup-instant',        'Soups',                'Instant Soup',       '🥣', 2, true),
  ('broth',               'Soups',                'Broth / Bouillon',   '🫕', 3, true),
  ('soup-cream',          'Soups',                'Cream Soup',         '🥣', 4, true),
  ('other-soups',         'Soups',                'Other Soups',        '🍲', 99, true),

  -- Coffee & Tea
  ('coffee-ground',       'Coffee & Tea',         'Ground Coffee',      '☕', 1, true),
  ('coffee-instant',      'Coffee & Tea',         'Instant Coffee',     '☕', 2, true),
  ('coffee-beans',        'Coffee & Tea',         'Coffee Beans',       '☕', 3, true),
  ('tea',                 'Coffee & Tea',         'Tea',                '🍵', 4, true),
  ('herbal-infusion',     'Coffee & Tea',         'Herbal Infusion',    '🌿', 5, true),
  ('other-coffee-tea',    'Coffee & Tea',         'Other Coffee & Tea', '☕', 99, true),

  -- Frozen Vegetables
  ('frozen-veg-single',   'Frozen Vegetables',    'Single Vegetable',   '🥦', 1, true),
  ('frozen-veg-mix',      'Frozen Vegetables',    'Vegetable Mix',      '🥗', 2, true),
  ('frozen-fruit',        'Frozen Vegetables',    'Frozen Fruit',       '🍓', 3, true),
  ('frozen-herbs',        'Frozen Vegetables',    'Frozen Herbs',       '🌿', 4, true),
  ('other-frozen-veg',    'Frozen Vegetables',    'Other Frozen Veg',   '🥦', 99, true),

  -- Ready Meals
  ('meal-frozen',         'Ready Meals',          'Frozen Ready Meal',  '🍱', 1, true),
  ('meal-chilled',        'Ready Meals',          'Chilled Ready Meal', '🥡', 2, true),
  ('meal-canned',         'Ready Meals',          'Canned Ready Meal',  '🥫', 3, true),
  ('meal-kit',            'Ready Meals',          'Meal Kit',           '📦', 4, true),
  ('other-ready-meals',   'Ready Meals',          'Other Ready Meals',  '🍱', 99, true),

  -- Desserts & Ice Cream
  ('ice-cream',           'Desserts & Ice Cream', 'Ice Cream',          '🍦', 1, true),
  ('pudding',             'Desserts & Ice Cream', 'Pudding',            '🍮', 2, true),
  ('mousse',              'Desserts & Ice Cream', 'Mousse',             '🥄', 3, true),
  ('jelly',               'Desserts & Ice Cream', 'Jelly / Gelatin',    '🍬', 4, true),
  ('frozen-dessert',      'Desserts & Ice Cream', 'Frozen Dessert',     '🍧', 5, true),
  ('other-desserts',      'Desserts & Ice Cream', 'Other Desserts',     '🍨', 99, true),

  -- Spices & Seasonings
  ('spice-single',        'Spices & Seasonings',  'Single Spice',       '🌶️', 1, true),
  ('spice-blend',         'Spices & Seasonings',  'Spice Blend',        '🧂', 2, true),
  ('dried-herbs',         'Spices & Seasonings',  'Dried Herbs',        '🌿', 3, true),
  ('seasoning-mix',       'Spices & Seasonings',  'Seasoning Mix',      '🫙', 4, true),
  ('other-spices',        'Spices & Seasonings',  'Other Spices',       '🌿', 99, true)
ON CONFLICT (product_type) DO UPDATE SET
  category     = EXCLUDED.category,
  display_name = EXCLUDED.display_name,
  icon_emoji   = EXCLUDED.icon_emoji,
  sort_order   = EXCLUDED.sort_order,
  is_active    = EXCLUDED.is_active;

-- ══════════════════════════════════════════════════════════════════════════════
-- 3. Raise scale guardrails — update check_table_ceilings() ceilings
--    Target: 25,000 products (10K per country × 2 + headroom)
-- ══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION check_table_ceilings()
RETURNS TABLE(table_name text, current_rows bigint, ceiling bigint,
              pct_of_ceiling numeric, status text)
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
    WITH ceilings(tbl, cap) AS (VALUES
        ('products',                 25000::bigint),
        ('nutrition_facts',          25000),
        ('product_ingredient',       250000),
        ('ingredient_ref',           15000),
        ('product_allergen_info',    75000),
        ('source_nutrition',         50000),
        ('product_field_provenance', 250000)
    ),
    counts AS (
        SELECT 'products'                AS tbl, COUNT(*) AS n FROM products
        UNION ALL
        SELECT 'nutrition_facts',               COUNT(*) FROM nutrition_facts
        UNION ALL
        SELECT 'product_ingredient',            COUNT(*) FROM product_ingredient
        UNION ALL
        SELECT 'ingredient_ref',                COUNT(*) FROM ingredient_ref
        UNION ALL
        SELECT 'product_allergen_info',         COUNT(*) FROM product_allergen_info
        UNION ALL
        SELECT 'source_nutrition',              COUNT(*) FROM source_nutrition
        UNION ALL
        SELECT 'product_field_provenance',      COUNT(*) FROM product_field_provenance
    )
    SELECT c.tbl,
           ct.n,
           c.cap,
           ROUND(100.0 * ct.n / c.cap, 1),
           CASE
               WHEN ct.n > c.cap       THEN 'EXCEEDED'
               WHEN ct.n > c.cap * 0.8 THEN 'WARNING'
               ELSE 'OK'
           END
    FROM ceilings c
    JOIN counts ct ON ct.tbl = c.tbl
    ORDER BY ROUND(100.0 * ct.n / c.cap, 1) DESC;
$fn$;

-- ══════════════════════════════════════════════════════════════════════════════
-- 4. Verification
-- ══════════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
    v_count int;
BEGIN
    -- Verify 7 new categories exist
    SELECT COUNT(*) INTO v_count
    FROM category_ref
    WHERE category IN (
        'Pasta & Rice', 'Soups', 'Coffee & Tea', 'Frozen Vegetables',
        'Ready Meals', 'Desserts & Ice Cream', 'Spices & Seasonings'
    );
    IF v_count != 7 THEN
        RAISE EXCEPTION 'Expected 7 new categories, found %', v_count;
    END IF;

    -- Verify updated ceiling for products is 25000
    SELECT ceiling INTO v_count
    FROM check_table_ceilings()
    WHERE table_name = 'products';
    IF v_count != 25000 THEN
        RAISE EXCEPTION 'Expected products ceiling 25000, found %', v_count;
    END IF;

    -- Verify all 7 new categories have product_type_ref "other" fallback
    SELECT COUNT(DISTINCT category) INTO v_count
    FROM product_type_ref
    WHERE category IN (
        'Pasta & Rice', 'Soups', 'Coffee & Tea', 'Frozen Vegetables',
        'Ready Meals', 'Desserts & Ice Cream', 'Spices & Seasonings'
    ) AND product_type LIKE 'other-%';
    IF v_count != 7 THEN
        RAISE EXCEPTION 'Expected 7 other-* fallback types, found %', v_count;
    END IF;

    RAISE NOTICE 'Migration verified: 7 new categories + product types + updated scale guardrails';
END $$;

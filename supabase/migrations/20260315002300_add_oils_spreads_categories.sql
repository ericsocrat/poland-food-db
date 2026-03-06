-- Migration: Add Oils & Vinegars and Spreads & Dips categories to category_ref
-- Rollback: DELETE FROM category_ref WHERE category IN ('Oils & Vinegars', 'Spreads & Dips');
-- Idempotency: ON CONFLICT DO NOTHING — safe to run repeatedly

INSERT INTO public.category_ref
  (category, display_name, description, icon_emoji, sort_order, slug, is_active, target_per_category)
VALUES
  ('Oils & Vinegars',  'Oils & Vinegars',  'Cooking oils, olive oils, and vinegars',       '🫒', 21, 'oils-vinegars',  true, 75),
  ('Spreads & Dips',   'Spreads & Dips',   'Spreads, dips, pâtés, and tapenades',          '🥣', 22, 'spreads-dips',   true, 75)
ON CONFLICT (category) DO NOTHING;

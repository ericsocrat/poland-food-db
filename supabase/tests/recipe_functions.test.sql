-- ─── pgTAP: Recipe API function tests ────────────────────────────────────────
-- Tests api_get_recipes, api_get_recipe_detail, api_get_recipe_nutrition.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- Issue: #364 — Recipe system completion
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(25);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

-- Insert a test recipe with ingredients and steps
INSERT INTO public.recipe (
  id, slug, title_key, description_key, category, difficulty,
  prep_time_min, cook_time_min, servings, country, is_published, tags
) VALUES (
  'a0000000-0000-0000-0000-000000000001'::uuid,
  'pgtap-test-recipe',
  'test.recipe.title',
  'test.recipe.description',
  'breakfast', 'easy', 10, 5, 2, 'PL', TRUE,
  ARRAY['vegetarian', 'quick']
) ON CONFLICT (slug) DO NOTHING;

-- Unpublished recipe (should be excluded from API results)
INSERT INTO public.recipe (
  id, slug, title_key, description_key, category, difficulty,
  prep_time_min, cook_time_min, servings, country, is_published, tags
) VALUES (
  'a0000000-0000-0000-0000-000000000002'::uuid,
  'pgtap-unpublished-recipe',
  'test.unpublished.title',
  'test.unpublished.description',
  'dinner', 'hard', 30, 60, 4, 'PL', FALSE,
  ARRAY['advanced']
) ON CONFLICT (slug) DO NOTHING;

-- Add steps to published recipe
INSERT INTO public.recipe_step (recipe_id, step_number, content_key)
VALUES
  ('a0000000-0000-0000-0000-000000000001'::uuid, 1, 'test.recipe.steps.1'),
  ('a0000000-0000-0000-0000-000000000001'::uuid, 2, 'test.recipe.steps.2')
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Add ingredients to published recipe
INSERT INTO public.recipe_ingredient (id, recipe_id, name_key, sort_order, optional)
VALUES
  ('b0000000-0000-0000-0000-000000000001'::uuid,
   'a0000000-0000-0000-0000-000000000001'::uuid,
   'test.recipe.ingredients.1', 1, FALSE),
  ('b0000000-0000-0000-0000-000000000002'::uuid,
   'a0000000-0000-0000-0000-000000000001'::uuid,
   'test.recipe.ingredients.2', 2, TRUE)
ON CONFLICT (recipe_id, sort_order) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_get_recipes — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_recipes()$$,
  'api_get_recipes() does not throw with no args'
);

SELECT lives_ok(
  $$SELECT public.api_get_recipes('PL', 'breakfast')$$,
  'api_get_recipes(PL, breakfast) does not throw'
);

-- Top-level keys
SELECT ok(
  (public.api_get_recipes()) ? 'total_count',
  'recipes response has total_count'
);

SELECT ok(
  (public.api_get_recipes()) ? 'recipes',
  'recipes response has recipes array'
);

SELECT ok(
  (public.api_get_recipes()) ? 'filters',
  'recipes response has filters'
);

SELECT ok(
  (public.api_get_recipes()) ? 'limit',
  'recipes response has limit'
);

SELECT ok(
  (public.api_get_recipes()) ? 'offset',
  'recipes response has offset'
);

-- Should return at least one recipe (our fixture)
SELECT ok(
  jsonb_array_length((public.api_get_recipes('PL', 'breakfast'))->'recipes') > 0,
  'returns at least 1 breakfast recipe for PL'
);

-- Unpublished recipe should not appear
SELECT is(
  (SELECT COUNT(*)::int FROM jsonb_array_elements(
    (public.api_get_recipes('PL', 'dinner'))->'recipes'
  ) elem WHERE elem->>'slug' = 'pgtap-unpublished-recipe'),
  0,
  'unpublished recipe excluded from results'
);

-- Recipe element has expected keys
SELECT ok(
  ((public.api_get_recipes('PL', 'breakfast'))->'recipes'->0) ? 'slug',
  'recipe element has slug'
);

SELECT ok(
  ((public.api_get_recipes('PL', 'breakfast'))->'recipes'->0) ? 'title_key',
  'recipe element has title_key'
);

SELECT ok(
  ((public.api_get_recipes('PL', 'breakfast'))->'recipes'->0) ? 'ingredient_count',
  'recipe element has ingredient_count'
);

SELECT ok(
  ((public.api_get_recipes('PL', 'breakfast'))->'recipes'->0) ? 'step_count',
  'recipe element has step_count'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_get_recipe_detail — valid slug
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_recipe_detail('pgtap-test-recipe')$$,
  'api_get_recipe_detail does not throw for valid slug'
);

-- Top-level keys
SELECT ok(
  (public.api_get_recipe_detail('pgtap-test-recipe')) ? 'recipe',
  'detail has recipe object'
);

SELECT ok(
  (public.api_get_recipe_detail('pgtap-test-recipe')) ? 'ingredients',
  'detail has ingredients array'
);

SELECT ok(
  (public.api_get_recipe_detail('pgtap-test-recipe')) ? 'steps',
  'detail has steps array'
);

SELECT ok(
  (public.api_get_recipe_detail('pgtap-test-recipe')) ? 'ingredient_count',
  'detail has ingredient_count'
);

-- Should have 2 steps and 2 ingredients
SELECT is(
  ((public.api_get_recipe_detail('pgtap-test-recipe'))->>'step_count')::int,
  2,
  'detail shows 2 steps'
);

SELECT is(
  ((public.api_get_recipe_detail('pgtap-test-recipe'))->>'ingredient_count')::int,
  2,
  'detail shows 2 ingredients'
);

-- Not-found returns error
SELECT ok(
  (public.api_get_recipe_detail('nonexistent-slug')) ? 'error',
  'detail returns error for nonexistent slug'
);

-- Unpublished returns error
SELECT ok(
  (public.api_get_recipe_detail('pgtap-unpublished-recipe')) ? 'error',
  'detail returns error for unpublished recipe'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_recipe_nutrition — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_recipe_nutrition('pgtap-test-recipe')$$,
  'api_get_recipe_nutrition does not throw'
);

-- Top-level keys
SELECT ok(
  (public.api_get_recipe_nutrition('pgtap-test-recipe')) ? 'total_ingredients',
  'nutrition has total_ingredients'
);

SELECT ok(
  (public.api_get_recipe_nutrition('pgtap-test-recipe')) ? 'coverage_pct',
  'nutrition has coverage_pct'
);

-- Not-found returns error
SELECT ok(
  (public.api_get_recipe_nutrition('nonexistent-slug')) ? 'error',
  'nutrition returns error for nonexistent slug'
);


-- ─── Finish ─────────────────────────────────────────────────────────────────

SELECT * FROM finish();
ROLLBACK;

-- ============================================================================
-- Migration: 20260222000100_recipes_v0.sql
-- Issue: #53 — Recipes v0 — Schema + Browse + Detail (Curated Only)
-- Description: Creates recipe, recipe_step, recipe_ingredient tables with
--              RLS, browse_recipes() and get_recipe_detail() RPCs.
-- Rollback: DROP FUNCTION IF EXISTS get_recipe_detail; DROP FUNCTION IF EXISTS browse_recipes;
--           DROP TABLE IF EXISTS recipe_ingredient; DROP TABLE IF EXISTS recipe_step;
--           DROP TABLE IF EXISTS recipe;
-- ============================================================================

-- ─── Recipe table ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.recipe (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title_key       TEXT NOT NULL,
  description_key TEXT NOT NULL,
  category        TEXT NOT NULL CHECK (category IN (
    'breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'drink', 'salad', 'soup'
  )),
  difficulty      TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'easy',
  prep_time_min   INTEGER NOT NULL CHECK (prep_time_min > 0),
  cook_time_min   INTEGER NOT NULL DEFAULT 0 CHECK (cook_time_min >= 0),
  servings        INTEGER NOT NULL CHECK (servings > 0),
  image_url       TEXT,
  country         TEXT DEFAULT NULL,
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  tags            TEXT[] NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Recipe steps (ordered instructions) ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.recipe_step (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   UUID NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL CHECK (step_number > 0),
  content_key TEXT NOT NULL,
  UNIQUE (recipe_id, step_number)
);

-- ─── Recipe ingredients ───────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.recipe_ingredient (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   UUID NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
  name_key    TEXT NOT NULL,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  optional    BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (recipe_id, sort_order)
);

-- ─── RLS ──────────────────────────────────────────────────────────────────────

ALTER TABLE recipe ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_step ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredient ENABLE ROW LEVEL SECURITY;

-- Anyone can read published recipes
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'recipe' AND policyname = 'Published recipes are public'
  ) THEN
    CREATE POLICY "Published recipes are public" ON recipe FOR SELECT USING (is_published = TRUE);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'recipe_step' AND policyname = 'Recipe steps are public'
  ) THEN
    CREATE POLICY "Recipe steps are public" ON recipe_step FOR SELECT
      USING (EXISTS (SELECT 1 FROM recipe WHERE id = recipe_step.recipe_id AND is_published = TRUE));
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'recipe_ingredient' AND policyname = 'Recipe ingredients are public'
  ) THEN
    CREATE POLICY "Recipe ingredients are public" ON recipe_ingredient FOR SELECT
      USING (EXISTS (SELECT 1 FROM recipe WHERE id = recipe_ingredient.recipe_id AND is_published = TRUE));
  END IF;
END $$;

-- ─── Indexes ──────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_recipe_category ON recipe(category) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_recipe_country ON recipe(country) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_recipe_tags ON recipe USING GIN(tags) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_recipe_step_recipe ON recipe_step(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredient_recipe ON recipe_ingredient(recipe_id);

-- ─── Browse recipes RPC ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION browse_recipes(
  p_category TEXT DEFAULT NULL,
  p_country TEXT DEFAULT NULL,
  p_tag TEXT DEFAULT NULL,
  p_difficulty TEXT DEFAULT NULL,
  p_max_time INTEGER DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID, slug TEXT, title_key TEXT, description_key TEXT,
  category TEXT, difficulty TEXT, prep_time_min INTEGER,
  cook_time_min INTEGER, servings INTEGER, image_url TEXT,
  country TEXT, tags TEXT[], total_time INTEGER
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT r.id, r.slug, r.title_key, r.description_key,
         r.category, r.difficulty, r.prep_time_min,
         r.cook_time_min, r.servings, r.image_url,
         r.country, r.tags,
         (r.prep_time_min + r.cook_time_min) AS total_time
  FROM recipe r
  WHERE r.is_published = TRUE
    AND (p_category IS NULL OR r.category = p_category)
    AND (p_country IS NULL OR r.country IS NULL OR r.country = p_country)
    AND (p_tag IS NULL OR p_tag = ANY(r.tags))
    AND (p_difficulty IS NULL OR r.difficulty = p_difficulty)
    AND (p_max_time IS NULL OR (r.prep_time_min + r.cook_time_min) <= p_max_time)
  ORDER BY r.created_at DESC
  LIMIT p_limit OFFSET p_offset;
$$;

-- ─── Get recipe detail RPC ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_recipe_detail(p_slug TEXT)
RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_recipe RECORD;
  v_steps JSONB;
  v_ingredients JSONB;
BEGIN
  SELECT * INTO v_recipe FROM recipe WHERE slug = p_slug AND is_published = TRUE;
  IF v_recipe IS NULL THEN RETURN NULL; END IF;

  SELECT jsonb_agg(jsonb_build_object(
    'step_number', rs.step_number,
    'content_key', rs.content_key
  ) ORDER BY rs.step_number)
  INTO v_steps
  FROM recipe_step rs WHERE rs.recipe_id = v_recipe.id;

  SELECT jsonb_agg(jsonb_build_object(
    'name_key', ri.name_key,
    'optional', ri.optional
  ) ORDER BY ri.sort_order)
  INTO v_ingredients
  FROM recipe_ingredient ri WHERE ri.recipe_id = v_recipe.id;

  RETURN jsonb_build_object(
    'id', v_recipe.id,
    'slug', v_recipe.slug,
    'title_key', v_recipe.title_key,
    'description_key', v_recipe.description_key,
    'category', v_recipe.category,
    'difficulty', v_recipe.difficulty,
    'prep_time_min', v_recipe.prep_time_min,
    'cook_time_min', v_recipe.cook_time_min,
    'servings', v_recipe.servings,
    'image_url', v_recipe.image_url,
    'country', v_recipe.country,
    'tags', v_recipe.tags,
    'steps', COALESCE(v_steps, '[]'::jsonb),
    'ingredients', COALESCE(v_ingredients, '[]'::jsonb)
  );
END;
$$;

-- ─── Seed 12 curated starter recipes ──────────────────────────────────────────

INSERT INTO recipe (slug, title_key, description_key, category, difficulty, prep_time_min, cook_time_min, servings, country, is_published, tags)
VALUES
  ('overnight-oats', 'recipes.items.overnight_oats.title', 'recipes.items.overnight_oats.description', 'breakfast', 'easy', 10, 0, 2, 'PL', TRUE, ARRAY['vegetarian', 'quick', 'high-fiber']),
  ('jajecznica', 'recipes.items.jajecznica.title', 'recipes.items.jajecznica.description', 'breakfast', 'easy', 5, 10, 2, 'PL', TRUE, ARRAY['quick', 'high-protein']),
  ('zupa-pomidorowa', 'recipes.items.zupa_pomidorowa.title', 'recipes.items.zupa_pomidorowa.description', 'soup', 'easy', 10, 20, 4, 'PL', TRUE, ARRAY['vegetarian', 'comfort-food']),
  ('chicken-salad-yogurt', 'recipes.items.chicken_salad_yogurt.title', 'recipes.items.chicken_salad_yogurt.description', 'lunch', 'easy', 15, 5, 2, 'PL', TRUE, ARRAY['high-protein', 'low-fat']),
  ('baked-salmon-vegetables', 'recipes.items.baked_salmon_vegetables.title', 'recipes.items.baked_salmon_vegetables.description', 'dinner', 'medium', 15, 25, 2, 'PL', TRUE, ARRAY['high-protein', 'omega-3']),
  ('pierogi-simplified', 'recipes.items.pierogi_simplified.title', 'recipes.items.pierogi_simplified.description', 'dinner', 'hard', 45, 45, 6, 'PL', TRUE, ARRAY['traditional', 'comfort-food']),
  ('yogurt-nuts-honey', 'recipes.items.yogurt_nuts_honey.title', 'recipes.items.yogurt_nuts_honey.description', 'snack', 'easy', 5, 0, 1, 'PL', TRUE, ARRAY['vegetarian', 'quick', 'high-protein']),
  ('hummus-vegetables', 'recipes.items.hummus_vegetables.title', 'recipes.items.hummus_vegetables.description', 'snack', 'easy', 15, 0, 4, 'PL', TRUE, ARRAY['vegan', 'high-fiber']),
  ('red-lentil-soup', 'recipes.items.red_lentil_soup.title', 'recipes.items.red_lentil_soup.description', 'soup', 'easy', 10, 25, 4, 'PL', TRUE, ARRAY['vegan', 'high-protein', 'high-fiber']),
  ('mediterranean-quinoa-salad', 'recipes.items.mediterranean_quinoa_salad.title', 'recipes.items.mediterranean_quinoa_salad.description', 'salad', 'easy', 15, 5, 4, NULL, TRUE, ARRAY['vegetarian', 'high-fiber']),
  ('green-smoothie', 'recipes.items.green_smoothie.title', 'recipes.items.green_smoothie.description', 'drink', 'easy', 5, 0, 1, NULL, TRUE, ARRAY['vegan', 'quick', 'high-fiber']),
  ('baked-apples-cinnamon', 'recipes.items.baked_apples_cinnamon.title', 'recipes.items.baked_apples_cinnamon.description', 'dessert', 'easy', 10, 20, 4, NULL, TRUE, ARRAY['vegetarian', 'low-fat'])
ON CONFLICT (slug) DO NOTHING;

-- ─── Seed recipe steps ────────────────────────────────────────────────────────

-- Overnight Oats
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.overnight_oats.steps.1'),
  (2, 'recipes.items.overnight_oats.steps.2'),
  (3, 'recipes.items.overnight_oats.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'overnight-oats'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Jajecznica
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.jajecznica.steps.1'),
  (2, 'recipes.items.jajecznica.steps.2'),
  (3, 'recipes.items.jajecznica.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'jajecznica'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Zupa Pomidorowa
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.zupa_pomidorowa.steps.1'),
  (2, 'recipes.items.zupa_pomidorowa.steps.2'),
  (3, 'recipes.items.zupa_pomidorowa.steps.3'),
  (4, 'recipes.items.zupa_pomidorowa.steps.4')
) AS s(step_number, content_key)
WHERE r.slug = 'zupa-pomidorowa'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Chicken Salad
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.chicken_salad_yogurt.steps.1'),
  (2, 'recipes.items.chicken_salad_yogurt.steps.2'),
  (3, 'recipes.items.chicken_salad_yogurt.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'chicken-salad-yogurt'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Baked Salmon
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.baked_salmon_vegetables.steps.1'),
  (2, 'recipes.items.baked_salmon_vegetables.steps.2'),
  (3, 'recipes.items.baked_salmon_vegetables.steps.3'),
  (4, 'recipes.items.baked_salmon_vegetables.steps.4')
) AS s(step_number, content_key)
WHERE r.slug = 'baked-salmon-vegetables'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Pierogi
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.pierogi_simplified.steps.1'),
  (2, 'recipes.items.pierogi_simplified.steps.2'),
  (3, 'recipes.items.pierogi_simplified.steps.3'),
  (4, 'recipes.items.pierogi_simplified.steps.4'),
  (5, 'recipes.items.pierogi_simplified.steps.5')
) AS s(step_number, content_key)
WHERE r.slug = 'pierogi-simplified'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Yogurt with Nuts
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.yogurt_nuts_honey.steps.1'),
  (2, 'recipes.items.yogurt_nuts_honey.steps.2')
) AS s(step_number, content_key)
WHERE r.slug = 'yogurt-nuts-honey'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Hummus
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.hummus_vegetables.steps.1'),
  (2, 'recipes.items.hummus_vegetables.steps.2'),
  (3, 'recipes.items.hummus_vegetables.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'hummus-vegetables'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Red Lentil Soup
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.red_lentil_soup.steps.1'),
  (2, 'recipes.items.red_lentil_soup.steps.2'),
  (3, 'recipes.items.red_lentil_soup.steps.3'),
  (4, 'recipes.items.red_lentil_soup.steps.4')
) AS s(step_number, content_key)
WHERE r.slug = 'red-lentil-soup'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Mediterranean Quinoa Salad
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.mediterranean_quinoa_salad.steps.1'),
  (2, 'recipes.items.mediterranean_quinoa_salad.steps.2'),
  (3, 'recipes.items.mediterranean_quinoa_salad.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'mediterranean-quinoa-salad'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Green Smoothie
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.green_smoothie.steps.1'),
  (2, 'recipes.items.green_smoothie.steps.2')
) AS s(step_number, content_key)
WHERE r.slug = 'green-smoothie'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Baked Apples
INSERT INTO recipe_step (recipe_id, step_number, content_key)
SELECT r.id, s.step_number, s.content_key
FROM recipe r, (VALUES
  (1, 'recipes.items.baked_apples_cinnamon.steps.1'),
  (2, 'recipes.items.baked_apples_cinnamon.steps.2'),
  (3, 'recipes.items.baked_apples_cinnamon.steps.3')
) AS s(step_number, content_key)
WHERE r.slug = 'baked-apples-cinnamon'
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- ─── Seed recipe ingredients ──────────────────────────────────────────────────

-- Overnight Oats
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.overnight_oats.ingredients.1', 1, FALSE),
  ('recipes.items.overnight_oats.ingredients.2', 2, FALSE),
  ('recipes.items.overnight_oats.ingredients.3', 3, FALSE),
  ('recipes.items.overnight_oats.ingredients.4', 4, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'overnight-oats'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Jajecznica
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.jajecznica.ingredients.1', 1, FALSE),
  ('recipes.items.jajecznica.ingredients.2', 2, FALSE),
  ('recipes.items.jajecznica.ingredients.3', 3, FALSE),
  ('recipes.items.jajecznica.ingredients.4', 4, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'jajecznica'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Zupa Pomidorowa
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.zupa_pomidorowa.ingredients.1', 1, FALSE),
  ('recipes.items.zupa_pomidorowa.ingredients.2', 2, FALSE),
  ('recipes.items.zupa_pomidorowa.ingredients.3', 3, FALSE),
  ('recipes.items.zupa_pomidorowa.ingredients.4', 4, FALSE),
  ('recipes.items.zupa_pomidorowa.ingredients.5', 5, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'zupa-pomidorowa'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Chicken Salad
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.chicken_salad_yogurt.ingredients.1', 1, FALSE),
  ('recipes.items.chicken_salad_yogurt.ingredients.2', 2, FALSE),
  ('recipes.items.chicken_salad_yogurt.ingredients.3', 3, FALSE),
  ('recipes.items.chicken_salad_yogurt.ingredients.4', 4, FALSE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'chicken-salad-yogurt'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Baked Salmon
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.baked_salmon_vegetables.ingredients.1', 1, FALSE),
  ('recipes.items.baked_salmon_vegetables.ingredients.2', 2, FALSE),
  ('recipes.items.baked_salmon_vegetables.ingredients.3', 3, FALSE),
  ('recipes.items.baked_salmon_vegetables.ingredients.4', 4, FALSE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'baked-salmon-vegetables'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Pierogi
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.pierogi_simplified.ingredients.1', 1, FALSE),
  ('recipes.items.pierogi_simplified.ingredients.2', 2, FALSE),
  ('recipes.items.pierogi_simplified.ingredients.3', 3, FALSE),
  ('recipes.items.pierogi_simplified.ingredients.4', 4, FALSE),
  ('recipes.items.pierogi_simplified.ingredients.5', 5, FALSE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'pierogi-simplified'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Yogurt with Nuts
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.yogurt_nuts_honey.ingredients.1', 1, FALSE),
  ('recipes.items.yogurt_nuts_honey.ingredients.2', 2, FALSE),
  ('recipes.items.yogurt_nuts_honey.ingredients.3', 3, FALSE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'yogurt-nuts-honey'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Hummus
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.hummus_vegetables.ingredients.1', 1, FALSE),
  ('recipes.items.hummus_vegetables.ingredients.2', 2, FALSE),
  ('recipes.items.hummus_vegetables.ingredients.3', 3, FALSE),
  ('recipes.items.hummus_vegetables.ingredients.4', 4, FALSE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'hummus-vegetables'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Red Lentil Soup
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.red_lentil_soup.ingredients.1', 1, FALSE),
  ('recipes.items.red_lentil_soup.ingredients.2', 2, FALSE),
  ('recipes.items.red_lentil_soup.ingredients.3', 3, FALSE),
  ('recipes.items.red_lentil_soup.ingredients.4', 4, FALSE),
  ('recipes.items.red_lentil_soup.ingredients.5', 5, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'red-lentil-soup'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Mediterranean Quinoa Salad
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.mediterranean_quinoa_salad.ingredients.1', 1, FALSE),
  ('recipes.items.mediterranean_quinoa_salad.ingredients.2', 2, FALSE),
  ('recipes.items.mediterranean_quinoa_salad.ingredients.3', 3, FALSE),
  ('recipes.items.mediterranean_quinoa_salad.ingredients.4', 4, FALSE),
  ('recipes.items.mediterranean_quinoa_salad.ingredients.5', 5, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'mediterranean-quinoa-salad'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Green Smoothie
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.green_smoothie.ingredients.1', 1, FALSE),
  ('recipes.items.green_smoothie.ingredients.2', 2, FALSE),
  ('recipes.items.green_smoothie.ingredients.3', 3, FALSE),
  ('recipes.items.green_smoothie.ingredients.4', 4, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'green-smoothie'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

-- Baked Apples
INSERT INTO recipe_ingredient (recipe_id, name_key, sort_order, optional)
SELECT r.id, i.name_key, i.sort_order, i.optional
FROM recipe r, (VALUES
  ('recipes.items.baked_apples_cinnamon.ingredients.1', 1, FALSE),
  ('recipes.items.baked_apples_cinnamon.ingredients.2', 2, FALSE),
  ('recipes.items.baked_apples_cinnamon.ingredients.3', 3, FALSE),
  ('recipes.items.baked_apples_cinnamon.ingredients.4', 4, TRUE)
) AS i(name_key, sort_order, optional)
WHERE r.slug = 'baked-apples-cinnamon'
ON CONFLICT (recipe_id, sort_order) DO NOTHING;

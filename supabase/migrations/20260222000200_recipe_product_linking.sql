-- ─── Migration: Recipe ↔ Product Linking ────────────────────────────────────
-- Issue #54 — Ingredient Matching + Find Product UX
-- Adds ingredient_ref linking to recipe_ingredient, many-to-many junction
--   table recipe_ingredient_product, find_products_for_recipe_ingredient() RPC,
--   and updates get_recipe_detail() to include linked products.
-- Rollback: DROP FUNCTION IF EXISTS find_products_for_recipe_ingredient;
--           ALTER TABLE recipe_ingredient DROP COLUMN IF EXISTS ingredient_ref_id;
--           DROP TABLE IF EXISTS recipe_ingredient_product;
-- ─────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Extend recipe_ingredient with ingredient_ref link
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE recipe_ingredient
  ADD COLUMN IF NOT EXISTS ingredient_ref_id BIGINT
    REFERENCES ingredient_ref(ingredient_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_recipe_ingredient_ref
  ON recipe_ingredient(ingredient_ref_id)
  WHERE ingredient_ref_id IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Junction table: recipe_ingredient ↔ products (many-to-many)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS recipe_ingredient_product (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_ingredient_id  UUID NOT NULL
                          REFERENCES recipe_ingredient(id) ON DELETE CASCADE,
  product_id            BIGINT NOT NULL
                          REFERENCES products(product_id) ON DELETE CASCADE,
  is_primary            BOOLEAN NOT NULL DEFAULT FALSE,
  match_confidence      REAL CHECK (match_confidence BETWEEN 0 AND 1),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (recipe_ingredient_id, product_id)
);

-- RLS: links are readable when the parent recipe is published
ALTER TABLE recipe_ingredient_product ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'recipe_ingredient_product'
      AND policyname = 'Recipe product links are public'
  ) THEN
    EXECUTE $pol$
      CREATE POLICY "Recipe product links are public"
        ON recipe_ingredient_product FOR SELECT
        USING (EXISTS (
          SELECT 1 FROM recipe_ingredient ri
          JOIN recipe r ON r.id = ri.recipe_id
          WHERE ri.id = recipe_ingredient_product.recipe_ingredient_id
            AND r.is_published = TRUE
        ))
    $pol$;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_rip_ingredient
  ON recipe_ingredient_product(recipe_ingredient_id);

CREATE INDEX IF NOT EXISTS idx_rip_product
  ON recipe_ingredient_product(product_id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. find_products_for_recipe_ingredient() — matching function
-- ═══════════════════════════════════════════════════════════════════════════════
-- Returns linked products (admin-curated) first, then auto-suggested products
-- sharing the same ingredient_ref. Sorted: primary first → linked → by score.

CREATE OR REPLACE FUNCTION find_products_for_recipe_ingredient(
  p_recipe_ingredient_id UUID,
  p_country              TEXT DEFAULT NULL,
  p_limit                INTEGER DEFAULT 10
)
RETURNS TABLE (
  product_id          BIGINT,
  product_name        TEXT,
  brand               TEXT,
  ean                 TEXT,
  unhealthiness_score NUMERIC,
  image_url           TEXT,
  is_linked           BOOLEAN,
  is_primary          BOOLEAN
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  WITH ingredient_match AS (
    SELECT ri.ingredient_ref_id
    FROM recipe_ingredient ri
    WHERE ri.id = p_recipe_ingredient_id
  ),
  linked AS (
    SELECT rip.product_id, rip.is_primary
    FROM recipe_ingredient_product rip
    WHERE rip.recipe_ingredient_id = p_recipe_ingredient_id
  ),
  -- Resolve the recipe's country if p_country is NULL
  recipe_country AS (
    SELECT COALESCE(p_country, r.country, 'PL') AS country
    FROM recipe_ingredient ri
    JOIN recipe r ON r.id = ri.recipe_id
    WHERE ri.id = p_recipe_ingredient_id
  ),
  -- Directly linked products
  direct_products AS (
    SELECT
      p.product_id,
      p.product_name,
      p.brand,
      p.ean,
      p.unhealthiness_score,
      pi_img.url AS image_url,
      TRUE AS is_linked,
      l.is_primary
    FROM linked l
    JOIN products p ON p.product_id = l.product_id
    LEFT JOIN product_images pi_img
      ON pi_img.product_id = p.product_id AND pi_img.is_primary = TRUE
    WHERE p.is_deprecated = FALSE
  ),
  -- Auto-suggested products via ingredient_ref
  suggested_products AS (
    SELECT DISTINCT ON (p.product_id)
      p.product_id,
      p.product_name,
      p.brand,
      p.ean,
      p.unhealthiness_score,
      pi_img.url AS image_url,
      FALSE AS is_linked,
      FALSE AS is_primary
    FROM ingredient_match im
    JOIN product_ingredient pring ON pring.ingredient_id = im.ingredient_ref_id
    JOIN products p ON p.product_id = pring.product_id
    CROSS JOIN recipe_country rc
    LEFT JOIN product_images pi_img
      ON pi_img.product_id = p.product_id AND pi_img.is_primary = TRUE
    WHERE im.ingredient_ref_id IS NOT NULL
      AND p.is_deprecated = FALSE
      AND p.country = rc.country
      AND p.product_id NOT IN (SELECT l2.product_id FROM linked l2)
  )
  SELECT * FROM direct_products
  UNION ALL
  SELECT * FROM suggested_products
  ORDER BY
    is_primary DESC,
    is_linked DESC,
    unhealthiness_score ASC NULLS LAST
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION find_products_for_recipe_ingredient IS
'Finds products for a recipe ingredient: admin-curated links first, then auto-suggested via ingredient_ref matching. Sorted by primary → linked → healthiest score.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Update get_recipe_detail() to include linked products per ingredient
-- ═══════════════════════════════════════════════════════════════════════════════
-- Now each ingredient includes a 'linked_products' array with product summaries.

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

  SELECT jsonb_agg(
    jsonb_build_object(
      'id', ri.id,
      'name_key', ri.name_key,
      'optional', ri.optional,
      'ingredient_ref_id', ri.ingredient_ref_id,
      'linked_products', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'product_id', p.product_id,
          'product_name', p.product_name,
          'brand', p.brand,
          'unhealthiness_score', p.unhealthiness_score,
          'image_url', pi_img.url,
          'is_primary', rip.is_primary
        ) ORDER BY rip.is_primary DESC, p.unhealthiness_score ASC NULLS LAST)
        FROM recipe_ingredient_product rip
        JOIN products p ON p.product_id = rip.product_id AND p.is_deprecated = FALSE
        LEFT JOIN product_images pi_img
          ON pi_img.product_id = p.product_id AND pi_img.is_primary = TRUE
        WHERE rip.recipe_ingredient_id = ri.id
      ), '[]'::jsonb)
    ) ORDER BY ri.sort_order
  )
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Seed: Link some recipe ingredients to ingredient_ref entries
-- ═══════════════════════════════════════════════════════════════════════════════
-- Link overnight-oats ingredients to ingredient_ref where a match exists.
-- Uses name_en (taxonomy_id was dropped in cleanup migration).

DO $$
DECLARE
  v_oats_ref BIGINT;
  v_yogurt_ref BIGINT;
  v_milk_ref BIGINT;
  v_honey_ref BIGINT;
  v_oats_ing UUID;
  v_yogurt_ing UUID;
  v_milk_ing UUID;
  v_honey_ref2 UUID;
  v_recipe_id UUID;
BEGIN
  -- Find ingredient_ref IDs by name_en (case-insensitive partial match)
  SELECT ingredient_id INTO v_oats_ref
    FROM ingredient_ref WHERE name_en ILIKE '%oat%' AND name_en NOT ILIKE '%coat%' LIMIT 1;
  SELECT ingredient_id INTO v_yogurt_ref
    FROM ingredient_ref WHERE name_en ILIKE '%yogurt%' OR name_en ILIKE '%yoghurt%' LIMIT 1;
  SELECT ingredient_id INTO v_milk_ref
    FROM ingredient_ref WHERE name_en ILIKE 'milk' OR name_en ILIKE 'whole milk' LIMIT 1;
  SELECT ingredient_id INTO v_honey_ref
    FROM ingredient_ref WHERE name_en ILIKE 'honey' LIMIT 1;

  -- Get the overnight-oats recipe
  SELECT id INTO v_recipe_id FROM recipe WHERE slug = 'overnight-oats';

  IF v_recipe_id IS NOT NULL THEN
    -- Link ingredient_ref to recipe_ingredient rows (by sort_order)
    IF v_oats_ref IS NOT NULL THEN
      UPDATE recipe_ingredient
        SET ingredient_ref_id = v_oats_ref
        WHERE recipe_id = v_recipe_id AND sort_order = 1
          AND ingredient_ref_id IS NULL;
    END IF;

    IF v_yogurt_ref IS NOT NULL THEN
      UPDATE recipe_ingredient
        SET ingredient_ref_id = v_yogurt_ref
        WHERE recipe_id = v_recipe_id AND sort_order = 2
          AND ingredient_ref_id IS NULL;
    END IF;

    IF v_milk_ref IS NOT NULL THEN
      UPDATE recipe_ingredient
        SET ingredient_ref_id = v_milk_ref
        WHERE recipe_id = v_recipe_id AND sort_order = 3
          AND ingredient_ref_id IS NULL;
    END IF;

    IF v_honey_ref IS NOT NULL THEN
      UPDATE recipe_ingredient
        SET ingredient_ref_id = v_honey_ref
        WHERE recipe_id = v_recipe_id AND sort_order = 5
          AND ingredient_ref_id IS NULL;
    END IF;
  END IF;
END $$;

-- ============================================================================
-- Migration: 20260315001400_recipe_api_functions.sql
-- Issue: #364 — Recipe system completion — API functions + QA
-- Description: Creates api_get_recipes(), api_get_recipe_detail(), and
--              api_get_recipe_nutrition() functions following API naming
--              conventions. These wrap/extend the existing browse_recipes()
--              and get_recipe_detail() RPCs with structured JSONB envelopes.
-- Rollback: DROP FUNCTION IF EXISTS api_get_recipe_nutrition;
--           DROP FUNCTION IF EXISTS api_get_recipe_detail;
--           DROP FUNCTION IF EXISTS api_get_recipes;
-- ============================================================================

-- ════════════════════════════════════════════════════════════════════════════
-- 1. api_get_recipes() — Browse published recipes with filters
-- ════════════════════════════════════════════════════════════════════════════
-- Used by: Recipe listing screen
-- Supports filtering by country, category, tag, difficulty, max total time.
-- Returns a JSON object with total_count + recipes array.

CREATE OR REPLACE FUNCTION api_get_recipes(
    p_country    text    DEFAULT NULL,
    p_category   text    DEFAULT NULL,
    p_tag        text    DEFAULT NULL,
    p_difficulty text    DEFAULT NULL,
    p_max_time   integer DEFAULT NULL,
    p_limit      integer DEFAULT 20,
    p_offset     integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
    v_total  integer;
    v_rows   jsonb;
BEGIN
    -- Clamp pagination
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    -- Total matching count
    SELECT COUNT(*)::int INTO v_total
    FROM recipe r
    WHERE r.is_published = TRUE
      AND (p_country IS NULL OR r.country IS NULL OR r.country = p_country)
      AND (p_category IS NULL OR r.category = p_category)
      AND (p_tag IS NULL OR p_tag = ANY(r.tags))
      AND (p_difficulty IS NULL OR r.difficulty = p_difficulty)
      AND (p_max_time IS NULL OR (r.prep_time_min + r.cook_time_min) <= p_max_time);

    -- Build result rows
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'id',              r.id,
            'slug',            r.slug,
            'title_key',       r.title_key,
            'description_key', r.description_key,
            'category',        r.category,
            'difficulty',      r.difficulty,
            'prep_time_min',   r.prep_time_min,
            'cook_time_min',   r.cook_time_min,
            'total_time_min',  r.prep_time_min + r.cook_time_min,
            'servings',        r.servings,
            'image_url',       r.image_url,
            'country',         r.country,
            'tags',            to_jsonb(r.tags),
            'ingredient_count', (SELECT COUNT(*)::int FROM recipe_ingredient ri
                                 WHERE ri.recipe_id = r.id),
            'step_count',       (SELECT COUNT(*)::int FROM recipe_step rs
                                 WHERE rs.recipe_id = r.id)
        ) AS row_data,
        r.created_at
        FROM recipe r
        WHERE r.is_published = TRUE
          AND (p_country IS NULL OR r.country IS NULL OR r.country = p_country)
          AND (p_category IS NULL OR r.category = p_category)
          AND (p_tag IS NULL OR p_tag = ANY(r.tags))
          AND (p_difficulty IS NULL OR r.difficulty = p_difficulty)
          AND (p_max_time IS NULL OR (r.prep_time_min + r.cook_time_min) <= p_max_time)
        ORDER BY r.created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'filters',       jsonb_build_object(
            'country',    p_country,
            'category',   p_category,
            'tag',        p_tag,
            'difficulty', p_difficulty,
            'max_time',   p_max_time
        ),
        'recipes',       v_rows
    );
END;
$$;

COMMENT ON FUNCTION api_get_recipes IS
    'Browse published recipes with optional filters. '
    'Params: p_country, p_category (breakfast|lunch|dinner|snack|dessert|drink|salad|soup), '
    'p_tag, p_difficulty (easy|medium|hard), p_max_time (minutes), p_limit (1-100), p_offset. '
    'Returns JSON with total_count + recipes array. Each recipe includes id, slug, title_key, '
    'description_key, category, difficulty, timing, servings, tags, ingredient_count, step_count.';


-- ════════════════════════════════════════════════════════════════════════════
-- 2. api_get_recipe_detail() — Full recipe with ingredients, steps, products
-- ════════════════════════════════════════════════════════════════════════════
-- Used by: Recipe detail screen
-- Wraps get_recipe_detail() with additional metadata.
-- Accepts slug (not UUID) following URL-friendly convention.

CREATE OR REPLACE FUNCTION api_get_recipe_detail(
    p_slug text
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
    v_recipe   record;
    v_steps    jsonb;
    v_ingredients jsonb;
BEGIN
    -- Find published recipe by slug
    SELECT * INTO v_recipe
    FROM recipe
    WHERE slug = p_slug AND is_published = TRUE;

    IF v_recipe IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'Recipe not found',
            'slug',  p_slug
        );
    END IF;

    -- Build steps array
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'step_number', rs.step_number,
            'content_key', rs.content_key
        ) ORDER BY rs.step_number
    ), '[]'::jsonb)
    INTO v_steps
    FROM recipe_step rs
    WHERE rs.recipe_id = v_recipe.id;

    -- Build ingredients array with linked products
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id',                ri.id,
            'name_key',          ri.name_key,
            'sort_order',        ri.sort_order,
            'optional',          ri.optional,
            'ingredient_ref_id', ri.ingredient_ref_id,
            'linked_products',   COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'product_id',          p.product_id,
                    'product_name',        p.product_name,
                    'brand',               p.brand,
                    'ean',                 p.ean,
                    'unhealthiness_score', p.unhealthiness_score,
                    'is_primary',          rip.is_primary
                ) ORDER BY rip.is_primary DESC, p.unhealthiness_score ASC NULLS LAST)
                FROM recipe_ingredient_product rip
                JOIN products p ON p.product_id = rip.product_id
                    AND p.is_deprecated = FALSE
                WHERE rip.recipe_ingredient_id = ri.id
            ), '[]'::jsonb)
        ) ORDER BY ri.sort_order
    ), '[]'::jsonb)
    INTO v_ingredients
    FROM recipe_ingredient ri
    WHERE ri.recipe_id = v_recipe.id;

    RETURN jsonb_build_object(
        'recipe', jsonb_build_object(
            'id',              v_recipe.id,
            'slug',            v_recipe.slug,
            'title_key',       v_recipe.title_key,
            'description_key', v_recipe.description_key,
            'category',        v_recipe.category,
            'difficulty',      v_recipe.difficulty,
            'prep_time_min',   v_recipe.prep_time_min,
            'cook_time_min',   v_recipe.cook_time_min,
            'total_time_min',  v_recipe.prep_time_min + v_recipe.cook_time_min,
            'servings',        v_recipe.servings,
            'image_url',       v_recipe.image_url,
            'country',         v_recipe.country,
            'tags',            to_jsonb(v_recipe.tags)
        ),
        'ingredients',     v_ingredients,
        'steps',           v_steps,
        'ingredient_count', jsonb_array_length(v_ingredients),
        'step_count',       jsonb_array_length(v_steps)
    );
END;
$$;

COMMENT ON FUNCTION api_get_recipe_detail IS
    'Full recipe detail by slug. Returns recipe metadata, ingredients (with linked products), '
    'and steps. Each ingredient includes linked_products array with product_id, name, brand, '
    'ean, unhealthiness_score, is_primary. Returns {error} if recipe not found or unpublished.';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. api_get_recipe_nutrition() — Aggregate nutrition from linked products
-- ════════════════════════════════════════════════════════════════════════════
-- Used by: Recipe detail screen — nutrition summary section
-- Aggregates nutrition data from linked products (primary products preferred).
-- Returns averaged nutrition per ingredient and totals for the recipe.

CREATE OR REPLACE FUNCTION api_get_recipe_nutrition(
    p_slug text
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
    v_recipe_id     uuid;
    v_linked_count  integer;
    v_total_ingredients integer;
    v_nutrition     jsonb;
BEGIN
    -- Find published recipe by slug
    SELECT id INTO v_recipe_id
    FROM recipe
    WHERE slug = p_slug AND is_published = TRUE;

    IF v_recipe_id IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'Recipe not found',
            'slug',  p_slug
        );
    END IF;

    -- Count total ingredients and those with linked products
    SELECT COUNT(*)::int INTO v_total_ingredients
    FROM recipe_ingredient ri
    WHERE ri.recipe_id = v_recipe_id;

    SELECT COUNT(DISTINCT ri.id)::int INTO v_linked_count
    FROM recipe_ingredient ri
    JOIN recipe_ingredient_product rip ON rip.recipe_ingredient_id = ri.id
    JOIN products p ON p.product_id = rip.product_id AND p.is_deprecated = FALSE
    WHERE ri.recipe_id = v_recipe_id;

    -- Aggregate nutrition from primary linked products (or first linked if no primary)
    -- Uses DISTINCT ON to pick one product per ingredient (primary first, then healthiest)
    SELECT COALESCE(jsonb_build_object(
        'avg_calories',       ROUND(AVG(nf.calories)::numeric, 1),
        'avg_total_fat_g',    ROUND(AVG(nf.total_fat_g)::numeric, 1),
        'avg_saturated_fat_g', ROUND(AVG(nf.saturated_fat_g)::numeric, 1),
        'avg_carbs_g',        ROUND(AVG(nf.carbs_g)::numeric, 1),
        'avg_sugars_g',       ROUND(AVG(nf.sugars_g)::numeric, 1),
        'avg_protein_g',      ROUND(AVG(nf.protein_g)::numeric, 1),
        'avg_salt_g',         ROUND(AVG(nf.salt_g)::numeric, 1),
        'avg_fiber_g',        ROUND(AVG(nf.fiber_g)::numeric, 1),
        'avg_unhealthiness',  ROUND(AVG(p.unhealthiness_score)::numeric, 0),
        'sum_calories',       ROUND(SUM(nf.calories)::numeric, 0),
        'sum_total_fat_g',    ROUND(SUM(nf.total_fat_g)::numeric, 1),
        'sum_protein_g',      ROUND(SUM(nf.protein_g)::numeric, 1),
        'sum_sugars_g',       ROUND(SUM(nf.sugars_g)::numeric, 1),
        'sum_salt_g',         ROUND(SUM(nf.salt_g)::numeric, 1)
    ), '{}'::jsonb)
    INTO v_nutrition
    FROM (
        SELECT DISTINCT ON (ri.id) ri.id, rip.product_id
        FROM recipe_ingredient ri
        JOIN recipe_ingredient_product rip ON rip.recipe_ingredient_id = ri.id
        JOIN products p2 ON p2.product_id = rip.product_id AND p2.is_deprecated = FALSE
        WHERE ri.recipe_id = v_recipe_id
        ORDER BY ri.id, rip.is_primary DESC, p2.unhealthiness_score ASC NULLS LAST
    ) best
    JOIN products p ON p.product_id = best.product_id
    JOIN nutrition_facts nf ON nf.product_id = p.product_id;

    RETURN jsonb_build_object(
        'slug',                 p_slug,
        'total_ingredients',    v_total_ingredients,
        'linked_ingredients',   v_linked_count,
        'coverage_pct',         CASE WHEN v_total_ingredients > 0
                                    THEN ROUND(100.0 * v_linked_count / v_total_ingredients, 0)
                                    ELSE 0 END,
        'nutrition_per_100g',   v_nutrition,
        'note',                 'Nutrition values are per 100g averages from linked products. '
                                'Not a true recipe nutrition calculation (no portion weights).'
    );
END;
$$;

COMMENT ON FUNCTION api_get_recipe_nutrition IS
    'Aggregate nutrition summary for a recipe from linked products. '
    'Picks one product per ingredient (primary first, then healthiest). '
    'Returns per-100g averages and sums, plus coverage percentage. '
    'Note: approximation only — does not account for ingredient portions.';

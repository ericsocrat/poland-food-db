-- ─── Migration: api_get_recipe_score + fix api_get_recipe_nutrition ──────────
-- Issue: #616 — aggregate TryVit Score for recipes from linked product nutrition
-- Rollback: DROP FUNCTION IF EXISTS public.api_get_recipe_score(text);
-- Idempotency: CREATE OR REPLACE — safe to run 1× or 100×
-- ─────────────────────────────────────────────────────────────────────────────


-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Fix api_get_recipe_nutrition — fiber_g → fibre_g column name bug
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_recipe_nutrition(p_slug text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
        'avg_fibre_g',        ROUND(AVG(nf.fibre_g)::numeric, 1),
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
                                || 'Not a true recipe nutrition calculation (no portion weights).'
    );
END;
$function$;

COMMENT ON FUNCTION public.api_get_recipe_nutrition IS
  'Aggregate per-100g nutrition from best-linked products per ingredient.
   Auth: none (published recipes only).
   Params: p_slug (recipe slug).
   Returns: JSONB {slug, total_ingredients, linked_ingredients, coverage_pct, nutrition_per_100g, note}.
   Bug fix: corrected fiber_g → fibre_g column reference (#616).';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. api_get_recipe_score — aggregate TryVit Score from linked product scores
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_recipe_score(p_slug text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_recipe_id         uuid;
    v_total_ingredients integer;
    v_linked_count      integer;
    v_avg_score         integer;
    v_nutrition         jsonb;
    v_coverage_pct      integer;
    v_confidence        text;
BEGIN
    -- Find published recipe by slug
    SELECT id INTO v_recipe_id
    FROM recipe
    WHERE slug = p_slug AND is_published = TRUE;

    IF v_recipe_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version',  'v1',
            'error',        'Recipe not found or not published',
            'recipe_slug',  p_slug
        );
    END IF;

    -- Count total ingredients and linked ingredients
    SELECT COUNT(*)::int INTO v_total_ingredients
    FROM recipe_ingredient
    WHERE recipe_id = v_recipe_id;

    SELECT COUNT(DISTINCT ri.id)::int INTO v_linked_count
    FROM recipe_ingredient ri
    JOIN recipe_ingredient_product rip ON rip.recipe_ingredient_id = ri.id
    JOIN products p ON p.product_id = rip.product_id AND p.is_deprecated = FALSE
    WHERE ri.recipe_id = v_recipe_id;

    -- Calculate coverage
    v_coverage_pct := CASE WHEN v_total_ingredients > 0
        THEN ROUND(100.0 * v_linked_count / v_total_ingredients, 0)::int
        ELSE 0 END;

    -- Determine confidence based on coverage
    v_confidence := CASE
        WHEN v_linked_count >= CEIL(v_total_ingredients * 0.8) THEN 'high'
        WHEN v_linked_count >= CEIL(v_total_ingredients * 0.5) THEN 'medium'
        ELSE 'low'
    END;

    -- Aggregate score + nutrition from best linked products per ingredient.
    -- Uses DISTINCT ON to pick one product per ingredient:
    --   primary first, then healthiest (lowest unhealthiness_score).
    SELECT
        ROUND(AVG(p.unhealthiness_score)::numeric, 0)::int,
        jsonb_build_object(
            'avg_calories',        ROUND(AVG(nf.calories)::numeric, 1),
            'avg_total_fat_g',     ROUND(AVG(nf.total_fat_g)::numeric, 1),
            'avg_saturated_fat_g', ROUND(AVG(nf.saturated_fat_g)::numeric, 1),
            'avg_sugars_g',        ROUND(AVG(nf.sugars_g)::numeric, 1),
            'avg_salt_g',          ROUND(AVG(nf.salt_g)::numeric, 1),
            'avg_protein_g',       ROUND(AVG(nf.protein_g)::numeric, 1),
            'avg_fibre_g',         ROUND(AVG(nf.fibre_g)::numeric, 1)
        )
    INTO v_avg_score, v_nutrition
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
        'api_version',       'v1',
        'recipe_slug',       p_slug,
        'aggregate_score',   COALESCE(v_avg_score, 0),
        'score_band',        CASE
                               WHEN COALESCE(v_avg_score, 0) <= 20 THEN 'green'
                               WHEN COALESCE(v_avg_score, 0) <= 40 THEN 'yellow'
                               WHEN COALESCE(v_avg_score, 0) <= 60 THEN 'orange'
                               WHEN COALESCE(v_avg_score, 0) <= 80 THEN 'red'
                               ELSE 'darkred'
                             END,
        'nutrition_summary', COALESCE(v_nutrition, '{}'::jsonb),
        'coverage_pct',      v_coverage_pct,
        'confidence',        v_confidence,
        'ingredient_count',  v_total_ingredients,
        'linked_count',      v_linked_count,
        'note',              'Score is the average unhealthiness of linked products (per 100g). '
                             || 'Coverage shows what fraction of ingredients have linked products.'
    );
END;
$$;

COMMENT ON FUNCTION public.api_get_recipe_score IS
  'Aggregate TryVit Score for a recipe from linked product scores.
   Auth: none (published recipes only).
   Params: p_slug (recipe slug).
   Returns: JSONB {api_version, recipe_slug, aggregate_score, score_band,
            nutrition_summary, coverage_pct, confidence, ingredient_count, linked_count, note}.
   Fallback: if recipe not found → returns {api_version, error, recipe_slug}.
   Score: weighted average of linked product unhealthiness scores (1–100).
   Confidence: high (≥80% coverage), medium (≥50%), low (<50%).';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Grant execute permissions
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION public.api_get_recipe_score(text) TO anon, authenticated, service_role;

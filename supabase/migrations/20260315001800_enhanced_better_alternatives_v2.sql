-- Migration: Enhanced Better Alternatives v2
-- Purpose:  api_better_alternatives_v2() with cross-category search,
--           health-profile filtering, swap-impact preview, and
--           ingredient-aware filtering (palm oil, concern tier).
-- Closes:   #619
-- Rollback: DROP FUNCTION IF EXISTS api_better_alternatives_v2;
--           DROP FUNCTION IF EXISTS find_better_alternatives_v2;

-- ═══════════════════════════════════════════════════════════════════
-- 1. Category affinity mapping for cross-category relevance penalty
-- ═══════════════════════════════════════════════════════════════════
-- Categories in the same group get a small penalty (0.85 multiplier);
-- categories in different groups get a larger penalty (0.60).
-- Same category = 1.00 (no penalty).  This keeps the ranking meaningful
-- when searching across all categories.

CREATE OR REPLACE FUNCTION public.category_affinity(
    p_cat_a text,
    p_cat_b text
) RETURNS numeric
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
SET search_path = public
AS $$
    SELECT CASE
        -- Same category: no penalty
        WHEN p_cat_a = p_cat_b THEN 1.00

        -- Group: Salty snacks
        WHEN p_cat_a IN ('Chips','Snacks') AND p_cat_b IN ('Chips','Snacks') THEN 0.90

        -- Group: Grains & Bread
        WHEN p_cat_a IN ('Bread','Cereals','Breakfast & Grain-Based')
         AND p_cat_b IN ('Bread','Cereals','Breakfast & Grain-Based') THEN 0.85

        -- Group: Dairy & Plant-Based
        WHEN p_cat_a IN ('Dairy','Plant-Based & Alternatives')
         AND p_cat_b IN ('Dairy','Plant-Based & Alternatives') THEN 0.85

        -- Group: Prepared meals
        WHEN p_cat_a IN ('Frozen & Prepared','Instant & Frozen')
         AND p_cat_b IN ('Frozen & Prepared','Instant & Frozen') THEN 0.90

        -- Group: Meat & Seafood
        WHEN p_cat_a IN ('Meat','Seafood & Fish')
         AND p_cat_b IN ('Meat','Seafood & Fish') THEN 0.85

        -- Group: Sweet things
        WHEN p_cat_a IN ('Sweets','Drinks')
         AND p_cat_b IN ('Sweets','Drinks') THEN 0.80

        -- Group: Condiments & Sauces
        WHEN p_cat_a IN ('Condiments','Sauces')
         AND p_cat_b IN ('Condiments','Sauces') THEN 0.90

        -- Default: distant categories
        ELSE 0.60
    END::numeric;
$$;

COMMENT ON FUNCTION public.category_affinity IS
  'Returns a relevance multiplier (0-1) for cross-category alternative ranking.
   Same-category = 1.0, related groups = 0.80-0.90, distant = 0.60.';

-- ═══════════════════════════════════════════════════════════════════
-- 2. find_better_alternatives_v2() — core engine
-- ═══════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.find_better_alternatives_v2(
    p_product_id          bigint,
    p_same_category       boolean  DEFAULT true,
    p_limit               integer  DEFAULT 5,
    p_diet_preference     text     DEFAULT NULL,
    p_avoid_allergens     text[]   DEFAULT NULL,
    p_strict_diet         boolean  DEFAULT false,
    p_strict_allergen     boolean  DEFAULT false,
    p_treat_may_contain   boolean  DEFAULT false,
    -- New v2 parameters
    p_cross_category      boolean  DEFAULT false,    -- search across categories
    p_health_profile_id   uuid     DEFAULT NULL,     -- filter by health profile thresholds
    p_prefer_no_palm_oil  boolean  DEFAULT false,    -- boost palm-oil-free products
    p_max_concern_tier    integer  DEFAULT NULL       -- max concern tier to allow (0-3)
)
RETURNS TABLE (
    alt_product_id        bigint,
    product_name          text,
    brand                 text,
    category              text,
    unhealthiness_score   integer,
    score_improvement     integer,
    shared_ingredients    integer,
    jaccard_similarity    numeric,
    nutri_score_label     text,
    -- New v2 columns
    is_cross_category     boolean,
    relevance_score       numeric,
    sat_fat_saved_g       numeric,
    sugar_saved_g         numeric,
    salt_saved_g          numeric,
    calories_saved        numeric,
    swap_headline         text,
    palm_oil_free         boolean,
    max_ingredient_concern integer
)
LANGUAGE plpgsql STABLE
SET search_path = public
AS $$
DECLARE
    v_target_score      integer;
    v_target_cat        text;
    v_target_country    text;
    v_target_sat_fat    numeric;
    v_target_sugars     numeric;
    v_target_salt       numeric;
    v_target_calories   numeric;
    v_target_palm_oil   boolean;
    -- Health profile thresholds
    v_hp_max_sugar      numeric;
    v_hp_max_salt       numeric;
    v_hp_max_sat_fat    numeric;
    v_hp_max_calories   numeric;
    v_effective_limit   integer;
    v_search_cross      boolean;
BEGIN
    v_effective_limit := LEAST(GREATEST(COALESCE(p_limit, 5), 1), 20);

    -- Determine search scope: p_cross_category overrides p_same_category
    v_search_cross := p_cross_category OR (NOT p_same_category);

    -- Resolve target product metadata
    SELECT p.unhealthiness_score, p.category, p.country,
           nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories
    INTO   v_target_score, v_target_cat, v_target_country,
           v_target_sat_fat, v_target_sugars, v_target_salt, v_target_calories
    FROM   products p
    LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
    WHERE  p.product_id = p_product_id;

    IF v_target_score IS NULL THEN
        RETURN;  -- product not found
    END IF;

    -- Check if source product has palm oil
    SELECT COALESCE(m.has_palm_oil, false)
    INTO   v_target_palm_oil
    FROM   v_master m
    WHERE  m.product_id = p_product_id;

    -- Load health profile thresholds if provided
    IF p_health_profile_id IS NOT NULL THEN
        SELECT hp.max_sugar_g, hp.max_salt_g, hp.max_saturated_fat_g, hp.max_calories_kcal
        INTO   v_hp_max_sugar, v_hp_max_salt, v_hp_max_sat_fat, v_hp_max_calories
        FROM   user_health_profiles hp
        WHERE  hp.profile_id = p_health_profile_id;
    END IF;

    RETURN QUERY
    WITH target_ingredients AS (
        SELECT pi.ingredient_id
        FROM   product_ingredient pi
        WHERE  pi.product_id = p_product_id
    ),
    target_count AS (
        SELECT COUNT(*)::integer AS cnt FROM target_ingredients
    ),
    candidates AS (
        SELECT
            p2.product_id                                    AS cand_id,
            p2.product_name                                  AS cand_name,
            p2.brand                                         AS cand_brand,
            p2.category                                      AS cand_category,
            p2.unhealthiness_score                           AS cand_score,
            p2.nutri_score_label                             AS cand_nutri,
            nf2.saturated_fat_g                              AS cand_sat_fat,
            nf2.sugars_g                                     AS cand_sugars,
            nf2.salt_g                                       AS cand_salt,
            nf2.calories                                     AS cand_calories,
            COALESCE(m2.has_palm_oil, false)                 AS cand_palm_oil,
            COALESCE(m2.ingredient_concern_score, 0)         AS cand_concern_score,
            -- Jaccard similarity
            COALESCE((
                SELECT COUNT(*)::integer
                FROM   product_ingredient pi2
                WHERE  pi2.product_id = p2.product_id
                  AND  pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
            ), 0)                                            AS shared_count,
            COALESCE((
                SELECT COUNT(*)::integer
                FROM   product_ingredient pi2
                WHERE  pi2.product_id = p2.product_id
            ), 0)                                            AS cand_ingr_count,
            -- Max concern tier of candidate ingredients
            COALESCE((
                SELECT MAX(ir.concern_tier)
                FROM   product_ingredient pi3
                JOIN   ingredient_ref ir ON ir.ingredient_id = pi3.ingredient_id
                WHERE  pi3.product_id = p2.product_id
            ), 0)                                            AS cand_max_concern
        FROM   products p2
        LEFT JOIN nutrition_facts nf2 ON nf2.product_id = p2.product_id
        LEFT JOIN v_master m2 ON m2.product_id = p2.product_id
        WHERE  p2.product_id != p_product_id
          AND  p2.is_deprecated IS NOT TRUE
          AND  p2.country = v_target_country
          AND  p2.unhealthiness_score < v_target_score  -- must be healthier
          -- Category filter
          AND  (v_search_cross OR p2.category = v_target_cat)
          -- Diet + allergen filtering (reuse existing helper)
          AND  check_product_preferences(
                   p2.product_id, p_diet_preference, p_avoid_allergens,
                   p_strict_diet, p_strict_allergen, p_treat_may_contain
               )
    )
    SELECT
        c.cand_id,
        c.cand_name,
        c.cand_brand,
        c.cand_category,
        c.cand_score::integer,
        (v_target_score - c.cand_score)::integer          AS score_improvement,
        c.shared_count,
        CASE WHEN tc.cnt + c.cand_ingr_count - c.shared_count > 0
             THEN ROUND(c.shared_count::numeric
                        / (tc.cnt + c.cand_ingr_count - c.shared_count), 3)
             ELSE 0
        END                                               AS jaccard_sim,
        c.cand_nutri,
        -- v2 columns
        (c.cand_category != v_target_cat)                 AS is_cross,
        -- Relevance score: combines score improvement with category affinity
        ROUND(
            (v_target_score - c.cand_score)::numeric
            * category_affinity(v_target_cat, c.cand_category)
            -- Bonus for palm-oil-free alternatives when source has palm oil
            * CASE WHEN p_prefer_no_palm_oil AND v_target_palm_oil AND NOT c.cand_palm_oil
                   THEN 1.15 ELSE 1.0 END
        , 2)                                              AS relevance,
        -- Nutrient savings (positive = you save by switching)
        ROUND(COALESCE(v_target_sat_fat, 0) - COALESCE(c.cand_sat_fat, 0), 1) AS sat_fat_delta,
        ROUND(COALESCE(v_target_sugars,  0) - COALESCE(c.cand_sugars,  0), 1) AS sugar_delta,
        ROUND(COALESCE(v_target_salt,    0) - COALESCE(c.cand_salt,    0), 1) AS salt_delta,
        ROUND(COALESCE(v_target_calories,0) - COALESCE(c.cand_calories,0), 0) AS calories_delta,
        -- Headline: e.g. "Save 12 points — 60% less sugar"
        (v_target_score - c.cand_score)::text || ' points healthier'
            || CASE
                 WHEN COALESCE(v_target_sugars,0) > 0
                  AND (COALESCE(v_target_sugars,0) - COALESCE(c.cand_sugars,0))
                      / NULLIF(v_target_sugars,0) > 0.3
                 THEN ' — ' || ROUND(
                          (COALESCE(v_target_sugars,0) - COALESCE(c.cand_sugars,0))
                          / NULLIF(v_target_sugars,0) * 100
                      )::text || '% less sugar'
                 WHEN COALESCE(v_target_sat_fat,0) > 0
                  AND (COALESCE(v_target_sat_fat,0) - COALESCE(c.cand_sat_fat,0))
                      / NULLIF(v_target_sat_fat,0) > 0.3
                 THEN ' — ' || ROUND(
                          (COALESCE(v_target_sat_fat,0) - COALESCE(c.cand_sat_fat,0))
                          / NULLIF(v_target_sat_fat,0) * 100
                      )::text || '% less saturated fat'
                 WHEN COALESCE(v_target_salt,0) > 0
                  AND (COALESCE(v_target_salt,0) - COALESCE(c.cand_salt,0))
                      / NULLIF(v_target_salt,0) > 0.3
                 THEN ' — ' || ROUND(
                          (COALESCE(v_target_salt,0) - COALESCE(c.cand_salt,0))
                          / NULLIF(v_target_salt,0) * 100
                      )::text || '% less salt'
                 ELSE ''
               END                                        AS headline,
        NOT c.cand_palm_oil                               AS palm_free,
        c.cand_max_concern
    FROM candidates c
    CROSS JOIN target_count tc
    WHERE
        -- Health profile filtering: exclude products exceeding thresholds
        (v_hp_max_sugar    IS NULL OR COALESCE(c.cand_sugars,  0) <= v_hp_max_sugar)
    AND (v_hp_max_salt     IS NULL OR COALESCE(c.cand_salt,    0) <= v_hp_max_salt)
    AND (v_hp_max_sat_fat  IS NULL OR COALESCE(c.cand_sat_fat, 0) <= v_hp_max_sat_fat)
    AND (v_hp_max_calories IS NULL OR COALESCE(c.cand_calories,0) <= v_hp_max_calories)
        -- Concern tier filtering
    AND (p_max_concern_tier IS NULL OR c.cand_max_concern <= p_max_concern_tier)
    ORDER BY relevance DESC, jaccard_sim DESC
    LIMIT v_effective_limit;
END;
$$;

COMMENT ON FUNCTION public.find_better_alternatives_v2 IS
  'Enhanced alternative finder with cross-category search (relevance-weighted),
   health profile nutrient filtering, swap savings preview, and ingredient
   concern-tier filtering. Backward compatible with v1 defaults.
   Auth: none required (public data). Closes #619.';

-- ═══════════════════════════════════════════════════════════════════
-- 3. api_better_alternatives_v2() — JSONB API wrapper
-- ═══════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.api_better_alternatives_v2(
    p_product_id          bigint,
    p_same_category       boolean  DEFAULT true,
    p_limit               integer  DEFAULT 5,
    p_diet_preference     text     DEFAULT NULL,
    p_avoid_allergens     text[]   DEFAULT NULL,
    p_strict_diet         boolean  DEFAULT false,
    p_strict_allergen     boolean  DEFAULT false,
    p_treat_may_contain   boolean  DEFAULT false,
    -- New v2 parameters
    p_cross_category      boolean  DEFAULT false,
    p_health_profile_id   uuid     DEFAULT NULL,
    p_prefer_no_palm_oil  boolean  DEFAULT false,
    p_max_concern_tier    integer  DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_rate_check  jsonb;
    v_result      jsonb;
    v_limit       integer;
BEGIN
    -- Rate limit enforcement
    v_rate_check := check_api_rate_limit(auth.uid(), 'api_better_alternatives');
    IF NOT (v_rate_check->>'allowed')::boolean THEN
        RETURN jsonb_build_object(
            'api_version',         '2.0',
            'error',               'rate_limit_exceeded',
            'message',             'Too many requests. Please try again later.',
            'retry_after_seconds', (v_rate_check->>'retry_after_seconds')::integer,
            'current_count',       (v_rate_check->>'current_count')::integer,
            'max_allowed',         (v_rate_check->>'max_allowed')::integer
        );
    END IF;

    v_limit := LEAST(GREATEST(COALESCE(p_limit, 5), 1), 20);

    SELECT jsonb_build_object(
        'api_version',     '2.0',
        'source_product', jsonb_build_object(
            'product_id',          m.product_id,
            'product_name',        m.product_name,
            'brand',               m.brand,
            'category',            m.category,
            'unhealthiness_score', m.unhealthiness_score,
            'nutri_score',         m.nutri_score_label,
            'has_palm_oil',        COALESCE(m.has_palm_oil, false),
            'saturated_fat_g',     m.saturated_fat_g,
            'sugars_g',            m.sugars_g,
            'salt_g',              m.salt_g,
            'calories',            m.calories
        ),
        'search_scope', CASE
            WHEN p_cross_category THEN 'cross_category'
            WHEN NOT p_same_category THEN 'all_categories'
            ELSE 'same_category'
        END,
        'filters_applied', jsonb_build_object(
            'health_profile',    p_health_profile_id IS NOT NULL,
            'prefer_no_palm_oil', p_prefer_no_palm_oil,
            'max_concern_tier',  p_max_concern_tier,
            'diet_preference',   p_diet_preference,
            'allergen_filter',   p_avoid_allergens IS NOT NULL
        ),
        'alternatives', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',          alt.alt_product_id,
                'product_name',        alt.product_name,
                'brand',               alt.brand,
                'category',            alt.category,
                'unhealthiness_score', alt.unhealthiness_score,
                'score_improvement',   alt.score_improvement,
                'nutri_score',         alt.nutri_score_label,
                'similarity',          alt.jaccard_similarity,
                'shared_ingredients',  alt.shared_ingredients,
                'is_cross_category',   alt.is_cross_category,
                'palm_oil_free',       alt.palm_oil_free,
                'swap_savings', jsonb_build_object(
                    'score_delta',      -alt.score_improvement,
                    'sat_fat_saved_g',  alt.sat_fat_saved_g,
                    'sugar_saved_g',    alt.sugar_saved_g,
                    'salt_saved_g',     alt.salt_saved_g,
                    'calories_saved',   alt.calories_saved,
                    'headline',         alt.swap_headline
                )
            ))
            FROM find_better_alternatives_v2(
                p_product_id, p_same_category, v_limit,
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain,
                p_cross_category, p_health_profile_id,
                p_prefer_no_palm_oil, p_max_concern_tier
            ) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives_v2(
                p_product_id, p_same_category, v_limit,
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain,
                p_cross_category, p_health_profile_id,
                p_prefer_no_palm_oil, p_max_concern_tier
            )
        ), 0)
    )
    INTO v_result
    FROM v_master m
    WHERE m.product_id = p_product_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.api_better_alternatives_v2 IS
  'Enhanced Better Alternatives API v2. Adds cross-category search with
   relevance weighting, health profile nutrient filtering, per-alternative
   swap savings preview, and ingredient concern-tier filtering.
   Auth: rate-limited. SECURITY DEFINER. Closes #619.
   Params:
     p_product_id (required), p_same_category (default true),
     p_limit (1-20, default 5), p_diet_preference (vegan/vegetarian),
     p_avoid_allergens (text[]), p_strict_diet/p_strict_allergen (bool),
     p_treat_may_contain (bool),
     p_cross_category (NEW: default false — search all categories),
     p_health_profile_id (NEW: filter by user health profile thresholds),
     p_prefer_no_palm_oil (NEW: boost palm-oil-free alternatives),
     p_max_concern_tier (NEW: exclude products with high concern additives).
   Returns: JSONB {api_version, source_product, search_scope, filters_applied,
            alternatives[{..., swap_savings, is_cross_category, palm_oil_free}],
            alternatives_count}';

-- ═══════════════════════════════════════════════════════════════════
-- 4. Grant anon+authenticated access
-- ═══════════════════════════════════════════════════════════════════
GRANT EXECUTE ON FUNCTION public.category_affinity(text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.find_better_alternatives_v2 TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.api_better_alternatives_v2  TO anon, authenticated;

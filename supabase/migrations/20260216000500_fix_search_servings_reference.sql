-- Fix: api_search_products references dropped "servings" table.
-- The servings table was removed in 20260212000100_consolidate_schema.
-- nutrition_facts now joins directly to products by product_id (PK).
-- ──────────────────────────────────────────────────────────────────────────

DROP FUNCTION IF EXISTS public.api_search_products(
    text, jsonb, integer, integer, boolean
);

CREATE OR REPLACE FUNCTION public.api_search_products(
    p_query        text     DEFAULT NULL,
    p_filters      jsonb    DEFAULT '{}'::jsonb,
    p_page         integer  DEFAULT 1,
    p_page_size    integer  DEFAULT 20,
    p_show_avoided boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_query           text;
    v_country         text;
    v_categories      text[];
    v_nutri_scores    text[];
    v_allergen_free   text[];
    v_max_score       numeric;
    v_sort_by         text;
    v_sort_order      text;
    v_offset          integer;
    v_total           integer;
    v_pages           integer;
    v_rows            jsonb;
    v_avoid_ids       bigint[];
    v_user_id         uuid;
    v_diet_pref       text;
    v_user_allergens  text[];
    v_strict_diet     boolean;
    v_strict_allergen boolean;
    v_treat_mc        boolean;
    v_tsq             tsquery;
BEGIN
    -- ── Sanitize inputs ─────────────────────────────────────────────────────
    v_query := NULLIF(TRIM(COALESCE(p_query, '')), '');
    p_page_size := LEAST(GREATEST(p_page_size, 1), 100);
    p_page      := GREATEST(p_page, 1);
    v_offset    := (p_page - 1) * p_page_size;

    -- ── Extract filters from jsonb ──────────────────────────────────────────
    v_categories    := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'category', '[]'::jsonb)));
    v_nutri_scores  := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'nutri_score', '[]'::jsonb)));
    v_allergen_free := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'allergen_free', '[]'::jsonb)));
    v_max_score     := (p_filters->>'max_unhealthiness')::numeric;
    v_sort_by       := COALESCE(p_filters->>'sort_by', 'relevance');
    v_sort_order    := LOWER(COALESCE(p_filters->>'sort_order', 'asc'));

    -- Default sort_order for relevance should be DESC (best first)
    IF v_sort_by = 'relevance' AND (p_filters->>'sort_order') IS NULL THEN
        v_sort_order := 'desc';
    END IF;

    -- ── Resolve country ─────────────────────────────────────────────────────
    v_country := resolve_effective_country(p_filters->>'country');

    -- ── Build tsquery from words (prefix matching) ──────────────────────────
    IF v_query IS NOT NULL AND LENGTH(v_query) >= 1 THEN
        SELECT to_tsquery('simple',
            string_agg(lexeme || ':*', ' & '))
        INTO v_tsq
        FROM unnest(string_to_array(v_query, ' ')) AS lexeme
        WHERE lexeme <> '';
    END IF;

    -- ── Load user preferences + avoid list ──────────────────────────────────
    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        SELECT up.diet_preference, up.avoid_allergens,
               up.strict_diet, up.strict_allergen, up.treat_may_contain_as_unsafe
        INTO   v_diet_pref, v_user_allergens,
               v_strict_diet, v_strict_allergen, v_treat_mc
        FROM   user_preferences up
        WHERE  up.user_id = v_user_id;

        -- Avoid list IDs for demotion
        SELECT ARRAY_AGG(li.product_id)
        INTO   v_avoid_ids
        FROM   user_product_list_items li
        JOIN   user_product_lists l ON l.id = li.list_id
        WHERE  l.user_id = v_user_id AND l.list_type = 'avoid';
    END IF;
    v_avoid_ids := COALESCE(v_avoid_ids, ARRAY[]::bigint[]);

    -- ── Main query ──────────────────────────────────────────────────────────
    -- NOTE: servings table was dropped in 20260212000100_consolidate_schema.
    -- nutrition_facts now has product_id as PK — join directly.
    WITH search_results AS (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            cr.display_name                                 AS category_display,
            COALESCE(cr.icon_emoji, '📦')                   AS category_icon,
            p.unhealthiness_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END                                             AS score_band,
            p.nutri_score_label                             AS nutri_score,
            p.nova_classification                           AS nova_group,
            nf.calories::numeric                            AS calories,
            COALESCE(p.high_salt_flag = 'YES', false)       AS high_salt,
            COALESCE(p.high_sugar_flag = 'YES', false)      AS high_sugar,
            COALESCE(p.high_sat_fat_flag = 'YES', false)    AS high_sat_fat,
            COALESCE(p.high_additive_load = 'YES', false)   AS high_additive_load,
            (p.product_id = ANY(v_avoid_ids))               AS is_avoided,
            -- Relevance score
            CASE
                WHEN v_query IS NOT NULL THEN
                    COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq)
                             ELSE 0 END, 0)
                    + GREATEST(
                        similarity(p.product_name, v_query),
                        similarity(p.brand, v_query) * 0.8
                    )
                ELSE 0
            END                                             AS relevance,
            COUNT(*) OVER()                                 AS total_count
        FROM products p
        LEFT JOIN category_ref cr
            ON cr.category = p.category
        LEFT JOIN nutrition_facts nf
            ON nf.product_id = p.product_id
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          -- Text search (empty = browse mode)
          AND (
              v_query IS NULL
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR p.product_name ILIKE '%' || v_query || '%'
              OR p.brand        ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
          -- Category multi-filter
          AND (array_length(v_categories, 1) IS NULL
               OR p.category = ANY(v_categories))
          -- Nutri-Score filter
          AND (array_length(v_nutri_scores, 1) IS NULL
               OR p.nutri_score_label = ANY(v_nutri_scores))
          -- Max unhealthiness
          AND (v_max_score IS NULL
               OR p.unhealthiness_score <= v_max_score)
          -- Allergen-free filter (search-specific)
          AND (array_length(v_allergen_free, 1) IS NULL
               OR NOT EXISTS (
                   SELECT 1 FROM product_allergen_info ai
                   WHERE ai.product_id = p.product_id
                     AND ai.type = 'contains'
                     AND ai.tag = ANY(v_allergen_free)
               ))
          -- User diet/allergen preferences (auto-applied for authenticated users)
          AND (v_user_id IS NULL
               OR check_product_preferences(
                   p.product_id, v_diet_pref, v_user_allergens,
                   v_strict_diet, v_strict_allergen, v_treat_mc
               ))
        ORDER BY
            -- Avoid demotion: avoided products pushed to bottom
            CASE WHEN NOT p_show_avoided AND p.product_id = ANY(v_avoid_ids) THEN 1 ELSE 0 END ASC,
            -- Name sort (ASC)
            CASE WHEN v_sort_by = 'name' AND v_sort_order <> 'desc'
                 THEN p.product_name END ASC NULLS LAST,
            -- Name sort (DESC)
            CASE WHEN v_sort_by = 'name' AND v_sort_order = 'desc'
                 THEN p.product_name END DESC NULLS LAST,
            -- Numeric sort column
            CASE
                WHEN v_sort_by = 'relevance' THEN
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query IS NOT NULL
                             THEN GREATEST(similarity(p.product_name, v_query),
                                           similarity(p.brand, v_query) * 0.8)
                             ELSE 0 END)
                WHEN v_sort_by = 'unhealthiness' AND v_sort_order = 'desc' THEN
                    -COALESCE(p.unhealthiness_score, 999)
                WHEN v_sort_by = 'unhealthiness' THEN
                    COALESCE(p.unhealthiness_score, 999)
                WHEN v_sort_by = 'nutri_score' AND v_sort_order = 'desc' THEN
                    -(CASE p.nutri_score_label
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3
                        WHEN 'D' THEN 4 WHEN 'E' THEN 5 ELSE 6 END)
                WHEN v_sort_by = 'nutri_score' THEN
                    (CASE p.nutri_score_label
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3
                        WHEN 'D' THEN 4 WHEN 'E' THEN 5 ELSE 6 END)
                WHEN v_sort_by = 'calories' AND v_sort_order = 'desc' THEN
                    -COALESCE(nf.calories::numeric, 9999)
                WHEN v_sort_by = 'calories' THEN
                    COALESCE(nf.calories::numeric, 9999)
                -- Default: relevance DESC
                ELSE
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query IS NOT NULL
                             THEN GREATEST(similarity(p.product_name, v_query),
                                           similarity(p.brand, v_query) * 0.8)
                             ELSE 0 END)
            END ASC NULLS LAST,
            -- Tiebreaker
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_page_size OFFSET v_offset
    )
    SELECT COALESCE(MAX(sr.total_count)::int, 0),
           COALESCE(jsonb_agg(jsonb_build_object(
               'product_id',          sr.product_id,
               'product_name',        sr.product_name,
               'brand',               sr.brand,
               'category',            sr.category,
               'category_display',    sr.category_display,
               'category_icon',       sr.category_icon,
               'unhealthiness_score', sr.unhealthiness_score,
               'score_band',          sr.score_band,
               'nutri_score',         sr.nutri_score,
               'nova_group',          sr.nova_group,
               'calories',            sr.calories,
               'high_salt',           sr.high_salt,
               'high_sugar',          sr.high_sugar,
               'high_sat_fat',        sr.high_sat_fat,
               'high_additive_load',  sr.high_additive_load,
               'is_avoided',          sr.is_avoided,
               'relevance',           ROUND(sr.relevance::numeric, 4)
           )), '[]'::jsonb)
    INTO v_total, v_rows
    FROM search_results sr;

    v_pages := GREATEST(CEIL(v_total::numeric / p_page_size)::int, 1);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'query',       v_query,
        'country',     v_country,
        'total',       v_total,
        'page',        p_page,
        'pages',       v_pages,
        'page_size',   p_page_size,
        'filters_applied', p_filters,
        'results',     v_rows
    );
END;
$function$;

-- Grant to authenticated + anon (search is public)
GRANT EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean)
    TO authenticated, anon;

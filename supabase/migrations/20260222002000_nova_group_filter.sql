-- ============================================================
-- Migration: Add NOVA Group filter to search + filter options
-- Supports Issue #129 — NOVA Group Filter on Search Panel
-- ============================================================

-- ─── 1. Update api_search_products — add nova_group filter ───────────────────

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
    v_query_clean     text;
    v_country         text;
    v_language        text;
    v_country_lang    text;
    v_categories      text[];
    v_nutri_scores    text[];
    v_nova_groups     text[];
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
    v_synonym_terms   text[] := ARRAY[]::text[];
    v_synonym_tsq     tsquery;
BEGIN
    v_query := NULLIF(TRIM(COALESCE(p_query, '')), '');
    p_page_size := LEAST(GREATEST(p_page_size, 1), 100);
    p_page      := GREATEST(p_page, 1);
    v_offset    := (p_page - 1) * p_page_size;

    v_query_clean := CASE WHEN v_query IS NOT NULL
                          THEN unaccent(v_query)
                          ELSE NULL END;

    v_categories    := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'category', '[]'::jsonb)));
    v_nutri_scores  := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'nutri_score', '[]'::jsonb)));
    v_nova_groups   := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'nova_group', '[]'::jsonb)));
    v_allergen_free := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'allergen_free', '[]'::jsonb)));
    v_max_score     := (p_filters->>'max_unhealthiness')::numeric;
    v_sort_by       := COALESCE(p_filters->>'sort_by', 'relevance');
    v_sort_order    := LOWER(COALESCE(p_filters->>'sort_order', 'asc'));

    IF v_sort_by = 'relevance' AND (p_filters->>'sort_order') IS NULL THEN
        v_sort_order := 'desc';
    END IF;

    v_country  := resolve_effective_country(p_filters->>'country');
    v_language := resolve_language(NULL);

    SELECT cref.default_language INTO v_country_lang
    FROM country_ref cref WHERE cref.country_code = v_country;
    v_country_lang := COALESCE(v_country_lang, LOWER(v_country));

    IF v_query_clean IS NOT NULL AND LENGTH(v_query_clean) >= 1 THEN
        SELECT to_tsquery('simple',
            string_agg(lexeme || ':*', ' & '))
        INTO v_tsq
        FROM unnest(string_to_array(v_query_clean, ' ')) AS lexeme
        WHERE lexeme <> '';
    END IF;

    IF v_query_clean IS NOT NULL THEN
        v_synonym_terms := expand_search_query(v_query_clean);

        IF array_length(v_synonym_terms, 1) > 0 THEN
            SELECT to_tsquery('simple',
                string_agg(
                    (SELECT string_agg(w || ':*', ' & ')
                     FROM unnest(string_to_array(unaccent(syn), ' ')) AS w
                     WHERE w <> ''),
                    ' | '
                )
            )
            INTO v_synonym_tsq
            FROM unnest(v_synonym_terms) AS syn
            WHERE syn IS NOT NULL AND syn <> '';
        END IF;
    END IF;

    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        SELECT up.diet_preference, up.avoid_allergens,
               up.strict_diet, up.strict_allergen, up.treat_may_contain_as_unsafe
        INTO   v_diet_pref, v_user_allergens,
               v_strict_diet, v_strict_allergen, v_treat_mc
        FROM   user_preferences up
        WHERE  up.user_id = v_user_id;

        SELECT ARRAY_AGG(li.product_id)
        INTO   v_avoid_ids
        FROM   user_product_list_items li
        JOIN   user_product_lists l ON l.id = li.list_id
        WHERE  l.user_id = v_user_id AND l.list_type = 'avoid';
    END IF;
    v_avoid_ids := COALESCE(v_avoid_ids, ARRAY[]::bigint[]);

    WITH search_results AS (
        SELECT
            p.product_id,
            p.product_name,
            p.product_name_en,
            CASE
                WHEN v_language = COALESCE(cref.default_language, LOWER(p.country))
                    THEN p.product_name
                WHEN v_language = 'en'
                    THEN COALESCE(p.product_name_en, p.product_name)
                ELSE COALESCE(
                    p.name_translations->>v_language,
                    p.product_name_en,
                    p.product_name
                )
            END                                          AS product_name_display,
            p.brand,
            p.category,
            COALESCE(ct.display_name, cr.display_name)  AS category_display,
            COALESCE(cr.icon_emoji, '📦')                AS category_icon,
            p.unhealthiness_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END                                          AS score_band,
            p.nutri_score_label                          AS nutri_score,
            p.nova_classification                        AS nova_group,
            nf.calories::numeric                         AS calories,
            COALESCE(p.high_salt_flag = 'YES', false)    AS high_salt,
            COALESCE(p.high_sugar_flag = 'YES', false)   AS high_sugar,
            COALESCE(p.high_sat_fat_flag = 'YES', false) AS high_sat_fat,
            COALESCE(p.high_additive_load = 'YES', false) AS high_additive_load,
            (p.product_id = ANY(v_avoid_ids))            AS is_avoided,
            -- Primary product image thumbnail
            (SELECT img.url FROM product_images img
             WHERE img.product_id = p.product_id AND img.is_primary = true
             LIMIT 1)                                    AS image_thumb_url,
            CASE
                WHEN v_query_clean IS NOT NULL THEN
                    COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq)
                             ELSE 0 END, 0)
                    + GREATEST(
                        similarity(unaccent(p.product_name), v_query_clean),
                        similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                        similarity(unaccent(p.brand), v_query_clean) * 0.8
                    )
                    + COALESCE(
                        CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                             THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                             ELSE 0 END, 0)
                ELSE 0
            END                                          AS relevance,
            COUNT(*) OVER()                              AS total_count
        FROM products p
        LEFT JOIN category_ref cr
            ON cr.category = p.category
        LEFT JOIN category_translations ct
            ON ct.category = p.category AND ct.language_code = v_language
        LEFT JOIN nutrition_facts nf
            ON nf.product_id = p.product_id
        LEFT JOIN country_ref cref
            ON cref.country_code = p.country
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND (
              v_query_clean IS NULL
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR unaccent(p.product_name) ILIKE '%' || v_query_clean || '%'
              OR unaccent(p.brand)        ILIKE '%' || v_query_clean || '%'
              OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || v_query_clean || '%'
              OR similarity(unaccent(p.product_name), v_query_clean) > 0.15
              OR similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean) > 0.15
              OR (v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq)
              OR EXISTS (
                  SELECT 1 FROM unnest(v_synonym_terms) AS syn
                  WHERE unaccent(p.product_name) ILIKE '%' || unaccent(syn) || '%'
                     OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || unaccent(syn) || '%'
              )
          )
          AND (array_length(v_categories, 1) IS NULL
               OR p.category = ANY(v_categories))
          AND (array_length(v_nutri_scores, 1) IS NULL
               OR p.nutri_score_label = ANY(v_nutri_scores))
          AND (array_length(v_nova_groups, 1) IS NULL
               OR p.nova_classification = ANY(v_nova_groups))
          AND (v_max_score IS NULL
               OR p.unhealthiness_score <= v_max_score)
          AND (array_length(v_allergen_free, 1) IS NULL
               OR NOT EXISTS (
                   SELECT 1 FROM product_allergen_info ai
                   WHERE ai.product_id = p.product_id
                     AND ai.type = 'contains'
                     AND ai.tag = ANY(v_allergen_free)
               ))
          AND (v_user_id IS NULL
               OR check_product_preferences(
                   p.product_id, v_diet_pref, v_user_allergens,
                   v_strict_diet, v_strict_allergen, v_treat_mc
               ))
        ORDER BY
            CASE WHEN NOT p_show_avoided AND p.product_id = ANY(v_avoid_ids) THEN 1 ELSE 0 END ASC,
            CASE WHEN v_sort_by = 'name' AND v_sort_order <> 'desc'
                 THEN p.product_name END ASC NULLS LAST,
            CASE WHEN v_sort_by = 'name' AND v_sort_order = 'desc'
                 THEN p.product_name END DESC NULLS LAST,
            CASE
                WHEN v_sort_by = 'relevance' THEN
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query_clean IS NOT NULL
                             THEN GREATEST(
                                 similarity(unaccent(p.product_name), v_query_clean),
                                 similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                 similarity(unaccent(p.brand), v_query_clean) * 0.8)
                             ELSE 0 END
                      + COALESCE(
                            CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                 THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                 ELSE 0 END, 0))
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
                ELSE
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query_clean IS NOT NULL
                             THEN GREATEST(
                                 similarity(unaccent(p.product_name), v_query_clean),
                                 similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                 similarity(unaccent(p.brand), v_query_clean) * 0.8)
                             ELSE 0 END
                      + COALESCE(
                            CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                 THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                 ELSE 0 END, 0))
            END ASC NULLS LAST,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_page_size OFFSET v_offset
    )
    SELECT COALESCE(MAX(sr.total_count)::int, 0),
           COALESCE(jsonb_agg(jsonb_build_object(
               'product_id',          sr.product_id,
               'product_name',        sr.product_name,
               'product_name_en',     sr.product_name_en,
               'product_name_display', sr.product_name_display,
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
               'relevance',           ROUND(sr.relevance::numeric, 4),
               'image_thumb_url',     sr.image_thumb_url
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

REVOKE EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean) TO authenticated, service_role;


-- ─── 2. Update api_get_filter_options — add nova_groups counts ───────────────

CREATE OR REPLACE FUNCTION public.api_get_filter_options(
    p_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_country    text;
    v_categories jsonb;
    v_nutri      jsonb;
    v_nova       jsonb;
    v_allergens  jsonb;
BEGIN
    v_country := resolve_effective_country(p_country);

    -- Category counts
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'category',     cr.category,
        'display_name', cr.display_name,
        'icon_emoji',   cr.icon_emoji,
        'count',        COALESCE(c.cnt, 0)
    ) ORDER BY cr.sort_order), '[]'::jsonb)
    INTO v_categories
    FROM category_ref cr
    LEFT JOIN (
        SELECT p.category, COUNT(*) AS cnt
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE AND p.country = v_country
        GROUP BY p.category
    ) c ON c.category = cr.category
    WHERE cr.is_active AND COALESCE(c.cnt, 0) > 0;

    -- Nutri-Score label counts
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'label', n.label,
        'count', n.cnt
    ) ORDER BY n.label), '[]'::jsonb)
    INTO v_nutri
    FROM (
        SELECT p.nutri_score_label AS label, COUNT(*) AS cnt
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND p.nutri_score_label IS NOT NULL
        GROUP BY p.nutri_score_label
    ) n;

    -- NOVA group counts
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'group', g.grp,
        'count', g.cnt
    ) ORDER BY g.grp), '[]'::jsonb)
    INTO v_nova
    FROM (
        SELECT p.nova_classification AS grp, COUNT(*) AS cnt
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND p.nova_classification IS NOT NULL
        GROUP BY p.nova_classification
    ) g;

    -- Allergen tag counts (products *containing* each allergen)
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'tag',   a.tag,
        'count', a.cnt
    ) ORDER BY a.cnt DESC), '[]'::jsonb)
    INTO v_allergens
    FROM (
        SELECT ai.tag, COUNT(DISTINCT ai.product_id) AS cnt
        FROM product_allergen_info ai
        JOIN products p ON p.product_id = ai.product_id
        WHERE ai.type = 'contains'
          AND p.is_deprecated IS NOT TRUE
          AND p.country = v_country
        GROUP BY ai.tag
    ) a;

    RETURN jsonb_build_object(
        'api_version',  '1.0',
        'country',      v_country,
        'categories',   v_categories,
        'nutri_scores', v_nutri,
        'nova_groups',  v_nova,
        'allergens',    v_allergens
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_get_filter_options(text)
    TO authenticated, anon;

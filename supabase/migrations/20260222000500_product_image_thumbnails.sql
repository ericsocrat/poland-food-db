-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: Add image_thumb_url to API responses
-- Purpose: Surface primary product image URL in search, category listing,
--          and dashboard endpoints for frontend thumbnail rendering.
-- Rollback: Re-run the previous version of each function/view.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Update v_master view to include primary image URL ────────────────
-- NOTE: DROP + CREATE (not CREATE OR REPLACE) because image_thumb_url is
-- inserted before existing columns, changing their positions. PostgreSQL's
-- CREATE OR REPLACE VIEW cannot rename columns at existing positions.

DROP VIEW IF EXISTS public.v_master;
CREATE VIEW public.v_master AS
SELECT
    p.product_id,
    p.country,
    p.brand,
    p.product_type,
    p.category,
    p.product_name,
    p.prep_method,
    p.store_availability,
    p.controversies,
    p.ean,

    -- Nutrition (per 100g)
    nf.calories,
    nf.total_fat_g,
    nf.saturated_fat_g,
    nf.trans_fat_g,
    nf.carbs_g,
    nf.sugars_g,
    nf.fibre_g,
    nf.protein_g,
    nf.salt_g,

    -- Scores
    p.unhealthiness_score,
    p.confidence,
    p.data_completeness_pct,
    p.nutri_score_label,
    p.nova_classification,
    CASE p.nova_classification
        WHEN '4' THEN 'High'
        WHEN '3' THEN 'Moderate'
        WHEN '2' THEN 'Low'
        WHEN '1' THEN 'Low'
        ELSE 'Unknown'
    END AS processing_risk,
    p.high_salt_flag,
    p.high_sugar_flag,
    p.high_sat_fat_flag,
    p.high_additive_load,
    p.ingredient_concern_score,

    -- Score explainability
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, ingr.additives_count::numeric, p.prep_method, p.controversies,
        p.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients
    ingr.additives_count,
    ingr.ingredients_text AS ingredients_raw,
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,

    -- Vegan / vegetarian — override to NULL when allergens contradict
    CASE
        WHEN ingr.vegan_status = 'yes'
             AND COALESCE(agg_ai.has_animal_allergen, false)
        THEN NULL
        ELSE ingr.vegan_status
    END AS vegan_status,
    CASE
        WHEN ingr.vegetarian_status = 'yes'
             AND COALESCE(agg_ai.has_meat_fish_allergen, false)
        THEN NULL
        ELSE ingr.vegetarian_status
    END AS vegetarian_status,

    -- Contradiction flags
    (ingr.vegan_status = 'yes'
        AND COALESCE(agg_ai.has_animal_allergen, false)) AS vegan_contradiction,
    (ingr.vegetarian_status = 'yes'
        AND COALESCE(agg_ai.has_meat_fish_allergen, false)) AS vegetarian_contradiction,

    -- Allergen/trace
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance
    p.source_type,
    p.source_url,
    p.source_ean,

    -- Primary product image URL (from product_images table)
    (SELECT img.url
     FROM product_images img
     WHERE img.product_id = p.product_id AND img.is_primary = true
     LIMIT 1) AS image_thumb_url,

    -- Data quality indicators
    CASE
        WHEN ingr.ingredient_count > 0 THEN 'complete'
        ELSE 'missing'
    END AS ingredient_data_quality,
    CASE
        WHEN nf.calories IS NOT NULL
             AND nf.total_fat_g IS NOT NULL
             AND nf.carbs_g IS NOT NULL
             AND nf.protein_g IS NOT NULL
             AND nf.salt_g IS NOT NULL
             AND (nf.total_fat_g IS NULL OR nf.saturated_fat_g IS NULL
                  OR nf.saturated_fat_g <= nf.total_fat_g)
             AND (nf.carbs_g IS NULL OR nf.sugars_g IS NULL
                  OR nf.sugars_g <= nf.carbs_g)
        THEN 'clean'
        ELSE 'suspect'
    END AS nutrition_data_quality,

    -- Phase 2: Product English name + provenance + timestamps
    p.product_name_en,
    p.product_name_en_source,
    p.created_at,
    p.updated_at,

    -- Phase 4: Cross-border translations
    p.name_translations

FROM public.products p
LEFT JOIN public.nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::integer AS ingredient_count,
        COUNT(*) FILTER (WHERE ir.is_additive)::integer AS additives_count,
        STRING_AGG(ir.name_en, ', ' ORDER BY pi.position) AS ingredients_text,
        STRING_AGG(CASE WHEN ir.is_additive THEN ir.name_en END, ', ' ORDER BY pi.position) AS additive_names,
        BOOL_OR(ir.from_palm_oil = 'yes') AS has_palm_oil,
        CASE
            WHEN BOOL_AND(ir.vegan IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegan = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegan_status,
        CASE
            WHEN BOOL_AND(ir.vegetarian IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegetarian = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegetarian_status
    FROM public.product_ingredient pi
    JOIN public.ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
) ingr ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) FILTER (WHERE ai.type = 'contains')::integer AS allergen_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'contains') AS allergen_tags,
        COUNT(*) FILTER (WHERE ai.type = 'traces')::integer AS trace_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'traces') AS trace_tags,
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'en:milk', 'en:eggs', 'en:fish', 'en:crustaceans', 'en:molluscs'
        )) AS has_animal_allergen,
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'en:fish', 'en:crustaceans', 'en:molluscs'
        )) AS has_meat_fish_allergen
    FROM public.product_allergen_info ai
    WHERE ai.product_id = p.product_id
) agg_ai ON true
WHERE p.is_deprecated IS NOT TRUE;

-- ─── 2. Update api_category_listing to include image_thumb_url ───────────

CREATE OR REPLACE FUNCTION public.api_category_listing(
    p_category                text,
    p_sort_by                 text     DEFAULT 'score',
    p_sort_dir                text     DEFAULT 'asc',
    p_limit                   integer  DEFAULT 20,
    p_offset                  integer  DEFAULT 0,
    p_country                 text     DEFAULT NULL,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false,
    p_language                text     DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total     integer;
    v_rows      jsonb;
    v_country   text;
    v_category  text;
    v_language  text;
    v_cat_disp  text;
BEGIN
    SELECT cr.category INTO v_category
    FROM category_ref cr WHERE cr.slug = p_category;

    IF v_category IS NULL THEN
        SELECT cr.category INTO v_category
        FROM category_ref cr WHERE cr.category = p_category;
    END IF;

    IF v_category IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Unknown category: ' || COALESCE(p_category, 'NULL')
        );
    END IF;

    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    v_country  := resolve_effective_country(p_country);
    v_language := resolve_language(p_language);

    SELECT COALESCE(ct.display_name, cr.display_name)
    INTO v_cat_disp
    FROM category_ref cr
    LEFT JOIN category_translations ct
        ON ct.category = cr.category AND ct.language_code = v_language
    WHERE cr.category = v_category;

    SELECT COUNT(*)::int INTO v_total
    FROM v_master m
    WHERE m.category = v_category
      AND m.country = v_country
      AND check_product_preferences(
          m.product_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
      );

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          m.product_id,
            'ean',                 m.ean,
            'product_name',        m.product_name,
            'brand',               m.brand,
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,
            'calories',            m.calories,
            'total_fat_g',         m.total_fat_g,
            'protein_g',           m.protein_g,
            'sugars_g',            m.sugars_g,
            'salt_g',              m.salt_g,
            'high_salt_flag',      (m.high_salt_flag = 'YES'),
            'high_sugar_flag',     (m.high_sugar_flag = 'YES'),
            'high_sat_fat_flag',   (m.high_sat_fat_flag = 'YES'),
            'confidence',          m.confidence,
            'data_completeness_pct', m.data_completeness_pct,
            'image_thumb_url',     m.image_thumb_url
        ) AS row_data
        FROM v_master m
        WHERE m.category = v_category
          AND m.country = v_country
          AND check_product_preferences(
              m.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
        ORDER BY
            CASE WHEN p_sort_dir = 'asc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END ASC NULLS LAST,
            CASE WHEN p_sort_dir = 'desc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END DESC NULLS LAST,
            m.product_id ASC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version',      '1.0',
        'category',         v_category,
        'category_display', v_cat_disp,
        'language',         v_language,
        'country',          v_country,
        'total_count',      v_total,
        'limit',            p_limit,
        'offset',           p_offset,
        'sort_by',          p_sort_by,
        'sort_dir',         p_sort_dir,
        'products',         v_rows
    );
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.api_category_listing(text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean, text)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_category_listing(text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean, text)
    TO authenticated, service_role;

-- ─── 3. Update api_search_products to include image_thumb_url ────────────

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

-- ─── 4. Update api_get_recently_viewed to include image_thumb_url ────────

CREATE OR REPLACE FUNCTION public.api_get_recently_viewed(
    p_limit  integer DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id  uuid := auth.uid();
    v_limit    integer := LEAST(GREATEST(p_limit, 1), 50);
    v_products jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_products
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            upv.viewed_at,
            (SELECT img.url FROM product_images img
             WHERE img.product_id = p.product_id AND img.is_primary = true
             LIMIT 1) AS image_thumb_url
        FROM public.user_product_views upv
        JOIN public.products p ON p.product_id = upv.product_id
        WHERE upv.user_id = v_user_id
          AND p.is_deprecated IS NOT TRUE
        ORDER BY upv.viewed_at DESC
        LIMIT v_limit
    ) t;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'products', v_products
    );
END;
$$;

-- ─── 5. Update api_get_dashboard_data to include image_thumb_url ─────────

CREATE OR REPLACE FUNCTION public.api_get_dashboard_data()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id          uuid := auth.uid();
    v_recently_viewed  jsonb;
    v_favorites        jsonb;
    v_new_products     jsonb;
    v_stats            jsonb;
    v_top_category     text;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Recently Viewed (last 8)
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_recently_viewed
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            upv.viewed_at,
            (SELECT img.url FROM product_images img
             WHERE img.product_id = p.product_id AND img.is_primary = true
             LIMIT 1) AS image_thumb_url
        FROM public.user_product_views upv
        JOIN public.products p ON p.product_id = upv.product_id
        WHERE upv.user_id = v_user_id
          AND p.is_deprecated IS NOT TRUE
        ORDER BY upv.viewed_at DESC
        LIMIT 8
    ) t;

    -- Favorites Preview (first 6)
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_favorites
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            li.added_at,
            (SELECT img.url FROM product_images img
             WHERE img.product_id = p.product_id AND img.is_primary = true
             LIMIT 1) AS image_thumb_url
        FROM public.user_product_list_items li
        JOIN public.user_product_lists l ON l.id = li.list_id
        JOIN public.products p ON p.product_id = li.product_id
        WHERE l.user_id = v_user_id
          AND l.list_type = 'favorites'
          AND p.is_deprecated IS NOT TRUE
        ORDER BY li.position, li.added_at DESC
        LIMIT 6
    ) t;

    -- New Products (last 14 days, user's most-viewed categories)
    SELECT p.category
    INTO v_top_category
    FROM public.user_product_views upv
    JOIN public.products p ON p.product_id = upv.product_id
    WHERE upv.user_id = v_user_id
      AND p.is_deprecated IS NOT TRUE
    GROUP BY p.category
    ORDER BY count(*) DESC
    LIMIT 1;

    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_new_products
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            (SELECT img.url FROM product_images img
             WHERE img.product_id = p.product_id AND img.is_primary = true
             LIMIT 1) AS image_thumb_url
        FROM public.products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.created_at >= now() - interval '14 days'
          AND (v_top_category IS NULL OR p.category = v_top_category)
        ORDER BY p.created_at DESC
        LIMIT 6
    ) t;

    -- User Stats
    SELECT jsonb_build_object(
        'total_scanned',
        (SELECT count(*) FROM public.scan_history WHERE user_id = v_user_id),
        'total_viewed',
        (SELECT count(*) FROM public.user_product_views WHERE user_id = v_user_id),
        'lists_count',
        (SELECT count(*) FROM public.user_product_lists WHERE user_id = v_user_id),
        'favorites_count',
        (SELECT count(*)
         FROM public.user_product_list_items li
         JOIN public.user_product_lists l ON l.id = li.list_id
         WHERE l.user_id = v_user_id AND l.list_type = 'favorites'),
        'most_viewed_category',
        v_top_category
    )
    INTO v_stats;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'recently_viewed', v_recently_viewed,
        'favorites_preview', v_favorites,
        'new_products', v_new_products,
        'stats', v_stats
    );
END;
$$;

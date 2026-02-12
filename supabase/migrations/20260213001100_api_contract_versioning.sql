-- ═══════════════════════════════════════════════════════════════════════════════
-- Frontend Contract Stability: api_version field + key inventory lockdown
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Every API function now returns an 'api_version' key in its response.
-- This lets frontends detect breaking changes and adapt accordingly.
--
-- Version scheme: "1.0" (semver major.minor)
--   - Major bump: keys removed or renamed, response structure changes
--   - Minor bump: keys added (backward-compatible)
--
-- All functions retain SECURITY DEFINER + search_path = public.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. api_product_detail  — 17 top-level keys + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_product_detail(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',         '1.0',

        -- Identity
        'product_id',          m.product_id,
        'ean',                 m.ean,
        'product_name',        m.product_name,
        'brand',               m.brand,
        'category',            m.category,
        'category_display',    cr.display_name,
        'category_icon',       cr.icon_emoji,
        'product_type',        m.product_type,
        'country',             m.country,
        'store_availability',  m.store_availability,
        'prep_method',         m.prep_method,

        -- Scores
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nutri_score_color',   nsr.color_hex,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk
        ),

        -- Flags
        'flags', jsonb_build_object(
            'high_salt',           (m.high_salt_flag = 'YES'),
            'high_sugar',          (m.high_sugar_flag = 'YES'),
            'high_sat_fat',        (m.high_sat_fat_flag = 'YES'),
            'high_additive_load',  (m.high_additive_load = 'YES'),
            'has_palm_oil',        COALESCE(m.has_palm_oil, false)
        ),

        -- Nutrition per 100 g
        'nutrition_per_100g', jsonb_build_object(
            'calories',       m.calories,
            'total_fat_g',    m.total_fat_g,
            'saturated_fat_g',m.saturated_fat_g,
            'trans_fat_g',    m.trans_fat_g,
            'carbs_g',        m.carbs_g,
            'sugars_g',       m.sugars_g,
            'fibre_g',        m.fibre_g,
            'protein_g',      m.protein_g,
            'salt_g',         m.salt_g
        ),

        -- Ingredients
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additives_count',    m.additives_count,
            'additive_names',     m.additive_names,
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'data_quality',       m.ingredient_data_quality
        ),

        -- Allergens
        'allergens', jsonb_build_object(
            'count',         m.allergen_count,
            'tags',          m.allergen_tags,
            'trace_count',   m.trace_count,
            'trace_tags',    m.trace_tags
        ),

        -- Data trust
        'trust', jsonb_build_object(
            'confidence',              m.confidence,
            'data_completeness_pct',   m.data_completeness_pct,
            'source_type',             m.source_type,
            'nutrition_data_quality',  m.nutrition_data_quality,
            'ingredient_data_quality', m.ingredient_data_quality
        )
    )
    FROM public.v_master m
    LEFT JOIN public.category_ref cr ON cr.category = m.category
    LEFT JOIN public.nutri_score_ref nsr ON nsr.label = m.nutri_score_label
    WHERE m.product_id = p_product_id;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. api_search_products  — 6 top-level keys + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_search_products(
    p_query text,
    p_category text DEFAULT NULL,
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_query   text;
BEGIN
    v_query := TRIM(p_query);
    IF LENGTH(v_query) < 2 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Query must be at least 2 characters.'
        );
    END IF;
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    SELECT COUNT(*)::int INTO v_total
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND (
          p.product_name ILIKE '%' || v_query || '%'
          OR p.brand ILIKE '%' || v_query || '%'
          OR similarity(p.product_name, v_query) > 0.15
      );

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'brand',               p.brand,
            'category',            p.category,
            'unhealthiness_score', p.unhealthiness_score,
            'score_band',          CASE
                                     WHEN p.unhealthiness_score <= 25 THEN 'low'
                                     WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN p.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         p.nutri_score_label,
            'nova_group',          p.nova_classification,
            'relevance',           GREATEST(
                                     similarity(p.product_name, v_query),
                                     similarity(p.brand, v_query) * 0.8
                                   )
        ) AS row_data
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND (p_category IS NULL OR p.category = p_category)
          AND (
              p.product_name ILIKE '%' || v_query || '%'
              OR p.brand ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
        ORDER BY
            CASE WHEN p.product_name ILIKE v_query || '%' THEN 0 ELSE 1 END,
            GREATEST(similarity(p.product_name, v_query), similarity(p.brand, v_query) * 0.8) DESC,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'query',       v_query,
        'category',    p_category,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. api_category_listing  — 8 top-level keys + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_category_listing(
    p_category text,
    p_sort_by text DEFAULT 'score',
    p_sort_dir text DEFAULT 'asc',
    p_limit integer DEFAULT 20,
    p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_order   text;
BEGIN
    -- Validate and map sort column
    v_order := CASE p_sort_by
        WHEN 'score'       THEN 'unhealthiness_score'
        WHEN 'calories'    THEN 'calories'
        WHEN 'protein'     THEN 'protein_g'
        WHEN 'name'        THEN 'product_name'
        WHEN 'nutri_score' THEN 'nutri_score_label'
        ELSE 'unhealthiness_score'
    END;

    -- Clamp pagination
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    -- Get total count
    SELECT COUNT(*)::int INTO v_total
    FROM v_master
    WHERE category = p_category;

    -- Build result rows with dynamic ordering
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
            'data_completeness_pct', m.data_completeness_pct
        ) AS row_data
        FROM v_master m
        WHERE m.category = p_category
        ORDER BY
            CASE WHEN p_sort_dir = 'asc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN m.unhealthiness_score::text
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE m.unhealthiness_score::text
                END
            END ASC NULLS LAST,
            CASE WHEN p_sort_dir = 'desc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN m.unhealthiness_score::text
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE m.unhealthiness_score::text
                END
            END DESC NULLS LAST,
            m.product_id ASC  -- stable tiebreaker
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'category',      p_category,
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'sort_by',       p_sort_by,
        'sort_dir',      p_sort_dir,
        'products',      v_rows
    );
END;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. api_score_explanation  — 9 top-level keys + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_score_explanation(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'product_id',      m.product_id,
        'product_name',    m.product_name,
        'brand',           m.brand,
        'category',        m.category,
        'score_breakdown', m.score_breakdown,
        'summary', jsonb_build_object(
            'score',       m.unhealthiness_score,
            'score_band',  CASE
                             WHEN m.unhealthiness_score <= 25 THEN 'low'
                             WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                             WHEN m.unhealthiness_score <= 75 THEN 'high'
                             ELSE 'very_high'
                           END,
            'headline',    CASE
                             WHEN m.unhealthiness_score <= 15 THEN
                                 'This product scores very well. It has low levels of nutrients of concern.'
                             WHEN m.unhealthiness_score <= 30 THEN
                                 'This product has a moderate profile. Some areas could be better.'
                             WHEN m.unhealthiness_score <= 50 THEN
                                 'This product has several areas of nutritional concern.'
                             ELSE
                                 'This product has significant nutritional concerns across multiple factors.'
                           END,
            'nutri_score',    m.nutri_score_label,
            'nova_group',     m.nova_classification,
            'processing_risk',m.processing_risk
        ),
        'top_factors', (
            SELECT jsonb_agg(f ORDER BY (f->>'weighted')::numeric DESC)
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS f
            WHERE (f->>'weighted')::numeric > 0
        ),
        'warnings', (
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'message', 'Salt content exceeds 1.5g per 100g.')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'message', 'Sugar content is elevated.')             WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'message', 'Saturated fat content is elevated.')     WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'message', 'This product has a high additive load.') WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'message', 'Contains palm oil.')                     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'message', 'Classified as ultra-processed (NOVA 4).') WHERE m.nova_classification = '4'
            ) warnings
        ),
        'category_context', (
            SELECT jsonb_build_object(
                'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
                'category_rank',      (
                    SELECT COUNT(*) + 1
                    FROM v_master m2
                    WHERE m2.category = m.category
                      AND m2.unhealthiness_score < m.unhealthiness_score
                ),
                'category_total',     COUNT(*)::int,
                'relative_position',  CASE
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score)       THEN 'better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                    ELSE 'much_worse_than_average'
                END
            )
            FROM products p2
            WHERE p2.category = m.category AND p2.is_deprecated IS NOT TRUE
        )
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. api_better_alternatives  — 4 top-level keys + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_better_alternatives(
    p_product_id bigint,
    p_same_category boolean DEFAULT true,
    p_limit integer DEFAULT 5
)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'source_product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'brand',              m.brand,
            'category',           m.category,
            'unhealthiness_score',m.unhealthiness_score,
            'nutri_score',        m.nutri_score_label
        ),
        'search_scope',    CASE WHEN p_same_category THEN 'same_category' ELSE 'all_categories' END,
        'alternatives',    COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_improvement',  alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity,
                'shared_ingredients', alt.shared_ingredients
            ))
            FROM find_better_alternatives(p_product_id, p_same_category, p_limit) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives(p_product_id, p_same_category, p_limit)
        ), 0)
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. api_data_confidence  — wraps compute_data_confidence + api_version
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_data_confidence(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT compute_data_confidence(p_product_id) || jsonb_build_object('api_version', '1.0');
$function$;

COMMIT;

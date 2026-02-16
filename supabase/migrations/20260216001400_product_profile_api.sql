-- ─── Migration: Canonical Product Profile API ───────────────────────────────
-- Issue: #33 — Product Profile Page + Canonical Product Profile API
-- Creates api_get_product_profile() and api_get_product_profile_by_ean()
-- that bundle all product data into a single round-trip.
-- Existing api_product_detail(), api_score_explanation(), api_better_alternatives(),
-- api_data_confidence() remain unchanged (backward compatible).
-- ─────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. api_get_product_profile() — composite product profile endpoint
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_product_profile(
    p_product_id bigint,
    p_language    text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
    v_language     text;
    v_country_lang text;
    v_result       jsonb;
BEGIN
    -- Resolve language
    v_language := resolve_language(p_language);

    -- Build composite profile
    SELECT jsonb_build_object(
        'api_version', '1.0',
        'meta', jsonb_build_object(
            'product_id',   m.product_id,
            'language',     v_language,
            'retrieved_at', now()
        ),
        'product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'product_name_en',    m.product_name_en,
            'product_name_display', CASE
                WHEN v_language = COALESCE(cref.default_language, LOWER(m.country))
                    THEN m.product_name
                WHEN v_language = 'en'
                    THEN COALESCE(m.product_name_en, m.product_name)
                ELSE COALESCE(
                    m.name_translations->>v_language,
                    m.product_name_en,
                    m.product_name
                )
            END,
            'original_language',  COALESCE(cref.default_language, LOWER(m.country)),
            'brand',              m.brand,
            'category',           m.category,
            'category_display',   COALESCE(ct.display_name, cr.display_name),
            'category_icon',      COALESCE(cr.icon_emoji, '📦'),
            'product_type',       m.product_type,
            'country',            m.country,
            'ean',                m.ean,
            'prep_method',        m.prep_method,
            'store_availability', m.store_availability,
            'controversies',      m.controversies
        ),
        'nutrition', jsonb_build_object(
            'per_100g', jsonb_build_object(
                'calories_kcal',   m.calories,
                'total_fat_g',     m.total_fat_g,
                'saturated_fat_g', m.saturated_fat_g,
                'trans_fat_g',     m.trans_fat_g,
                'carbs_g',         m.carbs_g,
                'sugars_g',        m.sugars_g,
                'fibre_g',         m.fibre_g,
                'protein_g',       m.protein_g,
                'salt_g',          m.salt_g
            ),
            'per_serving', NULL::jsonb
        ),
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additive_count',     m.additives_count,
            'additive_names',     m.additive_names,
            'has_palm_oil',       COALESCE(m.has_palm_oil, false),
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'ingredients_text',   m.ingredients_raw,
            'top_ingredients',    COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'name',            ir.name_en,
                    'position',        pi.position,
                    'concern_tier',    COALESCE(ir.concern_tier, 0),
                    'is_additive',     ir.is_additive
                ) ORDER BY pi.position)
                FROM product_ingredient pi
                JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
                WHERE pi.product_id = m.product_id
                  AND pi.position <= 10
            ), '[]'::jsonb)
        ),
        'allergens', jsonb_build_object(
            'contains',         COALESCE(m.allergen_tags, ''),
            'traces',           COALESCE(m.trace_tags, ''),
            'contains_count',   m.allergen_count,
            'traces_count',     m.trace_count
        ),
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score_label',   m.nutri_score_label,
            'nutri_score_color',   COALESCE(ns.color_hex, '#999999'),
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,
            'score_breakdown',     COALESCE(m.score_breakdown->'factors', '[]'::jsonb),
            'headline',            CASE
                                     WHEN m.unhealthiness_score <= 15 THEN
                                         'This product scores very well. It has low levels of nutrients of concern.'
                                     WHEN m.unhealthiness_score <= 30 THEN
                                         'This product has a moderate profile. Some areas could be better.'
                                     WHEN m.unhealthiness_score <= 50 THEN
                                         'This product has several areas of nutritional concern.'
                                     ELSE
                                         'This product has significant nutritional concerns across multiple factors.'
                                   END,
            'category_context', (
                SELECT jsonb_build_object(
                    'rank',               (
                        SELECT COUNT(*) + 1
                        FROM v_master m2
                        WHERE m2.category = m.category
                          AND m2.country = m.country
                          AND m2.unhealthiness_score < m.unhealthiness_score
                    ),
                    'total_in_category',  COUNT(*)::int,
                    'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
                    'relative_position',  CASE
                        WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                        WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score)       THEN 'better_than_average'
                        WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                        ELSE 'much_worse_than_average'
                    END
                )
                FROM products p2
                WHERE p2.category = m.category
                  AND p2.country = m.country
                  AND p2.is_deprecated IS NOT TRUE
            )
        ),
        'warnings', COALESCE((
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'severity', 'warning', 'message', 'High salt content')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'severity', 'warning', 'message', 'High sugar content')   WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'severity', 'warning', 'message', 'High saturated fat content') WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'severity', 'info',    'message', 'Contains many additives')    WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'severity', 'info',    'message', 'Contains palm oil')     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'severity', 'info',    'message', 'Ultra-processed food (NOVA 4)')       WHERE m.nova_classification = '4'
            ) warnings
        ), '[]'::jsonb),
        'quality', compute_data_confidence(m.product_id),
        'alternatives', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_delta',        alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity
            ))
            FROM find_better_alternatives(p_product_id, true, 3) alt
        ), '[]'::jsonb),
        'flags', jsonb_build_object(
            'high_salt',          (m.high_salt_flag = 'YES'),
            'high_sugar',         (m.high_sugar_flag = 'YES'),
            'high_sat_fat',       (m.high_sat_fat_flag = 'YES'),
            'high_additive_load', (m.high_additive_load = 'YES'),
            'has_palm_oil',       COALESCE(m.has_palm_oil, false)
        )
    )
    INTO v_result
    FROM v_master m
    LEFT JOIN category_ref cr ON cr.category = m.category
    LEFT JOIN category_translations ct
        ON ct.category = m.category AND ct.language_code = v_language
    LEFT JOIN nutri_score_ref ns ON ns.label = m.nutri_score_label
    LEFT JOIN country_ref cref ON cref.country_code = m.country
    WHERE m.product_id = p_product_id;

    RETURN v_result;
END;
$func$;

COMMENT ON FUNCTION public.api_get_product_profile(bigint, text) IS
'Canonical product profile endpoint — bundles product data, nutrition, '
'ingredients, allergens, scores with breakdown + category context, '
'warnings, quality/confidence, and top 3 alternatives in a single JSONB '
'envelope. Replaces the need for 4 separate RPC calls on the product page.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. api_get_product_profile_by_ean() — EAN-based lookup wrapper
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_product_profile_by_ean(
    p_ean      text,
    p_language text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
    v_product_id bigint;
    v_country    text;
BEGIN
    -- Resolve effective country for scoping
    v_country := resolve_effective_country(NULL);

    -- Find product by EAN within the user's country scope
    SELECT p.product_id INTO v_product_id
    FROM products p
    WHERE p.ean = p_ean
      AND p.country = v_country
      AND p.is_deprecated IS NOT TRUE
    LIMIT 1;

    -- If not found in user's country, try any active country
    IF v_product_id IS NULL THEN
        SELECT p.product_id INTO v_product_id
        FROM products p
        WHERE p.ean = p_ean
          AND p.is_deprecated IS NOT TRUE
        LIMIT 1;
    END IF;

    -- If still not found, return error
    IF v_product_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'product_not_found',
            'ean',         p_ean
        );
    END IF;

    RETURN api_get_product_profile(v_product_id, p_language);
END;
$func$;

COMMENT ON FUNCTION public.api_get_product_profile_by_ean(text, text) IS
'EAN-based product profile lookup. Resolves EAN → product_id then delegates '
'to api_get_product_profile(). Returns error envelope if EAN not found.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Grants — match existing pattern
-- ═══════════════════════════════════════════════════════════════════════════════

-- api_get_product_profile: accessible to anon (for SEO/sharing) and authenticated
GRANT EXECUTE ON FUNCTION public.api_get_product_profile(bigint, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_get_product_profile(bigint, text)
    FROM PUBLIC;

-- api_get_product_profile_by_ean: accessible to anon (for shared links) and authenticated
GRANT EXECUTE ON FUNCTION public.api_get_product_profile_by_ean(text, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_get_product_profile_by_ean(text, text)
    FROM PUBLIC;

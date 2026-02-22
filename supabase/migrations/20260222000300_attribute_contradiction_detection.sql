-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: 20260222000300_attribute_contradiction_detection.sql
-- Issue #152 — Attribute Contradictions
--
-- Problem: Products can claim "vegan: yes" (from ingredient_ref data) while
--          simultaneously declaring animal-derived allergens (en:milk, en:eggs …)
--          in product_allergen_info.  This combination is logically impossible
--          and may mislead users with dietary restrictions.
--
-- Changes:
--   1.  v_master — allergen lateral join gains two boolean flags:
--       has_animal_allergen, has_meat_fish_allergen.
--       Outer SELECT overrides vegan_status/vegetarian_status to NULL when
--       a contradiction is detected and exposes boolean contradiction columns.
--   2.  api_get_product_profile() — ingredients JSONB gains
--       vegan_contradiction / vegetarian_contradiction booleans.
--
-- Rollback:
--   Restore v_master from 20260216001100 and api_get_product_profile from
--   20260217000500 (the prior definitions without contradiction detection).
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. v_master — add contradiction detection
-- ═══════════════════════════════════════════════════════════════════════════════
-- NOTE: DROP + CREATE (not CREATE OR REPLACE) because new columns
-- (vegan_contradiction, vegetarian_contradiction) are inserted before
-- allergen_count, changing existing column positions. PostgreSQL's
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

    -- Contradiction flags (for frontend warnings)
    (ingr.vegan_status = 'yes'
        AND COALESCE(agg_ai.has_animal_allergen, false)) AS vegan_contradiction,
    (ingr.vegetarian_status = 'yes'
        AND COALESCE(agg_ai.has_meat_fish_allergen, false)) AS vegetarian_contradiction,

    -- Allergens
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance
    p.source_type,
    p.source_url,
    p.source_ean,

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
        -- Contradiction detection flags
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


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. api_get_product_profile — add contradiction flags to ingredients JSONB
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
            'per_serving', NULL::jsonb,
            'daily_values', compute_daily_value_pct(m.product_id, 'eu_ri', NULL)
        ),
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additive_count',     m.additives_count,
            'additive_names',     m.additive_names,
            'has_palm_oil',       COALESCE(m.has_palm_oil, false),
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'vegan_contradiction',      COALESCE(m.vegan_contradiction, false),
            'vegetarian_contradiction', COALESCE(m.vegetarian_contradiction, false),
            'ingredients_text',   m.ingredients_raw,
            'top_ingredients',    COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'ingredient_id',   deduped.ingredient_id,
                    'name',            deduped.name_en,
                    'position',        deduped.position,
                    'concern_tier',    deduped.concern_tier,
                    'is_additive',     deduped.is_additive,
                    'concern_reason',  deduped.concern_reason
                ) ORDER BY deduped.position)
                FROM (
                    SELECT DISTINCT ON (LOWER(ir.name_en))
                        ir.ingredient_id,
                        ir.name_en,
                        pi.position,
                        COALESCE(ir.concern_tier, 0) AS concern_tier,
                        ir.is_additive,
                        ir.concern_reason
                    FROM product_ingredient pi
                    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
                    WHERE pi.product_id = m.product_id
                      AND pi.position <= 10
                    ORDER BY LOWER(ir.name_en), pi.position
                ) deduped
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
                UNION ALL
                SELECT jsonb_build_object('type', 'vegan_contradiction',      'severity', 'warning', 'message', 'Vegan status contradicted by allergen data')      WHERE COALESCE(m.vegan_contradiction, false)
                UNION ALL
                SELECT jsonb_build_object('type', 'vegetarian_contradiction', 'severity', 'warning', 'message', 'Vegetarian status contradicted by allergen data') WHERE COALESCE(m.vegetarian_contradiction, false)
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
            'high_salt',                (m.high_salt_flag = 'YES'),
            'high_sugar',               (m.high_sugar_flag = 'YES'),
            'high_sat_fat',             (m.high_sat_fat_flag = 'YES'),
            'high_additive_load',       (m.high_additive_load = 'YES'),
            'has_palm_oil',             COALESCE(m.has_palm_oil, false),
            'vegan_contradiction',      COALESCE(m.vegan_contradiction, false),
            'vegetarian_contradiction', COALESCE(m.vegetarian_contradiction, false)
        ),
        'images', jsonb_build_object(
            'has_image', EXISTS(
                SELECT 1 FROM product_images img
                WHERE img.product_id = m.product_id
            ),
            'primary', (
                SELECT jsonb_build_object(
                    'image_id',   img.image_id,
                    'url',        img.url,
                    'image_type', img.image_type,
                    'source',     img.source,
                    'width',      img.width,
                    'height',     img.height,
                    'alt_text',   img.alt_text
                )
                FROM product_images img
                WHERE img.product_id = m.product_id
                  AND img.is_primary = true
                LIMIT 1
            ),
            'additional', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'image_id',   img.image_id,
                    'url',        img.url,
                    'image_type', img.image_type,
                    'source',     img.source,
                    'width',      img.width,
                    'height',     img.height,
                    'alt_text',   img.alt_text
                ) ORDER BY img.image_type, img.image_id)
                FROM product_images img
                WHERE img.product_id = m.product_id
                  AND img.is_primary = false
            ), '[]'::jsonb)
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
'ingredients (with case-insensitive deduplication and contradiction '
'detection), allergens, scores with breakdown + category context, '
'warnings, quality/confidence, top 3 alternatives, flags, and product '
'images in a single JSONB envelope. Vegan/vegetarian statuses are set '
'to NULL when contradicted by declared allergens.';

COMMIT;

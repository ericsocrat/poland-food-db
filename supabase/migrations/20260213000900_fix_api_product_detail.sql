-- ============================================================
-- Migration: Fix broken api_product_detail() function
-- Date:      2026-02-13
-- ============================================================
-- Problems fixed:
--   1. nutrition_per_serving block references non-existent columns
--      (serving_amount_g, srv_calories, etc.) — no serving table
--      exists in the schema. Removed until serving data is added.
--   2. trust.source_confidence_pct references m.source_confidence
--      which does not exist in v_master. Removed.
--   3. Cleaned up 5 junk 'en:none' allergen rows — these are OFF
--      placeholder tags meaning "no allergens declared" and should
--      not be stored as actual allergen entries.
-- ============================================================

BEGIN;

-- ────────────────────────────────────────────────────────────
-- 1. Recreate api_product_detail() without broken column refs
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION api_product_detail(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
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
$$;

COMMENT ON FUNCTION api_product_detail IS
    'Returns a single product as structured JSONB with nested sections: identity, '
    'scores, flags, nutrition_per_100g, ingredients, allergens, trust. '
    'Hides internal columns (ingredients_raw, source_url, scoring_version, etc.). '
    'Note: nutrition_per_serving removed — no serving data in schema yet.';

-- ────────────────────────────────────────────────────────────
-- 2. Remove junk en:none allergen/trace rows
-- ────────────────────────────────────────────────────────────
-- OFF uses 'en:none' as a placeholder for "no allergens/traces declared".
-- This is not a real allergen — products with no traces should simply
-- have no rows in product_allergen_info rather than a 'none' marker.
DELETE FROM product_allergen_info WHERE tag = 'en:none';

COMMIT;

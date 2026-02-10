-- Migration: Score Explainability
-- Date: 2026-02-10
-- Purpose: Create explain_score_v32() function that returns a JSONB breakdown
--          of how each product's unhealthiness score is computed.
--          Add score_breakdown column to v_master for easy access.

BEGIN;

-- ============================================================
-- 1. explain_score_v32() — JSONB breakdown of score computation
-- ============================================================
CREATE OR REPLACE FUNCTION explain_score_v32(
    p_saturated_fat_g  numeric,
    p_sugars_g         numeric,
    p_salt_g           numeric,
    p_calories         numeric,
    p_trans_fat_g      numeric,
    p_additives_count  numeric,
    p_prep_method      text,
    p_controversies    text,
    p_concern_score    numeric
)
RETURNS jsonb
LANGUAGE sql IMMUTABLE AS $$
    WITH factors AS (
        SELECT
            -- Raw sub-scores (0-100 scale before weighting)
            LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) AS sat_fat_raw,
            LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) AS sugars_raw,
            LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) AS salt_raw,
            LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) AS calories_raw,
            LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) AS trans_fat_raw,
            LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) AS additives_raw,
            (CASE p_prep_method
               WHEN 'air-popped'  THEN 20
               WHEN 'steamed'     THEN 30
               WHEN 'baked'       THEN 40
               WHEN 'grilled'     THEN 60
               WHEN 'smoked'      THEN 65
               WHEN 'fried'       THEN 80
               WHEN 'deep-fried'  THEN 100
               ELSE 50
             END)::numeric AS prep_raw,
            (CASE p_controversies
               WHEN 'none'      THEN 0
               WHEN 'minor'     THEN 30
               WHEN 'palm oil'  THEN 40
               WHEN 'moderate'  THEN 60
               WHEN 'serious'   THEN 100
               ELSE 0
             END)::numeric AS controversies_raw,
            LEAST(100, COALESCE(p_concern_score, 0)) AS concern_raw
    )
    SELECT jsonb_build_object(
        'version', 'v3.2',
        'final_score', GREATEST(1, LEAST(100, round(
            sat_fat_raw * 0.17 + sugars_raw * 0.17 + salt_raw * 0.17 +
            calories_raw * 0.10 + trans_fat_raw * 0.11 + additives_raw * 0.07 +
            prep_raw * 0.08 + controversies_raw * 0.08 + concern_raw * 0.05
        )))::integer,
        'factors', jsonb_build_array(
            jsonb_build_object('name', 'saturated_fat', 'weight', 0.17, 'raw', round(sat_fat_raw, 1),
                'weighted', round(sat_fat_raw * 0.17, 2), 'input', p_saturated_fat_g, 'ceiling', 10.0),
            jsonb_build_object('name', 'sugars',        'weight', 0.17, 'raw', round(sugars_raw, 1),
                'weighted', round(sugars_raw * 0.17, 2), 'input', p_sugars_g, 'ceiling', 27.0),
            jsonb_build_object('name', 'salt',          'weight', 0.17, 'raw', round(salt_raw, 1),
                'weighted', round(salt_raw * 0.17, 2), 'input', p_salt_g, 'ceiling', 3.0),
            jsonb_build_object('name', 'calories',      'weight', 0.10, 'raw', round(calories_raw, 1),
                'weighted', round(calories_raw * 0.10, 2), 'input', p_calories, 'ceiling', 600.0),
            jsonb_build_object('name', 'trans_fat',     'weight', 0.11, 'raw', round(trans_fat_raw, 1),
                'weighted', round(trans_fat_raw * 0.11, 2), 'input', p_trans_fat_g, 'ceiling', 2.0),
            jsonb_build_object('name', 'additives',     'weight', 0.07, 'raw', round(additives_raw, 1),
                'weighted', round(additives_raw * 0.07, 2), 'input', p_additives_count, 'ceiling', 10.0),
            jsonb_build_object('name', 'prep_method',   'weight', 0.08, 'raw', prep_raw,
                'weighted', round(prep_raw * 0.08, 2), 'input', p_prep_method),
            jsonb_build_object('name', 'controversies', 'weight', 0.08, 'raw', controversies_raw,
                'weighted', round(controversies_raw * 0.08, 2), 'input', p_controversies),
            jsonb_build_object('name', 'ingredient_concern', 'weight', 0.05, 'raw', round(concern_raw, 1),
                'weighted', round(concern_raw * 0.05, 2), 'input', p_concern_score)
        )
    )
    FROM factors;
$$;

COMMENT ON FUNCTION explain_score_v32 IS 'Returns a JSONB breakdown of the v3.2 unhealthiness score computation: final_score, plus an array of 9 factors with name, weight, raw score (0-100), weighted contribution, input value, and ceiling.';


-- ============================================================
-- 2. Add score_breakdown to v_master
-- ============================================================
-- We need to DROP + CREATE the view since we're adding a column.
DROP VIEW IF EXISTS public.v_master CASCADE;

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

    -- Per-serving nutrition
    sv_real.serving_amount_g_ml AS serving_amount_g,
    ns.calories       AS srv_calories,
    ns.total_fat_g    AS srv_total_fat_g,
    ns.saturated_fat_g AS srv_saturated_fat_g,
    ns.trans_fat_g    AS srv_trans_fat_g,
    ns.carbs_g        AS srv_carbs_g,
    ns.sugars_g       AS srv_sugars_g,
    ns.fibre_g        AS srv_fibre_g,
    ns.protein_g      AS srv_protein_g,
    ns.salt_g         AS srv_salt_g,

    -- Scores
    s.unhealthiness_score,
    s.scoring_version,
    s.scored_at,
    s.confidence,
    s.data_completeness_pct,
    s.nutri_score_label,
    s.nova_classification,
    s.processing_risk,
    s.high_salt_flag,
    s.high_sugar_flag,
    s.high_sat_fat_flag,
    s.high_additive_load,
    s.ingredient_concern_score,

    -- Score explainability (JSONB breakdown)
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, i.additives_count, p.prep_method, p.controversies,
        s.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients
    i.additives_count,
    i.ingredients_raw,

    -- Product-level provenance
    p.ean,
    ps.source_type,
    ps.source_url,
    ps.source_ean,
    ps.confidence_pct    AS source_confidence,
    ps.fields_populated  AS source_fields,
    ps.collected_at      AS source_collected_at,
    ps.notes             AS source_notes,

    -- Ingredient analytics (lateral)
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,
    ingr.vegan_status,
    ingr.vegetarian_status,
    ingr.allergen_count,
    ingr.allergen_tags,
    ingr.trace_count,
    ingr.trace_tags,

    -- Data quality indicators
    CASE
        WHEN i.ingredients_raw IS NOT NULL AND ingr.ingredient_count > 0 THEN 'complete'
        WHEN i.ingredients_raw IS NOT NULL THEN 'partial'
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
    END AS nutrition_data_quality

FROM public.products p
LEFT JOIN public.servings sv
    ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
LEFT JOIN public.nutrition_facts nf
    ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
LEFT JOIN public.servings sv_real
    ON sv_real.product_id = p.product_id AND sv_real.serving_basis = 'per serving'
LEFT JOIN public.nutrition_facts ns
    ON ns.product_id = p.product_id AND ns.serving_id = sv_real.serving_id
LEFT JOIN public.scores s ON s.product_id = p.product_id
LEFT JOIN public.ingredients i ON i.product_id = p.product_id
LEFT JOIN LATERAL (
    SELECT ps_inner.*
    FROM public.product_sources ps_inner
    WHERE ps_inner.product_id = p.product_id AND ps_inner.is_primary = true
    LIMIT 1
) ps ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS ingredient_count,
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
        END AS vegetarian_status,
        (SELECT COUNT(*)::int FROM public.product_allergen pa WHERE pa.product_id = p.product_id) AS allergen_count,
        (SELECT STRING_AGG(pa.allergen_tag, ', ' ORDER BY pa.allergen_tag)
         FROM public.product_allergen pa WHERE pa.product_id = p.product_id) AS allergen_tags,
        (SELECT COUNT(*)::int FROM public.product_trace pt WHERE pt.product_id = p.product_id) AS trace_count,
        (SELECT STRING_AGG(pt.trace_tag, ', ' ORDER BY pt.trace_tag)
         FROM public.product_trace pt WHERE pt.product_id = p.product_id) AS trace_tags
    FROM public.product_ingredient pi
    JOIN public.ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
) ingr ON true
WHERE p.is_deprecated IS NOT TRUE;

COMMIT;

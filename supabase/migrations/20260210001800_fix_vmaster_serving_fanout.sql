-- Migration: Fix v_master fan-out after adding real serving sizes
-- Problem: v_master joined servings without filtering on serving_basis,
--          producing 877 rows (560 per-100g + 317 per-serving) instead of 560.
-- Solution: Filter to per-100g for canonical nutrition columns,
--           add per-serving columns via separate LEFT JOIN.

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
    p.is_deprecated,
    p.deprecated_reason,
    -- Nutrition (per 100 g basis — canonical reference)
    sv.serving_basis,
    sv.serving_amount_g_ml,
    n.calories,
    n.total_fat_g,
    n.saturated_fat_g,
    n.trans_fat_g,
    n.carbs_g,
    n.sugars_g,
    n.fibre_g,
    n.protein_g,
    n.salt_g,
    -- Per-serving data (NULL when no real serving size found)
    sv_real.serving_amount_g_ml AS serving_qty_g,
    ns.calories       AS per_serving_calories,
    ns.total_fat_g    AS per_serving_total_fat_g,
    ns.saturated_fat_g AS per_serving_saturated_fat_g,
    ns.trans_fat_g    AS per_serving_trans_fat_g,
    ns.carbs_g        AS per_serving_carbs_g,
    ns.sugars_g       AS per_serving_sugars_g,
    ns.fibre_g        AS per_serving_fibre_g,
    ns.protein_g      AS per_serving_protein_g,
    ns.salt_g         AS per_serving_salt_g,
    -- Scores
    s.unhealthiness_score,
    s.nutri_score_label,
    s.processing_risk,
    s.nova_classification,
    s.scoring_version,
    s.scored_at,
    s.data_completeness_pct,
    s.confidence,
    -- Flags
    s.high_salt_flag,
    s.high_sugar_flag,
    s.high_sat_fat_flag,
    s.high_additive_load,
    -- Product metadata
    p.controversies,
    -- Ingredients
    i.ingredients_raw,
    i.additives_count,
    -- Ingredient analytics (from normalized tables)
    ingr_stats.ingredient_count,
    ingr_stats.additive_names,
    ingr_stats.has_palm_oil,
    ingr_stats.vegan_status,
    ingr_stats.vegetarian_status,
    allergen_agg.allergen_count,
    allergen_agg.allergen_tags,
    trace_agg.trace_count,
    trace_agg.trace_tags,
    -- Source provenance
    p.ean,
    src.source_type,
    src.ref AS source_ref,
    src.url AS source_url,
    src.notes AS source_notes
FROM public.products p
LEFT JOIN public.servings sv
    ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
LEFT JOIN public.nutrition_facts n
    ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
LEFT JOIN public.servings sv_real
    ON sv_real.product_id = p.product_id AND sv_real.serving_basis = 'per serving'
LEFT JOIN public.nutrition_facts ns
    ON ns.product_id = p.product_id AND ns.serving_id = sv_real.serving_id
LEFT JOIN public.scores s ON s.product_id = p.product_id
LEFT JOIN public.ingredients i ON i.product_id = p.product_id
LEFT JOIN public.sources src ON src.category = p.category
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
        END AS vegetarian_status
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
    GROUP BY pi.product_id
) ingr_stats ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS allergen_count,
        STRING_AGG(allergen_tag, ', ' ORDER BY allergen_tag) AS allergen_tags
    FROM product_allergen pa
    WHERE pa.product_id = p.product_id
    GROUP BY pa.product_id
) allergen_agg ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS trace_count,
        STRING_AGG(trace_tag, ', ' ORDER BY trace_tag) AS trace_tags
    FROM product_trace pt
    WHERE pt.product_id = p.product_id
    GROUP BY pt.product_id
) trace_agg ON true
WHERE p.is_deprecated IS NOT TRUE;

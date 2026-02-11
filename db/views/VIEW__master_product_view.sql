-- VIEW: master product view (v_master)
-- Flat denormalized view joining products → servings → nutrition_facts → scores → product_sources
-- plus ingredient analytics from normalized ingredient tables.
-- This view is already created in the schema migration (20260207000100_create_schema.sql).
-- Updated in migration 20260207000400_remove_unused_columns.sql.
-- Updated 2026-02-08: added EAN, source provenance fields.
-- Updated 2026-02-10: sources join changed from LIKE pattern to equijoin on sources.category.
-- Updated 2026-02-10: added ingredient analytics (ingredient_count, additive_names,
--   has_palm_oil, vegan_status, vegetarian_status, allergen_count/tags, trace_count/tags).
-- Updated 2026-02-10: filtered to per-100g basis only (prevents fan-out from real serving rows).
-- Updated 2026-02-10: added per-serving columns (serving_qty_g, per_serving_calories, etc.).
-- Updated 2026-02-10: added ingredient_data_quality indicator (complete/partial/missing).
-- Updated 2026-02-10: added nutrition_data_quality indicator (clean/suspect).
-- Updated 2026-02-10: migrated provenance from category-level sources to product-level
--   product_sources via LATERAL join. Added source_ean, source_confidence, source_fields,
--   source_collected_at. Removed source_ref. Added score_breakdown (JSONB).
--   63 columns total.
-- This file exists for reference and for recreating the view if needed.
--
-- Usage: SELECT * FROM v_master WHERE country = 'PL' AND category = 'Chips';

CREATE OR REPLACE VIEW public.v_master AS
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
    s.confidence,
    s.data_completeness_pct,
    s.nutri_score_label,
    s.nova_classification,
    CASE s.nova_classification
        WHEN '4' THEN 'High'
        WHEN '3' THEN 'Moderate'
        WHEN '2' THEN 'Low'
        WHEN '1' THEN 'Low'
        ELSE 'Unknown'
    END AS processing_risk,
    s.high_salt_flag,
    s.high_sugar_flag,
    s.high_sat_fat_flag,
    s.high_additive_load,
    s.ingredient_concern_score,

    -- Score explainability (JSONB breakdown of all 9 factors)
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, i.additives_count, p.prep_method, p.controversies,
        s.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients
    i.additives_count,
    i.ingredients_raw,

    -- Product-level provenance (LATERAL join to product_sources)
    p.ean,
    ps.source_type,
    ps.source_url,
    ps.source_ean,
    ps.confidence_pct    AS source_confidence,
    ps.fields_populated  AS source_fields,
    ps.collected_at      AS source_collected_at,
    ps.notes             AS source_notes,

    -- Ingredient analytics (LATERAL subquery)
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

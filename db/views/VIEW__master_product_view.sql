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
--   source_collected_at. Removed source_ref. 66 columns total.
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
    s.ingredient_concern_score,
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
    -- Product-level provenance (replaces category-level source join)
    p.ean,
    ps.source_type,
    ps.source_url,
    ps.source_ean,
    ps.confidence_pct    AS source_confidence,
    ps.fields_populated  AS source_fields,
    ps.collected_at      AS source_collected_at,
    ps.notes             AS source_notes,
    -- Ingredient data quality indicator
    CASE
        WHEN ingr_stats.ingredient_count > 0 THEN 'complete'
        WHEN i.ingredients_raw IS NOT NULL AND length(i.ingredients_raw) > 5 THEN 'partial'
        ELSE 'missing'
    END AS ingredient_data_quality,
    -- Nutrition data quality indicator
    CASE
        WHEN (n.saturated_fat_g = 0 AND n.total_fat_g > 10)
          OR (n.sugars_g = 0 AND n.carbs_g > 20)
          OR (n.salt_g > 10)
          OR (n.calories < 10 AND p.category NOT IN ('Drinks', 'Alcohol'))
          OR (n.salt_g = 0 AND p.category IN (
               'Chips', 'Instant & Frozen', 'Meat', 'Snacks',
               'Sauces', 'Condiments', 'Canned Goods', 'Bread',
               'Frozen & Prepared', 'Żabka'))
        THEN 'suspect'
        ELSE 'clean'
    END AS nutrition_data_quality
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

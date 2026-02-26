-- ==========================================================================
-- Migration: 20260311000500_vmaster_store_columns.sql
-- Purpose:   Add store_count + store_names columns to v_master via LATERAL
--            subquery on product_store_availability + store_ref.
--            Deprecate products.store_availability column (comment only).
--            Part of #350 — Store Architecture.
-- Rollback:  Restore previous v_master definition from 20260310000200.
-- ==========================================================================

BEGIN;

-- Add deprecation comment to the old column
COMMENT ON COLUMN public.products.store_availability IS
'DEPRECATED — use product_store_availability junction table instead. '
'Retained for backward compatibility during transition. '
'See issue #350 for migration plan.';

-- ═══════════════════════════════════════════════════════════════════════════
-- Recreate v_master with store columns
-- ═══════════════════════════════════════════════════════════════════════════
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

    -- Score breakdown
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

    -- Allergen/trace (canonical tags from allergen_ref)
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance
    p.source_type,
    p.source_url,
    p.source_ean,

    -- Primary product image
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

    -- Localization
    p.product_name_en,
    p.product_name_en_source,
    p.created_at,
    p.updated_at,
    p.name_translations,

    -- Store availability (structured) — appended at end for CREATE OR REPLACE
    COALESCE(stores_agg.store_count, 0) AS store_count,
    stores_agg.store_names

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
        -- Contradiction detection flags (now using canonical allergen IDs)
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'milk', 'eggs', 'fish', 'crustaceans', 'molluscs'
        )) AS has_animal_allergen,
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'fish', 'crustaceans', 'molluscs'
        )) AS has_meat_fish_allergen
    FROM public.product_allergen_info ai
    WHERE ai.product_id = p.product_id
) agg_ai ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::integer AS store_count,
        STRING_AGG(sr.store_name, ', ' ORDER BY sr.sort_order) AS store_names
    FROM public.product_store_availability psa
    JOIN public.store_ref sr ON sr.store_id = psa.store_id
    WHERE psa.product_id = p.product_id
      AND sr.is_active = true
) stores_agg ON true
WHERE p.is_deprecated IS NOT TRUE;

COMMIT;

-- VIEW: master product view (v_master)
-- Flat denormalized view joining products → servings → nutrition_facts → scores.
-- This view is already created in the schema migration (20260207000100_create_schema.sql).
-- Updated in migration 20260207000400_remove_unused_columns.sql.
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
    -- Nutrition (per serving basis)
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
    i.additives_count
FROM public.products p
LEFT JOIN public.servings sv ON sv.product_id = p.product_id
LEFT JOIN public.nutrition_facts n ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
LEFT JOIN public.scores s ON s.product_id = p.product_id
LEFT JOIN public.ingredients i ON i.product_id = p.product_id;

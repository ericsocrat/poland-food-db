-- Migration: add category column to sources, switch v_master to equijoin
-- Date: 2026-02-10
-- Reason: The sources table used "Multi-brand (CategoryName)" in the brand column,
--         and v_master joined with a LIKE pattern: src.brand LIKE '%(category)%'.
--         This is fragile. Adding an explicit category column enables a clean equijoin.

BEGIN;

-- 1. Add category column
ALTER TABLE sources ADD COLUMN IF NOT EXISTS category text;

-- 2. Backfill from existing brand pattern
UPDATE sources
SET category = SUBSTRING(brand FROM '\(([^)]+)\)')
WHERE category IS NULL;

-- 3. Recreate v_master with equijoin
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
    s.unhealthiness_score,
    s.nutri_score_label,
    s.processing_risk,
    s.nova_classification,
    s.scoring_version,
    s.scored_at,
    s.data_completeness_pct,
    s.confidence,
    s.high_salt_flag,
    s.high_sugar_flag,
    s.high_sat_fat_flag,
    s.high_additive_load,
    p.controversies,
    i.ingredients_raw,
    i.additives_count,
    p.ean,
    src.source_type,
    src.ref AS source_ref,
    src.url AS source_url,
    src.notes AS source_notes
FROM public.products p
LEFT JOIN public.servings sv ON sv.product_id = p.product_id
LEFT JOIN public.nutrition_facts n ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
LEFT JOIN public.scores s ON s.product_id = p.product_id
LEFT JOIN public.ingredients i ON i.product_id = p.product_id
LEFT JOIN public.sources src ON src.category = p.category
WHERE p.is_deprecated IS NOT TRUE;

COMMIT;

-- Migration: sync additives_count from junction table + enhanced v_master view
-- Date: 2026-02-10
-- Depends on: 20260210001300_ingredient_normalization.sql, 20260210001400_populate_ingredient_data.sql

-- 1. Backfill additives_count from product_ingredient junction table
--    (more authoritative than pipeline-sourced values)
UPDATE ingredients i
SET additives_count = sub.cnt
FROM (
  SELECT pi.product_id, COUNT(*) AS cnt
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  WHERE ir.is_additive = true
  GROUP BY pi.product_id
) sub
WHERE i.product_id = sub.product_id
  AND i.additives_count IS DISTINCT FROM sub.cnt;

-- Set to 0 for products with junction data but no additives detected
UPDATE ingredients i
SET additives_count = 0
FROM (
  SELECT DISTINCT pi.product_id
  FROM product_ingredient pi
) has_data
LEFT JOIN (
  SELECT pi.product_id
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  WHERE ir.is_additive = true
  GROUP BY pi.product_id
) has_additives ON has_additives.product_id = has_data.product_id
WHERE has_additives.product_id IS NULL
  AND i.product_id = has_data.product_id
  AND i.additives_count != 0;

-- 2. Re-score products whose additives_count changed
--    Recompute unhealthiness_score using the scoring function
UPDATE scores s
SET unhealthiness_score = compute_unhealthiness_v31(
      n.saturated_fat_g, n.sugars_g, n.salt_g, n.calories, n.trans_fat_g,
      i.additives_count, p.prep_method, p.controversies
    ),
    scored_at = NOW()
FROM products p
JOIN nutrition_facts n ON n.product_id = p.product_id
JOIN ingredients i ON i.product_id = p.product_id
WHERE s.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE
  AND s.unhealthiness_score != compute_unhealthiness_v31(
      n.saturated_fat_g, n.sugars_g, n.salt_g, n.calories, n.trans_fat_g,
      i.additives_count, p.prep_method, p.controversies
    );

-- 3. Re-sync high_additive_load flags after additives_count change
--    Threshold: additives_count >= 5 → YES
UPDATE scores sc
SET high_additive_load = CASE WHEN COALESCE(i.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END
FROM ingredients i
WHERE i.product_id = sc.product_id
  AND (
    (COALESCE(i.additives_count, 0) >= 5 AND sc.high_additive_load <> 'YES')
    OR (COALESCE(i.additives_count, 0) < 5 AND sc.high_additive_load = 'YES')
  );

-- 3. Drop and recreate v_master with ingredient analytics columns
DROP VIEW IF EXISTS public.v_master CASCADE;

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
    -- Ingredient analytics (from normalized ingredient tables)
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
LEFT JOIN public.servings sv ON sv.product_id = p.product_id
LEFT JOIN public.nutrition_facts n ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
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

COMMENT ON VIEW public.v_master IS 'Denormalized master view with nutrition, scores, ingredient analytics, allergens, traces, and source provenance.';

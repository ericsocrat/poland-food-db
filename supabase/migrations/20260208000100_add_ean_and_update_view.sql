-- 20260208000100_add_ean_and_update_view.sql
-- Purpose:
--   1) Add EAN (barcode) column to products table
--   2) Create partial unique index on ean (allows NULL)
--   3) Rebuild v_master view to include ean, sources, and is_deprecated filter

SET search_path = public;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Add EAN column (nullable text — preserves leading zeros)
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS ean TEXT;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Unique index on EAN (conditional — allows multiple NULLs)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE UNIQUE INDEX IF NOT EXISTS products_ean_uniq
  ON public.products (ean)
  WHERE ean IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Rebuild v_master with ean + sources + is_deprecated filter
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
    i.additives_count,
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
LEFT JOIN public.sources src ON (
    src.brand LIKE '%(' || p.category || ')%'
)
WHERE p.is_deprecated IS NOT TRUE;

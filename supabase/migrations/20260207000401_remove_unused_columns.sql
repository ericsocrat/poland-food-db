-- Migration: Remove unused/unnecessary columns
-- Date: 2026-02-07
-- Reason: These columns add complexity without proportional value.
--
-- Dropped columns:
--   scores.healthiness_score         — always 100 - unhealthiness_score; trivially derivable
--   scores.personal_unhealthiness_*  — experimental, never implemented, no pipeline writes them
--   nutrition_facts.cholesterol_mg   — not scored, not in data_completeness, rarely on PL labels
--   nutrition_facts.potassium_mg     — not scored, not in data_completeness, rarely on PL labels
--   products.aluminium_based_additives — orphaned; not referenced in any doc, pipeline, or scoring

-- ── Step 1: Drop the v_master view so column drops don't fail ────────────
DROP VIEW IF EXISTS public.v_master;

-- ── scores table ─────────────────────────────────────────────────────────
ALTER TABLE public.scores
  DROP COLUMN IF EXISTS healthiness_score,
  DROP COLUMN IF EXISTS personal_unhealthiness_balanced,
  DROP COLUMN IF EXISTS personal_unhealthiness_low_salt,
  DROP COLUMN IF EXISTS personal_unhealthiness_low_sugar;

-- ── nutrition_facts table ────────────────────────────────────────────────
ALTER TABLE public.nutrition_facts
  DROP COLUMN IF EXISTS cholesterol_mg,
  DROP COLUMN IF EXISTS potassium_mg;

-- ── products table ───────────────────────────────────────────────────────
ALTER TABLE public.products
  DROP COLUMN IF EXISTS aluminium_based_additives,
  DROP COLUMN IF EXISTS oil_method,
  DROP COLUMN IF EXISTS ingredient_complexity,
  DROP COLUMN IF EXISTS eu_notes;

-- ── Recreate v_master view without dropped columns ───────────────────────
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

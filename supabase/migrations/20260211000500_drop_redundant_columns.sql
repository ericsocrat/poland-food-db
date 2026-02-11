-- Migration: drop redundant columns & stale table
-- Date: 2026-02-11
-- Audit phase: cross-table redundancy cleanup
--
-- Columns dropped:
--   scores.processing_risk    — 1:1 derivable from nova_classification (4→High, 3→Moderate, 1-2→Low)
--   scores.scoring_version    — all 560 rows = 'v3.2'; only one version ever existed
--   scores.scored_at          — pipeline timestamp; not meaningful data
--   product_allergen.source   — all 728 rows = 'off'; never queried
--   product_trace.source      — all 782 rows = 'off'; never queried
--
-- Table dropped:
--   column_metadata           — 49-row data dictionary; never queried by any function/view/QA;
--                               still references deleted 'sources' table; drifting out of sync
--
-- View changes:
--   v_master                  — processing_risk derived via CASE; scoring_version/scored_at removed
--
-- Function changes:
--   None — API functions read processing_risk from v_master, which still provides it
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 0: Drop v_master (it references columns we're about to drop)
-- We must DROP (not CREATE OR REPLACE) because we're removing columns.
-- ─────────────────────────────────────────────────────────────────────────

DROP VIEW IF EXISTS public.v_master;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 1: Drop unused source columns from allergen/trace tables
-- ─────────────────────────────────────────────────────────────────────────

ALTER TABLE product_allergen DROP COLUMN IF EXISTS source;
ALTER TABLE product_trace    DROP COLUMN IF EXISTS source;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 2: Drop redundant scores columns
-- processing_risk is now derived in v_master from nova_classification
-- ─────────────────────────────────────────────────────────────────────────

ALTER TABLE scores DROP COLUMN IF EXISTS processing_risk;
ALTER TABLE scores DROP COLUMN IF EXISTS scoring_version;
ALTER TABLE scores DROP COLUMN IF EXISTS scored_at;

-- Drop the CHECK constraint on processing_risk if it exists
ALTER TABLE scores DROP CONSTRAINT IF EXISTS chk_scores_processing_risk;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 3: Drop column_metadata table
-- ─────────────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS column_metadata;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 4: Recreate v_master with processing_risk derived from CASE
-- ─────────────────────────────────────────────────────────────────────────

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
    nf.calories,
    nf.total_fat_g,
    nf.saturated_fat_g,
    nf.trans_fat_g,
    nf.carbs_g,
    nf.sugars_g,
    nf.fibre_g,
    nf.protein_g,
    nf.salt_g,
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
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, i.additives_count, p.prep_method, p.controversies,
        s.ingredient_concern_score
    ) AS score_breakdown,
    i.additives_count,
    i.ingredients_raw,
    p.ean,
    ps.source_type,
    ps.source_url,
    ps.source_ean,
    ps.confidence_pct    AS source_confidence,
    ps.fields_populated  AS source_fields,
    ps.collected_at      AS source_collected_at,
    ps.notes             AS source_notes,
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,
    ingr.vegan_status,
    ingr.vegetarian_status,
    ingr.allergen_count,
    ingr.allergen_tags,
    ingr.trace_count,
    ingr.trace_tags,
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

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 5: Verification
-- ─────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  v_scores_cols    int;
  v_allergen_cols  int;
  v_trace_cols     int;
  v_metadata_exists boolean;
BEGIN
  SELECT count(*) INTO v_scores_cols
  FROM   information_schema.columns
  WHERE  table_name = 'scores' AND table_schema = 'public';

  SELECT count(*) INTO v_allergen_cols
  FROM   information_schema.columns
  WHERE  table_name = 'product_allergen' AND table_schema = 'public';

  SELECT count(*) INTO v_trace_cols
  FROM   information_schema.columns
  WHERE  table_name = 'product_trace' AND table_schema = 'public';

  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'column_metadata' AND table_schema = 'public'
  ) INTO v_metadata_exists;

  RAISE NOTICE '── redundancy cleanup verification ──';
  RAISE NOTICE 'scores columns       : % (expected 11, was 14)', v_scores_cols;
  RAISE NOTICE 'product_allergen cols: % (expected 2, was 3)', v_allergen_cols;
  RAISE NOTICE 'product_trace cols   : % (expected 2, was 3)', v_trace_cols;
  RAISE NOTICE 'column_metadata exists: % (expected false)', v_metadata_exists;

  IF v_scores_cols != 11 THEN
    RAISE EXCEPTION 'FAIL: scores has % columns, expected 11', v_scores_cols;
  END IF;
  IF v_allergen_cols != 2 THEN
    RAISE EXCEPTION 'FAIL: product_allergen has % columns, expected 2', v_allergen_cols;
  END IF;
  IF v_trace_cols != 2 THEN
    RAISE EXCEPTION 'FAIL: product_trace has % columns, expected 2', v_trace_cols;
  END IF;
  IF v_metadata_exists THEN
    RAISE EXCEPTION 'FAIL: column_metadata table still exists';
  END IF;
END $$;

COMMIT;

-- Migration: Drop redundant ingredients table
-- Phase 4 of data-integrity audit.
--
-- The ingredients table (product_id, ingredients_raw, additives_count) is fully
-- redundant with the normalized junction tables (product_ingredient + ingredient_ref):
--   - ingredients_raw  → STRING_AGG(ir.name_en, ', ' ORDER BY pi.position)
--   - additives_count  → COUNT(*) FILTER (WHERE ir.is_additive)
-- Verified: 0 mismatches across all 560 rows.
--
-- Changes:
--   1. Drop the ingredients table (CASCADE drops dependent views)
--   2. Rebuild v_master — derive additives_count & ingredients_text from LATERAL ingr
--   3. Rebuild v_product_confidence — replace ingredients_raw check with junction EXISTS
--   4. Verification block

BEGIN;

-- ─── 1. Drop ingredients table ───────────────────────────────────────────
-- Must drop dependent objects first.
DROP VIEW IF EXISTS public.v_master CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.v_product_confidence CASCADE;
DROP TABLE IF EXISTS public.ingredients CASCADE;


-- ─── 2. Rebuild v_master ─────────────────────────────────────────────────
-- additives_count and ingredients_raw are now derived from the existing
-- LATERAL ingr subquery (product_ingredient + ingredient_ref).

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
        nf.trans_fat_g, ingr.additives_count, p.prep_method, p.controversies,
        s.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients (derived from junction tables)
    ingr.additives_count,
    ingr.ingredients_text AS ingredients_raw,

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
LEFT JOIN LATERAL (
    SELECT ps_inner.*
    FROM public.product_sources ps_inner
    WHERE ps_inner.product_id = p.product_id AND ps_inner.is_primary = true
    LIMIT 1
) ps ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS ingredient_count,
        COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count,
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


-- ─── 3. Rebuild v_product_confidence ─────────────────────────────────────
-- Replace ingredients_raw check (15 pts) + junction check (10 pts)
-- with a single junction EXISTS check (25 pts).  Total budget unchanged.

CREATE MATERIALIZED VIEW public.v_product_confidence AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    p.category,

    -- Nutrition completeness (0-30)
    (
        (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END)
    ) AS nutrition_pts,

    -- Ingredient completeness (0-25)
    (CASE WHEN EXISTS (
        SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
    ) THEN 25 ELSE 0 END) AS ingredient_pts,

    -- Source confidence (0-20)
    COALESCE(
        (SELECT ROUND(ps.confidence_pct * 0.2)::int
         FROM product_sources ps
         WHERE ps.product_id = p.product_id AND ps.is_primary = true
         LIMIT 1),
        0
    ) AS source_pts,

    -- EAN (0-10)
    (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) AS ean_pts,

    -- Allergens (0-10)
    (CASE WHEN EXISTS (
        SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id
    ) THEN 10 ELSE 0 END) AS allergen_pts,

    -- Per-serving (0-5)
    (CASE WHEN EXISTS (
        SELECT 1 FROM servings sv2
        WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving'
    ) THEN 5 ELSE 0 END) AS serving_pts,

    -- Total confidence score (capped at 100)
    LEAST(
        (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END) +
        COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
        (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END),
        100
    ) AS confidence_score,

    -- Confidence band
    CASE
        WHEN LEAST(
            (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END),
            100
        ) >= 80 THEN 'high'
        WHEN LEAST(
            (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 25 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END),
            100
        ) >= 50 THEN 'medium'
        ELSE 'low'
    END AS confidence_band,

    -- Completeness profile
    CASE
        WHEN EXISTS (
            SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
        ) THEN 'complete'
        ELSE 'missing'
    END AS ingredient_status,

    CASE
        WHEN nf.calories IS NOT NULL AND nf.total_fat_g IS NOT NULL
             AND nf.saturated_fat_g IS NOT NULL AND nf.carbs_g IS NOT NULL
             AND nf.sugars_g IS NOT NULL AND nf.salt_g IS NOT NULL
        THEN 'full'
        WHEN nf.calories IS NOT NULL AND nf.total_fat_g IS NOT NULL
        THEN 'partial'
        ELSE 'missing'
    END AS nutrition_status,

    CASE
        WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id)
        THEN 'known' ELSE 'unknown'
    END AS allergen_status

FROM products p
LEFT JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE p.is_deprecated IS NOT TRUE
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_confidence_id
    ON v_product_confidence (product_id);
CREATE INDEX IF NOT EXISTS idx_product_confidence_band
    ON v_product_confidence (confidence_band, confidence_score DESC);

COMMENT ON MATERIALIZED VIEW v_product_confidence IS
    'Pre-computed data confidence scores for all active products. '
    'Confidence formula: nutrition(0-30) + ingredients(0-25) + source(0-20) '
    '+ EAN(0-10) + allergens(0-10) + serving(0-5) = 0-100. '
    'Bands: high(>=80), medium(50-79), low(<50). Refresh after data changes.';


-- ─── 4. Verification ─────────────────────────────────────────────────────
DO $$
DECLARE
    tbl_exists boolean;
    v_count int;
    conf_count int;
    ingr_col_exists boolean;
BEGIN
    -- ingredients table must be gone
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'ingredients'
    ) INTO tbl_exists;
    IF tbl_exists THEN
        RAISE EXCEPTION 'ingredients table still exists';
    END IF;

    -- v_master must exist and have rows (relaxed for fresh replay)
    SELECT count(*) INTO v_count FROM v_master;
    IF v_count = 0 THEN
        RAISE NOTICE 'v_master is empty after rebuild (non-fatal on fresh replay)';
    END IF;

    -- v_master must still expose additives_count and ingredients_raw columns
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'v_master'
          AND column_name = 'additives_count'
    ) INTO ingr_col_exists;
    IF NOT ingr_col_exists THEN
        RAISE EXCEPTION 'v_master missing additives_count column';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'v_master'
          AND column_name = 'ingredients_raw'
    ) INTO ingr_col_exists;
    IF NOT ingr_col_exists THEN
        RAISE EXCEPTION 'v_master missing ingredients_raw column';
    END IF;

    -- v_product_confidence must have data (relaxed for fresh replay)
    SELECT count(*) INTO conf_count FROM v_product_confidence;
    IF conf_count = 0 THEN
        RAISE NOTICE 'v_product_confidence is empty after rebuild (non-fatal on fresh replay)';
    END IF;

    RAISE NOTICE '✓ ingredients table dropped';
    RAISE NOTICE '✓ v_master rebuilt — % rows, additives_count & ingredients_raw present', v_count;
    RAISE NOTICE '✓ v_product_confidence rebuilt — % rows', conf_count;
END $$;

COMMIT;

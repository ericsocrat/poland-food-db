-- ============================================================
-- Migration: Allergen tag normalization
-- Issue: #351 — Allergen normalization
-- Phase 2: Normalize tags, add FK to allergen_ref, update views
--
-- This migration:
-- 1. Adds source_tag column for traceability
-- 2. Drops the en: prefix CHECK constraint
-- 3. Normalizes all tags (strip en:, merge sub-allergens)
-- 4. Deduplicates after merging
-- 5. Adds FK to allergen_ref
-- 6. Migrates user_preferences.avoid_allergens
-- 7. Recreates v_master with canonical tags
--
-- To rollback (destructive — source_tag preserves originals):
--   See source_tag column for original values
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Add source_tag column for traceability
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.product_allergen_info
    ADD COLUMN IF NOT EXISTS source_tag text;

COMMENT ON COLUMN public.product_allergen_info.source_tag
    IS 'Original tag value before normalization (e.g., en:milk, en:pszenny). Preserved for traceability.';

-- Copy current tag → source_tag (only for rows without source_tag already set)
UPDATE public.product_allergen_info
SET source_tag = tag
WHERE source_tag IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Drop the en: prefix CHECK constraint
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.product_allergen_info
    DROP CONSTRAINT IF EXISTS chk_allergen_tag_en_prefix;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Normalize tags
--    Order matters: merge sub-allergens FIRST, then strip en: prefix
-- ═══════════════════════════════════════════════════════════════════════════

-- 3a. Delete sub-allergen rows that would duplicate their parent after merge
--     (e.g., product has both en:wheat AND en:gluten → delete the en:wheat row)
DELETE FROM public.product_allergen_info sub
WHERE sub.tag IN ('en:wheat', 'en:oats', 'en:barley', 'en:rye', 'en:spelt', 'en:kamut')
  AND EXISTS (
      SELECT 1 FROM public.product_allergen_info parent
      WHERE parent.product_id = sub.product_id
        AND parent.type = sub.type
        AND parent.tag = 'en:gluten'
  );

DELETE FROM public.product_allergen_info sub
WHERE sub.tag IN ('en:almonds', 'en:hazelnuts', 'en:walnuts',
                   'en:cashew-nuts', 'en:pistachio-nuts', 'en:pecan-nuts',
                   'en:brazil-nuts', 'en:macadamia-nuts')
  AND EXISTS (
      SELECT 1 FROM public.product_allergen_info parent
      WHERE parent.product_id = sub.product_id
        AND parent.type = sub.type
        AND parent.tag = 'en:nuts'
  );

-- 3b. Merge remaining gluten sub-allergens → en:gluten
UPDATE public.product_allergen_info
SET tag = 'en:gluten'
WHERE tag IN ('en:wheat', 'en:oats', 'en:barley', 'en:rye', 'en:spelt', 'en:kamut');

-- 3c. Merge remaining tree-nut sub-allergens + en:nuts → en:tree-nuts
--     First rename en:nuts → en:tree-nuts (canonical EU name)
UPDATE public.product_allergen_info
SET tag = 'en:tree-nuts'
WHERE tag = 'en:nuts';

--     Then merge nut sub-types (that weren't deleted as duplicates)
UPDATE public.product_allergen_info
SET tag = 'en:tree-nuts'
WHERE tag IN ('en:almonds', 'en:hazelnuts', 'en:walnuts',
              'en:cashew-nuts', 'en:pistachio-nuts', 'en:pecan-nuts',
              'en:brazil-nuts', 'en:macadamia-nuts');

-- 3d. Rename verbose tags
UPDATE public.product_allergen_info
SET tag = 'en:sesame'
WHERE tag = 'en:sesame-seeds';

UPDATE public.product_allergen_info
SET tag = 'en:sulphites'
WHERE tag = 'en:sulphur-dioxide-and-sulphites';

-- 3e. Strip en: prefix from all remaining tags
UPDATE public.product_allergen_info
SET tag = REPLACE(tag, 'en:', '')
WHERE tag LIKE 'en:%';

-- 3f. Final deduplication (safety net for any edge cases)
DELETE FROM public.product_allergen_info
WHERE ctid IN (
    SELECT ctid FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY product_id, tag, type
                   ORDER BY ctid
               ) AS rn
        FROM public.product_allergen_info
    ) ranked
    WHERE rn > 1
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Add FK to allergen_ref
-- ═══════════════════════════════════════════════════════════════════════════
-- First verify all tags exist in allergen_ref (should be 14 canonical IDs)
DO $$
DECLARE
    v_bad_count integer;
BEGIN
    SELECT COUNT(*) INTO v_bad_count
    FROM (SELECT DISTINCT tag FROM public.product_allergen_info) t
    WHERE NOT EXISTS (
        SELECT 1 FROM public.allergen_ref ar WHERE ar.allergen_id = t.tag
    );
    IF v_bad_count > 0 THEN
        RAISE WARNING 'Found % distinct tags not in allergen_ref — check normalization', v_bad_count;
    END IF;
END $$;

ALTER TABLE public.product_allergen_info
    DROP CONSTRAINT IF EXISTS fk_allergen_tag_ref;

ALTER TABLE public.product_allergen_info
    ADD CONSTRAINT fk_allergen_tag_ref
    FOREIGN KEY (tag) REFERENCES public.allergen_ref(allergen_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Migrate user_preferences.avoid_allergens
--    Strip en: prefix and normalize to canonical IDs
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE public.user_preferences
SET avoid_allergens = (
    SELECT ARRAY(
        SELECT DISTINCT
            CASE
                -- Merge sub-allergens
                WHEN unnested IN ('en:wheat','en:oats','en:barley','en:rye','en:spelt','en:kamut')
                    THEN 'gluten'
                WHEN unnested IN ('en:nuts','en:almonds','en:hazelnuts','en:walnuts',
                                  'en:cashew-nuts','en:pistachio-nuts','en:pecan-nuts',
                                  'en:brazil-nuts','en:macadamia-nuts')
                    THEN 'tree-nuts'
                WHEN unnested = 'en:sesame-seeds' THEN 'sesame'
                WHEN unnested = 'en:sulphur-dioxide-and-sulphites' THEN 'sulphites'
                -- Strip en: prefix
                WHEN unnested LIKE 'en:%' THEN REPLACE(unnested, 'en:', '')
                -- Already canonical
                ELSE unnested
            END
        FROM unnest(avoid_allergens) AS unnested
    )
)
WHERE avoid_allergens IS NOT NULL
  AND array_length(avoid_allergens, 1) > 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Recreate v_master with canonical (bare) allergen tags
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
    p.name_translations

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
WHERE p.is_deprecated IS NOT TRUE;

COMMIT;

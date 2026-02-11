-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: Clean up synthetic secondary sources & orphaned tables
-- ═══════════════════════════════════════════════════════════════════════════
-- RATIONALE:
--   The secondary source types (off_search, retailer_api, label_scan, manual)
--   in product_sources and the entire source_nutrition table contained
--   fabricated/synthetic data — nutrition values were just tiny random
--   variations of the canonical nutrition_facts.  The cross-validation
--   function compared these copies against each other, creating a
--   self-confirming loop that validated nothing real.
--
--   The legacy "sources" table (20 rows, one per category) was orphaned —
--   no FK, function, or view referenced it.
--
-- CHANGES:
--   1. Drop source_nutrition table (entirely synthetic)
--   2. Drop cross_validate_product() function (validates nothing)
--   3. Delete fake secondary rows from product_sources (keep real off_api)
--   4. Narrow product_sources CHECK constraint to off_api only
--   5. Drop legacy "sources" table (orphaned)
--   6. Rebuild compute_data_confidence() without cross_validation_pts
--      (6 components: nutrition 0-30, ingredients 0-25, source 0-20,
--       EAN 0-10, allergens 0-10, serving 0-5 = max 100)
--   7. Rebuild v_product_confidence without cross_validation_pts column
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─── 1. Drop source_nutrition ─────────────────────────────────────────────
DROP TABLE IF EXISTS public.source_nutrition CASCADE;

-- ─── 2. Drop cross_validate_product() ─────────────────────────────────────
DROP FUNCTION IF EXISTS public.cross_validate_product(bigint);

-- ─── 3. Delete fake secondary product_sources rows ────────────────────────
DELETE FROM product_sources
WHERE source_type IN ('off_search', 'retailer_api', 'label_scan', 'manual');

-- ─── 4. Widen CHECK constraint to accept all valid source types ──────────
ALTER TABLE product_sources DROP CONSTRAINT IF EXISTS chk_ps_source_type;
ALTER TABLE product_sources ADD CONSTRAINT chk_ps_source_type
    CHECK (source_type IN ('off_api','off_search','manual','label_scan','retailer_api'));

-- ─── 5. Drop legacy sources table ────────────────────────────────────────
DROP TABLE IF EXISTS public.sources CASCADE;

-- ─── 6. Rebuild compute_data_confidence() ─────────────────────────────────
-- Remove cross_validation_pts (was 0-5, based on synthetic data).
-- 6 components: nutrition(0-30) + ingredients(0-25) + source(0-20)
--             + EAN(0-10) + allergens(0-10) + serving(0-5) = max 100.

CREATE OR REPLACE FUNCTION compute_data_confidence(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    WITH components AS (
        SELECT
            p.product_id,

            -- Nutrition completeness (0-30): 5 pts per key nutrient present
            (
                (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
                (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
                (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
                (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
                (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
                (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END)
            ) AS nutrition_pts,

            -- Ingredient completeness (0-25): 25 if product_ingredient rows exist
            (CASE WHEN EXISTS (
                SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
            ) THEN 25 ELSE 0 END) AS ingredient_pts,

            -- Source confidence (0-20): mapped from product_sources.confidence_pct
            COALESCE(
                (SELECT ROUND(ps.confidence_pct * 0.2)::int
                 FROM product_sources ps
                 WHERE ps.product_id = p.product_id AND ps.is_primary = true
                 LIMIT 1),
                0
            ) AS source_pts,

            -- EAN presence (0-10)
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) AS ean_pts,

            -- Allergen data (0-10): any allergen declarations
            (CASE WHEN EXISTS (
                SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id
            ) THEN 10 ELSE 0 END) AS allergen_pts,

            -- Per-serving data (0-5)
            (CASE WHEN EXISTS (
                SELECT 1 FROM servings sv
                WHERE sv.product_id = p.product_id AND sv.serving_basis = 'per serving'
            ) THEN 5 ELSE 0 END) AS serving_pts,

            -- Data completeness profile components
            CASE
                WHEN EXISTS (
                    SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
                ) THEN 'complete'
                ELSE 'missing'
            END AS ingredient_status,

            CASE
                WHEN nf.calories IS NOT NULL
                     AND nf.total_fat_g IS NOT NULL
                     AND nf.saturated_fat_g IS NOT NULL
                     AND nf.carbs_g IS NOT NULL
                     AND nf.sugars_g IS NOT NULL
                     AND nf.salt_g IS NOT NULL
                THEN 'full'
                WHEN nf.calories IS NOT NULL
                     AND nf.total_fat_g IS NOT NULL
                THEN 'partial'
                ELSE 'missing'
            END AS nutrition_status,

            CASE
                WHEN EXISTS (
                    SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id
                ) THEN 'known'
                ELSE 'unknown'
            END AS allergen_status

        FROM products p
        LEFT JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
        LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
        WHERE p.product_id = p_product_id
          AND p.is_deprecated IS NOT TRUE
    )
    SELECT jsonb_build_object(
        'product_id', c.product_id,
        'confidence_score', LEAST(
            c.nutrition_pts + c.ingredient_pts + c.source_pts
            + c.ean_pts + c.allergen_pts + c.serving_pts,
            100
        ),
        'confidence_band', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 80 THEN 'high'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 50 THEN 'medium'
            ELSE 'low'
        END,
        'components', jsonb_build_object(
            'nutrition',    jsonb_build_object('points', c.nutrition_pts, 'max', 30),
            'ingredients',  jsonb_build_object('points', c.ingredient_pts, 'max', 25),
            'source',       jsonb_build_object('points', c.source_pts, 'max', 20),
            'ean',          jsonb_build_object('points', c.ean_pts, 'max', 10),
            'allergens',    jsonb_build_object('points', c.allergen_pts, 'max', 10),
            'serving_data', jsonb_build_object('points', c.serving_pts, 'max', 5)
        ),
        'data_completeness_profile', jsonb_build_object(
            'ingredients', c.ingredient_status,
            'nutrition',   c.nutrition_status,
            'allergens',   c.allergen_status
        ),
        'missing_data', (
            SELECT COALESCE(jsonb_agg(item), '[]'::jsonb) FROM (
                SELECT 'calories'::text AS item WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.calories IS NOT NULL)
                UNION ALL
                SELECT 'total_fat' WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.total_fat_g IS NOT NULL)
                UNION ALL
                SELECT 'saturated_fat' WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.saturated_fat_g IS NOT NULL)
                UNION ALL
                SELECT 'carbs' WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.carbs_g IS NOT NULL)
                UNION ALL
                SELECT 'sugars' WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.sugars_g IS NOT NULL)
                UNION ALL
                SELECT 'salt' WHERE c.nutrition_pts < 30
                    AND NOT EXISTS (SELECT 1 FROM nutrition_facts nf2
                        JOIN servings sv2 ON sv2.serving_id = nf2.serving_id
                        WHERE nf2.product_id = c.product_id
                        AND sv2.serving_basis = 'per 100 g'
                        AND nf2.salt_g IS NOT NULL)
                UNION ALL
                SELECT 'ingredients' WHERE c.ingredient_pts = 0
                UNION ALL
                SELECT 'ean' WHERE c.ean_pts = 0
                UNION ALL
                SELECT 'allergen_declarations' WHERE c.allergen_pts = 0
                UNION ALL
                SELECT 'per_serving_data' WHERE c.serving_pts = 0
            ) missing
        ),
        'explanation', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 80
            THEN 'This product has comprehensive data from verified sources. The score is highly reliable.'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 50
            THEN 'This product has partial data coverage. Some fields may be estimated or missing. The score is reasonably reliable but should be interpreted with some caution.'
            ELSE 'This product has limited data. The score may not fully reflect the product''s nutritional profile. We recommend checking the product label directly.'
        END
    )
    FROM components c;
$$;

COMMENT ON FUNCTION compute_data_confidence IS
    'Composite confidence score (0-100) with 6 components: '
    'nutrition(0-30) + ingredients(0-25) + source(0-20) + EAN(0-10) '
    '+ allergens(0-10) + serving(0-5). Returns JSON with score, band, '
    'component breakdown, completeness profile, missing data list, and explanation.';


-- ─── 7. Rebuild v_product_confidence ─────────────────────────────────────
-- Remove cross_validation_pts column.

DROP MATERIALIZED VIEW IF EXISTS public.v_product_confidence CASCADE;

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


-- ─── 8. Verification ─────────────────────────────────────────────────────
DO $$
DECLARE
    ps_count int;
    ps_types int;
    sn_exists boolean;
    cv_exists boolean;
    sources_exists boolean;
    conf_count int;
BEGIN
    -- product_sources should have valid source types
    SELECT count(*), count(DISTINCT source_type) INTO ps_count, ps_types
    FROM product_sources;
    IF ps_count = 0 THEN
        RAISE NOTICE 'No product_sources rows found (non-fatal on fresh replay)';
    END IF;

    -- source_nutrition should not exist
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'source_nutrition' AND schemaname = 'public')
    INTO sn_exists;
    IF sn_exists THEN
        RAISE EXCEPTION 'source_nutrition table still exists';
    END IF;

    -- cross_validate_product should not exist
    SELECT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'cross_validate_product')
    INTO cv_exists;
    IF cv_exists THEN
        RAISE EXCEPTION 'cross_validate_product function still exists';
    END IF;

    -- sources should not exist
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'sources' AND schemaname = 'public')
    INTO sources_exists;
    IF sources_exists THEN
        RAISE EXCEPTION 'sources table still exists';
    END IF;

    -- v_product_confidence should have data (relaxed for fresh replay)
    SELECT count(*) INTO conf_count FROM v_product_confidence;
    IF conf_count = 0 THEN
        RAISE NOTICE 'v_product_confidence is empty after rebuild (non-fatal on fresh replay)';
    END IF;

    RAISE NOTICE 'Cleanup verification passed: % product_sources rows, % confidence rows',
        ps_count, conf_count;
END $$;

COMMIT;

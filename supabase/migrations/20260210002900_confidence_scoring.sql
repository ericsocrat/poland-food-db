-- Migration: Confidence & Completeness Scoring (Phase 7 — Trust Layer)
-- Date: 2026-02-10
-- Purpose: Create a composite data confidence score (0-100) that lets users
--          understand how reliable the data is. Also creates a data completeness
--          profile (JSON) and exposes via an API function.
--
-- Formula:
--   nutrition_completeness  (0-30): 5 pts each for 6 key nutrients
--   ingredient_completeness (0-25): 15 if ingredients_raw present + 10 if normalized
--   source_confidence       (0-20): mapped from product_sources.confidence_pct
--   ean_presence             (0-10): 10 if EAN exists
--   allergen_data            (0-10): 10 if allergen declarations exist
--   serving_data             (0-5):  5 if real per-serving data exists
--   ────────────────────────────────
--   Total: 0-100
--
-- Bands:
--   High   (≥80): Comprehensive data from verified sources
--   Medium (50-79): Partial data — some fields may be estimated
--   Low    (<50): Limited data — score should be treated with caution

BEGIN;

-- ============================================================
-- 1. compute_data_confidence() — Composite confidence function
-- ============================================================

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

            -- Ingredient completeness (0-25): 15 if raw text, +10 if normalized
            (
                (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
                (CASE WHEN EXISTS (
                    SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
                ) THEN 10 ELSE 0 END)
            ) AS ingredient_pts,

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
                WHEN i.ingredients_raw IS NOT NULL AND EXISTS (
                    SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
                ) THEN 'complete'
                WHEN i.ingredients_raw IS NOT NULL THEN 'partial'
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
        LEFT JOIN ingredients i ON i.product_id = p.product_id
        WHERE p.product_id = p_product_id
          AND p.is_deprecated IS NOT TRUE
    )
    SELECT jsonb_build_object(
        'product_id', c.product_id,
        'confidence_score', c.nutrition_pts + c.ingredient_pts + c.source_pts
                            + c.ean_pts + c.allergen_pts + c.serving_pts,
        'confidence_band', CASE
            WHEN (c.nutrition_pts + c.ingredient_pts + c.source_pts
                  + c.ean_pts + c.allergen_pts + c.serving_pts) >= 80 THEN 'high'
            WHEN (c.nutrition_pts + c.ingredient_pts + c.source_pts
                  + c.ean_pts + c.allergen_pts + c.serving_pts) >= 50 THEN 'medium'
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
                SELECT 'ingredients_raw' WHERE c.ingredient_pts < 15
                UNION ALL
                SELECT 'normalized_ingredients' WHERE c.ingredient_pts >= 15 AND c.ingredient_pts < 25
                UNION ALL
                SELECT 'ean' WHERE c.ean_pts = 0
                UNION ALL
                SELECT 'allergen_declarations' WHERE c.allergen_pts = 0
                UNION ALL
                SELECT 'per_serving_data' WHERE c.serving_pts = 0
            ) missing
        ),
        'explanation', CASE
            WHEN (c.nutrition_pts + c.ingredient_pts + c.source_pts
                  + c.ean_pts + c.allergen_pts + c.serving_pts) >= 80
            THEN 'This product has comprehensive data from verified sources. The score is highly reliable.'
            WHEN (c.nutrition_pts + c.ingredient_pts + c.source_pts
                  + c.ean_pts + c.allergen_pts + c.serving_pts) >= 50
            THEN 'This product has partial data coverage. Some fields may be estimated or missing. The score is reasonably reliable but should be interpreted with some caution.'
            ELSE 'This product has limited data. The score may not fully reflect the product''s nutritional profile. We recommend checking the product label directly.'
        END
    )
    FROM components c;
$$;

COMMENT ON FUNCTION compute_data_confidence IS
    'Computes a composite data confidence score (0-100) for a product. '
    'Components: nutrition (0-30), ingredients (0-25), source (0-20), EAN (0-10), allergens (0-10), serving (0-5). '
    'Returns JSONB with confidence_score, confidence_band (high/medium/low), component breakdown, '
    'data_completeness_profile, missing_data list, and human-readable explanation.';


-- ============================================================
-- 2. api_data_confidence() — Batch confidence for API use
-- ============================================================
-- Returns confidence data for a single product (or use the bulk view below).

CREATE OR REPLACE FUNCTION api_data_confidence(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT compute_data_confidence(p_product_id);
$$;

COMMENT ON FUNCTION api_data_confidence IS
    'API wrapper for compute_data_confidence(). Returns structured JSONB with '
    'confidence score, band, components, completeness profile, and missing data list.';


-- ============================================================
-- 3. v_product_confidence — Confidence scores for all products
-- ============================================================
-- Materialized for performance (recomputing for 560 products is expensive via function).

CREATE MATERIALIZED VIEW IF NOT EXISTS public.v_product_confidence AS
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
    (
        (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
        (CASE WHEN EXISTS (
            SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
        ) THEN 10 ELSE 0 END)
    ) AS ingredient_pts,

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

    -- Total confidence score
    (
        (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
        (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
        COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
        (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END)
    ) AS confidence_score,

    -- Confidence band
    CASE
        WHEN (
            (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END)
        ) >= 80 THEN 'high'
        WHEN (
            (CASE WHEN nf.calories IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.total_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.saturated_fat_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.carbs_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.sugars_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN nf.salt_g IS NOT NULL THEN 5 ELSE 0 END) +
            (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END)
        ) >= 50 THEN 'medium'
        ELSE 'low'
    END AS confidence_band,

    -- Completeness profile
    CASE
        WHEN i.ingredients_raw IS NOT NULL AND EXISTS (
            SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id
        ) THEN 'complete'
        WHEN i.ingredients_raw IS NOT NULL THEN 'partial'
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
LEFT JOIN ingredients i ON i.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_confidence_id
    ON v_product_confidence (product_id);
CREATE INDEX IF NOT EXISTS idx_product_confidence_band
    ON v_product_confidence (confidence_band, confidence_score DESC);

COMMENT ON MATERIALIZED VIEW v_product_confidence IS
    'Pre-computed data confidence scores for all active products. '
    'Confidence formula: nutrition(0-30) + ingredients(0-25) + source(0-20) + EAN(0-10) + allergens(0-10) + serving(0-5) = 0-100. '
    'Bands: high(≥80), medium(50-79), low(<50). Refresh after data changes.';


COMMIT;

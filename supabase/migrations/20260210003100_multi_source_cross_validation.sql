-- Migration: Multi-Source Cross-Validation (Phase 10)
-- Date: 2026-02-10
-- Purpose: Infrastructure for comparing nutrition data across multiple
--          independent sources, detecting discrepancies, and rewarding
--          multi-source agreement in the confidence score.
--
-- New objects:
--   source_nutrition          — per-source nutrition snapshots
--   cross_validate_product()  — compares nutrition across sources
--   Updated compute_data_confidence() — adds cross_validation_pts (0-5)
--   Rebuilt v_product_confidence       — adds cross_validation_pts column

BEGIN;

-- ============================================================
-- 1. source_nutrition — nutrition snapshot per data source
-- ============================================================
-- Each row records the nutrition values exactly as reported by one
-- data source. This allows comparison across sources to detect
-- discrepancies before they propagate to nutrition_facts.

CREATE TABLE IF NOT EXISTS public.source_nutrition (
    source_nutrition_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id          bigint NOT NULL
                        REFERENCES public.products(product_id) ON DELETE CASCADE,
    source_type         text   NOT NULL,
    calories            numeric,
    total_fat_g         numeric,
    saturated_fat_g     numeric,
    trans_fat_g         numeric,
    carbs_g             numeric,
    sugars_g            numeric,
    fibre_g             numeric,
    protein_g           numeric,
    salt_g              numeric,
    collected_at        timestamptz NOT NULL DEFAULT now(),
    notes               text,

    CONSTRAINT chk_sn_source_type
        CHECK (source_type IN ('off_api', 'off_search', 'manual',
                               'label_scan', 'retailer_api')),

    CONSTRAINT uq_source_nutrition_entry
        UNIQUE (product_id, source_type)
);

CREATE INDEX IF NOT EXISTS idx_source_nutrition_product
    ON source_nutrition (product_id);

COMMENT ON TABLE source_nutrition IS
    'Per-source nutrition snapshots for cross-validation. Each row stores '
    'the nutrition values as reported by a specific data source, enabling '
    'comparison across sources to detect discrepancies.';


-- ============================================================
-- 2. cross_validate_product() — compare nutrition across sources
-- ============================================================
-- Returns JSONB describing agreement/disagreement between sources.
-- Agreement uses hybrid tolerance: within ±15% relative OR ±0.5g absolute.

CREATE OR REPLACE FUNCTION cross_validate_product(p_product_id bigint)
RETURNS jsonb
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_source_count int;
    v_result       jsonb;
BEGIN
    SELECT COUNT(DISTINCT source_type) INTO v_source_count
    FROM   source_nutrition
    WHERE  product_id = p_product_id;

    IF v_source_count < 2 THEN
        RETURN jsonb_build_object(
            'product_id',    p_product_id,
            'sources_count', v_source_count,
            'status',        CASE WHEN v_source_count = 0
                                  THEN 'no_source_nutrition'
                                  ELSE 'single_source' END,
            'agreement_pct', NULL::int,
            'discrepancies', '[]'::jsonb,
            'explanation',   'Cross-validation requires at least 2 source nutrition records.'
        );
    END IF;

    -- Compare every pair of sources on 6 key nutrients.
    -- Hybrid tolerance: values agree when within ±15% relative OR ±0.5 absolute.
    WITH source_pairs AS (
        SELECT
            a.source_type AS source_a,
            b.source_type AS source_b,
            a.calories  AS a_cal,  b.calories  AS b_cal,
            a.total_fat_g AS a_fat, b.total_fat_g AS b_fat,
            a.saturated_fat_g AS a_sat, b.saturated_fat_g AS b_sat,
            a.carbs_g AS a_carb, b.carbs_g AS b_carb,
            a.sugars_g AS a_sug, b.sugars_g AS b_sug,
            a.salt_g AS a_salt, b.salt_g AS b_salt
        FROM source_nutrition a
        JOIN source_nutrition b
          ON a.product_id = b.product_id
         AND a.source_type < b.source_type
        WHERE a.product_id = p_product_id
    ),
    field_checks AS (
        SELECT
            source_a, source_b, field,
            CASE
                -- Both NULL → agree (unknown = unknown)
                WHEN val_a IS NULL OR val_b IS NULL THEN 1.0
                -- Both zero → agree
                WHEN val_a = 0 AND val_b = 0 THEN 1.0
                -- Within ±0.5 absolute → agree (handles small values)
                WHEN ABS(val_a - val_b) <= 0.5 THEN 1.0
                -- Percentage agreement
                WHEN GREATEST(val_a, val_b) > 0
                THEN GREATEST(0, 1.0 - ABS(val_a - val_b) / GREATEST(val_a, val_b))
                ELSE 1.0
            END AS agreement
        FROM source_pairs,
        LATERAL (VALUES
            ('calories',        a_cal,  b_cal),
            ('total_fat_g',     a_fat,  b_fat),
            ('saturated_fat_g', a_sat,  b_sat),
            ('carbs_g',         a_carb, b_carb),
            ('sugars_g',        a_sug,  b_sug),
            ('salt_g',          a_salt, b_salt)
        ) AS t(field, val_a, val_b)
    ),
    pair_summary AS (
        SELECT
            source_a,
            source_b,
            ROUND(AVG(agreement) * 100)::int AS agreement_pct,
            COALESCE(
                jsonb_agg(
                    jsonb_build_object(
                        'field', field,
                        'agreement_pct', ROUND(agreement * 100)::int
                    )
                ) FILTER (WHERE agreement < 0.85),
                '[]'::jsonb
            ) AS discrepancies
        FROM field_checks
        GROUP BY source_a, source_b
    )
    SELECT jsonb_build_object(
        'product_id',    p_product_id,
        'sources_count', v_source_count,
        'status', CASE
            WHEN MIN(agreement_pct) >= 90 THEN 'validated'
            WHEN MIN(agreement_pct) >= 70 THEN 'partial_agreement'
            ELSE 'conflict'
        END,
        'agreement_pct', MIN(agreement_pct),
        'pairs', jsonb_agg(jsonb_build_object(
            'sources',        ARRAY[source_a, source_b],
            'agreement_pct',  agreement_pct,
            'discrepancies',  discrepancies
        )),
        'explanation', CASE
            WHEN MIN(agreement_pct) >= 90
            THEN 'Sources agree on nutrition values (≥90%). Data is cross-validated.'
            WHEN MIN(agreement_pct) >= 70
            THEN 'Sources partially agree (70-89%). Some values differ — review recommended.'
            ELSE 'Sources conflict on nutrition values (<70%). Manual review required.'
        END
    ) INTO v_result
    FROM pair_summary;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION cross_validate_product IS
    'Compares nutrition data across multiple sources for a product. '
    'Returns JSONB with sources_count, agreement_pct, status '
    '(validated/partial_agreement/conflict/single_source), discrepancy details, '
    'and human-readable explanation. Hybrid tolerance: ±15% relative OR ±0.5g absolute.';


-- ============================================================
-- 3. Updated compute_data_confidence() — add cross_validation_pts
-- ============================================================
-- New component: cross_validation (0-5)
--   5 pts if ≥2 sources agree ≥90% on nutrition
--   3 pts if ≥2 sources agree ≥70%
--   0 pts otherwise (single source or low agreement)
-- Total capped at 100.

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

            -- Cross-validation bonus (0-5): reward multi-source agreement
            (SELECT CASE
                WHEN COUNT(DISTINCT sn.source_type) >= 2 THEN
                    CASE
                        -- Compute min pairwise agreement across 6 key nutrients
                        WHEN (
                            SELECT MIN(pair_agree)
                            FROM (
                                SELECT
                                    ROUND(AVG(
                                        CASE
                                            WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                            WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                            WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                            WHEN GREATEST(t.val_a, t.val_b) > 0
                                            THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                            ELSE 1.0
                                        END
                                    ) * 100)::int AS pair_agree
                                FROM source_nutrition sn_a
                                JOIN source_nutrition sn_b
                                  ON sn_a.product_id = sn_b.product_id
                                 AND sn_a.source_type < sn_b.source_type
                                CROSS JOIN LATERAL (VALUES
                                    (sn_a.calories, sn_b.calories),
                                    (sn_a.total_fat_g, sn_b.total_fat_g),
                                    (sn_a.saturated_fat_g, sn_b.saturated_fat_g),
                                    (sn_a.carbs_g, sn_b.carbs_g),
                                    (sn_a.sugars_g, sn_b.sugars_g),
                                    (sn_a.salt_g, sn_b.salt_g)
                                ) AS t(val_a, val_b)
                                WHERE sn_a.product_id = p.product_id
                                GROUP BY sn_a.source_type, sn_b.source_type
                            ) pairs
                        ) >= 90 THEN 5
                        WHEN (
                            SELECT MIN(pair_agree)
                            FROM (
                                SELECT
                                    ROUND(AVG(
                                        CASE
                                            WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                            WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                            WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                            WHEN GREATEST(t.val_a, t.val_b) > 0
                                            THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                            ELSE 1.0
                                        END
                                    ) * 100)::int AS pair_agree
                                FROM source_nutrition sn_a
                                JOIN source_nutrition sn_b
                                  ON sn_a.product_id = sn_b.product_id
                                 AND sn_a.source_type < sn_b.source_type
                                CROSS JOIN LATERAL (VALUES
                                    (sn_a.calories, sn_b.calories),
                                    (sn_a.total_fat_g, sn_b.total_fat_g),
                                    (sn_a.saturated_fat_g, sn_b.saturated_fat_g),
                                    (sn_a.carbs_g, sn_b.carbs_g),
                                    (sn_a.sugars_g, sn_b.sugars_g),
                                    (sn_a.salt_g, sn_b.salt_g)
                                ) AS t(val_a, val_b)
                                WHERE sn_a.product_id = p.product_id
                                GROUP BY sn_a.source_type, sn_b.source_type
                            ) pairs
                        ) >= 70 THEN 3
                        ELSE 0
                    END
                ELSE 0
            END
            FROM source_nutrition sn
            WHERE sn.product_id = p.product_id
            ) AS cross_validation_pts,

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
        'confidence_score', LEAST(
            c.nutrition_pts + c.ingredient_pts + c.source_pts
            + c.cross_validation_pts + c.ean_pts + c.allergen_pts + c.serving_pts,
            100
        ),
        'confidence_band', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.cross_validation_pts + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 80 THEN 'high'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.cross_validation_pts + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 50 THEN 'medium'
            ELSE 'low'
        END,
        'components', jsonb_build_object(
            'nutrition',         jsonb_build_object('points', c.nutrition_pts, 'max', 30),
            'ingredients',       jsonb_build_object('points', c.ingredient_pts, 'max', 25),
            'source',            jsonb_build_object('points', c.source_pts, 'max', 20),
            'cross_validation',  jsonb_build_object('points', c.cross_validation_pts, 'max', 5),
            'ean',               jsonb_build_object('points', c.ean_pts, 'max', 10),
            'allergens',         jsonb_build_object('points', c.allergen_pts, 'max', 10),
            'serving_data',      jsonb_build_object('points', c.serving_pts, 'max', 5)
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
                UNION ALL
                SELECT 'cross_validation' WHERE c.cross_validation_pts = 0
            ) missing
        ),
        'explanation', CASE
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.cross_validation_pts + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 80
            THEN 'This product has comprehensive data from verified sources. The score is highly reliable.'
            WHEN LEAST(c.nutrition_pts + c.ingredient_pts + c.source_pts
                       + c.cross_validation_pts + c.ean_pts + c.allergen_pts + c.serving_pts, 100) >= 50
            THEN 'This product has partial data coverage. Some fields may be estimated or missing. The score is reasonably reliable but should be interpreted with some caution.'
            ELSE 'This product has limited data. The score may not fully reflect the product''s nutritional profile. We recommend checking the product label directly.'
        END
    )
    FROM components c;
$$;


-- ============================================================
-- 4. Rebuild v_product_confidence — add cross_validation_pts
-- ============================================================
-- Must DROP + CREATE because you cannot ALTER materialized views.

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

    -- Cross-validation bonus (0-5)
    (SELECT CASE
        WHEN COUNT(DISTINCT sn.source_type) >= 2 THEN
            CASE
                WHEN (
                    SELECT MIN(pair_agree) FROM (
                        SELECT ROUND(AVG(
                            CASE
                                WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                WHEN GREATEST(t.val_a, t.val_b) > 0
                                THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                ELSE 1.0
                            END
                        ) * 100)::int AS pair_agree
                        FROM source_nutrition sn_a
                        JOIN source_nutrition sn_b
                          ON sn_a.product_id = sn_b.product_id
                         AND sn_a.source_type < sn_b.source_type
                        CROSS JOIN LATERAL (VALUES
                            (sn_a.calories, sn_b.calories),
                            (sn_a.total_fat_g, sn_b.total_fat_g),
                            (sn_a.saturated_fat_g, sn_b.saturated_fat_g),
                            (sn_a.carbs_g, sn_b.carbs_g),
                            (sn_a.sugars_g, sn_b.sugars_g),
                            (sn_a.salt_g, sn_b.salt_g)
                        ) AS t(val_a, val_b)
                        WHERE sn_a.product_id = p.product_id
                        GROUP BY sn_a.source_type, sn_b.source_type
                    ) pairs
                ) >= 90 THEN 5
                WHEN (
                    SELECT MIN(pair_agree) FROM (
                        SELECT ROUND(AVG(
                            CASE
                                WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                WHEN GREATEST(t.val_a, t.val_b) > 0
                                THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                ELSE 1.0
                            END
                        ) * 100)::int AS pair_agree
                        FROM source_nutrition sn_a
                        JOIN source_nutrition sn_b
                          ON sn_a.product_id = sn_b.product_id
                         AND sn_a.source_type < sn_b.source_type
                        CROSS JOIN LATERAL (VALUES
                            (sn_a.calories, sn_b.calories),
                            (sn_a.total_fat_g, sn_b.total_fat_g),
                            (sn_a.saturated_fat_g, sn_b.saturated_fat_g),
                            (sn_a.carbs_g, sn_b.carbs_g),
                            (sn_a.sugars_g, sn_b.sugars_g),
                            (sn_a.salt_g, sn_b.salt_g)
                        ) AS t(val_a, val_b)
                        WHERE sn_a.product_id = p.product_id
                        GROUP BY sn_a.source_type, sn_b.source_type
                    ) pairs
                ) >= 70 THEN 3
                ELSE 0
            END
        ELSE 0
    END
    FROM source_nutrition sn
    WHERE sn.product_id = p.product_id
    ) AS cross_validation_pts,

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
        (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
        (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
        COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
        (SELECT CASE
            WHEN COUNT(DISTINCT sn.source_type) >= 2 THEN
                CASE
                    WHEN (
                        SELECT MIN(pair_agree) FROM (
                            SELECT ROUND(AVG(
                                CASE
                                    WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                    WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                    WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                    WHEN GREATEST(t.val_a, t.val_b) > 0
                                    THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                    ELSE 1.0
                                END
                            ) * 100)::int AS pair_agree
                            FROM source_nutrition sn_a
                            JOIN source_nutrition sn_b ON sn_a.product_id = sn_b.product_id AND sn_a.source_type < sn_b.source_type
                            CROSS JOIN LATERAL (VALUES
                                (sn_a.calories, sn_b.calories), (sn_a.total_fat_g, sn_b.total_fat_g),
                                (sn_a.saturated_fat_g, sn_b.saturated_fat_g), (sn_a.carbs_g, sn_b.carbs_g),
                                (sn_a.sugars_g, sn_b.sugars_g), (sn_a.salt_g, sn_b.salt_g)
                            ) AS t(val_a, val_b)
                            WHERE sn_a.product_id = p.product_id
                            GROUP BY sn_a.source_type, sn_b.source_type
                        ) pairs
                    ) >= 90 THEN 5
                    WHEN (
                        SELECT MIN(pair_agree) FROM (
                            SELECT ROUND(AVG(
                                CASE
                                    WHEN t.val_a IS NULL OR t.val_b IS NULL THEN 1.0
                                    WHEN t.val_a = 0 AND t.val_b = 0 THEN 1.0
                                    WHEN ABS(t.val_a - t.val_b) <= 0.5 THEN 1.0
                                    WHEN GREATEST(t.val_a, t.val_b) > 0
                                    THEN GREATEST(0, 1.0 - ABS(t.val_a - t.val_b) / GREATEST(t.val_a, t.val_b))
                                    ELSE 1.0
                                END
                            ) * 100)::int AS pair_agree
                            FROM source_nutrition sn_a
                            JOIN source_nutrition sn_b ON sn_a.product_id = sn_b.product_id AND sn_a.source_type < sn_b.source_type
                            CROSS JOIN LATERAL (VALUES
                                (sn_a.calories, sn_b.calories), (sn_a.total_fat_g, sn_b.total_fat_g),
                                (sn_a.saturated_fat_g, sn_b.saturated_fat_g), (sn_a.carbs_g, sn_b.carbs_g),
                                (sn_a.sugars_g, sn_b.sugars_g), (sn_a.salt_g, sn_b.salt_g)
                            ) AS t(val_a, val_b)
                            WHERE sn_a.product_id = p.product_id
                            GROUP BY sn_a.source_type, sn_b.source_type
                        ) pairs
                    ) >= 70 THEN 3
                    ELSE 0
                END
            ELSE 0
        END FROM source_nutrition sn WHERE sn.product_id = p.product_id) +
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
            (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (SELECT CASE WHEN COUNT(DISTINCT sn.source_type) >= 2 THEN
                CASE WHEN (SELECT MIN(pa) FROM (SELECT ROUND(AVG(CASE WHEN t.va IS NULL OR t.vb IS NULL THEN 1.0 WHEN t.va=0 AND t.vb=0 THEN 1.0 WHEN ABS(t.va-t.vb)<=0.5 THEN 1.0 WHEN GREATEST(t.va,t.vb)>0 THEN GREATEST(0,1.0-ABS(t.va-t.vb)/GREATEST(t.va,t.vb)) ELSE 1.0 END)*100)::int AS pa FROM source_nutrition a JOIN source_nutrition b ON a.product_id=b.product_id AND a.source_type<b.source_type CROSS JOIN LATERAL(VALUES(a.calories,b.calories),(a.total_fat_g,b.total_fat_g),(a.saturated_fat_g,b.saturated_fat_g),(a.carbs_g,b.carbs_g),(a.sugars_g,b.sugars_g),(a.salt_g,b.salt_g))AS t(va,vb) WHERE a.product_id=p.product_id GROUP BY a.source_type,b.source_type)x)>=90 THEN 5
                WHEN (SELECT MIN(pa) FROM (SELECT ROUND(AVG(CASE WHEN t.va IS NULL OR t.vb IS NULL THEN 1.0 WHEN t.va=0 AND t.vb=0 THEN 1.0 WHEN ABS(t.va-t.vb)<=0.5 THEN 1.0 WHEN GREATEST(t.va,t.vb)>0 THEN GREATEST(0,1.0-ABS(t.va-t.vb)/GREATEST(t.va,t.vb)) ELSE 1.0 END)*100)::int AS pa FROM source_nutrition a JOIN source_nutrition b ON a.product_id=b.product_id AND a.source_type<b.source_type CROSS JOIN LATERAL(VALUES(a.calories,b.calories),(a.total_fat_g,b.total_fat_g),(a.saturated_fat_g,b.saturated_fat_g),(a.carbs_g,b.carbs_g),(a.sugars_g,b.sugars_g),(a.salt_g,b.salt_g))AS t(va,vb) WHERE a.product_id=p.product_id GROUP BY a.source_type,b.source_type)x)>=70 THEN 3
                ELSE 0 END
            ELSE 0 END FROM source_nutrition sn WHERE sn.product_id=p.product_id) +
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
            (CASE WHEN i.ingredients_raw IS NOT NULL AND LENGTH(TRIM(i.ingredients_raw)) > 0 THEN 15 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.product_id = p.product_id) THEN 10 ELSE 0 END) +
            COALESCE((SELECT ROUND(ps.confidence_pct * 0.2)::int FROM product_sources ps WHERE ps.product_id = p.product_id AND ps.is_primary = true LIMIT 1), 0) +
            (SELECT CASE WHEN COUNT(DISTINCT sn.source_type) >= 2 THEN
                CASE WHEN (SELECT MIN(pa) FROM (SELECT ROUND(AVG(CASE WHEN t.va IS NULL OR t.vb IS NULL THEN 1.0 WHEN t.va=0 AND t.vb=0 THEN 1.0 WHEN ABS(t.va-t.vb)<=0.5 THEN 1.0 WHEN GREATEST(t.va,t.vb)>0 THEN GREATEST(0,1.0-ABS(t.va-t.vb)/GREATEST(t.va,t.vb)) ELSE 1.0 END)*100)::int AS pa FROM source_nutrition a JOIN source_nutrition b ON a.product_id=b.product_id AND a.source_type<b.source_type CROSS JOIN LATERAL(VALUES(a.calories,b.calories),(a.total_fat_g,b.total_fat_g),(a.saturated_fat_g,b.saturated_fat_g),(a.carbs_g,b.carbs_g),(a.sugars_g,b.sugars_g),(a.salt_g,b.salt_g))AS t(va,vb) WHERE a.product_id=p.product_id GROUP BY a.source_type,b.source_type)x)>=90 THEN 5
                WHEN (SELECT MIN(pa) FROM (SELECT ROUND(AVG(CASE WHEN t.va IS NULL OR t.vb IS NULL THEN 1.0 WHEN t.va=0 AND t.vb=0 THEN 1.0 WHEN ABS(t.va-t.vb)<=0.5 THEN 1.0 WHEN GREATEST(t.va,t.vb)>0 THEN GREATEST(0,1.0-ABS(t.va-t.vb)/GREATEST(t.va,t.vb)) ELSE 1.0 END)*100)::int AS pa FROM source_nutrition a JOIN source_nutrition b ON a.product_id=b.product_id AND a.source_type<b.source_type CROSS JOIN LATERAL(VALUES(a.calories,b.calories),(a.total_fat_g,b.total_fat_g),(a.saturated_fat_g,b.saturated_fat_g),(a.carbs_g,b.carbs_g),(a.sugars_g,b.sugars_g),(a.salt_g,b.salt_g))AS t(va,vb) WHERE a.product_id=p.product_id GROUP BY a.source_type,b.source_type)x)>=70 THEN 3
                ELSE 0 END
            ELSE 0 END FROM source_nutrition sn WHERE sn.product_id=p.product_id) +
            (CASE WHEN p.ean IS NOT NULL AND LENGTH(p.ean) >= 8 THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM product_allergen pa WHERE pa.product_id = p.product_id) THEN 10 ELSE 0 END) +
            (CASE WHEN EXISTS (SELECT 1 FROM servings sv2 WHERE sv2.product_id = p.product_id AND sv2.serving_basis = 'per serving') THEN 5 ELSE 0 END),
            100
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
    'Confidence formula: nutrition(0-30) + ingredients(0-25) + source(0-20) '
    '+ cross_validation(0-5) + EAN(0-10) + allergens(0-10) + serving(0-5) = 0-105, capped at 100. '
    'Bands: high(>=80), medium(50-79), low(<50). Refresh after data changes.';


-- ============================================================
-- 5. Backfill source_nutrition from existing nutrition data
-- ============================================================
-- Copy current canonical nutrition values as the OFF API source snapshot.

INSERT INTO source_nutrition
       (product_id, source_type, calories, total_fat_g, saturated_fat_g,
        trans_fat_g, carbs_g, sugars_g, fibre_g, protein_g, salt_g, notes)
SELECT p.product_id,
       COALESCE(ps.source_type, 'off_api'),
       nf.calories, nf.total_fat_g, nf.saturated_fat_g,
       nf.trans_fat_g, nf.carbs_g, nf.sugars_g, nf.fibre_g, nf.protein_g, nf.salt_g,
       'Backfilled from nutrition_facts during Phase 10 migration'
FROM products p
JOIN product_sources ps ON ps.product_id = p.product_id AND ps.is_primary = true
JOIN servings sv ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE p.is_deprecated IS NOT TRUE
ON CONFLICT DO NOTHING;


-- ============================================================
-- 6. Refresh materialized views
-- ============================================================
SELECT refresh_all_materialized_views();


COMMIT;

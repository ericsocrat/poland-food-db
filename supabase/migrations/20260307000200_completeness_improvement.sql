-- Systematic completeness improvement: source URL backfill + gap analysis function
-- Fixes: #376 — 24 products without source_url, plus diagnostic function
--
-- Impact:
--   - source_url backfill: 24 products gain +6.7pp completeness each
--   - New function: api_completeness_gap_analysis() for ongoing monitoring
--
-- Rollback:
--   UPDATE products SET source_url = NULL WHERE source_url LIKE 'https://world.openfoodfacts.org/api/v2/product/%';
--   DROP FUNCTION IF EXISTS api_completeness_gap_analysis;

BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 1: Backfill source_url for 24 products from EAN
-- ────────────────────────────────────────────────────────────────────────────
-- All 24 products have source_type='off_api' and valid EAN codes.
-- Construct the canonical OFF API v2 product URL from the EAN.

UPDATE products
SET    source_url = 'https://world.openfoodfacts.org/api/v2/product/' || ean
WHERE  is_deprecated IS NOT TRUE
  AND  source_url IS NULL
  AND  ean IS NOT NULL
  AND  source_type = 'off_api';

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 2: Re-run data_completeness_pct for affected products
-- ────────────────────────────────────────────────────────────────────────────
-- The source_url checkpoint in compute_data_completeness() now passes for these
-- products, which lifts each by ~6.7pp.

UPDATE products p
SET    data_completeness_pct = compute_data_completeness(p.product_id)
WHERE  p.is_deprecated IS NOT TRUE
  AND  p.source_url LIKE 'https://world.openfoodfacts.org/api/v2/product/%'
  AND  p.data_completeness_pct != compute_data_completeness(p.product_id);

-- Re-evaluate confidence for products whose completeness changed
UPDATE products p
SET    confidence = assign_confidence(p.data_completeness_pct, p.source_type)
WHERE  p.is_deprecated IS NOT TRUE
  AND  p.source_url LIKE 'https://world.openfoodfacts.org/api/v2/product/%'
  AND  p.confidence IS DISTINCT FROM assign_confidence(p.data_completeness_pct, p.source_type);

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 3: Completeness gap analysis function
-- ────────────────────────────────────────────────────────────────────────────
-- Diagnostic function: shows per-checkpoint coverage across active products.
-- Optional country/category filters. Returns one row per checkpoint.

CREATE OR REPLACE FUNCTION api_completeness_gap_analysis(
    p_country  text DEFAULT NULL,
    p_category text DEFAULT NULL
)
RETURNS TABLE(
    checkpoint        text,
    total_products    bigint,
    products_passing  bigint,
    products_failing  bigint,
    coverage_pct      numeric,
    backfill_path     text
) LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    WITH active AS (
        SELECT p.product_id, p.ean, p.nutri_score_label, p.nova_classification,
               p.source_url,
               nf.calories, nf.total_fat_g, nf.saturated_fat_g,
               nf.carbs_g, nf.sugars_g, nf.protein_g, nf.fibre_g,
               nf.salt_g, nf.trans_fat_g
        FROM products p
        LEFT JOIN nutrition_facts nf ON p.product_id = nf.product_id
        WHERE p.is_deprecated IS NOT TRUE
          AND (p_country IS NULL OR p.country = p_country)
          AND (p_category IS NULL OR p.category = p_category)
    ),
    totals AS (
        SELECT count(*) AS n FROM active
    ),
    checks AS (
        SELECT 'ean' AS cp,
               count(*) FILTER (WHERE a.ean IS NOT NULL) AS pass,
               'manual collection' AS bfp
        FROM active a
        UNION ALL
        SELECT 'calories', count(*) FILTER (WHERE a.calories IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'total_fat', count(*) FILTER (WHERE a.total_fat_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'saturated_fat', count(*) FILTER (WHERE a.saturated_fat_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'carbs', count(*) FILTER (WHERE a.carbs_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'sugars', count(*) FILTER (WHERE a.sugars_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'protein', count(*) FILTER (WHERE a.protein_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'fibre', count(*) FILTER (WHERE a.fibre_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'salt', count(*) FILTER (WHERE a.salt_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'trans_fat', count(*) FILTER (WHERE a.trans_fat_g IS NOT NULL), 'OFF API'
        FROM active a
        UNION ALL
        SELECT 'nutri_score',
               count(*) FILTER (WHERE a.nutri_score_label IS NOT NULL
                                  AND a.nutri_score_label NOT IN ('UNKNOWN','NOT-APPLICABLE')),
               'OFF API or calculation'
        FROM active a
        UNION ALL
        SELECT 'nova_classification',
               count(*) FILTER (WHERE a.nova_classification IS NOT NULL),
               'OFF API'
        FROM active a
        UNION ALL
        SELECT 'ingredients',
               count(*) FILTER (WHERE EXISTS (
                   SELECT 1 FROM product_ingredient pi WHERE pi.product_id = a.product_id
               )),
               'OFF API enrichment'
        FROM active a
        UNION ALL
        SELECT 'allergens',
               count(*) FILTER (WHERE EXISTS (
                   SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = a.product_id
               )),
               'OFF API enrichment or inference'
        FROM active a
        UNION ALL
        SELECT 'source_url',
               count(*) FILTER (WHERE a.source_url IS NOT NULL),
               'OFF API URL from EAN'
        FROM active a
    )
    SELECT c.cp                                                   AS checkpoint,
           t.n                                                    AS total_products,
           c.pass                                                 AS products_passing,
           t.n - c.pass                                           AS products_failing,
           round(100.0 * c.pass / NULLIF(t.n, 0), 1)             AS coverage_pct,
           c.bfp                                                  AS backfill_path
    FROM checks c
    CROSS JOIN totals t
    ORDER BY coverage_pct ASC;
$$;

-- Grant access for anon users (read-only diagnostic)
GRANT EXECUTE ON FUNCTION api_completeness_gap_analysis TO anon, authenticated;

COMMIT;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 4: Refresh materialized views (outside transaction)
-- ────────────────────────────────────────────────────────────────────────────
SELECT refresh_all_materialized_views();

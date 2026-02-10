-- Migration: Cross-Product Analytics
-- Date: 2026-02-10
-- Purpose: Create materialized views and functions for ingredient frequency
--          analysis, product similarity, and better-alternative recommendations.

BEGIN;

-- ============================================================
-- 1. mv_ingredient_frequency — Ingredient usage statistics
-- ============================================================
-- Materialized view for fast ingredient frequency queries.
-- Refresh after any product/ingredient data change.

CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_ingredient_frequency AS
SELECT
    ir.ingredient_id,
    ir.name_en,
    ir.is_additive,
    ir.concern_tier,
    ir.from_palm_oil,
    COUNT(DISTINCT pi.product_id) AS product_count,
    ROUND(COUNT(DISTINCT pi.product_id) * 100.0 /
        NULLIF((SELECT COUNT(DISTINCT product_id) FROM product_ingredient), 0), 1) AS usage_pct,
    ARRAY_AGG(DISTINCT p.category ORDER BY p.category) AS categories,
    ARRAY_LENGTH(ARRAY_AGG(DISTINCT p.category), 1) AS category_spread,
    ROUND(AVG(s.unhealthiness_score), 1) AS avg_score_of_products
FROM public.ingredient_ref ir
JOIN public.product_ingredient pi ON pi.ingredient_id = ir.ingredient_id
JOIN public.products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
LEFT JOIN public.scores s ON s.product_id = p.product_id
GROUP BY ir.ingredient_id, ir.name_en, ir.is_additive, ir.concern_tier, ir.from_palm_oil
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_ingredient_freq_id
    ON public.mv_ingredient_frequency (ingredient_id);
CREATE INDEX IF NOT EXISTS idx_mv_ingredient_freq_count
    ON public.mv_ingredient_frequency (product_count DESC);
CREATE INDEX IF NOT EXISTS idx_mv_ingredient_freq_concern
    ON public.mv_ingredient_frequency (concern_tier DESC, product_count DESC);

COMMENT ON MATERIALIZED VIEW public.mv_ingredient_frequency IS
    'Pre-computed ingredient usage statistics across all active products. '
    'Columns: ingredient_id, name_en, is_additive, concern_tier, from_palm_oil, '
    'product_count, usage_pct, categories (array), category_spread, avg_score_of_products. '
    'Refresh with: REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;';


-- ============================================================
-- 2. find_similar_products() — Jaccard similarity on ingredients
-- ============================================================
-- Returns the top-N most similar products by ingredient overlap.

CREATE OR REPLACE FUNCTION find_similar_products(
    p_product_id bigint,
    p_limit integer DEFAULT 5
)
RETURNS TABLE (
    similar_product_id   bigint,
    product_name         text,
    brand                text,
    category             text,
    unhealthiness_score  integer,
    shared_ingredients   integer,
    total_ingredients_a  integer,
    total_ingredients_b  integer,
    jaccard_similarity   numeric
)
LANGUAGE sql STABLE AS $$
    WITH target_ingredients AS (
        SELECT ingredient_id
        FROM product_ingredient
        WHERE product_id = p_product_id
    ),
    target_count AS (
        SELECT COUNT(*)::int AS cnt FROM target_ingredients
    ),
    candidates AS (
        SELECT
            pi2.product_id AS cand_id,
            COUNT(DISTINCT pi2.ingredient_id) FILTER (
                WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
            )::int AS shared,
            COUNT(DISTINCT pi2.ingredient_id)::int AS cand_total
        FROM product_ingredient pi2
        WHERE pi2.product_id != p_product_id
          AND pi2.product_id IN (
              SELECT product_id FROM products WHERE is_deprecated IS NOT TRUE
          )
        GROUP BY pi2.product_id
        HAVING COUNT(DISTINCT pi2.ingredient_id) FILTER (
            WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
        ) > 0
    )
    SELECT
        c.cand_id,
        p.product_name,
        p.brand,
        p.category,
        s.unhealthiness_score::integer,
        c.shared,
        tc.cnt,
        c.cand_total,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3)
    FROM candidates c
    CROSS JOIN target_count tc
    JOIN products p ON p.product_id = c.cand_id
    LEFT JOIN scores s ON s.product_id = c.cand_id
    ORDER BY ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC,
             s.unhealthiness_score ASC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION find_similar_products IS
    'Find top-N products most similar to a given product by Jaccard ingredient overlap. '
    'Returns product details, shared ingredient count, and Jaccard similarity coefficient (0-1).';


-- ============================================================
-- 3. find_better_alternatives() — Healthier substitutes
-- ============================================================
-- For a given product, find products in the same (or optionally any) category
-- that score lower (healthier) and share ingredient similarity.

CREATE OR REPLACE FUNCTION find_better_alternatives(
    p_product_id bigint,
    p_same_category boolean DEFAULT true,
    p_limit integer DEFAULT 5
)
RETURNS TABLE (
    alt_product_id       bigint,
    product_name         text,
    brand                text,
    category             text,
    unhealthiness_score  integer,
    score_improvement    integer,
    shared_ingredients   integer,
    jaccard_similarity   numeric,
    nutri_score_label    text
)
LANGUAGE sql STABLE AS $$
    WITH target AS (
        SELECT
            p.product_id,
            p.category AS target_cat,
            s.unhealthiness_score AS target_score
        FROM products p
        JOIN scores s ON s.product_id = p.product_id
        WHERE p.product_id = p_product_id
    ),
    target_ingredients AS (
        SELECT ingredient_id
        FROM product_ingredient
        WHERE product_id = p_product_id
    ),
    target_count AS (
        SELECT COUNT(*)::int AS cnt FROM target_ingredients
    ),
    candidates AS (
        SELECT
            p2.product_id AS cand_id,
            p2.product_name,
            p2.brand,
            p2.category,
            s2.unhealthiness_score,
            s2.nutri_score_label,
            COUNT(DISTINCT pi2.ingredient_id) FILTER (
                WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
            )::int AS shared,
            COUNT(DISTINCT pi2.ingredient_id)::int AS cand_total
        FROM products p2
        JOIN scores s2 ON s2.product_id = p2.product_id
        LEFT JOIN product_ingredient pi2 ON pi2.product_id = p2.product_id
        CROSS JOIN target t
        WHERE p2.is_deprecated IS NOT TRUE
          AND p2.product_id != p_product_id
          AND s2.unhealthiness_score < t.target_score
          AND (NOT p_same_category OR p2.category = t.target_cat)
        GROUP BY p2.product_id, p2.product_name, p2.brand, p2.category,
                 s2.unhealthiness_score, s2.nutri_score_label
    )
    SELECT
        c.cand_id,
        c.product_name,
        c.brand,
        c.category,
        c.unhealthiness_score::integer,
        (t.target_score - c.unhealthiness_score)::integer AS score_improvement,
        c.shared,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3),
        c.nutri_score_label
    FROM candidates c
    CROSS JOIN target t
    CROSS JOIN target_count tc
    ORDER BY
        (t.target_score - c.unhealthiness_score) DESC,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION find_better_alternatives IS
    'Find healthier alternatives to a given product. '
    'By default restricts to same category; set p_same_category=false for cross-category. '
    'Returns products with lower scores, ranked by score improvement and ingredient similarity.';

COMMIT;

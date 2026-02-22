-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Pre-Compute Similarity Matrix MV
-- Issue:     #139
-- Purpose:   Pre-compute pairwise Jaccard similarity as a materialized view
--            to eliminate the O(n²) self-join in find_similar_products() and
--            find_better_alternatives().
--
--   1. Create mv_product_similarity
--   2. Update find_similar_products() to use MV
--   3. Update find_better_alternatives() to use MV (same-category fast path)
--   4. Add mv_product_similarity to refresh_all_materialized_views()
--   5. Add mv_product_similarity to mv_staleness_check()
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Create mv_product_similarity
--    Stores pre-computed Jaccard similarity for same-category, same-country
--    product pairs where jaccard >= 0.1.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_product_similarity AS
WITH active_products AS (
    SELECT product_id, category, country
    FROM products
    WHERE is_deprecated IS NOT TRUE
      AND category IS NOT NULL
),
product_ingredients_dedup AS (
    SELECT DISTINCT pi.product_id, pi.ingredient_id
    FROM product_ingredient pi
    JOIN active_products ap ON pi.product_id = ap.product_id
),
ingredient_counts AS (
    SELECT product_id, COUNT(*)::int AS cnt
    FROM product_ingredients_dedup
    GROUP BY product_id
),
shared AS (
    SELECT
        a.product_id AS product_id_a,
        b.product_id AS product_id_b,
        COUNT(*)::int AS shared_count
    FROM product_ingredients_dedup a
    JOIN product_ingredients_dedup b
        ON a.ingredient_id = b.ingredient_id
        AND a.product_id < b.product_id
    JOIN active_products pa ON a.product_id = pa.product_id
    JOIN active_products pb ON b.product_id = pb.product_id
        AND pa.category = pb.category
        AND pa.country  = pb.country
    GROUP BY a.product_id, b.product_id
)
SELECT
    s.product_id_a,
    s.product_id_b,
    ap.category,
    ap.country,
    s.shared_count      AS shared_ingredients,
    ic_a.cnt             AS ingredients_a,
    ic_b.cnt             AS ingredients_b,
    ROUND(
        s.shared_count::numeric /
        NULLIF(ic_a.cnt + ic_b.cnt - s.shared_count, 0),
        3
    ) AS jaccard_similarity
FROM shared s
JOIN active_products ap  ON s.product_id_a = ap.product_id
JOIN ingredient_counts ic_a ON ic_a.product_id = s.product_id_a
JOIN ingredient_counts ic_b ON ic_b.product_id = s.product_id_b
WHERE ROUND(
    s.shared_count::numeric /
    NULLIF(ic_a.cnt + ic_b.cnt - s.shared_count, 0),
    3
) >= 0.1;

-- Indexes for CONCURRENTLY refresh and fast lookups
CREATE UNIQUE INDEX IF NOT EXISTS mv_product_similarity_pair_uniq
    ON mv_product_similarity (product_id_a, product_id_b);

CREATE INDEX IF NOT EXISTS mv_product_similarity_a_idx
    ON mv_product_similarity (product_id_a, jaccard_similarity DESC);

CREATE INDEX IF NOT EXISTS mv_product_similarity_b_idx
    ON mv_product_similarity (product_id_b, jaccard_similarity DESC);

CREATE INDEX IF NOT EXISTS mv_product_similarity_cat_idx
    ON mv_product_similarity (category, country);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Update find_similar_products() — MV lookup (same-category, fast)
--    Preserves return signature. Products in the MV already share the same
--    category and country. Diet/allergen filtering applied on top.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.find_similar_products(
    p_product_id              bigint,
    p_limit                   integer  DEFAULT 5,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS TABLE(
    similar_product_id    bigint,
    product_name          text,
    brand                 text,
    category              text,
    unhealthiness_score   integer,
    shared_ingredients    integer,
    total_ingredients_a   integer,
    total_ingredients_b   integer,
    jaccard_similarity    numeric
)
LANGUAGE sql STABLE
AS $function$
    WITH mv_matches AS (
        SELECT
            CASE WHEN mv.product_id_a = p_product_id
                 THEN mv.product_id_b ELSE mv.product_id_a
            END AS matched_id,
            mv.shared_ingredients AS shared,
            CASE WHEN mv.product_id_a = p_product_id
                 THEN mv.ingredients_a ELSE mv.ingredients_b
            END AS my_total,
            CASE WHEN mv.product_id_a = p_product_id
                 THEN mv.ingredients_b ELSE mv.ingredients_a
            END AS their_total,
            mv.jaccard_similarity
        FROM mv_product_similarity mv
        WHERE mv.product_id_a = p_product_id
           OR mv.product_id_b = p_product_id
    )
    SELECT
        mm.matched_id,
        p.product_name,
        p.brand,
        p.category,
        p.unhealthiness_score::integer,
        mm.shared,
        mm.my_total,
        mm.their_total,
        mm.jaccard_similarity
    FROM mv_matches mm
    JOIN products p ON p.product_id = mm.matched_id
    WHERE p.is_deprecated IS NOT TRUE
      AND check_product_preferences(
          mm.matched_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
      )
    ORDER BY mm.jaccard_similarity DESC, p.unhealthiness_score ASC
    LIMIT p_limit;
$function$;

REVOKE EXECUTE ON FUNCTION public.find_similar_products(
    bigint, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Update find_better_alternatives() — MV fast path when same_category
--    When p_same_category = true (the common hot path via api_better_alternatives),
--    uses the pre-computed MV for Jaccard. When false, falls back to live
--    Jaccard computation for cross-category results.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.find_better_alternatives(
    p_product_id              bigint,
    p_same_category           boolean  DEFAULT true,
    p_limit                   integer  DEFAULT 5,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS TABLE(
    alt_product_id      bigint,
    product_name        text,
    brand               text,
    category            text,
    unhealthiness_score integer,
    score_improvement   integer,
    shared_ingredients  integer,
    jaccard_similarity  numeric,
    nutri_score_label   text
)
LANGUAGE plpgsql STABLE
AS $function$
DECLARE
    v_target_score  integer;
    v_target_cat    text;
    v_target_country text;
BEGIN
    -- Resolve target product metadata
    SELECT p.unhealthiness_score, p.category, p.country
    INTO   v_target_score, v_target_cat, v_target_country
    FROM   products p
    WHERE  p.product_id = p_product_id;

    IF v_target_score IS NULL THEN
        RETURN;  -- product not found
    END IF;

    IF p_same_category THEN
        -- ── Fast path: MV-backed Jaccard ──
        RETURN QUERY
        SELECT
            s.cand_id,
            p2.product_name,
            p2.brand,
            p2.category,
            p2.unhealthiness_score::integer,
            (v_target_score - p2.unhealthiness_score)::integer,
            s.shared,
            s.jacc,
            p2.nutri_score_label
        FROM (
            SELECT
                CASE WHEN mv.product_id_a = p_product_id
                     THEN mv.product_id_b ELSE mv.product_id_a
                END AS cand_id,
                mv.shared_ingredients AS shared,
                mv.jaccard_similarity AS jacc
            FROM mv_product_similarity mv
            WHERE mv.product_id_a = p_product_id
               OR mv.product_id_b = p_product_id
        ) s
        JOIN products p2 ON p2.product_id = s.cand_id
        WHERE p2.is_deprecated IS NOT TRUE
          AND p2.unhealthiness_score < v_target_score
          AND p2.category = v_target_cat
          AND check_product_preferences(
              s.cand_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
        ORDER BY (v_target_score - p2.unhealthiness_score) DESC, s.jacc DESC
        LIMIT p_limit;
    ELSE
        -- ── Slow path: live Jaccard for cross-category ──
        RETURN QUERY
        WITH target_ingredients AS (
            SELECT DISTINCT ingredient_id
            FROM product_ingredient
            WHERE product_id = p_product_id
        ),
        target_count AS (
            SELECT COUNT(*)::int AS cnt FROM target_ingredients
        ),
        candidates AS (
            SELECT
                p2.product_id AS cand_id, p2.product_name, p2.brand, p2.category,
                p2.unhealthiness_score, p2.nutri_score_label,
                COUNT(DISTINCT pi2.ingredient_id) FILTER (
                    WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
                )::int AS shared,
                COUNT(DISTINCT pi2.ingredient_id)::int AS cand_total
            FROM products p2
            LEFT JOIN product_ingredient pi2 ON pi2.product_id = p2.product_id
            WHERE p2.is_deprecated IS NOT TRUE
              AND p2.product_id != p_product_id
              AND p2.country = v_target_country
              AND p2.unhealthiness_score < v_target_score
              AND check_product_preferences(
                  p2.product_id, p_diet_preference, p_avoid_allergens,
                  p_strict_diet, p_strict_allergen, p_treat_may_contain
              )
            GROUP BY p2.product_id, p2.product_name, p2.brand, p2.category,
                     p2.unhealthiness_score, p2.nutri_score_label
        )
        SELECT c.cand_id, c.product_name, c.brand, c.category,
            c.unhealthiness_score::integer,
            (v_target_score - c.unhealthiness_score)::integer,
            c.shared,
            ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3),
            c.nutri_score_label
        FROM candidates c
        CROSS JOIN target_count tc
        ORDER BY (v_target_score - c.unhealthiness_score) DESC,
            ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC
        LIMIT p_limit;
    END IF;
END;
$function$;

-- Internal function: not callable by anon
REVOKE EXECUTE ON FUNCTION public.find_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Update refresh_all_materialized_views() — add mv_product_similarity
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET statement_timeout = '30s'
AS $$
DECLARE
    start_ts  timestamptz;
    t1        numeric;
    t2        numeric;
    t3        numeric;
BEGIN
    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    t1 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));

    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
    t2 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));

    start_ts := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_similarity;
    t3 := EXTRACT(MILLISECONDS FROM (clock_timestamp() - start_ts));

    RETURN jsonb_build_object(
        'refreshed_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object('name', 'mv_ingredient_frequency',
                               'rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                               'ms',   t1),
            jsonb_build_object('name', 'v_product_confidence',
                               'rows', (SELECT COUNT(*) FROM v_product_confidence),
                               'ms',   t2),
            jsonb_build_object('name', 'mv_product_similarity',
                               'rows', (SELECT COUNT(*) FROM mv_product_similarity),
                               'ms',   t3)
        ),
        'total_ms', t1 + t2 + t3
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION refresh_all_materialized_views() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION refresh_all_materialized_views() TO authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Update mv_staleness_check() — add mv_product_similarity
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION mv_staleness_check()
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'checked_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object(
                'name', 'mv_ingredient_frequency',
                'mv_rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                'source_rows', (SELECT COUNT(DISTINCT ingredient_id) FROM product_ingredient),
                'is_stale', (SELECT COUNT(*) FROM mv_ingredient_frequency) !=
                            (SELECT COUNT(DISTINCT ingredient_id) FROM product_ingredient)
            ),
            jsonb_build_object(
                'name', 'v_product_confidence',
                'mv_rows', (SELECT COUNT(*) FROM v_product_confidence),
                'source_rows', (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM v_product_confidence) !=
                            (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE)
            ),
            jsonb_build_object(
                'name', 'mv_product_similarity',
                'mv_rows', (SELECT COUNT(*) FROM mv_product_similarity),
                'distinct_products', (
                    SELECT COUNT(DISTINCT pid) FROM (
                        SELECT product_id_a AS pid FROM mv_product_similarity
                        UNION
                        SELECT product_id_b FROM mv_product_similarity
                    ) t
                ),
                'is_stale', false  -- pair count is non-deterministic; rely on refresh schedule
            )
        )
    );
$$;

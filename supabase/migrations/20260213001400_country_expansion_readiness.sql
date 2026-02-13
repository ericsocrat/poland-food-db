-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Country Expansion Readiness
-- Closes all 5 blockers for multi-country support (backward-compatible).
--
-- Blocker 1 — API country filtering (new p_country params + new view)
-- Blocker 2 — Country-isolated similarity/alternatives
-- Blocker 3 — Country-parameterized scoring (no more hardcoded 'PL')
-- Blocker 4 — Activation gating via country_ref.is_active
-- Blocker 5 — Pipeline rename plan (documentation only, no SQL)
--
-- All changes are backward-compatible:
--   - New params default to NULL (= "all countries", same as before)
--   - score_category defaults p_country to 'PL' (existing callers unaffected)
--   - api_version remains '1.0' (additive key only: 'country' in responses)
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 1a: api_search_products — add p_country filter
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS api_search_products(text, text, integer, integer);

CREATE OR REPLACE FUNCTION api_search_products(
    p_query    text,
    p_category text    DEFAULT NULL,
    p_limit    integer DEFAULT 20,
    p_offset   integer DEFAULT 0,
    p_country  text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_query   text;
BEGIN
    v_query := TRIM(p_query);
    IF LENGTH(v_query) < 2 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Query must be at least 2 characters.'
        );
    END IF;
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    SELECT COUNT(*)::int INTO v_total
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND (p_country  IS NULL OR p.country  = p_country)
      AND (
          p.product_name ILIKE '%' || v_query || '%'
          OR p.brand ILIKE '%' || v_query || '%'
          OR similarity(p.product_name, v_query) > 0.15
      );

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'brand',               p.brand,
            'category',            p.category,
            'unhealthiness_score', p.unhealthiness_score,
            'score_band',          CASE
                                     WHEN p.unhealthiness_score <= 25 THEN 'low'
                                     WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN p.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         p.nutri_score_label,
            'nova_group',          p.nova_classification,
            'relevance',           GREATEST(
                                     similarity(p.product_name, v_query),
                                     similarity(p.brand, v_query) * 0.8
                                   )
        ) AS row_data
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND (p_category IS NULL OR p.category = p_category)
          AND (p_country  IS NULL OR p.country  = p_country)
          AND (
              p.product_name ILIKE '%' || v_query || '%'
              OR p.brand ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
        ORDER BY
            CASE WHEN p.product_name ILIKE v_query || '%' THEN 0 ELSE 1 END,
            GREATEST(similarity(p.product_name, v_query), similarity(p.brand, v_query) * 0.8) DESC,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'query',       v_query,
        'category',    p_category,
        'country',     p_country,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$function$;

COMMENT ON FUNCTION api_search_products(text, text, integer, integer, text) IS
'Full-text + trigram search with optional country and category filters. '
'p_country defaults to NULL (all countries). Backward-compatible: existing callers '
'that omit p_country get the same behavior as before.';

GRANT EXECUTE ON FUNCTION api_search_products(text, text, integer, integer, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION api_search_products(text, text, integer, integer, text)
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 1b: api_category_listing — add p_country filter
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS api_category_listing(text, text, text, integer, integer);

CREATE OR REPLACE FUNCTION api_category_listing(
    p_category text,
    p_sort_by  text    DEFAULT 'score',
    p_sort_dir text    DEFAULT 'asc',
    p_limit    integer DEFAULT 20,
    p_offset   integer DEFAULT 0,
    p_country  text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_order   text;
BEGIN
    -- Validate and map sort column
    v_order := CASE p_sort_by
        WHEN 'score'       THEN 'unhealthiness_score'
        WHEN 'calories'    THEN 'calories'
        WHEN 'protein'     THEN 'protein_g'
        WHEN 'name'        THEN 'product_name'
        WHEN 'nutri_score' THEN 'nutri_score_label'
        ELSE 'unhealthiness_score'
    END;

    -- Clamp pagination
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    -- Get total count
    SELECT COUNT(*)::int INTO v_total
    FROM v_master
    WHERE category = p_category
      AND (p_country IS NULL OR country = p_country);

    -- Build result rows with dynamic ordering
    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          m.product_id,
            'ean',                 m.ean,
            'product_name',        m.product_name,
            'brand',               m.brand,
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,
            'calories',            m.calories,
            'total_fat_g',         m.total_fat_g,
            'protein_g',           m.protein_g,
            'sugars_g',            m.sugars_g,
            'salt_g',              m.salt_g,
            'high_salt_flag',      (m.high_salt_flag = 'YES'),
            'high_sugar_flag',     (m.high_sugar_flag = 'YES'),
            'high_sat_fat_flag',   (m.high_sat_fat_flag = 'YES'),
            'confidence',          m.confidence,
            'data_completeness_pct', m.data_completeness_pct
        ) AS row_data
        FROM v_master m
        WHERE m.category = p_category
          AND (p_country IS NULL OR m.country = p_country)
        ORDER BY
            CASE WHEN p_sort_dir = 'asc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN m.unhealthiness_score::text
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE m.unhealthiness_score::text
                END
            END ASC NULLS LAST,
            CASE WHEN p_sort_dir = 'desc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN m.unhealthiness_score::text
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE m.unhealthiness_score::text
                END
            END DESC NULLS LAST,
            m.product_id ASC  -- stable tiebreaker
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'category',      p_category,
        'country',       p_country,
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'sort_by',       p_sort_by,
        'sort_dir',      p_sort_dir,
        'products',      v_rows
    );
END;
$function$;

COMMENT ON FUNCTION api_category_listing(text, text, text, integer, integer, text) IS
'Paged category browse with optional country filter. '
'p_country defaults to NULL (all countries). Backward-compatible.';

GRANT EXECUTE ON FUNCTION api_category_listing(text, text, text, integer, integer, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION api_category_listing(text, text, text, integer, integer, text)
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 1c: api_score_explanation — country-isolated category_context
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION api_score_explanation(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'product_id',      m.product_id,
        'product_name',    m.product_name,
        'brand',           m.brand,
        'category',        m.category,
        'score_breakdown', m.score_breakdown,
        'summary', jsonb_build_object(
            'score',       m.unhealthiness_score,
            'score_band',  CASE
                             WHEN m.unhealthiness_score <= 25 THEN 'low'
                             WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                             WHEN m.unhealthiness_score <= 75 THEN 'high'
                             ELSE 'very_high'
                           END,
            'headline',    CASE
                             WHEN m.unhealthiness_score <= 15 THEN
                                 'This product scores very well. It has low levels of nutrients of concern.'
                             WHEN m.unhealthiness_score <= 30 THEN
                                 'This product has a moderate profile. Some areas could be better.'
                             WHEN m.unhealthiness_score <= 50 THEN
                                 'This product has several areas of nutritional concern.'
                             ELSE
                                 'This product has significant nutritional concerns across multiple factors.'
                           END,
            'nutri_score',    m.nutri_score_label,
            'nova_group',     m.nova_classification,
            'processing_risk',m.processing_risk
        ),
        'top_factors', (
            SELECT jsonb_agg(f ORDER BY (f->>'weighted')::numeric DESC)
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS f
            WHERE (f->>'weighted')::numeric > 0
        ),
        'warnings', (
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'message', 'Salt content exceeds 1.5g per 100g.')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'message', 'Sugar content is elevated.')             WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'message', 'Saturated fat content is elevated.')     WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'message', 'This product has a high additive load.') WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'message', 'Contains palm oil.')                     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'message', 'Classified as ultra-processed (NOVA 4).') WHERE m.nova_classification = '4'
            ) warnings
        ),
        'category_context', (
            SELECT jsonb_build_object(
                'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
                'category_rank',      (
                    SELECT COUNT(*) + 1
                    FROM v_master m2
                    WHERE m2.category = m.category
                      AND m2.country = m.country
                      AND m2.unhealthiness_score < m.unhealthiness_score
                ),
                'category_total',     COUNT(*)::int,
                'relative_position',  CASE
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score)       THEN 'better_than_average'
                    WHEN m.unhealthiness_score <= AVG(p2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                    ELSE 'much_worse_than_average'
                END
            )
            FROM products p2
            WHERE p2.category = m.category
              AND p2.country = m.country
              AND p2.is_deprecated IS NOT TRUE
        )
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 1d: v_api_category_overview_by_country — country-dimensioned stats
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.v_api_category_overview_by_country AS
SELECT
    p.country                                               AS country_code,
    cr.category,
    cr.display_name,
    cr.description                                          AS category_description,
    cr.icon_emoji,
    cr.sort_order,
    COUNT(*)::int                                           AS product_count,
    ROUND(AVG(p.unhealthiness_score), 1)                   AS avg_score,
    MIN(p.unhealthiness_score)::int                        AS min_score,
    MAX(p.unhealthiness_score)::int                        AS max_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY p.unhealthiness_score)::int              AS median_score,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE p.nutri_score_label IN ('A','B')
    ) / NULLIF(COUNT(*), 0), 1)                            AS pct_nutri_a_b,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE p.nova_classification = '4'
    ) / NULLIF(COUNT(*), 0), 1)                            AS pct_nova_4
FROM public.products p
JOIN public.category_ref cr  ON cr.category = p.category
JOIN public.country_ref cref ON cref.country_code = p.country
WHERE p.is_deprecated IS NOT TRUE
  AND cr.is_active   = true
  AND cref.is_active = true
GROUP BY p.country, cr.category, cr.display_name, cr.description,
         cr.icon_emoji, cr.sort_order
ORDER BY p.country, cr.sort_order;

COMMENT ON VIEW public.v_api_category_overview_by_country IS
'Country-dimensioned dashboard stats. Same columns as v_api_category_overview '
'plus country_code. One row per (country, category) pair.';

-- RPC-only model: no direct SELECT for API roles
REVOKE SELECT ON public.v_api_category_overview_by_country FROM anon, authenticated;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 2a: find_better_alternatives — country isolation
-- ═══════════════════════════════════════════════════════════════════════════════
-- Infers country from source product; candidates must be same country.

CREATE OR REPLACE FUNCTION find_better_alternatives(
  p_product_id bigint,
  p_same_category boolean DEFAULT true,
  p_limit integer DEFAULT 5
) RETURNS TABLE(
  alt_product_id bigint, product_name text, brand text, category text,
  unhealthiness_score integer, score_improvement integer, shared_ingredients integer,
  jaccard_similarity numeric, nutri_score_label text
) LANGUAGE sql STABLE AS $function$
    WITH target AS (
        SELECT p.product_id, p.category AS target_cat,
               p.unhealthiness_score AS target_score,
               p.country AS target_country
        FROM products p
        WHERE p.product_id = p_product_id
    ),
    target_ingredients AS (
        SELECT ingredient_id FROM product_ingredient WHERE product_id = p_product_id
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
        CROSS JOIN target t
        WHERE p2.is_deprecated IS NOT TRUE
          AND p2.product_id != p_product_id
          AND p2.country = t.target_country
          AND p2.unhealthiness_score < t.target_score
          AND (NOT p_same_category OR p2.category = t.target_cat)
        GROUP BY p2.product_id, p2.product_name, p2.brand, p2.category,
                 p2.unhealthiness_score, p2.nutri_score_label
    )
    SELECT c.cand_id, c.product_name, c.brand, c.category,
        c.unhealthiness_score::integer,
        (t.target_score - c.unhealthiness_score)::integer AS score_improvement,
        c.shared,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3),
        c.nutri_score_label
    FROM candidates c
    CROSS JOIN target t
    CROSS JOIN target_count tc
    ORDER BY (t.target_score - c.unhealthiness_score) DESC,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC
    LIMIT p_limit;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 2b: find_similar_products — country isolation
-- ═══════════════════════════════════════════════════════════════════════════════
-- Infers country from source product; candidates must be same country.

CREATE OR REPLACE FUNCTION find_similar_products(
  p_product_id bigint,
  p_limit integer DEFAULT 5
) RETURNS TABLE(
  similar_product_id bigint, product_name text, brand text, category text,
  unhealthiness_score integer, shared_ingredients integer,
  total_ingredients_a integer, total_ingredients_b integer, jaccard_similarity numeric
) LANGUAGE sql STABLE AS $function$
    WITH source_product AS (
        SELECT country FROM products WHERE product_id = p_product_id
    ),
    target_ingredients AS (
        SELECT ingredient_id FROM product_ingredient WHERE product_id = p_product_id
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
              SELECT product_id FROM products
              WHERE is_deprecated IS NOT TRUE
                AND country = (SELECT country FROM source_product)
          )
        GROUP BY pi2.product_id
        HAVING COUNT(DISTINCT pi2.ingredient_id) FILTER (
            WHERE pi2.ingredient_id IN (SELECT ingredient_id FROM target_ingredients)
        ) > 0
    )
    SELECT c.cand_id, p.product_name, p.brand, p.category,
        p.unhealthiness_score::integer, c.shared, tc.cnt, c.cand_total,
        ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3)
    FROM candidates c
    CROSS JOIN target_count tc
    JOIN products p ON p.product_id = c.cand_id
    ORDER BY ROUND(c.shared::numeric / NULLIF(tc.cnt + c.cand_total - c.shared, 0), 3) DESC,
        p.unhealthiness_score ASC
    LIMIT p_limit;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 3: score_category — country-parameterized (no more hardcoded 'PL')
-- ═══════════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS score_category(text, integer);

CREATE OR REPLACE PROCEDURE score_category(
    p_category          text,
    p_data_completeness integer DEFAULT 100,
    p_country           text    DEFAULT 'PL'
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- 0. DEFAULT concern score for products without ingredient data
    UPDATE products
    SET    ingredient_concern_score = 0
    WHERE  country = p_country
      AND  category = p_category
      AND  is_deprecated IS NOT TRUE
      AND  ingredient_concern_score IS NULL;

    -- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
    UPDATE products p
    SET    unhealthiness_score = compute_unhealthiness_v32(
               nf.saturated_fat_g,
               nf.sugars_g,
               nf.salt_g,
               nf.calories,
               nf.trans_fat_g,
               ia.additives_count,
               p.prep_method,
               p.controversies,
               p.ingredient_concern_score
           )
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 4. Health-risk flags + DYNAMIC data_completeness_pct
    UPDATE products p
    SET    high_salt_flag    = CASE WHEN nf.salt_g >= 1.5 THEN 'YES' ELSE 'NO' END,
           high_sugar_flag   = CASE WHEN nf.sugars_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_sat_fat_flag = CASE WHEN nf.saturated_fat_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_additive_load = CASE WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END,
           data_completeness_pct = compute_data_completeness(p.product_id)
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 5. SET confidence level
    UPDATE products p
    SET    confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
    WHERE  p.country = p_country
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 6. AUTO-REFRESH materialized views
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
END;
$procedure$;

COMMENT ON PROCEDURE score_category(text, int, text) IS
'Consolidated scoring procedure for a given category and country. '
'Steps: 0 (concern defaults), 1 (unhealthiness v3.2), 4 (flags + dynamic data_completeness), '
'5 (confidence), 6 (auto-refresh MVs). '
'p_country defaults to ''PL'' for backward compatibility. '
'p_data_completeness is retained for backward compatibility but ignored.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- BLOCKER 4: Activation gating — ensure country_ref.is_active is enforced
-- ═══════════════════════════════════════════════════════════════════════════════
-- No schema changes needed — country_ref.is_active already exists.
-- Enforcement is via QA checks (added to QA__api_surfaces.sql):
--   "no non-deprecated products for inactive countries"
-- Pipeline scripts should check is_active before running.

-- ═══════════════════════════════════════════════════════════════════════════════
-- Security: re-grant EXECUTE on score_category to service_role
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON PROCEDURE score_category(text, int, text) TO service_role;

COMMIT;

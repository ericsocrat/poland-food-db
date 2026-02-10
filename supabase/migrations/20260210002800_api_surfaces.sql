-- Migration: API & UX Surface Hardening (Phase 6)
-- Date: 2026-02-10
-- Purpose: Create read-only API views and RPC functions for frontend consumption.
--          These hide internal columns, enforce stable response shapes, and
--          support pagination + sorting. Matching indexes are added for performance.
--
-- Surfaces created:
--   1. v_api_category_overview  — dashboard stats per category
--   2. api_product_detail()     — single product structured JSON
--   3. api_category_listing()   — paged category browse
--   4. api_score_explanation()  — human-readable + structured score breakdown
--   5. api_better_alternatives()— healthier substitutes wrapper
--   6. api_search_products()    — full-text + trigram search

BEGIN;

-- ============================================================
-- 0. Enable pg_trgm for fuzzy search
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;


-- ============================================================
-- 1. Supporting indexes for API query patterns
-- ============================================================

-- Composite index for sorted category listings (most common query pattern)
CREATE INDEX IF NOT EXISTS idx_products_category_score
    ON products (category, product_id);

-- Index on scores for fast unhealthiness lookups
CREATE INDEX IF NOT EXISTS idx_scores_unhealthiness
    ON scores (product_id, unhealthiness_score);

-- Trigram index for fuzzy product name search
CREATE INDEX IF NOT EXISTS idx_products_name_trgm
    ON products USING gin (product_name gin_trgm_ops);

-- Trigram index on brand for search
CREATE INDEX IF NOT EXISTS idx_products_brand_trgm
    ON products USING gin (brand gin_trgm_ops);


-- ============================================================
-- 2. v_api_category_overview — Dashboard stats per category
-- ============================================================
-- Used by: Home / Dashboard screen
-- Returns one row per active category with product count, score stats, and display metadata.

CREATE OR REPLACE VIEW public.v_api_category_overview AS
SELECT
    cr.category,
    cr.display_name,
    cr.description       AS category_description,
    cr.icon_emoji,
    cr.sort_order,
    stats.product_count,
    stats.avg_score,
    stats.min_score,
    stats.max_score,
    stats.median_score,
    stats.pct_nutri_a_b,
    stats.pct_nova_4
FROM public.category_ref cr
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int                                        AS product_count,
        ROUND(AVG(s.unhealthiness_score), 1)                AS avg_score,
        MIN(s.unhealthiness_score)::int                     AS min_score,
        MAX(s.unhealthiness_score)::int                     AS max_score,
        PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY s.unhealthiness_score)::int           AS median_score,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE s.nutri_score_label IN ('A','B')
        ) / NULLIF(COUNT(*), 0), 1)                         AS pct_nutri_a_b,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE s.nova_classification = '4'
        ) / NULLIF(COUNT(*), 0), 1)                         AS pct_nova_4
    FROM public.products p
    JOIN public.scores s ON s.product_id = p.product_id
    WHERE p.category = cr.category
      AND p.is_deprecated IS NOT TRUE
) stats ON true
WHERE cr.is_active = true
ORDER BY cr.sort_order;

COMMENT ON VIEW public.v_api_category_overview IS
    'Dashboard-ready category statistics. One row per active category with '
    'product count, score distribution, and display metadata from category_ref. '
    'Columns: category, display_name, category_description, icon_emoji, sort_order, '
    'product_count, avg_score, min_score, max_score, median_score, pct_nutri_a_b, pct_nova_4.';


-- ============================================================
-- 3. api_product_detail() — Single product detail (JSON)
-- ============================================================
-- Used by: Product Detail screen
-- Returns a single structured JSONB object with nested sections.
-- Intentionally omits: ingredients_raw, source_url, source_ean, source_fields,
--   source_collected_at, source_notes, scoring_version, scored_at, controversies,
--   ingredient_concern_score.

CREATE OR REPLACE FUNCTION api_product_detail(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        -- Identity
        'product_id',          m.product_id,
        'ean',                 m.ean,
        'product_name',        m.product_name,
        'brand',               m.brand,
        'category',            m.category,
        'category_display',    cr.display_name,
        'category_icon',       cr.icon_emoji,
        'product_type',        m.product_type,
        'country',             m.country,
        'store_availability',  m.store_availability,
        'prep_method',         m.prep_method,

        -- Scores
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nutri_score_color',   nsr.color_hex,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk
        ),

        -- Flags
        'flags', jsonb_build_object(
            'high_salt',           (m.high_salt_flag = 'YES'),
            'high_sugar',          (m.high_sugar_flag = 'YES'),
            'high_sat_fat',        (m.high_sat_fat_flag = 'YES'),
            'high_additive_load',  (m.high_additive_load = 'YES'),
            'has_palm_oil',        COALESCE(m.has_palm_oil, false)
        ),

        -- Nutrition per 100g
        'nutrition_per_100g', jsonb_build_object(
            'calories',       m.calories,
            'total_fat_g',    m.total_fat_g,
            'saturated_fat_g',m.saturated_fat_g,
            'trans_fat_g',    m.trans_fat_g,
            'carbs_g',        m.carbs_g,
            'sugars_g',       m.sugars_g,
            'fibre_g',        m.fibre_g,
            'protein_g',      m.protein_g,
            'salt_g',         m.salt_g
        ),

        -- Nutrition per serving (nullable — only if real serving exists)
        'nutrition_per_serving', CASE WHEN m.serving_amount_g IS NOT NULL THEN
            jsonb_build_object(
                'serving_g',      m.serving_amount_g,
                'calories',       m.srv_calories,
                'total_fat_g',    m.srv_total_fat_g,
                'saturated_fat_g',m.srv_saturated_fat_g,
                'trans_fat_g',    m.srv_trans_fat_g,
                'carbs_g',        m.srv_carbs_g,
                'sugars_g',       m.srv_sugars_g,
                'fibre_g',        m.srv_fibre_g,
                'protein_g',      m.srv_protein_g,
                'salt_g',         m.srv_salt_g
            )
            ELSE NULL
        END,

        -- Ingredients
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additives_count',    m.additives_count,
            'additive_names',     m.additive_names,
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'data_quality',       m.ingredient_data_quality
        ),

        -- Allergens
        'allergens', jsonb_build_object(
            'count',         m.allergen_count,
            'tags',          m.allergen_tags,
            'trace_count',   m.trace_count,
            'trace_tags',    m.trace_tags
        ),

        -- Data trust
        'trust', jsonb_build_object(
            'confidence',            m.confidence,
            'data_completeness_pct', m.data_completeness_pct,
            'source_type',           m.source_type,
            'source_confidence_pct', m.source_confidence,
            'nutrition_data_quality', m.nutrition_data_quality,
            'ingredient_data_quality',m.ingredient_data_quality
        )
    )
    FROM public.v_master m
    LEFT JOIN public.category_ref cr ON cr.category = m.category
    LEFT JOIN public.nutri_score_ref nsr ON nsr.label = m.nutri_score_label
    WHERE m.product_id = p_product_id;
$$;

COMMENT ON FUNCTION api_product_detail IS
    'Returns a single product as structured JSONB with nested sections: identity, '
    'scores, flags, nutrition_per_100g, nutrition_per_serving, ingredients, allergens, trust. '
    'Hides internal columns (ingredients_raw, source_url, scoring_version, etc.).';


-- ============================================================
-- 4. api_category_listing() — Paged category browse
-- ============================================================
-- Used by: Category Listing screen
-- Supports sorting by score, calories, protein, name, nutri-score.
-- Returns a JSON object with metadata + rows array.

CREATE OR REPLACE FUNCTION api_category_listing(
    p_category   text,
    p_sort_by    text    DEFAULT 'score',    -- score | calories | protein | name | nutri_score
    p_sort_dir   text    DEFAULT 'asc',      -- asc | desc
    p_limit      integer DEFAULT 20,
    p_offset     integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE AS $$
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
    WHERE category = p_category;

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
        'category',      p_category,
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'sort_by',       p_sort_by,
        'sort_dir',      p_sort_dir,
        'products',      v_rows
    );
END;
$$;

COMMENT ON FUNCTION api_category_listing IS
    'Paged category listing. Params: p_category (required), p_sort_by (score|calories|protein|name|nutri_score), '
    'p_sort_dir (asc|desc), p_limit (1-100, default 20), p_offset (default 0). '
    'Returns JSON with total_count + products array. Each product has: product_id, ean, product_name, brand, '
    'unhealthiness_score, score_band, nutri_score, nova_group, processing_risk, key nutrition, flags, and confidence.';


-- ============================================================
-- 5. api_score_explanation() — Score breakdown for a product
-- ============================================================
-- Used by: "Why this score?" modal / panel
-- Returns structured breakdown + human-readable summary sentences.

CREATE OR REPLACE FUNCTION api_score_explanation(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'product_id',      m.product_id,
        'product_name',    m.product_name,
        'brand',           m.brand,
        'category',        m.category,

        -- Structured breakdown (from explain_score_v32)
        'score_breakdown', m.score_breakdown,

        -- Human-readable summary
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

        -- Top contributing factors (sorted by weighted contribution descending)
        'top_factors', (
            SELECT jsonb_agg(f ORDER BY (f->>'weighted')::numeric DESC)
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS f
            WHERE (f->>'weighted')::numeric > 0
        ),

        -- Contextual warnings
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

        -- Category context
        'category_context', (
            SELECT jsonb_build_object(
                'category_avg_score', ROUND(AVG(s2.unhealthiness_score), 1),
                'category_rank',      (
                    SELECT COUNT(*) + 1
                    FROM v_master m2
                    WHERE m2.category = m.category
                      AND m2.unhealthiness_score < m.unhealthiness_score
                ),
                'category_total',     COUNT(*)::int,
                'relative_position',  CASE
                    WHEN m.unhealthiness_score <= AVG(s2.unhealthiness_score) * 0.7 THEN 'much_better_than_average'
                    WHEN m.unhealthiness_score <= AVG(s2.unhealthiness_score)       THEN 'better_than_average'
                    WHEN m.unhealthiness_score <= AVG(s2.unhealthiness_score) * 1.3 THEN 'worse_than_average'
                    ELSE 'much_worse_than_average'
                END
            )
            FROM products p2
            JOIN scores s2 ON s2.product_id = p2.product_id
            WHERE p2.category = m.category AND p2.is_deprecated IS NOT TRUE
        )
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$$;

COMMENT ON FUNCTION api_score_explanation IS
    'Returns structured + human-readable score explanation for a product. '
    'Includes: score_breakdown (9 factors), summary (headline, band), top_factors (sorted by impact), '
    'warnings (active flags), and category_context (rank, avg, relative position). '
    'Used by "Why this score?" UX entry point.';


-- ============================================================
-- 6. api_better_alternatives() — Healthier substitutes wrapper
-- ============================================================
-- Wraps find_better_alternatives() with additional context for frontend display.

CREATE OR REPLACE FUNCTION api_better_alternatives(
    p_product_id     bigint,
    p_same_category  boolean DEFAULT true,
    p_limit          integer DEFAULT 5
)
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'source_product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'brand',              m.brand,
            'category',           m.category,
            'unhealthiness_score',m.unhealthiness_score,
            'nutri_score',        m.nutri_score_label
        ),
        'search_scope',    CASE WHEN p_same_category THEN 'same_category' ELSE 'all_categories' END,
        'alternatives',    COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_improvement',  alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity,
                'shared_ingredients', alt.shared_ingredients
            ))
            FROM find_better_alternatives(p_product_id, p_same_category, p_limit) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives(p_product_id, p_same_category, p_limit)
        ), 0)
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$$;

COMMENT ON FUNCTION api_better_alternatives IS
    'Returns healthier alternatives for a product. Wraps find_better_alternatives() with '
    'source product context and structured JSON output. Params: p_product_id, '
    'p_same_category (default true), p_limit (default 5).';


-- ============================================================
-- 7. api_search_products() — Full-text + trigram search
-- ============================================================
-- Used by: Search bar (instant results)
-- Searches product_name and brand using trigram similarity.
-- Returns compact result set suitable for autocomplete / search results.

CREATE OR REPLACE FUNCTION api_search_products(
    p_query      text,
    p_category   text    DEFAULT NULL,
    p_limit      integer DEFAULT 20,
    p_offset     integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_total   integer;
    v_rows    jsonb;
    v_query   text;
BEGIN
    -- Normalize query
    v_query := TRIM(p_query);

    IF LENGTH(v_query) < 2 THEN
        RETURN jsonb_build_object('error', 'Query must be at least 2 characters.');
    END IF;

    -- Clamp pagination
    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    -- Count matches
    SELECT COUNT(*)::int INTO v_total
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND (
          p.product_name ILIKE '%' || v_query || '%'
          OR p.brand ILIKE '%' || v_query || '%'
          OR similarity(p.product_name, v_query) > 0.15
      );

    -- Build results sorted by relevance
    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'brand',               p.brand,
            'category',            p.category,
            'unhealthiness_score', s.unhealthiness_score,
            'score_band',          CASE
                                     WHEN s.unhealthiness_score <= 25 THEN 'low'
                                     WHEN s.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN s.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         s.nutri_score_label,
            'nova_group',          s.nova_classification,
            'relevance',           GREATEST(
                                     similarity(p.product_name, v_query),
                                     similarity(p.brand, v_query) * 0.8
                                   )
        ) AS row_data
        FROM products p
        LEFT JOIN scores s ON s.product_id = p.product_id
        WHERE p.is_deprecated IS NOT TRUE
          AND (p_category IS NULL OR p.category = p_category)
          AND (
              p.product_name ILIKE '%' || v_query || '%'
              OR p.brand ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
        ORDER BY
            -- Exact prefix match first
            CASE WHEN p.product_name ILIKE v_query || '%' THEN 0 ELSE 1 END,
            -- Then by similarity
            GREATEST(similarity(p.product_name, v_query), similarity(p.brand, v_query) * 0.8) DESC,
            -- Then by score
            s.unhealthiness_score ASC NULLS LAST
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'query',       v_query,
        'category',    p_category,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$$;

COMMENT ON FUNCTION api_search_products IS
    'Full-text + trigram search across product names and brands. '
    'Params: p_query (min 2 chars), p_category (optional filter), p_limit (1-100), p_offset. '
    'Returns JSON with total_count + results array sorted by relevance. '
    'Uses pg_trgm similarity() + ILIKE for fuzzy matching.';


COMMIT;

-- ==========================================================================
-- Migration: 20260311000400_store_api_functions.sql
-- Purpose:   Create 3 new store API functions and update api_product_detail
--            to include stores key as an additive, backward-compatible change.
--            Part of #350 — Store Architecture.
-- Rollback:  DROP FUNCTION IF EXISTS api_product_stores;
--            DROP FUNCTION IF EXISTS api_store_products;
--            DROP FUNCTION IF EXISTS api_list_stores;
--            (Restore previous api_product_detail from migration backup)
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_product_stores(product_id) — "Where can I buy this?"
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.api_product_stores(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT jsonb_build_object(
        'api_version', '1.0',
        'product_id',  p_product_id,
        'stores',      COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'store_id',    sr.store_id,
                'store_name',  sr.store_name,
                'store_slug',  sr.store_slug,
                'store_type',  sr.store_type,
                'country',     sr.country,
                'website_url', sr.website_url,
                'verified_at', psa.verified_at,
                'source',      psa.source
            ) ORDER BY sr.sort_order)
            FROM product_store_availability psa
            JOIN store_ref sr ON sr.store_id = psa.store_id
            WHERE psa.product_id = p_product_id
              AND sr.is_active = true),
            '[]'::jsonb
        )
    );
$function$;

COMMENT ON FUNCTION public.api_product_stores(bigint) IS
'Returns all active stores where a product is available. Auth: authenticated.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_store_products(store_slug, country, limit, offset)
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.api_store_products(
    p_store_slug text,
    p_country    text DEFAULT 'PL',
    p_limit      integer DEFAULT 50,
    p_offset     integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT jsonb_build_object(
        'api_version',  '1.0',
        'store_slug',   p_store_slug,
        'country',      p_country,
        'store',        (SELECT jsonb_build_object(
            'store_id',   sr.store_id,
            'store_name', sr.store_name,
            'store_slug', sr.store_slug,
            'store_type', sr.store_type,
            'website_url',sr.website_url
        ) FROM store_ref sr
        WHERE sr.store_slug = p_store_slug AND sr.country = p_country AND sr.is_active = true
        LIMIT 1),
        'total_count',  (SELECT COUNT(*)::int
            FROM product_store_availability psa
            JOIN store_ref sr ON sr.store_id = psa.store_id
            JOIN products p ON p.product_id = psa.product_id
            WHERE sr.store_slug = p_store_slug
              AND sr.country = p_country
              AND sr.is_active = true
              AND p.is_deprecated = false),
        'products',     COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'product_id',         p.product_id,
                'product_name',       p.product_name,
                'brand',              p.brand,
                'category',           p.category,
                'unhealthiness_score',p.unhealthiness_score,
                'nutri_score_label',  p.nutri_score_label,
                'ean',                p.ean
            ) ORDER BY p.unhealthiness_score NULLS LAST)
            FROM (
                SELECT p2.*
                FROM product_store_availability psa2
                JOIN store_ref sr2 ON sr2.store_id = psa2.store_id
                JOIN products p2 ON p2.product_id = psa2.product_id
                WHERE sr2.store_slug = p_store_slug
                  AND sr2.country = p_country
                  AND sr2.is_active = true
                  AND p2.is_deprecated = false
                ORDER BY p2.unhealthiness_score NULLS LAST
                LIMIT LEAST(p_limit, 100)
                OFFSET p_offset
            ) p),
            '[]'::jsonb
        )
    );
$function$;

COMMENT ON FUNCTION public.api_store_products(text, text, integer, integer) IS
'Returns paginated products available at a given store. Default sort: healthiest first. Auth: authenticated.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_list_stores(country) — "What stores exist in this country?"
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.api_list_stores(
    p_country text DEFAULT 'PL'
)
RETURNS jsonb
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT jsonb_build_object(
        'api_version', '1.0',
        'country',     p_country,
        'stores',      COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'store_id',      sr.store_id,
                'store_name',    sr.store_name,
                'store_slug',    sr.store_slug,
                'store_type',    sr.store_type,
                'website_url',   sr.website_url,
                'product_count', COALESCE(pc.cnt, 0)
            ) ORDER BY sr.sort_order)
            FROM store_ref sr
            LEFT JOIN (
                SELECT psa.store_id, COUNT(*)::int AS cnt
                FROM product_store_availability psa
                JOIN products p ON p.product_id = psa.product_id
                WHERE p.is_deprecated = false
                GROUP BY psa.store_id
            ) pc ON pc.store_id = sr.store_id
            WHERE sr.country = p_country
              AND sr.is_active = true),
            '[]'::jsonb
        )
    );
$function$;

COMMENT ON FUNCTION public.api_list_stores(text) IS
'Returns all active stores for a country with product counts. Auth: authenticated.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Update api_product_detail() — add 'stores' key (additive)
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.api_product_detail(p_product_id bigint)
RETURNS jsonb
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
    SELECT jsonb_build_object(
        'api_version',         '1.0',
        'product_id',          m.product_id,
        'ean',                 m.ean,
        'product_name',        m.product_name,
        'product_name_en',     m.product_name_en,
        'product_name_display', CASE
            WHEN resolve_language(NULL) = COALESCE(cref.default_language, LOWER(m.country))
                THEN m.product_name
            WHEN resolve_language(NULL) = 'en'
                THEN COALESCE(m.product_name_en, m.product_name)
            ELSE COALESCE(
                m.name_translations->>resolve_language(NULL),
                m.product_name_en,
                m.product_name
            )
        END,
        'original_language',   COALESCE(cref.default_language, LOWER(m.country)),
        'brand',               m.brand,
        'category',            m.category,
        'category_display',    COALESCE(ct.display_name, cr.display_name),
        'category_icon',       COALESCE(cr.icon_emoji, '📦'),
        'product_type',        m.product_type,
        'country',             m.country,
        'store_availability',  m.store_availability,
        'prep_method',         m.prep_method,
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nutri_score_color',   COALESCE(ns.color_hex, '#999999'),
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk
        ),
        'flags', jsonb_build_object(
            'high_salt',          (m.high_salt_flag = 'YES'),
            'high_sugar',         (m.high_sugar_flag = 'YES'),
            'high_sat_fat',       (m.high_sat_fat_flag = 'YES'),
            'high_additive_load', (m.high_additive_load = 'YES'),
            'has_palm_oil',       (m.has_palm_oil = 'YES')
        ),
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
        'ingredients', jsonb_build_object(
            'count',            m.ingredient_count,
            'additives_count',  m.additives_count,
            'additive_names',   m.additive_names,
            'vegan_status',     m.vegan_status,
            'vegetarian_status',m.vegetarian_status,
            'data_quality',     m.ingredient_data_quality
        ),
        'allergens', jsonb_build_object(
            'count',       m.allergen_count,
            'tags',        m.allergen_tags,
            'trace_count', m.trace_count,
            'trace_tags',  m.trace_tags
        ),
        'stores', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'store_name', sr.store_name,
                'store_slug', sr.store_slug,
                'store_type', sr.store_type
            ) ORDER BY sr.sort_order)
            FROM product_store_availability psa
            JOIN store_ref sr ON sr.store_id = psa.store_id
            WHERE psa.product_id = m.product_id
              AND sr.is_active = true),
            '[]'::jsonb
        ),
        'trust', jsonb_build_object(
            'confidence',            m.confidence,
            'data_completeness_pct', m.data_completeness_pct,
            'source_type',           m.source_type,
            'nutrition_data_quality', m.nutrition_data_quality,
            'ingredient_data_quality',m.ingredient_data_quality
        ),
        'freshness', jsonb_build_object(
            'created_at',     m.created_at,
            'updated_at',     m.updated_at,
            'data_age_days',  EXTRACT(day FROM now() - m.updated_at)::int
        )
    )
    FROM v_master m
    LEFT JOIN category_ref cr ON cr.category = m.category
    LEFT JOIN category_translations ct
        ON ct.category = m.category AND ct.language_code = resolve_language(NULL)
    LEFT JOIN nutri_score_ref ns ON ns.label = m.nutri_score_label
    LEFT JOIN country_ref cref ON cref.country_code = m.country
    WHERE m.product_id = p_product_id;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Grants for new functions (auth-only; revoke default PUBLIC)
-- ═══════════════════════════════════════════════════════════════════════════
REVOKE ALL ON FUNCTION public.api_product_stores(bigint) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.api_store_products(text, text, integer, integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.api_list_stores(text) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.api_product_stores(bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_store_products(text, text, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_list_stores(text) TO authenticated;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Auto-Country Resolution & Allergen Tag Enforcement
--
-- Closes three gaps:
--   1. resolve_effective_country() — when p_country IS NULL, resolve from
--      user_preferences.country (auth.uid()), else fall back to first active
--      country. All API surfaces now always operate in a single-country scope.
--   2. api_product_detail_by_ean resolves country before lookup — no
--      cross-country results possible even with p_country = NULL.
--   3. CHECK constraint on product_allergen_info.tag enforcing 'en:' prefix
--      at the schema level (was QA-only before).
--
-- All changes are backward-compatible:
--   - Callers that already pass p_country see identical behavior.
--   - Callers that omit p_country now get user-scoped results instead of
--     mixed-country results (strictly better behavior).
--   - api_version stays at '1.0'.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. resolve_effective_country() — internal helper
--    Priority: explicit param → user_preferences.country → first active country
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.resolve_effective_country(
    p_country text DEFAULT NULL
)
RETURNS text
LANGUAGE sql STABLE
AS $function$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (pass-through if not NULL)
        NULLIF(TRIM(p_country), ''),
        -- Priority 2: authenticated user's saved country preference
        (SELECT up.country
         FROM user_preferences up
         WHERE up.user_id = auth.uid()),
        -- Priority 3: first active country (deterministic via ORDER BY)
        (SELECT cr.country_code
         FROM country_ref cr
         WHERE cr.is_active = true
         ORDER BY cr.country_code
         LIMIT 1)
    );
$function$;

COMMENT ON FUNCTION public.resolve_effective_country(text) IS
'Resolves the effective country for API calls. '
'Priority: explicit param → user_preferences.country → first active country. '
'Guarantees a non-NULL country is always returned.';

-- Internal function: not callable by anon
REVOKE EXECUTE ON FUNCTION public.resolve_effective_country(text) FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Update api_search_products — resolve country at entry
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.api_search_products(
    text, text, integer, integer, text, text, text[], boolean, boolean, boolean
);

CREATE OR REPLACE FUNCTION public.api_search_products(
    p_query                   text,
    p_category                text     DEFAULT NULL,
    p_limit                   integer  DEFAULT 20,
    p_offset                  integer  DEFAULT 0,
    p_country                 text     DEFAULT NULL,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total    integer;
    v_rows     jsonb;
    v_query    text;
    v_country  text;
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

    -- Resolve effective country (never NULL)
    v_country := resolve_effective_country(p_country);

    SELECT COUNT(*)::int INTO v_total
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND p.country = v_country
      AND (
          p.product_name ILIKE '%' || v_query || '%'
          OR p.brand ILIKE '%' || v_query || '%'
          OR similarity(p.product_name, v_query) > 0.15
      )
      AND check_product_preferences(
          p.product_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
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
          AND p.country = v_country
          AND (
              p.product_name ILIKE '%' || v_query || '%'
              OR p.brand ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
          AND check_product_preferences(
              p.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
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
        'country',     v_country,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$function$;

COMMENT ON FUNCTION public.api_search_products IS
'Full-text + trigram search. Country is auto-resolved: explicit param → '
'user_preferences.country → first active country. Never returns mixed-country results.';

GRANT EXECUTE ON FUNCTION public.api_search_products
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_search_products
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Update api_category_listing — resolve country at entry
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
);

CREATE OR REPLACE FUNCTION public.api_category_listing(
    p_category                text,
    p_sort_by                 text     DEFAULT 'score',
    p_sort_dir                text     DEFAULT 'asc',
    p_limit                   integer  DEFAULT 20,
    p_offset                  integer  DEFAULT 0,
    p_country                 text     DEFAULT NULL,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total    integer;
    v_rows     jsonb;
    v_order    text;
    v_country  text;
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

    -- Resolve effective country (never NULL)
    v_country := resolve_effective_country(p_country);

    -- Get total count
    SELECT COUNT(*)::int INTO v_total
    FROM v_master m
    WHERE m.category = p_category
      AND m.country = v_country
      AND check_product_preferences(
          m.product_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
      );

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
          AND m.country = v_country
          AND check_product_preferences(
              m.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
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
        'country',       v_country,
        'total_count',   v_total,
        'limit',         p_limit,
        'offset',        p_offset,
        'sort_by',       p_sort_by,
        'sort_dir',      p_sort_dir,
        'products',      v_rows
    );
END;
$function$;

COMMENT ON FUNCTION public.api_category_listing IS
'Paged category browse. Country is auto-resolved: explicit param → '
'user_preferences.country → first active country. Never returns mixed-country results.';

GRANT EXECUTE ON FUNCTION public.api_category_listing
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_category_listing
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Update api_product_detail_by_ean — resolve country before lookup
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.api_product_detail_by_ean(text, text);

CREATE OR REPLACE FUNCTION public.api_product_detail_by_ean(
    p_ean     text,
    p_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_product_id bigint;
    v_result     jsonb;
    v_country    text;
BEGIN
    -- Resolve effective country (never NULL — prevents cross-country results)
    v_country := resolve_effective_country(p_country);

    -- Find the product by EAN within the resolved country
    SELECT p.product_id INTO v_product_id
    FROM products p
    WHERE p.ean = p_ean
      AND p.is_deprecated IS NOT TRUE
      AND p.country = v_country
    LIMIT 1;

    IF v_product_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'ean',         p_ean,
            'country',     v_country,
            'found',       false,
            'error',       'Product not found for this barcode.'
        );
    END IF;

    -- Reuse existing api_product_detail for the full payload
    v_result := api_product_detail(v_product_id);

    -- Enrich with scanner-specific metadata
    RETURN v_result || jsonb_build_object(
        'scan', jsonb_build_object(
            'scanned_ean',      p_ean,
            'found',            true,
            'alternative_count', COALESCE((
                SELECT COUNT(*)::int
                FROM find_better_alternatives(v_product_id, true, 5)
            ), 0)
        )
    );
END;
$function$;

COMMENT ON FUNCTION public.api_product_detail_by_ean(text, text) IS
'Barcode scanner endpoint. Country is auto-resolved: explicit param → '
'user_preferences.country → first active country. Cross-country results impossible.';

GRANT EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Update api_better_alternatives — resolve country for response metadata
--    (find_better_alternatives already infers country from source product,
--     but api_better_alternatives should echo the resolved country)
-- ═══════════════════════════════════════════════════════════════════════════════

-- api_better_alternatives delegates to find_better_alternatives which already
-- country-isolates by inferring from the source product. No change needed to
-- the internal logic, but we don't need to modify it here since country is
-- inferred from p_product_id, not from a p_country param.

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. CHECK constraint on product_allergen_info.tag enforcing 'en:' prefix
--    Previously only QA-checked (checks #1-#2 in QA__allergen_integrity.sql).
--    Now enforced at schema level to prevent bad data at insertion.
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.product_allergen_info
    ADD CONSTRAINT chk_allergen_tag_en_prefix
    CHECK (tag LIKE 'en:%');

COMMENT ON CONSTRAINT chk_allergen_tag_en_prefix ON public.product_allergen_info IS
'Enforces Open Food Facts en: taxonomy prefix on all allergen tags. '
'Prevents locale-specific junk tags (pl:, sr:) from entering the system.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Add resolve_effective_country to internal function block list
--    (already revoked above, but ensure security posture awareness)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Already done: REVOKE FROM PUBLIC, anon above.

COMMIT;

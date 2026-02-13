-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: User Personalization, Scanner & Preference-Aware Alternatives
--
-- Implements the "User Personalization + Scanner + Alternatives System":
--   1. user_preferences table (country, diet, allergens, strict modes)
--   2. api_product_detail_by_ean — barcode scanner endpoint
--   3. Preference-aware API surfaces (search, listing, alternatives)
--   4. Performance indexes (country btree, allergen GIN)
--   5. RLS policies for user_preferences (auth.uid()-scoped)
--
-- All changes are backward-compatible:
--   - Existing API callers (without preference params) get same behavior
--   - api_version stays at '1.0' (additive params only)
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. user_preferences table
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id                      uuid        NOT NULL DEFAULT auth.uid() PRIMARY KEY,
    country                      text        NOT NULL DEFAULT 'PL',
    diet_preference              text            NULL,
    avoid_allergens              text[]          NULL,
    strict_allergen              boolean     NOT NULL DEFAULT false,
    strict_diet                  boolean     NOT NULL DEFAULT false,
    treat_may_contain_as_unsafe  boolean     NOT NULL DEFAULT false,
    created_at                   timestamptz NOT NULL DEFAULT now(),
    updated_at                   timestamptz NOT NULL DEFAULT now(),

    -- Validate enum values
    CONSTRAINT chk_diet_preference
        CHECK (diet_preference IS NULL OR diet_preference IN ('none','vegetarian','vegan')),
    -- Validate allergen tags use en: prefix (matches product_allergen_info format)
    CONSTRAINT chk_avoid_allergens_format
        CHECK (avoid_allergens IS NULL
            OR cardinality(avoid_allergens) = 0
            OR array_to_string(avoid_allergens, ',') ~ '^en:[^,]+(,en:[^,]+)*$'
        )
);

COMMENT ON TABLE public.user_preferences IS
'Per-user personalization settings: country, diet preference, allergen exclusions, '
'and strict mode toggles. One row per authenticated user. RLS-protected.';

COMMENT ON COLUMN public.user_preferences.diet_preference IS
'null or ''none'' = no filter; ''vegetarian'' excludes non-vegetarian; ''vegan'' excludes non-vegan.';

COMMENT ON COLUMN public.user_preferences.avoid_allergens IS
'Array of allergen tags in en: format (e.g. ARRAY[''en:gluten'', ''en:milk'']). '
'Matched against product_allergen_info.tag.';

COMMENT ON COLUMN public.user_preferences.strict_allergen IS
'When true, products with unknown allergen data are hidden. '
'When false, they appear with a warning label.';

COMMENT ON COLUMN public.user_preferences.strict_diet IS
'When true, products with unknown vegan/vegetarian status are hidden. '
'When false, they appear with an "unknown" label.';

COMMENT ON COLUMN public.user_preferences.treat_may_contain_as_unsafe IS
'When true, allergens listed as "traces" (may contain) are treated as unsafe. '
'When false, only "contains" allergens trigger exclusion.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1b. RLS on user_preferences — users can only CRUD their own row
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences FORCE ROW LEVEL SECURITY;

-- SELECT: user can read their own preferences
CREATE POLICY "user_preferences_select_own"
    ON public.user_preferences FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: user can create their own preferences
CREATE POLICY "user_preferences_insert_own"
    ON public.user_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: user can update their own preferences
CREATE POLICY "user_preferences_update_own"
    ON public.user_preferences FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: user can delete their own preferences
CREATE POLICY "user_preferences_delete_own"
    ON public.user_preferences FOR DELETE
    USING (auth.uid() = user_id);

-- Service role needs full access for admin/scoring operations
GRANT ALL ON public.user_preferences TO service_role;
-- Authenticated users use RLS policies above
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_preferences TO authenticated;
-- Anon cannot access user_preferences at all
REVOKE ALL ON public.user_preferences FROM anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1c. updated_at auto-trigger for user_preferences
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.trg_set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$func$;

CREATE TRIGGER user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Performance indexes
-- ═══════════════════════════════════════════════════════════════════════════════

-- Country standalone index — powers all country-filtered queries
CREATE INDEX IF NOT EXISTS idx_products_country
    ON public.products (country)
    WHERE is_deprecated IS NOT TRUE;

-- Fast tag lookups for allergen filtering (covers tag = ANY(array))
-- Note: idx_allergen_info_tag (btree on tag) already exists

-- Composite index for allergen type + product lookup
CREATE INDEX IF NOT EXISTS idx_allergen_info_product_type
    ON public.product_allergen_info (product_id, type);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Barcode scanner endpoint: api_product_detail_by_ean
-- ═══════════════════════════════════════════════════════════════════════════════

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
BEGIN
    -- Find the product by EAN (+ optional country filter)
    SELECT p.product_id INTO v_product_id
    FROM products p
    WHERE p.ean = p_ean
      AND p.is_deprecated IS NOT TRUE
      AND (p_country IS NULL OR p.country = p_country)
    LIMIT 1;

    IF v_product_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'ean',         p_ean,
            'country',     p_country,
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
'Barcode scanner endpoint. Looks up product by EAN (optionally scoped to country). '
'Returns full api_product_detail payload + scan metadata (found, alternative_count). '
'Returns error JSON if EAN not found.';

GRANT EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Helper: check_product_preferences — reusable filter logic
--    Returns true if a product PASSES preference filters (should be shown)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.check_product_preferences(
    p_product_id              bigint,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS boolean
LANGUAGE sql STABLE
AS $function$
    SELECT
        -- Diet filter
        CASE
            WHEN p_diet_preference IS NULL OR p_diet_preference = 'none' THEN true
            WHEN p_diet_preference = 'vegan' THEN
                CASE
                    WHEN m.vegan_status = 'no' THEN false
                    WHEN p_strict_diet AND m.vegan_status != 'yes' THEN false
                    ELSE true
                END
            WHEN p_diet_preference = 'vegetarian' THEN
                CASE
                    WHEN m.vegetarian_status = 'no' THEN false
                    WHEN p_strict_diet AND m.vegetarian_status != 'yes' THEN false
                    ELSE true
                END
            ELSE true
        END
        AND
        -- Allergen filter (contains)
        CASE
            WHEN p_avoid_allergens IS NULL OR array_length(p_avoid_allergens, 1) IS NULL THEN true
            ELSE NOT EXISTS (
                SELECT 1 FROM product_allergen_info ai
                WHERE ai.product_id = p_product_id
                  AND ai.type = 'contains'
                  AND ai.tag = ANY(p_avoid_allergens)
            )
        END
        AND
        -- Allergen filter (may contain / traces)
        CASE
            WHEN NOT p_treat_may_contain THEN true
            WHEN p_avoid_allergens IS NULL OR array_length(p_avoid_allergens, 1) IS NULL THEN true
            ELSE NOT EXISTS (
                SELECT 1 FROM product_allergen_info ai
                WHERE ai.product_id = p_product_id
                  AND ai.type = 'traces'
                  AND ai.tag = ANY(p_avoid_allergens)
            )
        END
        AND
        -- Strict allergen mode: hide products with no allergen data at all
        CASE
            WHEN NOT p_strict_allergen THEN true
            WHEN p_avoid_allergens IS NULL OR array_length(p_avoid_allergens, 1) IS NULL THEN true
            ELSE EXISTS (
                SELECT 1 FROM product_allergen_info ai
                WHERE ai.product_id = p_product_id
            )
        END
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

COMMENT ON FUNCTION public.check_product_preferences(bigint, text, text[], boolean, boolean, boolean) IS
'Reusable preference-check function. Returns true if product passes all user filters '
'(diet, allergens, strict modes). Used by preference-aware API surfaces.';

-- Internal function: not callable by anon
REVOKE EXECUTE ON FUNCTION public.check_product_preferences(bigint, text, text[], boolean, boolean, boolean)
    FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Preference-aware api_search_products
-- ═══════════════════════════════════════════════════════════════════════════════
-- DROP old signature and recreate with preference params

DROP FUNCTION IF EXISTS api_search_products(text, text, integer, integer, text);

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
          AND (p_country  IS NULL OR p.country  = p_country)
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
        'country',     p_country,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'results',     v_rows
    );
END;
$function$;

COMMENT ON FUNCTION public.api_search_products IS
'Full-text + trigram search with optional country, diet, and allergen filters. '
'All preference params default to NULL/false — existing callers unaffected.';

GRANT EXECUTE ON FUNCTION public.api_search_products
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_search_products
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Preference-aware api_category_listing
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS api_category_listing(text, text, text, integer, integer, text);

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
    FROM v_master m
    WHERE m.category = p_category
      AND (p_country IS NULL OR m.country = p_country)
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
          AND (p_country IS NULL OR m.country = p_country)
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

COMMENT ON FUNCTION public.api_category_listing IS
'Paged category browse with optional country, diet, and allergen filters. '
'All preference params default to NULL/false — existing callers unaffected.';

GRANT EXECUTE ON FUNCTION public.api_category_listing
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_category_listing
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Preference-aware find_better_alternatives
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old signature to avoid overload ambiguity
DROP FUNCTION IF EXISTS public.find_better_alternatives(bigint, boolean, integer);

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
LANGUAGE sql STABLE
AS $function$
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
          AND check_product_preferences(
              p2.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
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

-- Internal function: not callable by anon
REVOKE EXECUTE ON FUNCTION public.find_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. Preference-aware find_similar_products
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old signature to avoid overload ambiguity
DROP FUNCTION IF EXISTS public.find_similar_products(bigint, integer);

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
          AND check_product_preferences(
              pi2.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
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

-- Internal function: not callable by anon
REVOKE EXECUTE ON FUNCTION public.find_similar_products(
    bigint, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Preference-aware api_better_alternatives
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old signature to avoid overload ambiguity
DROP FUNCTION IF EXISTS public.api_better_alternatives(bigint, boolean, integer);

CREATE OR REPLACE FUNCTION public.api_better_alternatives(
    p_product_id              bigint,
    p_same_category           boolean  DEFAULT true,
    p_limit                   integer  DEFAULT 5,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
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
            FROM find_better_alternatives(
                p_product_id, p_same_category,
                LEAST(GREATEST(p_limit, 1), 20),
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain
            ) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives(
                p_product_id, p_same_category,
                LEAST(GREATEST(p_limit, 1), 20),
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain
            )
        ), 0)
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

COMMENT ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) IS
'Healthier alternatives with optional diet/allergen filtering. '
'Country isolation is automatic (inferred from source product). '
'All preference params default to NULL/false — existing callers unaffected.';

GRANT EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
)
    FROM PUBLIC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. api_get_user_preferences — fetch current user's preferences
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_user_preferences()
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT COALESCE(
        (SELECT jsonb_build_object(
            'api_version',                '1.0',
            'user_id',                    up.user_id,
            'country',                    up.country,
            'diet_preference',            up.diet_preference,
            'avoid_allergens',            COALESCE(to_jsonb(up.avoid_allergens), '[]'::jsonb),
            'strict_allergen',            up.strict_allergen,
            'strict_diet',               up.strict_diet,
            'treat_may_contain_as_unsafe',up.treat_may_contain_as_unsafe,
            'created_at',                 up.created_at,
            'updated_at',                 up.updated_at
        )
        FROM user_preferences up
        WHERE up.user_id = auth.uid()),
        jsonb_build_object(
            'api_version', '1.0',
            'has_preferences', false,
            'message', 'No preferences set. Use api_set_user_preferences to configure.'
        )
    );
$function$;

COMMENT ON FUNCTION public.api_get_user_preferences() IS
'Returns the authenticated user''s preference profile. Returns a "no preferences" '
'message if the user hasn''t configured preferences yet.';

GRANT EXECUTE ON FUNCTION public.api_get_user_preferences()
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_get_user_preferences()
    FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 11. api_set_user_preferences — create or update user preferences
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_set_user_preferences(
    p_country                    text     DEFAULT 'PL',
    p_diet_preference            text     DEFAULT NULL,
    p_avoid_allergens            text[]   DEFAULT NULL,
    p_strict_allergen            boolean  DEFAULT false,
    p_strict_diet                boolean  DEFAULT false,
    p_treat_may_contain_as_unsafe boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid uuid;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Validate country is active
    IF NOT EXISTS (
        SELECT 1 FROM country_ref
        WHERE country_code = p_country AND is_active = true
    ) THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Country not available: ' || p_country
        );
    END IF;

    -- Validate diet preference
    IF p_diet_preference IS NOT NULL AND p_diet_preference NOT IN ('none','vegetarian','vegan') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid diet_preference. Use: none, vegetarian, vegan.'
        );
    END IF;

    -- Upsert
    INSERT INTO user_preferences (
        user_id, country, diet_preference, avoid_allergens,
        strict_allergen, strict_diet, treat_may_contain_as_unsafe
    ) VALUES (
        v_uid, p_country, p_diet_preference, p_avoid_allergens,
        p_strict_allergen, p_strict_diet, p_treat_may_contain_as_unsafe
    )
    ON CONFLICT (user_id) DO UPDATE SET
        country                     = EXCLUDED.country,
        diet_preference             = EXCLUDED.diet_preference,
        avoid_allergens             = EXCLUDED.avoid_allergens,
        strict_allergen             = EXCLUDED.strict_allergen,
        strict_diet                 = EXCLUDED.strict_diet,
        treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
        updated_at                  = now();

    RETURN api_get_user_preferences();
END;
$function$;

COMMENT ON FUNCTION public.api_set_user_preferences(
    text, text, text[], boolean, boolean, boolean
) IS
'Create or update the authenticated user''s preference profile. '
'Validates country against country_ref and diet_preference enum. '
'Returns the updated preference profile.';

GRANT EXECUTE ON FUNCTION public.api_set_user_preferences(
    text, text, text[], boolean, boolean, boolean
)
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_set_user_preferences(
    text, text, text[], boolean, boolean, boolean
)
    FROM PUBLIC, anon;

COMMIT;

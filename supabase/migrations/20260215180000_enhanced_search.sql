-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Enhanced Search & Filters  (Issue #22)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- 1. search_vector tsvector column + GIN index on products
-- 2. user_saved_searches table with RLS
-- 3. Drop old api_search_products (different signature)
-- 4. New api_search_products  — multi-faceted filters, avoid demotion, pagination
-- 5. api_search_autocomplete  — prefix matching, sub-100ms target
-- 6. api_get_filter_options   — category/nutri/allergen counts
-- 7. Saved searches CRUD      — api_save_search / api_get_saved_searches / api_delete_saved_search
-- ═══════════════════════════════════════════════════════════════════════════════


-- ───────────────────────────────────────────────────────────────────────────────
-- 1. Full-Text Search Vector on products
-- ───────────────────────────────────────────────────────────────────────────────

-- We use a trigger-maintained tsvector (not GENERATED ALWAYS) because
-- to_tsvector() is STABLE, not IMMUTABLE — PG blocks it in generated columns.

ALTER TABLE products ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Populate existing rows
UPDATE products
SET search_vector =
    setweight(to_tsvector('simple', coalesce(product_name, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(brand, '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(category, '')), 'C');

-- GIN index for fast @@ queries
CREATE INDEX IF NOT EXISTS idx_products_search_vector
    ON products USING gin(search_vector);

-- Trigger: keep search_vector in sync on insert/update
CREATE OR REPLACE FUNCTION trg_products_search_vector()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', coalesce(NEW.product_name, '')), 'A') ||
        setweight(to_tsvector('simple', coalesce(NEW.brand, '')), 'B') ||
        setweight(to_tsvector('simple', coalesce(NEW.category, '')), 'C');
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_products_search_vector_update ON products;
CREATE TRIGGER trg_products_search_vector_update
    BEFORE INSERT OR UPDATE OF product_name, brand, category ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_products_search_vector();


-- ───────────────────────────────────────────────────────────────────────────────
-- 2. user_saved_searches table
-- ───────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_saved_searches (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name       text NOT NULL,
    query      text,
    filters    jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE user_saved_searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own saved searches"
    ON user_saved_searches FOR ALL
    USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id
    ON user_saved_searches(user_id);

-- Limit: max 50 saved searches per user
CREATE OR REPLACE FUNCTION trg_limit_saved_searches()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT count(*) FROM user_saved_searches WHERE user_id = NEW.user_id) >= 50 THEN
        RAISE EXCEPTION 'Maximum 50 saved searches per user';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_limit_saved_searches ON user_saved_searches;
CREATE TRIGGER trg_limit_saved_searches
    BEFORE INSERT ON user_saved_searches
    FOR EACH ROW
    EXECUTE FUNCTION trg_limit_saved_searches();


-- ───────────────────────────────────────────────────────────────────────────────
-- 3. Drop old api_search_products (different parameter signature)
-- ───────────────────────────────────────────────────────────────────────────────

DROP FUNCTION IF EXISTS public.api_search_products(
    text, text, integer, integer, text, text, text[], boolean, boolean, boolean
);


-- ───────────────────────────────────────────────────────────────────────────────
-- 4. NEW api_search_products
--    Multi-faceted filters · avoid demotion · pagination · user prefs auto-applied
-- ───────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_search_products(
    p_query        text     DEFAULT NULL,
    p_filters      jsonb    DEFAULT '{}'::jsonb,
    p_page         integer  DEFAULT 1,
    p_page_size    integer  DEFAULT 20,
    p_show_avoided boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_query           text;
    v_country         text;
    v_categories      text[];
    v_nutri_scores    text[];
    v_allergen_free   text[];
    v_max_score       numeric;
    v_sort_by         text;
    v_sort_order      text;
    v_offset          integer;
    v_total           integer;
    v_pages           integer;
    v_rows            jsonb;
    v_avoid_ids       bigint[];
    v_user_id         uuid;
    v_diet_pref       text;
    v_user_allergens  text[];
    v_strict_diet     boolean;
    v_strict_allergen boolean;
    v_treat_mc        boolean;
    v_tsq             tsquery;
BEGIN
    -- ── Sanitize inputs ─────────────────────────────────────────────────────
    v_query := NULLIF(TRIM(COALESCE(p_query, '')), '');
    p_page_size := LEAST(GREATEST(p_page_size, 1), 100);
    p_page      := GREATEST(p_page, 1);
    v_offset    := (p_page - 1) * p_page_size;

    -- ── Extract filters from jsonb ──────────────────────────────────────────
    v_categories    := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'category', '[]'::jsonb)));
    v_nutri_scores  := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'nutri_score', '[]'::jsonb)));
    v_allergen_free := ARRAY(SELECT jsonb_array_elements_text(
                          COALESCE(p_filters->'allergen_free', '[]'::jsonb)));
    v_max_score     := (p_filters->>'max_unhealthiness')::numeric;
    v_sort_by       := COALESCE(p_filters->>'sort_by', 'relevance');
    v_sort_order    := LOWER(COALESCE(p_filters->>'sort_order', 'asc'));

    -- Default sort_order for relevance should be DESC (best first)
    IF v_sort_by = 'relevance' AND (p_filters->>'sort_order') IS NULL THEN
        v_sort_order := 'desc';
    END IF;

    -- ── Resolve country ─────────────────────────────────────────────────────
    v_country := resolve_effective_country(p_filters->>'country');

    -- ── Build tsquery from words (prefix matching) ──────────────────────────
    IF v_query IS NOT NULL AND LENGTH(v_query) >= 1 THEN
        SELECT to_tsquery('simple',
            string_agg(lexeme || ':*', ' & '))
        INTO v_tsq
        FROM unnest(string_to_array(v_query, ' ')) AS lexeme
        WHERE lexeme <> '';
    END IF;

    -- ── Load user preferences + avoid list ──────────────────────────────────
    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        SELECT up.diet_preference, up.avoid_allergens,
               up.strict_diet, up.strict_allergen, up.treat_may_contain_as_unsafe
        INTO   v_diet_pref, v_user_allergens,
               v_strict_diet, v_strict_allergen, v_treat_mc
        FROM   user_preferences up
        WHERE  up.user_id = v_user_id;

        -- Avoid list IDs for demotion
        SELECT ARRAY_AGG(li.product_id)
        INTO   v_avoid_ids
        FROM   user_product_list_items li
        JOIN   user_product_lists l ON l.id = li.list_id
        WHERE  l.user_id = v_user_id AND l.list_type = 'avoid';
    END IF;
    v_avoid_ids := COALESCE(v_avoid_ids, ARRAY[]::bigint[]);

    -- ── Main query ──────────────────────────────────────────────────────────
    WITH search_results AS (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            cr.display_name                                 AS category_display,
            COALESCE(cr.icon_emoji, '📦')                   AS category_icon,
            p.unhealthiness_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END                                             AS score_band,
            p.nutri_score_label                             AS nutri_score,
            p.nova_classification                           AS nova_group,
            nf.calories::numeric                            AS calories,
            COALESCE(p.high_salt_flag = 'YES', false)       AS high_salt,
            COALESCE(p.high_sugar_flag = 'YES', false)      AS high_sugar,
            COALESCE(p.high_sat_fat_flag = 'YES', false)    AS high_sat_fat,
            COALESCE(p.high_additive_load = 'YES', false)   AS high_additive_load,
            (p.product_id = ANY(v_avoid_ids))               AS is_avoided,
            -- Relevance score
            CASE
                WHEN v_query IS NOT NULL THEN
                    COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq)
                             ELSE 0 END, 0)
                    + GREATEST(
                        similarity(p.product_name, v_query),
                        similarity(p.brand, v_query) * 0.8
                    )
                ELSE 0
            END                                             AS relevance,
            COUNT(*) OVER()                                 AS total_count
        FROM products p
        LEFT JOIN category_ref cr
            ON cr.category = p.category
        LEFT JOIN servings sv
            ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
        LEFT JOIN nutrition_facts nf
            ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          -- Text search (empty = browse mode)
          AND (
              v_query IS NULL
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR p.product_name ILIKE '%' || v_query || '%'
              OR p.brand        ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
          -- Category multi-filter
          AND (array_length(v_categories, 1) IS NULL
               OR p.category = ANY(v_categories))
          -- Nutri-Score filter
          AND (array_length(v_nutri_scores, 1) IS NULL
               OR p.nutri_score_label = ANY(v_nutri_scores))
          -- Max unhealthiness
          AND (v_max_score IS NULL
               OR p.unhealthiness_score <= v_max_score)
          -- Allergen-free filter (search-specific)
          AND (array_length(v_allergen_free, 1) IS NULL
               OR NOT EXISTS (
                   SELECT 1 FROM product_allergen_info ai
                   WHERE ai.product_id = p.product_id
                     AND ai.type = 'contains'
                     AND ai.tag = ANY(v_allergen_free)
               ))
          -- User diet/allergen preferences (auto-applied for authenticated users)
          AND (v_user_id IS NULL
               OR check_product_preferences(
                   p.product_id, v_diet_pref, v_user_allergens,
                   v_strict_diet, v_strict_allergen, v_treat_mc
               ))
        ORDER BY
            -- Avoid demotion: avoided products pushed to bottom
            CASE WHEN NOT p_show_avoided AND p.product_id = ANY(v_avoid_ids) THEN 1 ELSE 0 END ASC,
            -- Name sort (ASC)
            CASE WHEN v_sort_by = 'name' AND v_sort_order <> 'desc'
                 THEN p.product_name END ASC NULLS LAST,
            -- Name sort (DESC)
            CASE WHEN v_sort_by = 'name' AND v_sort_order = 'desc'
                 THEN p.product_name END DESC NULLS LAST,
            -- Numeric sort column
            CASE
                WHEN v_sort_by = 'relevance' THEN
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query IS NOT NULL
                             THEN GREATEST(similarity(p.product_name, v_query),
                                           similarity(p.brand, v_query) * 0.8)
                             ELSE 0 END)
                WHEN v_sort_by = 'unhealthiness' AND v_sort_order = 'desc' THEN
                    -COALESCE(p.unhealthiness_score, 999)
                WHEN v_sort_by = 'unhealthiness' THEN
                    COALESCE(p.unhealthiness_score, 999)
                WHEN v_sort_by = 'nutri_score' AND v_sort_order = 'desc' THEN
                    -(CASE p.nutri_score_label
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3
                        WHEN 'D' THEN 4 WHEN 'E' THEN 5 ELSE 6 END)
                WHEN v_sort_by = 'nutri_score' THEN
                    (CASE p.nutri_score_label
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3
                        WHEN 'D' THEN 4 WHEN 'E' THEN 5 ELSE 6 END)
                WHEN v_sort_by = 'calories' AND v_sort_order = 'desc' THEN
                    -COALESCE(nf.calories::numeric, 9999)
                WHEN v_sort_by = 'calories' THEN
                    COALESCE(nf.calories::numeric, 9999)
                -- Default: relevance DESC
                ELSE
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query IS NOT NULL
                             THEN GREATEST(similarity(p.product_name, v_query),
                                           similarity(p.brand, v_query) * 0.8)
                             ELSE 0 END)
            END ASC NULLS LAST,
            -- Tiebreaker
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_page_size OFFSET v_offset
    )
    SELECT COALESCE(MAX(sr.total_count)::int, 0),
           COALESCE(jsonb_agg(jsonb_build_object(
               'product_id',          sr.product_id,
               'product_name',        sr.product_name,
               'brand',               sr.brand,
               'category',            sr.category,
               'category_display',    sr.category_display,
               'category_icon',       sr.category_icon,
               'unhealthiness_score', sr.unhealthiness_score,
               'score_band',          sr.score_band,
               'nutri_score',         sr.nutri_score,
               'nova_group',          sr.nova_group,
               'calories',            sr.calories,
               'high_salt',           sr.high_salt,
               'high_sugar',          sr.high_sugar,
               'high_sat_fat',        sr.high_sat_fat,
               'high_additive_load',  sr.high_additive_load,
               'is_avoided',          sr.is_avoided,
               'relevance',           ROUND(sr.relevance::numeric, 4)
           )), '[]'::jsonb)
    INTO v_total, v_rows
    FROM search_results sr;

    v_pages := GREATEST(CEIL(v_total::numeric / p_page_size)::int, 1);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'query',       v_query,
        'country',     v_country,
        'total',       v_total,
        'page',        p_page,
        'pages',       v_pages,
        'page_size',   p_page_size,
        'filters_applied', p_filters,
        'results',     v_rows
    );
END;
$function$;

-- Grant to authenticated + anon (search is public)
GRANT EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean)
    TO authenticated, anon;


-- ───────────────────────────────────────────────────────────────────────────────
-- 5. api_search_autocomplete — prefix matching, sub-100ms
-- ───────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_search_autocomplete(
    p_query  text,
    p_limit  integer DEFAULT 8
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_query   text;
    v_tsq     tsquery;
    v_rows    jsonb;
    v_country text;
BEGIN
    v_query := TRIM(COALESCE(p_query, ''));
    IF LENGTH(v_query) < 1 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'query', '',
            'suggestions', '[]'::jsonb
        );
    END IF;

    p_limit := LEAST(GREATEST(p_limit, 1), 15);
    v_country := resolve_effective_country(NULL);

    -- Build prefix tsquery: "lay chi" → "lay:* & chi:*"
    SELECT to_tsquery('simple', string_agg(word || ':*', ' & '))
    INTO   v_tsq
    FROM   unnest(string_to_array(v_query, ' ')) AS word
    WHERE  word <> '';

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'brand',               p.brand,
            'category',            p.category,
            'nutri_score',         p.nutri_score_label,
            'unhealthiness_score', p.unhealthiness_score,
            'score_band',          CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END
        ) AS row_data
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND (
              (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR p.product_name ILIKE v_query || '%'
              OR p.brand ILIKE v_query || '%'
          )
        ORDER BY
            CASE WHEN p.product_name ILIKE v_query || '%' THEN 0 ELSE 1 END,
            CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                 THEN ts_rank(p.search_vector, v_tsq)
                 ELSE 0 END DESC,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'query',       v_query,
        'suggestions', v_rows
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_search_autocomplete(text, integer)
    TO authenticated, anon;


-- ───────────────────────────────────────────────────────────────────────────────
-- 6. api_get_filter_options — category / nutri / allergen counts
-- ───────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_get_filter_options(
    p_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_country    text;
    v_categories jsonb;
    v_nutri      jsonb;
    v_allergens  jsonb;
BEGIN
    v_country := resolve_effective_country(p_country);

    -- Category counts
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'category',     cr.category,
        'display_name', cr.display_name,
        'icon_emoji',   cr.icon_emoji,
        'count',        COALESCE(c.cnt, 0)
    ) ORDER BY cr.sort_order), '[]'::jsonb)
    INTO v_categories
    FROM category_ref cr
    LEFT JOIN (
        SELECT p.category, COUNT(*) AS cnt
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE AND p.country = v_country
        GROUP BY p.category
    ) c ON c.category = cr.category
    WHERE cr.is_active AND COALESCE(c.cnt, 0) > 0;

    -- Nutri-Score label counts
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'label', n.label,
        'count', n.cnt
    ) ORDER BY n.label), '[]'::jsonb)
    INTO v_nutri
    FROM (
        SELECT p.nutri_score_label AS label, COUNT(*) AS cnt
        FROM products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND p.nutri_score_label IS NOT NULL
        GROUP BY p.nutri_score_label
    ) n;

    -- Allergen tag counts (products *containing* each allergen)
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'tag',   a.tag,
        'count', a.cnt
    ) ORDER BY a.cnt DESC), '[]'::jsonb)
    INTO v_allergens
    FROM (
        SELECT ai.tag, COUNT(DISTINCT ai.product_id) AS cnt
        FROM product_allergen_info ai
        JOIN products p ON p.product_id = ai.product_id
        WHERE ai.type = 'contains'
          AND p.is_deprecated IS NOT TRUE
          AND p.country = v_country
        GROUP BY ai.tag
    ) a;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'country',     v_country,
        'categories',  v_categories,
        'nutri_scores', v_nutri,
        'allergens',   v_allergens
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_get_filter_options(text)
    TO authenticated, anon;


-- ───────────────────────────────────────────────────────────────────────────────
-- 7. Saved searches CRUD
-- ───────────────────────────────────────────────────────────────────────────────

-- 7a. api_save_search
CREATE OR REPLACE FUNCTION public.api_save_search(
    p_name    text,
    p_query   text    DEFAULT NULL,
    p_filters jsonb   DEFAULT '{}'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_user_id uuid;
    v_id      uuid;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    IF TRIM(COALESCE(p_name, '')) = '' THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Name is required');
    END IF;

    INSERT INTO user_saved_searches (user_id, name, query, filters)
    VALUES (v_user_id,
            TRIM(p_name),
            NULLIF(TRIM(COALESCE(p_query, '')), ''),
            p_filters)
    RETURNING id INTO v_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'id',      v_id,
        'name',    TRIM(p_name),
        'created', true
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_save_search(text, text, jsonb)
    TO authenticated;

-- 7b. api_get_saved_searches
CREATE OR REPLACE FUNCTION public.api_get_saved_searches()
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_user_id uuid;
    v_rows    jsonb;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id',         s.id,
        'name',       s.name,
        'query',      s.query,
        'filters',    s.filters,
        'created_at', s.created_at
    ) ORDER BY s.created_at DESC), '[]'::jsonb)
    INTO v_rows
    FROM user_saved_searches s
    WHERE s.user_id = v_user_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'searches',    v_rows
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_get_saved_searches()
    TO authenticated;

-- 7c. api_delete_saved_search
CREATE OR REPLACE FUNCTION public.api_delete_saved_search(
    p_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_user_id uuid;
    v_count   integer;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    DELETE FROM user_saved_searches
    WHERE id = p_id AND user_id = v_user_id;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success',     v_count > 0,
        'deleted',     v_count > 0
    );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_delete_saved_search(uuid)
    TO authenticated;


-- ═══════════════════════════════════════════════════════════════════════════════
-- Done — migration complete
-- ═══════════════════════════════════════════════════════════════════════════════

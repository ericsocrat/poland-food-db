-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Localization Phase 1 — Language Foundation (#32)
--
-- Architecture refined per #32 architectural review:
--   - language_ref table replaces hardcoded CHECK constraint
--   - category_translations table replaces per-language columns
--   - resolve_language() validates against language_ref
--   - unaccent extension enabled for future search improvements
--
-- Changes:
--   1.  Enable unaccent extension
--   2.  Create language_ref table + seed en/pl/de
--   3.  Add preferred_language to user_preferences (FK → language_ref)
--   4.  Create category_translations table + seed en + pl
--   5.  Create resolve_language() — explicit → user pref → 'en'
--   6.  Update api_get_user_preferences() — return preferred_language
--   7.  Update api_set_user_preferences() — accept + validate preferred_language
--   8.  Update api_category_overview() — localized category names via join
--   9.  Update api_category_listing() — localized category envelope
--  10.  Update api_search_products() — localized category_display via join
--  11.  Update api_product_detail() — localized category_display via join
--
-- Backward-compatible: existing callers without p_language get English.
-- api_version stays at '1.0'.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Enable unaccent extension (for Phase 2/3 search improvements)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS unaccent;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Create language_ref table
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.language_ref (
    code        text PRIMARY KEY,              -- ISO 639-1 (e.g. 'en', 'pl', 'de')
    name_en     text NOT NULL,                 -- English name (e.g. 'Polish')
    name_native text NOT NULL,                 -- Native name (e.g. 'Polski')
    is_enabled  boolean NOT NULL DEFAULT true,
    sort_order  integer NOT NULL DEFAULT 0
);

COMMENT ON TABLE public.language_ref IS
'Supported UI languages. Adding a new language is a single INSERT — no schema change needed.';

-- Seed supported languages
INSERT INTO public.language_ref (code, name_en, name_native, sort_order) VALUES
    ('en', 'English', 'English', 1),
    ('pl', 'Polish',  'Polski',  2),
    ('de', 'German',  'Deutsch', 3)
ON CONFLICT (code) DO NOTHING;

-- RLS (read-only for all, including anon for language picker)
ALTER TABLE public.language_ref ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.language_ref FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_select_language_ref" ON public.language_ref;
CREATE POLICY "allow_select_language_ref" ON public.language_ref
    FOR SELECT USING (true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Add preferred_language to user_preferences (FK → language_ref)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.user_preferences
    ADD COLUMN IF NOT EXISTS preferred_language text NOT NULL DEFAULT 'en';

-- FK replaces CHECK constraint — adding languages is INSERT-only, no DDL needed
ALTER TABLE public.user_preferences
    ADD CONSTRAINT fk_user_prefs_language
    FOREIGN KEY (preferred_language) REFERENCES public.language_ref(code);

COMMENT ON COLUMN public.user_preferences.preferred_language IS
'User''s preferred UI language. FK to language_ref. Default: en.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Create category_translations table
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.category_translations (
    category      text NOT NULL REFERENCES public.category_ref(category) ON DELETE CASCADE,
    language_code text NOT NULL REFERENCES public.language_ref(code) ON DELETE CASCADE,
    display_name  text NOT NULL,
    PRIMARY KEY (category, language_code)
);

COMMENT ON TABLE public.category_translations IS
'Localized category display names. One row per (category, language). '
'Adding a new language for all categories is ~20 INSERTs — no schema change.';

-- Seed English translations from existing category_ref.display_name
INSERT INTO public.category_translations (category, language_code, display_name)
SELECT category, 'en', display_name
FROM public.category_ref
WHERE is_active = true
ON CONFLICT (category, language_code) DO NOTHING;

-- Seed Polish translations
INSERT INTO public.category_translations (category, language_code, display_name) VALUES
    ('Alcohol',                    'pl', 'Alkohol'),
    ('Baby',                       'pl', 'Żywność dla dzieci'),
    ('Bread',                      'pl', 'Pieczywo'),
    ('Breakfast & Grain-Based',    'pl', 'Śniadanie i produkty zbożowe'),
    ('Canned Goods',               'pl', 'Konserwy'),
    ('Cereals',                    'pl', 'Płatki śniadaniowe'),
    ('Chips',                      'pl', 'Chipsy'),
    ('Condiments',                 'pl', 'Przyprawy i dodatki'),
    ('Dairy',                      'pl', 'Nabiał'),
    ('Drinks',                     'pl', 'Napoje'),
    ('Frozen & Prepared',          'pl', 'Mrożonki i dania gotowe'),
    ('Instant & Frozen',           'pl', 'Instant i mrożonki'),
    ('Meat',                       'pl', 'Mięso'),
    ('Nuts, Seeds & Legumes',      'pl', 'Orzechy, nasiona i rośliny strączkowe'),
    ('Plant-Based & Alternatives', 'pl', 'Roślinne zamienniki'),
    ('Sauces',                     'pl', 'Sosy'),
    ('Seafood & Fish',             'pl', 'Owoce morza i ryby'),
    ('Snacks',                     'pl', 'Przekąski'),
    ('Sweets',                     'pl', 'Słodycze'),
    ('Żabka',                      'pl', 'Żabka')
ON CONFLICT (category, language_code) DO NOTHING;

-- RLS (read-only for all)
ALTER TABLE public.category_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category_translations FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_select_category_translations" ON public.category_translations;
CREATE POLICY "allow_select_category_translations" ON public.category_translations
    FOR SELECT USING (true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. resolve_language() — language resolution with priority chain
--    Validates explicit param against language_ref.is_enabled.
--    Invalid/disabled codes gracefully fall back.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.resolve_language(p_language text DEFAULT NULL)
RETURNS text
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (validated against language_ref)
        (SELECT lr.code
         FROM language_ref lr
         WHERE lr.code = NULLIF(TRIM(p_language), '')
           AND lr.is_enabled = true),
        -- Priority 2: authenticated user's saved language preference
        (SELECT up.preferred_language
         FROM user_preferences up
         WHERE up.user_id = auth.uid()),
        -- Priority 3: default to English
        'en'
    );
$func$;

COMMENT ON FUNCTION public.resolve_language(text) IS
'Resolves the effective UI language. Priority: explicit (validated) → user pref → ''en''. '
'Invalid or disabled language codes gracefully fall back. Safe for anonymous users.';

REVOKE EXECUTE ON FUNCTION public.resolve_language(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.resolve_language(text) TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Update api_get_user_preferences() — return preferred_language
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_user_preferences()
RETURNS jsonb
LANGUAGE plpgsql VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid  uuid;
    v_row  user_preferences%ROWTYPE;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Auto-upsert: ensure a row always exists for this user
    INSERT INTO user_preferences (user_id)
    VALUES (v_uid)
    ON CONFLICT (user_id) DO NOTHING;

    SELECT * INTO v_row
    FROM user_preferences
    WHERE user_id = v_uid;

    RETURN jsonb_build_object(
        'api_version',                 '1.0',
        'user_id',                     v_row.user_id,
        'country',                     v_row.country,
        'preferred_language',          v_row.preferred_language,
        'diet_preference',             v_row.diet_preference,
        'avoid_allergens',             COALESCE(to_jsonb(v_row.avoid_allergens), '[]'::jsonb),
        'strict_allergen',             v_row.strict_allergen,
        'strict_diet',                 v_row.strict_diet,
        'treat_may_contain_as_unsafe', v_row.treat_may_contain_as_unsafe,
        'onboarding_complete',         (v_row.country IS NOT NULL),
        'created_at',                  v_row.created_at,
        'updated_at',                  v_row.updated_at
    );
END;
$function$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Update api_set_user_preferences() — accept + validate preferred_language
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old 6-arg signature to avoid overload ambiguity
DROP FUNCTION IF EXISTS public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean);

CREATE OR REPLACE FUNCTION public.api_set_user_preferences(
    p_country                     text     DEFAULT NULL,
    p_diet_preference             text     DEFAULT NULL,
    p_avoid_allergens             text[]   DEFAULT NULL,
    p_strict_allergen             boolean  DEFAULT false,
    p_strict_diet                 boolean  DEFAULT false,
    p_treat_may_contain_as_unsafe boolean  DEFAULT false,
    p_preferred_language          text     DEFAULT NULL
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

    -- Validate country if provided
    IF p_country IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM country_ref
            WHERE country_code = p_country AND is_active = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Country not available: ' || COALESCE(p_country, 'NULL')
            );
        END IF;
    END IF;

    -- Validate diet preference
    IF p_diet_preference IS NOT NULL AND p_diet_preference NOT IN ('none','vegetarian','vegan') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid diet_preference. Use: none, vegetarian, vegan.'
        );
    END IF;

    -- Validate preferred_language against language_ref (data-driven, not hardcoded)
    IF p_preferred_language IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM language_ref
            WHERE code = p_preferred_language AND is_enabled = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Invalid preferred_language. Enabled: ' ||
                    (SELECT string_agg(code, ', ' ORDER BY sort_order)
                     FROM language_ref WHERE is_enabled = true)
            );
        END IF;
    END IF;

    -- Upsert
    INSERT INTO user_preferences (
        user_id, country, diet_preference, avoid_allergens,
        strict_allergen, strict_diet, treat_may_contain_as_unsafe,
        preferred_language
    ) VALUES (
        v_uid, p_country, p_diet_preference, p_avoid_allergens,
        p_strict_allergen, p_strict_diet, p_treat_may_contain_as_unsafe,
        COALESCE(p_preferred_language, 'en')
    )
    ON CONFLICT (user_id) DO UPDATE SET
        country                     = COALESCE(EXCLUDED.country, user_preferences.country),
        diet_preference             = EXCLUDED.diet_preference,
        avoid_allergens             = EXCLUDED.avoid_allergens,
        strict_allergen             = EXCLUDED.strict_allergen,
        strict_diet                 = EXCLUDED.strict_diet,
        treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
        preferred_language          = COALESCE(EXCLUDED.preferred_language, user_preferences.preferred_language),
        updated_at                  = now();

    RETURN api_get_user_preferences();
END;
$function$;

GRANT EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text)
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text)
    FROM PUBLIC, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. Update api_category_overview() — localized via category_translations join
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old 1-arg signature to avoid overload with new 2-arg version
DROP FUNCTION IF EXISTS public.api_category_overview(text);

CREATE OR REPLACE FUNCTION public.api_category_overview(
    p_country  text DEFAULT NULL,
    p_language text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_country  text;
    v_language text;
    v_rows     jsonb;
BEGIN
    v_country  := resolve_effective_country(p_country);
    v_language := resolve_language(p_language);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'country_code',         ov.country_code,
            'category',             ov.category,
            'slug',                 ov.slug,
            'display_name',         COALESCE(ct.display_name, ov.display_name),
            'category_description', ov.category_description,
            'icon_emoji',           ov.icon_emoji,
            'sort_order',           ov.sort_order,
            'product_count',        ov.product_count,
            'avg_score',            ov.avg_score,
            'min_score',            ov.min_score,
            'max_score',            ov.max_score,
            'median_score',         ov.median_score,
            'pct_nutri_a_b',        ov.pct_nutri_a_b,
            'pct_nova_4',           ov.pct_nova_4
        ) AS row_data,
        ov.sort_order
        FROM v_api_category_overview_by_country ov
        LEFT JOIN category_translations ct
            ON ct.category = ov.category AND ct.language_code = v_language
        WHERE ov.country_code = v_country
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'country',     v_country,
        'language',    v_language,
        'categories',  v_rows
    );
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.api_category_overview(text, text) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.api_category_overview(text, text) TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Update api_category_listing() — add p_language, localized envelope
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old 11-arg signature; new version adds p_language as 12th param
DROP FUNCTION IF EXISTS public.api_category_listing(text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean);

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
    p_treat_may_contain       boolean  DEFAULT false,
    p_language                text     DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_total     integer;
    v_rows      jsonb;
    v_country   text;
    v_category  text;
    v_language  text;
    v_cat_disp  text;
BEGIN
    -- Resolve slug → real category name (fall back to treating input as literal)
    SELECT cr.category INTO v_category
    FROM category_ref cr
    WHERE cr.slug = p_category;

    IF v_category IS NULL THEN
        SELECT cr.category INTO v_category
        FROM category_ref cr
        WHERE cr.category = p_category;
    END IF;

    IF v_category IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Unknown category: ' || COALESCE(p_category, 'NULL')
        );
    END IF;

    p_limit  := LEAST(GREATEST(p_limit, 1), 100);
    p_offset := GREATEST(p_offset, 0);

    v_country  := resolve_effective_country(p_country);
    v_language := resolve_language(p_language);

    -- Resolve localized category display name
    SELECT COALESCE(ct.display_name, cr.display_name)
    INTO v_cat_disp
    FROM category_ref cr
    LEFT JOIN category_translations ct
        ON ct.category = cr.category AND ct.language_code = v_language
    WHERE cr.category = v_category;

    SELECT COUNT(*)::int INTO v_total
    FROM v_master m
    WHERE m.category = v_category
      AND m.country = v_country
      AND check_product_preferences(
          m.product_id, p_diet_preference, p_avoid_allergens,
          p_strict_diet, p_strict_allergen, p_treat_may_contain
      );

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
        WHERE m.category = v_category
          AND m.country = v_country
          AND check_product_preferences(
              m.product_id, p_diet_preference, p_avoid_allergens,
              p_strict_diet, p_strict_allergen, p_treat_may_contain
          )
        ORDER BY
            CASE WHEN p_sort_dir = 'asc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END ASC NULLS LAST,
            CASE WHEN p_sort_dir = 'desc' THEN
                CASE p_sort_by
                    WHEN 'score'       THEN LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                    WHEN 'calories'    THEN LPAD(COALESCE(m.calories, 0)::text, 10, '0')
                    WHEN 'protein'     THEN LPAD(COALESCE(m.protein_g * 100, 0)::int::text, 10, '0')
                    WHEN 'name'        THEN m.product_name
                    WHEN 'nutri_score' THEN COALESCE(m.nutri_score_label, 'Z')
                    ELSE LPAD(COALESCE(m.unhealthiness_score, 0)::text, 10, '0')
                END
            END DESC NULLS LAST,
            m.product_id ASC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version',      '1.0',
        'category',         v_category,
        'category_display', v_cat_disp,
        'language',         v_language,
        'country',          v_country,
        'total_count',      v_total,
        'limit',            p_limit,
        'offset',           p_offset,
        'sort_by',          p_sort_by,
        'sort_dir',         p_sort_dir,
        'products',         v_rows
    );
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.api_category_listing(text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean, text)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_category_listing(text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean, text)
    TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. Update api_search_products() — localized category_display via join
--     Signature unchanged (text, jsonb, int, int, boolean).
--     Language auto-resolved from user preference via resolve_language(NULL).
-- ═══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.api_search_products(text, jsonb, integer, integer, boolean);

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
    v_language        text;
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

    IF v_sort_by = 'relevance' AND (p_filters->>'sort_order') IS NULL THEN
        v_sort_order := 'desc';
    END IF;

    -- ── Resolve country + language ──────────────────────────────────────────
    v_country  := resolve_effective_country(p_filters->>'country');
    v_language := resolve_language(NULL);  -- auto-resolve from user pref

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
            COALESCE(ct.display_name, cr.display_name)  AS category_display,
            COALESCE(cr.icon_emoji, '📦')                AS category_icon,
            p.unhealthiness_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END                                          AS score_band,
            p.nutri_score_label                          AS nutri_score,
            p.nova_classification                        AS nova_group,
            nf.calories::numeric                         AS calories,
            COALESCE(p.high_salt_flag = 'YES', false)    AS high_salt,
            COALESCE(p.high_sugar_flag = 'YES', false)   AS high_sugar,
            COALESCE(p.high_sat_fat_flag = 'YES', false) AS high_sat_fat,
            COALESCE(p.high_additive_load = 'YES', false) AS high_additive_load,
            (p.product_id = ANY(v_avoid_ids))            AS is_avoided,
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
            END                                          AS relevance,
            COUNT(*) OVER()                              AS total_count
        FROM products p
        LEFT JOIN category_ref cr
            ON cr.category = p.category
        LEFT JOIN category_translations ct
            ON ct.category = p.category AND ct.language_code = v_language
        LEFT JOIN nutrition_facts nf
            ON nf.product_id = p.product_id
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND (
              v_query IS NULL
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR p.product_name ILIKE '%' || v_query || '%'
              OR p.brand        ILIKE '%' || v_query || '%'
              OR similarity(p.product_name, v_query) > 0.15
          )
          AND (array_length(v_categories, 1) IS NULL
               OR p.category = ANY(v_categories))
          AND (array_length(v_nutri_scores, 1) IS NULL
               OR p.nutri_score_label = ANY(v_nutri_scores))
          AND (v_max_score IS NULL
               OR p.unhealthiness_score <= v_max_score)
          AND (array_length(v_allergen_free, 1) IS NULL
               OR NOT EXISTS (
                   SELECT 1 FROM product_allergen_info ai
                   WHERE ai.product_id = p.product_id
                     AND ai.type = 'contains'
                     AND ai.tag = ANY(v_allergen_free)
               ))
          AND (v_user_id IS NULL
               OR check_product_preferences(
                   p.product_id, v_diet_pref, v_user_allergens,
                   v_strict_diet, v_strict_allergen, v_treat_mc
               ))
        ORDER BY
            CASE WHEN NOT p_show_avoided AND p.product_id = ANY(v_avoid_ids) THEN 1 ELSE 0 END ASC,
            CASE WHEN v_sort_by = 'name' AND v_sort_order <> 'desc'
                 THEN p.product_name END ASC NULLS LAST,
            CASE WHEN v_sort_by = 'name' AND v_sort_order = 'desc'
                 THEN p.product_name END DESC NULLS LAST,
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
                ELSE
                    -(COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                      + CASE WHEN v_query IS NOT NULL
                             THEN GREATEST(similarity(p.product_name, v_query),
                                           similarity(p.brand, v_query) * 0.8)
                             ELSE 0 END)
            END ASC NULLS LAST,
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

REVOKE EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean)
    TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 11. Update api_product_detail() — localized category_display via join
--     Uses resolve_language(NULL) to auto-resolve from user preference.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_product_detail(
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
    SELECT jsonb_build_object(
        'api_version',         '1.0',
        'product_id',          m.product_id,
        'ean',                 m.ean,
        'product_name',        m.product_name,
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
            'additives_count',  m.additive_count,
            'additive_names',   COALESCE(m.additive_names, ARRAY[]::text[]),
            'vegan_status',     m.vegan_status,
            'vegetarian_status',m.vegetarian_status,
            'data_quality',     m.ingredient_data_quality
        ),
        'allergens', jsonb_build_object(
            'count',       m.allergen_count,
            'tags',        COALESCE(m.allergen_tags, ARRAY[]::text[]),
            'trace_count', m.trace_count,
            'trace_tags',  COALESCE(m.trace_tags, ARRAY[]::text[])
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
    WHERE m.product_id = p_product_id;
$func$;

REVOKE EXECUTE ON FUNCTION public.api_product_detail(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_product_detail(bigint) TO authenticated, service_role;

COMMIT;

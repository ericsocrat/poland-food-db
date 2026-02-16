-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: 20260216001000_localization_phase3_cross_language_search.sql
-- Phase 3 of Issue #32 — Cross-Language Search
--
-- Creates:
--   1.  search_synonyms table (bidirectional PL↔EN food term mappings)
--   2.  RLS policies + indexes
--   3.  Seed ~50 bidirectional PL↔EN food term pairs (~100 rows)
--   4.  expand_search_query() helper function
--   5.  Update api_search_products() with synonym expansion
--   6.  Update api_search_autocomplete() with synonym expansion
--
-- Rollback notes:
--   DROP FUNCTION IF EXISTS expand_search_query(text);
--   DROP TABLE IF EXISTS search_synonyms CASCADE;
--   -- Then restore api_search_products and api_search_autocomplete
--   -- from Phase 2 migration (20260216000900)
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Create search_synonyms table
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.search_synonyms (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    term_original  text NOT NULL,
    term_target    text NOT NULL,
    language_from  text NOT NULL REFERENCES language_ref(code),
    language_to    text NOT NULL REFERENCES language_ref(code),
    UNIQUE(term_original, language_from, language_to)
);

COMMENT ON TABLE public.search_synonyms IS
    'Cross-language search synonyms: maps food terms between languages for search expansion';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. RLS policies + indexes + grants
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.search_synonyms ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'search_synonyms' AND policyname = 'search_synonyms_read_authenticated'
    ) THEN
        CREATE POLICY "search_synonyms_read_authenticated"
            ON public.search_synonyms FOR SELECT
            TO authenticated
            USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'search_synonyms' AND policyname = 'search_synonyms_all_service'
    ) THEN
        CREATE POLICY "search_synonyms_all_service"
            ON public.search_synonyms FOR ALL
            TO service_role
            USING (true);
    END IF;
END $$;

-- Index for fast case-insensitive term lookup
CREATE INDEX IF NOT EXISTS idx_search_synonyms_lookup
    ON public.search_synonyms (LOWER(term_original), language_from);

GRANT SELECT ON public.search_synonyms TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Seed PL↔EN food term synonyms (~50 bidirectional pairs)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
-- ── PL → EN ──────────────────────────────────────────────────────────────────
('mleko',       'milk',           'pl', 'en'),
('ser',         'cheese',         'pl', 'en'),
('chleb',       'bread',          'pl', 'en'),
('masło',       'butter',         'pl', 'en'),
('jajko',       'egg',            'pl', 'en'),
('jajka',       'eggs',           'pl', 'en'),
('mąka',        'flour',          'pl', 'en'),
('cukier',      'sugar',          'pl', 'en'),
('sól',         'salt',           'pl', 'en'),
('woda',        'water',          'pl', 'en'),
('sok',         'juice',          'pl', 'en'),
('piwo',        'beer',           'pl', 'en'),
('wino',        'wine',           'pl', 'en'),
('herbata',     'tea',            'pl', 'en'),
('kawa',        'coffee',         'pl', 'en'),
('ryż',         'rice',           'pl', 'en'),
('makaron',     'pasta',          'pl', 'en'),
('mięso',       'meat',           'pl', 'en'),
('kurczak',     'chicken',        'pl', 'en'),
('ryba',        'fish',           'pl', 'en'),
('warzywa',     'vegetables',     'pl', 'en'),
('owoce',       'fruit',          'pl', 'en'),
('jabłko',      'apple',          'pl', 'en'),
('banan',       'banana',         'pl', 'en'),
('pomidor',     'tomato',         'pl', 'en'),
('ziemniak',    'potato',         'pl', 'en'),
('chipsy',      'chips',          'pl', 'en'),
('czekolada',   'chocolate',      'pl', 'en'),
('ciastka',     'cookies',        'pl', 'en'),
('lody',        'ice cream',      'pl', 'en'),
('jogurt',      'yogurt',         'pl', 'en'),
('śmietana',    'sour cream',     'pl', 'en'),
('kiełbasa',    'sausage',        'pl', 'en'),
('szynka',      'ham',            'pl', 'en'),
('serek',       'fromage frais',  'pl', 'en'),
('napój',       'drink',          'pl', 'en'),
('napoje',      'drinks',         'pl', 'en'),
('przekąski',   'snacks',         'pl', 'en'),
('papryka',     'paprika',        'pl', 'en'),
('olej',        'oil',            'pl', 'en'),
('ocet',        'vinegar',        'pl', 'en'),
('musztarda',   'mustard',        'pl', 'en'),
('majonez',     'mayonnaise',     'pl', 'en'),
('pieczywo',    'bakery',         'pl', 'en'),
('bułka',       'roll',           'pl', 'en'),
('rogalik',     'croissant',      'pl', 'en'),
('płatki',      'cereal',         'pl', 'en'),
('musli',       'muesli',         'pl', 'en'),
('dżem',        'jam',            'pl', 'en'),
('krakersy',    'crackers',       'pl', 'en'),

-- ── EN → PL ──────────────────────────────────────────────────────────────────
('milk',        'mleko',          'en', 'pl'),
('cheese',      'ser',            'en', 'pl'),
('bread',       'chleb',          'en', 'pl'),
('butter',      'masło',          'en', 'pl'),
('egg',         'jajko',          'en', 'pl'),
('eggs',        'jajka',          'en', 'pl'),
('flour',       'mąka',           'en', 'pl'),
('sugar',       'cukier',         'en', 'pl'),
('salt',        'sól',            'en', 'pl'),
('water',       'woda',           'en', 'pl'),
('juice',       'sok',            'en', 'pl'),
('beer',        'piwo',           'en', 'pl'),
('wine',        'wino',           'en', 'pl'),
('tea',         'herbata',        'en', 'pl'),
('coffee',      'kawa',           'en', 'pl'),
('rice',        'ryż',            'en', 'pl'),
('pasta',       'makaron',        'en', 'pl'),
('meat',        'mięso',          'en', 'pl'),
('chicken',     'kurczak',        'en', 'pl'),
('fish',        'ryba',           'en', 'pl'),
('vegetables',  'warzywa',        'en', 'pl'),
('fruit',       'owoce',          'en', 'pl'),
('apple',       'jabłko',         'en', 'pl'),
('banana',      'banan',          'en', 'pl'),
('tomato',      'pomidor',        'en', 'pl'),
('potato',      'ziemniak',       'en', 'pl'),
('chips',       'chipsy',         'en', 'pl'),
('chocolate',   'czekolada',      'en', 'pl'),
('cookies',     'ciastka',        'en', 'pl'),
('ice cream',   'lody',           'en', 'pl'),
('yogurt',      'jogurt',         'en', 'pl'),
('sour cream',  'śmietana',       'en', 'pl'),
('sausage',     'kiełbasa',       'en', 'pl'),
('ham',         'szynka',         'en', 'pl'),
('fromage frais', 'serek',        'en', 'pl'),
('drink',       'napój',          'en', 'pl'),
('drinks',      'napoje',         'en', 'pl'),
('snacks',      'przekąski',      'en', 'pl'),
('paprika',     'papryka',        'en', 'pl'),
('oil',         'olej',           'en', 'pl'),
('vinegar',     'ocet',           'en', 'pl'),
('mustard',     'musztarda',      'en', 'pl'),
('mayonnaise',  'majonez',        'en', 'pl'),
('bakery',      'pieczywo',       'en', 'pl'),
('roll',        'bułka',          'en', 'pl'),
('croissant',   'rogalik',        'en', 'pl'),
('cereal',      'płatki',         'en', 'pl'),
('muesli',      'musli',          'en', 'pl'),
('jam',         'dżem',           'en', 'pl'),
('crackers',    'krakersy',       'en', 'pl')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. expand_search_query() — returns synonym terms for a search query
--    Looks up both the whole query and individual words (for multi-word queries).
--    Case-insensitive matching against search_synonyms.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.expand_search_query(p_query text)
RETURNS text[]
LANGUAGE sql STABLE
SECURITY INVOKER
SET search_path = public
AS $$
    WITH terms AS (
        -- Whole query as one lookup term
        SELECT LOWER(TRIM(p_query)) AS term
        UNION
        -- Individual words (only for multi-word queries)
        SELECT LOWER(w)
        FROM unnest(string_to_array(TRIM(p_query), ' ')) AS w
        WHERE w <> ''
          AND TRIM(p_query) LIKE '% %'
    )
    SELECT COALESCE(
        array_agg(DISTINCT ss.term_target),
        ARRAY[]::text[]
    )
    FROM terms t
    JOIN public.search_synonyms ss
        ON LOWER(ss.term_original) = t.term;
$$;

COMMENT ON FUNCTION public.expand_search_query(text) IS
    'Returns cross-language synonym terms for search expansion. Case-insensitive.';

GRANT EXECUTE ON FUNCTION public.expand_search_query(text)
    TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Update api_search_products() — add synonym expansion
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
    v_query_clean     text;   -- unaccented query for matching
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
    -- Phase 3: synonym expansion
    v_synonym_terms   text[] := ARRAY[]::text[];
    v_synonym_tsq     tsquery;
BEGIN
    -- ── Sanitize inputs ─────────────────────────────────────────────────────
    v_query := NULLIF(TRIM(COALESCE(p_query, '')), '');
    p_page_size := LEAST(GREATEST(p_page_size, 1), 100);
    p_page      := GREATEST(p_page, 1);
    v_offset    := (p_page - 1) * p_page_size;

    -- Unaccent the query for diacritic-insensitive matching
    v_query_clean := CASE WHEN v_query IS NOT NULL
                          THEN unaccent(v_query)
                          ELSE NULL END;

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
    v_language := resolve_language(NULL);

    -- ── Build tsquery from unaccented words (prefix matching) ───────────────
    IF v_query_clean IS NOT NULL AND LENGTH(v_query_clean) >= 1 THEN
        SELECT to_tsquery('simple',
            string_agg(lexeme || ':*', ' & '))
        INTO v_tsq
        FROM unnest(string_to_array(v_query_clean, ' ')) AS lexeme
        WHERE lexeme <> '';
    END IF;

    -- ── Expand query with cross-language synonyms ───────────────────────────
    IF v_query_clean IS NOT NULL THEN
        v_synonym_terms := expand_search_query(v_query_clean);

        IF array_length(v_synonym_terms, 1) > 0 THEN
            -- Build OR-combined tsquery from all synonym terms
            -- Multi-word synonyms use & (all words must match),
            -- different synonyms are ORed together
            SELECT to_tsquery('simple',
                string_agg(
                    (SELECT string_agg(w || ':*', ' & ')
                     FROM unnest(string_to_array(unaccent(syn), ' ')) AS w
                     WHERE w <> ''),
                    ' | '
                )
            )
            INTO v_synonym_tsq
            FROM unnest(v_synonym_terms) AS syn
            WHERE syn IS NOT NULL AND syn <> '';
        END IF;
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
            p.product_name_en,
            CASE
                WHEN v_language = LOWER(p.country) THEN p.product_name
                WHEN v_language = 'en' THEN COALESCE(p.product_name_en, p.product_name)
                ELSE p.product_name
            END                                          AS product_name_display,
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
                WHEN v_query_clean IS NOT NULL THEN
                    -- Original query relevance
                    COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq)
                             ELSE 0 END, 0)
                    + GREATEST(
                        similarity(unaccent(p.product_name), v_query_clean),
                        similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                        similarity(unaccent(p.brand), v_query_clean) * 0.8
                    )
                    -- Synonym relevance (weighted 0.9× to prefer direct matches)
                    + COALESCE(
                        CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                             THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                             ELSE 0 END, 0)
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
              v_query_clean IS NULL
              -- Original query matching
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR unaccent(p.product_name) ILIKE '%' || v_query_clean || '%'
              OR unaccent(p.brand)        ILIKE '%' || v_query_clean || '%'
              OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || v_query_clean || '%'
              OR similarity(unaccent(p.product_name), v_query_clean) > 0.15
              OR similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean) > 0.15
              -- Synonym matching (Phase 3)
              OR (v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq)
              OR EXISTS (
                  SELECT 1 FROM unnest(v_synonym_terms) AS syn
                  WHERE unaccent(p.product_name) ILIKE '%' || unaccent(syn) || '%'
                     OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || unaccent(syn) || '%'
              )
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
                      + CASE WHEN v_query_clean IS NOT NULL
                             THEN GREATEST(
                                 similarity(unaccent(p.product_name), v_query_clean),
                                 similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                 similarity(unaccent(p.brand), v_query_clean) * 0.8)
                             ELSE 0 END
                      + COALESCE(
                            CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                 THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                 ELSE 0 END, 0))
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
                      + CASE WHEN v_query_clean IS NOT NULL
                             THEN GREATEST(
                                 similarity(unaccent(p.product_name), v_query_clean),
                                 similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                 similarity(unaccent(p.brand), v_query_clean) * 0.8)
                             ELSE 0 END
                      + COALESCE(
                            CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                 THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                 ELSE 0 END, 0))
            END ASC NULLS LAST,
            p.unhealthiness_score ASC NULLS LAST
        LIMIT p_page_size OFFSET v_offset
    )
    SELECT COALESCE(MAX(sr.total_count)::int, 0),
           COALESCE(jsonb_agg(jsonb_build_object(
               'product_id',          sr.product_id,
               'product_name',        sr.product_name,
               'product_name_en',     sr.product_name_en,
               'product_name_display', sr.product_name_display,
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

REVOKE EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_search_products(text, jsonb, integer, integer, boolean) TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Update api_search_autocomplete() — add synonym expansion
-- ═══════════════════════════════════════════════════════════════════════════════

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
    v_query         text;
    v_query_clean   text;
    v_tsq           tsquery;
    v_rows          jsonb;
    v_country       text;
    v_language      text;
    -- Phase 3: synonym expansion
    v_synonym_terms text[] := ARRAY[]::text[];
    v_synonym_tsq   tsquery;
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
    v_country     := resolve_effective_country(NULL);
    v_language    := resolve_language(NULL);
    v_query_clean := unaccent(v_query);

    -- Build prefix tsquery from unaccented words
    SELECT to_tsquery('simple', string_agg(word || ':*', ' & '))
    INTO   v_tsq
    FROM   unnest(string_to_array(v_query_clean, ' ')) AS word
    WHERE  word <> '';

    -- Expand query with cross-language synonyms
    v_synonym_terms := expand_search_query(v_query_clean);
    IF array_length(v_synonym_terms, 1) > 0 THEN
        SELECT to_tsquery('simple',
            string_agg(
                (SELECT string_agg(w || ':*', ' & ')
                 FROM unnest(string_to_array(unaccent(syn), ' ')) AS w
                 WHERE w <> ''),
                ' | '
            )
        )
        INTO v_synonym_tsq
        FROM unnest(v_synonym_terms) AS syn
        WHERE syn IS NOT NULL AND syn <> '';
    END IF;

    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb) INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'product_id',          p.product_id,
            'product_name',        p.product_name,
            'product_name_en',     p.product_name_en,
            'product_name_display', CASE
                WHEN v_language = LOWER(p.country) THEN p.product_name
                WHEN v_language = 'en' THEN COALESCE(p.product_name_en, p.product_name)
                ELSE p.product_name
            END,
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
              -- Original query matching
              (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR unaccent(p.product_name) ILIKE v_query_clean || '%'
              OR unaccent(p.brand) ILIKE v_query_clean || '%'
              OR unaccent(COALESCE(p.product_name_en, '')) ILIKE v_query_clean || '%'
              -- Synonym matching (Phase 3)
              OR (v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq)
              OR EXISTS (
                  SELECT 1 FROM unnest(v_synonym_terms) AS syn
                  WHERE unaccent(p.product_name) ILIKE unaccent(syn) || '%'
                     OR unaccent(COALESCE(p.product_name_en, '')) ILIKE unaccent(syn) || '%'
              )
          )
        ORDER BY
            -- Prefer direct matches over synonym matches
            CASE WHEN unaccent(p.product_name) ILIKE v_query_clean || '%' THEN 0
                 WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq THEN 1
                 WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq THEN 2
                 ELSE 3 END,
            CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                 THEN ts_rank(p.search_vector, v_tsq)
                 WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                 THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
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

COMMIT;

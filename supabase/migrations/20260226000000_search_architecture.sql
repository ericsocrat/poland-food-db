-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: 20260226000000_search_architecture.sql
-- Issue #192 — Search Architecture Roadmap
--
-- Formalizes the search ranking model, adds configurable weights,
-- extracts a reusable search_rank() function, adds language-aware
-- search vector building, German synonyms, and a quality report stub.
--
-- Creates:
--   1.  search_ranking_config table + default weights
--   2.  build_search_vector() — language-aware tsvector builder
--   3.  search_rank() — formalized multi-signal ranking function
--   4.  German (DE↔EN) synonym pairs in search_synonyms
--   5.  new_search_ranking feature flag
--   6.  Updated trigger to use build_search_vector()
--   7.  Updated api_search_products() with search_rank() behind flag
--   8.  search_quality_report() stub (Phase 3, requires #190)
--
-- Rollback:
--   DROP FUNCTION IF EXISTS search_quality_report(int, text);
--   DROP FUNCTION IF EXISTS search_rank(tsvector, tsquery, tsquery, text, text, text, text, text, numeric, jsonb);
--   DROP FUNCTION IF EXISTS build_search_vector(text, text, text, text, text);
--   DROP TABLE IF EXISTS search_ranking_config CASCADE;
--   DELETE FROM search_synonyms WHERE language_from = 'de' OR language_to = 'de';
--   DELETE FROM feature_flags WHERE key = 'new_search_ranking';
--   -- Then restore api_search_products + trigger from Phase 3 migration
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. search_ranking_config — configurable ranking weights
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.search_ranking_config (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    config_name text   NOT NULL UNIQUE,
    description text,
    weights     jsonb  NOT NULL,
    active      boolean NOT NULL DEFAULT false,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.search_ranking_config IS
    'Configurable search ranking weights. Only one config may be active at a time. '
    'Allows A/B testing of ranking models via feature flags (#191).';

ALTER TABLE public.search_ranking_config ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'search_ranking_config'
          AND policyname = 'search_ranking_config_read_all'
    ) THEN
        CREATE POLICY "search_ranking_config_read_all"
            ON public.search_ranking_config FOR SELECT
            USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'search_ranking_config'
          AND policyname = 'search_ranking_config_write_service'
    ) THEN
        CREATE POLICY "search_ranking_config_write_service"
            ON public.search_ranking_config FOR ALL
            TO service_role
            USING (true);
    END IF;
END $$;

GRANT SELECT ON public.search_ranking_config TO authenticated, anon, service_role;

-- Ensure only one active config via partial unique index
CREATE UNIQUE INDEX IF NOT EXISTS idx_search_ranking_config_single_active
    ON public.search_ranking_config (active) WHERE active = true;

-- Seed default config
INSERT INTO public.search_ranking_config (config_name, description, weights, active) VALUES
(
    'default',
    'Baseline 5-signal ranking model: text_rank (0.35), trigram_similarity (0.30), synonym_match (0.15), category_context (0.10), data_completeness (0.10)',
    '{
        "text_rank": 0.35,
        "trigram_similarity": 0.30,
        "synonym_match": 0.15,
        "category_context": 0.10,
        "data_completeness": 0.10
    }'::jsonb,
    true
)
ON CONFLICT (config_name) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. build_search_vector() — language-aware tsvector builder
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.build_search_vector(
    p_product_name    text,
    p_product_name_en text,
    p_brand           text,
    p_category        text,
    p_country         text
)
RETURNS tsvector
LANGUAGE plpgsql STABLE
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    v_config regconfig;
BEGIN
    -- Select text-search configuration based on product country
    v_config := CASE UPPER(COALESCE(p_country, 'PL'))
        WHEN 'DE' THEN 'german'::regconfig
        WHEN 'UK' THEN 'english'::regconfig
        WHEN 'CZ' THEN 'simple'::regconfig   -- Czech: no built-in config, use simple
        ELSE 'simple'::regconfig              -- PL + fallback: simple with unaccent
    END;

    RETURN
        setweight(to_tsvector(v_config, unaccent(COALESCE(p_product_name, ''))), 'A') ||
        setweight(to_tsvector('english', unaccent(COALESCE(p_product_name_en, ''))), 'A') ||
        setweight(to_tsvector(v_config, unaccent(COALESCE(p_brand, ''))), 'B') ||
        setweight(to_tsvector(v_config, unaccent(COALESCE(p_category, ''))), 'C');
END;
$$;

COMMENT ON FUNCTION public.build_search_vector(text, text, text, text, text) IS
    'Builds a weighted tsvector using language-specific tokenization based on product country. '
    'Weight A = product names, B = brand, C = category. PL/fallback use simple config, '
    'DE uses german stemmer, EN/UK use english stemmer.';

GRANT EXECUTE ON FUNCTION public.build_search_vector(text, text, text, text, text)
    TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. search_rank() — formalized multi-signal ranking function
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.search_rank(
    p_search_vector    tsvector,
    p_tsquery          tsquery,
    p_synonym_tsquery  tsquery,
    p_product_name     text,
    p_product_name_en  text,
    p_brand            text,
    p_category         text,
    p_query_clean      text,
    p_data_completeness numeric,
    p_weights          jsonb
)
RETURNS numeric
LANGUAGE plpgsql STABLE
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    v_text_rank        numeric;
    v_trigram_rank     numeric;
    v_synonym_rank     numeric;
    v_category_boost   numeric;
    v_completeness     numeric;
    v_w_text           numeric;
    v_w_trigram        numeric;
    v_w_synonym        numeric;
    v_w_category       numeric;
    v_w_completeness   numeric;
BEGIN
    -- Extract weights (with fallback defaults)
    v_w_text       := COALESCE((p_weights->>'text_rank')::numeric,        0.35);
    v_w_trigram    := COALESCE((p_weights->>'trigram_similarity')::numeric, 0.30);
    v_w_synonym    := COALESCE((p_weights->>'synonym_match')::numeric,     0.15);
    v_w_category   := COALESCE((p_weights->>'category_context')::numeric,  0.10);
    v_w_completeness := COALESCE((p_weights->>'data_completeness')::numeric, 0.10);

    -- Signal 1: Full-text ts_rank (0–1 scale, weighted by tsvector field weights)
    v_text_rank := COALESCE(
        CASE WHEN p_tsquery IS NOT NULL AND p_search_vector @@ p_tsquery
             THEN ts_rank(p_search_vector, p_tsquery)
             ELSE 0 END, 0);

    -- Signal 2: Trigram similarity (0–1 scale, best of name/name_en/brand)
    v_trigram_rank := GREATEST(
        similarity(unaccent(COALESCE(p_product_name, '')), p_query_clean),
        similarity(unaccent(COALESCE(p_product_name_en, '')), p_query_clean),
        similarity(unaccent(COALESCE(p_brand, '')), p_query_clean) * 0.8
    );

    -- Signal 3: Synonym full-text match (0–1 scale, discounted 0.9×)
    v_synonym_rank := COALESCE(
        CASE WHEN p_synonym_tsquery IS NOT NULL AND p_search_vector @@ p_synonym_tsquery
             THEN ts_rank(p_search_vector, p_synonym_tsquery) * 0.9
             ELSE 0 END, 0);

    -- Signal 4: Category context boost (0/0.5/1 scale)
    v_category_boost := CASE
        WHEN p_query_clean ILIKE '%' || COALESCE(p_category, '') || '%'
            AND LENGTH(COALESCE(p_category, '')) >= 2 THEN 1.0
        WHEN similarity(p_query_clean, COALESCE(p_category, '')) > 0.3 THEN 0.5
        ELSE 0.0
    END;

    -- Signal 5: Data completeness (0–1 scale)
    v_completeness := COALESCE(p_data_completeness, 0) / 100.0;

    -- Weighted composite score
    RETURN (v_text_rank      * v_w_text) +
           (v_trigram_rank   * v_w_trigram) +
           (v_synonym_rank   * v_w_synonym) +
           (v_category_boost * v_w_category) +
           (v_completeness   * v_w_completeness);
END;
$$;

COMMENT ON FUNCTION public.search_rank(tsvector, tsquery, tsquery, text, text, text, text, text, numeric, jsonb) IS
    'Formalized 5-signal search ranking function. Signals: (1) full-text ts_rank, '
    '(2) trigram similarity, (3) synonym match, (4) category context, (5) data completeness. '
    'Weights are passed as a JSONB parameter from search_ranking_config.';

REVOKE EXECUTE ON FUNCTION public.search_rank(tsvector, tsquery, tsquery, text, text, text, text, text, numeric, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.search_rank(tsvector, tsquery, tsquery, text, text, text, text, text, numeric, jsonb)
    TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. German (DE↔EN) synonyms
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.search_synonyms (term_original, term_target, language_from, language_to) VALUES
-- ── DE → EN ──────────────────────────────────────────────────────────────────
('milch',        'milk',        'de', 'en'),
('käse',         'cheese',      'de', 'en'),
('brot',         'bread',       'de', 'en'),
('butter',       'butter',      'de', 'en'),
('ei',           'egg',         'de', 'en'),
('eier',         'eggs',        'de', 'en'),
('mehl',         'flour',       'de', 'en'),
('zucker',       'sugar',       'de', 'en'),
('salz',         'salt',        'de', 'en'),
('wasser',       'water',       'de', 'en'),
('saft',         'juice',       'de', 'en'),
('bier',         'beer',        'de', 'en'),
('wein',         'wine',        'de', 'en'),
('tee',          'tea',         'de', 'en'),
('kaffee',       'coffee',      'de', 'en'),
('reis',         'rice',        'de', 'en'),
('nudeln',       'pasta',       'de', 'en'),
('fleisch',      'meat',        'de', 'en'),
('hähnchen',     'chicken',     'de', 'en'),
('fisch',        'fish',        'de', 'en'),
('gemüse',       'vegetables',  'de', 'en'),
('obst',         'fruit',       'de', 'en'),
('apfel',        'apple',       'de', 'en'),
('banane',       'banana',      'de', 'en'),
('tomate',       'tomato',      'de', 'en'),
('kartoffel',    'potato',      'de', 'en'),
('chips',        'chips',       'de', 'en'),
('schokolade',   'chocolate',   'de', 'en'),
('kekse',        'cookies',     'de', 'en'),
('eis',          'ice cream',   'de', 'en'),
('joghurt',      'yogurt',      'de', 'en'),
('sahne',        'cream',       'de', 'en'),
('wurst',        'sausage',     'de', 'en'),
('schinken',     'ham',         'de', 'en'),
('getränk',      'drink',       'de', 'en'),
('getränke',     'drinks',      'de', 'en'),
('snacks',       'snacks',      'de', 'en'),
('paprika',      'paprika',     'de', 'en'),
('öl',           'oil',         'de', 'en'),
('essig',        'vinegar',     'de', 'en'),
('senf',         'mustard',     'de', 'en'),
('mayonnaise',   'mayonnaise',  'de', 'en'),
('bäckerei',     'bakery',      'de', 'en'),
('brötchen',     'roll',        'de', 'en'),
('croissant',    'croissant',   'de', 'en'),
('müsli',        'muesli',      'de', 'en'),
('marmelade',    'jam',         'de', 'en'),
('cracker',      'crackers',    'de', 'en'),
('zuckerfrei',   'sugar free',  'de', 'en'),
('glutenfrei',   'gluten free', 'de', 'en'),

-- ── EN → DE ──────────────────────────────────────────────────────────────────
('milk',         'milch',       'en', 'de'),
('cheese',       'käse',        'en', 'de'),
('bread',        'brot',        'en', 'de'),
('butter',       'butter',      'en', 'de'),
('egg',          'ei',          'en', 'de'),
('eggs',         'eier',        'en', 'de'),
('flour',        'mehl',        'en', 'de'),
('sugar',        'zucker',      'en', 'de'),
('salt',         'salz',        'en', 'de'),
('water',        'wasser',      'en', 'de'),
('juice',        'saft',        'en', 'de'),
('beer',         'bier',        'en', 'de'),
('wine',         'wein',        'en', 'de'),
('tea',          'tee',         'en', 'de'),
('coffee',       'kaffee',      'en', 'de'),
('rice',         'reis',        'en', 'de'),
('pasta',        'nudeln',      'en', 'de'),
('meat',         'fleisch',     'en', 'de'),
('chicken',      'hähnchen',    'en', 'de'),
('fish',         'fisch',       'en', 'de'),
('vegetables',   'gemüse',      'en', 'de'),
('fruit',        'obst',        'en', 'de'),
('apple',        'apfel',       'en', 'de'),
('banana',       'banane',      'en', 'de'),
('tomato',       'tomate',      'en', 'de'),
('potato',       'kartoffel',   'en', 'de'),
('chips',        'chips',       'en', 'de'),
('chocolate',    'schokolade',  'en', 'de'),
('cookies',      'kekse',       'en', 'de'),
('ice cream',    'eis',         'en', 'de'),
('yogurt',       'joghurt',     'en', 'de'),
('cream',        'sahne',       'en', 'de'),
('sausage',      'wurst',       'en', 'de'),
('ham',          'schinken',    'en', 'de'),
('drink',        'getränk',     'en', 'de'),
('drinks',       'getränke',    'en', 'de'),
('snacks',       'snacks',      'en', 'de'),
('paprika',      'paprika',     'en', 'de'),
('oil',          'öl',          'en', 'de'),
('vinegar',      'essig',       'en', 'de'),
('mustard',      'senf',        'en', 'de'),
('mayonnaise',   'mayonnaise',  'en', 'de'),
('bakery',       'bäckerei',    'en', 'de'),
('roll',         'brötchen',    'en', 'de'),
('croissant',    'croissant',   'en', 'de'),
('muesli',       'müsli',       'en', 'de'),
('jam',          'marmelade',   'en', 'de'),
('crackers',     'cracker',     'en', 'de'),
('sugar free',   'zuckerfrei',  'en', 'de'),
('gluten free',  'glutenfrei',  'en', 'de')
ON CONFLICT (term_original, language_from, language_to) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. new_search_ranking feature flag
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.feature_flags (key, name, description, flag_type, enabled, tags, expires_at)
VALUES (
    'new_search_ranking',
    'New Search Ranking Model',
    'Enables the formalized 5-signal search_rank() function with configurable weights from search_ranking_config. When disabled, falls back to legacy inline ranking.',
    'boolean',
    false,
    ARRAY['search', 'ranking'],
    now() + INTERVAL '6 months'
)
ON CONFLICT (key) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Update trigger to use build_search_vector()
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.trg_products_search_vector()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    NEW.search_vector := build_search_vector(
        NEW.product_name,
        NEW.product_name_en,
        NEW.brand,
        NEW.category,
        NEW.country
    );
    RETURN NEW;
END;
$$;

-- Re-create trigger to also fire on country changes
DROP TRIGGER IF EXISTS trg_products_search_vector_update ON products;
CREATE TRIGGER trg_products_search_vector_update
    BEFORE INSERT OR UPDATE OF product_name, product_name_en, brand, category, country
    ON products FOR EACH ROW
    EXECUTE FUNCTION trg_products_search_vector();

-- Backfill search_vector for all products using language-aware builder
UPDATE products
SET search_vector = build_search_vector(
    product_name, product_name_en, brand, category, country
)
WHERE search_vector IS DISTINCT FROM build_search_vector(
    product_name, product_name_en, brand, category, country
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Updated api_search_products() — search_rank() behind feature flag
-- ═══════════════════════════════════════════════════════════════════════════════

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
    v_query_clean     text;
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
    v_synonym_terms   text[] := ARRAY[]::text[];
    v_synonym_tsq     tsquery;
    -- ── New: search architecture (#192) ──
    v_use_new_ranking boolean;
    v_weights         jsonb;
BEGIN
    -- ── Input normalization ──────────────────────────────────────────────────
    v_query := NULLIF(TRIM(COALESCE(p_query, '')), '');
    p_page_size := LEAST(GREATEST(p_page_size, 1), 100);
    p_page      := GREATEST(p_page, 1);
    v_offset    := (p_page - 1) * p_page_size;

    v_query_clean := CASE WHEN v_query IS NOT NULL
                          THEN unaccent(v_query)
                          ELSE NULL END;

    -- ── Filter parsing ───────────────────────────────────────────────────────
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

    v_country  := resolve_effective_country(p_filters->>'country');
    v_language := resolve_language(NULL);

    -- ── Full-text query construction ─────────────────────────────────────────
    IF v_query_clean IS NOT NULL AND LENGTH(v_query_clean) >= 1 THEN
        SELECT to_tsquery('simple',
            string_agg(lexeme || ':*', ' & '))
        INTO v_tsq
        FROM unnest(string_to_array(v_query_clean, ' ')) AS lexeme
        WHERE lexeme <> '';
    END IF;

    -- ── Synonym expansion ────────────────────────────────────────────────────
    IF v_query_clean IS NOT NULL THEN
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
    END IF;

    -- ── User preferences ─────────────────────────────────────────────────────
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

    -- ── Ranking model selection (#192) ───────────────────────────────────────
    SELECT enabled INTO v_use_new_ranking
    FROM feature_flags
    WHERE key = 'new_search_ranking';
    v_use_new_ranking := COALESCE(v_use_new_ranking, false);

    IF v_use_new_ranking THEN
        SELECT weights INTO v_weights
        FROM search_ranking_config
        WHERE active = true
        LIMIT 1;
    END IF;
    IF v_weights IS NULL THEN
        v_weights := '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb;
    END IF;

    -- ── Main search query ────────────────────────────────────────────────────
    WITH search_results AS (
        SELECT
            p.product_id,
            p.product_name,
            p.product_name_en,
            CASE
                WHEN v_language = LOWER(p.country) THEN p.product_name
                WHEN v_language = 'en' THEN COALESCE(p.product_name_en, p.product_name)
                ELSE p.product_name
            END AS product_name_display,
            p.brand,
            p.category,
            COALESCE(ct.display_name, cr.display_name) AS category_display,
            COALESCE(cr.icon_emoji, '📦') AS category_icon,
            p.unhealthiness_score,
            CASE
                WHEN p.unhealthiness_score <= 25 THEN 'low'
                WHEN p.unhealthiness_score <= 50 THEN 'moderate'
                WHEN p.unhealthiness_score <= 75 THEN 'high'
                ELSE 'very_high'
            END AS score_band,
            p.nutri_score_label AS nutri_score,
            p.nova_classification AS nova_group,
            nf.calories::numeric AS calories,
            COALESCE(p.high_salt_flag = 'YES', false) AS high_salt,
            COALESCE(p.high_sugar_flag = 'YES', false) AS high_sugar,
            COALESCE(p.high_sat_fat_flag = 'YES', false) AS high_sat_fat,
            COALESCE(p.high_additive_load = 'YES', false) AS high_additive_load,
            (p.product_id = ANY(v_avoid_ids)) AS is_avoided,
            -- ── Ranking: new formalized model OR legacy inline ───────────
            CASE WHEN v_query_clean IS NOT NULL THEN
                CASE WHEN v_use_new_ranking THEN
                    search_rank(
                        p.search_vector, v_tsq, v_synonym_tsq,
                        p.product_name, p.product_name_en, p.brand, p.category,
                        v_query_clean, p.data_completeness_pct, v_weights
                    )
                ELSE
                    -- Legacy inline ranking (identical to Phase 3 behavior)
                    COALESCE(
                        CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                             THEN ts_rank(p.search_vector, v_tsq)
                             ELSE 0 END, 0)
                    + GREATEST(
                        similarity(unaccent(p.product_name), v_query_clean),
                        similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                        similarity(unaccent(p.brand), v_query_clean) * 0.8
                    )
                    + COALESCE(
                        CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                             THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                             ELSE 0 END, 0)
                END
            ELSE 0 END AS relevance,
            COUNT(*) OVER() AS total_count
        FROM products p
        LEFT JOIN category_ref cr ON cr.category = p.category
        LEFT JOIN category_translations ct ON ct.category = p.category AND ct.language_code = v_language
        LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND (
              v_query_clean IS NULL
              OR (v_tsq IS NOT NULL AND p.search_vector @@ v_tsq)
              OR unaccent(p.product_name) ILIKE '%' || v_query_clean || '%'
              OR unaccent(p.brand) ILIKE '%' || v_query_clean || '%'
              OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || v_query_clean || '%'
              OR similarity(unaccent(p.product_name), v_query_clean) > 0.15
              OR similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean) > 0.15
              OR (v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq)
              OR EXISTS (
                  SELECT 1 FROM unnest(v_synonym_terms) AS syn
                  WHERE unaccent(p.product_name) ILIKE '%' || unaccent(syn) || '%'
                     OR unaccent(COALESCE(p.product_name_en, '')) ILIKE '%' || unaccent(syn) || '%'
              )
          )
          AND (array_length(v_categories, 1) IS NULL OR p.category = ANY(v_categories))
          AND (array_length(v_nutri_scores, 1) IS NULL OR p.nutri_score_label = ANY(v_nutri_scores))
          AND (v_max_score IS NULL OR p.unhealthiness_score <= v_max_score)
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
            CASE WHEN v_sort_by = 'name' AND v_sort_order <> 'desc' THEN p.product_name END ASC NULLS LAST,
            CASE WHEN v_sort_by = 'name' AND v_sort_order = 'desc' THEN p.product_name END DESC NULLS LAST,
            CASE
                WHEN v_sort_by = 'relevance' THEN
                    -(CASE WHEN v_query_clean IS NOT NULL THEN
                        CASE WHEN v_use_new_ranking THEN
                            search_rank(
                                p.search_vector, v_tsq, v_synonym_tsq,
                                p.product_name, p.product_name_en, p.brand, p.category,
                                v_query_clean, p.data_completeness_pct, v_weights
                            )
                        ELSE
                            COALESCE(CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                                     THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                            + CASE WHEN v_query_clean IS NOT NULL
                                   THEN GREATEST(
                                       similarity(unaccent(p.product_name), v_query_clean),
                                       similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                       similarity(unaccent(p.brand), v_query_clean) * 0.8)
                                   ELSE 0 END
                            + COALESCE(CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                       THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                       ELSE 0 END, 0)
                        END
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
                    -(CASE WHEN v_query_clean IS NOT NULL THEN
                        CASE WHEN v_use_new_ranking THEN
                            search_rank(
                                p.search_vector, v_tsq, v_synonym_tsq,
                                p.product_name, p.product_name_en, p.brand, p.category,
                                v_query_clean, p.data_completeness_pct, v_weights
                            )
                        ELSE
                            COALESCE(CASE WHEN v_tsq IS NOT NULL AND p.search_vector @@ v_tsq
                                     THEN ts_rank(p.search_vector, v_tsq) ELSE 0 END, 0)
                            + CASE WHEN v_query_clean IS NOT NULL
                                   THEN GREATEST(
                                       similarity(unaccent(p.product_name), v_query_clean),
                                       similarity(unaccent(COALESCE(p.product_name_en, '')), v_query_clean),
                                       similarity(unaccent(p.brand), v_query_clean) * 0.8)
                                   ELSE 0 END
                            + COALESCE(CASE WHEN v_synonym_tsq IS NOT NULL AND p.search_vector @@ v_synonym_tsq
                                       THEN ts_rank(p.search_vector, v_synonym_tsq) * 0.9
                                       ELSE 0 END, 0)
                        END
                    ELSE 0 END)
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
-- 8. search_quality_report() — stub for Phase 3 (requires #190)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.search_quality_report(
    p_days    integer DEFAULT 7,
    p_country text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Phase 3: Search quality metrics require the analytics_events table
    -- from Event Analytics (#190). This stub returns the planned schema
    -- so frontend contracts can be established ahead of the dependency.
    RETURN jsonb_build_object(
        'api_version',    '1.0',
        'status',         'pending_dependency',
        'dependency',     'issue_190_event_analytics',
        'period_days',    p_days,
        'country',        COALESCE(p_country, 'all'),
        'message',        'Search quality metrics will be activated when Event Analytics (#190) is deployed.',
        'planned_metrics', jsonb_build_object(
            'total_searches',       NULL,
            'unique_queries',       NULL,
            'zero_result_rate',     NULL,
            'click_through_rate',   NULL,
            'mean_reciprocal_rank', NULL,
            'avg_results_per_query', NULL,
            'top_zero_result_queries', '[]'::jsonb,
            'top_queries',          '[]'::jsonb
        )
    );
END;
$$;

COMMENT ON FUNCTION public.search_quality_report(integer, text) IS
    'Search quality dashboard stub (Phase 3). Returns planned metric schema. '
    'Will compute CTR, zero-result rate, MRR when analytics_events (#190) is available.';

REVOKE EXECUTE ON FUNCTION public.search_quality_report(integer, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.search_quality_report(integer, text) TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Verification
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
    v_count integer;
BEGIN
    -- Verify search_ranking_config has active default
    SELECT COUNT(*) INTO v_count
    FROM search_ranking_config WHERE active = true;
    ASSERT v_count = 1, 'Expected exactly 1 active search_ranking_config';

    -- Verify German synonyms were inserted
    SELECT COUNT(*) INTO v_count
    FROM search_synonyms WHERE language_from = 'de' OR language_to = 'de';
    ASSERT v_count >= 90, 'Expected at least 90 German synonym rows (50 pairs)';

    -- Verify new_search_ranking flag exists
    SELECT COUNT(*) INTO v_count
    FROM feature_flags WHERE key = 'new_search_ranking';
    ASSERT v_count = 1, 'Expected new_search_ranking feature flag';

    -- Verify functions exist
    ASSERT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'build_search_vector'
    ), 'build_search_vector() not found';

    ASSERT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'search_rank'
    ), 'search_rank() not found';

    ASSERT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'search_quality_report'
    ), 'search_quality_report() not found';

    RAISE NOTICE '✓ search_architecture migration verified';
END $$;

COMMIT;

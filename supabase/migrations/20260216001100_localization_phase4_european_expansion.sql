-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: 20260216001100_localization_phase4_european_expansion.sql
-- Phase 4 of Issue #32 — European Expansion Scale
--
-- Creates / alters:
--   1.  Add name_translations JSONB column to products
--   2.  Add default_language column to country_ref (FK → language_ref)
--   3.  Backfill default_language for existing countries
--   4.  Update v_master view to include name_translations
--   5.  Update search_vector trigger to index name_translations values
--   6.  Backfill search_vector for all rows
--   7.  Update api_product_detail() — ELSE branch checks name_translations
--   8.  Update api_search_products() — ELSE branch + synonym match
--   9.  Update api_search_autocomplete() — ELSE branch
--  10.  Update api_record_scan() — ELSE branch + select name_translations
--
-- Rollback notes:
--   ALTER TABLE products DROP COLUMN IF EXISTS name_translations;
--   ALTER TABLE country_ref DROP COLUMN IF EXISTS default_language;
--   -- Then restore all 4 API functions + v_master + trigger from Phase 3
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Add name_translations JSONB to products
--    Stores cross-border translations: {"de": "Paprika Chips", "fr": "Chips au Paprika"}
--    Empty for most products; populated on-demand for cross-border or top items.
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
    ADD COLUMN IF NOT EXISTS name_translations jsonb NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.products.name_translations IS
    'Per-language product name translations as JSONB: {"de": "...", "fr": "..."}. '
    'Used for cross-border products or high-visibility items. Keys are ISO 639-1 codes.';

-- GIN index for key-existence queries (? operator)
CREATE INDEX IF NOT EXISTS idx_products_name_translations
    ON public.products USING GIN (name_translations);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Add default_language to country_ref
--    Tracks the primary language of each country's market.
--    Used by product_name_display logic to detect the "native" language.
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.country_ref
    ADD COLUMN IF NOT EXISTS default_language text;

-- FK to language_ref (only if constraint doesn't exist)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_country_ref_default_language'
          AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.country_ref
            ADD CONSTRAINT fk_country_ref_default_language
            FOREIGN KEY (default_language) REFERENCES public.language_ref(code);
    END IF;
END $$;

COMMENT ON COLUMN public.country_ref.default_language IS
    'ISO 639-1 code for the primary language of this market. '
    'FK to language_ref. Used in product_name_display logic.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Backfill default_language for existing countries
-- ═══════════════════════════════════════════════════════════════════════════════

UPDATE public.country_ref SET default_language = 'pl' WHERE country_code = 'PL' AND default_language IS NULL;
UPDATE public.country_ref SET default_language = 'de' WHERE country_code = 'DE' AND default_language IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Update v_master — include name_translations
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.v_master AS
SELECT
    p.product_id,
    p.country,
    p.brand,
    p.product_type,
    p.category,
    p.product_name,
    p.prep_method,
    p.store_availability,
    p.controversies,
    p.ean,

    -- Nutrition (per 100g)
    nf.calories,
    nf.total_fat_g,
    nf.saturated_fat_g,
    nf.trans_fat_g,
    nf.carbs_g,
    nf.sugars_g,
    nf.fibre_g,
    nf.protein_g,
    nf.salt_g,

    -- Scores
    p.unhealthiness_score,
    p.confidence,
    p.data_completeness_pct,
    p.nutri_score_label,
    p.nova_classification,
    CASE p.nova_classification
        WHEN '4' THEN 'High'
        WHEN '3' THEN 'Moderate'
        WHEN '2' THEN 'Low'
        WHEN '1' THEN 'Low'
        ELSE 'Unknown'
    END AS processing_risk,
    p.high_salt_flag,
    p.high_sugar_flag,
    p.high_sat_fat_flag,
    p.high_additive_load,
    p.ingredient_concern_score,

    -- Score explainability
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, ingr.additives_count::numeric, p.prep_method, p.controversies,
        p.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients
    ingr.additives_count,
    ingr.ingredients_text AS ingredients_raw,
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,
    ingr.vegan_status,
    ingr.vegetarian_status,

    -- Allergens
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance
    p.source_type,
    p.source_url,
    p.source_ean,

    -- Data quality indicators
    CASE
        WHEN ingr.ingredient_count > 0 THEN 'complete'
        ELSE 'missing'
    END AS ingredient_data_quality,

    CASE
        WHEN nf.calories IS NOT NULL
             AND nf.total_fat_g IS NOT NULL
             AND nf.carbs_g IS NOT NULL
             AND nf.protein_g IS NOT NULL
             AND nf.salt_g IS NOT NULL
             AND (nf.total_fat_g IS NULL OR nf.saturated_fat_g IS NULL
                  OR nf.saturated_fat_g <= nf.total_fat_g)
             AND (nf.carbs_g IS NULL OR nf.sugars_g IS NULL
                  OR nf.sugars_g <= nf.carbs_g)
        THEN 'clean'
        ELSE 'suspect'
    END AS nutrition_data_quality,

    -- Phase 2: Product English name + provenance + timestamps
    p.product_name_en,
    p.product_name_en_source,
    p.created_at,
    p.updated_at,

    -- Phase 4: Cross-border translations
    p.name_translations

FROM public.products p
LEFT JOIN public.nutrition_facts nf ON nf.product_id = p.product_id
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::integer AS ingredient_count,
        COUNT(*) FILTER (WHERE ir.is_additive)::integer AS additives_count,
        STRING_AGG(ir.name_en, ', ' ORDER BY pi.position) AS ingredients_text,
        STRING_AGG(CASE WHEN ir.is_additive THEN ir.name_en END, ', ' ORDER BY pi.position) AS additive_names,
        BOOL_OR(ir.from_palm_oil = 'yes') AS has_palm_oil,
        CASE
            WHEN BOOL_AND(ir.vegan IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegan = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegan_status,
        CASE
            WHEN BOOL_AND(ir.vegetarian IN ('yes','unknown')) THEN 'yes'
            WHEN BOOL_OR(ir.vegetarian = 'no') THEN 'no'
            ELSE 'maybe'
        END AS vegetarian_status
    FROM public.product_ingredient pi
    JOIN public.ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
) ingr ON true
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) FILTER (WHERE ai.type = 'contains')::integer AS allergen_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'contains') AS allergen_tags,
        COUNT(*) FILTER (WHERE ai.type = 'traces')::integer AS trace_count,
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'traces') AS trace_tags
    FROM public.product_allergen_info ai
    WHERE ai.product_id = p.product_id
) agg_ai ON true
WHERE p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Update search_vector trigger — include name_translations values
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION trg_products_search_vector()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_trans_vector tsvector := ''::tsvector;
    v_val text;
BEGIN
    -- Build tsvector from name_translations JSONB values (weight B)
    IF NEW.name_translations IS NOT NULL AND NEW.name_translations <> '{}'::jsonb THEN
        FOR v_val IN SELECT jsonb_each_text(NEW.name_translations)
        LOOP
            -- jsonb_each_text returns (key, value) — we get the composite text here
            NULL;
        END LOOP;
        -- Simpler approach: concatenate all values
        SELECT setweight(
            to_tsvector('simple', unaccent(string_agg(val, ' '))),
            'B'
        )
        INTO v_trans_vector
        FROM jsonb_each_text(NEW.name_translations) AS t(key, val);
    END IF;

    NEW.search_vector :=
        setweight(to_tsvector('simple', unaccent(coalesce(NEW.product_name, ''))), 'A') ||
        setweight(to_tsvector('simple', unaccent(coalesce(NEW.product_name_en, ''))), 'A') ||
        v_trans_vector ||
        setweight(to_tsvector('simple', unaccent(coalesce(NEW.brand, ''))), 'B') ||
        setweight(to_tsvector('simple', unaccent(coalesce(NEW.category, ''))), 'C');
    RETURN NEW;
END;
$$;

-- Recreate trigger to also fire on name_translations changes
DROP TRIGGER IF EXISTS trg_products_search_vector_update ON products;
CREATE TRIGGER trg_products_search_vector_update
    BEFORE INSERT OR UPDATE OF product_name, product_name_en, name_translations, brand, category ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_products_search_vector();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Backfill search_vector (now includes name_translations)
-- ═══════════════════════════════════════════════════════════════════════════════

UPDATE products
SET search_vector =
    setweight(to_tsvector('simple', unaccent(coalesce(product_name, ''))), 'A') ||
    setweight(to_tsvector('simple', unaccent(coalesce(product_name_en, ''))), 'A') ||
    COALESCE(
        (SELECT setweight(to_tsvector('simple', unaccent(string_agg(val, ' '))), 'B')
         FROM jsonb_each_text(name_translations) AS t(key, val)),
        ''::tsvector
    ) ||
    setweight(to_tsvector('simple', unaccent(coalesce(brand, ''))), 'B') ||
    setweight(to_tsvector('simple', unaccent(coalesce(category, ''))), 'C');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Update api_product_detail() — ELSE branch checks name_translations
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
$func$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. Update api_search_products() — ELSE branch checks name_translations
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
    v_query_clean     text;
    v_country         text;
    v_language        text;
    v_country_lang    text;   -- Phase 4: country's default language
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

    -- Phase 4: resolve the country's default language
    SELECT cref.default_language INTO v_country_lang
    FROM country_ref cref WHERE cref.country_code = v_country;
    v_country_lang := COALESCE(v_country_lang, LOWER(v_country));

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
                WHEN v_language = COALESCE(cref.default_language, LOWER(p.country))
                    THEN p.product_name
                WHEN v_language = 'en'
                    THEN COALESCE(p.product_name_en, p.product_name)
                ELSE COALESCE(
                    p.name_translations->>v_language,
                    p.product_name_en,
                    p.product_name
                )
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
        LEFT JOIN country_ref cref
            ON cref.country_code = p.country
        WHERE p.is_deprecated IS NOT TRUE
          AND p.country = v_country
          AND (
              v_query_clean IS NULL
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
-- 9. Update api_search_autocomplete() — ELSE branch checks name_translations
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
    v_country_lang  text;
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

    -- Phase 4: resolve the country's default language
    SELECT cref.default_language INTO v_country_lang
    FROM country_ref cref WHERE cref.country_code = v_country;
    v_country_lang := COALESCE(v_country_lang, LOWER(v_country));

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
                WHEN v_language = COALESCE(cref.default_language, LOWER(p.country))
                    THEN p.product_name
                WHEN v_language = 'en'
                    THEN COALESCE(p.product_name_en, p.product_name)
                ELSE COALESCE(
                    p.name_translations->>v_language,
                    p.product_name_en,
                    p.product_name
                )
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
        LEFT JOIN country_ref cref ON cref.country_code = p.country
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. Update api_record_scan() — ELSE branch checks name_translations
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_record_scan(
  p_ean text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id      uuid := auth.uid();
  v_product      record;
  v_found        boolean := false;
  v_product_id   bigint;
  v_language     text;
  v_country_lang text;
  v_cat_display  text;
  v_cat_icon     text;
BEGIN
  -- Validate
  IF p_ean IS NULL OR LENGTH(TRIM(p_ean)) NOT IN (8, 13) THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'EAN must be 8 or 13 digits'
    );
  END IF;

  -- Resolve user language
  v_language := resolve_language(NULL);

  -- Lookup product by EAN (now includes name_translations)
  SELECT p.product_id, p.product_name, p.product_name_en, p.name_translations,
         p.brand, p.category, p.country, p.unhealthiness_score, p.nutri_score_label
    INTO v_product
    FROM public.products p
   WHERE p.ean = TRIM(p_ean)
   LIMIT 1;

  IF FOUND THEN
    v_found := true;
    v_product_id := v_product.product_id;

    -- Resolve country default language
    SELECT cref.default_language INTO v_country_lang
    FROM public.country_ref cref
    WHERE cref.country_code = v_product.country;
    v_country_lang := COALESCE(v_country_lang, LOWER(v_product.country));

    -- Resolve category display + icon
    SELECT COALESCE(ct.display_name, cr.display_name),
           COALESCE(cr.icon_emoji, '📦')
    INTO v_cat_display, v_cat_icon
    FROM public.category_ref cr
    LEFT JOIN public.category_translations ct
        ON ct.category = cr.category AND ct.language_code = v_language
    WHERE cr.category = v_product.category;
  END IF;

  -- Record scan (only for authenticated users)
  IF v_user_id IS NOT NULL THEN
    INSERT INTO public.scan_history (user_id, ean, product_id, found)
    VALUES (v_user_id, TRIM(p_ean), v_product_id, v_found);
  END IF;

  -- Return result
  IF v_found THEN
    RETURN jsonb_build_object(
      'api_version',    '1.0',
      'found',          true,
      'product_id',     v_product.product_id,
      'product_name',   v_product.product_name,
      'product_name_en', v_product.product_name_en,
      'product_name_display', CASE
          WHEN v_language = v_country_lang THEN v_product.product_name
          WHEN v_language = 'en' THEN COALESCE(v_product.product_name_en, v_product.product_name)
          ELSE COALESCE(
              v_product.name_translations->>v_language,
              v_product.product_name_en,
              v_product.product_name
          )
      END,
      'brand',              v_product.brand,
      'category',           v_product.category,
      'category_display',   v_cat_display,
      'category_icon',      v_cat_icon,
      'unhealthiness_score', v_product.unhealthiness_score,
      'nutri_score',        v_product.nutri_score_label
    );
  ELSE
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'found',       false,
      'ean',         TRIM(p_ean),
      'has_pending_submission', EXISTS (
        SELECT 1 FROM public.product_submissions
         WHERE ean = TRIM(p_ean) AND status = 'pending'
      )
    );
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.api_record_scan(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_record_scan(text) TO authenticated, service_role;

COMMIT;

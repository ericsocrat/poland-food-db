-- Migration: Nutri-Score provenance (#353)
-- Adds country-level Nutri-Score adoption flag and per-product source column.
-- Rollback: ALTER TABLE country_ref DROP COLUMN IF EXISTS nutri_score_official;
--           ALTER TABLE products DROP COLUMN IF EXISTS nutri_score_source;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Add nutri_score_official flag to country_ref
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.country_ref
  ADD COLUMN IF NOT EXISTS nutri_score_official boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.country_ref.nutri_score_official IS
  'Whether Nutri-Score is officially adopted/endorsed in this country (EU regulation status)';

-- Backfill: DE adopted Nutri-Score in 2020 (voluntary), PL has not
UPDATE public.country_ref
SET nutri_score_official = true
WHERE country_code = 'DE';

UPDATE public.country_ref
SET nutri_score_official = false
WHERE country_code = 'PL';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Add nutri_score_source column to products
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS nutri_score_source text;

ALTER TABLE public.products
  DROP CONSTRAINT IF EXISTS chk_products_nutri_score_source;

ALTER TABLE public.products
  ADD CONSTRAINT chk_products_nutri_score_source
  CHECK (nutri_score_source IS NULL OR nutri_score_source IN (
    'official_label',   -- printed on physical package (DE products)
    'off_computed',     -- computed by Open Food Facts algorithm
    'manual',           -- manually assigned during research
    'unknown'           -- source not determined
  ));

COMMENT ON COLUMN public.products.nutri_score_source IS
  'How the nutri_score_label was determined: official package label, OFF computation, manual, or unknown';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Backfill nutri_score_source for existing products
-- ═══════════════════════════════════════════════════════════════════════════

-- All existing Nutri-Score values came from OFF API pipeline.
-- NOT-APPLICABLE (alcohol) and NULL have no meaningful source.
-- UNKNOWN means we tried but OFF couldn't compute it.
UPDATE public.products
SET nutri_score_source = CASE
  WHEN nutri_score_label IS NULL           THEN NULL
  WHEN nutri_score_label = 'NOT-APPLICABLE' THEN NULL
  WHEN nutri_score_label = 'UNKNOWN'       THEN 'unknown'
  ELSE 'off_computed'
END
WHERE nutri_score_source IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Update v_master to include nutri_score_source
-- ═══════════════════════════════════════════════════════════════════════════

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

    -- Nutrition (per 100g — direct from nutrition_facts, no serving indirection)
    nf.calories,
    nf.total_fat_g,
    nf.saturated_fat_g,
    nf.trans_fat_g,
    nf.carbs_g,
    nf.sugars_g,
    nf.fibre_g,
    nf.protein_g,
    nf.salt_g,

    -- Scores (now on products directly)
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

    -- Score explainability (JSONB breakdown of all 9 factors)
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, ingr.additives_count::numeric, p.prep_method, p.controversies,
        p.ingredient_concern_score
    ) AS score_breakdown,

    -- Ingredients (derived from junction tables)
    ingr.additives_count,
    ingr.ingredients_text AS ingredients_raw,
    ingr.ingredient_count,
    ingr.additive_names,
    ingr.has_palm_oil,

    -- Vegan / vegetarian — override to NULL when allergens contradict
    CASE
        WHEN ingr.vegan_status = 'yes'
             AND COALESCE(agg_ai.has_animal_allergen, false)
        THEN NULL
        ELSE ingr.vegan_status
    END AS vegan_status,

    CASE
        WHEN ingr.vegetarian_status = 'yes'
             AND COALESCE(agg_ai.has_meat_fish_allergen, false)
        THEN NULL
        ELSE ingr.vegetarian_status
    END AS vegetarian_status,

    -- Contradiction flags (for frontend warnings)
    (ingr.vegan_status = 'yes'
        AND COALESCE(agg_ai.has_animal_allergen, false)) AS vegan_contradiction,
    (ingr.vegetarian_status = 'yes'
        AND COALESCE(agg_ai.has_meat_fish_allergen, false)) AS vegetarian_contradiction,

    -- Allergen/trace (from unified product_allergen_info table — single-scan aggregation)
    COALESCE(agg_ai.allergen_count, 0) AS allergen_count,
    agg_ai.allergen_tags,
    COALESCE(agg_ai.trace_count, 0) AS trace_count,
    agg_ai.trace_tags,

    -- Source provenance (now on products directly)
    p.source_type,
    p.source_url,
    p.source_ean,

    -- Primary product image URL (from product_images table)
    (SELECT img.url
     FROM product_images img
     WHERE img.product_id = p.product_id AND img.is_primary = true
     LIMIT 1) AS image_thumb_url,

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
    p.name_translations,

    -- Store architecture: count and names from M:N junction
    (SELECT COUNT(*)::int
     FROM product_store_availability psa
     JOIN store_ref sr ON sr.store_id = psa.store_id
     WHERE psa.product_id = p.product_id AND sr.is_active = true
    ) AS store_count,
    (SELECT STRING_AGG(sr.store_name, ', ' ORDER BY sr.sort_order)
     FROM product_store_availability psa
     JOIN store_ref sr ON sr.store_id = psa.store_id
     WHERE psa.product_id = p.product_id AND sr.is_active = true
    ) AS store_names,

    -- Nutri-Score provenance (#353)
    p.nutri_score_source

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
        STRING_AGG(ai.tag, ', ' ORDER BY ai.tag) FILTER (WHERE ai.type = 'traces') AS trace_tags,
        -- Contradiction detection flags
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'milk', 'eggs', 'fish', 'crustaceans', 'molluscs'
        )) AS has_animal_allergen,
        BOOL_OR(ai.type = 'contains' AND ai.tag IN (
            'fish', 'crustaceans', 'molluscs'
        )) AS has_meat_fish_allergen
    FROM public.product_allergen_info ai
    WHERE ai.product_id = p.product_id
) agg_ai ON true
WHERE p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Update api_product_detail to include nutri_score_source +
--    nutri_score_official_in_country
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
            'nutri_score_source',  m.nutri_score_source,
            'nutri_score_official_in_country', COALESCE(cref.nutri_score_official, false),
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
-- 6. Update api_category_listing to include nutri_score_source
-- ═══════════════════════════════════════════════════════════════════════════

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
    SELECT cr.category INTO v_category
    FROM category_ref cr WHERE cr.slug = p_category;

    IF v_category IS NULL THEN
        SELECT cr.category INTO v_category
        FROM category_ref cr WHERE cr.category = p_category;
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
            'nutri_score_source',  m.nutri_score_source,
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
            'data_completeness_pct', m.data_completeness_pct,
            'image_thumb_url',     m.image_thumb_url
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

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Update api_score_explanation to include provenance note
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_score_explanation(p_product_id bigint)
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
        'model_version',   pp.score_model_version,
        'scored_at',       pp.scored_at,
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
            'nutri_score',       m.nutri_score_label,
            'nutri_score_source', m.nutri_score_source,
            'nutri_score_official_in_country', COALESCE(cref.nutri_score_official, false),
            'nutri_score_note',  CASE
                                   WHEN COALESCE(cref.nutri_score_official, false) = false
                                        AND m.nutri_score_label IS NOT NULL
                                        AND m.nutri_score_label NOT IN ('NOT-APPLICABLE', 'UNKNOWN')
                                   THEN 'Nutri-Score is not officially adopted in this country. This grade is computed from nutrition data and may differ from grades shown on the physical label.'
                                   ELSE NULL
                                 END,
            'nova_group',        m.nova_classification,
            'processing_risk',   m.processing_risk
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
    JOIN products pp ON pp.product_id = m.product_id
    LEFT JOIN country_ref cref ON cref.country_code = m.country
    WHERE m.product_id = p_product_id;
$function$;

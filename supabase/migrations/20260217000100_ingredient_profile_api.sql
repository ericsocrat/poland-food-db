-- ─── Ingredient Profile API ─────────────────────────────────────────────────
-- Issue #36 — Ingredient Profile Pages
-- Provides api_get_ingredient_profile() for individual ingredient deep-dives
-- and updates api_get_product_profile() to include ingredient_id for linking.

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. New function: api_get_ingredient_profile
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_ingredient_profile(
    p_ingredient_id bigint,
    p_language      text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
    v_language text;
    v_result   jsonb;
BEGIN
    v_language := resolve_language(p_language);

    -- ── ingredient core ─────────────────────────────────────────────────
    SELECT jsonb_build_object(
        'api_version', '1.0',
        'ingredient', jsonb_build_object(
            'ingredient_id',   ir.ingredient_id,
            'taxonomy_id',     ir.taxonomy_id,
            'name_en',         ir.name_en,
            'name_display',    ir.name_en,  -- future: localize via name_translations
            'is_additive',     ir.is_additive,
            'additive_code',   CASE
                                 WHEN ir.is_additive THEN UPPER(ir.name_en)
                                 ELSE NULL
                               END,
            'concern_tier',    COALESCE(ir.concern_tier, 0),
            'concern_tier_label', COALESCE(ct.tier_name, 'No concern'),
            'concern_reason',  ir.concern_reason,
            'concern_description', ct.description,
            'efsa_guidance',   ct.efsa_guidance,
            'score_impact',    ct.score_impact,
            'vegan',           COALESCE(ir.vegan, 'unknown'),
            'vegetarian',      COALESCE(ir.vegetarian, 'unknown'),
            'from_palm_oil',   COALESCE(ir.from_palm_oil, 'unknown')
        ),
        'usage', jsonb_build_object(
            'product_count', COALESCE((
                SELECT COUNT(DISTINCT pi.product_id)
                FROM product_ingredient pi
                WHERE pi.ingredient_id = ir.ingredient_id
            ), 0),
            'category_breakdown', COALESCE((
                SELECT jsonb_agg(cat_row ORDER BY cat_row->>'count' DESC)
                FROM (
                    SELECT jsonb_build_object(
                        'category', p.category,
                        'count',    COUNT(*)::int
                    ) AS cat_row
                    FROM product_ingredient pi
                    JOIN products p ON p.product_id = pi.product_id
                    WHERE pi.ingredient_id = ir.ingredient_id
                    GROUP BY p.category
                    ORDER BY COUNT(*) DESC
                    LIMIT 10
                ) cats
            ), '[]'::jsonb),
            'top_products', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'product_id',    p.product_id,
                    'product_name',  COALESCE(p.product_name_en, p.product_name),
                    'brand',         p.brand,
                    'score',         p.unhealthiness_score,
                    'category',      p.category
                ) ORDER BY p.unhealthiness_score ASC NULLS LAST)
                FROM (
                    SELECT DISTINCT ON (p2.product_id) p2.*
                    FROM product_ingredient pi2
                    JOIN products p2 ON p2.product_id = pi2.product_id
                    WHERE pi2.ingredient_id = ir.ingredient_id
                      AND p2.unhealthiness_score IS NOT NULL
                    ORDER BY p2.product_id, p2.unhealthiness_score ASC
                    LIMIT 10
                ) p
            ), '[]'::jsonb)
        ),
        'related_ingredients', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'ingredient_id', rel.ingredient_id,
                'name_en',       rel.name_en,
                'is_additive',   rel.is_additive,
                'concern_tier',  COALESCE(rel.concern_tier, 0),
                'co_occurrence_count', rel.co_count
            ) ORDER BY rel.co_count DESC)
            FROM (
                SELECT ir2.ingredient_id, ir2.name_en, ir2.is_additive,
                       ir2.concern_tier, COUNT(*) AS co_count
                FROM product_ingredient pi1
                JOIN product_ingredient pi2 ON pi2.product_id = pi1.product_id
                                            AND pi2.ingredient_id <> pi1.ingredient_id
                JOIN ingredient_ref ir2 ON ir2.ingredient_id = pi2.ingredient_id
                WHERE pi1.ingredient_id = ir.ingredient_id
                GROUP BY ir2.ingredient_id, ir2.name_en, ir2.is_additive, ir2.concern_tier
                ORDER BY COUNT(*) DESC
                LIMIT 10
            ) rel
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM ingredient_ref ir
    LEFT JOIN concern_tier_ref ct ON ct.tier = ir.concern_tier
    WHERE ir.ingredient_id = p_ingredient_id;

    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Ingredient not found',
            'ingredient_id', p_ingredient_id
        );
    END IF;

    RETURN v_result;
END;
$func$;

COMMENT ON FUNCTION api_get_ingredient_profile IS
    'Returns a full ingredient profile with concern details, usage stats, co-occurring ingredients.';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Update api_get_product_profile() — add ingredient_id to top_ingredients
-- ═══════════════════════════════════════════════════════════════════════════════
-- We re-create the function to include ingredient_id in each item of the
-- top_ingredients array.  The rest of the function is identical.

CREATE OR REPLACE FUNCTION public.api_get_product_profile(
    p_product_id bigint,
    p_language    text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
    v_language     text;
    v_country_lang text;
    v_result       jsonb;
BEGIN
    v_language := resolve_language(p_language);

    SELECT jsonb_build_object(
        'api_version', '1.0',
        'meta', jsonb_build_object(
            'product_id',   m.product_id,
            'language',     v_language,
            'retrieved_at', now()
        ),
        'product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'product_name_en',    m.product_name_en,
            'product_name_display', CASE
                WHEN v_language = 'en' AND m.product_name_en IS NOT NULL THEN m.product_name_en
                WHEN m.name_translations IS NOT NULL
                     AND m.name_translations ? v_language
                THEN m.name_translations ->> v_language
                ELSE m.product_name
            END,
            'original_language',  COALESCE(cref.default_language, LOWER(m.country)),
            'brand',              m.brand,
            'category',           m.category,
            'category_display',   COALESCE(
                cat.name_translations ->> v_language,
                cat.name_en,
                m.category
            ),
            'category_icon',      COALESCE(cat.icon, '🍽️'),
            'ean',                m.ean,
            'store_availability', m.store_availability,
            'country',            m.country,
            'data_source',        m.data_source
        ),
        'nutrition', jsonb_build_object(
            'per_100g', jsonb_build_object(
                'energy_kcal',     m.energy_kcal,
                'fat_g',           m.fat_g,
                'saturated_fat_g', m.saturated_fat_g,
                'trans_fat_g',     m.trans_fat_g,
                'carbs_g',         m.carbs_g,
                'sugars_g',        m.sugars_g,
                'fiber_g',         m.fiber_g,
                'protein_g',       m.protein_g,
                'salt_g',          m.salt_g
            ),
            'per_serving', NULL::jsonb,
            'daily_values', compute_daily_value_pct(m.product_id, 'eu_ri', NULL)
        ),
        'ingredients', jsonb_build_object(
            'count',              m.ingredient_count,
            'additive_count',     m.additives_count,
            'additive_names',     m.additive_names,
            'has_palm_oil',       COALESCE(m.has_palm_oil, false),
            'vegan_status',       m.vegan_status,
            'vegetarian_status',  m.vegetarian_status,
            'ingredients_text',   m.ingredients_raw,
            'top_ingredients',    COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'ingredient_id',   ir.ingredient_id,
                    'name',            ir.name_en,
                    'position',        pi.position,
                    'concern_tier',    COALESCE(ir.concern_tier, 0),
                    'is_additive',     ir.is_additive,
                    'concern_reason',  ir.concern_reason
                ) ORDER BY pi.position)
                FROM product_ingredient pi
                JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
                WHERE pi.product_id = m.product_id
                  AND pi.position <= 10
            ), '[]'::jsonb)
        ),
        'allergens', jsonb_build_object(
            'contains',         COALESCE(m.allergen_tags, ''),
            'traces',           COALESCE(m.trace_tags, ''),
            'contains_count',   m.allergen_count,
            'traces_count',     m.trace_count
        ),
        'scores', jsonb_build_object(
            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score_label',   m.nutri_score_label,
            'nova_group',          m.nova_group,
            'headline',            CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'Good choice — low health risk.'
                                     WHEN m.unhealthiness_score <= 50 THEN 'Moderate — some concerns to note.'
                                     WHEN m.unhealthiness_score <= 75 THEN 'Elevated risk — review the details below.'
                                     ELSE 'High risk — consider healthier alternatives.'
                                   END,
            'score_explanation',   COALESCE(m.score_explanation, '{}'::jsonb)
        ),
        'warnings', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'type',     w.key,
                'severity', 'warning',
                'message',  w.value
            ))
            FROM jsonb_each_text(
                COALESCE(m.score_explanation->'penalty_reasons', '{}'::jsonb)
            ) w
        ), '[]'::jsonb),
        'quality', jsonb_build_object(
            'completeness',   CASE
                                WHEN m.ingredient_count > 0
                                     AND m.energy_kcal IS NOT NULL
                                THEN 'full'
                                WHEN m.energy_kcal IS NOT NULL THEN 'partial'
                                ELSE 'minimal'
                              END,
            'confidence',     CASE
                                WHEN m.unhealthiness_score IS NOT NULL THEN 'scored'
                                ELSE 'unscored'
                              END,
            'ingredient_coverage', CASE
                                     WHEN m.ingredient_count > 0 THEN true
                                     ELSE false
                                   END,
            'nutrition_coverage',  CASE
                                     WHEN m.energy_kcal IS NOT NULL THEN true
                                     ELSE false
                                   END
        ),
        'alternatives', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',    a.product_id,
                'product_name',  COALESCE(a.product_name_en, a.product_name),
                'brand',         a.brand,
                'category',      a.category,
                'score',         a.unhealthiness_score,
                'score_diff',    m.unhealthiness_score - a.unhealthiness_score
            ) ORDER BY a.unhealthiness_score ASC)
            FROM (
                SELECT p2.*
                FROM products p2
                WHERE p2.category = m.category
                  AND p2.country  = m.country
                  AND p2.product_id <> m.product_id
                  AND p2.unhealthiness_score IS NOT NULL
                  AND p2.unhealthiness_score < m.unhealthiness_score
                ORDER BY p2.unhealthiness_score ASC
                LIMIT 5
            ) a
        ), '[]'::jsonb),
        'flags', jsonb_build_object(
            'high_salt',           COALESCE(m.salt_g > 1.5, false),
            'high_sugar',          COALESCE(m.sugars_g > 22.5, false),
            'high_sat_fat',        COALESCE(m.saturated_fat_g > 5, false),
            'high_additive_load',  COALESCE(m.additives_count >= 5, false),
            'has_palm_oil',        COALESCE(m.has_palm_oil, false)
        ),
        'images', jsonb_build_object(
            'has_image', EXISTS (
                SELECT 1 FROM product_images pimg
                WHERE pimg.product_id = m.product_id
                  AND pimg.status = 'approved'
            ),
            'primary', (
                SELECT jsonb_build_object(
                    'url',       pimg.url,
                    'alt_text',  pimg.alt_text,
                    'source',    pimg.source,
                    'width',     pimg.width,
                    'height',    pimg.height
                )
                FROM product_images pimg
                WHERE pimg.product_id = m.product_id
                  AND pimg.is_primary = true
                  AND pimg.status = 'approved'
                LIMIT 1
            ),
            'additional', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'url',       pimg.url,
                    'alt_text',  pimg.alt_text,
                    'source',    pimg.source,
                    'image_type', pimg.image_type,
                    'width',     pimg.width,
                    'height',    pimg.height
                ) ORDER BY pimg.created_at)
                FROM product_images pimg
                WHERE pimg.product_id = m.product_id
                  AND pimg.is_primary = false
                  AND pimg.status = 'approved'
            ), '[]'::jsonb)
        )
    )
    INTO v_result
    FROM products m
    LEFT JOIN category_ref cat ON cat.slug = m.category
    LEFT JOIN country_ref cref ON cref.country_code = UPPER(m.country)
    WHERE m.product_id = p_product_id;

    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Product not found',
            'product_id',  p_product_id
        );
    END IF;

    -- ── record anonymous view for analytics ─────────────────────────────
    INSERT INTO product_view_log (product_id)
    VALUES (p_product_id)
    ON CONFLICT DO NOTHING;

    RETURN v_result;
END;
$func$;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Grants
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION api_get_ingredient_profile(bigint, text) TO anon, authenticated, service_role;

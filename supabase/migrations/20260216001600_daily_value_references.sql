-- ─── Migration: Daily Value References & % DV Calculation ───────────────────
-- Issue: #37 — Personalized Nutrition % Daily Values on Product Profile
-- Creates daily_value_ref table, seeds EU Reference Intakes, adds
-- compute_daily_value_pct() helper, and extends api_get_product_profile()
-- with a daily_values section in the nutrition envelope.
-- ─────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. daily_value_ref table
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.daily_value_ref (
    nutrient     text          NOT NULL,
    regulation   text          NOT NULL,
    daily_value  numeric(10,2) NOT NULL CHECK (daily_value > 0),
    unit         text          NOT NULL,
    source       text          NOT NULL,
    updated_at   date          NOT NULL,
    PRIMARY KEY (nutrient, regulation)
);

COMMENT ON TABLE  public.daily_value_ref IS
'Reference daily intake values for nutrients by regulation (EU RI, FDA DV, WHO). '
'Used by compute_daily_value_pct() to calculate % Daily Value for product profiles.';
COMMENT ON COLUMN public.daily_value_ref.nutrient IS
'Nutrient key matching nutrition_facts columns: calories, total_fat, saturated_fat, carbs, sugars, fiber, protein, salt, trans_fat.';
COMMENT ON COLUMN public.daily_value_ref.regulation IS
'Regulation source: eu_ri = EU Reference Intakes (1169/2011), fda_dv = US FDA Daily Values.';
COMMENT ON COLUMN public.daily_value_ref.daily_value IS
'Reference daily amount in the specified unit.';

-- ─── Seed EU Reference Intakes (Regulation EU 1169/2011) ────────────────────

INSERT INTO public.daily_value_ref (nutrient, regulation, daily_value, unit, source, updated_at) VALUES
    ('calories',      'eu_ri', 2000,  'kcal', 'Regulation (EU) 1169/2011', '2026-01-01'),
    ('total_fat',     'eu_ri', 70,    'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('saturated_fat', 'eu_ri', 20,    'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('carbs',         'eu_ri', 260,   'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('sugars',        'eu_ri', 90,    'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('fiber',         'eu_ri', 25,    'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('protein',       'eu_ri', 50,    'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('salt',          'eu_ri', 6,     'g',    'Regulation (EU) 1169/2011', '2026-01-01'),
    ('trans_fat',     'eu_ri', 2.2,   'g',    'WHO recommendation',       '2026-01-01')
ON CONFLICT DO NOTHING;

-- ─── Indexes ────────────────────────────────────────────────────────────────

-- Already PK-indexed by (nutrient, regulation). No additional indexes needed.

-- ─── RLS ────────────────────────────────────────────────────────────────────

ALTER TABLE public.daily_value_ref ENABLE ROW LEVEL SECURITY;

-- Public read access (reference data)
CREATE POLICY "daily_value_ref: public read"
    ON public.daily_value_ref FOR SELECT
    USING (true);

-- Service role: full access for maintenance
CREATE POLICY "daily_value_ref: service_role all"
    ON public.daily_value_ref FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ─── Grants ─────────────────────────────────────────────────────────────────

GRANT SELECT ON public.daily_value_ref TO anon, authenticated;
GRANT ALL    ON public.daily_value_ref TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. compute_daily_value_pct() — helper function
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_daily_value_pct(
    p_product_id  bigint,
    p_regulation  text    DEFAULT 'eu_ri',
    p_user_id     uuid    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
    v_per_100g     jsonb;
    v_per_serving  jsonb;
    v_ref_type     text;
    v_regulation   text;
    -- Nutrient raw values (per 100g)
    v_calories     numeric;
    v_total_fat    numeric;
    v_sat_fat      numeric;
    v_carbs        numeric;
    v_sugars       numeric;
    v_fiber        numeric;
    v_protein      numeric;
    v_salt         numeric;
    v_trans_fat    numeric;
    -- Reference values (from daily_value_ref or health profile)
    r_calories     numeric;
    r_total_fat    numeric;
    r_sat_fat      numeric;
    r_carbs        numeric;
    r_sugars       numeric;
    r_fiber        numeric;
    r_protein      numeric;
    r_salt         numeric;
    r_trans_fat    numeric;
    -- Serving
    v_serving_g    numeric;
BEGIN
    v_regulation := p_regulation;

    -- ── Fetch raw nutrition values ──────────────────────────────────────────
    SELECT nf.calories,
           nf.total_fat_g,
           nf.saturated_fat_g,
           nf.carbs_g,
           nf.sugars_g,
           nf.fibre_g,
           nf.protein_g,
           nf.salt_g,
           nf.trans_fat_g
    INTO   v_calories, v_total_fat, v_sat_fat, v_carbs,
           v_sugars, v_fiber, v_protein, v_salt, v_trans_fat
    FROM   nutrition_facts nf
    WHERE  nf.product_id = p_product_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'reference_type', 'none',
            'regulation',     v_regulation,
            'per_100g',       NULL,
            'per_serving',    NULL
        );
    END IF;

    -- ── Load standard reference values ──────────────────────────────────────
    SELECT dv.daily_value INTO r_calories  FROM daily_value_ref dv WHERE dv.nutrient = 'calories'      AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_total_fat FROM daily_value_ref dv WHERE dv.nutrient = 'total_fat'     AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_sat_fat   FROM daily_value_ref dv WHERE dv.nutrient = 'saturated_fat' AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_carbs     FROM daily_value_ref dv WHERE dv.nutrient = 'carbs'         AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_sugars    FROM daily_value_ref dv WHERE dv.nutrient = 'sugars'        AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_fiber     FROM daily_value_ref dv WHERE dv.nutrient = 'fiber'         AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_protein   FROM daily_value_ref dv WHERE dv.nutrient = 'protein'       AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_salt      FROM daily_value_ref dv WHERE dv.nutrient = 'salt'          AND dv.regulation = v_regulation;
    SELECT dv.daily_value INTO r_trans_fat FROM daily_value_ref dv WHERE dv.nutrient = 'trans_fat'     AND dv.regulation = v_regulation;

    v_ref_type := 'standard';

    -- ── Personalization: override with health profile thresholds ─────────────
    IF p_user_id IS NOT NULL THEN
        DECLARE
            hp RECORD;
        BEGIN
            SELECT uhp.max_calories_kcal,
                   uhp.max_sugar_g,
                   uhp.max_salt_g,
                   uhp.max_saturated_fat_g
            INTO hp
            FROM user_health_profiles uhp
            WHERE uhp.user_id = p_user_id
              AND uhp.is_active = true
            LIMIT 1;

            IF FOUND THEN
                IF hp.max_calories_kcal IS NOT NULL THEN r_calories := hp.max_calories_kcal; v_ref_type := 'personalized'; END IF;
                IF hp.max_sugar_g       IS NOT NULL THEN r_sugars   := hp.max_sugar_g;       v_ref_type := 'personalized'; END IF;
                IF hp.max_salt_g        IS NOT NULL THEN r_salt     := hp.max_salt_g;        v_ref_type := 'personalized'; END IF;
                IF hp.max_saturated_fat_g IS NOT NULL THEN r_sat_fat := hp.max_saturated_fat_g; v_ref_type := 'personalized'; END IF;
            END IF;
        END;
    END IF;

    -- ── Build per-100g %DV object ───────────────────────────────────────────
    v_per_100g := jsonb_build_object(
        'calories',      CASE WHEN r_calories  IS NOT NULL AND v_calories  IS NOT NULL THEN jsonb_build_object('value', v_calories,  'daily_value', r_calories,  'pct', ROUND(v_calories  / r_calories  * 100, 1), 'level', CASE WHEN ROUND(v_calories  / r_calories  * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_calories  / r_calories  * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'total_fat',     CASE WHEN r_total_fat IS NOT NULL AND v_total_fat IS NOT NULL THEN jsonb_build_object('value', v_total_fat, 'daily_value', r_total_fat, 'pct', ROUND(v_total_fat / r_total_fat * 100, 1), 'level', CASE WHEN ROUND(v_total_fat / r_total_fat * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_total_fat / r_total_fat * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'saturated_fat', CASE WHEN r_sat_fat   IS NOT NULL AND v_sat_fat   IS NOT NULL THEN jsonb_build_object('value', v_sat_fat,   'daily_value', r_sat_fat,   'pct', ROUND(v_sat_fat   / r_sat_fat   * 100, 1), 'level', CASE WHEN ROUND(v_sat_fat   / r_sat_fat   * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_sat_fat   / r_sat_fat   * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'carbs',         CASE WHEN r_carbs     IS NOT NULL AND v_carbs     IS NOT NULL THEN jsonb_build_object('value', v_carbs,     'daily_value', r_carbs,     'pct', ROUND(v_carbs     / r_carbs     * 100, 1), 'level', CASE WHEN ROUND(v_carbs     / r_carbs     * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_carbs     / r_carbs     * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'sugars',        CASE WHEN r_sugars    IS NOT NULL AND v_sugars    IS NOT NULL THEN jsonb_build_object('value', v_sugars,    'daily_value', r_sugars,    'pct', ROUND(v_sugars    / r_sugars    * 100, 1), 'level', CASE WHEN ROUND(v_sugars    / r_sugars    * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_sugars    / r_sugars    * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'fiber',         CASE WHEN r_fiber     IS NOT NULL AND v_fiber     IS NOT NULL THEN jsonb_build_object('value', v_fiber,     'daily_value', r_fiber,     'pct', ROUND(v_fiber     / r_fiber     * 100, 1), 'level', CASE WHEN ROUND(v_fiber     / r_fiber     * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_fiber     / r_fiber     * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'protein',       CASE WHEN r_protein   IS NOT NULL AND v_protein   IS NOT NULL THEN jsonb_build_object('value', v_protein,   'daily_value', r_protein,   'pct', ROUND(v_protein   / r_protein   * 100, 1), 'level', CASE WHEN ROUND(v_protein   / r_protein   * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_protein   / r_protein   * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'salt',          CASE WHEN r_salt      IS NOT NULL AND v_salt      IS NOT NULL THEN jsonb_build_object('value', v_salt,      'daily_value', r_salt,      'pct', ROUND(v_salt      / r_salt      * 100, 1), 'level', CASE WHEN ROUND(v_salt      / r_salt      * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_salt      / r_salt      * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END,
        'trans_fat',     CASE WHEN r_trans_fat IS NOT NULL AND v_trans_fat IS NOT NULL THEN jsonb_build_object('value', v_trans_fat, 'daily_value', r_trans_fat, 'pct', ROUND(v_trans_fat / r_trans_fat * 100, 1), 'level', CASE WHEN ROUND(v_trans_fat / r_trans_fat * 100, 1) <= 5 THEN 'low' WHEN ROUND(v_trans_fat / r_trans_fat * 100, 1) <= 20 THEN 'moderate' ELSE 'high' END) END
    );

    -- ── Build per-serving %DV (if serving data exists) ──────────────────────
    -- For now per_serving is NULL; can be extended when serving data is available
    v_per_serving := NULL;

    RETURN jsonb_build_object(
        'reference_type', v_ref_type,
        'regulation',     v_regulation,
        'per_100g',       v_per_100g,
        'per_serving',    v_per_serving
    );
END;
$func$;

COMMENT ON FUNCTION public.compute_daily_value_pct(bigint, text, uuid) IS
'Computes % Daily Value for a product''s nutrition values. Uses EU Reference Intakes '
'by default. If p_user_id is provided and has an active health profile with thresholds, '
'those override the standard reference values for matching nutrients. Returns per_100g '
'(and per_serving when available) with value, daily_value, pct, and traffic-light level.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Extend api_get_product_profile() — add daily_values to nutrition section
-- ═══════════════════════════════════════════════════════════════════════════════

-- We use CREATE OR REPLACE to add the daily_values key to the nutrition envelope.
-- The full function is re-stated to include the new key.

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
            'category_display',   COALESCE(ct.display_name, cr.display_name),
            'category_icon',      COALESCE(cr.icon_emoji, '📦'),
            'product_type',       m.product_type,
            'country',            m.country,
            'ean',                m.ean,
            'prep_method',        m.prep_method,
            'store_availability', m.store_availability,
            'controversies',      m.controversies
        ),
        'nutrition', jsonb_build_object(
            'per_100g', jsonb_build_object(
                'calories_kcal',   m.calories,
                'total_fat_g',     m.total_fat_g,
                'saturated_fat_g', m.saturated_fat_g,
                'trans_fat_g',     m.trans_fat_g,
                'carbs_g',         m.carbs_g,
                'sugars_g',        m.sugars_g,
                'fibre_g',         m.fibre_g,
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
                    'name',            ir.name_en,
                    'position',        pi.position,
                    'concern_tier',    COALESCE(ir.concern_tier, 0),
                    'is_additive',     ir.is_additive
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
            'nutri_score_color',   COALESCE(ns.color_hex, '#999999'),
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,
            'score_breakdown',     COALESCE(m.score_breakdown->'factors', '[]'::jsonb),
            'headline',            CASE
                                     WHEN m.unhealthiness_score <= 15 THEN
                                         'This product scores very well. It has low levels of nutrients of concern.'
                                     WHEN m.unhealthiness_score <= 30 THEN
                                         'This product has a moderate profile. Some areas could be better.'
                                     WHEN m.unhealthiness_score <= 50 THEN
                                         'This product has several areas of nutritional concern.'
                                     ELSE
                                         'This product has significant nutritional concerns across multiple factors.'
                                   END,
            'category_context', (
                SELECT jsonb_build_object(
                    'rank',               (
                        SELECT COUNT(*) + 1
                        FROM v_master m2
                        WHERE m2.category = m.category
                          AND m2.country = m.country
                          AND m2.unhealthiness_score < m.unhealthiness_score
                    ),
                    'total_in_category',  COUNT(*)::int,
                    'category_avg_score', ROUND(AVG(p2.unhealthiness_score), 1),
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
        ),
        'warnings', COALESCE((
            SELECT jsonb_agg(w) FROM (
                SELECT jsonb_build_object('type', 'high_salt',    'severity', 'warning', 'message', 'High salt content')    AS w WHERE m.high_salt_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sugar',   'severity', 'warning', 'message', 'High sugar content')   WHERE m.high_sugar_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'high_sat_fat', 'severity', 'warning', 'message', 'High saturated fat content') WHERE m.high_sat_fat_flag = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'additives',    'severity', 'info',    'message', 'Contains many additives')    WHERE m.high_additive_load = 'YES'
                UNION ALL
                SELECT jsonb_build_object('type', 'palm_oil',     'severity', 'info',    'message', 'Contains palm oil')     WHERE COALESCE(m.has_palm_oil, false) = true
                UNION ALL
                SELECT jsonb_build_object('type', 'nova_4',       'severity', 'info',    'message', 'Ultra-processed food (NOVA 4)')       WHERE m.nova_classification = '4'
            ) warnings
        ), '[]'::jsonb),
        'quality', compute_data_confidence(m.product_id),
        'alternatives', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_delta',        alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity
            ))
            FROM find_better_alternatives(p_product_id, true, 3) alt
        ), '[]'::jsonb),
        'flags', jsonb_build_object(
            'high_salt',          (m.high_salt_flag = 'YES'),
            'high_sugar',         (m.high_sugar_flag = 'YES'),
            'high_sat_fat',       (m.high_sat_fat_flag = 'YES'),
            'high_additive_load', (m.high_additive_load = 'YES'),
            'has_palm_oil',       COALESCE(m.has_palm_oil, false)
        ),
        'images', jsonb_build_object(
            'has_image', EXISTS (
                SELECT 1 FROM product_images pi2
                WHERE pi2.product_id = m.product_id
            ),
            'primary', (
                SELECT jsonb_build_object(
                    'image_id',   pi3.image_id,
                    'url',        pi3.url,
                    'image_type', pi3.image_type,
                    'source',     pi3.source,
                    'width',      pi3.width,
                    'height',     pi3.height,
                    'alt_text',   pi3.alt_text
                )
                FROM product_images pi3
                WHERE pi3.product_id = m.product_id
                  AND pi3.is_primary = true
                LIMIT 1
            ),
            'additional', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'image_id',   pi4.image_id,
                    'url',        pi4.url,
                    'image_type', pi4.image_type,
                    'source',     pi4.source,
                    'width',      pi4.width,
                    'height',     pi4.height,
                    'alt_text',   pi4.alt_text
                ) ORDER BY pi4.image_id)
                FROM product_images pi4
                WHERE pi4.product_id = m.product_id
                  AND pi4.is_primary = false
            ), '[]'::jsonb)
        )
    )
    INTO v_result
    FROM v_master m
    LEFT JOIN category_ref cr ON cr.category = m.category
    LEFT JOIN category_translations ct
        ON ct.category = m.category AND ct.language_code = v_language
    LEFT JOIN nutri_score_ref ns ON ns.label = m.nutri_score_label
    LEFT JOIN country_ref cref ON cref.country_code = m.country
    WHERE m.product_id = p_product_id;

    RETURN v_result;
END;
$func$;

COMMENT ON FUNCTION public.api_get_product_profile(bigint, text) IS
'Canonical product profile endpoint — bundles product data, nutrition (with '
'% Daily Values), ingredients, allergens, scores with breakdown + category '
'context, warnings, quality/confidence, alternatives, flags, and images in '
'a single JSONB envelope.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Grants for compute_daily_value_pct
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION public.compute_daily_value_pct(bigint, text, uuid)
    TO anon, authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.compute_daily_value_pct(bigint, text, uuid)
    FROM PUBLIC;

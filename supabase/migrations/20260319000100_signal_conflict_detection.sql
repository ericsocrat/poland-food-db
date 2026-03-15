-- Migration: Add signal-conflict detection to api_score_explanation()
-- Issue: #885 — fix(scoring): add signal-conflict detection to api_score_explanation()
-- Depends on: 20260315002200_score_explanation_v33_api.sql
-- Rollback: Re-deploy the previous api_score_explanation function body from 20260315002200
-- Idempotency: CREATE OR REPLACE — safe to run 1× or 100×

-- Changes (additive, backward compatible):
-- 1. Adds 'conflicts' array to 'summary' — detects when headline sentiment
--    contradicts co-displayed Nutri-Score, NOVA, high_* flags, or ingredient concerns.
-- 2. Adds 'qualified_headline' to 'summary' — equals headline when clean,
--    appends highest-severity conflict note when contradictions exist.
-- 3. Implements 6 messaging rules (M1–M6) per issue #885 spec.
-- 4. All existing response keys preserved unchanged.
-- 5. Uses LATERAL subquery (not CTE) for conflict detection to preserve
--    predicate pushdown into v_master — avoids full-view materialization.

CREATE OR REPLACE FUNCTION public.api_score_explanation(p_product_id bigint)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
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
                             WHEN m.unhealthiness_score <= 20 THEN 'low'
                             WHEN m.unhealthiness_score <= 40 THEN 'moderate'
                             WHEN m.unhealthiness_score <= 60 THEN 'elevated'
                             WHEN m.unhealthiness_score <= 80 THEN 'high'
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
            'qualified_headline',
                           CASE
                             WHEN m.unhealthiness_score <= 15 THEN
                                 'This product scores very well. It has low levels of nutrients of concern.'
                             WHEN m.unhealthiness_score <= 30 THEN
                                 'This product has a moderate profile. Some areas could be better.'
                             WHEN m.unhealthiness_score <= 50 THEN
                                 'This product has several areas of nutritional concern.'
                             ELSE
                                 'This product has significant nutritional concerns across multiple factors.'
                           END
                           || CASE WHEN cd.conflicts != '[]'::jsonb
                                   THEN ' ' || (cd.conflicts->0->>'message')
                                   ELSE ''
                              END,
            'conflicts',   cd.conflicts,
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
        'nutrient_bonus', (
            SELECT jsonb_build_object(
                'factor', nd->>'name',
                'raw',    (nd->>'raw')::numeric,
                'weighted', (nd->>'weighted')::numeric,
                'components', nd->'components'
            )
            FROM jsonb_array_elements(m.score_breakdown->'factors') AS nd
            WHERE nd->>'name' = 'nutrient_density'
              AND (nd->>'weighted')::numeric < 0
            LIMIT 1
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
                UNION ALL
                SELECT jsonb_build_object('type', 'good_protein', 'message', 'Good source of protein.')
                  WHERE COALESCE(nf.protein_g, 0) >= 10
                UNION ALL
                SELECT jsonb_build_object('type', 'good_fibre',   'message', 'Good source of fibre.')
                  WHERE COALESCE(nf.fibre_g, 0) >= 3
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
    LEFT JOIN nutrition_facts nf ON nf.product_id = m.product_id
    CROSS JOIN LATERAL (
        SELECT COALESCE(jsonb_agg(c ORDER BY
            CASE c->>'severity'
                WHEN 'high'   THEN 1
                WHEN 'medium' THEN 2
                WHEN 'info'   THEN 3
            END,
            c->>'rule'
        ), '[]'::jsonb) AS conflicts
        FROM (
            -- M1: Good headline (score ≤ 30) contradicts NOVA 4 (ultra-processed)
            SELECT jsonb_build_object(
                'rule', 'M1', 'key', 'nova_ultra_processed',
                'severity', 'high',
                'message', 'Note: this product is classified as ultra-processed (NOVA 4).'
            ) AS c
            WHERE m.unhealthiness_score <= 30
              AND m.nova_classification = '4'
            UNION ALL
            -- M2: Good headline (score ≤ 30) contradicts Nutri-Score D or E
            SELECT jsonb_build_object(
                'rule', 'M2', 'key', 'nutri_score_poor',
                'severity', 'high',
                'message', 'Note: Nutri-Score rates this product ' || m.nutri_score_label || '.'
            )
            WHERE m.unhealthiness_score <= 30
              AND m.nutri_score_label IN ('D', 'E')
            UNION ALL
            -- M3a: Excellent headline (score ≤ 15) contradicts high salt flag
            SELECT jsonb_build_object(
                'rule', 'M3', 'key', 'high_salt_flag',
                'severity', 'medium',
                'message', 'Note: high salt content flagged.'
            )
            WHERE m.unhealthiness_score <= 15
              AND m.high_salt_flag = 'YES'
            UNION ALL
            -- M3b: Excellent headline (score ≤ 15) contradicts high sugar flag
            SELECT jsonb_build_object(
                'rule', 'M3', 'key', 'high_sugar_flag',
                'severity', 'medium',
                'message', 'Note: high sugar content flagged.'
            )
            WHERE m.unhealthiness_score <= 15
              AND m.high_sugar_flag = 'YES'
            UNION ALL
            -- M3c: Excellent headline (score ≤ 15) contradicts high saturated fat flag
            SELECT jsonb_build_object(
                'rule', 'M3', 'key', 'high_sat_fat_flag',
                'severity', 'medium',
                'message', 'Note: high saturated fat content flagged.'
            )
            WHERE m.unhealthiness_score <= 15
              AND m.high_sat_fat_flag = 'YES'
            UNION ALL
            -- M4: Bad headline (score > 30) but Nutri-Score A or B
            SELECT jsonb_build_object(
                'rule', 'M4', 'key', 'nutri_score_favorable',
                'severity', 'info',
                'message', 'Note: Nutri-Score rates this product favorably (' || m.nutri_score_label || ').'
            )
            WHERE m.unhealthiness_score > 30
              AND m.nutri_score_label IN ('A', 'B')
            UNION ALL
            -- M5: Bad headline (score > 30) but NOVA 1 or 2 (minimally processed)
            SELECT jsonb_build_object(
                'rule', 'M5', 'key', 'nova_minimal_processing',
                'severity', 'info',
                'message', 'Note: NOVA classifies this as minimally processed.'
            )
            WHERE m.unhealthiness_score > 30
              AND m.nova_classification IN ('1', '2')
            UNION ALL
            -- M6: Low/moderate band (score ≤ 40) but ingredient concern > 50
            SELECT jsonb_build_object(
                'rule', 'M6', 'key', 'high_ingredient_concern',
                'severity', 'medium',
                'message', 'Note: contains ingredients with elevated concern levels.'
            )
            WHERE m.unhealthiness_score <= 40
              AND COALESCE(m.ingredient_concern_score, 0) > 50
        ) rules
    ) cd
    WHERE m.product_id = p_product_id;
$function$;

COMMENT ON FUNCTION public.api_score_explanation IS
  'Purpose: Score breakdown + human-readable headline + warnings + signal-conflict detection + category context
   Auth: none (public/anon)
   Params: p_product_id (required bigint)
   Returns: JSONB {api_version, product_id, product_name, brand, category,
     score_breakdown, model_version, scored_at,
     summary: {score, score_band, headline, qualified_headline, conflicts, nutri_score, ...},
     top_factors, nutrient_bonus, warnings, category_context}
   Conflicts: Array of {rule, key, severity, message} per M1-M6 messaging rules.
     Empty array when no contradictions detected.
   Qualified headline: headline + highest-severity conflict note (or plain headline if clean).
   Backward compatible: headline field unchanged. Issues #611, #885.';

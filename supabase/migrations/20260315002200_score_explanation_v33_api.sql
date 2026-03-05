-- Migration: Update api_score_explanation to surface v3.3 nutrient density bonus
-- Issue: #611 — feat(scoring): update score explanation API and UI for v3.3
-- Depends on: 20260315002100_rescore_v33_nutrient_density.sql (explain_score_v33 exists)
-- Rollback: Re-deploy the previous api_score_explanation function body
-- Idempotency: CREATE OR REPLACE — safe to run 1× or 100×

-- Changes:
-- 1. Adds 'nutrient_bonus' key: extracts nutrient_density factor from score_breakdown
--    Returns { factor, raw, weighted, components: { protein_bonus, fibre_bonus } }
-- 2. Adds positive indicators to 'warnings' for high-protein and good-fibre products
-- 3. 'top_factors' unchanged (still penalty-only, WHERE weighted > 0) — backward compatible
-- 4. Updates score_band thresholds to match v3.3 (20/40/60/80)

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
    WHERE m.product_id = p_product_id;
$function$;

COMMENT ON FUNCTION public.api_score_explanation IS
  'Purpose: Score explanation for a single product — v3.3 with nutrient density bonus
   Auth: anon + authenticated (no RLS dependency, reads views)
   Params: p_product_id (required — bigint)
   Returns: JSONB {api_version, product_id, product_name, brand, category,
            score_breakdown, model_version, scored_at, summary, top_factors,
            nutrient_bonus, warnings, category_context}
   v3.3 changes: Added nutrient_bonus field (protein/fibre bonus extracted from
            score_breakdown), positive indicators (good_protein, good_fibre) in warnings,
            score_band thresholds updated to 20/40/60/80.
   Backward compatible: top_factors unchanged (penalty-only), new fields are additive.';

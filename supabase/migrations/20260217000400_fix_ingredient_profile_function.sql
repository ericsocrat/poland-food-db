-- ─── Fix: api_get_ingredient_profile — remove dropped column references ─────
-- The ingredient_ref table had taxonomy_id, is_in_taxonomy, created_at
-- columns dropped in migration 20260211000400_cleanup_ingredient_ref.sql.
-- But api_get_ingredient_profile (created in 20260217000100) still references
-- ir.taxonomy_id, causing PostgreSQL error 42703.
-- This migration re-creates the function without the dropped column.
-- ─────────────────────────────────────────────────────────────────────────────

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
            'name_en',         ir.name_en,
            'name_display',    ir.name_en,
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

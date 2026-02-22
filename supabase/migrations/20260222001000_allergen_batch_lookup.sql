-- ============================================================
-- Migration: Batch allergen lookup for product list views
-- Supports Issue #128 — Allergen Warning Chips on search/category/dashboard cards
-- ============================================================

-- ─── api_get_product_allergens ───────────────────────────────────────────────
-- Batch-fetch allergen data for a set of product IDs.
-- Returns a JSONB object keyed by product_id (as text), each value containing
-- { "contains": ["en:milk", ...], "traces": ["en:gluten", ...] }
-- Products with no allergen data are omitted from the result.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_get_product_allergens(
    p_product_ids bigint[]
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(
            jsonb_object_agg(
                sub.product_id::text,
                jsonb_build_object(
                    'contains', COALESCE(sub.contains_tags, ARRAY[]::text[]),
                    'traces',   COALESCE(sub.traces_tags,   ARRAY[]::text[])
                )
            ),
            '{}'::jsonb
        )
        FROM (
            SELECT
                ai.product_id,
                array_agg(ai.tag ORDER BY ai.tag)
                    FILTER (WHERE ai.type = 'contains') AS contains_tags,
                array_agg(ai.tag ORDER BY ai.tag)
                    FILTER (WHERE ai.type = 'traces')   AS traces_tags
            FROM product_allergen_info ai
            WHERE ai.product_id = ANY(p_product_ids)
            GROUP BY ai.product_id
        ) sub
    );
END;
$$;

-- Permissions
GRANT EXECUTE ON FUNCTION public.api_get_product_allergens(bigint[]) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.api_get_product_allergens IS
    'Batch-fetch allergen contains/traces tags for a list of product IDs. '
    'Used by frontend to render allergen warning chips on product cards.';

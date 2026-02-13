-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: api_category_overview() RPC
--
-- Exposes v_api_category_overview_by_country via a proper SECURITY DEFINER RPC.
-- Frontend should call this instead of querying the view directly.
-- Follows the same pattern as all other API surfaces:
--   - p_country NULL → resolve_effective_country()
--   - SECURITY DEFINER + search_path = public
--   - anon revoked, authenticated + service_role granted
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

CREATE OR REPLACE FUNCTION public.api_category_overview(
    p_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_country text;
    v_rows    jsonb;
BEGIN
    -- Resolve effective country (same as all other API surfaces)
    v_country := resolve_effective_country(p_country);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'country_code',         ov.country_code,
            'category',             ov.category,
            'display_name',         ov.display_name,
            'category_description', ov.category_description,
            'icon_emoji',           ov.icon_emoji,
            'sort_order',           ov.sort_order,
            'product_count',        ov.product_count,
            'avg_score',            ov.avg_score,
            'min_score',            ov.min_score,
            'max_score',            ov.max_score,
            'median_score',         ov.median_score,
            'pct_nutri_a_b',        ov.pct_nutri_a_b,
            'pct_nova_4',           ov.pct_nova_4
        ) AS row_data,
        ov.sort_order
        FROM v_api_category_overview_by_country ov
        WHERE ov.country_code = v_country
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'country',     v_country,
        'categories',  v_rows
    );
END;
$function$;

COMMENT ON FUNCTION public.api_category_overview(text) IS
'Returns category overview stats for a single country. '
'If p_country is NULL, resolves from user_preferences → first active country. '
'Reads from v_api_category_overview_by_country (service_role-only view).';

-- RPC-only model: authenticated + service_role can call, anon cannot
REVOKE EXECUTE ON FUNCTION public.api_category_overview(text) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.api_category_overview(text) TO authenticated, service_role;

COMMIT;

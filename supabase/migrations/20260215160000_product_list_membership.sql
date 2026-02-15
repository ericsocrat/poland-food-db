-- ─── Product list membership lookup ─────────────────────────────────────────
-- Lightweight function that returns which of the caller's lists contain a
-- specific product. Used by the AddToListMenu dropdown for toggle state.

CREATE OR REPLACE FUNCTION public.api_get_product_list_membership(
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id  uuid := auth.uid();
    v_list_ids jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT coalesce(jsonb_agg(li.list_id), '[]'::jsonb)
    INTO v_list_ids
    FROM public.user_product_list_items li
    JOIN public.user_product_lists l ON l.id = li.list_id
    WHERE l.user_id = v_user_id
      AND li.product_id = p_product_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'product_id',  p_product_id,
        'list_ids',    v_list_ids
    );
END;
$$;

-- Grants
GRANT EXECUTE ON FUNCTION public.api_get_product_list_membership(bigint) TO authenticated;

-- Also add api_get_favorite_product_ids for the favorites heart badge
CREATE OR REPLACE FUNCTION public.api_get_favorite_product_ids()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id     uuid := auth.uid();
    v_product_ids jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT coalesce(jsonb_agg(li.product_id ORDER BY li.position), '[]'::jsonb)
    INTO v_product_ids
    FROM public.user_product_list_items li
    JOIN public.user_product_lists l ON l.id = li.list_id
    WHERE l.user_id = v_user_id
      AND l.list_type = 'favorites';

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'product_ids', v_product_ids
    );
END;
$$;

-- Grants
GRANT EXECUTE ON FUNCTION public.api_get_favorite_product_ids() TO authenticated;

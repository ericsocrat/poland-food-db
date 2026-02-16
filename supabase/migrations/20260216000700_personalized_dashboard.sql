-- ─── Personalized Dashboard (#24) ───────────────────────────────────────────
-- Creates user_product_views table and dashboard API functions.
-- Depends on: products, user_product_lists, user_product_list_items, scan_history

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. user_product_views table
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_product_views (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES public.products(product_id) ON DELETE CASCADE,
    viewed_at   timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id, product_id)
);

ALTER TABLE public.user_product_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own views"
    ON public.user_product_views FOR ALL
    USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_upv_user_recent
    ON public.user_product_views(user_id, viewed_at DESC);

CREATE INDEX IF NOT EXISTS idx_upv_product
    ON public.user_product_views(product_id);


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_record_product_view  (fire-and-forget upsert)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_record_product_view(
    p_product_id  bigint
)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    IF p_product_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Product ID required');
    END IF;

    -- Upsert: if exists for same user+product, just update viewed_at
    INSERT INTO public.user_product_views (user_id, product_id, viewed_at)
    VALUES (v_user_id, p_product_id, now())
    ON CONFLICT (user_id, product_id)
    DO UPDATE SET viewed_at = now();

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'recorded', true
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_record_product_view(bigint) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_record_product_view(bigint) FROM anon, public;


-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_recently_viewed  (standalone, paginated)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_recently_viewed(
    p_limit  integer DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id  uuid := auth.uid();
    v_limit    integer := LEAST(GREATEST(p_limit, 1), 50);
    v_products jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_products
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            upv.viewed_at
        FROM public.user_product_views upv
        JOIN public.products p ON p.product_id = upv.product_id
        WHERE upv.user_id = v_user_id
          AND p.is_deprecated IS NOT TRUE
        ORDER BY upv.viewed_at DESC
        LIMIT v_limit
    ) t;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'products', v_products
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_get_recently_viewed(integer) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_get_recently_viewed(integer) FROM anon, public;


-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_get_dashboard_data  (batched: all sections in one call)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_dashboard_data()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id          uuid := auth.uid();
    v_recently_viewed  jsonb;
    v_favorites        jsonb;
    v_new_products     jsonb;
    v_stats            jsonb;
    v_top_category     text;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- ─── Recently Viewed (last 8) ───────────────────────────────────────
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_recently_viewed
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            upv.viewed_at
        FROM public.user_product_views upv
        JOIN public.products p ON p.product_id = upv.product_id
        WHERE upv.user_id = v_user_id
          AND p.is_deprecated IS NOT TRUE
        ORDER BY upv.viewed_at DESC
        LIMIT 8
    ) t;

    -- ─── Favorites Preview (first 6) ───────────────────────────────────
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_favorites
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label,
            li.added_at
        FROM public.user_product_list_items li
        JOIN public.user_product_lists l ON l.id = li.list_id
        JOIN public.products p ON p.product_id = li.product_id
        WHERE l.user_id = v_user_id
          AND l.list_type = 'favorites'
          AND p.is_deprecated IS NOT TRUE
        ORDER BY li.position, li.added_at DESC
        LIMIT 6
    ) t;

    -- ─── New Products (last 14 days, user's most-viewed categories) ─────
    SELECT p.category
    INTO v_top_category
    FROM public.user_product_views upv
    JOIN public.products p ON p.product_id = upv.product_id
    WHERE upv.user_id = v_user_id
      AND p.is_deprecated IS NOT TRUE
    GROUP BY p.category
    ORDER BY count(*) DESC
    LIMIT 1;

    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
    INTO v_new_products
    FROM (
        SELECT
            p.product_id,
            p.product_name,
            p.brand,
            p.category,
            p.country,
            p.unhealthiness_score,
            p.nutri_score_label
        FROM public.products p
        WHERE p.is_deprecated IS NOT TRUE
          AND p.created_at >= now() - interval '14 days'
          AND (v_top_category IS NULL OR p.category = v_top_category)
        ORDER BY p.created_at DESC
        LIMIT 6
    ) t;

    -- ─── User Stats ─────────────────────────────────────────────────────
    SELECT jsonb_build_object(
        'total_scanned',
        (SELECT count(*) FROM public.scan_history WHERE user_id = v_user_id),
        'total_viewed',
        (SELECT count(*) FROM public.user_product_views WHERE user_id = v_user_id),
        'lists_count',
        (SELECT count(*) FROM public.user_product_lists WHERE user_id = v_user_id),
        'favorites_count',
        (SELECT count(*)
         FROM public.user_product_list_items li
         JOIN public.user_product_lists l ON l.id = li.list_id
         WHERE l.user_id = v_user_id AND l.list_type = 'favorites'),
        'most_viewed_category',
        v_top_category
    )
    INTO v_stats;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'recently_viewed', v_recently_viewed,
        'favorites_preview', v_favorites,
        'new_products', v_new_products,
        'stats', v_stats
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_get_dashboard_data() TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_get_dashboard_data() FROM anon, public;

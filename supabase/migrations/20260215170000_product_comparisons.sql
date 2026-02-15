-- ============================================================================
-- Migration: Product Comparisons
-- Issue: #21 — Product Comparison View
-- Purpose: user_comparisons table + shareable comparison URLs +
--          api_get_products_for_compare, api_save_comparison,
--          api_get_saved_comparisons, api_get_shared_comparison
-- ============================================================================
BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Table: user_comparisons
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_comparisons (
    id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_ids  bigint[]    NOT NULL CHECK (array_length(product_ids, 1) BETWEEN 2 AND 4),
    title        text,
    share_token  text        UNIQUE,
    created_at   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.user_comparisons ENABLE ROW LEVEL SECURITY;

-- Owner can CRUD their own comparisons
CREATE POLICY "Users manage own comparisons"
    ON public.user_comparisons FOR ALL
    USING (auth.uid() = user_id);

-- Public read via share token (no auth needed)
CREATE POLICY "Public read via share token"
    ON public.user_comparisons FOR SELECT
    USING (share_token IS NOT NULL);

CREATE INDEX idx_uc_user_id ON public.user_comparisons(user_id);
CREATE INDEX idx_uc_share_token ON public.user_comparisons(share_token)
    WHERE share_token IS NOT NULL;

-- Limit saved comparisons per user (max 50)
CREATE OR REPLACE FUNCTION public.trg_limit_comparisons()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM public.user_comparisons
    WHERE user_id = NEW.user_id;

    IF v_count >= 50 THEN
        RAISE EXCEPTION 'Maximum 50 saved comparisons per user'
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_limit_user_comparisons
    BEFORE INSERT ON public.user_comparisons
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_limit_comparisons();


-- ────────────────────────────────────────────────────────────────────────────
-- 2. api_get_products_for_compare(p_product_ids bigint[])
--    Returns full comparison data for 2-4 products in a single query.
--    Works without auth — no user data exposed.
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.api_get_products_for_compare(
    p_product_ids bigint[]
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count integer;
    v_products jsonb;
BEGIN
    -- Validate array length
    v_count := array_length(p_product_ids, 1);
    IF v_count IS NULL OR v_count < 2 OR v_count > 4 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Please provide between 2 and 4 product IDs'
        );
    END IF;

    SELECT jsonb_agg(
        jsonb_build_object(
            'product_id',          m.product_id,
            'ean',                 m.ean,
            'product_name',        m.product_name,
            'brand',               m.brand,
            'category',            m.category,
            'category_display',    COALESCE(cr.display_name, m.category),
            'category_icon',       COALESCE(cr.icon_emoji, '📦'),

            'unhealthiness_score', m.unhealthiness_score,
            'score_band',          CASE
                                     WHEN m.unhealthiness_score <= 25 THEN 'low'
                                     WHEN m.unhealthiness_score <= 50 THEN 'moderate'
                                     WHEN m.unhealthiness_score <= 75 THEN 'high'
                                     ELSE 'very_high'
                                   END,
            'nutri_score',         m.nutri_score_label,
            'nova_group',          m.nova_classification,
            'processing_risk',     m.processing_risk,

            'calories',            m.calories,
            'total_fat_g',         m.total_fat_g,
            'saturated_fat_g',     m.saturated_fat_g,
            'trans_fat_g',         m.trans_fat_g,
            'carbs_g',             m.carbs_g,
            'sugars_g',            m.sugars_g,
            'fibre_g',             m.fibre_g,
            'protein_g',           m.protein_g,
            'salt_g',              m.salt_g,

            'high_salt',           (m.high_salt_flag = 'YES'),
            'high_sugar',          (m.high_sugar_flag = 'YES'),
            'high_sat_fat',        (m.high_sat_fat_flag = 'YES'),
            'high_additive_load',  (m.high_additive_load = 'YES'),

            'additives_count',     COALESCE(m.additives_count, 0),
            'ingredient_count',    COALESCE(m.ingredient_count, 0),

            'allergen_count',      m.allergen_count,
            'allergen_tags',       m.allergen_tags,
            'trace_tags',          m.trace_tags,

            'confidence',          m.confidence,
            'data_completeness_pct', m.data_completeness_pct
        )
        ORDER BY array_position(p_product_ids, m.product_id)
    )
    INTO v_products
    FROM public.v_master m
    LEFT JOIN public.category_ref cr ON cr.category = m.category
    WHERE m.product_id = ANY(p_product_ids);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'product_count', COALESCE(jsonb_array_length(v_products), 0),
        'products', COALESCE(v_products, '[]'::jsonb)
    );
END;
$$;

COMMENT ON FUNCTION public.api_get_products_for_compare(bigint[]) IS
    'Returns comparison data for 2-4 products in a single batch query. '
    'Includes nutrition, scores, flags, allergens, and additives. '
    'No user_id exposed — safe for unauthenticated/shared access.';

-- Grant to both authenticated and anonymous for shared URL support
GRANT EXECUTE ON FUNCTION public.api_get_products_for_compare(bigint[])
    TO authenticated, anon;


-- ────────────────────────────────────────────────────────────────────────────
-- 3. api_save_comparison(p_product_ids, p_title)
--    Saves a comparison for the authenticated user, generates share token.
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.api_save_comparison(
    p_product_ids bigint[],
    p_title       text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id     uuid := auth.uid();
    v_count       integer;
    v_id          uuid;
    v_share_token text;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    -- Validate array length
    v_count := array_length(p_product_ids, 1);
    IF v_count IS NULL OR v_count < 2 OR v_count > 4 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Please provide between 2 and 4 product IDs'
        );
    END IF;

    -- Generate a URL-safe share token
    v_share_token := encode(gen_random_bytes(12), 'hex');

    INSERT INTO public.user_comparisons (user_id, product_ids, title, share_token)
    VALUES (v_user_id, p_product_ids, p_title, v_share_token)
    RETURNING id INTO v_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'comparison_id', v_id,
        'share_token', v_share_token,
        'product_ids', p_product_ids,
        'title', p_title
    );
END;
$$;

COMMENT ON FUNCTION public.api_save_comparison(bigint[], text) IS
    'Saves a product comparison for the authenticated user. '
    'Generates a unique share_token for shareable URLs. '
    'Max 50 comparisons per user enforced by trigger.';

GRANT EXECUTE ON FUNCTION public.api_save_comparison(bigint[], text)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_save_comparison(bigint[], text)
    FROM anon, public;


-- ────────────────────────────────────────────────────────────────────────────
-- 4. api_get_saved_comparisons(p_limit, p_offset)
--    Returns the user's saved comparisons with product name previews.
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.api_get_saved_comparisons(
    p_limit  integer DEFAULT 10,
    p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_total   integer;
    v_items   jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    -- Count total
    SELECT COUNT(*) INTO v_total
    FROM public.user_comparisons
    WHERE user_id = v_user_id;

    -- Fetch comparisons with product name previews
    SELECT COALESCE(jsonb_agg(row_obj ORDER BY created_at DESC), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'comparison_id', uc.id,
            'title',         uc.title,
            'product_ids',   uc.product_ids,
            'share_token',   uc.share_token,
            'created_at',    uc.created_at,
            'product_names', (
                SELECT jsonb_agg(p.product_name ORDER BY array_position(uc.product_ids, p.product_id))
                FROM public.products p
                WHERE p.product_id = ANY(uc.product_ids)
            )
        ) AS row_obj,
        uc.created_at
        FROM public.user_comparisons uc
        WHERE uc.user_id = v_user_id
        ORDER BY uc.created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN jsonb_build_object(
        'api_version',  '1.0',
        'total_count',  v_total,
        'limit',        p_limit,
        'offset',       p_offset,
        'comparisons',  v_items
    );
END;
$$;

COMMENT ON FUNCTION public.api_get_saved_comparisons(integer, integer) IS
    'Returns the authenticated user''s saved comparisons, paginated. '
    'Includes product name previews for list display.';

GRANT EXECUTE ON FUNCTION public.api_get_saved_comparisons(integer, integer)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_get_saved_comparisons(integer, integer)
    FROM anon, public;


-- ────────────────────────────────────────────────────────────────────────────
-- 5. api_get_shared_comparison(p_share_token)
--    Public function to load a shared comparison by token.
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.api_get_shared_comparison(
    p_share_token text
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_comparison record;
    v_products   jsonb;
BEGIN
    SELECT id, product_ids, title, created_at
    INTO v_comparison
    FROM public.user_comparisons
    WHERE share_token = p_share_token;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Comparison not found or link has expired'
        );
    END IF;

    -- Reuse the compare function for product data
    SELECT (api_get_products_for_compare(v_comparison.product_ids))->'products'
    INTO v_products;

    RETURN jsonb_build_object(
        'api_version',    '1.0',
        'comparison_id',  v_comparison.id,
        'title',          v_comparison.title,
        'created_at',     v_comparison.created_at,
        'product_count',  COALESCE(jsonb_array_length(v_products), 0),
        'products',       COALESCE(v_products, '[]'::jsonb)
    );
END;
$$;

COMMENT ON FUNCTION public.api_get_shared_comparison(text) IS
    'Returns a shared comparison by token. No auth required. '
    'Does NOT expose user_id. Reuses api_get_products_for_compare for data.';

GRANT EXECUTE ON FUNCTION public.api_get_shared_comparison(text)
    TO authenticated, anon;


-- ────────────────────────────────────────────────────────────────────────────
-- 6. api_delete_comparison(p_comparison_id)
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.api_delete_comparison(
    p_comparison_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    DELETE FROM public.user_comparisons
    WHERE id = p_comparison_id AND user_id = v_user_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Comparison not found or access denied'
        );
    END IF;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'success', true
    );
END;
$$;

COMMENT ON FUNCTION public.api_delete_comparison(uuid) IS
    'Deletes a saved comparison. Owner-only.';

GRANT EXECUTE ON FUNCTION public.api_delete_comparison(uuid)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_delete_comparison(uuid)
    FROM anon, public;

COMMIT;

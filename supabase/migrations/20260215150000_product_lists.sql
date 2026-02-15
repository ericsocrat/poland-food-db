-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: Product Lists & Favorites (#20)
-- Creates user_product_lists + user_product_list_items tables,
-- RLS policies, auto-create trigger, and all api_* RPC functions.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. Tables ──────────────────────────────────────────────────────────────

CREATE TABLE public.user_product_lists (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name            text NOT NULL,
    description     text,
    is_default      boolean NOT NULL DEFAULT false,
    list_type       text NOT NULL DEFAULT 'custom'
                    CHECK (list_type IN ('favorites', 'avoid', 'custom')),
    share_token     text UNIQUE,
    share_enabled   boolean NOT NULL DEFAULT false,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.user_product_lists OWNER TO postgres;

CREATE TABLE public.user_product_list_items (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id     uuid NOT NULL REFERENCES public.user_product_lists(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES public.products(product_id) ON DELETE CASCADE,
    position    integer NOT NULL DEFAULT 0,
    notes       text,
    added_at    timestamptz NOT NULL DEFAULT now(),
    UNIQUE(list_id, product_id)
);

ALTER TABLE public.user_product_list_items OWNER TO postgres;

-- ─── 2. Indexes ─────────────────────────────────────────────────────────────

CREATE INDEX idx_upl_user_id ON public.user_product_lists(user_id);
CREATE INDEX idx_upl_share_token ON public.user_product_lists(share_token)
    WHERE share_token IS NOT NULL;
CREATE INDEX idx_upl_user_type ON public.user_product_lists(user_id, list_type);

CREATE INDEX idx_upli_list_id ON public.user_product_list_items(list_id);
CREATE INDEX idx_upli_product_id ON public.user_product_list_items(product_id);

-- ─── 3. Updated_at trigger ──────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.trg_update_list_timestamp()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_user_product_lists_updated_at
    BEFORE UPDATE ON public.user_product_lists
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_update_list_timestamp();

-- ─── 4. Enforce unique favorites + avoid per user ───────────────────────────

CREATE UNIQUE INDEX idx_upl_unique_favorites
    ON public.user_product_lists(user_id)
    WHERE list_type = 'favorites';

CREATE UNIQUE INDEX idx_upl_unique_avoid
    ON public.user_product_lists(user_id)
    WHERE list_type = 'avoid';

-- ─── 5. RLS Policies ───────────────────────────────────────────────────────

ALTER TABLE public.user_product_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_product_list_items ENABLE ROW LEVEL SECURITY;

-- Lists: owner full access
CREATE POLICY "Users manage own lists"
    ON public.user_product_lists
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Lists: public read via share token (only enabled lists)
CREATE POLICY "Public read shared lists"
    ON public.user_product_lists
    FOR SELECT
    USING (share_enabled = true AND share_token IS NOT NULL);

-- Items: owner full access (via list ownership)
CREATE POLICY "Users manage items in own lists"
    ON public.user_product_list_items
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_product_lists
            WHERE id = user_product_list_items.list_id
              AND user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_product_lists
            WHERE id = user_product_list_items.list_id
              AND user_id = auth.uid()
        )
    );

-- Items: public read via shared list
CREATE POLICY "Public read items in shared lists"
    ON public.user_product_list_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_product_lists
            WHERE id = user_product_list_items.list_id
              AND share_enabled = true
              AND share_token IS NOT NULL
        )
    );

-- ─── 6. Grants ──────────────────────────────────────────────────────────────

GRANT ALL ON public.user_product_lists TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_product_lists TO authenticated;
REVOKE ALL ON public.user_product_lists FROM anon;
-- anon needs SELECT for shared list access
GRANT SELECT ON public.user_product_lists TO anon;

GRANT ALL ON public.user_product_list_items TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_product_list_items TO authenticated;
REVOKE ALL ON public.user_product_list_items FROM anon;
GRANT SELECT ON public.user_product_list_items TO anon;

-- ─── 7. Auto-create default lists on first sign-in ─────────────────────────
-- Uses a trigger on user_preferences (created during onboarding) to ensure
-- every user gets Favorites + Avoid lists.

CREATE OR REPLACE FUNCTION public.trg_create_default_lists()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Only create if they don't already exist
    INSERT INTO public.user_product_lists (user_id, name, list_type, is_default)
    VALUES
        (NEW.user_id, 'Favorites', 'favorites', true),
        (NEW.user_id, 'Avoid',     'avoid',     true)
    ON CONFLICT DO NOTHING;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auto_create_lists
    AFTER INSERT ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_create_default_lists();

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. API Functions
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 8a. api_get_lists() ────────────────────────────────────────────────────
-- Returns all lists for the authenticated user with item counts.

CREATE OR REPLACE FUNCTION public.api_get_lists()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_lists   jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb ORDER BY
        CASE list_type WHEN 'favorites' THEN 0 WHEN 'avoid' THEN 1 ELSE 2 END,
        t.created_at
    ), '[]'::jsonb)
    INTO v_lists
    FROM (
        SELECT
            l.id,
            l.name,
            l.description,
            l.list_type,
            l.is_default,
            l.share_enabled,
            l.share_token,
            l.created_at,
            l.updated_at,
            (SELECT count(*) FROM public.user_product_list_items li WHERE li.list_id = l.id) AS item_count
        FROM public.user_product_lists l
        WHERE l.user_id = v_user_id
    ) t;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'lists', v_lists
    );
END;
$$;

-- ─── 8b. api_get_list_items(p_list_id) ──────────────────────────────────────
-- Returns items in a specific list with full product details.

CREATE OR REPLACE FUNCTION public.api_get_list_items(
    p_list_id   uuid,
    p_limit     integer DEFAULT 50,
    p_offset    integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id    uuid := auth.uid();
    v_list       record;
    v_items      jsonb;
    v_total      integer;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Verify list ownership
    SELECT id, name, list_type, description, share_enabled
    INTO v_list
    FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Total count
    SELECT count(*) INTO v_total
    FROM public.user_product_list_items
    WHERE list_id = p_list_id;

    -- Items with product data
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb ORDER BY t.position, t.added_at), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            li.id        AS item_id,
            li.product_id,
            li.position,
            li.notes,
            li.added_at,
            p.product_name,
            p.brand,
            p.category,
            s.unhealthiness_score::integer,
            coalesce(s.nutri_score_label, 'UNKNOWN') AS nutri_score_label,
            coalesce(s.nova_classification, 'N/A')   AS nova_classification,
            n.energy_kcal_100g::numeric(7,1)         AS calories
        FROM public.user_product_list_items li
        JOIN public.products  p ON p.product_id = li.product_id AND p.is_deprecated = false
        LEFT JOIN public.scores s ON s.product_id = li.product_id
        LEFT JOIN public.nutrition_facts n ON n.product_id = li.product_id
        WHERE li.list_id = p_list_id
        ORDER BY li.position, li.added_at
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'list_id',     v_list.id,
        'list_name',   v_list.name,
        'list_type',   v_list.list_type,
        'description', v_list.description,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'items',       v_items
    );
END;
$$;

-- ─── 8c. api_create_list(p_name, p_description, p_list_type) ────────────────

CREATE OR REPLACE FUNCTION public.api_create_list(
    p_name        text,
    p_description text DEFAULT NULL,
    p_list_type   text DEFAULT 'custom'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_list_id uuid;
    v_count   integer;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Validate name
    IF trim(coalesce(p_name, '')) = '' THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List name is required');
    END IF;

    -- Validate list_type
    IF p_list_type NOT IN ('favorites', 'avoid', 'custom') THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Invalid list type');
    END IF;

    -- Only one favorites and one avoid per user
    IF p_list_type IN ('favorites', 'avoid') THEN
        SELECT count(*) INTO v_count
        FROM public.user_product_lists
        WHERE user_id = v_user_id AND list_type = p_list_type;

        IF v_count > 0 THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', format('You already have a %s list', p_list_type)
            );
        END IF;
    END IF;

    -- Limit: max 20 custom lists per user
    SELECT count(*) INTO v_count
    FROM public.user_product_lists
    WHERE user_id = v_user_id AND list_type = 'custom';

    IF v_count >= 20 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Maximum 20 custom lists allowed');
    END IF;

    INSERT INTO public.user_product_lists (user_id, name, description, list_type)
    VALUES (v_user_id, trim(p_name), p_description, p_list_type)
    RETURNING id INTO v_list_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'list_id',     v_list_id,
        'name',        trim(p_name),
        'list_type',   p_list_type
    );
END;
$$;

-- ─── 8d. api_update_list(p_list_id, p_name, p_description) ─────────────────

CREATE OR REPLACE FUNCTION public.api_update_list(
    p_list_id     uuid,
    p_name        text DEFAULT NULL,
    p_description text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_list    record;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT id, is_default INTO v_list
    FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Cannot rename default lists
    IF v_list.is_default AND p_name IS NOT NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Cannot rename default lists');
    END IF;

    UPDATE public.user_product_lists
    SET
        name        = coalesce(nullif(trim(p_name), ''), name),
        description = coalesce(p_description, description)
    WHERE id = p_list_id AND user_id = v_user_id;

    RETURN jsonb_build_object('api_version', '1.0', 'success', true);
END;
$$;

-- ─── 8e. api_delete_list(p_list_id) ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_delete_list(p_list_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_list    record;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT id, is_default INTO v_list
    FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    IF v_list.is_default THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Cannot delete default lists');
    END IF;

    DELETE FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    RETURN jsonb_build_object('api_version', '1.0', 'success', true);
END;
$$;

-- ─── 8f. api_add_to_list(p_list_id, p_product_id, p_notes) ─────────────────

CREATE OR REPLACE FUNCTION public.api_add_to_list(
    p_list_id    uuid,
    p_product_id bigint,
    p_notes      text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id  uuid := auth.uid();
    v_list     record;
    v_item_id  uuid;
    v_max_pos  integer;
    v_count    integer;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Verify list ownership
    SELECT id, list_type INTO v_list
    FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Verify product exists and is not deprecated
    IF NOT EXISTS (SELECT 1 FROM public.products WHERE product_id = p_product_id AND is_deprecated = false) THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Product not found');
    END IF;

    -- Limit items per list: 500
    SELECT count(*) INTO v_count
    FROM public.user_product_list_items
    WHERE list_id = p_list_id;

    IF v_count >= 500 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Maximum 500 items per list');
    END IF;

    -- Get next position
    SELECT coalesce(max(position), 0) + 1 INTO v_max_pos
    FROM public.user_product_list_items
    WHERE list_id = p_list_id;

    -- Upsert: update notes if already exists
    INSERT INTO public.user_product_list_items (list_id, product_id, position, notes)
    VALUES (p_list_id, p_product_id, v_max_pos, p_notes)
    ON CONFLICT (list_id, product_id) DO UPDATE
        SET notes = coalesce(EXCLUDED.notes, user_product_list_items.notes)
    RETURNING id INTO v_item_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'item_id',     v_item_id,
        'list_type',   v_list.list_type
    );
END;
$$;

-- ─── 8g. api_remove_from_list(p_list_id, p_product_id) ─────────────────────

CREATE OR REPLACE FUNCTION public.api_remove_from_list(
    p_list_id    uuid,
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_deleted integer;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Verify list ownership
    IF NOT EXISTS (
        SELECT 1 FROM public.user_product_lists
        WHERE id = p_list_id AND user_id = v_user_id
    ) THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    DELETE FROM public.user_product_list_items
    WHERE list_id = p_list_id AND product_id = p_product_id;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    IF v_deleted = 0 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Item not found in list');
    END IF;

    RETURN jsonb_build_object('api_version', '1.0', 'success', true);
END;
$$;

-- ─── 8h. api_reorder_list(p_list_id, p_product_ids) ────────────────────────
-- Bulk re-position items in a single query. p_product_ids is the new order.

CREATE OR REPLACE FUNCTION public.api_reorder_list(
    p_list_id     uuid,
    p_product_ids bigint[]
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
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    -- Verify list ownership
    IF NOT EXISTS (
        SELECT 1 FROM public.user_product_lists
        WHERE id = p_list_id AND user_id = v_user_id
    ) THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Bulk update positions from array order
    UPDATE public.user_product_list_items li
    SET position = arr.ord
    FROM unnest(p_product_ids) WITH ORDINALITY AS arr(pid, ord)
    WHERE li.list_id = p_list_id
      AND li.product_id = arr.pid;

    RETURN jsonb_build_object('api_version', '1.0', 'success', true);
END;
$$;

-- ─── 8i. api_toggle_share(p_list_id, p_enabled) ────────────────────────────

CREATE OR REPLACE FUNCTION public.api_toggle_share(
    p_list_id  uuid,
    p_enabled  boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id    uuid := auth.uid();
    v_list       record;
    v_token      text;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT id, share_token, list_type INTO v_list
    FROM public.user_product_lists
    WHERE id = p_list_id AND user_id = v_user_id;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Cannot share the Avoid list
    IF v_list.list_type = 'avoid' THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Cannot share the Avoid list');
    END IF;

    -- Generate token on first enable (or if missing)
    IF p_enabled AND v_list.share_token IS NULL THEN
        v_token := encode(gen_random_bytes(18), 'base64');
        -- URL-safe: replace +/= chars
        v_token := replace(replace(replace(v_token, '+', '-'), '/', '_'), '=', '');
    ELSE
        v_token := v_list.share_token;
    END IF;

    UPDATE public.user_product_lists
    SET share_enabled = p_enabled,
        share_token   = v_token
    WHERE id = p_list_id AND user_id = v_user_id;

    RETURN jsonb_build_object(
        'api_version',  '1.0',
        'share_enabled', p_enabled,
        'share_token',   CASE WHEN p_enabled THEN v_token ELSE NULL END
    );
END;
$$;

-- ─── 8j. api_revoke_share(p_list_id) ────────────────────────────────────────
-- Disables sharing AND regenerates the token so old links break permanently.

CREATE OR REPLACE FUNCTION public.api_revoke_share(p_list_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.user_product_lists
        WHERE id = p_list_id AND user_id = v_user_id
    ) THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'List not found');
    END IF;

    -- Regenerate token + disable — old links become permanently invalid
    UPDATE public.user_product_lists
    SET share_enabled = false,
        share_token   = encode(gen_random_bytes(18), 'base64')
    WHERE id = p_list_id AND user_id = v_user_id;

    RETURN jsonb_build_object('api_version', '1.0', 'success', true);
END;
$$;

-- ─── 8k. api_get_shared_list(p_share_token) ─────────────────────────────────
-- Public function — no auth required. Does NOT expose user_id.

CREATE OR REPLACE FUNCTION public.api_get_shared_list(
    p_share_token text,
    p_limit       integer DEFAULT 50,
    p_offset      integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_list   record;
    v_items  jsonb;
    v_total  integer;
BEGIN
    -- Find the shared list (no auth check — intentionally public)
    SELECT id, name, description, list_type
    INTO v_list
    FROM public.user_product_lists
    WHERE share_token = p_share_token
      AND share_enabled = true;

    IF v_list.id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Shared list not found or link expired');
    END IF;

    -- Total count
    SELECT count(*) INTO v_total
    FROM public.user_product_list_items
    WHERE list_id = v_list.id;

    -- Items with product data — NO user_id, NO health warnings
    SELECT coalesce(jsonb_agg(row_to_json(t)::jsonb ORDER BY t.position, t.added_at), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            li.product_id,
            li.position,
            p.product_name,
            p.brand,
            p.category,
            s.unhealthiness_score::integer,
            coalesce(s.nutri_score_label, 'UNKNOWN') AS nutri_score_label,
            n.energy_kcal_100g::numeric(7,1)         AS calories
        FROM public.user_product_list_items li
        JOIN public.products p ON p.product_id = li.product_id AND p.is_deprecated = false
        LEFT JOIN public.scores s ON s.product_id = li.product_id
        LEFT JOIN public.nutrition_facts n ON n.product_id = li.product_id
        WHERE li.list_id = v_list.id
        ORDER BY li.position, li.added_at
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'list_name',   v_list.name,
        'description', v_list.description,
        'list_type',   v_list.list_type,
        'total_count', v_total,
        'limit',       p_limit,
        'offset',      p_offset,
        'items',       v_items
    );
END;
$$;

-- ─── 8l. api_get_avoid_product_ids() ────────────────────────────────────────
-- Returns a flat array of product IDs the user is avoiding.
-- Called once on auth → cached client-side. No N+1.

CREATE OR REPLACE FUNCTION public.api_get_avoid_product_ids()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id    uuid := auth.uid();
    v_product_ids bigint[];
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
    END IF;

    SELECT array_agg(li.product_id)
    INTO v_product_ids
    FROM public.user_product_list_items li
    JOIN public.user_product_lists l ON l.id = li.list_id
    WHERE l.user_id = v_user_id
      AND l.list_type = 'avoid';

    RETURN jsonb_build_object(
        'api_version',  '1.0',
        'product_ids',  coalesce(to_jsonb(v_product_ids), '[]'::jsonb)
    );
END;
$$;

-- ─── 9. Function Grants ────────────────────────────────────────────────────

-- Authenticated-only functions
DO $$
DECLARE
    func_name text;
BEGIN
    FOREACH func_name IN ARRAY ARRAY[
        'api_get_lists',
        'api_get_list_items',
        'api_create_list',
        'api_update_list',
        'api_delete_list',
        'api_add_to_list',
        'api_remove_from_list',
        'api_reorder_list',
        'api_toggle_share',
        'api_revoke_share',
        'api_get_avoid_product_ids'
    ] LOOP
        EXECUTE format('REVOKE EXECUTE ON FUNCTION public.%I FROM anon', func_name);
    END LOOP;
END $$;

-- Public functions (accessible without auth)
GRANT EXECUTE ON FUNCTION public.api_get_shared_list(text, integer, integer) TO anon;
GRANT EXECUTE ON FUNCTION public.api_get_shared_list(text, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_shared_list(text, integer, integer) TO service_role;

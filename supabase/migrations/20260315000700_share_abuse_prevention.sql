-- Share abuse prevention: per-user share limits, content validation, rate limiting
--
-- 1. check_share_limit() — enforces max 50 shared links per user per type
-- 2. Rate limit entries for share endpoints (api_save_comparison, api_toggle_share)
-- 3. Patch api_save_comparison() to validate product_ids NOT EMPTY + apply share limit
-- 4. Patch api_toggle_share() to apply share limit before generating token
--
-- Rollback: DROP FUNCTION IF EXISTS check_share_limit;
--           DELETE FROM api_rate_limits WHERE endpoint IN ('api_save_comparison','api_toggle_share');

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. check_share_limit() — per-user share limit enforcement
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.check_share_limit(
  p_user_id uuid,
  p_type    text
)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'allowed', CASE p_type
      WHEN 'list' THEN
        (SELECT COUNT(*) < 50 FROM user_product_lists
         WHERE user_id = p_user_id AND share_token IS NOT NULL)
      WHEN 'comparison' THEN
        (SELECT COUNT(*) < 50 FROM user_comparisons
         WHERE user_id = p_user_id AND share_token IS NOT NULL)
      ELSE true
    END,
    'type', p_type,
    'limit', 50
  );
$$;

COMMENT ON FUNCTION public.check_share_limit IS
  'Returns whether a user may create another share link (max 50 per type)';

-- Grant to authenticated users
GRANT EXECUTE ON FUNCTION public.check_share_limit(uuid, text) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.check_share_limit(uuid, text) FROM anon;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Rate limit entries for share endpoints
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO public.api_rate_limits (endpoint, max_requests, window_seconds, description)
VALUES
  ('api_save_comparison', 20, 3600, 'Save/share comparison — max 20 per hour'),
  ('api_toggle_share',    20, 3600, 'Toggle list sharing — max 20 per hour')
ON CONFLICT (endpoint) DO UPDATE SET
  max_requests = EXCLUDED.max_requests,
  window_seconds = EXCLUDED.window_seconds,
  description = EXCLUDED.description;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Patch api_save_comparison() — add share limit + content validation
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_save_comparison(
  p_product_ids  bigint[],
  p_title        text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id      uuid;
  v_id           uuid;
  v_token        text;
  v_count        integer;
  v_share_check  jsonb;
  v_rate_check   jsonb;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Authentication required'
    );
  END IF;

  -- Content validation: require 2-4 products
  v_count := array_length(p_product_ids, 1);
  IF v_count IS NULL OR v_count < 2 OR v_count > 4 THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Please provide between 2 and 4 product IDs'
    );
  END IF;

  -- Rate limit check
  v_rate_check := check_api_rate_limit(v_user_id, 'api_save_comparison');
  IF NOT (v_rate_check ->> 'allowed')::boolean THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Rate limit exceeded for comparisons'
    );
  END IF;

  -- Share limit check
  v_share_check := check_share_limit(v_user_id, 'comparison');
  IF NOT (v_share_check ->> 'allowed')::boolean THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Share limit reached (max 50 shared comparisons)'
    );
  END IF;

  -- Generate token and insert
  v_token := encode(gen_random_bytes(12), 'hex');
  INSERT INTO user_comparisons (user_id, product_ids, title, share_token)
  VALUES (v_user_id, p_product_ids, p_title, v_token)
  RETURNING id INTO v_id;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'comparison_id', v_id,
    'share_token', v_token,
    'product_ids', p_product_ids,
    'title', p_title
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Patch api_toggle_share() — add share limit
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_toggle_share(
  p_list_id   uuid,
  p_enabled   boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id      uuid;
  v_token        text;
  v_list         record;
  v_share_check  jsonb;
  v_rate_check   jsonb;
  v_item_count   integer;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Authentication required'
    );
  END IF;

  -- Ownership check
  SELECT id, share_token, list_type INTO v_list
  FROM user_product_lists
  WHERE id = p_list_id AND user_id = v_user_id;

  IF v_list.id IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'List not found'
    );
  END IF;

  -- Cannot share the Avoid list
  IF v_list.list_type = 'avoid' THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'Cannot share the Avoid list'
    );
  END IF;

  IF p_enabled THEN
    -- Content validation: list must have at least 1 item to share
    SELECT COUNT(*) INTO v_item_count
    FROM user_product_list_items
    WHERE list_id = p_list_id;

    IF v_item_count = 0 THEN
      RETURN jsonb_build_object(
        'api_version', '1.0',
        'error', 'Cannot share an empty list'
      );
    END IF;

    -- Rate limit check
    v_rate_check := check_api_rate_limit(v_user_id, 'api_toggle_share');
    IF NOT (v_rate_check ->> 'allowed')::boolean THEN
      RETURN jsonb_build_object(
        'api_version', '1.0',
        'error', 'Rate limit exceeded for sharing'
      );
    END IF;

    -- Share limit check
    v_share_check := check_share_limit(v_user_id, 'list');
    IF NOT (v_share_check ->> 'allowed')::boolean THEN
      RETURN jsonb_build_object(
        'api_version', '1.0',
        'error', 'Share limit reached (max 50 shared lists)'
      );
    END IF;

    -- Generate new token on first enable (or if missing)
    IF v_list.share_token IS NULL THEN
      v_token := encode(gen_random_bytes(18), 'base64');
      v_token := replace(replace(replace(v_token, '+', '-'), '/', '_'), '=', '');
    ELSE
      v_token := v_list.share_token;
    END IF;

    UPDATE user_product_lists
    SET share_enabled = p_enabled,
        share_token   = v_token
    WHERE id = p_list_id AND user_id = v_user_id;
  ELSE
    -- Disable sharing
    UPDATE user_product_lists
    SET share_enabled = false
    WHERE id = p_list_id AND user_id = v_user_id;
    v_token := NULL;
  END IF;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'share_enabled', p_enabled,
    'share_token', CASE WHEN p_enabled THEN v_token ELSE NULL END
  );
END;
$$;

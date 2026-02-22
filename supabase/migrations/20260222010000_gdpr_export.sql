-- Migration: GDPR Data Export — api_export_user_data()
-- Issue #145 — User Data Export (JSON/CSV Download from Settings)
--
-- Creates an RPC that assembles ALL personal data for the calling user
-- into a single JSONB payload for client-side download.

/* ── RPC: api_export_user_data ─────────────────────────────────────────────── */

CREATE OR REPLACE FUNCTION api_export_user_data()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_result JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated'
      USING ERRCODE = 'P0001';
  END IF;

  SELECT jsonb_build_object(
    'exported_at',       now()::text,
    'format_version',    '1.0',
    'user_id',           v_uid::text,

    /* ── User preferences ──────────────────────────────────────────────── */
    'preferences', (
      SELECT row_to_json(p.*)::jsonb
      FROM user_preferences p
      WHERE p.user_id = v_uid
    ),

    /* ── Health profiles ───────────────────────────────────────────────── */
    'health_profiles', COALESCE((
      SELECT jsonb_agg(row_to_json(h.*)::jsonb ORDER BY h.created_at)
      FROM user_health_profiles h
      WHERE h.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Product lists (favorites, avoid, custom) with items ───────────── */
    'product_lists', COALESCE((
      SELECT jsonb_agg(
        jsonb_build_object(
          'id',           l.id,
          'name',         l.name,
          'description',  l.description,
          'list_type',    l.list_type,
          'is_default',   l.is_default,
          'share_enabled', l.share_enabled,
          'created_at',   l.created_at,
          'updated_at',   l.updated_at,
          'items', COALESCE((
            SELECT jsonb_agg(
              jsonb_build_object(
                'product_id', li.product_id,
                'position',   li.position,
                'notes',      li.notes,
                'added_at',   li.added_at
              ) ORDER BY li.position
            )
            FROM user_product_list_items li
            WHERE li.list_id = l.id
          ), '[]'::jsonb)
        ) ORDER BY l.created_at
      )
      FROM user_product_lists l
      WHERE l.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Comparisons ───────────────────────────────────────────────────── */
    'comparisons', COALESCE((
      SELECT jsonb_agg(row_to_json(c.*)::jsonb ORDER BY c.created_at)
      FROM user_comparisons c
      WHERE c.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Saved searches ────────────────────────────────────────────────── */
    'saved_searches', COALESCE((
      SELECT jsonb_agg(row_to_json(s.*)::jsonb ORDER BY s.created_at)
      FROM user_saved_searches s
      WHERE s.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Scan history ──────────────────────────────────────────────────── */
    'scan_history', COALESCE((
      SELECT jsonb_agg(row_to_json(sh.*)::jsonb ORDER BY sh.scanned_at)
      FROM scan_history sh
      WHERE sh.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Watched products ──────────────────────────────────────────────── */
    'watched_products', COALESCE((
      SELECT jsonb_agg(row_to_json(w.*)::jsonb ORDER BY w.created_at)
      FROM user_watched_products w
      WHERE w.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Product views ─────────────────────────────────────────────────── */
    'product_views', COALESCE((
      SELECT jsonb_agg(row_to_json(pv.*)::jsonb ORDER BY pv.viewed_at)
      FROM user_product_views pv
      WHERE pv.user_id = v_uid
    ), '[]'::jsonb),

    /* ── Achievements ──────────────────────────────────────────────────── */
    'achievements', COALESCE((
      SELECT jsonb_agg(row_to_json(a.*)::jsonb ORDER BY a.created_at)
      FROM user_achievement a
      WHERE a.user_id = v_uid
    ), '[]'::jsonb)
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- Permissions: only authenticated users can call
REVOKE ALL ON FUNCTION api_export_user_data() FROM PUBLIC;
REVOKE ALL ON FUNCTION api_export_user_data() FROM anon;
GRANT EXECUTE ON FUNCTION api_export_user_data() TO authenticated;

COMMENT ON FUNCTION api_export_user_data() IS
  'GDPR Article 20 — assembles all personal data for the calling user into JSONB for download.';

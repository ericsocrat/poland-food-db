-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260321000100_admin_submissions_country_context.sql
-- Ticket:    #925 — Show country context in admin submission review UI
-- ═══════════════════════════════════════════════════════════════════════════
-- Adds scan_country and suggested_country fields to the
-- api_admin_get_submissions response. Adds optional p_country filter param.
--
-- Backward compatible: new keys are additive, new param has DEFAULT NULL.
-- ═══════════════════════════════════════════════════════════════════════════
-- To roll back: redeploy api_admin_get_submissions from 20260315000600
-- ═══════════════════════════════════════════════════════════════════════════


CREATE OR REPLACE FUNCTION public.api_admin_get_submissions(
  p_status    text    DEFAULT 'pending',
  p_page      integer DEFAULT 1,
  p_page_size integer DEFAULT 20,
  p_country   text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_offset  integer;
  v_total   bigint;
  v_items   jsonb;
BEGIN
  v_offset := (GREATEST(p_page, 1) - 1) * LEAST(p_page_size, 50);

  SELECT COUNT(*) INTO v_total
    FROM public.product_submissions
   WHERE (p_status = 'all' OR status = p_status)
     AND (p_country IS NULL
          OR scan_country = p_country
          OR suggested_country = p_country);

  SELECT COALESCE(jsonb_agg(row_obj ORDER BY rn), '[]'::jsonb)
    INTO v_items
    FROM (
      SELECT
        ROW_NUMBER() OVER (ORDER BY ps.created_at ASC) AS rn,
        jsonb_build_object(
          'id',               ps.id,
          'ean',              ps.ean,
          'product_name',     ps.product_name,
          'brand',            ps.brand,
          'category',         ps.category,
          'photo_url',        ps.photo_url,
          'notes',            ps.notes,
          'status',           ps.status,
          'user_id',          ps.user_id,
          'merged_product_id', ps.merged_product_id,
          'created_at',       ps.created_at,
          'updated_at',       ps.updated_at,
          'reviewed_at',      ps.reviewed_at,
          -- ── Country context (#925) ─────────────────────────
          'scan_country',         ps.scan_country,
          'suggested_country',    ps.suggested_country,
          -- ── Trust & quality enrichment (#474) ──────────────
          'user_trust_score',       COALESCE(uts.trust_score, 50),
          'user_total_submissions', COALESCE(uts.total_submissions, 0),
          'user_approved_pct',      CASE
            WHEN COALESCE(uts.total_submissions, 0) > 0
            THEN round(100.0 * uts.approved_submissions / uts.total_submissions)
            ELSE NULL
          END,
          'user_flagged',           (uts.flagged_at IS NOT NULL),
          'review_notes',           ps.review_notes,
          'existing_product_match', (
            SELECT jsonb_build_object(
              'product_id', p.product_id,
              'product_name', p.product_name
            )
            FROM products p
            WHERE p.ean = ps.ean AND p.is_deprecated IS NOT TRUE
            LIMIT 1
          )
        ) AS row_obj
      FROM public.product_submissions ps
      LEFT JOIN public.user_trust_scores uts ON uts.user_id = ps.user_id
      WHERE (p_status = 'all' OR ps.status = p_status)
        AND (p_country IS NULL
             OR ps.scan_country = p_country
             OR ps.suggested_country = p_country)
      ORDER BY ps.created_at ASC
      OFFSET v_offset
      LIMIT LEAST(p_page_size, 50)
    ) sub;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'total',       v_total,
    'page',        GREATEST(p_page, 1),
    'pages',       GREATEST(CEIL(v_total::numeric / LEAST(p_page_size, 50)), 1),
    'page_size',   LEAST(p_page_size, 50),
    'status_filter', p_status,
    'country_filter', p_country,
    'submissions', v_items
  );
END;
$$;

-- Updated grants for new signature (4 params)
GRANT EXECUTE ON FUNCTION public.api_admin_get_submissions(text, integer, integer, text)
  TO service_role, authenticated;

COMMENT ON FUNCTION public.api_admin_get_submissions(text, integer, integer, text) IS
  'Purpose: List product submissions with trust enrichment and country context
   Auth: authenticated (SECURITY DEFINER)
   Params: p_status (default pending), p_page (default 1), p_page_size (default 20, max 50), p_country (optional country filter)
   Returns: JSONB {api_version, total, page, pages, page_size, status_filter, country_filter, submissions: [...]}
   Country filter: matches scan_country OR suggested_country
   Backward compatible: new p_country param defaults to NULL (no filter)';

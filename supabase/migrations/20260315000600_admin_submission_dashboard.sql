-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260315000600_admin_submission_dashboard.sql
-- Ticket:    #474 — Admin dashboard for submission review & user flagging
-- ═══════════════════════════════════════════════════════════════════════════
-- Enhances admin workflow with trust score visibility, batch operations,
-- and submission velocity monitoring.
--
-- Phase 1: Enhanced api_admin_get_submissions (add trust score + quality data)
-- Phase 2: api_admin_batch_reject_user (batch reject + flag user)
-- Phase 3: api_admin_submission_velocity (velocity dashboard data)
-- ═══════════════════════════════════════════════════════════════════════════
-- To roll back: redeploy api_admin_get_submissions from 20260215200000;
--               DROP FUNCTION IF EXISTS api_admin_batch_reject_user;
--               DROP FUNCTION IF EXISTS api_admin_submission_velocity;
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── Phase 1: Enhanced api_admin_get_submissions ───────────────────────────
-- Adds: user_trust_score, user_total_submissions, user_approved_pct,
--       review_notes (auto-triage), existing_product_match
-- Backward compatible: all new keys are additive.

CREATE OR REPLACE FUNCTION public.api_admin_get_submissions(
  p_status    text    DEFAULT 'pending',
  p_page      integer DEFAULT 1,
  p_page_size integer DEFAULT 20
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
   WHERE (p_status = 'all' OR status = p_status);

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
    'submissions', v_items
  );
END;
$$;

-- Grants unchanged
GRANT EXECUTE ON FUNCTION public.api_admin_get_submissions(text, integer, integer)
  TO service_role, authenticated;


-- ─── Phase 2: api_admin_batch_reject_user ──────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_batch_reject_user(
  p_user_id uuid,
  p_reason  text DEFAULT 'Batch rejected: flagged user'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller uuid := auth.uid();
  v_count  integer;
BEGIN
  -- Require authenticated caller
  IF v_caller IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'authentication_required'
    );
  END IF;

  -- Reject all pending submissions from the target user
  UPDATE product_submissions
     SET status      = 'rejected',
         review_notes = p_reason,
         reviewed_by  = v_caller,
         reviewed_at  = now(),
         updated_at   = now()
   WHERE user_id = p_user_id
     AND status IN ('pending', 'manual_review', 'flag_for_review');

  GET DIAGNOSTICS v_count = ROW_COUNT;

  -- Flag user in trust scores (cap at 10, set flag)
  INSERT INTO user_trust_scores (user_id, trust_score, flagged_at, flag_reason)
  VALUES (p_user_id, 10, now(), p_reason)
  ON CONFLICT (user_id) DO UPDATE SET
    trust_score = LEAST(user_trust_scores.trust_score, 10),
    flagged_at  = now(),
    flag_reason = p_reason,
    updated_at  = now();

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'rejected_count', v_count,
    'user_id', p_user_id,
    'user_flagged', true,
    'flag_reason', p_reason
  );
END;
$$;

COMMENT ON FUNCTION public.api_admin_batch_reject_user(uuid, text) IS
  'Admin: batch-reject all pending/review submissions from a user + flag trust score. '
  'Caps trust_score at 10, sets flagged_at + flag_reason.';

REVOKE ALL ON FUNCTION public.api_admin_batch_reject_user(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_admin_batch_reject_user(uuid, text) TO service_role, authenticated;


-- ─── Phase 3: api_admin_submission_velocity ────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_submission_velocity()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller uuid := auth.uid();
BEGIN
  IF v_caller IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error', 'authentication_required'
    );
  END IF;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'last_24h',          (SELECT COUNT(*) FROM product_submissions
                          WHERE created_at > now() - interval '24 hours'),
    'last_7d',           (SELECT COUNT(*) FROM product_submissions
                          WHERE created_at > now() - interval '7 days'),
    'pending_count',     (SELECT COUNT(*) FROM product_submissions
                          WHERE status IN ('pending', 'manual_review', 'flag_for_review')),
    'auto_rejected_24h', (SELECT COUNT(*) FROM product_submissions
                          WHERE status = 'auto_reject'
                            AND created_at > now() - interval '24 hours'),
    'status_breakdown',  (
      SELECT COALESCE(jsonb_object_agg(status, cnt), '{}'::jsonb)
      FROM (
        SELECT status, COUNT(*) AS cnt
          FROM product_submissions
         GROUP BY status
      ) s
    ),
    'top_submitters',    (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'user_id', sub.user_id,
        'submission_count', sub.cnt,
        'trust_score', COALESCE(uts.trust_score, 50),
        'flagged', (uts.flagged_at IS NOT NULL)
      ) ORDER BY sub.cnt DESC), '[]'::jsonb)
      FROM (
        SELECT user_id, COUNT(*) AS cnt
          FROM product_submissions
         WHERE created_at > now() - interval '7 days'
         GROUP BY user_id
         ORDER BY cnt DESC
         LIMIT 10
      ) sub
      LEFT JOIN user_trust_scores uts ON uts.user_id = sub.user_id
    )
  );
END;
$$;

COMMENT ON FUNCTION public.api_admin_submission_velocity() IS
  'Admin: submission velocity dashboard — counts, status breakdown, top submitters. '
  'Returns aggregated stats for the last 24h and 7d.';

REVOKE ALL ON FUNCTION public.api_admin_submission_velocity() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_admin_submission_velocity() TO service_role, authenticated;

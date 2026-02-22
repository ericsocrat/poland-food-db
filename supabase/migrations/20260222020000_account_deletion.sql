-- Migration: account_deletion
-- GDPR Article 17 — Right to Erasure
-- Provides api_delete_user_data() RPC and deletion_audit_log table.

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Allow approved product_submissions to survive user deletion
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.product_submissions
  ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE public.product_submissions
  DROP CONSTRAINT IF EXISTS product_submissions_user_id_fkey;

ALTER TABLE public.product_submissions
  ADD CONSTRAINT product_submissions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Fix reviewed_by FK to avoid blocking user deletion
ALTER TABLE public.product_submissions
  DROP CONSTRAINT IF EXISTS product_submissions_reviewed_by_fkey;

ALTER TABLE public.product_submissions
  ADD CONSTRAINT product_submissions_reviewed_by_fkey
  FOREIGN KEY (reviewed_by) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Update RLS policy to handle NULL user_id (approved submissions from deleted users)
DROP POLICY IF EXISTS "Users see own submissions" ON public.product_submissions;
CREATE POLICY "Users see own submissions"
  ON public.product_submissions FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Deletion audit log (no PII — stores only timestamp + affected tables)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.deletion_audit_log (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  deleted_at       timestamptz NOT NULL DEFAULT now(),
  tables_affected  text[]      NOT NULL
);

ALTER TABLE public.deletion_audit_log ENABLE ROW LEVEL SECURITY;
-- No policies = service_role only (bypasses RLS).
-- authenticated/anon cannot read or write.

COMMENT ON TABLE public.deletion_audit_log IS
  'GDPR Art.17 audit trail — records account deletions without PII';

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. api_delete_user_data() — deletes all user data + auth record
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_delete_user_data()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid    UUID := auth.uid();
  v_tables TEXT[] := ARRAY[
    'notification_queue',
    'push_subscriptions',
    'scan_history',
    'user_saved_searches',
    'user_comparisons',
    'user_product_list_items',
    'user_product_lists',
    'user_watched_products',
    'user_product_views',
    'user_achievement',
    'user_health_profiles',
    'user_preferences',
    'product_submissions',
    'analytics_events'
  ];
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated'
      USING ERRCODE = 'P0001';
  END IF;

  -- ── Preserve approved submissions (anonymize) ─────────────────────────
  UPDATE public.product_submissions
     SET user_id = NULL
   WHERE user_id = v_uid
     AND status IN ('approved', 'merged');

  -- Delete non-approved submissions
  DELETE FROM public.product_submissions
   WHERE user_id = v_uid;

  -- Clear reviewed_by references
  UPDATE public.product_submissions
     SET reviewed_by = NULL
   WHERE reviewed_by = v_uid;

  -- ── Delete from all user tables (explicit, not relying on CASCADE) ────
  DELETE FROM public.notification_queue     WHERE user_id = v_uid;
  DELETE FROM public.push_subscriptions     WHERE user_id = v_uid;
  DELETE FROM public.scan_history           WHERE user_id = v_uid;
  DELETE FROM public.user_saved_searches    WHERE user_id = v_uid;
  DELETE FROM public.user_comparisons       WHERE user_id = v_uid;
  DELETE FROM public.user_product_list_items
   WHERE list_id IN (SELECT id FROM public.user_product_lists WHERE user_id = v_uid);
  DELETE FROM public.user_product_lists     WHERE user_id = v_uid;
  DELETE FROM public.user_watched_products  WHERE user_id = v_uid;
  DELETE FROM public.user_product_views     WHERE user_id = v_uid;
  DELETE FROM public.user_achievement       WHERE user_id = v_uid;
  DELETE FROM public.user_health_profiles   WHERE user_id = v_uid;
  DELETE FROM public.user_preferences       WHERE user_id = v_uid;

  -- ── Anonymize analytics (keep events, remove PII link) ────────────────
  UPDATE public.analytics_events
     SET user_id = NULL
   WHERE user_id = v_uid;

  -- ── Audit log (no PII) ───────────────────────────────────────────────
  INSERT INTO public.deletion_audit_log (tables_affected)
  VALUES (v_tables);

  -- ── Delete the auth user (SECURITY DEFINER has elevated access) ───────
  DELETE FROM auth.users WHERE id = v_uid;

  RETURN jsonb_build_object(
    'status',    'deleted',
    'timestamp', now()::text
  );
END;
$$;

REVOKE ALL ON FUNCTION public.api_delete_user_data() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.api_delete_user_data() FROM anon;
GRANT EXECUTE ON FUNCTION public.api_delete_user_data() TO authenticated;

COMMENT ON FUNCTION public.api_delete_user_data() IS
  'GDPR Art.17 — permanently deletes all user data and auth record';

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Update analytics CHECK constraint with events added since initial migration
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.analytics_events
  DROP CONSTRAINT IF EXISTS chk_ae_event_name;

ALTER TABLE public.analytics_events
  ADD CONSTRAINT chk_ae_event_name CHECK (event_name IN (
    'search_performed',
    'filter_applied',
    'search_saved',
    'compare_opened',
    'list_created',
    'list_shared',
    'favorites_added',
    'list_item_added',
    'avoid_added',
    'scanner_used',
    'product_not_found',
    'submission_created',
    'product_viewed',
    'dashboard_viewed',
    'share_link_opened',
    'category_viewed',
    'preferences_updated',
    'onboarding_completed',
    'image_search_performed',
    'offline_cache_cleared',
    'push_notification_enabled',
    'push_notification_disabled',
    'push_notification_denied',
    'push_notification_dismissed',
    'pwa_install_prompted',
    'pwa_install_accepted',
    'pwa_install_dismissed',
    'user_data_exported',
    'account_deleted'
  ));

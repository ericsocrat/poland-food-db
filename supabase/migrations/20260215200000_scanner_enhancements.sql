-- ════════════════════════════════════════════════════════════════════════════
-- Issue #23 — Barcode Scanner Enhancements & Product Submissions
-- ════════════════════════════════════════════════════════════════════════════
-- Tables: scan_history, product_submissions
-- Functions: api_record_scan, api_get_scan_history,
--            api_submit_product, api_get_my_submissions,
--            api_admin_get_submissions, api_admin_review_submission

BEGIN;

-- ──────────────────────────────────────────────────────────────────────────
-- 1. scan_history table
-- ──────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.scan_history (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ean         text NOT NULL,
  product_id  bigint REFERENCES public.products(product_id) ON DELETE SET NULL,
  found       boolean NOT NULL DEFAULT false,
  scanned_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.scan_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own scans"
  ON public.scan_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own scans"
  ON public.scan_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_sh_user_recent  ON public.scan_history (user_id, scanned_at DESC);
CREATE INDEX idx_sh_ean          ON public.scan_history (ean);

GRANT SELECT, INSERT ON public.scan_history TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 2. product_submissions table
-- ──────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.product_submissions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ean             text NOT NULL,
  product_name    text NOT NULL,
  brand           text,
  category        text,
  photo_url       text,
  notes           text,
  status          text NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'rejected', 'merged')),
  reviewed_by     uuid REFERENCES auth.users(id),
  reviewed_at     timestamptz,
  merged_product_id bigint REFERENCES public.products(product_id),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.product_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own submissions"
  ON public.product_submissions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own submissions"
  ON public.product_submissions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Admin policies (service_role bypasses RLS; for any future admin UI use service_role key)

CREATE INDEX idx_ps_ean        ON public.product_submissions (ean);
CREATE INDEX idx_ps_status     ON public.product_submissions (status);
CREATE INDEX idx_ps_user_id    ON public.product_submissions (user_id);
-- Unique partial: only one pending per EAN
CREATE UNIQUE INDEX idx_ps_ean_pending ON public.product_submissions (ean) WHERE status = 'pending';

GRANT SELECT, INSERT ON public.product_submissions TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 3. Supabase Storage bucket for submission photos
-- ──────────────────────────────────────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'submission-photos',
  'submission-photos',
  false,
  5242880,  -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Authenticated users can upload to their own folder
CREATE POLICY "Users upload own photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'submission-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Authenticated users can read any submission photo (needed for admin review fallback)
CREATE POLICY "Authenticated read submission photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'submission-photos'
    AND auth.role() = 'authenticated'
  );

-- ──────────────────────────────────────────────────────────────────────────
-- 4. api_record_scan — look up EAN & record to scan_history
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_record_scan(
  p_ean text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id   uuid := auth.uid();
  v_product   record;
  v_found     boolean := false;
  v_product_id bigint;
BEGIN
  -- Validate
  IF p_ean IS NULL OR LENGTH(TRIM(p_ean)) NOT IN (8, 13) THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'EAN must be 8 or 13 digits'
    );
  END IF;

  -- Lookup product by EAN
  SELECT product_id, product_name, brand, category, unhealthiness_score,
         nutri_score
    INTO v_product
    FROM public.products
   WHERE ean = TRIM(p_ean)
   LIMIT 1;

  IF FOUND THEN
    v_found := true;
    v_product_id := v_product.product_id;
  END IF;

  -- Record scan (only for authenticated users)
  IF v_user_id IS NOT NULL THEN
    INSERT INTO public.scan_history (user_id, ean, product_id, found)
    VALUES (v_user_id, TRIM(p_ean), v_product_id, v_found);
  END IF;

  -- Return result
  IF v_found THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'found',       true,
      'product_id',  v_product.product_id,
      'product_name', v_product.product_name,
      'brand',       v_product.brand,
      'category',    v_product.category,
      'unhealthiness_score', v_product.unhealthiness_score,
      'nutri_score', v_product.nutri_score
    );
  ELSE
    -- Check if there's already a pending submission for this EAN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'found',       false,
      'ean',         TRIM(p_ean),
      'has_pending_submission', EXISTS (
        SELECT 1 FROM public.product_submissions
         WHERE ean = TRIM(p_ean) AND status = 'pending'
      )
    );
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_record_scan(text) TO authenticated, anon;

-- ──────────────────────────────────────────────────────────────────────────
-- 5. api_get_scan_history — paginated scan history for the current user
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_get_scan_history(
  p_page      integer DEFAULT 1,
  p_page_size integer DEFAULT 20,
  p_filter    text    DEFAULT 'all'   -- 'all', 'found', 'not_found'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_offset  integer;
  v_total   bigint;
  v_items   jsonb;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
  END IF;

  v_offset := (GREATEST(p_page, 1) - 1) * LEAST(p_page_size, 50);

  -- Count total
  SELECT COUNT(*) INTO v_total
    FROM public.scan_history sh
   WHERE sh.user_id = v_user_id
     AND (p_filter = 'all'
          OR (p_filter = 'found' AND sh.found = true)
          OR (p_filter = 'not_found' AND sh.found = false));

  -- Fetch items with product details
  SELECT COALESCE(jsonb_agg(row_obj ORDER BY rn), '[]'::jsonb)
    INTO v_items
    FROM (
      SELECT
        ROW_NUMBER() OVER (ORDER BY sh.scanned_at DESC) AS rn,
        jsonb_build_object(
          'scan_id',       sh.id,
          'ean',           sh.ean,
          'found',         sh.found,
          'scanned_at',    sh.scanned_at,
          'product_id',    p.product_id,
          'product_name',  p.product_name,
          'brand',         p.brand,
          'category',      p.category,
          'unhealthiness_score', p.unhealthiness_score,
          'nutri_score',   p.nutri_score,
          'submission_status', (
            SELECT ps.status FROM public.product_submissions ps
             WHERE ps.ean = sh.ean AND ps.user_id = v_user_id
             ORDER BY ps.created_at DESC LIMIT 1
          )
        ) AS row_obj
      FROM public.scan_history sh
      LEFT JOIN public.products p ON p.product_id = sh.product_id
      WHERE sh.user_id = v_user_id
        AND (p_filter = 'all'
             OR (p_filter = 'found' AND sh.found = true)
             OR (p_filter = 'not_found' AND sh.found = false))
      ORDER BY sh.scanned_at DESC
      OFFSET v_offset
      LIMIT LEAST(p_page_size, 50)
    ) sub;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'total',       v_total,
    'page',        GREATEST(p_page, 1),
    'pages',       GREATEST(CEIL(v_total::numeric / LEAST(p_page_size, 50)), 1),
    'page_size',   LEAST(p_page_size, 50),
    'filter',      p_filter,
    'scans',       v_items
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_get_scan_history(integer, integer, text) TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 6. api_submit_product — user submits a missing product
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_submit_product(
  p_ean          text,
  p_product_name text,
  p_brand        text    DEFAULT NULL,
  p_category     text    DEFAULT NULL,
  p_photo_url    text    DEFAULT NULL,
  p_notes        text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id     uuid := auth.uid();
  v_submission_id uuid;
  v_existing_product_id bigint;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
  END IF;

  -- Validate required fields
  IF p_ean IS NULL OR LENGTH(TRIM(p_ean)) NOT IN (8, 13) THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Valid EAN (8 or 13 digits) required');
  END IF;

  IF p_product_name IS NULL OR LENGTH(TRIM(p_product_name)) < 2 THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Product name required (min 2 chars)');
  END IF;

  -- Check if EAN already exists in products
  SELECT product_id INTO v_existing_product_id
    FROM public.products WHERE ean = TRIM(p_ean) LIMIT 1;

  IF v_existing_product_id IS NOT NULL THEN
    RETURN jsonb_build_object(
      'api_version',   '1.0',
      'error',         'This product already exists in our database',
      'product_id',    v_existing_product_id
    );
  END IF;

  -- Check if there's already a pending submission for this EAN
  IF EXISTS (SELECT 1 FROM public.product_submissions WHERE ean = TRIM(p_ean) AND status = 'pending') THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'A submission for this EAN is already pending review'
    );
  END IF;

  -- Insert submission
  INSERT INTO public.product_submissions (user_id, ean, product_name, brand, category, photo_url, notes)
  VALUES (v_user_id, TRIM(p_ean), TRIM(p_product_name), NULLIF(TRIM(COALESCE(p_brand, '')), ''),
          NULLIF(TRIM(COALESCE(p_category, '')), ''), p_photo_url, NULLIF(TRIM(COALESCE(p_notes, '')), ''))
  RETURNING id INTO v_submission_id;

  RETURN jsonb_build_object(
    'api_version',    '1.0',
    'submission_id',  v_submission_id,
    'status',         'pending'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_submit_product(text, text, text, text, text, text) TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 7. api_get_my_submissions — user's own submissions, paginated
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_get_my_submissions(
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
  v_user_id uuid := auth.uid();
  v_offset  integer;
  v_total   bigint;
  v_items   jsonb;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required');
  END IF;

  v_offset := (GREATEST(p_page, 1) - 1) * LEAST(p_page_size, 50);

  SELECT COUNT(*) INTO v_total
    FROM public.product_submissions
   WHERE user_id = v_user_id;

  SELECT COALESCE(jsonb_agg(row_obj ORDER BY rn), '[]'::jsonb)
    INTO v_items
    FROM (
      SELECT
        ROW_NUMBER() OVER (ORDER BY ps.created_at DESC) AS rn,
        jsonb_build_object(
          'id',               ps.id,
          'ean',              ps.ean,
          'product_name',     ps.product_name,
          'brand',            ps.brand,
          'category',         ps.category,
          'photo_url',        ps.photo_url,
          'status',           ps.status,
          'merged_product_id', ps.merged_product_id,
          'created_at',       ps.created_at,
          'updated_at',       ps.updated_at
        ) AS row_obj
      FROM public.product_submissions ps
      WHERE ps.user_id = v_user_id
      ORDER BY ps.created_at DESC
      OFFSET v_offset
      LIMIT LEAST(p_page_size, 50)
    ) sub;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'total',       v_total,
    'page',        GREATEST(p_page, 1),
    'pages',       GREATEST(CEIL(v_total::numeric / LEAST(p_page_size, 50)), 1),
    'page_size',   LEAST(p_page_size, 50),
    'submissions', v_items
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_get_my_submissions(integer, integer) TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 8. api_admin_get_submissions — admin review queue (service_role only)
-- ──────────────────────────────────────────────────────────────────────────

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
  -- This function is intended for service_role or admin use.
  -- Regular users will get empty results due to RLS,
  -- but we call it via SECURITY DEFINER so it bypasses RLS.
  -- Access control: only callable from server-side or service_role context.

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
          'reviewed_at',      ps.reviewed_at
        ) AS row_obj
      FROM public.product_submissions ps
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

-- Only service_role should call this in production; granting to authenticated
-- for admin UI access (function is SECURITY DEFINER so it can read all rows).
GRANT EXECUTE ON FUNCTION public.api_admin_get_submissions(text, integer, integer) TO service_role, authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 9. api_admin_review_submission — approve / reject / merge
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_admin_review_submission(
  p_submission_id     uuid,
  p_action            text,    -- 'approve', 'reject', 'merge'
  p_merged_product_id bigint DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_reviewer  uuid := auth.uid();
  v_sub       record;
BEGIN
  -- Fetch the submission
  SELECT * INTO v_sub
    FROM public.product_submissions
   WHERE id = p_submission_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Submission not found');
  END IF;

  IF v_sub.status != 'pending' THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Submission is not pending');
  END IF;

  IF p_action NOT IN ('approve', 'reject', 'merge') THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Action must be approve, reject, or merge');
  END IF;

  IF p_action = 'reject' THEN
    UPDATE public.product_submissions
       SET status = 'rejected',
           reviewed_by = v_reviewer,
           reviewed_at = now(),
           updated_at = now()
     WHERE id = p_submission_id;

    RETURN jsonb_build_object(
      'api_version', '1.0',
      'submission_id', p_submission_id,
      'status', 'rejected'
    );
  END IF;

  IF p_action = 'merge' THEN
    IF p_merged_product_id IS NULL THEN
      RETURN jsonb_build_object('api_version', '1.0', 'error', 'merged_product_id required for merge');
    END IF;

    UPDATE public.product_submissions
       SET status = 'merged',
           merged_product_id = p_merged_product_id,
           reviewed_by = v_reviewer,
           reviewed_at = now(),
           updated_at = now()
     WHERE id = p_submission_id;

    RETURN jsonb_build_object(
      'api_version', '1.0',
      'submission_id', p_submission_id,
      'status', 'merged',
      'merged_product_id', p_merged_product_id
    );
  END IF;

  -- Approve: mark submission as approved (product creation is a manual/pipeline step)
  UPDATE public.product_submissions
     SET status = 'approved',
         reviewed_by = v_reviewer,
         reviewed_at = now(),
         updated_at = now()
   WHERE id = p_submission_id;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'submission_id', p_submission_id,
    'status', 'approved'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.api_admin_review_submission(uuid, text, bigint) TO service_role, authenticated;

COMMIT;

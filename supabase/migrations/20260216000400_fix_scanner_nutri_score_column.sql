-- Fix: api_record_scan and api_get_scan_history reference non-existent
-- column "nutri_score" on products table.  The actual column name is
-- "nutri_score_label" (added in 20260212000100_consolidate_schema).
-- The JSON key stays 'nutri_score' so the frontend contract is unchanged.
-- ──────────────────────────────────────────────────────────────────────────

-- 1. Fix api_record_scan
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
         nutri_score_label
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
      'nutri_score', v_product.nutri_score_label
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

-- 2. Fix api_get_scan_history
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
          'nutri_score',   p.nutri_score_label,
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

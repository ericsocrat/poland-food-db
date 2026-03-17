-- Migration: feat(scanner): country-scoped pending submission uniqueness (#930)
-- Part of epic #920 — scanner country awareness
-- Depends on: #922 (suggested_country column), #923 (country-aware api_submit_product)
--
-- Changes:
--   1. Replace global idx_ps_ean_pending with country-scoped idx_ps_ean_country_pending
--   2. Update api_submit_product pending check to be country-scoped
--   3. Update api_record_scan has_pending_submission to be country-scoped
--
-- Backward compatible: NULL suggested_country falls back to global check
-- Rollback: DROP INDEX IF EXISTS idx_ps_ean_country_pending;
--           CREATE UNIQUE INDEX idx_ps_ean_pending ON product_submissions(ean) WHERE status = 'pending';
--           Then re-create previous api_submit_product and api_record_scan from 20260320000300.

-- ════════════════════════════════════════════════════════════════════════════
-- Step 1: Replace global unique index with country-scoped
-- ════════════════════════════════════════════════════════════════════════════

-- Drop global unique partial index (one pending per EAN globally)
DROP INDEX IF EXISTS idx_ps_ean_pending;

-- Create country-scoped unique partial index (one pending per EAN per country)
-- NULL suggested_country values are excluded from uniqueness (NULL ≠ NULL),
-- so legacy rows without country still insert fine.
CREATE UNIQUE INDEX idx_ps_ean_country_pending
  ON public.product_submissions(ean, suggested_country)
  WHERE status = 'pending';


-- ════════════════════════════════════════════════════════════════════════════
-- Step 2: Update api_submit_product — country-scoped pending check
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_submit_product(
  p_ean              text,
  p_product_name     text,
  p_brand            text DEFAULT NULL,
  p_category         text DEFAULT NULL,
  p_photo_url        text DEFAULT NULL,
  p_notes            text DEFAULT NULL,
  p_scan_country     text DEFAULT NULL,
  p_suggested_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid               uuid;
  v_ean               text;
  v_existing          uuid;
  v_result            jsonb;
  v_rate_check        jsonb;
  v_scan_country      text;
  v_suggested_country text;
BEGIN
  -- Auth check
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'Authentication required'
    );
  END IF;

  -- Rate limit check (before any processing)
  v_rate_check := check_submission_rate_limit(v_uid);
  IF NOT (v_rate_check->>'allowed')::boolean THEN
    RETURN jsonb_build_object(
      'api_version',         '1.0',
      'error',               'rate_limit_exceeded',
      'message',             'Too many submissions. Please try again later.',
      'retry_after_seconds', (v_rate_check->>'retry_after_seconds')::integer,
      'current_count',       (v_rate_check->>'current_count')::integer,
      'max_allowed',         (v_rate_check->>'max_allowed')::integer
    );
  END IF;

  -- Trim EAN
  v_ean := TRIM(COALESCE(p_ean, ''));

  -- Validate EAN (checksum + format)
  IF NOT is_valid_ean(v_ean) THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'Invalid EAN — must be a valid EAN-8 or EAN-13 barcode with correct checksum'
    );
  END IF;

  -- Check product_name required
  IF p_product_name IS NULL OR TRIM(p_product_name) = '' THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'Product name is required'
    );
  END IF;

  -- Check if EAN already exists in products
  IF EXISTS (SELECT 1 FROM products WHERE ean = v_ean AND is_deprecated IS NOT TRUE) THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'Product with this EAN already exists in database'
    );
  END IF;

  -- Resolve scan_country: explicit param → user_preferences → NULL
  v_scan_country := p_scan_country;
  IF v_scan_country IS NULL THEN
    SELECT up.country INTO v_scan_country
    FROM public.user_preferences up
    WHERE up.user_id = v_uid;
  END IF;

  -- Resolve suggested_country: explicit param → scan_country → NULL
  v_suggested_country := COALESCE(p_suggested_country, v_scan_country);

  -- Check if EAN already has a pending submission (country-scoped when possible)
  IF v_suggested_country IS NOT NULL THEN
    -- Country known: check for pending in same country only
    SELECT id INTO v_existing
    FROM product_submissions
    WHERE ean = v_ean
      AND suggested_country = v_suggested_country
      AND status = 'pending'
    LIMIT 1;
  ELSE
    -- Country unknown: fall back to global check (safe default)
    SELECT id INTO v_existing
    FROM product_submissions
    WHERE ean = v_ean AND status = 'pending'
    LIMIT 1;
  END IF;

  IF v_existing IS NOT NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'A submission for this EAN is already pending review'
    );
  END IF;

  -- Insert submission
  INSERT INTO product_submissions (
    user_id, ean, product_name, brand, category, photo_url, notes,
    scan_country, suggested_country
  )
  VALUES (
    v_uid, v_ean, TRIM(p_product_name), NULLIF(TRIM(p_brand), ''),
    NULLIF(TRIM(p_category), ''), NULLIF(TRIM(p_photo_url), ''),
    NULLIF(TRIM(p_notes), ''),
    v_scan_country, v_suggested_country
  )
  RETURNING jsonb_build_object(
    'api_version',        '1.0',
    'submission_id',      id::text,
    'ean',                ean,
    'product_name',       product_name,
    'status',             status,
    'scan_country',       scan_country,
    'suggested_country',  suggested_country
  ) INTO v_result;

  RETURN v_result;
END;
$$;


-- ════════════════════════════════════════════════════════════════════════════
-- Step 3: Update api_record_scan — country-scoped has_pending_submission
-- ════════════════════════════════════════════════════════════════════════════
-- When product not found, the has_pending_submission flag should only consider
-- pending submissions for the user's country (not submissions for other countries).

CREATE OR REPLACE FUNCTION public.api_record_scan(
  p_ean          text,
  p_scan_country text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id       uuid := auth.uid();
  v_product       record;
  v_found         boolean := false;
  v_product_id    bigint;
  v_language      text;
  v_country_lang  text;
  v_cat_display   text;
  v_cat_icon      text;
  v_rate_check    jsonb;
  v_scan_country  text;
BEGIN
  -- Validate EAN format
  IF p_ean IS NULL OR LENGTH(TRIM(p_ean)) NOT IN (8, 13) THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'EAN must be 8 or 13 digits'
    );
  END IF;

  -- Rate limit check (only for authenticated users who will write)
  IF v_user_id IS NOT NULL THEN
    v_rate_check := check_scan_rate_limit(v_user_id);
    IF NOT (v_rate_check->>'allowed')::boolean THEN
      RETURN jsonb_build_object(
        'api_version',         '1.0',
        'error',               'rate_limit_exceeded',
        'message',             'Too many scans. Please try again later.',
        'retry_after_seconds', (v_rate_check->>'retry_after_seconds')::integer,
        'current_count',       (v_rate_check->>'current_count')::integer,
        'max_allowed',         (v_rate_check->>'max_allowed')::integer
      );
    END IF;
  END IF;

  -- Resolve scan_country: explicit param → user_preferences → NULL
  v_scan_country := p_scan_country;
  IF v_scan_country IS NULL AND v_user_id IS NOT NULL THEN
    SELECT up.country INTO v_scan_country
    FROM public.user_preferences up
    WHERE up.user_id = v_user_id;
  END IF;

  -- Resolve user language
  v_language := resolve_language(NULL);

  -- Lookup product by EAN (now includes name_translations)
  SELECT p.product_id, p.product_name, p.product_name_en, p.name_translations,
         p.brand, p.category, p.country, p.unhealthiness_score, p.nutri_score_label
    INTO v_product
    FROM public.products p
   WHERE p.ean = TRIM(p_ean)
   LIMIT 1;

  IF FOUND THEN
    v_found := true;
    v_product_id := v_product.product_id;

    -- Resolve country default language
    SELECT cref.default_language INTO v_country_lang
    FROM public.country_ref cref
    WHERE cref.country_code = v_product.country;
    v_country_lang := COALESCE(v_country_lang, LOWER(v_product.country));

    -- Resolve category display + icon
    SELECT COALESCE(ct.display_name, cr.display_name),
           COALESCE(cr.icon_emoji, '📦')
    INTO v_cat_display, v_cat_icon
    FROM public.category_ref cr
    LEFT JOIN public.category_translations ct
        ON ct.category = cr.category AND ct.language_code = v_language
    WHERE cr.category = v_product.category;
  END IF;

  -- Record scan (only for authenticated users)
  IF v_user_id IS NOT NULL THEN
    INSERT INTO public.scan_history (user_id, ean, product_id, found, scan_country)
    VALUES (v_user_id, TRIM(p_ean), v_product_id, v_found, v_scan_country);
  END IF;

  -- Return result
  IF v_found THEN
    RETURN jsonb_build_object(
      'api_version',    '1.0',
      'found',          true,
      'product_id',     v_product.product_id,
      'product_name',   v_product.product_name,
      'product_name_en', v_product.product_name_en,
      'product_name_display', CASE
          WHEN v_language = v_country_lang THEN v_product.product_name
          WHEN v_language = 'en' THEN COALESCE(v_product.product_name_en, v_product.product_name)
          ELSE COALESCE(
              v_product.name_translations->>v_language,
              v_product.product_name_en,
              v_product.product_name
          )
      END,
      'brand',              v_product.brand,
      'category',           v_product.category,
      'category_display',   v_cat_display,
      'category_icon',      v_cat_icon,
      'unhealthiness_score', v_product.unhealthiness_score,
      'nutri_score',        v_product.nutri_score_label,
      'scan_country',       v_scan_country,
      'product_country',    v_product.country
    );
  ELSE
    -- Country-scoped has_pending_submission check
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'found',       false,
      'ean',         TRIM(p_ean),
      'has_pending_submission', CASE
        WHEN v_scan_country IS NOT NULL THEN EXISTS (
          SELECT 1 FROM public.product_submissions
           WHERE ean = TRIM(p_ean)
             AND suggested_country = v_scan_country
             AND status = 'pending'
        )
        ELSE EXISTS (
          SELECT 1 FROM public.product_submissions
           WHERE ean = TRIM(p_ean) AND status = 'pending'
        )
      END,
      'scan_country', v_scan_country
    );
  END IF;
END;
$$;

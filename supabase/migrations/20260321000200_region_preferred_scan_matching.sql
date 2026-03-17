-- Migration: feat(scanner): region-preferred product matching in api_record_scan (#926)
-- Part of epic #920 — scanner country awareness (Phase 2: Smart Lookup)
-- Depends on: 20260320000300 (country-aware api_record_scan with p_scan_country)
--
-- Changes:
--   api_record_scan:
--     1. EAN lookup now prefers same-region matches via ORDER BY
--     2. Excludes deprecated products from lookup
--     3. Response includes is_cross_country boolean
--   Fix: drop stale 3-param overload of api_admin_get_submissions
--        and fix unqualified COMMENT from 20260321000100
--
-- Backward compatible: when v_scan_country is NULL, ORDER BY degrades to product_id only
-- Rollback: re-run previous version from 20260320000300_country_aware_scanner_rpcs.sql

-- ════════════════════════════════════════════════════════════════════════════
-- 0. Fix: drop stale 3-param overload of api_admin_get_submissions
--    The 4-param version (with p_country) supersedes it.
--    The unqualified COMMENT in 20260321000100 fails because both overloads exist.
-- ════════════════════════════════════════════════════════════════════════════
DROP FUNCTION IF EXISTS public.api_admin_get_submissions(text, integer, integer);

-- Re-apply the comment with fully-qualified signature
COMMENT ON FUNCTION public.api_admin_get_submissions(text, integer, integer, text) IS
  'Purpose: List product submissions with trust enrichment and country context
   Auth: authenticated (SECURITY DEFINER)
   Params: p_status (default pending), p_page (default 1), p_page_size (default 20, max 50), p_country (optional country filter)
   Returns: JSONB {api_version, total, page, pages, page_size, status_filter, country_filter, submissions: [...]}
   Country filter: matches scan_country OR suggested_country
   Backward compatible: new p_country param defaults to NULL (no filter)';

-- ════════════════════════════════════════════════════════════════════════════
-- 1. api_record_scan — region-preferred matching + is_cross_country (#926)
-- ════════════════════════════════════════════════════════════════════════════

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

  -- Lookup product by EAN — prefer same-region match (#926)
  -- When v_scan_country IS NULL, (p.country = NULL) evaluates to NULL (FALSE),
  -- so ORDER BY degrades to product_id only — stable backward compat.
  SELECT p.product_id, p.product_name, p.product_name_en, p.name_translations,
         p.brand, p.category, p.country, p.unhealthiness_score, p.nutri_score_label
    INTO v_product
    FROM public.products p
   WHERE p.ean = TRIM(p_ean)
     AND p.is_deprecated IS NOT TRUE
   ORDER BY (p.country = v_scan_country) DESC,
            p.product_id
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
      'product_country',    v_product.country,
      'is_cross_country',   (v_product.country IS DISTINCT FROM v_scan_country
                             AND v_scan_country IS NOT NULL)
    );
  ELSE
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'found',       false,
      'ean',         TRIM(p_ean),
      'has_pending_submission', EXISTS (
        SELECT 1 FROM public.product_submissions
         WHERE ean = TRIM(p_ean) AND status = 'pending'
      ),
      'scan_country', v_scan_country
    );
  END IF;
END;
$$;

COMMENT ON FUNCTION public.api_record_scan(text, text) IS
  'Record a barcode scan and lookup product. Prefers same-region match when EAN exists in multiple countries. Returns is_cross_country when matched product differs from scan region. Enforces 100/24h rate limit per user.';

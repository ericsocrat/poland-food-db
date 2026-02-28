-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ EAN Checksum Validation on Product Submissions — Issue #465             ║
-- ║                                                                          ║
-- ║ 1. is_valid_ean(text) — IMMUTABLE checksum validator (EAN-8 / EAN-13)   ║
-- ║ 2. review_notes column on product_submissions                            ║
-- ║ 3. Trigger: auto-reject invalid EANs on product_submissions INSERT      ║
-- ║ 4. Update api_submit_product() — fail fast on invalid EAN               ║
-- ║                                                                          ║
-- ║ To roll back:                                                            ║
-- ║   DROP TRIGGER IF EXISTS trg_submission_ean_check ON product_submissions;║
-- ║   DROP FUNCTION IF EXISTS trig_validate_submission_ean();                ║
-- ║   DROP FUNCTION IF EXISTS is_valid_ean(text);                            ║
-- ║   ALTER TABLE product_submissions DROP COLUMN IF EXISTS review_notes;    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════════════════
-- 1. is_valid_ean(text) — EAN-8 / EAN-13 checksum validator
--    Ported from validate_eans.py, matching GS1 checksum algorithm exactly.
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.is_valid_ean(p_ean text)
RETURNS boolean
LANGUAGE plpgsql IMMUTABLE STRICT
AS $$
DECLARE
  v_len    integer;
  v_sum    integer := 0;
  v_digit  integer;
  v_weight integer;
  i        integer;
BEGIN
  -- STRICT means NULL input → NULL return (not false)

  -- Must be non-empty
  IF p_ean = '' THEN
    RETURN false;
  END IF;

  -- Must be digits only
  IF p_ean !~ '^\d+$' THEN
    RETURN false;
  END IF;

  v_len := length(p_ean);

  -- Must be EAN-8 or EAN-13
  IF v_len NOT IN (8, 13) THEN
    RETURN false;
  END IF;

  -- GS1 checksum algorithm
  -- EAN-13: weights alternate 1, 3, 1, 3, ... (positions 1-based)
  -- EAN-8:  weights alternate 3, 1, 3, 1, ... (positions 1-based)
  FOR i IN 1..v_len LOOP
    v_digit := substring(p_ean FROM i FOR 1)::integer;
    IF v_len = 13 THEN
      v_weight := CASE WHEN i % 2 = 1 THEN 1 ELSE 3 END;
    ELSE -- EAN-8
      v_weight := CASE WHEN i % 2 = 1 THEN 3 ELSE 1 END;
    END IF;
    v_sum := v_sum + (v_digit * v_weight);
  END LOOP;

  RETURN v_sum % 10 = 0;
END;
$$;

COMMENT ON FUNCTION public.is_valid_ean(text) IS
  'Validates EAN-8/EAN-13 barcodes using GS1 checksum algorithm. IMMUTABLE STRICT — returns NULL for NULL input, false for invalid.';

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Add review_notes column to product_submissions
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.product_submissions
  ADD COLUMN IF NOT EXISTS review_notes text;

COMMENT ON COLUMN public.product_submissions.review_notes IS
  'Reviewer or system notes (e.g., auto-rejection reason for invalid EAN)';

-- ════════════════════════════════════════════════════════════════════════════
-- 3. Trigger: auto-reject invalid EANs on product_submissions
--    - NULL EAN → allowed (user might not have barcode)
--    - Valid EAN → passes through unchanged
--    - Invalid EAN → status='rejected', review_notes set
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.trig_validate_submission_ean()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  -- Allow NULL EAN (user might not have the barcode)
  IF NEW.ean IS NOT NULL THEN
    -- Strip whitespace
    NEW.ean := trim(NEW.ean);

    -- Validate checksum
    IF NOT is_valid_ean(NEW.ean) THEN
      NEW.status := 'rejected';
      NEW.review_notes := 'Auto-rejected: invalid EAN checksum (not a valid EAN-8 or EAN-13 barcode)';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trig_validate_submission_ean() IS
  'Trigger function: auto-rejects product submissions with invalid EAN checksums.';

-- Drop if exists (idempotent)
DROP TRIGGER IF EXISTS trg_submission_ean_check ON public.product_submissions;

CREATE TRIGGER trg_submission_ean_check
  BEFORE INSERT OR UPDATE ON public.product_submissions
  FOR EACH ROW
  EXECUTE FUNCTION public.trig_validate_submission_ean();

-- ════════════════════════════════════════════════════════════════════════════
-- 4. Update api_submit_product() — fail fast on invalid EAN checksum
--    Replace basic length check with is_valid_ean() call.
-- ════════════════════════════════════════════════════════════════════════════

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
  v_uid      uuid;
  v_ean      text;
  v_existing uuid;
  v_result   jsonb;
BEGIN
  -- Auth check
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'Authentication required'
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

  -- Check if EAN already has a pending submission
  SELECT id INTO v_existing
  FROM product_submissions
  WHERE ean = v_ean AND status = 'pending'
  LIMIT 1;

  IF v_existing IS NOT NULL THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'error',       'A submission for this EAN is already pending review'
    );
  END IF;

  -- Insert submission
  INSERT INTO product_submissions (user_id, ean, product_name, brand, category, photo_url, notes)
  VALUES (v_uid, v_ean, TRIM(p_product_name), NULLIF(TRIM(p_brand), ''),
          NULLIF(TRIM(p_category), ''), NULLIF(TRIM(p_photo_url), ''),
          NULLIF(TRIM(p_notes), ''))
  RETURNING jsonb_build_object(
    'api_version', '1.0',
    'submission_id', id::text,
    'ean',           ean,
    'product_name',  product_name,
    'status',        status
  ) INTO v_result;

  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.api_submit_product(text, text, text, text, text, text) IS
  'Submit a new product for review. Validates EAN-8/EAN-13 checksum before accepting.';

REVOKE ALL ON FUNCTION public.api_submit_product(text, text, text, text, text, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.api_submit_product(text, text, text, text, text, text) TO authenticated;

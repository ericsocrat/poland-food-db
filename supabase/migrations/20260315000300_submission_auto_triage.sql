-- ============================================================================
-- Migration: 20260315000300_submission_auto_triage.sql
-- Purpose:   Submission auto-triage trigger with quality scoring
-- Closes:    #468
--
-- Objects:
--   _score_submission_quality(uuid,text,text,text,text) — internal helper
--   score_submission_quality(uuid) — admin scoring function
--   trig_auto_triage_submission() — trigger function
--   trg_submission_quality_triage — BEFORE INSERT trigger
--
-- Trigger ordering:
--   trg_submission_ean_check    → fires first (EAN validation)
--   trg_submission_quality_triage → fires second (quality scoring)
--   PostgreSQL fires BEFORE INSERT triggers alphabetically: ean < quality ✓
--
-- Rollback:
--   DROP TRIGGER IF EXISTS trg_submission_quality_triage ON product_submissions;
--   DROP FUNCTION IF EXISTS trig_auto_triage_submission();
--   DROP FUNCTION IF EXISTS score_submission_quality(uuid);
--   DROP FUNCTION IF EXISTS _score_submission_quality(uuid,text,text,text,text);
-- ============================================================================

-- ─── 1. Internal scoring helper ─────────────────────────────────────────────
-- Scores a submission's quality (0-100) from 6 signals.
-- Starting score: 50 (neutral). Higher = more trustworthy.
--
-- Signal 1: Account age          → -20 (<24h) or -10 (<7d)
-- Signal 2: Submission velocity  → -30 (>=5/h) or -15 (>=3/h)
-- Signal 3: EAN matches product  → +30
-- Signal 4: Has photo            → +10
-- Signal 5: Brand name quality   → -25 (suspicious)
-- Signal 6: Product name quality → -25 (suspicious)
--
-- Thresholds:
--   <20  → auto_reject
--   <40  → flag_for_review
--   >=80 AND EAN exists → auto_resolve_existing
--   else → manual_review

CREATE OR REPLACE FUNCTION _score_submission_quality(
  p_user_id      uuid,
  p_ean          text,
  p_brand        text,
  p_product_name text,
  p_photo_url    text
)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_score        integer := 50;
  v_signals      jsonb := '[]'::jsonb;
  v_account_age  interval;
  v_hourly_count integer;
  v_existing_pid bigint;
BEGIN
  -- ── Signal 1: Account age ──────────────────────────────────────────────
  IF p_user_id IS NOT NULL THEN
    SELECT (now() - created_at) INTO v_account_age
    FROM auth.users WHERE id = p_user_id;

    IF v_account_age IS NOT NULL THEN
      IF v_account_age < interval '24 hours' THEN
        v_score := v_score - 20;
        v_signals := v_signals || jsonb_build_array(
          jsonb_build_object('signal', 'new_account', 'impact', -20,
            'detail', 'Account created less than 24 hours ago')
        );
      ELSIF v_account_age < interval '7 days' THEN
        v_score := v_score - 10;
        v_signals := v_signals || jsonb_build_array(
          jsonb_build_object('signal', 'young_account', 'impact', -10,
            'detail', 'Account less than 7 days old')
        );
      END IF;
    END IF;
  END IF;

  -- ── Signal 2: Submission velocity (hourly burst) ───────────────────────
  IF p_user_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_hourly_count
    FROM product_submissions
    WHERE user_id = p_user_id
      AND created_at > now() - interval '1 hour';

    IF v_hourly_count >= 5 THEN
      v_score := v_score - 30;
      v_signals := v_signals || jsonb_build_array(
        jsonb_build_object('signal', 'high_velocity', 'impact', -30,
          'detail', format('%s submissions in last hour', v_hourly_count))
      );
    ELSIF v_hourly_count >= 3 THEN
      v_score := v_score - 15;
      v_signals := v_signals || jsonb_build_array(
        jsonb_build_object('signal', 'elevated_velocity', 'impact', -15,
          'detail', format('%s submissions in last hour', v_hourly_count))
      );
    END IF;
  END IF;

  -- ── Signal 3: EAN matches existing product ────────────────────────────
  IF p_ean IS NOT NULL THEN
    SELECT product_id INTO v_existing_pid
    FROM products
    WHERE ean = p_ean AND is_deprecated IS NOT TRUE;

    IF v_existing_pid IS NOT NULL THEN
      v_score := v_score + 30;
      v_signals := v_signals || jsonb_build_array(
        jsonb_build_object('signal', 'ean_exists', 'impact', 30,
          'detail', format('Matches product_id %s', v_existing_pid))
      );
    END IF;
  END IF;

  -- ── Signal 4: Has photo ───────────────────────────────────────────────
  IF p_photo_url IS NOT NULL AND p_photo_url <> '' THEN
    v_score := v_score + 10;
    v_signals := v_signals || jsonb_build_array(
      jsonb_build_object('signal', 'has_photo', 'impact', 10,
        'detail', 'Photo attached')
    );
  END IF;

  -- ── Signal 5: Brand name quality ──────────────────────────────────────
  IF p_brand IS NOT NULL AND (
    length(p_brand) < 2 OR
    p_brand ~ '[<>{}();]' OR
    p_brand ~ '^\d+$'
  ) THEN
    v_score := v_score - 25;
    v_signals := v_signals || jsonb_build_array(
      jsonb_build_object('signal', 'suspicious_brand', 'impact', -25,
        'detail', 'Brand name contains suspicious characters or is too short')
    );
  END IF;

  -- ── Signal 6: Product name quality ────────────────────────────────────
  IF p_product_name IS NOT NULL AND (
    length(p_product_name) < 3 OR
    p_product_name ~ '[<>{}();]'
  ) THEN
    v_score := v_score - 25;
    v_signals := v_signals || jsonb_build_array(
      jsonb_build_object('signal', 'suspicious_product_name', 'impact', -25,
        'detail', 'Product name contains suspicious characters or is too short')
    );
  END IF;

  -- Clamp to 0-100
  v_score := GREATEST(0, LEAST(100, v_score));

  RETURN jsonb_build_object(
    'quality_score', v_score,
    'signals', v_signals,
    'recommended_action', CASE
      WHEN v_score < 20 THEN 'auto_reject'
      WHEN v_score < 40 THEN 'flag_for_review'
      WHEN v_score >= 80 AND v_existing_pid IS NOT NULL THEN 'auto_resolve_existing'
      ELSE 'manual_review'
    END
  );
END;
$$;

REVOKE ALL ON FUNCTION _score_submission_quality(uuid,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _score_submission_quality(uuid,text,text,text,text) TO service_role;


-- ─── 2. Public admin scoring function ───────────────────────────────────────
-- Wraps the internal helper for admin use on existing submissions.

CREATE OR REPLACE FUNCTION score_submission_quality(p_id uuid)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_sub record;
BEGIN
  SELECT * INTO v_sub FROM product_submissions WHERE id = p_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('error', 'submission_not_found');
  END IF;

  RETURN _score_submission_quality(
    v_sub.user_id, v_sub.ean, v_sub.brand, v_sub.product_name, v_sub.photo_url
  ) || jsonb_build_object('submission_id', p_id);
END;
$$;

REVOKE ALL ON FUNCTION score_submission_quality(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION score_submission_quality(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION score_submission_quality(uuid) TO authenticated;


-- ─── 3. Trigger function ────────────────────────────────────────────────────
-- Auto-triages incoming submissions based on quality score.
-- Skips if the EAN validation trigger already rejected the row.

CREATE OR REPLACE FUNCTION trig_auto_triage_submission()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_quality jsonb;
  v_action  text;
BEGIN
  -- Skip if already processed (e.g., by EAN validation trigger)
  IF NEW.status <> 'pending' THEN
    RETURN NEW;
  END IF;

  -- Score the submission using the internal helper
  v_quality := _score_submission_quality(
    NEW.user_id, NEW.ean, NEW.brand, NEW.product_name, NEW.photo_url
  );
  v_action := v_quality->>'recommended_action';

  -- Apply triage decision
  CASE v_action
    WHEN 'auto_reject' THEN
      NEW.status := 'rejected';
      NEW.review_notes := format(
        'Auto-rejected: quality score %s/100. Signals: %s',
        v_quality->>'quality_score', v_quality->'signals'
      );
    WHEN 'auto_resolve_existing' THEN
      NEW.status := 'rejected';
      NEW.review_notes := format(
        'Auto-resolved: product already exists in database. Quality score: %s/100',
        v_quality->>'quality_score'
      );
    WHEN 'flag_for_review' THEN
      NEW.review_notes := format(
        'Flagged: quality score %s/100. Signals: %s',
        v_quality->>'quality_score', v_quality->'signals'
      );
    ELSE
      NULL; -- manual_review: leave as pending, no auto-notes
  END CASE;

  RETURN NEW;
END;
$$;


-- ─── 4. Create trigger (idempotent) ─────────────────────────────────────────
-- Name sorts alphabetically AFTER trg_submission_ean_check (ean < quality)
-- so EAN validation runs first.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_submission_quality_triage'
      AND tgrelid = 'product_submissions'::regclass
  ) THEN
    CREATE TRIGGER trg_submission_quality_triage
      BEFORE INSERT ON product_submissions
      FOR EACH ROW
      EXECUTE FUNCTION trig_auto_triage_submission();
  END IF;
END;
$$;

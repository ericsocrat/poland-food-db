-- Migration: Country-aware submission quality scoring (Signal 3)
-- Issue: #931 — feat(scanner): country-aware submission quality scoring
-- Rollback: Re-deploy _score_submission_quality from 20260315000500,
--           score_submission_quality from 20260315000300,
--           trig_auto_triage_submission from 20260315000300.
--
-- Changes:
--   1. _score_submission_quality gains p_suggested_country text DEFAULT NULL
--      Signal 3 scoring:
--        same-country EAN match → +15
--        cross-country EAN match → +5
--        unknown globally       → +0
--        NULL country fallback  → global check (+15/+0)
--   2. score_submission_quality(uuid) passes suggested_country from submission
--   3. trig_auto_triage_submission() passes NEW.suggested_country

-- ─── 1. Redeploy _score_submission_quality with country-aware Signal 3 ──────

-- Drop old 5-param overload so 5-arg calls route to the new 6-param version
-- (which has DEFAULT NULL on the 6th param).
DROP FUNCTION IF EXISTS _score_submission_quality(uuid, text, text, text, text);

CREATE OR REPLACE FUNCTION _score_submission_quality(
    p_user_id            uuid,
    p_ean                text,
    p_brand              text,
    p_product_name       text,
    p_photo_url          text,
    p_suggested_country  text DEFAULT NULL
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
    v_trust        integer;
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

    -- ── Signal 3: EAN matches existing product (country-aware #931) ────────
    IF p_ean IS NOT NULL THEN
        IF p_suggested_country IS NOT NULL THEN
            -- Country-aware: check same-country first
            SELECT product_id INTO v_existing_pid
            FROM products
            WHERE ean = p_ean
              AND country = p_suggested_country
              AND is_deprecated IS NOT TRUE;

            IF v_existing_pid IS NOT NULL THEN
                -- Same-country match: full credit
                v_score := v_score + 15;
                v_signals := v_signals || jsonb_build_array(
                    jsonb_build_object('signal', 'ean_exists_same_country', 'impact', 15,
                        'detail', format('Matches product_id %s in %s', v_existing_pid, p_suggested_country))
                );
            ELSE
                -- Check cross-country (EAN exists in another country)
                IF EXISTS (
                    SELECT 1 FROM products
                    WHERE ean = p_ean AND is_deprecated IS NOT TRUE
                ) THEN
                    v_score := v_score + 5;
                    v_signals := v_signals || jsonb_build_array(
                        jsonb_build_object('signal', 'ean_exists_other_country', 'impact', 5,
                            'detail', format('EAN exists in another country but not in %s', p_suggested_country))
                    );
                    -- Do NOT set v_existing_pid — product doesn't exist in target country
                END IF;
            END IF;
        ELSE
            -- Fallback: no country specified, global check (original behavior)
            SELECT product_id INTO v_existing_pid
            FROM products
            WHERE ean = p_ean AND is_deprecated IS NOT TRUE;

            IF v_existing_pid IS NOT NULL THEN
                v_score := v_score + 15;
                v_signals := v_signals || jsonb_build_array(
                    jsonb_build_object('signal', 'ean_exists', 'impact', 15,
                        'detail', format('Matches product_id %s', v_existing_pid))
                );
            END IF;
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

    -- ── Signal 7: User trust score (#471) ─────────────────────────────────
    IF p_user_id IS NOT NULL THEN
        SELECT uts.trust_score INTO v_trust
        FROM user_trust_scores uts
        WHERE uts.user_id = p_user_id;

        v_trust := COALESCE(v_trust, 50);  -- New users default to 50

        IF v_trust >= 80 THEN
            v_score := v_score + 15;
            v_signals := v_signals || jsonb_build_array(
                jsonb_build_object('signal', 'trusted_contributor', 'impact', 15,
                    'detail', format('Trust score %s — trusted contributor bonus', v_trust))
            );
        ELSIF v_trust < 20 THEN
            v_score := v_score - 30;
            v_signals := v_signals || jsonb_build_array(
                jsonb_build_object('signal', 'low_trust', 'impact', -30,
                    'detail', format('Trust score %s — low trust penalty', v_trust))
            );
        ELSIF v_trust < 40 THEN
            v_score := v_score - 15;
            v_signals := v_signals || jsonb_build_array(
                jsonb_build_object('signal', 'below_avg_trust', 'impact', -15,
                    'detail', format('Trust score %s — below average trust', v_trust))
            );
        END IF;
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

COMMENT ON FUNCTION _score_submission_quality(uuid, text, text, text, text, text) IS
  'Internal: scores a product submission 0-100 from 7 signals.
   Signal 3 is country-aware (#931): +15 same-country, +5 cross-country, +0 unknown.
   Falls back to global check (+15/+0) when p_suggested_country IS NULL.
   Auth: service_role only (internal helper).';

REVOKE ALL ON FUNCTION _score_submission_quality(uuid, text, text, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _score_submission_quality(uuid, text, text, text, text, text) TO service_role;


-- ─── 2. Update admin scoring wrapper to pass suggested_country ──────────────

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
    v_sub.user_id, v_sub.ean, v_sub.brand, v_sub.product_name, v_sub.photo_url,
    v_sub.suggested_country
  ) || jsonb_build_object('submission_id', p_id);
END;
$$;

REVOKE ALL ON FUNCTION score_submission_quality(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION score_submission_quality(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION score_submission_quality(uuid) TO authenticated;


-- ─── 3. Update trigger to pass NEW.suggested_country ────────────────────────

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

  -- Score the submission using the internal helper (country-aware #931)
  v_quality := _score_submission_quality(
    NEW.user_id, NEW.ean, NEW.brand, NEW.product_name, NEW.photo_url,
    NEW.suggested_country
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

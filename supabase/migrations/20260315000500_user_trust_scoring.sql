-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260315000500_user_trust_scoring.sql
-- Ticket:    #471 — User trust scoring system for submission reputation
-- ═══════════════════════════════════════════════════════════════════════════
-- Per-user reputation tracking that auto-adjusts on submission outcomes.
--
-- Phase 1: user_trust_scores table + RLS
-- Phase 2: Auto-adjustment trigger on product_submissions
-- Phase 3: Integrate trust signal into _score_submission_quality
-- ═══════════════════════════════════════════════════════════════════════════
-- To roll back: DROP TABLE IF EXISTS user_trust_scores CASCADE;
--               DROP TRIGGER IF EXISTS trg_trust_score_adjustment ON product_submissions;
--               then redeploy _score_submission_quality from 20260315000300.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── Phase 1: User trust scores table ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.user_trust_scores (
    user_id                   uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    trust_score               integer     NOT NULL DEFAULT 50
        CONSTRAINT chk_trust_score_range CHECK (trust_score BETWEEN 0 AND 100),
    total_submissions         integer     NOT NULL DEFAULT 0
        CONSTRAINT chk_trust_total_nonneg CHECK (total_submissions >= 0),
    approved_submissions      integer     NOT NULL DEFAULT 0
        CONSTRAINT chk_trust_approved_nonneg CHECK (approved_submissions >= 0),
    rejected_submissions      integer     NOT NULL DEFAULT 0
        CONSTRAINT chk_trust_rejected_nonneg CHECK (rejected_submissions >= 0),
    auto_rejected_submissions integer     NOT NULL DEFAULT 0
        CONSTRAINT chk_trust_autorej_nonneg CHECK (auto_rejected_submissions >= 0),
    flagged_at                timestamptz,
    flag_reason               text,
    last_submission_at        timestamptz,
    created_at                timestamptz NOT NULL DEFAULT now(),
    updated_at                timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.user_trust_scores IS
    'Per-user trust/reputation tracking for product submissions. '
    'Score 0-100: starts at 50 (neutral). Auto-adjusts on submission outcomes. '
    'Invisible to users (RLS blocks all user access); admins use for prioritization.';

-- RLS: no direct user access, service_role only
ALTER TABLE public.user_trust_scores ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'trust_scores_service_only') THEN
        CREATE POLICY trust_scores_service_only
            ON user_trust_scores FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

GRANT ALL ON user_trust_scores TO service_role;
-- No grants to authenticated or anon — users cannot see trust scores


-- ─── Phase 2: Auto-adjustment trigger ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.trig_adjust_trust_score()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_delta integer := 0;
    v_is_insert boolean := (TG_OP = 'INSERT');
BEGIN
    -- ── INSERT: handle auto-rejections during submission creation ─────────
    IF v_is_insert THEN
        -- Initialize trust record for new submitters
        INSERT INTO user_trust_scores (user_id)
        VALUES (NEW.user_id)
        ON CONFLICT (user_id) DO NOTHING;

        IF NEW.status = 'auto_reject' THEN
            v_delta := -5;
            UPDATE user_trust_scores SET
                trust_score               = GREATEST(0, trust_score + v_delta),
                total_submissions         = total_submissions + 1,
                auto_rejected_submissions = auto_rejected_submissions + 1,
                last_submission_at        = now(),
                updated_at                = now()
            WHERE user_id = NEW.user_id;
        ELSE
            -- Track submission count even if no score change
            UPDATE user_trust_scores SET
                total_submissions  = total_submissions + 1,
                last_submission_at = now(),
                updated_at         = now()
            WHERE user_id = NEW.user_id;
        END IF;

        RETURN NEW;
    END IF;

    -- ── UPDATE: handle status changes (admin actions) ────────────────────
    IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
        RETURN NEW;  -- No status change — skip
    END IF;

    -- Initialize trust record if missing
    INSERT INTO user_trust_scores (user_id)
    VALUES (NEW.user_id)
    ON CONFLICT (user_id) DO NOTHING;

    -- Calculate delta based on new status
    v_delta := CASE NEW.status
        WHEN 'approved' THEN 5
        WHEN 'merged'   THEN 5     -- Merged into existing product = positive signal
        WHEN 'rejected' THEN -15   -- Manual rejection by admin
        ELSE 0
    END;

    IF v_delta <> 0 THEN
        UPDATE user_trust_scores SET
            trust_score          = GREATEST(0, LEAST(100, trust_score + v_delta)),
            approved_submissions = approved_submissions
                + CASE WHEN NEW.status IN ('approved', 'merged') THEN 1 ELSE 0 END,
            rejected_submissions = rejected_submissions
                + CASE WHEN NEW.status = 'rejected' THEN 1 ELSE 0 END,
            last_submission_at   = now(),
            updated_at           = now()
        WHERE user_id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trig_adjust_trust_score() IS
    'AFTER INSERT OR UPDATE trigger on product_submissions. '
    'Auto-adjusts user trust score: +5 approved/merged, -15 rejected, -5 auto_reject. '
    'Initializes trust record on first submission (ON CONFLICT DO NOTHING).';

-- Create trigger (idempotent)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'trg_trust_score_adjustment'
          AND tgrelid = 'public.product_submissions'::regclass
    ) THEN
        CREATE TRIGGER trg_trust_score_adjustment
            AFTER INSERT OR UPDATE ON product_submissions
            FOR EACH ROW
            EXECUTE FUNCTION trig_adjust_trust_score();
    END IF;
END $$;


-- ─── Phase 3: Integrate trust signal into _score_submission_quality ─────────

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

COMMENT ON FUNCTION _score_submission_quality(uuid, text, text, text, text) IS
    'Internal 7-signal quality scorer for product submissions. '
    'Signals: account age, velocity, EAN match, photo, brand quality, '
    'product name quality, user trust score (#471). '
    'Returns {quality_score, signals[], recommended_action}.';

-- Grants unchanged (already set in 20260315000300)
REVOKE ALL ON FUNCTION _score_submission_quality(uuid, text, text, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _score_submission_quality(uuid, text, text, text, text) TO service_role;

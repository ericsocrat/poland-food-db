-- ══════════════════════════════════════════════════════════════════════════
-- Migration: Drift Detection Automation
-- Issue:     #199 — GOV-A4: Version Drift Detection Automation
-- Depends:   #198 (formula registry), #191 (feature flags), #189 (scoring engine)
--
-- Creates governance_drift_check() — a unified drift detection runner that
-- aggregates 8 automated checks across scoring, search, naming, and flags.
-- Also creates a drift_check_results table for historical logging.
--
-- Rollback: DROP FUNCTION IF EXISTS governance_drift_check CASCADE;
--           DROP FUNCTION IF EXISTS log_drift_check CASCADE;
--           DROP TABLE IF EXISTS drift_check_results CASCADE;
-- ══════════════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────────
-- Section 1: drift_check_results — Historical drift check log
-- ────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.drift_check_results (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_id          uuid        NOT NULL DEFAULT gen_random_uuid(),
    check_name      text        NOT NULL,
    severity        text        NOT NULL,
    status          text        NOT NULL,
    detail          text,
    checked_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.drift_check_results IS 'Historical log of governance drift check results (#199)';
COMMENT ON COLUMN public.drift_check_results.run_id IS 'Groups all checks from a single run';
COMMENT ON COLUMN public.drift_check_results.severity IS 'critical | medium | low';
COMMENT ON COLUMN public.drift_check_results.status IS 'pass | drift | skip';

-- Index for time-based queries and filtering by status
CREATE INDEX IF NOT EXISTS idx_drift_check_results_checked_at
    ON public.drift_check_results (checked_at DESC);

CREATE INDEX IF NOT EXISTS idx_drift_check_results_status
    ON public.drift_check_results (status)
    WHERE status = 'drift';

-- RLS: service_role and authenticated can read; only service_role can write
ALTER TABLE public.drift_check_results ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'drift_check_results' AND policyname = 'drift_results_service_all'
    ) THEN
        CREATE POLICY drift_results_service_all ON public.drift_check_results
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'drift_check_results' AND policyname = 'drift_results_auth_read'
    ) THEN
        CREATE POLICY drift_results_auth_read ON public.drift_check_results
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;


-- ────────────────────────────────────────────────────────────────────────
-- Section 2: governance_drift_check() — Master drift detection runner
-- ────────────────────────────────────────────────────────────────────────
-- Returns one row per check. Status: 'pass' | 'drift' | 'skip'
-- Severity: 'critical' | 'medium' | 'low'
--
-- Drift Check Catalog (8 checks):
-- ┌────┬────────────────────────────┬──────────┬────────────────────────────────────┐
-- │ #  │ Check Name                 │ Severity │ What It Detects                    │
-- ├────┼────────────────────────────┼──────────┼────────────────────────────────────┤
-- │ 1  │ formula_weight_drift       │ critical │ Active formula weights ≠ fingerprint│
-- │ 2  │ function_source_drift      │ critical │ Function body changed w/o registry │
-- │ 3  │ scoring_version_count      │ critical │ Multiple active scoring versions   │
-- │ 4  │ search_config_count        │ critical │ Multiple active search configs     │
-- │ 5  │ scoring_function_exists    │ critical │ Scoring function missing from DB   │
-- │ 6  │ trigger_naming_convention  │ medium   │ Non-conforming trigger names       │
-- │ 7  │ stale_feature_flags        │ medium   │ Expired flags still active         │
-- │ 8  │ source_hashes_populated    │ medium   │ Empty formula_source_hashes table  │
-- └────┴────────────────────────────┴──────────┴────────────────────────────────────┘

CREATE OR REPLACE FUNCTION public.governance_drift_check()
RETURNS TABLE(
    check_name  text,
    severity    text,
    status      text,
    detail      text
) LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- ── Check 1: Formula weight drift (scoring + search) ────────────────
    -- Delegates to check_formula_drift() from #198.
    -- Detects when active formula weights don't match their stored fingerprint.
    RETURN QUERY
    SELECT 'formula_weight_drift'::text,
           'critical'::text,
           CASE WHEN EXISTS (
               SELECT 1 FROM check_formula_drift() cfd WHERE cfd.status = 'drift_detected'
           ) THEN 'drift' ELSE 'pass' END,
           'Active formula weights vs registered fingerprints'::text;

    -- ── Check 2: Function source code drift ─────────────────────────────
    -- Delegates to check_function_source_drift() from #198.
    -- Detects when critical function bodies have been modified without
    -- updating formula_source_hashes.
    RETURN QUERY
    SELECT 'function_source_drift'::text,
           'critical'::text,
           CASE WHEN EXISTS (
               SELECT 1 FROM check_function_source_drift() cfd WHERE cfd.status = 'drift_detected'
           ) THEN 'drift' ELSE 'pass' END,
           'Critical function source vs registered hashes'::text;

    -- ── Check 3: Multiple active scoring versions ───────────────────────
    -- Only one scoring_model_versions row should have status='active'.
    -- (Enforced by EXCLUDE constraint, but belt-and-suspenders.)
    RETURN QUERY
    SELECT 'scoring_version_count'::text,
           'critical'::text,
           CASE WHEN (
               SELECT count(*) FROM scoring_model_versions WHERE status = 'active'
           ) > 1 THEN 'drift' ELSE 'pass' END,
           'Only one scoring version should be active'::text;

    -- ── Check 4: Multiple active search configs ─────────────────────────
    -- Only one search_ranking_config row should have active=true.
    RETURN QUERY
    SELECT 'search_config_count'::text,
           'critical'::text,
           CASE WHEN (
               SELECT count(*) FROM search_ranking_config WHERE active = true
           ) > 1 THEN 'drift' ELSE 'pass' END,
           'Only one search ranking config should be active'::text;

    -- ── Check 5: Scoring function exists in pg_proc ─────────────────────
    -- The active scoring function must exist. If it's been dropped or
    -- renamed, scoring breaks silently.
    RETURN QUERY
    SELECT 'scoring_function_exists'::text,
           'critical'::text,
           CASE WHEN NOT EXISTS (
               SELECT 1 FROM pg_proc WHERE proname = 'compute_unhealthiness_v32'
           ) THEN 'drift' ELSE 'pass' END,
           'Active scoring function compute_unhealthiness_v32 must exist'::text;

    -- ── Check 6: Trigger naming convention (products table) ─────────────
    -- All user triggers on products must follow either:
    --   trg_products_{purpose}  (standard convention)
    --   products_{NN}_{purpose} (numbered ordering convention)
    RETURN QUERY
    SELECT 'trigger_naming_convention'::text,
           'medium'::text,
           CASE WHEN EXISTS (
               SELECT 1 FROM pg_trigger t
               JOIN pg_class c ON c.oid = t.tgrelid
               WHERE c.relname = 'products'
                 AND NOT t.tgisinternal
                 AND t.tgname !~ '^(trg_products_|products_\d+_)'
           ) THEN 'drift' ELSE 'pass' END,
           'Products triggers must follow trg_products_* or products_NN_* convention'::text;

    -- ── Check 7: Stale feature flags ────────────────────────────────────
    -- Flags past their expiration date should not remain active.
    RETURN QUERY
    SELECT 'stale_feature_flags'::text,
           'medium'::text,
           CASE WHEN EXISTS (
               SELECT 1 FROM feature_flags
               WHERE expires_at IS NOT NULL
                 AND expires_at < now()
                 AND enabled = true
           ) THEN 'drift' ELSE 'pass' END,
           'No active flags should be past their expiration date'::text;

    -- ── Check 8: Formula source hashes populated ────────────────────────
    -- The formula_source_hashes table must not be empty — at minimum the
    -- 6 critical functions seeded by #198 should be present.
    RETURN QUERY
    SELECT 'source_hashes_populated'::text,
           'medium'::text,
           CASE WHEN (SELECT count(*) FROM formula_source_hashes) = 0
           THEN 'drift' ELSE 'pass' END,
           'formula_source_hashes must have registered function entries'::text;

    RETURN;
END;
$$;

COMMENT ON FUNCTION public.governance_drift_check IS
    'Master governance drift detection runner — 8 checks across scoring, '
    'search, naming conventions, and feature flags (#199)';


-- ────────────────────────────────────────────────────────────────────────
-- Section 3: log_drift_check() — Persist drift check results
-- ────────────────────────────────────────────────────────────────────────
-- Runs governance_drift_check() and inserts results into drift_check_results.
-- Returns the run_id for reference.

CREATE OR REPLACE FUNCTION public.log_drift_check()
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_run_id uuid := gen_random_uuid();
BEGIN
    INSERT INTO drift_check_results (run_id, check_name, severity, status, detail)
    SELECT v_run_id, g.check_name, g.severity, g.status, g.detail
    FROM governance_drift_check() g;

    RETURN v_run_id;
END;
$$;

COMMENT ON FUNCTION public.log_drift_check IS
    'Executes governance_drift_check() and persists results for history (#199)';


-- ────────────────────────────────────────────────────────────────────────
-- Section 4: Permissions
-- ────────────────────────────────────────────────────────────────────────

-- governance_drift_check: read-only, safe for authenticated users
GRANT EXECUTE ON FUNCTION public.governance_drift_check() TO authenticated;
GRANT EXECUTE ON FUNCTION public.governance_drift_check() TO service_role;

-- log_drift_check: writes to results table, service_role only
GRANT EXECUTE ON FUNCTION public.log_drift_check() TO service_role;

-- Revoke from public/anon (defense in depth)
REVOKE EXECUTE ON FUNCTION public.governance_drift_check() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.governance_drift_check() FROM anon;
REVOKE EXECUTE ON FUNCTION public.log_drift_check() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.log_drift_check() FROM anon;

-- Table permissions
GRANT SELECT ON public.drift_check_results TO authenticated;
GRANT ALL    ON public.drift_check_results TO service_role;
REVOKE ALL   ON public.drift_check_results FROM PUBLIC;
REVOKE ALL   ON public.drift_check_results FROM anon;

-- ══════════════════════════════════════════════════════════════════════════
-- Migration: Unified Formula Registry & Drift Detection
-- Issue:     #198 — Scoring & Search Formula Registry (GOV-A3)
-- ══════════════════════════════════════════════════════════════════════════
--
-- Extends the existing scoring_model_versions and search_ranking_config
-- tables with fingerprint-based drift detection, then unifies them under
-- a single v_formula_registry view.
--
-- Deliverables:
--   1. weights_fingerprint column on both tables (auto-computed SHA-256)
--   2. version column on search_ranking_config for uniform versioning
--   3. Auto-fingerprint trigger (recomputes on INSERT/UPDATE)
--   4. v_formula_registry — unified view across scoring + search
--   5. check_formula_drift() — sentinel function for CI/QA
--   6. check_function_source_drift() — pg_proc source hash comparison
--
-- Rollback:
--   DROP VIEW IF EXISTS v_formula_registry;
--   DROP FUNCTION IF EXISTS check_formula_drift();
--   DROP FUNCTION IF EXISTS check_function_source_drift();
--   DROP FUNCTION IF EXISTS trg_auto_fingerprint();
--   DROP TRIGGER IF EXISTS auto_fingerprint_smv ON scoring_model_versions;
--   DROP TRIGGER IF EXISTS auto_fingerprint_src ON search_ranking_config;
--   ALTER TABLE scoring_model_versions DROP COLUMN IF EXISTS weights_fingerprint;
--   ALTER TABLE search_ranking_config DROP COLUMN IF EXISTS weights_fingerprint;
--   ALTER TABLE search_ranking_config DROP COLUMN IF EXISTS version;
--   ALTER TABLE search_ranking_config DROP COLUMN IF EXISTS change_reason;
--   DROP TABLE IF EXISTS formula_source_hashes;
-- ══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Add fingerprint column to scoring_model_versions
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.scoring_model_versions
    ADD COLUMN IF NOT EXISTS weights_fingerprint text;

COMMENT ON COLUMN public.scoring_model_versions.weights_fingerprint
    IS 'SHA-256 of config JSONB for drift detection. Auto-computed on INSERT/UPDATE.';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Add fingerprint, version, and change_reason to search_ranking_config
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.search_ranking_config
    ADD COLUMN IF NOT EXISTS weights_fingerprint text,
    ADD COLUMN IF NOT EXISTS version text,
    ADD COLUMN IF NOT EXISTS change_reason text;

COMMENT ON COLUMN public.search_ranking_config.weights_fingerprint
    IS 'SHA-256 of weights JSONB for drift detection. Auto-computed on INSERT/UPDATE.';
COMMENT ON COLUMN public.search_ranking_config.version
    IS 'Semantic version string (e.g. v1.0.0) for registry uniformity.';
COMMENT ON COLUMN public.search_ranking_config.change_reason
    IS 'Why this config version was created.';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Backfill fingerprints for existing rows
-- ═══════════════════════════════════════════════════════════════════════════════

-- Scoring: fingerprint the full config JSONB
UPDATE public.scoring_model_versions
SET    weights_fingerprint = encode(sha256(config::text::bytea), 'hex')
WHERE  weights_fingerprint IS NULL;

-- Search: fingerprint the weights JSONB + backfill version
UPDATE public.search_ranking_config
SET    weights_fingerprint = encode(sha256(weights::text::bytea), 'hex'),
       version = COALESCE(version, 'v1.0.0'),
       change_reason = COALESCE(change_reason, 'Initial registration')
WHERE  weights_fingerprint IS NULL;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Auto-fingerprint triggers
-- ═══════════════════════════════════════════════════════════════════════════════

-- Generic trigger function for scoring_model_versions
CREATE OR REPLACE FUNCTION public.trg_auto_fingerprint_smv()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $fn$
BEGIN
    NEW.weights_fingerprint := encode(sha256(NEW.config::text::bytea), 'hex');
    RETURN NEW;
END;
$fn$;

-- Trigger on scoring_model_versions
DROP TRIGGER IF EXISTS auto_fingerprint_smv ON public.scoring_model_versions;
CREATE TRIGGER auto_fingerprint_smv
    BEFORE INSERT OR UPDATE OF config ON public.scoring_model_versions
    FOR EACH ROW
    EXECUTE FUNCTION trg_auto_fingerprint_smv();

-- Generic trigger function for search_ranking_config
CREATE OR REPLACE FUNCTION public.trg_auto_fingerprint_src()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $fn$
BEGIN
    NEW.weights_fingerprint := encode(sha256(NEW.weights::text::bytea), 'hex');
    RETURN NEW;
END;
$fn$;

-- Trigger on search_ranking_config
DROP TRIGGER IF EXISTS auto_fingerprint_src ON public.search_ranking_config;
CREATE TRIGGER auto_fingerprint_src
    BEFORE INSERT OR UPDATE OF weights ON public.search_ranking_config
    FOR EACH ROW
    EXECUTE FUNCTION trg_auto_fingerprint_src();


-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Unified formula registry view
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.v_formula_registry AS

-- Scoring formulas
SELECT
    'scoring'::text                    AS domain,
    smv.version                        AS version,
    'compute_unhealthiness'::text      AS formula_name,
    smv.status                         AS status,
    smv.config                         AS weights_config,
    smv.weights_fingerprint            AS fingerprint,
    smv.description                    AS change_reason,
    smv.created_by                     AS created_by,
    smv.activated_at                   AS activated_at,
    smv.created_at                     AS created_at,
    (smv.status = 'active')            AS is_active
FROM public.scoring_model_versions smv

UNION ALL

-- Search ranking formulas
SELECT
    'search'::text                     AS domain,
    src.version                        AS version,
    src.config_name                    AS formula_name,
    CASE WHEN src.active THEN 'active' ELSE 'inactive' END AS status,
    src.weights                        AS weights_config,
    src.weights_fingerprint            AS fingerprint,
    COALESCE(src.change_reason, src.description) AS change_reason,
    'system'::text                     AS created_by,
    CASE WHEN src.active THEN src.updated_at END AS activated_at,
    src.created_at                     AS created_at,
    src.active                         AS is_active
FROM public.search_ranking_config src;

COMMENT ON VIEW public.v_formula_registry IS
    'Unified read-only registry of all scoring and search formulas with version, '
    'fingerprint, and activation status. Source: scoring_model_versions + search_ranking_config.';

GRANT SELECT ON public.v_formula_registry TO authenticated, anon, service_role;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Formula source hash registry
-- ═══════════════════════════════════════════════════════════════════════════════

-- Stores the expected pg_proc source hash for each critical function.
-- check_function_source_drift() compares against actual pg_proc.

CREATE TABLE IF NOT EXISTS public.formula_source_hashes (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    function_name   text   NOT NULL UNIQUE,
    expected_hash   text   NOT NULL,
    description     text,
    registered_at   timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.formula_source_hashes IS
    'Expected pg_proc source hashes for critical scoring/search functions. '
    'Used by check_function_source_drift() to detect unregistered code changes.';

ALTER TABLE public.formula_source_hashes ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'formula_source_hashes'
          AND policyname = 'fsh_read_all'
    ) THEN
        CREATE POLICY "fsh_read_all"
            ON public.formula_source_hashes FOR SELECT
            USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'formula_source_hashes'
          AND policyname = 'fsh_write_service'
    ) THEN
        CREATE POLICY "fsh_write_service"
            ON public.formula_source_hashes FOR ALL
            TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

GRANT SELECT ON public.formula_source_hashes TO authenticated, anon, service_role;

-- Seed current function source hashes
INSERT INTO public.formula_source_hashes (function_name, expected_hash, description)
SELECT
    p.proname::text,
    encode(sha256(p.prosrc::bytea), 'hex'),
    'Auto-registered during formula_registry migration'
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
      'compute_unhealthiness_v32',
      'explain_score_v32',
      'compute_score',
      '_compute_from_config',
      '_explain_from_config',
      'search_rank'
  )
ON CONFLICT (function_name) DO UPDATE
SET expected_hash = EXCLUDED.expected_hash,
    updated_at    = now();


-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. check_formula_drift() — JSONB fingerprint drift detection
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.check_formula_drift()
RETURNS TABLE(
    domain          text,
    formula_name    text,
    version         text,
    registered_fp   text,
    recomputed_fp   text,
    status          text    -- 'match' | 'drift_detected' | 'no_fingerprint'
)
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    RETURN QUERY

    -- Check scoring formulas
    SELECT
        'scoring'::text           AS domain,
        'compute_unhealthiness'   AS formula_name,
        smv.version               AS version,
        smv.weights_fingerprint   AS registered_fp,
        encode(sha256(smv.config::text::bytea), 'hex') AS recomputed_fp,
        CASE
            WHEN smv.weights_fingerprint IS NULL THEN 'no_fingerprint'
            WHEN smv.weights_fingerprint = encode(sha256(smv.config::text::bytea), 'hex')
                THEN 'match'
            ELSE 'drift_detected'
        END                       AS status
    FROM scoring_model_versions smv
    WHERE smv.status = 'active'

    UNION ALL

    -- Check search formulas
    SELECT
        'search'::text            AS domain,
        src.config_name           AS formula_name,
        src.version               AS version,
        src.weights_fingerprint   AS registered_fp,
        encode(sha256(src.weights::text::bytea), 'hex') AS recomputed_fp,
        CASE
            WHEN src.weights_fingerprint IS NULL THEN 'no_fingerprint'
            WHEN src.weights_fingerprint = encode(sha256(src.weights::text::bytea), 'hex')
                THEN 'match'
            ELSE 'drift_detected'
        END                       AS status
    FROM search_ranking_config src
    WHERE src.active = true;
END;
$fn$;

COMMENT ON FUNCTION public.check_formula_drift() IS
    'Returns drift status for all active scoring and search formulas by comparing '
    'stored fingerprints against recomputed SHA-256 of current JSONB config.';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. check_function_source_drift() — pg_proc source hash comparison
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.check_function_source_drift()
RETURNS TABLE(
    function_name    text,
    expected_hash    text,
    actual_hash      text,
    status           text    -- 'match' | 'drift_detected' | 'function_missing'
)
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
BEGIN
    RETURN QUERY
    SELECT
        fsh.function_name,
        fsh.expected_hash,
        COALESCE(encode(sha256(p.prosrc::bytea), 'hex'), 'MISSING') AS actual_hash,
        CASE
            WHEN p.prosrc IS NULL THEN 'function_missing'
            WHEN fsh.expected_hash = encode(sha256(p.prosrc::bytea), 'hex')
                THEN 'match'
            ELSE 'drift_detected'
        END AS status
    FROM formula_source_hashes fsh
    LEFT JOIN pg_proc p
        ON p.proname = fsh.function_name
       AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ORDER BY fsh.function_name;
END;
$fn$;

COMMENT ON FUNCTION public.check_function_source_drift() IS
    'Compares registered pg_proc source hashes against actual function bodies to '
    'detect unregistered code changes to critical scoring/search functions.';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Grants
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION public.check_formula_drift()          TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.check_function_source_drift()  TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.trg_auto_fingerprint_smv()     TO service_role;
GRANT EXECUTE ON FUNCTION public.trg_auto_fingerprint_src()     TO service_role;

REVOKE EXECUTE ON FUNCTION public.check_formula_drift()          FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.check_function_source_drift()  FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.trg_auto_fingerprint_smv()     FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.trg_auto_fingerprint_src()     FROM PUBLIC, anon;

COMMIT;

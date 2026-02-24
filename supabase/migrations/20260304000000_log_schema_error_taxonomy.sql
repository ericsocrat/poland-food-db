-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Structured Log Schema & Error Taxonomy
-- Issue: #210 (GOV-F1)
--
-- Creates:
--   1. log_level_ref — severity level reference table (5 rows)
--   2. error_code_registry — known error codes with domain/category/severity
--   3. validate_log_entry() — validates log JSON against schema
--
-- Rollback:
--   DROP FUNCTION IF EXISTS validate_log_entry(jsonb);
--   DROP TABLE IF EXISTS error_code_registry;
--   DROP TABLE IF EXISTS log_level_ref;
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── Step 1: log_level_ref table ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.log_level_ref (
    level              text PRIMARY KEY,
    numeric_level      integer NOT NULL UNIQUE,
    description        text NOT NULL,
    retention_days     integer,          -- NULL = indefinite
    escalation_target  text              -- NULL, 'dashboard', 'slack', 'pager'
);

COMMENT ON TABLE public.log_level_ref IS 'Severity level definitions for structured logging. 5 levels: DEBUG→CRITICAL.';

-- Seed levels (idempotent)
INSERT INTO public.log_level_ref (level, numeric_level, description, retention_days, escalation_target)
VALUES
    ('DEBUG',    0, 'Development tracing — local dev only, never stored in production',        0,    NULL),
    ('INFO',     1, 'Normal operations — request completed, backfill finished',                30,   NULL),
    ('WARN',     2, 'Unexpected but recoverable — clamped value, degraded fallback',           90,   'dashboard'),
    ('ERROR',    3, 'Operation failed, system continues — query timeout, API error',           365,  'slack'),
    ('CRITICAL', 4, 'System-wide impact, immediate attention — missing index, data corruption', NULL, 'pager')
ON CONFLICT (level) DO UPDATE SET
    numeric_level     = EXCLUDED.numeric_level,
    description       = EXCLUDED.description,
    retention_days    = EXCLUDED.retention_days,
    escalation_target = EXCLUDED.escalation_target;

-- ─── Step 2: error_code_registry table ───────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.error_code_registry (
    error_code  text PRIMARY KEY,
    domain      text NOT NULL,
    category    text NOT NULL,
    severity    text NOT NULL REFERENCES public.log_level_ref(level),
    description text NOT NULL,
    action      text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.error_code_registry IS 'Registry of all known error codes following {DOMAIN}_{CATEGORY}_{NNN} format.';

-- Seed starter error codes (idempotent)
INSERT INTO public.error_code_registry (error_code, domain, category, severity, description, action)
VALUES
    ('SCORING_CALC_001',       'scoring',    'calculation', 'ERROR',    'Division by zero in scoring formula',                          'Skip product, log, alert'),
    ('SCORING_CALC_002',       'scoring',    'calculation', 'WARN',     'Negative score computed (below floor)',                         'Clamp to 1, log'),
    ('SCORING_VERSION_001',    'scoring',    'version',     'ERROR',    'Product references non-existent scoring version',               'Default to active version'),
    ('SEARCH_QUERY_001',       'search',     'query',       'WARN',     'Zero results returned for non-empty query',                     'Log for analysis'),
    ('SEARCH_QUERY_002',       'search',     'query',       'ERROR',    'Query exceeded timeout threshold (>2s)',                         'Return partial results'),
    ('SEARCH_INDEX_001',       'search',     'index',       'CRITICAL', 'tsvector or pg_trgm index missing or invalid',                  'Alert immediately'),
    ('PROVENANCE_CONFLICT_001','provenance', 'conflict',    'WARN',     'Two sources disagree on field value',                           'Queue for resolution'),
    ('PROVENANCE_STALE_001',   'provenance', 'freshness',   'INFO',     'Product data older than 90 days',                               'Schedule re-check'),
    ('PIPELINE_IO_001',        'pipeline',   'io',          'ERROR',    'OFF API unreachable',                                           'Retry with exponential backoff'),
    ('PIPELINE_IO_002',        'pipeline',   'io',          'WARN',     'OFF API returned incomplete data',                              'Log missing fields'),
    ('MIGRATION_LOCK_001',     'migration',  'lock',        'CRITICAL', 'AccessExclusiveLock held >5s during migration',                 'Alert, prepare rollback'),
    ('AUTH_TOKEN_001',         'auth',       'token',       'WARN',     'Expired JWT presented',                                         'Return 401'),
    ('AUTH_RLS_001',           'auth',       'access',      'ERROR',    'RLS policy violation or unauthorized access attempt',            'Log, return 403')
ON CONFLICT (error_code) DO UPDATE SET
    domain      = EXCLUDED.domain,
    category    = EXCLUDED.category,
    severity    = EXCLUDED.severity,
    description = EXCLUDED.description,
    action      = EXCLUDED.action;

-- ─── Step 3: validate_log_entry() function ───────────────────────────────────

CREATE OR REPLACE FUNCTION public.validate_log_entry(p_entry jsonb)
RETURNS jsonb
LANGUAGE plpgsql IMMUTABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
    v_errors text[] := '{}';
    v_level  text;
    v_domain text;
BEGIN
    -- 1. Required fields
    IF p_entry IS NULL THEN
        RETURN jsonb_build_object('valid', false, 'errors', jsonb_build_array('Entry is NULL'));
    END IF;

    IF NOT (p_entry ? 'timestamp') THEN
        v_errors := array_append(v_errors, 'Missing required field: timestamp');
    END IF;

    IF NOT (p_entry ? 'level') THEN
        v_errors := array_append(v_errors, 'Missing required field: level');
    ELSE
        v_level := UPPER(p_entry->>'level');
        IF v_level NOT IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL') THEN
            v_errors := array_append(v_errors, 'Invalid level: ' || (p_entry->>'level') || '. Must be one of: DEBUG, INFO, WARN, ERROR, CRITICAL');
        END IF;
    END IF;

    IF NOT (p_entry ? 'domain') THEN
        v_errors := array_append(v_errors, 'Missing required field: domain');
    ELSE
        v_domain := LOWER(p_entry->>'domain');
        IF v_domain NOT IN ('scoring', 'search', 'provenance', 'pipeline', 'migration', 'auth', 'frontend', 'config') THEN
            v_errors := array_append(v_errors, 'Invalid domain: ' || (p_entry->>'domain') || '. Must be one of: scoring, search, provenance, pipeline, migration, auth, frontend, config');
        END IF;
    END IF;

    IF NOT (p_entry ? 'action') THEN
        v_errors := array_append(v_errors, 'Missing required field: action');
    END IF;

    IF NOT (p_entry ? 'message') THEN
        v_errors := array_append(v_errors, 'Missing required field: message');
    END IF;

    -- 2. Conditional: error_code required for ERROR/CRITICAL
    IF v_level IN ('ERROR', 'CRITICAL') AND NOT (p_entry ? 'error_code') THEN
        v_errors := array_append(v_errors, 'error_code is required when level is ERROR or CRITICAL');
    END IF;

    -- 3. Type checks for optional fields
    IF (p_entry ? 'duration_ms') AND jsonb_typeof(p_entry->'duration_ms') != 'number' THEN
        v_errors := array_append(v_errors, 'duration_ms must be a number');
    END IF;

    IF (p_entry ? 'context') AND jsonb_typeof(p_entry->'context') != 'object' THEN
        v_errors := array_append(v_errors, 'context must be an object');
    END IF;

    -- Return result
    IF array_length(v_errors, 1) IS NULL OR array_length(v_errors, 1) = 0 THEN
        RETURN jsonb_build_object('valid', true);
    ELSE
        RETURN jsonb_build_object(
            'valid', false,
            'errors', to_jsonb(v_errors)
        );
    END IF;
END;
$fn$;

COMMENT ON FUNCTION public.validate_log_entry(jsonb) IS 'Validates a structured log entry against the LOG_SCHEMA.md specification. Returns {valid: true} or {valid: false, errors: [...]}.';

-- ─── Step 4: Security ────────────────────────────────────────────────────────

-- validate_log_entry is SECURITY DEFINER → restrict access
REVOKE EXECUTE ON FUNCTION public.validate_log_entry(jsonb) FROM anon, public;
GRANT EXECUTE ON FUNCTION public.validate_log_entry(jsonb) TO service_role, authenticated;

-- Tables: service-write / auth-read (RLS Pattern B)
ALTER TABLE public.log_level_ref ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.error_code_registry ENABLE ROW LEVEL SECURITY;

-- service_role: full access
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'log_level_ref' AND policyname = 'log_level_ref_service_all') THEN
        CREATE POLICY log_level_ref_service_all ON public.log_level_ref
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'error_code_registry' AND policyname = 'error_code_registry_service_all') THEN
        CREATE POLICY error_code_registry_service_all ON public.error_code_registry
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

-- authenticated: read-only
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'log_level_ref' AND policyname = 'log_level_ref_auth_read') THEN
        CREATE POLICY log_level_ref_auth_read ON public.log_level_ref
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'error_code_registry' AND policyname = 'error_code_registry_auth_read') THEN
        CREATE POLICY error_code_registry_auth_read ON public.error_code_registry
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

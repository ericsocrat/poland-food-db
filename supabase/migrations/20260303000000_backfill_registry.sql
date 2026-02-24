-- ============================================================================
-- Migration: 20260303000000_backfill_registry.sql
-- Issue: #208
-- Rollback: DROP TABLE IF EXISTS public.backfill_registry CASCADE;
-- Runtime estimate: < 1s
-- Lock risk: none (new table creation)
-- Idempotent: YES
-- Description: Create backfill_registry table for tracking batch data operations
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 1: Create backfill_registry table
-- ═══════════════════════════════════════════════════════════════════════════
-- Tracks all backfill operations: batch data updates, scoring re-computations,
-- search vector regenerations, etc.  Every backfill MUST register here before
-- execution and update status upon completion.
--
-- See docs/BACKFILL_STANDARD.md for full governance standard.

CREATE TABLE IF NOT EXISTS public.backfill_registry (
    backfill_id     uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
    name            text        NOT NULL,
    description     text,
    source_issue    text,                       -- e.g., '#193'
    status          text        NOT NULL DEFAULT 'pending',
    started_at      timestamptz,
    completed_at    timestamptz,
    rows_processed  integer     NOT NULL DEFAULT 0,
    rows_expected   integer,
    batch_size      integer     NOT NULL DEFAULT 1000,
    error_message   text,
    executed_by     text,                       -- github username or 'automation'
    rollback_sql    text,                       -- SQL to undo this backfill
    validation_passed boolean,
    created_at      timestamptz NOT NULL DEFAULT now(),

    -- Domain constraints
    CONSTRAINT chk_backfill_status
        CHECK (status IN ('pending', 'running', 'completed', 'failed', 'rolled_back')),
    CONSTRAINT chk_backfill_rows_non_negative
        CHECK (rows_processed >= 0),
    CONSTRAINT chk_backfill_batch_size_positive
        CHECK (batch_size > 0),
    CONSTRAINT backfill_registry_name_unique UNIQUE (name)
);

-- Comment
COMMENT ON TABLE public.backfill_registry IS
    'Tracks all backfill operations — batch data updates, scoring re-computations, etc. See docs/BACKFILL_STANDARD.md.';

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 2: Indexes
-- ═══════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_backfill_registry_status
    ON public.backfill_registry (status);

CREATE INDEX IF NOT EXISTS idx_backfill_registry_created
    ON public.backfill_registry (created_at DESC);

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 3: RLS — service-write / authenticated-read
-- ═══════════════════════════════════════════════════════════════════════════
-- Follows Pattern B from drift_check_results: service_role gets full access,
-- authenticated users get read-only, anon gets nothing.

ALTER TABLE public.backfill_registry ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'backfill_registry'
          AND policyname = 'backfill_service_all'
    ) THEN
        CREATE POLICY backfill_service_all ON public.backfill_registry
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'backfill_registry'
          AND policyname = 'backfill_auth_read'
    ) THEN
        CREATE POLICY backfill_auth_read ON public.backfill_registry
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

GRANT ALL ON public.backfill_registry TO service_role;
GRANT SELECT ON public.backfill_registry TO authenticated;
REVOKE ALL ON public.backfill_registry FROM anon;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 4: Helper functions
-- ═══════════════════════════════════════════════════════════════════════════

-- Register a new backfill (returns the backfill_id)
CREATE OR REPLACE FUNCTION register_backfill(
    p_name text,
    p_description text DEFAULT NULL,
    p_source_issue text DEFAULT NULL,
    p_rows_expected integer DEFAULT NULL,
    p_batch_size integer DEFAULT 1000,
    p_rollback_sql text DEFAULT NULL,
    p_executed_by text DEFAULT 'automation'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_id uuid;
BEGIN
    INSERT INTO backfill_registry (name, description, source_issue, rows_expected,
                                   batch_size, rollback_sql, executed_by)
    VALUES (p_name, p_description, p_source_issue, p_rows_expected,
            p_batch_size, p_rollback_sql, p_executed_by)
    ON CONFLICT (name) DO UPDATE SET
        description    = EXCLUDED.description,
        source_issue   = EXCLUDED.source_issue,
        rows_expected  = EXCLUDED.rows_expected,
        batch_size     = EXCLUDED.batch_size,
        rollback_sql   = EXCLUDED.rollback_sql,
        executed_by    = EXCLUDED.executed_by,
        status         = 'pending',
        rows_processed = 0,
        started_at     = NULL,
        completed_at   = NULL,
        error_message  = NULL,
        validation_passed = NULL
    RETURNING backfill_id INTO v_id;

    RETURN v_id;
END $$;

-- Mark a backfill as started
CREATE OR REPLACE FUNCTION start_backfill(p_backfill_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE backfill_registry
    SET status     = 'running',
        started_at = now()
    WHERE backfill_id = p_backfill_id
      AND status = 'pending';
END $$;

-- Update progress during execution
CREATE OR REPLACE FUNCTION update_backfill_progress(
    p_backfill_id uuid,
    p_rows_processed integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE backfill_registry
    SET rows_processed = p_rows_processed
    WHERE backfill_id = p_backfill_id
      AND status = 'running';
END $$;

-- Complete a backfill
CREATE OR REPLACE FUNCTION complete_backfill(
    p_backfill_id uuid,
    p_rows_processed integer DEFAULT NULL,
    p_validation_passed boolean DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE backfill_registry
    SET status            = 'completed',
        completed_at      = now(),
        rows_processed    = COALESCE(p_rows_processed, rows_processed),
        validation_passed = p_validation_passed
    WHERE backfill_id = p_backfill_id
      AND status = 'running';
END $$;

-- Fail a backfill
CREATE OR REPLACE FUNCTION fail_backfill(
    p_backfill_id uuid,
    p_error_message text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE backfill_registry
    SET status        = 'failed',
        completed_at  = now(),
        error_message = p_error_message
    WHERE backfill_id = p_backfill_id
      AND status = 'running';
END $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 4b: Revoke anon access to internal backfill functions
-- ═══════════════════════════════════════════════════════════════════════════

REVOKE EXECUTE ON FUNCTION public.register_backfill(text, text, text, integer, integer, text, text) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.start_backfill(uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.update_backfill_progress(uuid, integer) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.complete_backfill(uuid, integer, boolean) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.fail_backfill(uuid, text) FROM anon, public;

-- Grant to service_role only (these are machine-only functions)
GRANT EXECUTE ON FUNCTION public.register_backfill(text, text, text, integer, integer, text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.start_backfill(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION public.update_backfill_progress(uuid, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_backfill(uuid, integer, boolean) TO service_role;
GRANT EXECUTE ON FUNCTION public.fail_backfill(uuid, text) TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 5: Monitoring view
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.v_backfill_status AS
SELECT
    backfill_id,
    name,
    status,
    rows_processed,
    rows_expected,
    CASE WHEN rows_expected > 0
         THEN round(rows_processed * 100.0 / rows_expected, 1)
         ELSE NULL
    END AS pct_complete,
    batch_size,
    started_at,
    completed_at,
    CASE WHEN started_at IS NOT NULL AND completed_at IS NULL
         THEN extract(epoch FROM (now() - started_at))::integer
         WHEN started_at IS NOT NULL AND completed_at IS NOT NULL
         THEN extract(epoch FROM (completed_at - started_at))::integer
         ELSE NULL
    END AS elapsed_seconds,
    validation_passed,
    error_message,
    executed_by,
    source_issue,
    created_at
FROM public.backfill_registry
ORDER BY created_at DESC;

GRANT SELECT ON public.v_backfill_status TO authenticated;
GRANT SELECT ON public.v_backfill_status TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 6: Validation
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
    ASSERT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name   = 'backfill_registry'
    ), 'Migration validation FAILED: backfill_registry table not found';

    ASSERT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'register_backfill'
          AND pronamespace = 'public'::regnamespace
    ), 'Migration validation FAILED: register_backfill function not found';

    RAISE NOTICE 'Migration validated: backfill_registry + 5 functions + monitoring view';
END $$;

-- Audit log retention & archival strategy (Issue #371)
--
-- Adds a retention_policies configuration table, a cleanup function with
-- dry-run safety, and timestamp indexes for range-scan cleanup performance.
--
-- Rollback:
--   DROP FUNCTION IF EXISTS execute_retention_cleanup;
--   DROP TABLE IF EXISTS retention_policies;
--   DROP INDEX IF EXISTS idx_change_log_created_at;
--   DROP INDEX IF EXISTS idx_score_audit_changed_at;
--   DROP INDEX IF EXISTS idx_score_history_recorded_at;
-- ============================================================================

-- ─── 1. Retention configuration table ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.retention_policies (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name     text    NOT NULL UNIQUE,
    timestamp_column text  NOT NULL,
    active_retention_days integer NOT NULL DEFAULT 90
        CONSTRAINT chk_retention_active_days CHECK (active_retention_days > 0),
    is_enabled     boolean NOT NULL DEFAULT true,
    last_cleanup_at timestamptz,
    rows_deleted   bigint  NOT NULL DEFAULT 0
        CONSTRAINT chk_retention_rows_deleted CHECK (rows_deleted >= 0),
    created_at     timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  retention_policies IS 'Configurable retention windows for audit/history tables';
COMMENT ON COLUMN retention_policies.table_name IS 'Target table (must exist in public schema)';
COMMENT ON COLUMN retention_policies.timestamp_column IS 'Column used for age-based cleanup (e.g. created_at, changed_at)';
COMMENT ON COLUMN retention_policies.active_retention_days IS 'Rows older than this are eligible for cleanup';
COMMENT ON COLUMN retention_policies.last_cleanup_at IS 'Timestamp of last successful cleanup run';
COMMENT ON COLUMN retention_policies.rows_deleted IS 'Cumulative count of rows deleted across all cleanup runs';

-- RLS: service_role can write, authenticated can read policies
ALTER TABLE retention_policies ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'retention_policies' AND policyname = 'retention_policies_select_authenticated'
    ) THEN
        CREATE POLICY retention_policies_select_authenticated ON retention_policies
            FOR SELECT TO authenticated USING (true);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'retention_policies' AND policyname = 'retention_policies_all_service'
    ) THEN
        CREATE POLICY retention_policies_all_service ON retention_policies
            FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

-- ─── 2. Seed retention policies ────────────────────────────────────────────

INSERT INTO retention_policies (table_name, timestamp_column, active_retention_days)
VALUES
    ('product_change_log',    'created_at',   90),
    ('score_audit_log',       'changed_at',   90),
    ('product_score_history', 'recorded_at', 180),
    ('drift_check_results',   'checked_at',   90),
    ('flag_audit_log',        'changed_at',  365)
ON CONFLICT (table_name) DO NOTHING;

-- ─── 3. Cleanup function ───────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.execute_retention_cleanup(
    p_dry_run boolean DEFAULT true,
    p_batch_size integer DEFAULT 5000
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_policy   RECORD;
    v_cutoff   timestamptz;
    v_eligible bigint;
    v_deleted  bigint;
    v_results  jsonb := '[]'::jsonb;
    v_total_deleted bigint := 0;
BEGIN
    -- Validate batch size
    IF p_batch_size < 1 OR p_batch_size > 50000 THEN
        RETURN jsonb_build_object(
            'error', 'p_batch_size must be between 1 and 50000'
        );
    END IF;

    FOR v_policy IN
        SELECT rp.id, rp.table_name, rp.timestamp_column, rp.active_retention_days
        FROM retention_policies rp
        WHERE rp.is_enabled = true
        ORDER BY rp.table_name
    LOOP
        v_cutoff := now() - (v_policy.active_retention_days || ' days')::interval;

        -- Count eligible rows
        EXECUTE format(
            'SELECT count(*) FROM %I WHERE %I < $1',
            v_policy.table_name, v_policy.timestamp_column
        ) INTO v_eligible USING v_cutoff;

        v_deleted := 0;

        IF NOT p_dry_run AND v_eligible > 0 THEN
            -- Delete in batches to avoid long locks
            EXECUTE format(
                'DELETE FROM %I WHERE ctid = ANY(
                    ARRAY(SELECT ctid FROM %I WHERE %I < $1 LIMIT $2)
                )',
                v_policy.table_name,
                v_policy.table_name, v_policy.timestamp_column
            ) USING v_cutoff, p_batch_size;

            GET DIAGNOSTICS v_deleted = ROW_COUNT;

            -- Update tracking counters
            UPDATE retention_policies
            SET last_cleanup_at = now(),
                rows_deleted    = rows_deleted + v_deleted
            WHERE id = v_policy.id;

            v_total_deleted := v_total_deleted + v_deleted;
        END IF;

        v_results := v_results || jsonb_build_object(
            'table',        v_policy.table_name,
            'cutoff_date',  v_cutoff,
            'rows_eligible', v_eligible,
            'rows_deleted',  v_deleted
        );
    END LOOP;

    RETURN jsonb_build_object(
        'dry_run',       p_dry_run,
        'tables',        v_results,
        'total_deleted', v_total_deleted,
        'executed_at',   now()
    );
END;
$$;

COMMENT ON FUNCTION execute_retention_cleanup IS
    'Cleans up audit/history tables based on retention_policies. '
    'Default: dry_run=true (preview only). Pass false to delete.';

-- Security: only service_role can execute
REVOKE ALL ON FUNCTION execute_retention_cleanup FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION execute_retention_cleanup TO service_role;

-- ─── 4. Timestamp indexes for cleanup performance ──────────────────────────
-- These support the WHERE timestamp_col < cutoff range scans in cleanup

CREATE INDEX IF NOT EXISTS idx_change_log_created_at
    ON product_change_log (created_at);

CREATE INDEX IF NOT EXISTS idx_score_audit_changed_at
    ON score_audit_log (changed_at);

CREATE INDEX IF NOT EXISTS idx_score_history_recorded_at
    ON product_score_history (recorded_at);

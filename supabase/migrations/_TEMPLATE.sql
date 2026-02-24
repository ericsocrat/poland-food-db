-- ============================================================================
-- Migration: YYYYMMDDHHMMSS_{description}.sql
-- Issue: #{issue_number}
-- Rollback: {DROP TABLE IF EXISTS ... / ALTER TABLE DROP COLUMN IF EXISTS ...}
-- Runtime estimate: < {N}s
-- Lock risk: {none | LOW | MEDIUM | HIGH | CRITICAL}
-- Idempotent: YES
-- Description: {one-line description of what this migration does}
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 1: Schema change (idempotent)
-- ═══════════════════════════════════════════════════════════════════════════

-- Example: CREATE TABLE IF NOT EXISTS public.new_table ( ... );
-- Example: ALTER TABLE products ADD COLUMN IF NOT EXISTS new_column text;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 2: Functions (idempotent via CREATE OR REPLACE)
-- ═══════════════════════════════════════════════════════════════════════════

-- Example:
-- CREATE OR REPLACE FUNCTION my_function()
-- RETURNS void
-- LANGUAGE plpgsql
-- SECURITY INVOKER
-- AS $$
-- BEGIN
--   -- function body
-- END $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 3: Triggers (idempotent via DROP IF EXISTS + CREATE)
-- ═══════════════════════════════════════════════════════════════════════════

-- Example:
-- DROP TRIGGER IF EXISTS products_NN_domain_action ON products;
-- CREATE TRIGGER products_NN_domain_action
--   BEFORE|AFTER INSERT|UPDATE|DELETE ON products
--   FOR EACH ROW
--   EXECUTE FUNCTION trg_my_function();

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 4: Indexes (use CONCURRENTLY on populated tables)
-- ═══════════════════════════════════════════════════════════════════════════

-- Example:
-- CREATE INDEX IF NOT EXISTS idx_table_column ON table (column);

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 5: Grants & RLS
-- ═══════════════════════════════════════════════════════════════════════════

-- Example:
-- ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;
-- GRANT SELECT ON new_table TO authenticated;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 6: Validation (verify migration applied)
-- ═══════════════════════════════════════════════════════════════════════════

-- DO $$
-- BEGIN
--   ASSERT EXISTS (
--     SELECT 1 FROM information_schema.columns
--     WHERE table_schema = 'public'
--       AND table_name   = 'new_table'
--       AND column_name  = 'expected_column'
--   ), 'Migration validation FAILED: expected_column not found';
--   RAISE NOTICE '✅ Migration validated';
-- END $$;

-- NOTE: Data backfills go in a SEPARATE migration file.
-- See docs/MIGRATION_CONVENTIONS.md for full standards.

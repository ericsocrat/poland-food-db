-- ============================================================
-- DR Drill — Scenario A: Bad Migration (Column Drop)
-- ============================================================
-- Simulates a migration that accidentally drops the health_score
-- column from the products table. Uses SAVEPOINT/ROLLBACK for
-- safe execution — no data is permanently modified.
--
-- Run via: RUN_DR_DRILL.ps1 or manually in psql
-- Environment: local or staging ONLY — never production
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- STEP 1: Record pre-drill state
-- ═══════════════════════════════════════════════════════════════
\echo '────────────────────────────────────────────────────────────'
\echo 'SCENARIO A: Bad Migration (Column Drop)'
\echo '────────────────────────────────────────────────────────────'

\echo '[A-1] Recording pre-drill state...'

SELECT COUNT(*) AS product_count FROM products;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
  AND column_name = 'health_score';

-- ═══════════════════════════════════════════════════════════════
-- STEP 2: Begin transaction with checkpoint
-- ═══════════════════════════════════════════════════════════════
\echo '[A-2] Creating transaction checkpoint...'
BEGIN;
SAVEPOINT before_bad_migration;

-- ═══════════════════════════════════════════════════════════════
-- STEP 3: Simulate destructive migration
-- ═══════════════════════════════════════════════════════════════
\echo '[A-3] Simulating bad migration: DROP COLUMN health_score...'
ALTER TABLE products DROP COLUMN health_score;

-- ═══════════════════════════════════════════════════════════════
-- STEP 4: Verify damage
-- ═══════════════════════════════════════════════════════════════
\echo '[A-4] Verifying damage (expect 0 rows — column is gone)...'

SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
  AND column_name = 'health_score';

-- ═══════════════════════════════════════════════════════════════
-- STEP 5: Recovery — ROLLBACK to SAVEPOINT
-- ═══════════════════════════════════════════════════════════════
\echo '[A-5] RECOVERY: Rolling back to savepoint...'
ROLLBACK TO before_bad_migration;

-- ═══════════════════════════════════════════════════════════════
-- STEP 6: Verify recovery
-- ═══════════════════════════════════════════════════════════════
\echo '[A-6] Verifying recovery (expect 1 row — column restored)...'

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
  AND column_name = 'health_score';

SELECT COUNT(*) AS product_count_after FROM products;

COMMIT;

\echo '[A] SCENARIO A COMPLETE ✓'
\echo ''

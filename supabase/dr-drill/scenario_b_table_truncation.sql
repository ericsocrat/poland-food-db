-- ============================================================
-- DR Drill — Scenario B: Table Truncation (Data Loss)
-- ============================================================
-- Simulates accidental TRUNCATE on the products table, wiping
-- all product data. Uses SAVEPOINT/ROLLBACK for safe execution.
--
-- Run via: RUN_DR_DRILL.ps1 or manually in psql
-- Environment: local or staging ONLY — never production
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- STEP 1: Record pre-drill state
-- ═══════════════════════════════════════════════════════════════
\echo '────────────────────────────────────────────────────────────'
\echo 'SCENARIO B: Table Truncation (Data Loss)'
\echo '────────────────────────────────────────────────────────────'

\echo '[B-1] Recording pre-drill state...'

SELECT 'products' AS tbl, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'nutrition_facts', COUNT(*) FROM nutrition_facts
UNION ALL SELECT 'product_allergen_info', COUNT(*) FROM product_allergen_info
UNION ALL SELECT 'product_ingredient', COUNT(*) FROM product_ingredient;

-- ═══════════════════════════════════════════════════════════════
-- STEP 2: Begin transaction with checkpoint
-- ═══════════════════════════════════════════════════════════════
\echo '[B-2] Creating transaction checkpoint...'
BEGIN;
SAVEPOINT before_truncate;

-- ═══════════════════════════════════════════════════════════════
-- STEP 3: Simulate data loss (CASCADE takes dependent rows)
-- ═══════════════════════════════════════════════════════════════
\echo '[B-3] Simulating TRUNCATE products CASCADE...'
TRUNCATE products CASCADE;

-- ═══════════════════════════════════════════════════════════════
-- STEP 4: Verify damage
-- ═══════════════════════════════════════════════════════════════
\echo '[B-4] Verifying damage (expect 0 rows across all tables)...'

SELECT 'products' AS tbl, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'nutrition_facts', COUNT(*) FROM nutrition_facts
UNION ALL SELECT 'product_allergen_info', COUNT(*) FROM product_allergen_info
UNION ALL SELECT 'product_ingredient', COUNT(*) FROM product_ingredient;

-- ═══════════════════════════════════════════════════════════════
-- STEP 5: Recovery — ROLLBACK to SAVEPOINT
-- ═══════════════════════════════════════════════════════════════
\echo '[B-5] RECOVERY: Rolling back to savepoint...'
ROLLBACK TO before_truncate;

-- ═══════════════════════════════════════════════════════════════
-- STEP 6: Verify recovery
-- ═══════════════════════════════════════════════════════════════
\echo '[B-6] Verifying recovery (row counts should match pre-drill)...'

SELECT 'products' AS tbl, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'nutrition_facts', COUNT(*) FROM nutrition_facts
UNION ALL SELECT 'product_allergen_info', COUNT(*) FROM product_allergen_info
UNION ALL SELECT 'product_ingredient', COUNT(*) FROM product_ingredient;

COMMIT;

\echo '[B] SCENARIO B COMPLETE ✓'
\echo ''

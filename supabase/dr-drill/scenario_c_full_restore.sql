-- ============================================================
-- DR Drill — Scenario C: Full Backup Restore
-- ============================================================
-- Validates that the cloud backup file can be restored and that
-- the restored database passes all integrity checks.
--
-- This scenario has TWO modes:
--   1. VERIFY ONLY (default) — validates backup integrity without
--      destroying any data (runs pg_restore --list + row counts)
--   2. FULL RESTORE — drops and restores from backup (destructive,
--      requires separate shell execution via RUN_DR_DRILL.ps1)
--
-- This SQL file handles verification queries only.
-- The actual pg_restore command is executed by RUN_DR_DRILL.ps1.
--
-- Environment: local or staging ONLY — never production
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- PRE-RESTORE: Record current state (baseline for comparison)
-- ═══════════════════════════════════════════════════════════════
\echo '────────────────────────────────────────────────────────────'
\echo 'SCENARIO C: Full Backup Restore — Pre-Restore Baseline'
\echo '────────────────────────────────────────────────────────────'

\echo '[C-1] Recording pre-restore row counts...'

SELECT 'products' AS tbl, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'nutrition_facts', COUNT(*) FROM nutrition_facts
UNION ALL SELECT 'product_allergen_info', COUNT(*) FROM product_allergen_info
UNION ALL SELECT 'product_ingredient', COUNT(*) FROM product_ingredient
UNION ALL SELECT 'ingredient_ref', COUNT(*) FROM ingredient_ref
UNION ALL SELECT 'country_ref', COUNT(*) FROM country_ref
UNION ALL SELECT 'category_ref', COUNT(*) FROM category_ref
UNION ALL SELECT 'nutri_score_ref', COUNT(*) FROM nutri_score_ref
UNION ALL SELECT 'concern_tier_ref', COUNT(*) FROM concern_tier_ref
ORDER BY tbl;

\echo '[C-2] Recording current migration version...'

SELECT version, name
FROM supabase_migrations.schema_migrations
ORDER BY version DESC
LIMIT 5;

\echo '[C] PRE-RESTORE BASELINE CAPTURED ✓'
\echo ''

-- Migration: 20260302000000_migration_safety_conventions.sql
-- Issue: #203
-- Rollback: ALTER TRIGGER trg_products_score_audit ON products RENAME TO score_change_audit;
--           ALTER TRIGGER trg_products_score_history ON products RENAME TO trg_record_score_change;
-- Runtime estimate: < 1s
-- Lock risk: none (trigger rename is metadata-only)

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 1: Rename non-conforming triggers on products table
-- ═══════════════════════════════════════════════════════════════════════════
-- governance_drift_check() Check 6 requires all triggers on products to match
-- the pattern ^(trg_products_|products_\d+_). Two triggers violate this:
--   - score_change_audit     → rename to trg_products_score_audit
--   - trg_record_score_change → rename to trg_products_score_history
-- Both are safe metadata-only renames (no table locks, no downtime).

DO $$
BEGIN
  -- Rename score_change_audit → trg_products_score_audit
  IF EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'score_change_audit'
      AND tgrelid = 'products'::regclass
  ) THEN
    ALTER TRIGGER score_change_audit ON products RENAME TO trg_products_score_audit;
    RAISE NOTICE '✅ Renamed score_change_audit → trg_products_score_audit';
  ELSE
    RAISE NOTICE '⏭ score_change_audit not found (already renamed or does not exist)';
  END IF;

  -- Rename trg_record_score_change → trg_products_score_history
  IF EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_record_score_change'
      AND tgrelid = 'products'::regclass
  ) THEN
    ALTER TRIGGER trg_record_score_change ON products RENAME TO trg_products_score_history;
    RAISE NOTICE '✅ Renamed trg_record_score_change → trg_products_score_history';
  ELSE
    RAISE NOTICE '⏭ trg_record_score_change not found (already renamed or does not exist)';
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Step 2: Validation — all products triggers now conform
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_bad_count INT;
BEGIN
  SELECT count(*) INTO v_bad_count
  FROM pg_trigger
  WHERE tgrelid = 'products'::regclass
    AND NOT tgisinternal
    AND tgname !~ '^(trg_products_|products_\d+_)';

  IF v_bad_count > 0 THEN
    RAISE WARNING '⚠ % trigger(s) on products still do not follow naming convention', v_bad_count;
  ELSE
    RAISE NOTICE '✅ All products triggers conform to naming convention';
  END IF;
END $$;

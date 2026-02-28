-- Data freshness tracking — Phase 1 of Issue #357
--
-- Adds per-product freshness tracking columns:
--   • last_fetched_at  — when data was last fetched/refreshed from source API
--   • off_revision     — Open Food Facts internal revision number at time of fetch
--
-- Backfills last_fetched_at from created_at for all existing products.
--
-- Creates v_data_freshness_summary view for monitoring freshness by category/country.
--
-- Rollback: ALTER TABLE products DROP COLUMN IF EXISTS last_fetched_at, DROP COLUMN IF EXISTS off_revision;
--           DROP VIEW IF EXISTS v_data_freshness_summary;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Add columns
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS last_fetched_at timestamptz,
  ADD COLUMN IF NOT EXISTS off_revision    integer;

COMMENT ON COLUMN products.last_fetched_at IS
  'Timestamp when this product was last fetched or refreshed from the source API (OFF).';
COMMENT ON COLUMN products.off_revision IS
  'Open Food Facts internal revision number at time of last fetch.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Backfill existing products — set last_fetched_at to created_at
-- ═══════════════════════════════════════════════════════════════════════════════

UPDATE products
SET last_fetched_at = created_at
WHERE last_fetched_at IS NULL
  AND created_at IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Check constraint — last_fetched_at must not be in the future
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_products_last_fetched_not_future'
  ) THEN
    ALTER TABLE products
      ADD CONSTRAINT chk_products_last_fetched_not_future
      CHECK (last_fetched_at <= now() + interval '1 hour');
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Check constraint — off_revision must be positive
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_products_off_revision_positive'
  ) THEN
    ALTER TABLE products
      ADD CONSTRAINT chk_products_off_revision_positive
      CHECK (off_revision IS NULL OR off_revision > 0);
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Index for freshness queries (stale product detection)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_products_last_fetched
  ON products (last_fetched_at)
  WHERE is_deprecated IS NOT TRUE AND last_fetched_at IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Freshness summary view — monitoring dashboard
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW v_data_freshness_summary AS
SELECT
  p.country,
  p.category,
  COUNT(*)                                                        AS total_products,
  COUNT(*) FILTER (WHERE p.last_fetched_at IS NOT NULL)           AS has_fetch_date,
  COUNT(*) FILTER (WHERE p.last_fetched_at >= now() - interval '30 days')  AS fresh_30d,
  COUNT(*) FILTER (WHERE p.last_fetched_at >= now() - interval '90 days'
                     AND p.last_fetched_at <  now() - interval '30 days')  AS aging_30_90d,
  COUNT(*) FILTER (WHERE p.last_fetched_at <  now() - interval '90 days')  AS stale_90d,
  COUNT(*) FILTER (WHERE p.last_fetched_at IS NULL)               AS never_fetched,
  MIN(p.last_fetched_at)                                          AS oldest_fetch,
  MAX(p.last_fetched_at)                                          AS newest_fetch,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE p.last_fetched_at >= now() - interval '90 days')
    / NULLIF(COUNT(*), 0), 1
  )                                                                AS pct_fresh
FROM products p
WHERE p.is_deprecated IS NOT TRUE
GROUP BY p.country, p.category
ORDER BY pct_fresh NULLS LAST, p.country, p.category;

COMMENT ON VIEW v_data_freshness_summary IS
  'Per-country, per-category freshness breakdown. Used for monitoring data staleness.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Grant permissions
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT SELECT ON v_data_freshness_summary TO anon, authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. Update v_master to include last_fetched_at
-- ═══════════════════════════════════════════════════════════════════════════════

-- v_master already selects p.* columns, so last_fetched_at and off_revision
-- are automatically included via the products table alias. No v_master change needed.

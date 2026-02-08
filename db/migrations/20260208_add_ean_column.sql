-- Add EAN (barcode) column to products table
-- Planned migration from DATA_SOURCES.md §12.1
-- EANs are critical for matching products across sources (label ↔ OFF ↔ retailer).
-- Last updated: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Add EAN column (nullable)
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS ean TEXT;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Create unique index on EAN (conditional — allows multiple NULLs)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE UNIQUE INDEX IF NOT EXISTS products_ean_uniq
  ON public.products (ean)
  WHERE ean IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- Notes:
-- ═══════════════════════════════════════════════════════════════════════════
--
-- EAN-13 format:
--   - Store as TEXT (not numeric) to preserve leading zeros
--   - Always 13 digits (e.g., '5900259000002')
--   - One EAN = one product SKU (reformulations get updated in-place, not new rows)
--   - Multi-pack EANs are different products from single-pack EANs
--   - Private labels & bulk items may not have universal EANs (NULL allowed)
--
-- Usage:
--   - Open Food Facts lookup: https://world.openfoodfacts.org/product/{EAN}
--   - Must verify Polish label image before trusting OFF data
--   - For cross-validation against authority (IŻŻ tables, manufacturer sites)
--

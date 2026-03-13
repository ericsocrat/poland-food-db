-- Migration: add 'scraper' to products.source_type CHECK constraint
-- Purpose: Enable automated retailer scrapers (#863) to mark their provenance
-- Rollback: ALTER TABLE products DROP CONSTRAINT chk_products_source_type;
--           ALTER TABLE products ADD CONSTRAINT chk_products_source_type
--             CHECK (source_type IS NULL OR source_type IN ('off_api','manual','off_search','csv_import'));

ALTER TABLE public.products
  DROP CONSTRAINT IF EXISTS chk_products_source_type;

ALTER TABLE public.products
  ADD CONSTRAINT chk_products_source_type
  CHECK (source_type IS NULL OR source_type IN (
    'off_api', 'manual', 'off_search', 'csv_import', 'scraper'
  ));

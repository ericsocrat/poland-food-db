-- Migration: Add scan_country + suggested_country to product_submissions
-- Purpose: Captures user's catalog region at submission time and the country the
--          user believes the product belongs to. Enables country-aware admin routing
--          and downstream country-scoped submission dedup.
-- Nullable: Existing rows have no country context; old API callers still work.
-- Rollback: ALTER TABLE public.product_submissions DROP COLUMN IF EXISTS scan_country;
--           ALTER TABLE public.product_submissions DROP COLUMN IF EXISTS suggested_country;
-- Issue: #922 | Epic: #920

ALTER TABLE public.product_submissions
  ADD COLUMN IF NOT EXISTS scan_country text
  REFERENCES public.country_ref(country_code);

ALTER TABLE public.product_submissions
  ADD COLUMN IF NOT EXISTS suggested_country text
  REFERENCES public.country_ref(country_code);

-- Index for admin filtering by suggested country
CREATE INDEX IF NOT EXISTS idx_ps_suggested_country
  ON public.product_submissions (suggested_country)
  WHERE suggested_country IS NOT NULL;

-- FK-support index for scan_country (required by QA FK-coverage checks)
CREATE INDEX IF NOT EXISTS idx_ps_scan_country
  ON public.product_submissions (scan_country)
  WHERE scan_country IS NOT NULL;

COMMENT ON COLUMN public.product_submissions.scan_country IS
  'User catalog region at submission time (from user_preferences.country). NULL for legacy rows.';

COMMENT ON COLUMN public.product_submissions.suggested_country IS
  'Country the user believes this product belongs to. Defaults to scan_country, user-editable. NULL for legacy rows.';

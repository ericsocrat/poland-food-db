-- Migration: Add scan_country to scan_history
-- Purpose: Captures user's catalog region at scan time (from user_preferences.country).
--          Enables country-scoped scan analytics and downstream country-aware features.
-- Nullable: Existing rows have no country context; old API callers still work.
-- Rollback: ALTER TABLE public.scan_history DROP COLUMN IF EXISTS scan_country;
-- Issue: #921 | Epic: #920

ALTER TABLE public.scan_history
  ADD COLUMN IF NOT EXISTS scan_country text
  REFERENCES public.country_ref(country_code);

-- Partial index for country-scoped analytics queries
CREATE INDEX IF NOT EXISTS idx_sh_country
  ON public.scan_history (scan_country)
  WHERE scan_country IS NOT NULL;

COMMENT ON COLUMN public.scan_history.scan_country IS
  'User catalog region at scan time (from user_preferences.country). NULL for legacy rows.';

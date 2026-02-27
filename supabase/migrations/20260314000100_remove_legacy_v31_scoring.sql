-- ============================================================================
-- Migration: Remove legacy compute_unhealthiness_v31() scoring function
-- Issue:     #447
-- Purpose:   Drop dead code — v31 was superseded by v32 in migration
--            20260210001900_ingredient_concern_scoring.sql. No active callers.
-- Rollback:  Re-create from 20260210001000_prep_method_not_null_and_scoring_v31b.sql
-- ============================================================================

-- Revoke any leftover grants (idempotent — silent if already revoked)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname = 'compute_unhealthiness_v31'
  ) THEN
    REVOKE ALL ON FUNCTION public.compute_unhealthiness_v31(
      numeric, numeric, numeric, numeric, numeric, numeric, text, text
    ) FROM anon, authenticated;
  END IF;
END $$;

-- Drop the function (idempotent)
DROP FUNCTION IF EXISTS public.compute_unhealthiness_v31(
  numeric, numeric, numeric, numeric, numeric, numeric, text, text
);

-- Migration: Create reusable scoring function
-- Date: 2026-02-07
-- Purpose: DRY up the v3.1 unhealthiness formula into a single PostgreSQL function.
--          All 5 category pipelines now call compute_unhealthiness_v31() instead of
--          each duplicating ~15 lines of identical scoring SQL.
--          Changing weights or ceilings in a future v3.2 only requires editing this function.

-- ═══════════════════════════════════════════════════════════════════════════
-- compute_unhealthiness_v31()
-- Implements the 8-factor weighted scoring formula documented in
-- SCORING_METHODOLOGY.md §2.3.
--
-- Parameters:
--   p_saturated_fat_g  — per 100g          (ceiling: 10g)
--   p_sugars_g         — per 100g          (ceiling: 27g)
--   p_salt_g           — per 100g          (ceiling: 3g)
--   p_calories         — kcal per 100g     (ceiling: 600 kcal)
--   p_trans_fat_g      — per 100g          (ceiling: 2g)
--   p_additives_count  — integer count     (ceiling: 10)
--   p_prep_method      — categorical text  (air-popped|baked|fried|deep-fried|*)
--   p_controversies    — categorical text  (none|minor|moderate|serious|*)
--
-- Returns: INTEGER [1, 100]
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_unhealthiness_v31(
    p_saturated_fat_g NUMERIC,
    p_sugars_g        NUMERIC,
    p_salt_g          NUMERIC,
    p_calories        NUMERIC,
    p_trans_fat_g     NUMERIC,
    p_additives_count NUMERIC,
    p_prep_method     TEXT,
    p_controversies   TEXT
) RETURNS INTEGER
LANGUAGE SQL IMMUTABLE
AS $$
    SELECT GREATEST(1, LEAST(100, round(
        LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) * 0.18 +
        LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) * 0.18 +
        LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) * 0.18 +
        LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) * 0.10 +
        LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) * 0.12 +
        LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) * 0.07 +
        (CASE p_prep_method
           WHEN 'air-popped' THEN 20 WHEN 'baked' THEN 40
           WHEN 'fried' THEN 80 WHEN 'deep-fried' THEN 100 ELSE 50
         END) * 0.09 +
        (CASE p_controversies
           WHEN 'none' THEN 0 WHEN 'minor' THEN 30
           WHEN 'moderate' THEN 60 WHEN 'serious' THEN 100 ELSE 0
         END) * 0.08
    )))::integer;
$$;

COMMENT ON FUNCTION public.compute_unhealthiness_v31 IS
  'v3.1 unhealthiness score: 8-factor weighted sum, clamped [1,100]. See SCORING_METHODOLOGY.md §2.3.';

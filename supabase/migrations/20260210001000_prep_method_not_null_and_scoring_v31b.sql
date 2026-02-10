-- Migration: Make prep_method NOT NULL + enhance scoring for smoked foods
-- Created: 2026-02-10
--
-- 1. Add DEFAULT + NOT NULL constraint on products.prep_method
--    (all 560 active products already have values; prevents future NULLs)
-- 2. Update compute_unhealthiness_v31() to differentiate:
--    - 'smoked' → 65 (PAH exposure from smoking, EFSA concern)
--    - 'steamed' → 30 (healthiest cooking method, no harmful compounds)
--    - 'grilled' → 60 (HCA formation at high temperatures)

-- ──────────────────────────────────────────────────────────────
-- 1. Make prep_method NOT NULL with sensible default
-- ──────────────────────────────────────────────────────────────
ALTER TABLE products ALTER COLUMN prep_method SET DEFAULT 'not-applicable';
ALTER TABLE products ALTER COLUMN prep_method SET NOT NULL;

-- ──────────────────────────────────────────────────────────────
-- 2. Update scoring function: differentiate smoked/steamed/grilled
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION compute_unhealthiness_v31(
    p_saturated_fat_g NUMERIC,
    p_sugars_g        NUMERIC,
    p_salt_g          NUMERIC,
    p_calories        NUMERIC,
    p_trans_fat_g     NUMERIC,
    p_additives_count NUMERIC,
    p_prep_method     TEXT,
    p_controversies   TEXT
)
RETURNS INTEGER
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT GREATEST(1, LEAST(100, round(
        LEAST(100, COALESCE(p_saturated_fat_g, 0) / 10.0 * 100) * 0.18 +
        LEAST(100, COALESCE(p_sugars_g, 0)        / 27.0 * 100) * 0.18 +
        LEAST(100, COALESCE(p_salt_g, 0)           / 3.0  * 100) * 0.18 +
        LEAST(100, COALESCE(p_calories, 0)         / 600.0 * 100) * 0.10 +
        LEAST(100, COALESCE(p_trans_fat_g, 0)      / 2.0  * 100) * 0.12 +
        LEAST(100, COALESCE(p_additives_count, 0)  / 10.0 * 100) * 0.07 +
        (CASE p_prep_method
           WHEN 'air-popped'  THEN 20
           WHEN 'steamed'     THEN 30
           WHEN 'baked'       THEN 40
           WHEN 'grilled'     THEN 60
           WHEN 'smoked'      THEN 65
           WHEN 'fried'       THEN 80
           WHEN 'deep-fried'  THEN 100
           ELSE 50  -- not-applicable, none, marinated, fermented, etc.
         END) * 0.09 +
        (CASE p_controversies
           WHEN 'none' THEN 0 WHEN 'minor' THEN 30
           WHEN 'moderate' THEN 60 WHEN 'serious' THEN 100 ELSE 0
         END) * 0.08
    )))::integer;
$$;

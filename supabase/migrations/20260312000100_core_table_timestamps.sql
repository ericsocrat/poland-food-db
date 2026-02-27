-- ==========================================================================
-- Migration: 20260312000100_core_table_timestamps.sql
-- Purpose:   Add created_at + updated_at to 6 core tables that lack
--            change-tracking timestamps. Reuses existing trg_set_updated_at()
--            trigger function (already on products).
--            Part of #362 — Core Table Timestamps.
-- Rollback:  ALTER TABLE nutrition_facts DROP COLUMN IF EXISTS created_at,
--              DROP COLUMN IF EXISTS updated_at;
--            (repeat for other 5 tables; drop triggers first)
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. nutrition_facts — most impactful: enables stale-nutrition detection
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.nutrition_facts
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_nutrition_facts_updated_at ON public.nutrition_facts;
CREATE TRIGGER trg_nutrition_facts_updated_at
  BEFORE UPDATE ON public.nutrition_facts
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. product_ingredient — tracks when ingredient lists are refreshed
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.product_ingredient
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_product_ingredient_updated_at ON public.product_ingredient;
CREATE TRIGGER trg_product_ingredient_updated_at
  BEFORE UPDATE ON public.product_ingredient
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. product_allergen_info — tracks when allergen data is refreshed
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.product_allergen_info
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_product_allergen_info_updated_at ON public.product_allergen_info;
CREATE TRIGGER trg_product_allergen_info_updated_at
  BEFORE UPDATE ON public.product_allergen_info
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. ingredient_ref — tracks dictionary changes (name corrections, flags)
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.ingredient_ref
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_ingredient_ref_updated_at ON public.ingredient_ref;
CREATE TRIGGER trg_ingredient_ref_updated_at
  BEFORE UPDATE ON public.ingredient_ref
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. category_ref — rarely changes but consistent pattern
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.category_ref
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_category_ref_updated_at ON public.category_ref;
CREATE TRIGGER trg_category_ref_updated_at
  BEFORE UPDATE ON public.category_ref
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. country_ref — rarely changes but consistent pattern
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.country_ref
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_country_ref_updated_at ON public.country_ref;
CREATE TRIGGER trg_country_ref_updated_at
  BEFORE UPDATE ON public.country_ref
  FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

COMMIT;

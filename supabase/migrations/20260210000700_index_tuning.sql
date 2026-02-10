-- Migration: Index tuning
-- Created: 2026-02-10
--
-- 1. Add products.category index (used in every pipeline + QA query)
-- 2. Add products.is_deprecated partial index (every query filters by this)
-- 3. Drop 3 redundant indexes that duplicate primary keys

-- ──────────────────────────────────────────────────────────────
-- ADD missing indexes
-- ──────────────────────────────────────────────────────────────

-- Every pipeline, view, and QA query filters by category
CREATE INDEX IF NOT EXISTS products_category_idx
    ON public.products (category);

-- Every pipeline query uses "is_deprecated IS NOT TRUE"
-- Partial index covers the ~560 active rows (excludes deprecated)
CREATE INDEX IF NOT EXISTS products_active_idx
    ON public.products (product_id)
    WHERE is_deprecated IS NOT TRUE;

-- ──────────────────────────────────────────────────────────────
-- DROP redundant indexes (exact duplicates of primary keys)
-- ──────────────────────────────────────────────────────────────

-- ingredients_product_id_idx duplicates ingredients_pkey (both btree on product_id)
DROP INDEX IF EXISTS public.ingredients_product_id_idx;

-- scores_product_id_idx duplicates scores_pkey (both btree on product_id)
DROP INDEX IF EXISTS public.scores_product_id_idx;

-- nutrition_facts_product_serving_idx duplicates nutrition_facts_pkey
-- (both btree on product_id, serving_id)
DROP INDEX IF EXISTS public.nutrition_facts_product_serving_idx;

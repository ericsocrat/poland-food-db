-- Migration: Fix QA Suite 35 orphan junction rows + Suite 41 missing FK index
-- Rollback: DROP INDEX IF EXISTS idx_prod_ingr_parent;
--           (orphan deletions are not reversible but are semantically correct)
-- Idempotency: DELETE is conditional; CREATE INDEX IF NOT EXISTS

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Clean up orphan product_store_availability rows for deprecated products
--    QA Suite 35 (StoreArch) Check #5: products that are deleted or deprecated
--    but still have junction rows in product_store_availability.
-- ═══════════════════════════════════════════════════════════════════════════════

DELETE FROM public.product_store_availability psa
WHERE NOT EXISTS (
    SELECT 1 FROM public.products p
    WHERE p.product_id = psa.product_id
      AND p.is_deprecated IS NOT TRUE
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Backfill missing product_store_availability rows
--    QA Suite 35 (StoreArch) Check #12: products with store_availability set
--    but no matching junction row in product_store_availability.
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.product_store_availability (product_id, store_id, source)
SELECT p.product_id, sr.store_id, 'pipeline'
FROM public.products p
JOIN public.store_ref sr
    ON sr.country = p.country
    AND sr.store_name = p.store_availability
WHERE p.store_availability IS NOT NULL
  AND p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
      SELECT 1 FROM public.product_store_availability psa
      WHERE psa.product_id = p.product_id
        AND psa.store_id = sr.store_id
  )
ON CONFLICT (product_id, store_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Add missing index on product_ingredient.parent_ingredient_id
--    QA Suite 41 (IdxVerify) Check #13: FK column without supporting index.
--    Used in sub-ingredient lookups and ON DELETE/UPDATE cascade operations.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_prod_ingr_parent
    ON public.product_ingredient (parent_ingredient_id)
    WHERE parent_ingredient_id IS NOT NULL;

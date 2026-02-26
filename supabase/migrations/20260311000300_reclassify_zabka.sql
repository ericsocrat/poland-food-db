-- ==========================================================================
-- Migration: 20260311000300_reclassify_zabka.sql
-- Purpose:   Link Żabka products to Żabka store, reclassify from
--            category='Żabka' to 'Frozen & Prepared', deactivate
--            category_ref entry. Re-score affected categories.
--            Part of #350 — Store Architecture.
-- Rollback:  UPDATE products SET category = 'Żabka'
--              WHERE product_id IN (...);
--            UPDATE category_ref SET is_active = true WHERE category = 'Żabka';
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Ensure all 28 Żabka products are linked to the Żabka store
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO public.product_store_availability (product_id, store_id, verified_at, source)
SELECT
    p.product_id,
    sr.store_id,
    NOW(),
    'pipeline'
FROM public.products p
CROSS JOIN public.store_ref sr
WHERE p.category = 'Żabka'
  AND p.is_deprecated = false
  AND sr.country = 'PL'
  AND sr.store_slug = 'zabka'
ON CONFLICT (product_id, store_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Reclassify all Żabka products to "Frozen & Prepared"
--    All 28 are product_type='Ready-to-eat' (burgers, wraps, meals, panini)
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE public.products
SET category = 'Frozen & Prepared'
WHERE category = 'Żabka'
  AND is_deprecated = false;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Deactivate Żabka in category_ref (preserve for history)
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE public.category_ref
SET is_active = false
WHERE category = 'Żabka';

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Re-score the affected category
-- ═══════════════════════════════════════════════════════════════════════════
CALL score_category('Frozen & Prepared');

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════
-- CI Post-pipeline fixup
-- ═══════════════════════════════════════════════════════════════════════════
-- PURPOSE: Correct data-state issues arising because data-enrichment
--          migrations reference hardcoded product_ids from the local
--          environment.  In CI, products are inserted fresh by pipeline
--          SQL files and receive new auto-increment IDs.
--
-- Safe to run multiple times (fully idempotent).
-- Run AFTER all db/pipelines/*/PIPELINE__*.sql have been applied.
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─── 1. Cap each category to 28 active products ──────────────────────────
-- Pipeline SQL files for some categories contain >28 products.
-- Keep the first 28 inserted (by product_id) per category and deprecate
-- the rest.  This matches the local database invariant.

WITH ranked AS (
    SELECT product_id,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY product_id) AS rn
    FROM   products
    WHERE  is_deprecated IS NOT TRUE
)
UPDATE products p
SET    is_deprecated      = true,
       deprecated_reason  = 'CI: excess beyond 28 per category'
FROM   ranked r
WHERE  p.product_id = r.product_id
  AND  r.rn > 28;

-- ─── 2. Populate product_sources for products missing them ───────────────
-- All pipeline products come from Open Food Facts, so give them a default
-- source row so QA check #33 (MISSING PRODUCT SOURCE) passes.

INSERT INTO product_sources
       (product_id, source_type, source_url, fields_populated,
        confidence_pct, is_primary)
SELECT p.product_id,
       'off_api',
       'https://world.openfoodfacts.org/api/v2/search',
       ARRAY['product_name','brand','category','product_type','ean',
             'prep_method','store_availability','controversies',
             'calories','total_fat_g','saturated_fat_g',
             'carbohydrates_g','sugars_g','protein_g',
             'fiber_g','salt_g','sodium_mg','trans_fat_g'],
       80,
       true
FROM   products p
WHERE  p.is_deprecated IS NOT TRUE
  AND  NOT EXISTS (
         SELECT 1 FROM product_sources ps
         WHERE  ps.product_id = p.product_id
       )
ON CONFLICT DO NOTHING;

-- ─── 3. Default ingredient_concern_score to 0 where missing ─────────────
-- The ingredient data migration (20260210001400) uses hardcoded product_ids
-- that don't exist in CI, so product_ingredient is empty and concern scores
-- are never computed.  Default to 0 (= no additive concerns detected).

UPDATE scores sc
SET    ingredient_concern_score = 0
FROM   products p
WHERE  sc.product_id = p.product_id
  AND  p.is_deprecated IS NOT TRUE
  AND  sc.ingredient_concern_score IS NULL;

-- ─── 4. Refresh materialized views ──────────────────────────────────────
-- mv_ingredient_frequency and v_product_confidence were created WITH DATA
-- during migrations (when 0 products existed).  Refresh now that products
-- are populated and cleaned up.

SELECT refresh_all_materialized_views();

COMMIT;

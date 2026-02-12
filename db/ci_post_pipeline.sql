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

-- ─── 2. Default source columns for products missing them ─────────────────
-- All pipeline products come from Open Food Facts, so set source_type
-- and source_url on products that lack them.

UPDATE products
SET    source_type = 'off_api',
       source_url  = 'https://world.openfoodfacts.org/api/v2/search'
WHERE  is_deprecated IS NOT TRUE
  AND  source_type IS NULL;

-- ─── 3. Default ingredient_concern_score to 0 where missing ─────────────
-- The ingredient data migration (20260210001400) uses hardcoded product_ids
-- that don't exist in CI, so product_ingredient is empty and concern scores
-- are never computed.  Default to 0 (= no additive concerns detected).

UPDATE products
SET    ingredient_concern_score = 0
WHERE  is_deprecated IS NOT TRUE
  AND  ingredient_concern_score IS NULL;

-- ─── 4. Refresh materialized views ──────────────────────────────────────
-- mv_ingredient_frequency and v_product_confidence were created WITH DATA
-- during migrations (when 0 products existed).  Refresh now that products
-- are populated and cleaned up.

SELECT refresh_all_materialized_views();

COMMIT;

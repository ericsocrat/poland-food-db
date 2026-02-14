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

-- ─── 1. (Removed) ───────────────────────────────────────────────────────
-- Previously capped each category to 28 active products.  This was stale:
-- local categories range from 9 to 98 products.  CI now runs the full
-- dataset so that QA checks are validated against the same data shape
-- as the local environment.

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

-- ─── 4. Populate allergen data ──────────────────────────────────────────
-- The allergen population migration (20260213000500) runs BEFORE pipelines
-- in CI, so its EAN-based JOINs match zero products.  Re-run a subset of
-- the allergen declarations here, after products exist, so allergen-related
-- QA checks have data to validate against.

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT p.product_id, v.tag, v.type
FROM (VALUES
  -- Chips (contain milk / gluten from flavoring ingredients)
  ('PL', '5900073020118', 'en:gluten', 'contains'),
  ('PL', '5900073020118', 'en:milk', 'traces'),
  ('PL', '5905187114760', 'en:milk', 'contains'),
  ('PL', '5905187114760', 'en:gluten', 'contains'),
  ('PL', '5900073020187', 'en:gluten', 'contains'),
  ('PL', '5900073020187', 'en:milk', 'traces'),
  -- Bread (contain gluten)
  ('PL', '5900014005716', 'en:gluten', 'contains'),
  ('PL', '5900535013986', 'en:gluten', 'contains'),
  ('PL', '5900535013986', 'en:milk', 'traces'),
  -- Dairy (contain milk)
  ('PL', '5900014004245', 'en:milk', 'contains'),
  ('PL', '5900699106388', 'en:milk', 'contains'),
  -- Sweets / Snacks (contain milk, gluten, eggs, soybeans)
  ('PL', '5901359074290', 'en:gluten', 'contains'),
  ('PL', '5901359074290', 'en:milk', 'contains'),
  ('PL', '5901359074290', 'en:soybeans', 'traces'),
  ('PL', '5902709615323', 'en:gluten', 'contains'),
  ('PL', '5901359062013', 'en:gluten', 'contains'),
  ('PL', '5901359062013', 'en:eggs', 'contains'),
  ('PL', '5900490000182', 'en:gluten', 'contains'),
  ('PL', '5901359122021', 'en:milk', 'contains'),
  ('PL', '5901359122021', 'en:gluten', 'contains')
) AS v(country, ean, tag, type)
JOIN products p ON p.country = v.country AND p.ean = v.ean
WHERE p.is_deprecated IS NOT TRUE
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ─── 4a. Recalculate data_completeness_pct & confidence ─────────────────
-- The allergen insert above changes the result of compute_data_completeness()
-- for affected products.  Re-sync stored values so QA check 19 passes.

UPDATE products p
SET    data_completeness_pct = compute_data_completeness(p.product_id)
WHERE  p.is_deprecated IS NOT TRUE
  AND  p.data_completeness_pct != compute_data_completeness(p.product_id);

UPDATE products p
SET    confidence = assign_confidence(p.data_completeness_pct, p.source_type)
WHERE  p.is_deprecated IS NOT TRUE
  AND  p.confidence != assign_confidence(p.data_completeness_pct, p.source_type);

-- ─── 5. Refresh materialized views ──────────────────────────────────────
-- mv_ingredient_frequency and v_product_confidence were created WITH DATA
-- during migrations (when 0 products existed).  Refresh now that products
-- are populated and cleaned up.

SELECT refresh_all_materialized_views();

COMMIT;

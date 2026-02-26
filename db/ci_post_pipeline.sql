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

-- ─── 3a. Deprecate products with wrong data or miscategorization ────────
-- These products have data quality issues from the OFF API that cause
-- QA nutrition range checks to fail.  They are already deprecated in the
-- local environment but are active in CI (fresh DB from pipeline SQL).

UPDATE products
SET    is_deprecated    = true,
       deprecated_reason = 'OFF API data error: kJ stored as kcal'
WHERE  country = 'DE'
  AND  brand   = 'Goldähren'
  AND  product_name IN ('Eiweiss Brot', 'Mehrkornschnitten')
  AND  is_deprecated IS NOT TRUE;

UPDATE products
SET    is_deprecated    = true,
       deprecated_reason = 'OFF API data error: calorie/macro mismatch'
WHERE  country = 'DE'
  AND  brand   = 'Milram'
  AND  product_name = 'Benjamin'
  AND  is_deprecated IS NOT TRUE;

UPDATE products
SET    is_deprecated    = true,
       deprecated_reason = 'Miscategorized: seasoning in Alcohol/Baby pipeline'
WHERE  brand        = 'Nestlé'
  AND  product_name = 'Przyprawa Maggi'
  AND  category IN ('Alcohol', 'Baby')
  AND  is_deprecated IS NOT TRUE;

UPDATE products
SET    is_deprecated    = true,
       deprecated_reason = 'Miscategorized: dairy product in Baby pipeline'
WHERE  brand        = 'Mlekovita'
  AND  product_name LIKE 'Bezwodny tłuszcz mleczny%'
  AND  category = 'Baby'
  AND  is_deprecated IS NOT TRUE;

-- ─── 3b. Fix data errors in nutrition_facts ─────────────────────────────
-- Pano "Chleb wieloziarnisty Złoty Łan" has salt=13.0 in pipeline SQL
-- (OFF API decimal error).  The sibling product has salt=1.3.

UPDATE nutrition_facts
SET    salt_g = 1.3
WHERE  product_id = (
         SELECT product_id FROM products
         WHERE  brand = 'Pano'
           AND  product_name = 'Chleb wieloziarnisty Złoty Łan'
           AND  category = 'Bread'
           AND  country = 'PL'
       )
  AND  salt_g = 13.0;

-- Re-score the Bread category so the salt fix produces correct
-- unhealthiness_score, high_salt_flag, completeness, and confidence.
CALL score_category('Bread');

-- ─── 4. Populate allergen data ──────────────────────────────────────────
-- The allergen population migration (20260213000500) runs BEFORE pipelines
-- in CI, so its EAN-based JOINs match zero products.  Re-run a subset of
-- the allergen declarations here, after products exist, so allergen-related
-- QA checks have data to validate against.

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT p.product_id, v.tag, v.type
FROM (VALUES
  -- Chips (contain milk / gluten from flavoring ingredients)
  ('PL', '5900073020118', 'gluten', 'contains'),
  ('PL', '5900073020118', 'milk', 'traces'),
  ('PL', '5905187114760', 'milk', 'contains'),
  ('PL', '5905187114760', 'gluten', 'contains'),
  ('PL', '5900073020187', 'gluten', 'contains'),
  ('PL', '5900073020187', 'milk', 'traces'),
  -- Bread (contain gluten)
  ('PL', '5900014005716', 'gluten', 'contains'),
  ('PL', '5900535013986', 'gluten', 'contains'),
  ('PL', '5900535013986', 'milk', 'traces'),
  -- Dairy (contain milk)
  ('PL', '5900014004245', 'milk', 'contains'),
  ('PL', '5900699106388', 'milk', 'contains'),
  -- Sweets / Snacks (contain milk, gluten, eggs, soybeans)
  ('PL', '5901359074290', 'gluten', 'contains'),
  ('PL', '5901359074290', 'milk', 'contains'),
  ('PL', '5901359074290', 'soybeans', 'traces'),
  ('PL', '5902709615323', 'gluten', 'contains'),
  ('PL', '5901359062013', 'gluten', 'contains'),
  ('PL', '5901359062013', 'eggs', 'contains'),
  ('PL', '5900490000182', 'gluten', 'contains'),
  ('PL', '5901359122021', 'milk', 'contains'),
  ('PL', '5901359122021', 'gluten', 'contains')
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

-- ─── 5. Store architecture: reclassify Żabka + backfill junction ────────
-- Migration 000300 reclassifies Żabka products and 000200 backfills the
-- product_store_availability junction, but both run on an empty DB in CI.
-- Re-run the logic here after pipelines have populated products.

-- 5a. Link Żabka-brand products to Żabka store
INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT p.product_id, sr.store_id, NOW(), 'pipeline'
FROM products p
CROSS JOIN store_ref sr
WHERE p.category = 'Żabka'
  AND p.is_deprecated = false
  AND sr.country = 'PL'
  AND sr.store_slug = 'zabka'
ON CONFLICT (product_id, store_id) DO NOTHING;

-- 5b. Reclassify Żabka products → Frozen & Prepared
UPDATE products
SET    category = 'Frozen & Prepared'
WHERE  category = 'Żabka'
  AND  is_deprecated = false;

-- 5c. Re-score affected category
CALL score_category('Frozen & Prepared');

-- 5d. Backfill junction for all products with store_availability set
INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT p.product_id, sr.store_id, NOW(), 'pipeline'
FROM products p
JOIN store_ref sr
  ON sr.country = p.country
 AND sr.store_name = p.store_availability
WHERE p.store_availability IS NOT NULL
  AND p.is_deprecated = false
ON CONFLICT (product_id, store_id) DO NOTHING;

-- ─── 6. Refresh materialized views ──────────────────────────────────────
-- mv_ingredient_frequency and v_product_confidence were created WITH DATA
-- during migrations (when 0 products existed).  Refresh now that products
-- are populated and cleaned up.

SELECT refresh_all_materialized_views();

COMMIT;

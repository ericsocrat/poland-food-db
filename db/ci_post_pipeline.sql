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
-- After the enrichment replay step (qa.yml), most products have real
-- concern scores computed from product_ingredient data.  This fallback
-- covers any products that were not enriched (no EAN match, no OFF data).

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

-- Remove junction-table data for deprecated products so MV row counts
-- stay consistent (mv_ingredient_frequency JOINs on active products only).
DELETE FROM product_ingredient
WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);

DELETE FROM product_allergen_info
WHERE product_id IN (SELECT product_id FROM products WHERE is_deprecated = true);

-- Remove orphan ingredient_ref entries left behind
DELETE FROM ingredient_ref
WHERE NOT EXISTS (
    SELECT 1 FROM product_ingredient pi WHERE pi.ingredient_id = ingredient_ref.ingredient_id
)
AND EXISTS (SELECT 1 FROM product_ingredient LIMIT 1);

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

-- (Bread re-scoring deferred to step 7 — full re-score pass)

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

-- 5c. (F&P re-scoring deferred to step 7 — full re-score pass)

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

-- ─── 6. Backfill nutri_score_source for pipeline products ────────────────
-- The nutri_score_provenance migration (#353) runs BEFORE pipelines in CI,
-- so its backfill UPDATE matches 0 products. Re-run the same logic here
-- after products exist, so QA check 22 (scored products must have source) passes.

UPDATE products
SET nutri_score_source = CASE
  WHEN nutri_score_label IS NULL            THEN NULL
  WHEN nutri_score_label = 'NOT-APPLICABLE' THEN NULL
  WHEN nutri_score_label = 'UNKNOWN'        THEN 'unknown'
  ELSE 'off_computed'
END
WHERE is_deprecated IS NOT TRUE
  AND nutri_score_source IS NULL
  AND nutri_score_label IS NOT NULL;

-- ─── 6a. Seed brand_ref from pipeline products ──────────────────────────
-- The brand_ref migration (20260315001200) auto-seeds from products, but
-- in CI migrations run BEFORE pipeline data is loaded, so the table is
-- empty.  Re-run the auto-seed + enrichment here after products exist.

INSERT INTO public.brand_ref (brand_name, display_name)
SELECT DISTINCT brand, brand
FROM public.products
WHERE brand IS NOT NULL
  AND is_deprecated IS NOT TRUE
ON CONFLICT (brand_name) DO NOTHING;

-- Store brands (Polish retailers)
UPDATE public.brand_ref SET is_store_brand = true, country_origin = 'PL'
WHERE brand_name IN (
  'Biedronka', 'Top Biedronka',
  'Żabka',
  'Auchan',
  'Carrefour',
  'Dino'
) AND is_store_brand = false;

-- Store brands (German/international retailers)
UPDATE public.brand_ref SET is_store_brand = true, country_origin = 'DE'
WHERE brand_name IN ('Lidl', 'Aldi')
AND is_store_brand = false;

-- Major international brands — parent companies + origins
UPDATE public.brand_ref SET parent_company = 'PepsiCo', country_origin = 'US'
WHERE brand_name IN ('Pepsi', 'Doritos', 'Lay''s', 'Lays', 'Cheetos')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'The Coca-Cola Company', country_origin = 'US'
WHERE brand_name IN ('Coca-Cola', 'Fanta', 'Sprite', 'Costa Coffee')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mondelēz International', country_origin = 'US'
WHERE brand_name IN ('Milka', 'Oreo', 'Philadelphia', 'Cadbury')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Oetker Group', country_origin = 'DE'
WHERE brand_name IN ('Dr. Oetker', 'Dr.Oetker')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Nestlé', country_origin = 'CH'
WHERE brand_name IN ('Nestlé', 'Nestle', 'Nescafé', 'Maggi', 'Winiary')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Unilever', country_origin = 'NL'
WHERE brand_name IN ('Knorr', 'Hellmann''s', 'Lipton')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Danone', country_origin = 'FR'
WHERE brand_name IN ('Danone', 'Żywiec Zdrój', 'Alpro')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Barilla Group', country_origin = 'IT'
WHERE brand_name IN ('Barilla', 'Wasa')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Ferrero', country_origin = 'IT'
WHERE brand_name IN ('Ferrero', 'Kinder', 'Nutella')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mars, Inc.', country_origin = 'US'
WHERE brand_name IN ('Mars', 'Snickers', 'M&M''s', 'Twix', 'Uncle Ben''s')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Schwarz Group', country_origin = 'DE'
WHERE brand_name IN ('GutBio', 'Gut bio', 'Vemondo')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Maspex', country_origin = 'PL'
WHERE brand_name IN ('Kubuś', 'Tymbark', 'Lubella', 'DecoMorreno')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Colian', country_origin = 'PL'
WHERE brand_name IN ('Goplana', 'Solidarność', 'Grześki', 'Jeżyki')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Lotte Wedel', country_origin = 'PL'
WHERE brand_name IN ('E. Wedel', 'Wedel')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Tarczyński S.A.', country_origin = 'PL'
WHERE brand_name IN ('Tarczyński')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Kellogg Company', country_origin = 'US'
WHERE brand_name IN ('Kellogg''s', 'Pringles')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Hochland', country_origin = 'DE'
WHERE brand_name IN ('Hochland', 'Almette')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Lorenz Snack-World', country_origin = 'DE'
WHERE brand_name IN ('Lorenz', 'Crunchips')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mestemacher', country_origin = 'DE'
WHERE brand_name = 'Mestemacher'
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Carlsberg Group', country_origin = 'DK'
WHERE brand_name IN ('Carlsberg', 'Somersby')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Heineken', country_origin = 'NL'
WHERE brand_name IN ('Heineken', 'Żywiec')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Asahi Group', country_origin = 'JP'
WHERE brand_name IN ('Tyskie', 'Lech', 'Kompania Piwowarska')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Indofood', country_origin = 'ID'
WHERE brand_name IN ('Indomie')
AND parent_company IS NULL;

-- ─── 7. Final re-scoring pass ─────────────────────────────────────────────
-- Earlier steps deprecate products, fix nutrition data, reclassify Żabka,
-- and backfill source columns.  These changes affect scoring inputs
-- (ingredient_concern_score, controversies, data_completeness_pct).
-- Rather than tracking which categories are affected, re-score ALL
-- categories to ensure scores are consistent after all fixups.
-- This also guarantees ingredient data from the enrichment replay is
-- fully factored into scores (additives count, concern score, palm oil).

CALL score_category('Alcohol');
CALL score_category('Baby');
CALL score_category('Bread');
CALL score_category('Breakfast & Grain-Based');
CALL score_category('Canned Goods');
CALL score_category('Cereals');
CALL score_category('Chips');
CALL score_category('Condiments');
CALL score_category('Dairy');
CALL score_category('Drinks');
CALL score_category('Frozen & Prepared');
CALL score_category('Instant & Frozen');
CALL score_category('Meat');
CALL score_category('Nuts, Seeds & Legumes');
CALL score_category('Plant-Based & Alternatives');
CALL score_category('Sauces');
CALL score_category('Seafood & Fish');
CALL score_category('Snacks');
CALL score_category('Sweets');

-- DE categories (micro-pilot)
CALL score_category('Chips',    p_country := 'DE');
CALL score_category('Bread',    p_country := 'DE');
CALL score_category('Dairy',    p_country := 'DE');
CALL score_category('Drinks',   p_country := 'DE');
CALL score_category('Sweets',   p_country := 'DE');

COMMIT;

-- ─── 8. Refresh materialized views ──────────────────────────────────────
-- mv_ingredient_frequency and v_product_confidence were created WITH DATA
-- during migrations (when 0 products existed).  Refresh now that products
-- are populated, cleaned up, and scored.

SELECT refresh_all_materialized_views();

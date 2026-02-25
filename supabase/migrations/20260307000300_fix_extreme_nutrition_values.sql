-- =============================================================================
-- Migration: Fix extreme nutrition values and category misclassifications
-- Issue: #366
-- Date: 2026-02-25
--
-- Changes:
--   Step 1: Fix confirmed salt decimal error for bread product
--   Step 2: Reclassify 2 misclassified Baby products
--   Step 3: Re-score affected categories
--   Step 4: Refresh materialized views
--
-- Rollback:
--   UPDATE nutrition_facts SET salt_g = 13.0
--     WHERE product_id = (SELECT product_id FROM products
--       WHERE product_name = 'Chleb wieloziarnisty Złoty Łan'
--       AND brand = 'Pano' AND country = 'PL');
--   UPDATE products SET category = 'Baby'
--     WHERE product_id IN (23, 44);  -- Przyprawa Maggi, Bezwodny tłuszcz mleczny
--   CALL score_category('Bread');
--   CALL score_category('Baby');
--   CALL score_category('Condiments');
--   CALL score_category('Dairy');
-- =============================================================================

-- ─── Step 1: Fix bread salt decimal error ────────────────────────────────────
-- Product: "Chleb wieloziarnisty Złoty Łan" (Pano, EAN 5900340007347)
-- Current: 13.0g salt/100g — impossible for bread (normal range: 0.8-1.5g/100g)
-- Evidence: Sister product "Chleb wieloziarnisty złoty łan" (EAN 5901486007406)
--   has 1.0g salt. OFF API also reports 13g (community data entry error in OFF).
-- Fix: 1.3g (likely decimal shift 1.3 → 13.0)
UPDATE nutrition_facts
SET salt_g = 1.3
WHERE product_id = (
    SELECT product_id FROM products
    WHERE product_name = 'Chleb wieloziarnisty Złoty Łan'
      AND brand = 'Pano'
      AND country = 'PL'
)
AND salt_g = 13.0;  -- Guard: only apply if still at error value

-- ─── Step 2: Reclassify misclassified Baby products ─────────────────────────
-- Product: "Przyprawa Maggi" (Nestlé) — OFF category: en:condiments
-- This is a seasoning/condiment, not baby food.
UPDATE products
SET category = 'Condiments'
WHERE product_name = 'Przyprawa Maggi'
  AND brand = 'Nestlé'
  AND country = 'PL'
  AND category = 'Baby';  -- Guard: only apply if still in Baby

-- Product: "Bezwodny tłuszcz mleczny, Masło klarowane" (Mlekovita)
-- OFF category: pl:masła-klarowane (clarified butter)
-- This is a dairy cooking fat, not baby food.
UPDATE products
SET category = 'Dairy'
WHERE product_name = 'Bezwodny tłuszcz mleczny, Masło klarowane'
  AND brand = 'Mlekovita'
  AND country = 'PL'
  AND category = 'Baby';  -- Guard: only apply if still in Baby

-- ─── Step 3: Re-score affected categories ────────────────────────────────────
-- Bread: salt correction changes unhealthiness_score
-- Baby: 2 products removed → category stats change
-- Condiments: 1 product added (Maggi)
-- Dairy: 1 product added (Bezwodny tłuszcz)
CALL score_category('Bread');
CALL score_category('Baby');
CALL score_category('Condiments');
CALL score_category('Dairy');

-- ─── Step 4: Refresh materialized views ──────────────────────────────────────
SELECT refresh_all_materialized_views();

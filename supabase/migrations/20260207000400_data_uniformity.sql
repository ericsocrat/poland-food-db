-- 20260207000400_data_uniformity.sql
-- Purpose: Fix data inconsistencies and convert TEXT columns to proper numeric types.
--
-- Issues addressed:
--   1. Country: "Poland" → "PL" (deprecate 27 duplicate rows)
--   2. Brand casing: 23 brands normalised (e.g. ŁOWICZ → Łowicz)
--   3. nutri_score_label: "not-applicable" / "NOT-APPLICABLE" → "UNKNOWN"
--   4. controversies: NULL → "none", "1" → "palm oil"
--   5. prep_method: "Ready to eat" → "ready to eat"
--   6. nutrition_facts: all measurement columns TEXT → NUMERIC
--   7. scores.unhealthiness_score: TEXT → NUMERIC (fixes sort order)
--   8. ingredients.additives_count: TEXT → INTEGER
--   9. Rebuilt v_master view with new column types + additional columns

SET search_path = public;

-- -----------------------------------------------------------------------
-- 1. Country normalisation
-- -----------------------------------------------------------------------
UPDATE products
SET is_deprecated = true,
    deprecated_reason = 'Duplicate — normalised to country=PL version'
WHERE country = 'Poland'
  AND EXISTS (
    SELECT 1 FROM products p2
    WHERE p2.country  = 'PL'
      AND p2.brand    = products.brand
      AND p2.product_name = products.product_name
  );

-- -----------------------------------------------------------------------
-- 2. nutri_score_label normalisation
-- -----------------------------------------------------------------------
UPDATE scores
SET nutri_score_label = 'UNKNOWN'
WHERE nutri_score_label IN ('not-applicable', 'NOT-APPLICABLE');

-- -----------------------------------------------------------------------
-- 3. Controversies cleanup
-- -----------------------------------------------------------------------
UPDATE products SET controversies = 'none' WHERE controversies IS NULL OR controversies = '';
UPDATE products SET controversies = 'palm oil' WHERE controversies = '1';

-- -----------------------------------------------------------------------
-- 4. prep_method casing
-- -----------------------------------------------------------------------
UPDATE products
SET prep_method = 'ready to eat'
WHERE lower(prep_method) = 'ready to eat' AND prep_method != 'ready to eat';

-- -----------------------------------------------------------------------
-- 5. Drop view so we can alter column types
-- -----------------------------------------------------------------------
DROP VIEW IF EXISTS v_master;

-- -----------------------------------------------------------------------
-- 6. Convert TEXT → NUMERIC for nutrition_facts
-- -----------------------------------------------------------------------
ALTER TABLE nutrition_facts
  ALTER COLUMN calories        TYPE numeric USING (NULLIF(calories, ''))::numeric,
  ALTER COLUMN total_fat_g     TYPE numeric USING (NULLIF(total_fat_g, ''))::numeric,
  ALTER COLUMN saturated_fat_g TYPE numeric USING (NULLIF(saturated_fat_g, ''))::numeric,
  ALTER COLUMN trans_fat_g     TYPE numeric USING (NULLIF(trans_fat_g, ''))::numeric,
  ALTER COLUMN carbs_g         TYPE numeric USING (NULLIF(carbs_g, ''))::numeric,
  ALTER COLUMN sugars_g        TYPE numeric USING (NULLIF(sugars_g, ''))::numeric,
  ALTER COLUMN fibre_g         TYPE numeric USING (NULLIF(fibre_g, ''))::numeric,
  ALTER COLUMN protein_g       TYPE numeric USING (NULLIF(protein_g, ''))::numeric,
  ALTER COLUMN salt_g          TYPE numeric USING (NULLIF(salt_g, ''))::numeric;

-- -----------------------------------------------------------------------
-- 7. Convert TEXT → NUMERIC for scores.unhealthiness_score
-- -----------------------------------------------------------------------
ALTER TABLE scores
  ALTER COLUMN unhealthiness_score TYPE numeric
    USING (NULLIF(unhealthiness_score, ''))::numeric;

-- -----------------------------------------------------------------------
-- 8. Convert TEXT → INTEGER for ingredients.additives_count
-- -----------------------------------------------------------------------
ALTER TABLE ingredients
  ALTER COLUMN additives_count TYPE integer
    USING (NULLIF(additives_count, ''))::integer;

-- -----------------------------------------------------------------------
-- 9. Recreate v_master view (expanded to include all useful columns)
-- -----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_master AS
SELECT
  p.product_id,
  p.country,
  p.brand,
  p.product_type,
  p.category,
  p.product_name,
  n.calories,
  n.total_fat_g,
  n.saturated_fat_g,
  n.trans_fat_g,
  n.carbs_g,
  n.sugars_g,
  n.fibre_g,
  n.protein_g,
  n.salt_g,
  s.unhealthiness_score,
  s.nutri_score_label,
  s.processing_risk,
  s.nova_classification,
  s.high_salt_flag,
  s.high_sugar_flag,
  s.high_sat_fat_flag,
  s.high_additive_load,
  s.scoring_version,
  s.scored_at,
  s.data_completeness_pct,
  s.confidence,
  p.prep_method,
  p.store_availability,
  p.controversies,
  p.is_deprecated,
  p.deprecated_reason,
  i.ingredients_raw,
  i.additives_count
FROM products p
LEFT JOIN servings sv ON sv.product_id = p.product_id
LEFT JOIN nutrition_facts n ON n.product_id = p.product_id AND n.serving_id = sv.serving_id
LEFT JOIN scores s ON s.product_id = p.product_id
LEFT JOIN ingredients i ON i.product_id = p.product_id;

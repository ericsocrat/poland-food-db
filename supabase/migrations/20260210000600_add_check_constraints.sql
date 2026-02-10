-- Migration: add CHECK constraints for domain-restricted columns
-- Date: 2026-02-10
-- Reason: Enforce data integrity at the DB level for columns that have a
--         fixed set of valid values. Prevents invalid data from being inserted
--         by pipelines or manual edits.

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- products table
-- ═══════════════════════════════════════════════════════════════════════════

-- country: currently PL only (extensible per COUNTRY_EXPANSION_GUIDE.md)
ALTER TABLE products
  ADD CONSTRAINT chk_products_country
  CHECK (country IN ('PL'));

-- prep_method: scoring function CASE values + 'not-applicable' + 'none'
ALTER TABLE products
  ADD CONSTRAINT chk_products_prep_method
  CHECK (prep_method IS NULL OR prep_method IN (
    'air-popped', 'baked', 'fried', 'deep-fried', 'none', 'not-applicable'
  ));

-- controversies: known valid values
ALTER TABLE products
  ADD CONSTRAINT chk_products_controversies
  CHECK (controversies IN ('none', 'minor', 'moderate', 'serious', 'palm oil'));

-- ═══════════════════════════════════════════════════════════════════════════
-- scores table
-- ═══════════════════════════════════════════════════════════════════════════

-- unhealthiness_score: function returns [1, 100]
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_unhealthiness_range
  CHECK (unhealthiness_score IS NULL OR (unhealthiness_score >= 1 AND unhealthiness_score <= 100));

-- nutri_score_label: EU Nutri-Score grades + special values
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_nutri_score_label
  CHECK (nutri_score_label IS NULL OR nutri_score_label IN (
    'A', 'B', 'C', 'D', 'E', 'UNKNOWN', 'NOT-APPLICABLE'
  ));

-- confidence: assign_confidence() return values
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_confidence
  CHECK (confidence IS NULL OR confidence IN ('verified', 'estimated', 'low'));

-- nova_classification: NOVA food processing groups (1-4), stored as text
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_nova
  CHECK (nova_classification IS NULL OR nova_classification IN ('1', '2', '3', '4'));

-- processing_risk: derived from NOVA
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_processing_risk
  CHECK (processing_risk IS NULL OR processing_risk IN ('Low', 'Moderate', 'High'));

-- YES/NO flag columns
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_high_salt_flag
  CHECK (high_salt_flag IS NULL OR high_salt_flag IN ('YES', 'NO'));

ALTER TABLE scores
  ADD CONSTRAINT chk_scores_high_sugar_flag
  CHECK (high_sugar_flag IS NULL OR high_sugar_flag IN ('YES', 'NO'));

ALTER TABLE scores
  ADD CONSTRAINT chk_scores_high_sat_fat_flag
  CHECK (high_sat_fat_flag IS NULL OR high_sat_fat_flag IN ('YES', 'NO'));

ALTER TABLE scores
  ADD CONSTRAINT chk_scores_high_additive_load
  CHECK (high_additive_load IS NULL OR high_additive_load IN ('YES', 'NO'));

-- data_completeness_pct: 0-100
ALTER TABLE scores
  ADD CONSTRAINT chk_scores_completeness
  CHECK (data_completeness_pct IS NULL OR (data_completeness_pct >= 0 AND data_completeness_pct <= 100));

-- ═══════════════════════════════════════════════════════════════════════════
-- nutrition_facts table
-- ═══════════════════════════════════════════════════════════════════════════

-- All nutrition values must be non-negative
ALTER TABLE nutrition_facts
  ADD CONSTRAINT chk_nutrition_non_negative
  CHECK (
    COALESCE(calories, 0) >= 0 AND
    COALESCE(total_fat_g, 0) >= 0 AND
    COALESCE(saturated_fat_g, 0) >= 0 AND
    COALESCE(trans_fat_g, 0) >= 0 AND
    COALESCE(carbs_g, 0) >= 0 AND
    COALESCE(sugars_g, 0) >= 0 AND
    COALESCE(fibre_g, 0) >= 0 AND
    COALESCE(protein_g, 0) >= 0 AND
    COALESCE(salt_g, 0) >= 0
  );

-- sat_fat cannot exceed total_fat
ALTER TABLE nutrition_facts
  ADD CONSTRAINT chk_nutrition_satfat_le_totalfat
  CHECK (
    saturated_fat_g IS NULL OR total_fat_g IS NULL
    OR saturated_fat_g <= total_fat_g
  );

-- sugars cannot exceed carbs
ALTER TABLE nutrition_facts
  ADD CONSTRAINT chk_nutrition_sugars_le_carbs
  CHECK (
    sugars_g IS NULL OR carbs_g IS NULL
    OR sugars_g <= carbs_g
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- servings table
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE servings
  ADD CONSTRAINT chk_servings_basis
  CHECK (serving_basis IN ('per 100 g', 'per 100 ml', 'per piece', 'per serving'));

ALTER TABLE servings
  ADD CONSTRAINT chk_servings_amount_positive
  CHECK (serving_amount_g_ml IS NULL OR serving_amount_g_ml > 0);

-- ═══════════════════════════════════════════════════════════════════════════
-- ingredients table
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE ingredients
  ADD CONSTRAINT chk_ingredients_additives_non_negative
  CHECK (additives_count IS NULL OR additives_count >= 0);

COMMIT;

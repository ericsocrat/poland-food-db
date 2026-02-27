-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Index 4 unindexed FK columns
-- Issue:     #363
-- Purpose:   Add B-tree indexes to all FK columns that currently lack them.
--            Prevents sequential scans on JOIN/CASCADE operations at scale.
-- Rollback:  DROP INDEX IF EXISTS idx_products_nutri_score_label;
--            DROP INDEX IF EXISTS idx_user_preferences_language;
--            DROP INDEX IF EXISTS idx_country_ref_default_language;
--            DROP INDEX IF EXISTS idx_error_code_registry_severity;
--            DROP INDEX IF EXISTS idx_products_name_reviewed_by;
--            DROP INDEX IF EXISTS idx_product_submissions_reviewed_by;
-- ═══════════════════════════════════════════════════════════════════════════════

-- products.nutri_score_label → nutri_score_ref(label)
-- Used in v_master JOINs and Nutri-Score-based filtering
CREATE INDEX IF NOT EXISTS idx_products_nutri_score_label
  ON products (nutri_score_label);

-- user_preferences.preferred_language → language_ref(code)
-- Used in every language-aware API call
CREATE INDEX IF NOT EXISTS idx_user_preferences_language
  ON user_preferences (preferred_language);

-- country_ref.default_language → language_ref(code)
-- Small table (2 rows) but indexed for FK correctness
CREATE INDEX IF NOT EXISTS idx_country_ref_default_language
  ON country_ref (default_language);

-- error_code_registry.severity → log_level_ref(level)
-- Small table (13 rows) but indexed for FK correctness
CREATE INDEX IF NOT EXISTS idx_error_code_registry_severity
  ON error_code_registry (severity);

-- products.product_name_en_reviewed_by → auth.users(id)
-- Sparse column (mostly NULL); partial index saves space
CREATE INDEX IF NOT EXISTS idx_products_name_reviewed_by
  ON products (product_name_en_reviewed_by)
  WHERE product_name_en_reviewed_by IS NOT NULL;

-- product_submissions.reviewed_by → auth.users(id)
-- Sparse column; partial index saves space
CREATE INDEX IF NOT EXISTS idx_product_submissions_reviewed_by
  ON product_submissions (reviewed_by)
  WHERE reviewed_by IS NOT NULL;

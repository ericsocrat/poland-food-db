-- Backfill nutri_score_source for all existing products (#893)
-- Logic mirrors ci_post_pipeline.sql §6 and pipeline _gen_04_scoring() §2b.
-- Idempotent: only updates rows where nutri_score_source IS NULL.
-- Rollback: UPDATE products SET nutri_score_source = NULL;

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

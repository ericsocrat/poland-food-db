-- ════════════════════════════════════════════════════════════════════════════
-- Migration: Add missing FK indexes on scan_history and product_submissions
-- ════════════════════════════════════════════════════════════════════════════
-- scan_history.product_id and product_submissions.merged_product_id both
-- have FK constraints to products but lacked supporting indexes.
-- Without indexes, DELETE on products triggers sequential scans.
-- ════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_sh_product_id
    ON public.scan_history (product_id)
    WHERE product_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ps_merged_product_id
    ON public.product_submissions (merged_product_id)
    WHERE merged_product_id IS NOT NULL;

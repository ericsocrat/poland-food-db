-- Migration: Re-score all products with v3.3 (nutrient density bonus)
-- Purpose:   After v3.3 scoring function (#608) and protein/fibre backfill (#609),
--            re-score every active product to incorporate the nutrient density bonus.
-- Depends:   20260315001900_scoring_v33_nutrient_density.sql (#608)
-- Rollback:  Re-run score_category() — scoring is always re-derivable from inputs.
-- Idempotency: Safe to run multiple times — score_category() is fully idempotent.

-- Step 1: Re-score all 25 categories (20 PL + 5 DE) via score_category()
-- score_category() internally calls compute_unhealthiness_v33() which includes
-- the nutrient density bonus (protein + fibre credit), then sets health-risk flags,
-- data_completeness_pct, confidence, and refreshes materialized views.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT DISTINCT country, category
        FROM public.products
        WHERE is_deprecated IS NOT TRUE
        ORDER BY country, category
    LOOP
        RAISE NOTICE 'Re-scoring % / % with v3.3 (nutrient density)', r.country, r.category;
        CALL public.score_category(
            p_category := r.category,
            p_country  := r.country
        );
    END LOOP;
    RAISE NOTICE 'All categories re-scored with v3.3 nutrient density bonus';
END
$$;

-- Step 2: Validate — no scores out of bounds
DO $$
DECLARE
    bad_count integer;
BEGIN
    SELECT count(*)
    INTO bad_count
    FROM public.products
    WHERE is_deprecated IS NOT TRUE
      AND (unhealthiness_score < 1 OR unhealthiness_score > 100);

    IF bad_count > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: % products with out-of-bounds scores', bad_count;
    END IF;

    RAISE NOTICE 'Validation passed: 0 products with out-of-bounds scores';
END
$$;

-- Step 3: Validate — all active products are on v3.3
DO $$
DECLARE
    non_v33 integer;
BEGIN
    SELECT count(*)
    INTO non_v33
    FROM public.products
    WHERE is_deprecated IS NOT TRUE
      AND (score_model_version IS NULL OR score_model_version <> 'v3.3');

    IF non_v33 > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: % products not on v3.3', non_v33;
    END IF;

    RAISE NOTICE 'Validation passed: all active products on v3.3';
END
$$;

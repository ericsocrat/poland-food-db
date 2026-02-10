-- Migration: Expand prep_method domain + index tuning notes
-- Created: 2026-02-10
--
-- The pipeline's _detect_prep_method() now infers additional preparation
-- methods from OFF category tags and product names.  The CHECK constraint
-- must accept the expanded set.

-- Drop the old constraint
ALTER TABLE public.products
    DROP CONSTRAINT IF EXISTS chk_products_prep_method;

-- Re-create with full list of valid prep methods
ALTER TABLE public.products
    ADD CONSTRAINT chk_products_prep_method CHECK (
        prep_method IS NULL
        OR prep_method IN (
            'air-popped',
            'baked',
            'fried',
            'deep-fried',
            'grilled',
            'roasted',
            'smoked',
            'steamed',
            'marinated',
            'pasteurized',
            'fermented',
            'dried',
            'raw',
            'none',
            'not-applicable'
        )
    );

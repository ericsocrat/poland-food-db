-- ==========================================================================
-- Migration: 20260310000400_fix_allergen_check_constraint.sql
-- Purpose:   1. Update chk_avoid_allergens_format to accept bare canonical IDs
--               (e.g. 'gluten', 'milk') instead of en:-prefixed tags.
--               Required after 20260310000200 normalized allergen tags.
--            2. Remove orphaned junk ingredient_ref entries (OFF parser artifacts)
-- Rollback:  Re-add old constraint with en: prefix regex;
--            Re-insert deleted ingredient_ref rows if needed.
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Update allergen check constraint for bare canonical IDs
-- ═══════════════════════════════════════════════════════════════════════════

-- Drop the old constraint that requires en: prefix
ALTER TABLE public.user_preferences
    DROP CONSTRAINT IF EXISTS chk_avoid_allergens_format;

-- Add updated constraint: accepts bare canonical allergen IDs (lowercase, hyphens)
-- Format: 'gluten', 'tree-nuts', 'sulphites', etc.
ALTER TABLE public.user_preferences
    ADD CONSTRAINT chk_avoid_allergens_format
        CHECK (avoid_allergens IS NULL
            OR cardinality(avoid_allergens) = 0
            OR array_to_string(avoid_allergens, ',') ~ '^[a-z][a-z0-9-]+(,[a-z][a-z0-9-]+)*$'
        );

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Remove orphaned junk ingredient_ref entries
--    These are OFF parser artifacts (bare numbers, "Kcal", nutrition
--    strings) that should never have been imported as ingredients.
--    Only delete rows with no product_ingredient references.
-- ═══════════════════════════════════════════════════════════════════════════
DELETE FROM public.ingredient_ref
WHERE (
    name_en ~ '^\d+$'
    OR length(trim(name_en)) <= 1
    OR name_en ~* '^(per 100|kcal|kj\b)'
)
AND NOT EXISTS (
    SELECT 1 FROM public.product_ingredient pi
    WHERE pi.ingredient_id = ingredient_ref.ingredient_id
);

COMMIT;

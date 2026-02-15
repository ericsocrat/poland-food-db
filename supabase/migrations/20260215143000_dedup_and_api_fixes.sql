-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: Post-enrichment dedup, concern score fix, API country fallback
-- Applied: 2026-02-15
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────
-- 1. DEDUPLICATE product_ingredient rows
--    Codex P1: OFF API hierarchy inserted duplicate (product_id, ingredient_id)
--    pairs across nesting levels. 1,000 duplicate rows across 252 products.
-- ─────────────────────────────────────────────────────────────────────────
DELETE FROM product_ingredient
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM product_ingredient
    GROUP BY product_id, ingredient_id
);

-- Prevent future duplicates (idempotent)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_product_ingredient'
    ) THEN
        ALTER TABLE product_ingredient
            ADD CONSTRAINT uq_product_ingredient UNIQUE (product_id, ingredient_id);
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────
-- 2. FIX ingredient_concern_score calculation
--    Bug: LEAST(100, NULL) = 100 in PostgreSQL (ignores NULLs).
--    Products with 0 ingredients were scored as concern_score = 100.
--    Fix: LEAST(100, COALESCE(SUM(...), 0))
-- ─────────────────────────────────────────────────────────────────────────
UPDATE products p
SET ingredient_concern_score = (
    SELECT LEAST(100, COALESCE(SUM(
        CASE ir.concern_tier
            WHEN 1 THEN 15
            WHEN 2 THEN 40
            WHEN 3 THEN 100
            ELSE 0
        END
    ), 0))
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = p.product_id
);

-- ─────────────────────────────────────────────────────────────────────────
-- 3. FIX resolve_effective_country — add PL fallback
--    Without auth context (QA, cron, etc.), resolve_effective_country()
--    returns NULL, causing WHERE country = NULL → 0 results.
--    Add 'PL' as tier-3 fallback (only active country).
-- ─────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.resolve_effective_country(p_country text DEFAULT NULL::text)
    RETURNS text
    LANGUAGE sql
    STABLE SECURITY DEFINER
    SET search_path TO 'public'
AS $function$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (pass-through if not NULL)
        NULLIF(TRIM(p_country), ''),
        -- Priority 2: authenticated user's saved country preference
        (SELECT up.country
         FROM user_preferences up
         WHERE up.user_id = auth.uid()),
        -- Priority 3: fallback to default active country
        'PL'
    );
$function$;

COMMIT;

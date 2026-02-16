-- ─── Migration 95: Localization Hardening ────────────────────────────────────
-- Architectural refinements and validation improvements:
--   1. localization_metrics view — translation coverage tracking
--   2. product_name_en_confidence column — optional quality scoring
--   3. expand_search_query() — cap synonym expansions at 10
--
-- Rollback:
--   DROP VIEW IF EXISTS public.localization_metrics;
--   ALTER TABLE products DROP COLUMN IF EXISTS product_name_en_confidence;
--   -- Revert expand_search_query to uncapped version
-- ─────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Localization Coverage Metrics View
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.localization_metrics AS
SELECT
    count(*)                           AS total_products,
    count(product_name_en)             AS translated_products,
    round(
        count(product_name_en)::numeric
        / nullif(count(*), 0) * 100,
        2
    )                                  AS pct_translated
FROM public.products
WHERE is_deprecated = false;

COMMENT ON VIEW public.localization_metrics IS
    'Read-only view: English translation coverage of non-deprecated products.';

-- Grant read-only to authenticated users
GRANT SELECT ON public.localization_metrics TO authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Translation Confidence Column (Optional Quality Scoring)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.products
    ADD COLUMN IF NOT EXISTS product_name_en_confidence numeric;

-- Add CHECK constraint for 0-1 range (safe to re-run)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_product_name_en_confidence_range'
          AND conrelid = 'public.products'::regclass
    ) THEN
        ALTER TABLE public.products
            ADD CONSTRAINT chk_product_name_en_confidence_range
            CHECK (product_name_en_confidence BETWEEN 0 AND 1);
    END IF;
END $$;

COMMENT ON COLUMN public.products.product_name_en_confidence IS
    'Optional 0.0-1.0 confidence score for the English translation. NULL = not scored.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Cap Synonym Expansion at 10 Results
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.expand_search_query(p_query text)
RETURNS text[]
LANGUAGE sql STABLE
SECURITY INVOKER
SET search_path = public
AS $$
    WITH terms AS (
        -- Whole query as one lookup term
        SELECT LOWER(TRIM(p_query)) AS term
        UNION
        -- Individual words (only for multi-word queries)
        SELECT LOWER(w)
        FROM unnest(string_to_array(TRIM(p_query), ' ')) AS w
        WHERE w <> ''
          AND TRIM(p_query) LIKE '% %'
    ),
    matched AS (
        SELECT DISTINCT ss.term_target
        FROM terms t
        JOIN public.search_synonyms ss
            ON LOWER(ss.term_original) = t.term
        LIMIT 10  -- Safety cap: prevent degenerate growth
    )
    SELECT COALESCE(
        array_agg(m.term_target),
        ARRAY[]::text[]
    )
    FROM matched m;
$$;

COMMENT ON FUNCTION public.expand_search_query(text) IS
    'Returns up to 10 synonym expansions for a search query. Capped to prevent degenerate growth.';

-- Maintain grants
REVOKE EXECUTE ON FUNCTION public.expand_search_query(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.expand_search_query(text) TO authenticated, service_role;

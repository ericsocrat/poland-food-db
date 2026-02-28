-- ============================================================
-- Migration: Ingredient display name translations
-- Issue: #355 — Ingredient display localization
-- Phase 1: ingredient_translations table + resolve helper
--
-- Follows the allergen_translations pattern (20260310000300).
-- Table only — data population is Phase 2.
-- To rollback: DROP FUNCTION IF EXISTS resolve_ingredient_name;
--              DROP TABLE IF EXISTS ingredient_translations CASCADE;
-- ============================================================

-- ── 1. ingredient_translations table ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ingredient_translations (
    ingredient_id   bigint NOT NULL REFERENCES public.ingredient_ref(ingredient_id) ON DELETE CASCADE,
    language_code   text   NOT NULL REFERENCES public.language_ref(code) ON DELETE CASCADE,
    name            text   NOT NULL,
    source          text   NOT NULL DEFAULT 'curated'
                    CHECK (source IN ('curated', 'off_api', 'auto_translated', 'user_submitted')),
    reviewed_at     timestamptz,
    PRIMARY KEY (ingredient_id, language_code)
);

COMMENT ON TABLE public.ingredient_translations
    IS 'Localized display names for ingredients. Follows allergen_translations pattern. Phase 1: schema only.';

-- ── 2. Indexes ──────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_ingredient_translations_lang
    ON public.ingredient_translations (language_code);

CREATE INDEX IF NOT EXISTS idx_ingredient_translations_name_trgm
    ON public.ingredient_translations USING gin (name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_ingredient_translations_ingredient
    ON public.ingredient_translations (ingredient_id);

-- ── 3. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE public.ingredient_translations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ingredient_translations: anon + authenticated read"
    ON public.ingredient_translations;
CREATE POLICY "ingredient_translations: anon + authenticated read"
    ON public.ingredient_translations FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "ingredient_translations: service_role write"
    ON public.ingredient_translations;
CREATE POLICY "ingredient_translations: service_role write"
    ON public.ingredient_translations FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ── 4. Grants ───────────────────────────────────────────────────────────────
GRANT SELECT ON public.ingredient_translations TO anon, authenticated;
GRANT ALL    ON public.ingredient_translations TO service_role;

-- ── 5. Helper function: resolve ingredient display name ─────────────────────
CREATE OR REPLACE FUNCTION public.resolve_ingredient_name(
    p_ingredient_id bigint,
    p_language      text DEFAULT 'en'
)
RETURNS text
LANGUAGE sql STABLE
SET search_path = public
AS $$
    SELECT COALESCE(
        -- 1. Exact language match in translations
        (SELECT t.name
         FROM ingredient_translations t
         WHERE t.ingredient_id = p_ingredient_id
           AND t.language_code = p_language),
        -- 2. Fallback to English translation
        (SELECT t.name
         FROM ingredient_translations t
         WHERE t.ingredient_id = p_ingredient_id
           AND t.language_code = 'en'),
        -- 3. Fallback to canonical name_en on ingredient_ref
        (SELECT ir.name_en
         FROM ingredient_ref ir
         WHERE ir.ingredient_id = p_ingredient_id),
        -- 4. Ultimate fallback: return NULL (ingredient not found)
        NULL
    );
$$;

COMMENT ON FUNCTION public.resolve_ingredient_name IS
    'Returns localized ingredient name. Fallback: requested lang → en translation → name_en → NULL.';

GRANT EXECUTE ON FUNCTION public.resolve_ingredient_name TO anon, authenticated, service_role;

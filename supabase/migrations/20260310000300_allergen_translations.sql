-- ============================================================
-- Migration: Allergen translations
-- Issue: #351 — Allergen normalization
-- Phase 3: Allergen display name translations (PL + DE)
--
-- Follows the category_translations pattern.
-- To rollback: DROP TABLE IF EXISTS allergen_translations CASCADE;
-- ============================================================

-- ── 1. allergen_translations table ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.allergen_translations (
    allergen_id   text NOT NULL REFERENCES public.allergen_ref(allergen_id),
    language_code text NOT NULL REFERENCES public.language_ref(code),
    display_name  text NOT NULL,
    PRIMARY KEY (allergen_id, language_code)
);

COMMENT ON TABLE public.allergen_translations
    IS 'Localized display names for allergens. Follows category_translations pattern.';

-- ── 2. Seed translations (PL + DE + EN) ────────────────────────────────────
INSERT INTO public.allergen_translations (allergen_id, language_code, display_name)
VALUES
    -- English (reference — matches allergen_ref.display_name_en)
    ('gluten',      'en', 'Gluten'),
    ('crustaceans', 'en', 'Crustaceans'),
    ('eggs',        'en', 'Eggs'),
    ('fish',        'en', 'Fish'),
    ('peanuts',     'en', 'Peanuts'),
    ('soybeans',    'en', 'Soybeans'),
    ('milk',        'en', 'Milk'),
    ('tree-nuts',   'en', 'Tree Nuts'),
    ('celery',      'en', 'Celery'),
    ('mustard',     'en', 'Mustard'),
    ('sesame',      'en', 'Sesame Seeds'),
    ('sulphites',   'en', 'Sulphur Dioxide & Sulphites'),
    ('lupin',       'en', 'Lupin'),
    ('molluscs',    'en', 'Molluscs'),

    -- Polish
    ('gluten',      'pl', 'Gluten'),
    ('crustaceans', 'pl', 'Skorupiaki'),
    ('eggs',        'pl', 'Jajka'),
    ('fish',        'pl', 'Ryby'),
    ('peanuts',     'pl', 'Orzeszki ziemne'),
    ('soybeans',    'pl', 'Soja'),
    ('milk',        'pl', 'Mleko'),
    ('tree-nuts',   'pl', 'Orzechy'),
    ('celery',      'pl', 'Seler'),
    ('mustard',     'pl', 'Gorczyca'),
    ('sesame',      'pl', 'Sezam'),
    ('sulphites',   'pl', 'Dwutlenek siarki i siarczyny'),
    ('lupin',       'pl', 'Łubin'),
    ('molluscs',    'pl', 'Mięczaki'),

    -- German
    ('gluten',      'de', 'Gluten'),
    ('crustaceans', 'de', 'Krebstiere'),
    ('eggs',        'de', 'Eier'),
    ('fish',        'de', 'Fisch'),
    ('peanuts',     'de', 'Erdnüsse'),
    ('soybeans',    'de', 'Soja'),
    ('milk',        'de', 'Milch'),
    ('tree-nuts',   'de', 'Schalenfrüchte'),
    ('celery',      'de', 'Sellerie'),
    ('mustard',     'de', 'Senf'),
    ('sesame',      'de', 'Sesam'),
    ('sulphites',   'de', 'Schwefeldioxid und Sulfite'),
    ('lupin',       'de', 'Lupinen'),
    ('molluscs',    'de', 'Weichtiere')
ON CONFLICT (allergen_id, language_code) DO UPDATE SET
    display_name = EXCLUDED.display_name;

-- ── 3. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE public.allergen_translations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allergen_translations: anon + authenticated read" ON public.allergen_translations;
CREATE POLICY "allergen_translations: anon + authenticated read"
    ON public.allergen_translations FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "allergen_translations: service_role write" ON public.allergen_translations;
CREATE POLICY "allergen_translations: service_role write"
    ON public.allergen_translations FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ── 4. Grants ───────────────────────────────────────────────────────────────
GRANT SELECT ON public.allergen_translations TO anon, authenticated;
GRANT ALL    ON public.allergen_translations TO service_role;

-- ── 5. Helper function: resolve allergen display name ───────────────────────
CREATE OR REPLACE FUNCTION public.resolve_allergen_display(
    p_allergen_id text,
    p_language    text DEFAULT 'en'
)
RETURNS text
LANGUAGE sql STABLE
AS $$
    SELECT COALESCE(
        (SELECT t.display_name
         FROM allergen_translations t
         WHERE t.allergen_id = p_allergen_id
           AND t.language_code = p_language),
        (SELECT t.display_name
         FROM allergen_translations t
         WHERE t.allergen_id = p_allergen_id
           AND t.language_code = 'en'),
        (SELECT ar.display_name_en
         FROM allergen_ref ar
         WHERE ar.allergen_id = p_allergen_id),
        p_allergen_id
    );
$$;

COMMENT ON FUNCTION public.resolve_allergen_display IS
    'Returns localized allergen display name. Fallback: requested lang → en → display_name_en → raw ID.';

GRANT EXECUTE ON FUNCTION public.resolve_allergen_display TO anon, authenticated, service_role;

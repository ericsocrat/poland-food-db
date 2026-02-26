-- ============================================================
-- Migration: allergen_ref foundation
-- Issue: #351 — Allergen normalization
-- Phase 1: Create canonical allergen reference table
--
-- Creates allergen_ref with EU-14 mandatory allergens per
-- Regulation (EU) No 1169/2011, Annex II.
--
-- To rollback: DROP TABLE IF EXISTS allergen_ref CASCADE;
-- ============================================================

-- ── 1. allergen_ref table ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.allergen_ref (
    allergen_id     text PRIMARY KEY,
    display_name_en text NOT NULL,
    allergen_group  text,
    eu_mandatory    boolean NOT NULL DEFAULT false,
    icon_emoji      text,
    severity_note   text,
    sort_order      integer NOT NULL DEFAULT 0,
    is_active       boolean NOT NULL DEFAULT true
);

COMMENT ON TABLE  public.allergen_ref IS 'Canonical allergen dictionary — EU-14 mandatory allergens + common extras.';
COMMENT ON COLUMN public.allergen_ref.allergen_id     IS 'Canonical English slug: gluten, milk, peanuts, etc.';
COMMENT ON COLUMN public.allergen_ref.allergen_group  IS 'Grouping: cereals, dairy, nuts, seafood, legumes, etc.';
COMMENT ON COLUMN public.allergen_ref.eu_mandatory    IS 'true for EU 1169/2011 Annex II 14 mandatory allergens.';
COMMENT ON COLUMN public.allergen_ref.icon_emoji      IS 'Display emoji for UI rendering.';

-- ── 2. Seed EU-14 mandatory allergens ───────────────────────────────────────
INSERT INTO public.allergen_ref (allergen_id, display_name_en, allergen_group, eu_mandatory, icon_emoji, severity_note, sort_order)
VALUES
    ('gluten',      'Gluten',                       'cereals',       true,  '🌾', 'Includes wheat, rye, barley, oats, spelt, kamut', 1),
    ('crustaceans', 'Crustaceans',                  'seafood',       true,  '🦐', 'Shrimp, crab, lobster, crayfish',                 2),
    ('eggs',        'Eggs',                         'animal',        true,  '🥚', 'All egg-derived products',                        3),
    ('fish',        'Fish',                         'seafood',       true,  '🐟', 'All fish species and derivatives',                4),
    ('peanuts',     'Peanuts',                      'nuts',          true,  '🥜', 'Can cause anaphylaxis',                           5),
    ('soybeans',    'Soybeans',                     'legumes',       true,  '🫘', 'Soy lecithin, soy protein, tofu',                 6),
    ('milk',        'Milk',                         'dairy',         true,  '🥛', 'Lactose, casein, whey, butter, cheese',           7),
    ('tree-nuts',   'Tree Nuts',                    'nuts',          true,  '🌰', 'Almonds, hazelnuts, walnuts, cashews, pecans, pistachios, macadamia, brazil nuts', 8),
    ('celery',      'Celery',                       'vegetables',    true,  '🥬', 'Including celeriac',                              9),
    ('mustard',     'Mustard',                      'spices',        true,  '🟡', 'Mustard seeds, powder, oil',                      10),
    ('sesame',      'Sesame Seeds',                 'seeds',         true,  '⚪', 'Sesame oil, tahini',                              11),
    ('sulphites',   'Sulphur Dioxide & Sulphites',  'preservatives', true,  '⚗️', 'At concentrations >10 mg/kg or >10 mg/L as SO₂', 12),
    ('lupin',       'Lupin',                        'legumes',       true,  '🌿', 'Lupin flour, seeds',                              13),
    ('molluscs',    'Molluscs',                     'seafood',       true,  '🐚', 'Squid, octopus, snails, mussels, oysters',        14)
ON CONFLICT (allergen_id) DO UPDATE SET
    display_name_en = EXCLUDED.display_name_en,
    allergen_group  = EXCLUDED.allergen_group,
    eu_mandatory    = EXCLUDED.eu_mandatory,
    icon_emoji      = EXCLUDED.icon_emoji,
    severity_note   = EXCLUDED.severity_note,
    sort_order      = EXCLUDED.sort_order;

-- ── 3. Indexes ──────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_allergen_ref_group
    ON public.allergen_ref (allergen_group);

CREATE INDEX IF NOT EXISTS idx_allergen_ref_eu
    ON public.allergen_ref (allergen_id) WHERE eu_mandatory = true;

-- ── 4. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE public.allergen_ref ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allergen_ref: anon + authenticated read" ON public.allergen_ref;
CREATE POLICY "allergen_ref: anon + authenticated read"
    ON public.allergen_ref FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "allergen_ref: service_role write" ON public.allergen_ref;
CREATE POLICY "allergen_ref: service_role write"
    ON public.allergen_ref FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ── 5. Grants ───────────────────────────────────────────────────────────────
GRANT SELECT ON public.allergen_ref TO anon, authenticated;
GRANT ALL    ON public.allergen_ref TO service_role;

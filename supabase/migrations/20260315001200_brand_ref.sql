-- ============================================================
-- Migration: brand_ref table + seed data
-- Issue: #356 Phase 1 — Brand normalization
-- Purpose: Create a canonical brand dictionary seeded from all
--          existing products.brand values. Currently brand is
--          free text — this table establishes the controlled
--          vocabulary. ~478 unique brand names across PL + DE.
--          Phase 2 (separate migration) will add FK constraint
--          + brand_aliases table for variant resolution.
-- Rollback: DROP TABLE IF EXISTS brand_ref CASCADE;
-- ============================================================

-- ─── 1. Create brand_ref table ───────────────────────────────
CREATE TABLE IF NOT EXISTS public.brand_ref (
    brand_name      text PRIMARY KEY,
    display_name    text NOT NULL,
    parent_company  text,
    country_origin  text,         -- ISO 3166-1 alpha-2 (no FK: many origins outside PL/DE)
    logo_url        text,
    website_url     text,
    is_store_brand  boolean NOT NULL DEFAULT false,
    sort_order      integer NOT NULL DEFAULT 0,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.brand_ref IS
  'Canonical brand dictionary. PK is the normalized brand name. '
  'Phase 1 seeds from existing products.brand values. '
  'Phase 2 will add FK from products.brand + brand_aliases table. '
  'Issue #356.';

COMMENT ON COLUMN public.brand_ref.brand_name IS
  'Canonical brand name, e.g. Dr. Oetker. Matches products.brand.';
COMMENT ON COLUMN public.brand_ref.display_name IS
  'Human-readable display name (usually same as brand_name).';
COMMENT ON COLUMN public.brand_ref.parent_company IS
  'Parent company or conglomerate, e.g. Oetker Group, PepsiCo.';
COMMENT ON COLUMN public.brand_ref.country_origin IS
  'ISO 3166-1 alpha-2 country of origin. Not FK — many origins '
  'outside the active country set (PL/DE).';
COMMENT ON COLUMN public.brand_ref.is_store_brand IS
  'True for retailer/private-label brands: Biedronka, Lidl, Żabka, etc.';

-- ─── 2. Indexes ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_brand_ref_parent_company
    ON brand_ref(parent_company) WHERE parent_company IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_brand_ref_store_brand
    ON brand_ref(is_store_brand) WHERE is_store_brand = true;

-- ─── 3. RLS ──────────────────────────────────────────────────
ALTER TABLE public.brand_ref ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'brand_ref'
      AND policyname = 'brand_ref_read_all'
  ) THEN
    CREATE POLICY brand_ref_read_all
      ON public.brand_ref FOR SELECT
      USING (true);
  END IF;
END $$;

GRANT SELECT ON public.brand_ref TO anon, authenticated, service_role;

-- ─── 4. Auto-seed from existing products ─────────────────────
-- Populates brand_ref with every distinct brand currently in use.
-- ON CONFLICT ensures idempotency on re-run.
INSERT INTO public.brand_ref (brand_name, display_name)
SELECT DISTINCT brand, brand
FROM public.products
WHERE brand IS NOT NULL
  AND is_deprecated IS NOT TRUE
ON CONFLICT (brand_name) DO NOTHING;

-- ─── 5. Enrich known brands with metadata ────────────────────
-- Store brands (Polish retailers)
UPDATE public.brand_ref SET is_store_brand = true, country_origin = 'PL'
WHERE brand_name IN (
  'Biedronka', 'Top Biedronka',
  'Żabka',
  'Auchan',
  'Carrefour',
  'Dino'
) AND is_store_brand = false;

-- Store brands (German/international retailers)
UPDATE public.brand_ref SET is_store_brand = true, country_origin = 'DE'
WHERE brand_name IN ('Lidl', 'Aldi')
AND is_store_brand = false;

-- Major international brands — parent companies + origins
UPDATE public.brand_ref SET parent_company = 'PepsiCo', country_origin = 'US'
WHERE brand_name IN ('Pepsi', 'Doritos', 'Lay''s', 'Lays', 'Cheetos')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'The Coca-Cola Company', country_origin = 'US'
WHERE brand_name IN ('Coca-Cola', 'Fanta', 'Sprite', 'Costa Coffee')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mondelēz International', country_origin = 'US'
WHERE brand_name IN ('Milka', 'Oreo', 'Philadelphia', 'Cadbury')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Oetker Group', country_origin = 'DE'
WHERE brand_name IN ('Dr. Oetker', 'Dr.Oetker')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Nestlé', country_origin = 'CH'
WHERE brand_name IN ('Nestlé', 'Nestle', 'Nescafé', 'Maggi', 'Winiary')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Unilever', country_origin = 'NL'
WHERE brand_name IN ('Knorr', 'Hellmann''s', 'Lipton')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Danone', country_origin = 'FR'
WHERE brand_name IN ('Danone', 'Żywiec Zdrój', 'Alpro')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Barilla Group', country_origin = 'IT'
WHERE brand_name IN ('Barilla', 'Wasa')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Ferrero', country_origin = 'IT'
WHERE brand_name IN ('Ferrero', 'Kinder', 'Nutella')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mars, Inc.', country_origin = 'US'
WHERE brand_name IN ('Mars', 'Snickers', 'M&M''s', 'Twix', 'Uncle Ben''s')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Schwarz Group', country_origin = 'DE'
WHERE brand_name IN ('GutBio', 'Gut bio', 'Vemondo')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Maspex', country_origin = 'PL'
WHERE brand_name IN ('Kubuś', 'Tymbark', 'Lubella', 'DecoMorreno')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Colian', country_origin = 'PL'
WHERE brand_name IN ('Goplana', 'Solidarność', 'Grześki', 'Jeżyki')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Lotte Wedel', country_origin = 'PL'
WHERE brand_name IN ('E. Wedel', 'Wedel')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Tarczyński S.A.', country_origin = 'PL'
WHERE brand_name IN ('Tarczyński')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Kellogg Company', country_origin = 'US'
WHERE brand_name IN ('Kellogg''s', 'Pringles')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Hochland', country_origin = 'DE'
WHERE brand_name IN ('Hochland', 'Almette')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Lorenz Snack-World', country_origin = 'DE'
WHERE brand_name IN ('Lorenz', 'Crunchips')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Mestemacher', country_origin = 'DE'
WHERE brand_name = 'Mestemacher'
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Carlsberg Group', country_origin = 'DK'
WHERE brand_name IN ('Carlsberg', 'Somersby')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Heineken', country_origin = 'NL'
WHERE brand_name IN ('Heineken', 'Żywiec')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Asahi Group', country_origin = 'JP'
WHERE brand_name IN ('Tyskie', 'Lech', 'Kompania Piwowarska')
AND parent_company IS NULL;

UPDATE public.brand_ref SET parent_company = 'Indofood', country_origin = 'ID'
WHERE brand_name IN ('Indomie')
AND parent_company IS NULL;

-- ==========================================================================
-- Migration: 20260311000100_store_architecture_foundation.sql
-- Purpose:   Create store_ref + product_store_availability tables for
--            structured M:N store ↔ product relationship.
--            Part of #350 — Store Architecture.
-- Rollback:  DROP TABLE product_store_availability;
--            DROP TABLE store_ref;
-- ==========================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. store_ref — Canonical store dictionary
-- ═══════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.store_ref (
    store_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country     text NOT NULL REFERENCES public.country_ref(country_code),
    store_name  text NOT NULL,
    store_slug  text NOT NULL,
    store_type  text NOT NULL DEFAULT 'supermarket'
        CHECK (store_type IN (
            'convenience','supermarket','hypermarket',
            'discounter','specialty','online','drugstore'
        )),
    website_url text,
    is_active   boolean NOT NULL DEFAULT true,
    sort_order  integer NOT NULL DEFAULT 0,
    UNIQUE (country, store_slug)
);

COMMENT ON TABLE public.store_ref IS
'Canonical store/retailer dictionary. Country-scoped with type classification. '
'Stores are referenced by product_store_availability junction table.';

COMMENT ON COLUMN public.store_ref.store_slug IS
'URL-safe identifier, unique within country. Lowercase, hyphens only.';

COMMENT ON COLUMN public.store_ref.store_type IS
'Retail format classification: convenience (Żabka), supermarket (Biedronka), '
'hypermarket (Auchan), discounter (Lidl, Aldi), specialty, online, drugstore (Rossmann, dm).';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. product_store_availability — M:N junction
-- ═══════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.product_store_availability (
    product_id  bigint NOT NULL REFERENCES public.products(product_id) ON DELETE CASCADE,
    store_id    integer NOT NULL REFERENCES public.store_ref(store_id) ON DELETE CASCADE,
    verified_at timestamptz,
    source      text CHECK (source IS NULL OR source IN ('off_api','manual','user_report','pipeline')),
    PRIMARY KEY (product_id, store_id)
);

COMMENT ON TABLE public.product_store_availability IS
'M:N junction linking products to stores where they are available. '
'A product can be available at multiple stores; a store can carry many products.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Indexes
-- ═══════════════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_store_ref_country
    ON public.store_ref (country);

CREATE INDEX IF NOT EXISTS idx_store_ref_slug
    ON public.store_ref (store_slug);

CREATE INDEX IF NOT EXISTS idx_product_store_product
    ON public.product_store_availability (product_id);

CREATE INDEX IF NOT EXISTS idx_product_store_store
    ON public.product_store_availability (store_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. RLS policies
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.store_ref ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_store_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_ref FORCE ROW LEVEL SECURITY;
ALTER TABLE public.product_store_availability FORCE ROW LEVEL SECURITY;

-- Read-all for anon + authenticated
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'store_ref_read_all') THEN
        EXECUTE 'CREATE POLICY store_ref_read_all ON public.store_ref FOR SELECT USING (true)';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'product_store_read_all') THEN
        EXECUTE 'CREATE POLICY product_store_read_all ON public.product_store_availability FOR SELECT USING (true)';
    END IF;
END
$$;

-- Service-role write
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'store_ref_service_write') THEN
        EXECUTE 'CREATE POLICY store_ref_service_write ON public.store_ref FOR ALL TO service_role USING (true) WITH CHECK (true)';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'product_store_service_write') THEN
        EXECUTE 'CREATE POLICY product_store_service_write ON public.product_store_availability FOR ALL TO service_role USING (true) WITH CHECK (true)';
    END IF;
END
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Grants
-- ═══════════════════════════════════════════════════════════════════════════
GRANT SELECT ON public.store_ref TO anon, authenticated;
GRANT SELECT ON public.product_store_availability TO anon, authenticated;
GRANT ALL ON public.store_ref TO service_role;
GRANT ALL ON public.product_store_availability TO service_role;

COMMIT;

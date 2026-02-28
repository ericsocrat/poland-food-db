-- ============================================================
-- Migration: product_links junction table
-- Issue: #352 Phase 1 — Cross-country product linking
-- Purpose: Enable explicit linking between products across
--          countries (PL ↔ DE). Supports relationship types:
--          identical, equivalent, variant, related.
--          11 brands overlap between PL and DE but 0 EAN
--          matches exist — all links require manual creation.
-- Rollback: DROP TABLE IF EXISTS product_links CASCADE;
-- ============================================================

-- ─── 1. Create product_links table ──────────────────────────
CREATE TABLE IF NOT EXISTS public.product_links (
    link_id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id_a    bigint NOT NULL REFERENCES products(product_id),
    product_id_b    bigint NOT NULL REFERENCES products(product_id),
    link_type       text NOT NULL CHECK (link_type IN (
                      'identical', 'equivalent', 'variant', 'related'
                    )),
    confidence      text NOT NULL DEFAULT 'manual' CHECK (confidence IN (
                      'manual', 'ean_match', 'brand_match', 'verified'
                    )),
    notes           text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    -- Enforce ordering to prevent duplicate bidirectional rows
    CONSTRAINT chk_product_links_ordered CHECK (product_id_a < product_id_b),
    -- One link per product pair
    CONSTRAINT uq_product_links_pair UNIQUE (product_id_a, product_id_b)
);

COMMENT ON TABLE public.product_links IS
  'Cross-country product links. Bidirectional by design: '
  'if PL→DE link exists, DE→PL is implicit. product_id_a < product_id_b enforced. '
  'Issue #352.';

COMMENT ON COLUMN public.product_links.link_type IS
  'identical: same product/recipe, different market. '
  'equivalent: same brand+category, minor regional differences. '
  'variant: same brand, different flavor/size. '
  'related: same category, comparable positioning by different brands.';

COMMENT ON COLUMN public.product_links.confidence IS
  'How the link was established: '
  'manual: human-created. ean_match: same EAN found. '
  'brand_match: heuristic brand+name match. verified: human-reviewed match.';

-- ─── 2. Indexes ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_product_links_a
    ON product_links(product_id_a);
CREATE INDEX IF NOT EXISTS idx_product_links_b
    ON product_links(product_id_b);

-- ─── 3. RLS ──────────────────────────────────────────────────
ALTER TABLE public.product_links ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'product_links'
      AND policyname = 'product_links_read_all'
  ) THEN
    CREATE POLICY product_links_read_all
      ON public.product_links FOR SELECT
      USING (true);
  END IF;
END $$;

-- Service role can insert/update/delete links
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'product_links'
      AND policyname = 'product_links_service_write'
  ) THEN
    CREATE POLICY product_links_service_write
      ON public.product_links FOR ALL
      TO service_role
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;

GRANT SELECT ON public.product_links TO anon, authenticated;
GRANT ALL ON public.product_links TO service_role;

-- ─── 4. Helper function: get linked products ─────────────────
CREATE OR REPLACE FUNCTION public.api_get_cross_country_links(
    p_product_id bigint
)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'link_id',    pl.link_id,
            'link_type',  pl.link_type,
            'confidence', pl.confidence,
            'notes',      pl.notes,
            'created_at', pl.created_at,
            'product',    jsonb_build_object(
                'product_id',   p.product_id,
                'product_name', p.product_name,
                'brand',        p.brand,
                'country',      p.country,
                'category',     p.category,
                'unhealthiness_score', p.unhealthiness_score,
                'nutri_score_label',   p.nutri_score_label
            )
        )
        ORDER BY pl.link_type, p.product_name
    ), '[]'::jsonb)
    FROM product_links pl
    JOIN products p ON p.product_id = CASE
        WHEN pl.product_id_a = p_product_id THEN pl.product_id_b
        ELSE pl.product_id_a
    END
    WHERE (pl.product_id_a = p_product_id OR pl.product_id_b = p_product_id)
      AND p.is_deprecated IS NOT TRUE;
$$;

COMMENT ON FUNCTION public.api_get_cross_country_links IS
  'Returns linked products for a given product_id. '
  'Bidirectional: queries both product_id_a and product_id_b. '
  'Returns empty JSON array if no links exist.';

GRANT EXECUTE ON FUNCTION public.api_get_cross_country_links(bigint) TO anon, authenticated, service_role;

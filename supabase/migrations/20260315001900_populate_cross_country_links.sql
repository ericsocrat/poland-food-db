-- ============================================================
-- Migration: Populate cross-country product links (PL ↔ DE)
-- Issue: #605 — Cross-country product linking via EAN + brand
-- Purpose: Auto-populate product_links using two strategies:
--   1. EAN matching (same barcode → identical, ean_match)
--   2. Brand+name fuzzy matching (pg_trgm → equivalent/variant, brand_match)
--
-- Current state: 0 EAN matches, ~20 brand+name matches (similarity >0.4)
-- Rollback: DELETE FROM product_links WHERE confidence IN ('ean_match','brand_match');
-- Idempotency: ON CONFLICT DO NOTHING on all inserts
-- ============================================================

-- ─── 1. EAN-based automatic linking ─────────────────────────
-- Same EAN across different countries → identical product
-- Currently 0 matches but infrastructure is ready for future data
INSERT INTO public.product_links (product_id_a, product_id_b, link_type, confidence, notes)
SELECT
    LEAST(a.product_id, b.product_id),
    GREATEST(a.product_id, b.product_id),
    'identical',
    'ean_match',
    'Auto-linked: same EAN ' || a.ean || ' across ' || a.country || '↔' || b.country
FROM public.products a
JOIN public.products b
  ON a.ean = b.ean
 AND a.country < b.country          -- avoid self-join duplicates + enforce ordering
WHERE a.is_deprecated IS NOT TRUE
  AND b.is_deprecated IS NOT TRUE
  AND a.ean IS NOT NULL
ON CONFLICT (product_id_a, product_id_b) DO NOTHING;

-- ─── 2. Brand+name fuzzy linking (high confidence) ──────────
-- Same brand + same category + name similarity ≥ 0.6 → identical, brand_match
INSERT INTO public.product_links (product_id_a, product_id_b, link_type, confidence, notes)
SELECT
    LEAST(a.product_id, b.product_id),
    GREATEST(a.product_id, b.product_id),
    'identical',
    'brand_match',
    'Auto-linked: brand "' || a.brand || '" + name similarity '
      || round(similarity(a.product_name, b.product_name)::numeric, 2)
FROM public.products a
JOIN public.products b
  ON a.brand = b.brand
 AND a.category = b.category
 AND a.country < b.country          -- enforce ordering + distinct pairs
WHERE a.is_deprecated IS NOT TRUE
  AND b.is_deprecated IS NOT TRUE
  AND similarity(a.product_name, b.product_name) >= 0.6
ON CONFLICT (product_id_a, product_id_b) DO NOTHING;

-- ─── 3. Brand+name fuzzy linking (medium confidence) ────────
-- Same brand + same category + name similarity 0.4–0.6 → equivalent, brand_match
INSERT INTO public.product_links (product_id_a, product_id_b, link_type, confidence, notes)
SELECT
    LEAST(a.product_id, b.product_id),
    GREATEST(a.product_id, b.product_id),
    'equivalent',
    'brand_match',
    'Auto-linked: brand "' || a.brand || '" + name similarity '
      || round(similarity(a.product_name, b.product_name)::numeric, 2)
FROM public.products a
JOIN public.products b
  ON a.brand = b.brand
 AND a.category = b.category
 AND a.country < b.country
WHERE a.is_deprecated IS NOT TRUE
  AND b.is_deprecated IS NOT TRUE
  AND similarity(a.product_name, b.product_name) >= 0.4
  AND similarity(a.product_name, b.product_name) < 0.6
  -- Skip pairs already linked in step 2
  AND NOT EXISTS (
      SELECT 1 FROM public.product_links pl
      WHERE pl.product_id_a = LEAST(a.product_id, b.product_id)
        AND pl.product_id_b = GREATEST(a.product_id, b.product_id)
  )
ON CONFLICT (product_id_a, product_id_b) DO NOTHING;

-- ─── 4. Helper function: auto-link new products ─────────────
-- Call after pipeline runs to link newly added products
CREATE OR REPLACE FUNCTION public.auto_link_cross_country_products()
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_ean_count   integer := 0;
    v_brand_count integer := 0;
BEGIN
    -- Step A: EAN matches
    WITH inserted AS (
        INSERT INTO product_links (product_id_a, product_id_b, link_type, confidence, notes)
        SELECT
            LEAST(a.product_id, b.product_id),
            GREATEST(a.product_id, b.product_id),
            'identical',
            'ean_match',
            'Auto-linked: same EAN ' || a.ean || ' across ' || a.country || '↔' || b.country
        FROM products a
        JOIN products b
          ON a.ean = b.ean
         AND a.country < b.country
        WHERE a.is_deprecated IS NOT TRUE
          AND b.is_deprecated IS NOT TRUE
          AND a.ean IS NOT NULL
        ON CONFLICT (product_id_a, product_id_b) DO NOTHING
        RETURNING 1
    )
    SELECT count(*) INTO v_ean_count FROM inserted;

    -- Step B: Brand+name matches (high: ≥0.6 → identical, medium: 0.4–<0.6 → equivalent)
    WITH inserted AS (
        INSERT INTO product_links (product_id_a, product_id_b, link_type, confidence, notes)
        SELECT
            LEAST(a.product_id, b.product_id),
            GREATEST(a.product_id, b.product_id),
            CASE WHEN similarity(a.product_name, b.product_name) >= 0.6
                 THEN 'identical' ELSE 'equivalent' END,
            'brand_match',
            'Auto-linked: brand "' || a.brand || '" + name similarity '
              || round(similarity(a.product_name, b.product_name)::numeric, 2)
        FROM products a
        JOIN products b
          ON a.brand = b.brand
         AND a.category = b.category
         AND a.country < b.country
        WHERE a.is_deprecated IS NOT TRUE
          AND b.is_deprecated IS NOT TRUE
          AND similarity(a.product_name, b.product_name) >= 0.4
        ON CONFLICT (product_id_a, product_id_b) DO NOTHING
        RETURNING 1
    )
    SELECT count(*) INTO v_brand_count FROM inserted;

    RETURN jsonb_build_object(
        'ean_links_created',   v_ean_count,
        'brand_links_created', v_brand_count,
        'total_links', (SELECT count(*) FROM product_links)
    );
END;
$$;

COMMENT ON FUNCTION public.auto_link_cross_country_products IS
  'Automatically populates product_links by scanning for EAN matches '
  'and brand+name fuzzy matches across countries. Safe to call repeatedly '
  '(ON CONFLICT DO NOTHING). Returns count of new links created. Issue #605.';

GRANT EXECUTE ON FUNCTION public.auto_link_cross_country_products()
    TO service_role;

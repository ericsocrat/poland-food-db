-- Migration: Add gs1_country_hint() utility function
-- Purpose: Extract GS1 country-of-registration hint from EAN-13 prefix
-- Rollback: DROP FUNCTION IF EXISTS public.gs1_country_hint;
-- Idempotency: CREATE OR REPLACE — safe to run multiple times

-- ═══════════════════════════════════════════════════════════════════════
-- GS1 prefix → country hint (EAN-13 first 2–3 digits)
-- ═══════════════════════════════════════════════════════════════════════
-- GS1 prefix indicates where the barcode was REGISTERED, not where
-- the product was manufactured or sold.  Many imported products carry
-- foreign prefixes.  Use as an admin hint, never as blocking validation.
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.gs1_country_hint(p_ean text)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE STRICT
SET search_path = public
AS $$
  SELECT CASE
    -- NULL / too-short handled by STRICT (returns NULL automatically)
    WHEN length(p_ean) < 3 THEN NULL

    -- Poland (590)
    WHEN substring(p_ean, 1, 3) = '590'
      THEN '{"code":"PL","name":"Poland","confidence":"high"}'::jsonb

    -- Germany (400–440)
    WHEN substring(p_ean, 1, 2) BETWEEN '40' AND '44'
      THEN '{"code":"DE","name":"Germany","confidence":"high"}'::jsonb

    -- France (300–379)
    WHEN substring(p_ean, 1, 2) BETWEEN '30' AND '37'
      THEN '{"code":"FR","name":"France","confidence":"high"}'::jsonb

    -- United Kingdom (50)
    WHEN substring(p_ean, 1, 2) = '50'
      THEN '{"code":"GB","name":"United Kingdom","confidence":"high"}'::jsonb

    -- Ireland (539)
    WHEN substring(p_ean, 1, 3) = '539'
      THEN '{"code":"IE","name":"Ireland","confidence":"high"}'::jsonb

    -- Italy (800–839)
    WHEN substring(p_ean, 1, 3) BETWEEN '800' AND '839'
      THEN '{"code":"IT","name":"Italy","confidence":"high"}'::jsonb

    -- Spain (840–849)
    WHEN substring(p_ean, 1, 3) BETWEEN '840' AND '849'
      THEN '{"code":"ES","name":"Spain","confidence":"high"}'::jsonb

    -- Store-internal (020–029, 200–299)
    WHEN substring(p_ean, 1, 3) BETWEEN '020' AND '029'
      THEN '{"code":"STORE","name":"Store-internal","confidence":"low"}'::jsonb
    WHEN substring(p_ean, 1, 1) = '2'
      THEN '{"code":"STORE","name":"Store-internal","confidence":"low"}'::jsonb

    -- Unknown — return prefix for debugging
    ELSE jsonb_build_object(
      'code', 'UNKNOWN',
      'name', 'Unknown origin',
      'confidence', 'none',
      'prefix', substring(p_ean, 1, 3)
    )
  END;
$$;

COMMENT ON FUNCTION public.gs1_country_hint IS
  'Returns GS1 country-of-registration hint from EAN prefix.
   NOT a definitive origin — imported products carry foreign prefixes.
   Use as admin hint only, never as blocking validation.
   Returns: {code, name, confidence} or NULL for invalid/NULL input.
   Confidence: high (known GS1 prefix), low (store-internal), none (unknown).';

-- Migration: Brand normalization function + brand_alias table for dedup hardening
-- Issue: #861 — Deduplication hardening for multi-source 10K scale
-- Rollback: DROP TABLE IF EXISTS brand_alias; DROP FUNCTION IF EXISTS normalize_brand(text);
-- Idempotency: all DDL guarded with IF NOT EXISTS / CREATE OR REPLACE

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. normalize_brand() — deterministic brand name normalization
--    Rules: UPPER → collapse whitespace → space after dots → trim
--    Examples:
--      'dr. oetker'  → 'DR. OETKER'
--      'dr.oetker'   → 'DR. OETKER'
--      '  Piątnica ' → 'PIĄTNICA'
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.normalize_brand(p_brand text)
RETURNS text
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
SET search_path = public
AS $$
  SELECT TRIM(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        UPPER(TRIM(p_brand)),
        '\s+', ' ', 'g'          -- collapse multiple whitespace to single space
      ),
      '\.(\S)', '. \1', 'g'     -- ensure space after dots (DR.OETKER → DR. OETKER)
    )
  );
$$;

COMMENT ON FUNCTION public.normalize_brand IS
  'Deterministic brand name normalization for dedup matching.
   Rules: UPPER + collapse whitespace + space after dots + trim.
   IMMUTABLE STRICT — safe for indexes and generated columns.';


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. brand_alias table — maps variant spellings to canonical brand names
--    Alias (PK) → canonical brand name (FK to brand_ref)
--    One-way: alias resolves to a single canonical brand.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.brand_alias (
  alias           text PRIMARY KEY,
  canonical_brand text NOT NULL REFERENCES public.brand_ref(brand_name),
  source          text NOT NULL DEFAULT 'manual'
    CHECK (source IN ('manual', 'pipeline', 'automated')),
  created_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.brand_alias IS
  'Maps variant brand spellings to canonical brand_ref entries.
   Example: "Dr Oetker" → "Dr. Oetker", "PIĄTNICA" → "Piątnica".
   Used by pipeline dedup and QA fuzzy-brand checks.';

-- RLS: readable by all, writable by service_role only
ALTER TABLE public.brand_alias ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'brand_alias' AND policyname = 'brand_alias_read_all'
  ) THEN
    CREATE POLICY brand_alias_read_all ON public.brand_alias
      FOR SELECT USING (true);
  END IF;
END $$;

-- Index for reverse lookups (find all aliases for a canonical brand)
CREATE INDEX IF NOT EXISTS idx_brand_alias_canonical
  ON public.brand_alias (canonical_brand);

-- ─── Migration: Harden anon API access ──────────────────────────────────────
-- Issue: QA check #9 (security_posture) found 7 api_* functions callable by
-- anon that were not in the approved allowlist.
--
-- Root causes:
--   1. ALTER DEFAULT PRIVILEGES ... REVOKE EXECUTE FROM PUBLIC (set in
--      20260216000100) only applies to functions created by the same role.
--      Functions created under different role contexts in CI leaked PUBLIC.
--   2. api_search_products & api_record_scan were revoked from anon in
--      localization phase 4 but remained in the QA allowlist (stale).
--   3. Newer functions (product_profile, ingredient_profile, track_event)
--      were intentionally public but not in the allowlist.
--
-- Fix: Blanket REVOKE from anon on ALL api_* functions, then re-grant only
-- the approved public endpoints.
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 1: Revoke anon + PUBLIC from every api_* function in public schema
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT p.oid::regprocedure AS fn_sig
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname LIKE 'api_%'
    LOOP
        EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC, anon', r.fn_sig);
    END LOOP;
END
$$;

-- Step 2: Re-grant approved public endpoints to anon
-- These functions are intentionally callable without authentication.

-- Autocomplete & filter facets (browsing without login)
GRANT EXECUTE ON FUNCTION public.api_search_autocomplete(text, integer)
    TO anon;

GRANT EXECUTE ON FUNCTION public.api_get_filter_options(text)
    TO anon;

-- Shared resources (public links)
GRANT EXECUTE ON FUNCTION public.api_get_shared_list(text, integer, integer)
    TO anon;

GRANT EXECUTE ON FUNCTION public.api_get_shared_comparison(text)
    TO anon;

GRANT EXECUTE ON FUNCTION public.api_get_products_for_compare(bigint[])
    TO anon;

-- Fire-and-forget analytics (both auth and anon users)
GRANT EXECUTE ON FUNCTION public.api_track_event(text, jsonb, text, text)
    TO anon;

-- Public product/ingredient profiles (browsable without auth)
GRANT EXECUTE ON FUNCTION public.api_get_product_profile(bigint, text)
    TO anon;

GRANT EXECUTE ON FUNCTION public.api_get_product_profile_by_ean(text, text)
    TO anon;

GRANT EXECUTE ON FUNCTION public.api_get_ingredient_profile(bigint, text)
    TO anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Make resolve_effective_country() SECURITY DEFINER
--
-- Problem:
--   In Supabase-managed Postgres, the `postgres` role is NOT a true superuser
--   (rolsuper=false). Our SECURITY DEFINER API functions (api_search_products,
--   etc.) run as `postgres`, and resolve_effective_country() reads
--   user_preferences which has RLS with FORCE ROW SECURITY.
--
--   Although the tier-2 preference lookup currently works (because `postgres`
--   has explicit SELECT privilege on user_preferences), relying on non-superuser
--   implicit privilege is fragile. If user_preferences RLS policies change,
--   or if the function owner changes, the preference lookup could silently
--   fail and fall through to the tier-3 default country.
--
-- Fix:
--   Make resolve_effective_country() SECURITY DEFINER with explicit
--   SET search_path. This guarantees the function always executes with
--   the owner's privileges, regardless of the calling context or RLS changes.
--   EXECUTE remains revoked from anon and PUBLIC (internal-only function).
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- Drop and recreate with SECURITY DEFINER + SET search_path
CREATE OR REPLACE FUNCTION public.resolve_effective_country(
    p_country text DEFAULT NULL
)
RETURNS text
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (pass-through if not NULL)
        NULLIF(TRIM(p_country), ''),
        -- Priority 2: authenticated user's saved country preference
        (SELECT up.country
         FROM user_preferences up
         WHERE up.user_id = auth.uid()),
        -- Priority 3: first active country (deterministic via ORDER BY)
        (SELECT cr.country_code
         FROM country_ref cr
         WHERE cr.is_active = true
         ORDER BY cr.country_code
         LIMIT 1)
    );
$function$;

COMMENT ON FUNCTION public.resolve_effective_country(text) IS
'Resolves the effective country for API calls. '
'Priority: explicit param → user_preferences.country → first active country. '
'Guarantees a non-NULL country is always returned. '
'SECURITY DEFINER: ensures user_preferences read bypasses RLS regardless of owner role superuser status.';

-- Maintain existing privilege model: internal-only
-- Revoke from all RPC-callable roles (PUBLIC, anon, authenticated)
REVOKE EXECUTE ON FUNCTION public.resolve_effective_country(text)
    FROM PUBLIC, anon, authenticated;

COMMIT;

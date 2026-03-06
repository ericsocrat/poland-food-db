-- Migration: Revoke anon access to internal v33 scoring functions + v2 helper functions
-- These were accidentally granted to anon in their originating migrations.
-- Internal scoring/helper functions should only be callable by authenticated + service_role.
-- Rollback: GRANT EXECUTE ON FUNCTION <name> TO anon; (for each function)

-- ── v3.3 scoring internals (granted in 20260315001910) ──────────────────────
REVOKE EXECUTE ON FUNCTION public.compute_unhealthiness_v33(
    numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric, numeric, numeric
) FROM PUBLIC, anon;

REVOKE EXECUTE ON FUNCTION public.explain_score_v33(
    numeric, numeric, numeric, numeric, numeric, numeric, text, text, numeric, numeric, numeric
) FROM PUBLIC, anon;

-- ── v2 alternative-finding internals (granted in 20260315001800) ─────────────
REVOKE EXECUTE ON FUNCTION public.find_better_alternatives_v2(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean, boolean, uuid, boolean, integer
) FROM PUBLIC, anon;

REVOKE EXECUTE ON FUNCTION public.category_affinity(text, text) FROM PUBLIC, anon;

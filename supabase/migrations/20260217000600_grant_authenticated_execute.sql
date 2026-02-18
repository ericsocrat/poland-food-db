-- ════════════════════════════════════════════════════════════════════════════
-- Migration: Grant EXECUTE on authenticated-only functions to `authenticated`
-- ════════════════════════════════════════════════════════════════════════════
-- Migration 20260216000100 revoked EXECUTE from PUBLIC and anon, but never
-- explicitly granted EXECUTE to the `authenticated` role. This left all
-- revoked functions uncallable — including product lists, comparisons,
-- saved searches, scanner history, and submissions.
--
-- This migration fixes the issue by granting EXECUTE to `authenticated`
-- (and admin functions also to `service_role`) for every function that
-- was revoked in 20260216000100.
-- ════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ──────────────────────────────────────────────────────────────────────────
-- 1. Product Lists (Issue #20)
-- ──────────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.api_get_lists()                                      TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_list_items(uuid, integer, integer)            TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_create_list(text, text, text)                     TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_update_list(uuid, text, text)                     TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_delete_list(uuid)                                 TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_add_to_list(uuid, bigint, text)                   TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_remove_from_list(uuid, bigint)                    TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_reorder_list(uuid, bigint[])                      TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_toggle_share(uuid, boolean)                       TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_revoke_share(uuid)                                TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_avoid_product_ids()                           TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 2. Product List Membership (Issue #20 addendum)
-- ──────────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.api_get_product_list_membership(bigint)               TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_favorite_product_ids()                        TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 3. Product Comparisons (Issue #21)
-- ──────────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.api_save_comparison(bigint[], text)                    TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_saved_comparisons(integer, integer)            TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_delete_comparison(uuid)                            TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 4. Enhanced Search (saved searches)
-- ──────────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.api_save_search(text, text, jsonb)                     TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_saved_searches()                               TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_delete_saved_search(uuid)                          TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 5. Scanner & Submissions (Issue #23)
-- ──────────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.api_get_scan_history(integer, integer, text)           TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_submit_product(text, text, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_get_my_submissions(integer, integer)               TO authenticated;

-- Admin functions → service_role only (not general authenticated users)
GRANT EXECUTE ON FUNCTION public.api_admin_get_submissions(text, integer, integer)      TO service_role;
GRANT EXECUTE ON FUNCTION public.api_admin_review_submission(uuid, text, bigint)        TO service_role;

COMMIT;

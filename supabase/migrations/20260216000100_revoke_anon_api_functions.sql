-- ════════════════════════════════════════════════════════════════════════════
-- Migration: Revoke anon EXECUTE from authenticated-only api_* functions
-- ════════════════════════════════════════════════════════════════════════════
-- Several api_* functions created after auth_only_platform gained PUBLIC
-- EXECUTE by default (PostgreSQL default). This migration explicitly
-- revokes anon access from all authenticated-only functions, and sets
-- ALTER DEFAULT PRIVILEGES to prevent future regressions.
--
-- Functions intentionally available to anon (public endpoints):
--   api_search_products, api_search_autocomplete, api_get_filter_options,
--   api_record_scan, api_get_shared_list, api_get_shared_comparison,
--   api_get_products_for_compare
-- ════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ──────────────────────────────────────────────────────────────────────────
-- 1. Bulk REVOKE from PUBLIC and anon on authenticated-only functions
-- ──────────────────────────────────────────────────────────────────────────

-- Product Lists (Issue #20) — all except api_get_shared_list
REVOKE EXECUTE ON FUNCTION public.api_get_lists()                                      FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_list_items(uuid, integer, integer)            FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_create_list(text, text, text)                     FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_update_list(uuid, text, text)                     FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_delete_list(uuid)                                 FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_add_to_list(uuid, bigint, text)                   FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_remove_from_list(uuid, bigint)                    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_reorder_list(uuid, bigint[])                      FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_toggle_share(uuid, boolean)                       FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_revoke_share(uuid)                                FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_avoid_product_ids()                           FROM PUBLIC, anon;

-- Product List Membership (Issue #20 addendum)
REVOKE EXECUTE ON FUNCTION public.api_get_product_list_membership(bigint)               FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_favorite_product_ids()                        FROM PUBLIC, anon;

-- Product Comparisons (Issue #21) — all except shared comparison + compare data
REVOKE EXECUTE ON FUNCTION public.api_save_comparison(bigint[], text)                    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_saved_comparisons(integer, integer)            FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_delete_comparison(uuid)                            FROM PUBLIC, anon;

-- Enhanced Search (saved searches are auth-only)
REVOKE EXECUTE ON FUNCTION public.api_save_search(text, text, jsonb)                     FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_saved_searches()                               FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_delete_saved_search(uuid)                          FROM PUBLIC, anon;

-- Scanner & Submissions (Issue #23) — all except api_record_scan
REVOKE EXECUTE ON FUNCTION public.api_get_scan_history(integer, integer, text)           FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_submit_product(text, text, text, text, text, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_my_submissions(integer, integer)               FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_submissions(text, integer, integer)      FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_admin_review_submission(uuid, text, bigint)        FROM PUBLIC, anon;

-- ──────────────────────────────────────────────────────────────────────────
-- 2. Prevent future regressions: revoke default PUBLIC EXECUTE
-- ──────────────────────────────────────────────────────────────────────────

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

COMMIT;

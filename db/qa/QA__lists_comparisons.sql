-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Product Lists & Comparisons
-- Validates the structural integrity, RLS, indexes, triggers, constraints,
-- and API function signatures for user_product_lists, user_product_list_items,
-- and user_comparisons tables introduced in Issues #20 and #21.
-- 12 checks — all BLOCKING.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  RLS is enabled on all three user-data tables
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. RLS enabled on list & comparison tables' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN ('user_product_lists', 'user_product_list_items', 'user_comparisons')
  AND c.relrowsecurity = false;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  Each table has at least one RLS policy defined
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. Each list/comparison table has RLS policies' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'user_product_lists', 'user_product_list_items', 'user_comparisons'
    ]) AS tbl
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_policy pol
    JOIN pg_class c ON pol.polrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relname = expected.tbl
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  All list/comparison API functions exist and are SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. List/comparison api_* functions are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'api_get_lists',
        'api_get_list_items',
        'api_create_list',
        'api_update_list',
        'api_delete_list',
        'api_add_to_list',
        'api_remove_from_list',
        'api_reorder_list',
        'api_toggle_share',
        'api_revoke_share',
        'api_get_shared_list',
        'api_get_avoid_product_ids',
        'api_get_products_for_compare',
        'api_save_comparison',
        'api_get_saved_comparisons',
        'api_get_shared_comparison',
        'api_delete_comparison'
    ]) AS fn
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname = expected.fn
      AND p.prosecdef = true
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  user_product_lists.list_type CHECK constraint exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. list_type CHECK constraint exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_constraint con
           JOIN pg_class c ON con.conrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_product_lists'
             AND con.contype = 'c'
             AND pg_get_constraintdef(con.oid) LIKE '%list_type%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  user_comparisons.product_ids array length CHECK (2-4) exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. comparison product_ids array length CHECK exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_constraint con
           JOIN pg_class c ON con.conrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_comparisons'
             AND con.contype = 'c'
             AND pg_get_constraintdef(con.oid) LIKE '%product_ids%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  Unique partial indexes for favorites/avoid per user exist
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. Unique favorites + avoid indexes exist' AS check_name,
       (2 - COUNT(*)) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'i'
  AND c.relname IN ('idx_upl_unique_favorites', 'idx_upl_unique_avoid');

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  Performance indexes exist on user_product_lists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. user_product_lists has required indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['idx_upl_user_id', 'idx_upl_share_token', 'idx_upl_user_type']) AS idx
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relkind = 'i' AND c.relname = expected.idx
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  Performance indexes exist on user_comparisons
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. user_comparisons has required indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['idx_uc_user_id', 'idx_uc_share_token']) AS idx
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relkind = 'i' AND c.relname = expected.idx
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  updated_at trigger exists on user_product_lists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. user_product_lists has updated_at trigger' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_trigger t
           JOIN pg_class c ON t.tgrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_product_lists'
             AND t.tgname = 'trg_user_product_lists_updated_at'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10 Comparison count-limiter trigger exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. user_comparisons has limit trigger' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_trigger t
           JOIN pg_class c ON t.tgrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_comparisons'
             AND t.tgname = 'trg_limit_user_comparisons'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #11 Auto-create default lists trigger fires on user_preferences
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. Auto-create-lists trigger is on user_preferences' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_trigger t
           JOIN pg_class c ON t.tgrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'user_preferences'
             AND t.tgname = 'trg_auto_create_lists'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12 anon cannot INSERT/UPDATE/DELETE on user_product_lists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. anon has no write privilege on user_product_lists' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['INSERT', 'UPDATE', 'DELETE']) AS priv
) p
WHERE has_table_privilege('anon', 'public.user_product_lists', p.priv);

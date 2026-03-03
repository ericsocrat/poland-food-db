-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Push Notification Infrastructure  (17 checks)
-- Validates push_subscriptions and notification_queue tables, RLS policies,
-- constraints, notification preference columns, and API function contracts.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  push_subscriptions table exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'push_subscriptions'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#1  push_subscriptions table exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  push_subscriptions has RLS enabled
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT relrowsecurity FROM pg_class
        WHERE oid = 'public.push_subscriptions'::regclass
    ) THEN 'PASS' ELSE 'FAIL' END AS "#2  push_subscriptions RLS enabled";

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  push_subscriptions has unique constraint on (user_id, endpoint)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'push_subscriptions'
          AND indexdef LIKE '%user_id%endpoint%'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#3  push_subscriptions unique (user_id, endpoint)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  push_subscriptions user_id cascades on delete
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.referential_constraints
        WHERE constraint_name IN (
            SELECT constraint_name FROM information_schema.table_constraints
            WHERE table_name = 'push_subscriptions' AND constraint_type = 'FOREIGN KEY'
        ) AND delete_rule = 'CASCADE'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#4  push_subscriptions CASCADE on user delete";

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  notification_queue table exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'notification_queue'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#5  notification_queue table exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  notification_queue has RLS enabled
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT relrowsecurity FROM pg_class
        WHERE oid = 'public.notification_queue'::regclass
    ) THEN 'PASS' ELSE 'FAIL' END AS "#6  notification_queue RLS enabled";

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  api_save_push_subscription function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_name = 'api_save_push_subscription'
          AND routine_schema = 'public'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#7  api_save_push_subscription exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  api_delete_push_subscription function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_name = 'api_delete_push_subscription'
          AND routine_schema = 'public'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#8  api_delete_push_subscription exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  api_get_push_subscriptions function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_name = 'api_get_push_subscriptions'
          AND routine_schema = 'public'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#9  api_get_push_subscriptions exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  queue_score_change_notifications trigger function exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_name = 'queue_score_change_notifications'
          AND routine_schema = 'public'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#10  queue_score_change_notifications function exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #11  trg_queue_score_notifications trigger exists on product_score_history
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE trigger_name = 'trg_queue_score_notifications'
          AND event_object_table = 'product_score_history'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#11  trg_queue_score_notifications trigger exists";

-- ─────────────────────────────────────────────────────────────────────────────
-- #12  api_save_push_subscription returns auth error without auth
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        api_save_push_subscription('https://push.example.com', 'key1', 'key2')
    )->>'error' = 'Authentication required.'
    THEN 'PASS' ELSE 'FAIL' END AS "#12  api_save_push_subscription auth error";

-- ─────────────────────────────────────────────────────────────────────────────
-- #13  api_delete_push_subscription returns auth error without auth
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        api_delete_push_subscription('https://push.example.com')
    )->>'error' = 'Authentication required.'
    THEN 'PASS' ELSE 'FAIL' END AS "#13  api_delete_push_subscription auth error";

-- ─────────────────────────────────────────────────────────────────────────────
-- #14  api_get_push_subscriptions returns auth error without auth
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        api_get_push_subscriptions()
    )->>'error' = 'Authentication required.'
    THEN 'PASS' ELSE 'FAIL' END AS "#14  api_get_push_subscriptions auth error";

-- ─────────────────────────────────────────────────────────────────────────────
-- #15  user_preferences.notification_score_changes column exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_preferences'
          AND column_name = 'notification_score_changes'
          AND data_type = 'boolean'
    ) THEN 'PASS' ELSE 'FAIL' END AS "#15  user_preferences.notification_score_changes exists (boolean)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #16  user_preferences.notification_frequency column exists with CHECK
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_preferences'
          AND column_name = 'notification_frequency'
          AND data_type = 'text'
    ) AND EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_notification_frequency'
          AND conrelid = 'public.user_preferences'::regclass
    ) THEN 'PASS' ELSE 'FAIL' END AS "#16  user_preferences.notification_frequency exists with CHECK";

-- ─────────────────────────────────────────────────────────────────────────────
-- #17  api_set_user_preferences has 9 params (new signature)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.proname = 'api_set_user_preferences'
          AND pronargs = 9
    ) THEN 'PASS' ELSE 'FAIL' END AS "#17  api_set_user_preferences accepts 9 params";

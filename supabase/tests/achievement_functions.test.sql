-- supabase/tests/achievement_functions.test.sql
-- pgTAP tests for Issue #51: Achievements v1

BEGIN;
SELECT plan(14);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. SCHEMA TESTS
-- ═══════════════════════════════════════════════════════════════════════════

-- achievement_def table exists
SELECT has_table('achievement_def', 'achievement_def table exists');

-- user_achievement table exists
SELECT has_table('user_achievement', 'user_achievement table exists');

-- achievement_def has expected columns
SELECT has_column('achievement_def', 'slug', 'achievement_def has slug column');
SELECT has_column('achievement_def', 'category', 'achievement_def has category column');
SELECT has_column('achievement_def', 'threshold', 'achievement_def has threshold column');
SELECT has_column('achievement_def', 'is_active', 'achievement_def has is_active column');

-- user_achievement has expected columns
SELECT has_column('user_achievement', 'user_id', 'user_achievement has user_id column');
SELECT has_column('user_achievement', 'achievement_id', 'user_achievement has achievement_id column');
SELECT has_column('user_achievement', 'progress', 'user_achievement has progress column');
SELECT has_column('user_achievement', 'unlocked_at', 'user_achievement has unlocked_at column');


-- ═══════════════════════════════════════════════════════════════════════════
-- 2. FUNCTION TESTS
-- ═══════════════════════════════════════════════════════════════════════════

-- increment_achievement_progress exists and doesn't throw
SELECT lives_ok(
    $$SELECT public.increment_achievement_progress('first_scan', 1)$$,
    'increment_achievement_progress does not throw'
);

-- increment_achievement_progress returns error for unauthenticated user
SELECT is(
    (public.increment_achievement_progress('first_scan', 1))->>'error',
    'Authentication required',
    'increment_achievement_progress requires auth'
);

-- api_get_achievements exists and doesn't throw
SELECT lives_ok(
    $$SELECT public.api_get_achievements()$$,
    'api_get_achievements does not throw'
);

-- api_get_achievements returns error for unauthenticated user
SELECT is(
    (public.api_get_achievements())->>'error',
    'Authentication required',
    'api_get_achievements requires auth'
);

SELECT * FROM finish();
ROLLBACK;

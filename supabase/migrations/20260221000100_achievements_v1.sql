-- 20260221000100_achievements_v1.sql
-- Issue #51: Achievements v1 — Schema + Unlock Engine + Seed Data
--
-- Phase 1: achievement_def + user_achievement tables, RLS, indexes
-- Phase 2: increment_achievement_progress() unlock engine function
-- Phase 3: Seed 18 achievement definitions across 4 categories
-- Phase 4: API surface functions (get achievements, check unlock)
-- Rollback: DROP TABLE user_achievement CASCADE; DROP TABLE achievement_def CASCADE;

SET search_path = public;

-- ═══════════════════════════════════════════════════════════════════════════
-- PHASE 1: SCHEMA
-- ═══════════════════════════════════════════════════════════════════════════

-- Achievement definitions (admin-managed, data-driven)
CREATE TABLE IF NOT EXISTS achievement_def (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug         TEXT UNIQUE NOT NULL,
    category     TEXT NOT NULL CHECK (category IN ('exploration', 'health', 'engagement', 'mastery')),
    title_key    TEXT NOT NULL,
    desc_key     TEXT NOT NULL,
    icon         TEXT NOT NULL,
    threshold    INTEGER NOT NULL DEFAULT 1 CHECK (threshold >= 1),
    country      TEXT DEFAULT NULL,
    sort_order   INTEGER NOT NULL DEFAULT 0,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- User achievement progress + unlocks
CREATE TABLE IF NOT EXISTS user_achievement (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_id  UUID NOT NULL REFERENCES achievement_def(id) ON DELETE CASCADE,
    progress        INTEGER NOT NULL DEFAULT 0 CHECK (progress >= 0),
    unlocked_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, achievement_id)
);

-- Enable RLS
ALTER TABLE achievement_def ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievement ENABLE ROW LEVEL SECURITY;

-- RLS policies: achievement_def is public-read for active definitions
CREATE POLICY "achievement_def_public_read"
    ON achievement_def FOR SELECT
    TO anon, authenticated
    USING (is_active = TRUE);

-- RLS policies: user_achievement is user-scoped
CREATE POLICY "user_achievement_select"
    ON user_achievement FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "user_achievement_insert"
    ON user_achievement FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_achievement_update"
    ON user_achievement FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_achievement_user
    ON user_achievement(user_id);

CREATE INDEX IF NOT EXISTS idx_user_achievement_unlock
    ON user_achievement(user_id, unlocked_at)
    WHERE unlocked_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_achievement_def_category
    ON achievement_def(category);

CREATE INDEX IF NOT EXISTS idx_achievement_def_slug
    ON achievement_def(slug);


-- ═══════════════════════════════════════════════════════════════════════════
-- PHASE 2: UNLOCK ENGINE
-- ═══════════════════════════════════════════════════════════════════════════

-- increment_achievement_progress: atomic upsert + threshold check + idempotent unlock
CREATE OR REPLACE FUNCTION increment_achievement_progress(
    p_achievement_slug TEXT,
    p_increment INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id        UUID := auth.uid();
    v_def            RECORD;
    v_progress       INTEGER;
    v_unlocked       BOOLEAN := FALSE;
    v_newly_unlocked BOOLEAN := FALSE;
BEGIN
    -- Auth check
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Authentication required');
    END IF;

    -- Validate increment
    IF p_increment < 1 THEN
        RETURN jsonb_build_object('error', 'Increment must be positive');
    END IF;

    -- Get achievement definition
    SELECT * INTO v_def
    FROM achievement_def
    WHERE slug = p_achievement_slug AND is_active = TRUE;

    IF v_def IS NULL THEN
        RETURN jsonb_build_object('error', 'Achievement not found');
    END IF;

    -- Upsert progress
    INSERT INTO user_achievement (user_id, achievement_id, progress)
    VALUES (v_user_id, v_def.id, p_increment)
    ON CONFLICT (user_id, achievement_id)
    DO UPDATE SET progress = user_achievement.progress + p_increment
    RETURNING progress INTO v_progress;

    -- Check if threshold met and not already unlocked
    IF v_progress >= v_def.threshold THEN
        UPDATE user_achievement
        SET unlocked_at = COALESCE(unlocked_at, now())
        WHERE user_id = v_user_id
          AND achievement_id = v_def.id
          AND unlocked_at IS NULL;

        v_newly_unlocked := FOUND;
        v_unlocked := TRUE;
    END IF;

    RETURN jsonb_build_object(
        'slug',            p_achievement_slug,
        'progress',        v_progress,
        'threshold',       v_def.threshold,
        'unlocked',        v_unlocked,
        'newly_unlocked',  v_newly_unlocked
    );
END;
$$;

-- Grant execute to authenticated users only
GRANT EXECUTE ON FUNCTION increment_achievement_progress(TEXT, INTEGER)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION increment_achievement_progress(TEXT, INTEGER)
    FROM PUBLIC, anon;


-- ═══════════════════════════════════════════════════════════════════════════
-- PHASE 3: SEED ACHIEVEMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- Exploration category
INSERT INTO achievement_def (slug, category, title_key, desc_key, icon, threshold, sort_order) VALUES
    ('first_scan',            'exploration', 'achievement.first_scan.title',            'achievement.first_scan.desc',            '🔍', 1,  10),
    ('scan_10',               'exploration', 'achievement.scan_10.title',               'achievement.scan_10.desc',               '📱', 10, 20),
    ('scan_50',               'exploration', 'achievement.scan_50.title',               'achievement.scan_50.desc',               '🏅', 50, 30),
    ('first_search',          'exploration', 'achievement.first_search.title',          'achievement.first_search.desc',          '🔎', 1,  40),
    ('explore_5_categories',  'exploration', 'achievement.explore_5_categories.title',  'achievement.explore_5_categories.desc',  '🧭', 5,  50)
ON CONFLICT (slug) DO NOTHING;

-- Health category
INSERT INTO achievement_def (slug, category, title_key, desc_key, icon, threshold, sort_order) VALUES
    ('first_low_score',   'health', 'achievement.first_low_score.title',   'achievement.first_low_score.desc',   '💚', 1,  10),
    ('low_score_10',      'health', 'achievement.low_score_10.title',      'achievement.low_score_10.desc',      '🥗', 10, 20),
    ('compare_products',  'health', 'achievement.compare_products.title',  'achievement.compare_products.desc',  '⚖️', 1,  30),
    ('compare_10',        'health', 'achievement.compare_10.title',        'achievement.compare_10.desc',        '🔬', 10, 40),
    ('allergen_filter',   'health', 'achievement.allergen_filter.title',   'achievement.allergen_filter.desc',   '🛡️', 1,  50)
ON CONFLICT (slug) DO NOTHING;

-- Engagement category
INSERT INTO achievement_def (slug, category, title_key, desc_key, icon, threshold, sort_order) VALUES
    ('first_list',         'engagement', 'achievement.first_list.title',         'achievement.first_list.desc',         '📋', 1,  10),
    ('list_10_products',   'engagement', 'achievement.list_10_products.title',   'achievement.list_10_products.desc',   '📚', 10, 20),
    ('first_submission',   'engagement', 'achievement.first_submission.title',   'achievement.first_submission.desc',   '🦸', 1,  30),
    ('share_product',      'engagement', 'achievement.share_product.title',      'achievement.share_product.desc',      '🔗', 1,  40),
    ('weekly_streak_4',    'engagement', 'achievement.weekly_streak_4.title',    'achievement.weekly_streak_4.desc',    '🔥', 4,  50)
ON CONFLICT (slug) DO NOTHING;

-- Mastery category
INSERT INTO achievement_def (slug, category, title_key, desc_key, icon, threshold, sort_order) VALUES
    ('read_learn_page',  'mastery', 'achievement.read_learn_page.title',  'achievement.read_learn_page.desc',  '📖', 1, 10),
    ('all_exploration',  'mastery', 'achievement.all_exploration.title',  'achievement.all_exploration.desc',  '⭐', 5, 20),
    ('all_health',       'mastery', 'achievement.all_health.title',       'achievement.all_health.desc',       '🏆', 5, 30)
ON CONFLICT (slug) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════════
-- PHASE 4: API SURFACE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- api_get_achievements: returns all definitions + user progress (joined)
CREATE OR REPLACE FUNCTION api_get_achievements()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_result  JSONB;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Authentication required');
    END IF;

    SELECT jsonb_build_object(
        'achievements', COALESCE(jsonb_agg(
            jsonb_build_object(
                'id',          d.id,
                'slug',        d.slug,
                'category',    d.category,
                'title_key',   d.title_key,
                'desc_key',    d.desc_key,
                'icon',        d.icon,
                'threshold',   d.threshold,
                'country',     d.country,
                'sort_order',  d.sort_order,
                'progress',    COALESCE(ua.progress, 0),
                'unlocked_at', ua.unlocked_at
            ) ORDER BY d.category, d.sort_order
        ), '[]'::jsonb),
        'total',    COUNT(*)::integer,
        'unlocked', COUNT(ua.unlocked_at)::integer
    ) INTO v_result
    FROM achievement_def d
    LEFT JOIN user_achievement ua
        ON ua.achievement_id = d.id AND ua.user_id = v_user_id
    WHERE d.is_active = TRUE;

    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION api_get_achievements() TO authenticated;
REVOKE EXECUTE ON FUNCTION api_get_achievements() FROM PUBLIC, anon;

-- ============================================================
-- Migration: RLS User Table Hardening
-- Issue: #359 — security(rls): RLS policy hardening
-- Phase: 2 of 3
--
-- Changes all user_* mutation policies from {public} to {authenticated}.
-- SELECT policies for shared items (comparisons, lists) remain {public}
-- to allow share-token access by anonymous users.
--
-- Tables affected:
--   - user_preferences (4 policies)
--   - user_health_profiles (4 policies)
--   - user_comparisons (1 mutation policy)
--   - user_product_lists (1 mutation policy)
--   - user_product_list_items (1 mutation policy)
--   - user_product_views (1 mutation policy)
--   - user_saved_searches (1 mutation policy)
--   - scan_history (2 policies)
--   - product_submissions (2 policies)
--
-- Rollback: Re-create policies with {public} role grants.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 1. user_preferences — all 4 policies: {public} → {authenticated}
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS user_preferences_select_own ON user_preferences;
CREATE POLICY user_preferences_select_own ON user_preferences
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS user_preferences_insert_own ON user_preferences;
CREATE POLICY user_preferences_insert_own ON user_preferences
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS user_preferences_update_own ON user_preferences;
CREATE POLICY user_preferences_update_own ON user_preferences
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS user_preferences_delete_own ON user_preferences;
CREATE POLICY user_preferences_delete_own ON user_preferences
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 2. user_health_profiles — all 4 policies: {public} → {authenticated}
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS health_profiles_select_own ON user_health_profiles;
CREATE POLICY health_profiles_select_own ON user_health_profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS health_profiles_insert_own ON user_health_profiles;
CREATE POLICY health_profiles_insert_own ON user_health_profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS health_profiles_update_own ON user_health_profiles;
CREATE POLICY health_profiles_update_own ON user_health_profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS health_profiles_delete_own ON user_health_profiles;
CREATE POLICY health_profiles_delete_own ON user_health_profiles
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 3. user_comparisons — mutation: {public} ALL → {authenticated} ALL
--    Keep: "Public read via share token" (anon needs share-token access)
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users manage own comparisons" ON user_comparisons;
CREATE POLICY "Users manage own comparisons" ON user_comparisons
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 4. user_product_lists — mutation: {public} ALL → {authenticated} ALL
--    Keep: "Public read shared lists" (anon needs share-token access)
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users manage own lists" ON user_product_lists;
CREATE POLICY "Users manage own lists" ON user_product_lists
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 5. user_product_list_items — mutation: {public} ALL → {authenticated} ALL
--    Keep: "Public read items in shared lists" (anon needs access)
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users manage items in own lists" ON user_product_list_items;
CREATE POLICY "Users manage items in own lists" ON user_product_list_items
  FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM user_product_lists
    WHERE user_product_lists.id = user_product_list_items.list_id
      AND user_product_lists.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM user_product_lists
    WHERE user_product_lists.id = user_product_list_items.list_id
      AND user_product_lists.user_id = auth.uid()
  ));

-- ═══════════════════════════════════════════════════════════════
-- 6. user_product_views — {public} ALL → {authenticated} ALL
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users see own views" ON user_product_views;
CREATE POLICY "Users see own views" ON user_product_views
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 7. user_saved_searches — {public} ALL → {authenticated} ALL
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users manage own saved searches" ON user_saved_searches;
CREATE POLICY "Users manage own saved searches" ON user_saved_searches
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 8. scan_history — {public} → {authenticated}
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users insert own scans" ON scan_history;
CREATE POLICY "Users insert own scans" ON scan_history
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users see own scans" ON scan_history;
CREATE POLICY "Users see own scans" ON scan_history
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- 9. product_submissions — {public} → {authenticated}
--    Note: admin review via service_role is already handled elsewhere
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "Users insert own submissions" ON product_submissions;
CREATE POLICY "Users insert own submissions" ON product_submissions
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users see own submissions" ON product_submissions;
CREATE POLICY "Users see own submissions" ON product_submissions
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

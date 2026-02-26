-- ============================================================
-- Migration: RLS Missing Policies + Enable Disabled RLS
-- Issue: #359 — security(rls): RLS policy hardening
-- Phase: 3 of 3
--
-- Fixes:
--   - analytics_daily: RLS on, no policies → add service write + auth read
--   - audit_results: RLS on, no policies → add service write + auth read
--   - deletion_audit_log: RLS on, no policies → add service write + auth read
--   - allowed_event_names: RLS disabled → enable + public read + service write
--   - scoring_model_versions: RLS disabled → enable + public read + service write
--
-- Rollback: DROP the created policies; ALTER TABLE ... DISABLE ROW LEVEL SECURITY
--           for allowed_event_names and scoring_model_versions.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 1. analytics_daily — RLS on, zero policies (deny-all currently)
-- ═══════════════════════════════════════════════════════════════
CREATE POLICY analytics_daily_service_all ON analytics_daily
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

CREATE POLICY analytics_daily_auth_read ON analytics_daily
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 2. audit_results — RLS on, zero policies (deny-all currently)
-- ═══════════════════════════════════════════════════════════════
CREATE POLICY audit_results_service_all ON audit_results
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

CREATE POLICY audit_results_auth_read ON audit_results
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 3. deletion_audit_log — RLS on, zero policies (deny-all currently)
-- ═══════════════════════════════════════════════════════════════
CREATE POLICY deletion_audit_service_all ON deletion_audit_log
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

CREATE POLICY deletion_audit_auth_read ON deletion_audit_log
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 4. allowed_event_names — RLS DISABLED → enable + restrict
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE allowed_event_names ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_names_public_read ON allowed_event_names
  FOR SELECT TO public
  USING (true);

CREATE POLICY event_names_service_write ON allowed_event_names
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════════
-- 5. scoring_model_versions — RLS DISABLED → enable + restrict
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE scoring_model_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY smv_public_read ON scoring_model_versions
  FOR SELECT TO public
  USING (true);

CREATE POLICY smv_service_write ON scoring_model_versions
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

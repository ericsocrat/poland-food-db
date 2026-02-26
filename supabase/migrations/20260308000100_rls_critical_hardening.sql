-- ============================================================
-- Migration: RLS Critical Hardening — Admin/Service Tables
-- Issue: #359 — security(rls): RLS policy hardening
-- Phase: 1 of 3
--
-- Fixes CRITICAL/HIGH vulnerabilities:
--   - feature_flags: {public} ALL → service_role only
--   - flag_overrides: {public} ALL → service_role only
--   - score_audit_log: {public} ALL → postgres/service_role writes, authenticated reads
--   - score_distribution_snapshots: {public} ALL → service_role writes, authenticated reads
--   - score_shadow_results: {public} ALL → service_role writes
--   - data_conflicts: {public} ALL (current_setting check) → service_role only
--   - product_change_log: {public} ALL (current_setting check) → postgres writes, authenticated reads
--   - flag_audit_log: {public} INSERT true → service_role only
--
-- Rollback: Re-create the original policies with {public} role grants.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 1. feature_flags — CRITICAL: anon could toggle feature flags
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS flags_admin ON feature_flags;
CREATE POLICY flags_service_admin ON feature_flags
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);
-- flags_select (public SELECT) intentionally kept — read is safe

-- ═══════════════════════════════════════════════════════════════
-- 2. flag_overrides — CRITICAL: anon could override feature flags
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS overrides_admin ON flag_overrides;
CREATE POLICY overrides_service_admin ON flag_overrides
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════════
-- 3. flag_audit_log — HIGH: anon could insert audit log entries
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS audit_insert ON flag_audit_log;
CREATE POLICY audit_service_insert ON flag_audit_log
  FOR INSERT TO service_role, postgres
  WITH CHECK (true);

-- Tighten read to service_role (was {public} with auth.role() check)
DROP POLICY IF EXISTS audit_select ON flag_audit_log;
CREATE POLICY audit_service_select ON flag_audit_log
  FOR SELECT TO service_role
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 4. score_audit_log — HIGH: {public} ALL true/true (wide open)
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS sal_service_write ON score_audit_log;
CREATE POLICY sal_service_write ON score_audit_log
  FOR ALL TO postgres, service_role
  USING (true) WITH CHECK (true);

-- Tighten read: was {public} SELECT true, now authenticated only
DROP POLICY IF EXISTS sal_authenticated_read ON score_audit_log;
CREATE POLICY sal_authenticated_read ON score_audit_log
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 5. score_distribution_snapshots — HIGH: {public} ALL true/true
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS sds_service_all ON score_distribution_snapshots;
CREATE POLICY sds_service_all ON score_distribution_snapshots
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Tighten read: was {public} SELECT true, now authenticated only
DROP POLICY IF EXISTS sds_authenticated_read ON score_distribution_snapshots;
CREATE POLICY sds_authenticated_read ON score_distribution_snapshots
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 6. score_shadow_results — HIGH: {public} ALL true/true
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS ssr_service_all ON score_shadow_results;
CREATE POLICY ssr_service_all ON score_shadow_results
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Add read access for authenticated (was implicitly denied before
-- since only the ALL policy existed for {public})
CREATE POLICY ssr_authenticated_read ON score_shadow_results
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 7. data_conflicts — MEDIUM: {public} ALL with fragile
--    current_setting('role') check
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS allow_service_conflicts ON data_conflicts;
CREATE POLICY conflicts_service_all ON data_conflicts
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Add authenticated read access
CREATE POLICY conflicts_auth_read ON data_conflicts
  FOR SELECT TO authenticated
  USING (true);

-- ═══════════════════════════════════════════════════════════════
-- 8. product_change_log — MEDIUM: {public} ALL with fragile
--    current_setting('role') check (trigger-driven, postgres only)
-- ═══════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS allow_service_change_log ON product_change_log;
CREATE POLICY change_log_postgres_write ON product_change_log
  FOR ALL TO postgres
  USING (true) WITH CHECK (true);

CREATE POLICY change_log_auth_read ON product_change_log
  FOR SELECT TO authenticated
  USING (true);

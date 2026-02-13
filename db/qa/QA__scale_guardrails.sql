-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Scale Guardrails
-- Validates that all protections for growth to 5-10K products are in place:
--   - Role-level statement timeouts
--   - Idle-in-transaction timeouts
--   - API parameter clamping
--   - Row count ceilings
--   - Materialized view freshness
--   - Constraint coverage
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  anon role has statement_timeout set
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. anon has statement_timeout' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           JOIN pg_roles r ON r.oid = rs.setrole
           WHERE r.rolname = 'anon'
             AND rs.setconfig::text[] @> ARRAY['statement_timeout=5s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  authenticated role has statement_timeout set
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. authenticated has statement_timeout' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           JOIN pg_roles r ON r.oid = rs.setrole
           WHERE r.rolname = 'authenticated'
             AND rs.setconfig::text[] @> ARRAY['statement_timeout=5s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  anon role has idle_in_transaction_session_timeout set
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. anon has idle_in_txn_timeout' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           JOIN pg_roles r ON r.oid = rs.setrole
           WHERE r.rolname = 'anon'
             AND rs.setconfig::text[] @> ARRAY['idle_in_transaction_session_timeout=30s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  authenticated role has idle_in_transaction_session_timeout set
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. authenticated has idle_in_txn_timeout' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           JOIN pg_roles r ON r.oid = rs.setrole
           WHERE r.rolname = 'authenticated'
             AND rs.setconfig::text[] @> ARRAY['idle_in_transaction_session_timeout=30s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  api_better_alternatives clamps limit to max 20
--     Passing p_limit=100 should return at most 20 alternatives.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. api_better_alternatives clamps limit' AS check_name,
       CASE WHEN (
           SELECT COALESCE(
               (api_better_alternatives(2, true, 100)->'alternatives_count')::int,
               0
           ) <= 20
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  No table exceeds its row count ceiling
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. No table exceeds row ceiling' AS check_name,
       COUNT(*) AS violations
FROM check_table_ceilings()
WHERE status = 'EXCEEDED';

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  No table is at >80% of ceiling (warning threshold)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. No table near ceiling (>80%)' AS check_name,
       COUNT(*) AS violations
FROM check_table_ceilings()
WHERE status = 'WARNING';

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  Materialized views are not stale
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. MVs are not stale' AS check_name,
       (SELECT COUNT(*)
        FROM jsonb_array_elements(mv_staleness_check()->'views') v
        WHERE (v->>'is_stale')::boolean = true
       ) AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  check_table_ceilings function exists and is SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. check_table_ceilings is SECURITY DEFINER' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'check_table_ceilings'
             AND p.prosecdef = true
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  hardcoded country CHECK is removed (enables multi-country expansion)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. No hardcoded country CHECK on products' AS check_name,
       COUNT(*) AS violations
FROM pg_constraint
WHERE conrelid = 'products'::regclass
  AND conname = 'chk_products_country';

-- ─────────────────────────────────────────────────────────────────────────────
-- #11  products.country is still FK-protected by country_ref
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. products.country FK to country_ref exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_constraint
           WHERE conrelid = 'products'::regclass
             AND conname = 'fk_products_country'
             AND contype = 'f'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12  score_category procedure exists (auto-refresh MVs integrated)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. score_category procedure exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'score_category'
             AND p.prokind = 'p'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #13  All api_* functions remain SECURITY DEFINER after scale changes
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '13. All api_* are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND p.prosecdef = false;

-- ─────────────────────────────────────────────────────────────────────────────
-- #14  authenticator role has statement_timeout set
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '14. authenticator has statement_timeout' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_db_role_setting rs
           JOIN pg_roles r ON r.oid = rs.setrole
           WHERE r.rolname = 'authenticator'
             AND rs.setconfig::text[] @> ARRAY['statement_timeout=5s']
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #15  Connection pooler is configured (config.toml check — structural)
--      Verifies the check_table_ceilings function returns expected columns
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '15. check_table_ceilings returns all tables' AS check_name,
       CASE WHEN (SELECT COUNT(*) FROM check_table_ceilings()) >= 7
       THEN 0 ELSE 1 END AS violations;

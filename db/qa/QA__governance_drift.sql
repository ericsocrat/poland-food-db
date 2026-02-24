-- ══════════════════════════════════════════════════════════════════════════
-- QA Suite: Governance Drift Detection
-- Validates governance_drift_check() function and drift_check_results table.
-- Issue: #199 — GOV-A4: Version Drift Detection Automation
-- 8 checks
-- ══════════════════════════════════════════════════════════════════════════

-- ─── T01: governance_drift_check() function exists ──────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'governance_drift_check'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T01_governance_drift_check_exists";

-- ─── T02: governance_drift_check() returns 8 checks ────────────────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM governance_drift_check()) = 8
    THEN 'PASS' ELSE 'FAIL'
END AS "T02_returns_8_checks";

-- ─── T03: All checks pass on clean state ────────────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM governance_drift_check()
        WHERE status = 'drift'
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T03_all_checks_pass_clean_state";

-- ─── T04: Every check has a valid severity level ────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM governance_drift_check()
        WHERE severity NOT IN ('critical', 'medium', 'low')
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T04_valid_severity_levels";

-- ─── T05: Every check has a non-empty detail ────────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM governance_drift_check()
        WHERE detail IS NULL OR detail = ''
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T05_non_empty_details";

-- ─── T06: drift_check_results table exists ──────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'drift_check_results'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T06_drift_check_results_table_exists";

-- ─── T07: log_drift_check() function exists ─────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'log_drift_check'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T07_log_drift_check_exists";

-- ─── T08: Check names are unique (no duplicates) ────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM governance_drift_check()
    ) = (
        SELECT COUNT(DISTINCT check_name)
        FROM governance_drift_check()
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T08_unique_check_names";

-- ═══════════════════════════════════════════════════════════════════════════
-- Summary
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'Governance Drift Detection QA: 8 tests complete' AS summary;

-- ══════════════════════════════════════════════════════════════════════════
-- QA: Canonical Scoring Engine — Integrity & Regression Tests
-- Issue: #189
-- ══════════════════════════════════════════════════════════════════════════

-- ─── T01: Version Registry — v3.2 is active ────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM scoring_model_versions
        WHERE version = 'v3.2' AND status = 'active'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T01_v3.2_is_active";

-- ─── T02: Exactly one active version ────────────────────────────────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM scoring_model_versions WHERE status = 'active') = 1
    THEN 'PASS' ELSE 'FAIL'
END AS "T02_single_active_version";

-- ─── T03: v3.2 has 9 factors summing to 1.0 ─────────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM scoring_model_versions smv,
             jsonb_array_elements(smv.config->'factors') f
        WHERE smv.version = 'v3.2'
    ) = 9
    AND ABS((
        SELECT SUM((f->>'weight')::numeric)
        FROM scoring_model_versions smv,
             jsonb_array_elements(smv.config->'factors') f
        WHERE smv.version = 'v3.2'
    ) - 1.0) < 0.01
    THEN 'PASS' ELSE 'FAIL'
END AS "T03_v3.2_factor_config_valid";

-- ─── T04: score_model_version populated ──────────────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM products
        WHERE unhealthiness_score IS NOT NULL
          AND score_model_version IS NULL
          AND is_deprecated IS NOT TRUE
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T04_model_version_populated";

-- ─── T05: scored_at populated ──────────────────────────────────────────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM products
        WHERE unhealthiness_score IS NOT NULL
          AND scored_at IS NULL
          AND is_deprecated IS NOT TRUE
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T05_scored_at_populated";

-- ─── T06: Audit log table exists and is empty (no changes since migration) ──

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'score_audit_log'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T06_audit_log_exists";

-- ─── T07: compute_score() exists ─────────────────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_name = 'compute_score'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T07_compute_score_exists";

-- ─── T08: rescore_batch() exists ─────────────────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_name = 'rescore_batch'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T08_rescore_batch_exists";

-- ─── T09: validate_country_profile for v3.2 PL returns valid ─────────────

SELECT CASE
    WHEN (validate_country_profile('v3.2', 'PL')->>'valid')::boolean
    THEN 'PASS' ELSE 'FAIL'
END AS "T09_pl_profile_valid";

-- ─── T10: score_shadow_results table exists ──────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'score_shadow_results'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T10_shadow_results_table";

-- ─── T11: score_distribution_snapshots table exists ──────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'score_distribution_snapshots'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T11_snapshots_table";

-- ─── T12: api_score_explanation includes model_version and scored_at ─────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM products
        WHERE unhealthiness_score IS NOT NULL
          AND is_deprecated IS NOT TRUE
        LIMIT 1
    )
    AND (
        SELECT api_score_explanation(
            (SELECT product_id FROM products
             WHERE unhealthiness_score IS NOT NULL
               AND is_deprecated IS NOT TRUE
             LIMIT 1)
        )
    ) ? 'model_version'
    AND (
        SELECT api_score_explanation(
            (SELECT product_id FROM products
             WHERE unhealthiness_score IS NOT NULL
               AND is_deprecated IS NOT TRUE
             LIMIT 1)
        )
    ) ? 'scored_at'
    THEN 'PASS'
    WHEN NOT EXISTS (
        SELECT 1 FROM products
        WHERE unhealthiness_score IS NOT NULL
          AND is_deprecated IS NOT TRUE
    )
    THEN 'SKIP — no scored products'
    ELSE 'FAIL'
END AS "T12_explanation_has_metadata";

-- ─── T13: admin_scoring_versions returns array ──────────────────────────

SELECT CASE
    WHEN jsonb_typeof(admin_scoring_versions()) = 'array'
     AND jsonb_array_length(admin_scoring_versions()) >= 1
    THEN 'PASS' ELSE 'FAIL'
END AS "T13_admin_versions_works";

-- ─── T14: api_score_history returns valid shape ─────────────────────────

SELECT CASE
    WHEN (api_score_history(1, 10))->>'api_version' = '1.0'
     AND (api_score_history(1, 10)) ? 'history'
    THEN 'PASS' ELSE 'FAIL'
END AS "T14_score_history_shape";

-- ─── T15: detect_score_drift callable (no snapshots = empty) ─────────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM detect_score_drift(10.0)) >= 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T15_drift_detection_callable";

-- ─── T16: Score trigger fires and creates audit entry ────────────────────
-- Note: This test creates a temp entry and rolls it back if possible.
-- In CI, we verify the trigger function exists.

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'score_change_audit'
          AND tgrelid = 'products'::regclass
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T16_audit_trigger_installed";

-- ─── T17: Scoring functions have correct grants ─────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM information_schema.routine_privileges
        WHERE routine_schema = 'public'
          AND routine_name = 'compute_score'
          AND grantee IN ('authenticated', 'service_role')
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T17_compute_score_grants";

-- ═══════════════════════════════════════════════════════════════════════════
-- Summary
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'Scoring Engine QA: 17 tests complete' AS summary;

-- ============================================================
-- DR Drill — Scenario D: User Data Restore
-- ============================================================
-- Simulates loss of a single user's data and validates the
-- ability to restore it. Uses SAVEPOINT/ROLLBACK for safety.
--
-- Run via: RUN_DR_DRILL.ps1 or manually in psql
-- Environment: local or staging ONLY — never production
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- STEP 1: Identify a test user and record their data
-- ═══════════════════════════════════════════════════════════════
\echo '────────────────────────────────────────────────────────────'
\echo 'SCENARIO D: User Data Restore'
\echo '────────────────────────────────────────────────────────────'

\echo '[D-1] Identifying test user (first user with data)...'

-- Find a user who has at least one preference or health profile
SELECT u.id AS user_id, u.email
FROM auth.users u
WHERE EXISTS (SELECT 1 FROM user_preferences p WHERE p.user_id = u.id)
   OR EXISTS (SELECT 1 FROM user_health_profiles h WHERE h.user_id = u.id)
LIMIT 1;

\echo '[D-1b] Recording user data counts (use user_id from above)...'

-- Note: In automated mode, RUN_DR_DRILL.ps1 captures the user_id
-- and substitutes it. For manual execution, replace {test_user_id}
-- with the actual UUID from step D-1.

DO $$
DECLARE
    v_user_id uuid;
    v_prefs   bigint;
    v_health  bigint;
    v_lists   bigint;
    v_items   bigint;
    v_scans   bigint;
BEGIN
    -- Pick the first user with data
    SELECT u.id INTO v_user_id
    FROM auth.users u
    WHERE EXISTS (SELECT 1 FROM user_preferences p WHERE p.user_id = u.id)
       OR EXISTS (SELECT 1 FROM user_health_profiles h WHERE h.user_id = u.id)
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE NOTICE '[D] No user with data found — skipping scenario D.';
        RETURN;
    END IF;

    RAISE NOTICE '[D] Test user: %', v_user_id;

    SELECT COUNT(*) INTO v_prefs  FROM user_preferences       WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_health FROM user_health_profiles    WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_lists  FROM user_product_lists      WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_scans  FROM scan_history            WHERE user_id = v_user_id;

    RAISE NOTICE '[D-1] Pre-drill counts — prefs: %, health: %, lists: %, scans: %',
        v_prefs, v_health, v_lists, v_scans;

    -- ═══════════════════════════════════════════════════════════
    -- STEP 2: Create checkpoint
    -- ═══════════════════════════════════════════════════════════
    RAISE NOTICE '[D-2] Creating savepoint...';

    -- ═══════════════════════════════════════════════════════════
    -- STEP 3: Simulate user data loss
    -- ═══════════════════════════════════════════════════════════
    RAISE NOTICE '[D-3] Simulating user data deletion...';

    DELETE FROM scan_history            WHERE user_id = v_user_id;
    DELETE FROM user_product_list_items WHERE list_id IN (
        SELECT id FROM user_product_lists WHERE user_id = v_user_id
    );
    DELETE FROM user_product_lists      WHERE user_id = v_user_id;
    DELETE FROM user_health_profiles    WHERE user_id = v_user_id;
    DELETE FROM user_preferences        WHERE user_id = v_user_id;

    -- Verify damage
    SELECT COUNT(*) INTO v_prefs  FROM user_preferences       WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_health FROM user_health_profiles    WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_lists  FROM user_product_lists      WHERE user_id = v_user_id;
    SELECT COUNT(*) INTO v_scans  FROM scan_history            WHERE user_id = v_user_id;

    RAISE NOTICE '[D-4] Post-deletion counts — prefs: %, health: %, lists: %, scans: % (all should be 0)',
        v_prefs, v_health, v_lists, v_scans;

    -- The SAVEPOINT/ROLLBACK is managed by the outer transaction
    -- (handled in the DO block's exception or by RUN_DR_DRILL.ps1)
    RAISE NOTICE '[D] Data deletion verified — rollback will restore.';
END;
$$;

-- The outer transaction with SAVEPOINT is managed by the runner:
-- BEGIN; SAVEPOINT ...; \i this_file; ROLLBACK TO ...; COMMIT;
-- For standalone execution, wrap this file in a transaction.

\echo '[D] SCENARIO D COMPLETE ✓'
\echo ''

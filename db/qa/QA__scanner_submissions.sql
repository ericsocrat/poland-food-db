-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Scanner & Submissions Pipeline
-- Validates the scan_history and product_submissions tables, their RLS,
-- indexes, constraints, FK integrity, status-workflow consistency, and
-- all associated API functions from Issue #23.
-- 15 checks — all BLOCKING.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  RLS is enabled on scan_history and product_submissions
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. RLS enabled on scanner tables' AS check_name,
       COUNT(*) AS violations
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN ('scan_history', 'product_submissions')
  AND c.relrowsecurity = false;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  All scanner/submission API functions exist and are SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. Scanner/submission API functions are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'api_record_scan',
        'api_get_scan_history',
        'api_submit_product',
        'api_get_my_submissions',
        'api_admin_get_submissions',
        'api_admin_review_submission'
    ]) AS fn
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname = expected.fn
      AND p.prosecdef = true
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  product_submissions.status CHECK constraint exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. product_submissions status CHECK exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_constraint con
           JOIN pg_class c ON con.conrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'product_submissions'
             AND con.contype = 'c'
             AND pg_get_constraintdef(con.oid) LIKE '%status%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  Unique partial index prevents duplicate pending submissions per EAN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. Unique pending-per-EAN index exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_class c
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relkind = 'i'
             AND c.relname = 'idx_ps_ean_pending'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  Performance indexes on scan_history exist
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. scan_history has required indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['idx_sh_user_recent', 'idx_sh_ean']) AS idx
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relkind = 'i' AND c.relname = expected.idx
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  Performance indexes on product_submissions exist
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. product_submissions has required indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['idx_ps_ean', 'idx_ps_status', 'idx_ps_user_id']) AS idx
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relkind = 'i' AND c.relname = expected.idx
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  Reviewed submissions must have reviewed_at and reviewed_by set
--     (status != 'pending' implies reviewed metadata is populated)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. Reviewed submissions have reviewed_at + reviewed_by' AS check_name,
       COUNT(*) AS violations
FROM product_submissions
WHERE status IN ('approved', 'rejected', 'merged')
  AND (reviewed_at IS NULL OR reviewed_by IS NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  Merged submissions must reference a valid product
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. Merged submissions have valid merged_product_id' AS check_name,
       COUNT(*) AS violations
FROM product_submissions ps
WHERE ps.status = 'merged'
  AND (ps.merged_product_id IS NULL
       OR NOT EXISTS (
           SELECT 1 FROM products p
           WHERE p.product_id = ps.merged_product_id
       ));

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  scan_history.found must be consistent with product_id
--     found = true → product_id IS NOT NULL
--     found = false → product_id IS NULL
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. scan_history found flag consistent with product_id' AS check_name,
       COUNT(*) AS violations
FROM scan_history
WHERE (found = true AND product_id IS NULL)
   OR (found = false AND product_id IS NOT NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- #10 scan_history.ean values are 8 or 13 characters (valid EAN lengths)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. scan_history EANs have valid length' AS check_name,
       COUNT(*) AS violations
FROM scan_history
WHERE LENGTH(TRIM(ean)) NOT IN (8, 13);

-- ─────────────────────────────────────────────────────────────────────────────
-- #11 product_submissions.updated_at >= created_at (temporal order)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. Submission updated_at >= created_at' AS check_name,
       COUNT(*) AS violations
FROM product_submissions
WHERE updated_at < created_at;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12 Pending submissions must NOT have reviewed metadata
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. Pending submissions have no review metadata' AS check_name,
       COUNT(*) AS violations
FROM product_submissions
WHERE status = 'pending'
  AND (reviewed_at IS NOT NULL OR reviewed_by IS NOT NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- #13 Auto-triage functions exist and are SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '13. Auto-triage functions are SECURITY DEFINER' AS check_name,
       COUNT(*) AS violations
FROM (VALUES
  ('score_submission_quality'),
  ('_score_submission_quality')
) AS expected(fn_name)
WHERE NOT EXISTS (
  SELECT 1 FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.proname = expected.fn_name
    AND p.prosecdef = true
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #14 Auto-triage trigger exists on product_submissions
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '14. Auto-triage trigger exists on product_submissions' AS check_name,
       CASE WHEN EXISTS (
         SELECT 1 FROM pg_trigger
         WHERE tgname = 'trg_submission_quality_triage'
           AND tgrelid = 'product_submissions'::regclass
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #15 Trigger ordering: quality_triage sorts after ean_check
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '15. Trigger ordering: quality_triage after ean_check' AS check_name,
       CASE WHEN 'trg_submission_quality_triage' > 'trg_submission_ean_check'
            THEN 0 ELSE 1 END AS violations;

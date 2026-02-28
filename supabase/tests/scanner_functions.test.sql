-- ─── pgTAP: Scanner function tests ──────────────────────────────────────────
-- Tests api_record_scan and api_get_scan_history against the real database.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- These tests would have caught the nutri_score vs nutri_score_label bug.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(59);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-test-cat', 'pgtap-test-cat', 'pgTAP Test', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-test-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label
) VALUES (
  999999, '5901234123457', 'pgTAP Test Product', 'Test Brand',
  'pgtap-test-cat', 'XX', 42, 'B'
) ON CONFLICT (product_id) DO NOTHING;

-- Second product with EAN-8 format
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label
) VALUES (
  999998, '59012341', 'pgTAP EAN8 Product', 'Test Brand',
  'pgtap-test-cat', 'XX', 30, 'A'
) ON CONFLICT (product_id) DO NOTHING;

-- ─── 1. api_record_scan — valid EAN-13 returns found=true ───────────────────

SELECT lives_ok(
  $$SELECT public.api_record_scan('5901234123457')$$,
  'api_record_scan does not throw for a known EAN-13'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'found',
  'true',
  'api_record_scan returns found=true for a known EAN-13'
);

-- ─── 2. Response contains ALL required keys (found=true branch) ─────────────

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'api_version',
  'found response contains api_version key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'found',
  'found response contains found key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'product_id',
  'found response contains product_id key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'product_name',
  'found response contains product_name key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'brand',
  'found response contains brand key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'category',
  'found response contains category key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'unhealthiness_score',
  'found response contains unhealthiness_score key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'nutri_score',
  'found response contains nutri_score key (mapped from nutri_score_label)'
);

-- ─── 3. Returned values match fixture data ──────────────────────────────────

SELECT is(
  ((public.api_record_scan('5901234123457'))->>'product_id')::bigint,
  999999::bigint,
  'returned product_id matches the expected product'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'product_name',
  'pgTAP Test Product',
  'returned product_name matches fixture'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'brand',
  'Test Brand',
  'returned brand matches fixture'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'category',
  'pgtap-test-cat',
  'returned category matches fixture'
);

SELECT is(
  ((public.api_record_scan('5901234123457'))->>'unhealthiness_score')::int,
  42,
  'returned unhealthiness_score matches fixture value'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'nutri_score',
  'B',
  'returned nutri_score matches fixture nutri_score_label'
);

-- ─── 4. EAN-8 support ──────────────────────────────────────────────────────

SELECT is(
  (public.api_record_scan('59012341'))->>'found',
  'true',
  'api_record_scan finds product by EAN-8'
);

-- ─── 5. Unknown EAN returns found=false with correct keys ───────────────────

SELECT is(
  (public.api_record_scan('0000000000000'))->>'found',
  'false',
  'api_record_scan returns found=false for unknown EAN'
);

SELECT ok(
  (public.api_record_scan('0000000000000')) ? 'ean',
  'not-found response contains ean key'
);

SELECT ok(
  (public.api_record_scan('0000000000000')) ? 'has_pending_submission',
  'not-found response contains has_pending_submission key'
);

-- ─── 6. Invalid EAN returns error ───────────────────────────────────────────

SELECT ok(
  (public.api_record_scan('123')) ? 'error',
  'api_record_scan returns error for invalid EAN (too short)'
);

SELECT ok(
  (public.api_record_scan(NULL)) ? 'error',
  'api_record_scan returns error for NULL EAN'
);

SELECT ok(
  (public.api_record_scan('')) ? 'error',
  'api_record_scan returns error for empty string EAN'
);

SELECT ok(
  (public.api_record_scan('12345')) ? 'error',
  'api_record_scan returns error for 5-digit EAN (neither 8 nor 13)'
);

-- ─── 7. Whitespace trimming ────────────────────────────────────────────────

SELECT is(
  (public.api_record_scan('  5901234123457  '))->>'found',
  'true',
  'api_record_scan trims leading/trailing whitespace from EAN'
);

-- ─── 8. api_get_scan_history — requires auth ───────────────────────────────
-- Without auth.uid() it should return an error, not crash.

SELECT lives_ok(
  $$SELECT public.api_get_scan_history()$$,
  'api_get_scan_history does not throw without auth'
);

SELECT ok(
  (public.api_get_scan_history()) ? 'error',
  'api_get_scan_history returns error without auth context'
);

SELECT is(
  (public.api_get_scan_history())->>'api_version',
  '1.0',
  'api_get_scan_history error includes api_version'
);

-- ─── 9. is_valid_ean — pure function tests ──────────────────────────────────

SELECT is(
  public.is_valid_ean('5901234123457'),
  true,
  'is_valid_ean returns true for valid EAN-13'
);

SELECT is(
  public.is_valid_ean('96385074'),
  true,
  'is_valid_ean returns true for valid EAN-8'
);

SELECT is(
  public.is_valid_ean('5901234123456'),
  false,
  'is_valid_ean returns false for bad checksum EAN-13'
);

SELECT is(
  public.is_valid_ean('abcdefghijklm'),
  false,
  'is_valid_ean returns false for non-numeric input'
);

SELECT is(
  public.is_valid_ean('12345'),
  false,
  'is_valid_ean returns false for wrong length (5 digits)'
);

SELECT is(
  public.is_valid_ean(''),
  false,
  'is_valid_ean returns false for empty string'
);

SELECT is(
  public.is_valid_ean(NULL),
  NULL::boolean,
  'is_valid_ean returns NULL for NULL input (STRICT)'
);

-- ─── 10. Trigger: auto-reject invalid EAN on product_submissions ────────────

-- Valid EAN → stays pending
INSERT INTO public.product_submissions (ean, product_name, status)
VALUES ('4006381333931', 'pgTAP Trigger Valid EAN', 'pending');

SELECT is(
  (SELECT status FROM public.product_submissions WHERE product_name = 'pgTAP Trigger Valid EAN'),
  'pending',
  'Submission with valid EAN-13 stays pending'
);

-- Invalid EAN → auto-rejected by trigger
INSERT INTO public.product_submissions (ean, product_name, status)
VALUES ('4006381333932', 'pgTAP Trigger Invalid EAN', 'pending');

SELECT is(
  (SELECT status FROM public.product_submissions WHERE product_name = 'pgTAP Trigger Invalid EAN'),
  'rejected',
  'Submission with invalid EAN is auto-rejected by trigger'
);

SELECT ok(
  (SELECT review_notes FROM public.product_submissions WHERE product_name = 'pgTAP Trigger Invalid EAN') LIKE 'Auto-rejected%',
  'Auto-rejected submission has review_notes explaining reason'
);

-- ─── 11. Rate limiting functions ───────────────────────────────────────────────

-- check_submission_rate_limit returns allowed=true for a random UUID (no submissions)
SELECT is(
  (check_submission_rate_limit('00000000-0000-0000-0000-000000000099'::uuid))->>'allowed',
  'true',
  'check_submission_rate_limit returns allowed=true for user with 0 submissions'
);

-- check_scan_rate_limit returns allowed=true for a random UUID (no scans)
SELECT is(
  (check_scan_rate_limit('00000000-0000-0000-0000-000000000099'::uuid))->>'allowed',
  'true',
  'check_scan_rate_limit returns allowed=true for user with 0 scans'
);

-- Submission rate limit returns all expected JSONB keys
SELECT ok(
  (check_submission_rate_limit('00000000-0000-0000-0000-000000000099'::uuid)) ?& ARRAY['allowed','current_count','max_allowed','window','retry_after_seconds'],
  'check_submission_rate_limit response has all required keys'
);

-- Scan rate limit returns all expected JSONB keys
SELECT ok(
  (check_scan_rate_limit('00000000-0000-0000-0000-000000000099'::uuid)) ?& ARRAY['allowed','current_count','max_allowed','window','retry_after_seconds'],
  'check_scan_rate_limit response has all required keys'
);

-- Submission rate limit max_allowed = 10
SELECT is(
  ((check_submission_rate_limit('00000000-0000-0000-0000-000000000099'::uuid))->>'max_allowed')::int,
  10,
  'check_submission_rate_limit max_allowed is 10'
);

-- Scan rate limit max_allowed = 100
SELECT is(
  ((check_scan_rate_limit('00000000-0000-0000-0000-000000000099'::uuid))->>'max_allowed')::int,
  100,
  'check_scan_rate_limit max_allowed is 100'
);

-- retry_after_seconds is 0 when not rate limited
SELECT is(
  ((check_submission_rate_limit('00000000-0000-0000-0000-000000000099'::uuid))->>'retry_after_seconds')::int,
  0,
  'retry_after_seconds is 0 when not rate limited'
);


-- ─── 12. Auto-triage quality scoring ────────────────────────────────────────

-- _score_submission_quality returns JSONB with all expected keys
SELECT ok(
  _score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'Test Brand', 'Test Product Name', NULL
  ) ?& ARRAY['quality_score', 'signals', 'recommended_action'],
  '_score_submission_quality returns all expected JSONB keys'
);

-- Normal submission (no account in auth.users, no prior submissions) gets baseline score = 50
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'Test Brand', 'Test Product Name', NULL
  ))->>'quality_score')::int,
  50,
  '_score_submission_quality returns 50 for normal clean submission'
);

-- Normal submission recommended_action is manual_review
SELECT is(
  (_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'Test Brand', 'Test Product Name', NULL
  ))->>'recommended_action',
  'manual_review',
  '_score_submission_quality recommends manual_review for normal submission'
);

-- Submission with photo gets +10 bonus (score = 60)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'Test Brand', 'Test Product Name', 'https://example.com/photo.jpg'
  ))->>'quality_score')::int,
  60,
  '_score_submission_quality gives +10 bonus for photo'
);

-- Suspicious brand (too short) gets -25 penalty (score = 25)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'X', 'Test Product Name', NULL
  ))->>'quality_score')::int,
  25,
  '_score_submission_quality penalizes suspicious brand name'
);

-- Suspicious brand + suspicious product name → auto_reject (score = 0)
SELECT is(
  (_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', 'X', 'ab', NULL
  ))->>'recommended_action',
  'auto_reject',
  '_score_submission_quality auto-rejects low quality submissions'
);

-- score_submission_quality returns error for non-existent submission
SELECT is(
  score_submission_quality('00000000-0000-0000-0000-000000000099'::uuid)->>'error',
  'submission_not_found',
  'score_submission_quality returns error for non-existent submission'
);

-- Auto-triage trigger exists on product_submissions
SELECT has_trigger(
  'product_submissions',
  'trg_submission_quality_triage',
  'Auto-triage trigger exists on product_submissions'
);


-- ─── 13. User trust scoring (#471) ──────────────────────────────────────────

-- Trust score adjustment trigger exists
SELECT has_trigger(
  'product_submissions',
  'trg_trust_score_adjustment',
  'Trust score adjustment trigger exists on product_submissions'
);

-- Trust score adjustment function exists
SELECT has_function(
  'trig_adjust_trust_score',
  'trig_adjust_trust_score function exists'
);

-- Insert trust record for test user (bypass FK to auth.users)
SET LOCAL session_replication_role = 'replica';
INSERT INTO user_trust_scores (user_id, trust_score)
VALUES ('00000000-0000-0000-0000-000000000099'::uuid, 85)
ON CONFLICT (user_id) DO UPDATE SET trust_score = 85;
SET LOCAL session_replication_role = 'DEFAULT';

-- High trust (85) gives +15 bonus → score = 65
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    NULL, 'Test Brand', 'Test Product Name', NULL
  ))->>'quality_score')::int,
  65,
  '_score_submission_quality gives +15 for trusted contributor (trust=85)'
);

-- Low trust (15) gives -30 penalty → score = 20
SET LOCAL session_replication_role = 'replica';
UPDATE user_trust_scores SET trust_score = 15
WHERE user_id = '00000000-0000-0000-0000-000000000099'::uuid;
SET LOCAL session_replication_role = 'DEFAULT';

SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    NULL, 'Test Brand', 'Test Product Name', NULL
  ))->>'quality_score')::int,
  20,
  '_score_submission_quality gives -30 for low trust (trust=15)'
);

-- Below-average trust (35) gives -15 penalty → score = 35
SET LOCAL session_replication_role = 'replica';
UPDATE user_trust_scores SET trust_score = 35
WHERE user_id = '00000000-0000-0000-0000-000000000099'::uuid;
SET LOCAL session_replication_role = 'DEFAULT';

SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    NULL, 'Test Brand', 'Test Product Name', NULL
  ))->>'quality_score')::int,
  35,
  '_score_submission_quality gives -15 for below-avg trust (trust=35)'
);

-- Trust signal appears in signals array
SET LOCAL session_replication_role = 'replica';
UPDATE user_trust_scores SET trust_score = 10
WHERE user_id = '00000000-0000-0000-0000-000000000099'::uuid;
SET LOCAL session_replication_role = 'DEFAULT';

SELECT ok(
  (_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    NULL, 'Test Brand', 'Test Product Name', NULL
  ))->'signals' @> '[{"signal": "low_trust"}]'::jsonb,
  '_score_submission_quality includes low_trust signal'
);

-- Clean up trust record
DELETE FROM user_trust_scores
WHERE user_id = '00000000-0000-0000-0000-000000000099'::uuid;


SELECT * FROM finish();
ROLLBACK;

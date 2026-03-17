-- ─── pgTAP: Scanner function tests ──────────────────────────────────────────
-- Tests api_record_scan and api_get_scan_history against the real database.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- These tests would have caught the nutri_score vs nutri_score_label bug.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(107);

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

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'scan_country',
  'found response contains scan_country key (#923)'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'product_country',
  'found response contains product_country key (#923)'
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

SELECT ok(
  (public.api_record_scan('0000000000000')) ? 'scan_country',
  'not-found response contains scan_country key (#923)'
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

-- ─── 6b. Explicit scan_country parameter (#923) ───────────────────────────

SELECT is(
  (public.api_record_scan('5901234123457', 'PL'))->>'scan_country',
  'PL',
  'explicit p_scan_country=PL is returned in response (#923)'
);

SELECT is(
  (public.api_record_scan('5901234123457', 'PL'))->>'product_country',
  'XX',
  'product_country reflects fixture product country XX (#923)'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'scan_country',
  NULL,
  'scan_country is NULL when no param and no auth (#923)'
);

-- ─── 7 (cont). Whitespace trimming ────────────────────────────────────────

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

-- Temporarily disable trust trigger so submission INSERTs with NULL user_id work
-- (EAN validation + quality triage triggers remain active)
ALTER TABLE public.product_submissions DISABLE TRIGGER trg_trust_score_adjustment;

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

ALTER TABLE public.product_submissions ENABLE TRIGGER trg_trust_score_adjustment;

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

-- Admin dashboard functions (#474)
SELECT has_function(
  'api_admin_batch_reject_user',
  'api_admin_batch_reject_user function exists'
);

SELECT has_function(
  'api_admin_submission_velocity',
  'api_admin_submission_velocity function exists'
);

-- api_admin_get_submissions returns trust enrichment keys
SELECT lives_ok(
  $$SELECT public.api_admin_get_submissions('all', 1, 5)$$,
  'api_admin_get_submissions lives_ok with trust enrichment'
);

-- api_admin_get_submissions response envelope contains country_filter key (#925)
SELECT ok(
  public.api_admin_get_submissions('all', 1, 5) ? 'country_filter',
  'api_admin_get_submissions response has country_filter key'
);

-- api_admin_get_submissions accepts p_country filter (#925)
SELECT lives_ok(
  $$SELECT public.api_admin_get_submissions('all', 1, 5, 'PL')$$,
  'api_admin_get_submissions lives_ok with country filter'
);

-- api_admin_submission_velocity returns expected keys
SELECT ok(
  public.api_admin_submission_velocity() ?& ARRAY['api_version', 'last_24h', 'last_7d', 'pending_count', 'status_breakdown', 'top_submitters'],
  'api_admin_submission_velocity returns all expected keys'
);

-- api_admin_batch_reject_user returns auth error for anon
SELECT is(
  (public.api_admin_batch_reject_user('00000000-0000-0000-0000-000000000099'::uuid))->>'error',
  'authentication_required',
  'api_admin_batch_reject_user requires authentication'
);


-- ─── 14. User trust scoring (#471) ──────────────────────────────────────────

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
SET LOCAL session_replication_role = 'origin';

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
SET LOCAL session_replication_role = 'origin';

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
SET LOCAL session_replication_role = 'origin';

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
SET LOCAL session_replication_role = 'origin';

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


-- ─── 15. Region-preferred matching + is_cross_country (#926) ────────────────

-- Response contains is_cross_country key
SELECT ok(
  (public.api_record_scan('5901234123457', 'PL')) ? 'is_cross_country',
  'found response contains is_cross_country key (#926)'
);

-- is_cross_country = true when scan_country differs from product_country
SELECT is(
  (public.api_record_scan('5901234123457', 'PL'))->>'is_cross_country',
  'true',
  'is_cross_country=true when scan_country=PL but product_country=XX (#926)'
);

-- is_cross_country = false when scan_country matches product_country
SELECT is(
  (public.api_record_scan('5901234123457', 'XX'))->>'is_cross_country',
  'false',
  'is_cross_country=false when scan_country matches product_country (#926)'
);

-- is_cross_country = false when no scan_country (NULL)
SELECT is(
  (public.api_record_scan('5901234123457'))->>'is_cross_country',
  'false',
  'is_cross_country=false when scan_country is NULL (#926)'
);

-- Region-preferred matching: insert PL + DE products with same EAN
-- EAN 4015000969604 is unused; PL product gets lower product_id
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label
) VALUES (
  999990, '4015000969604', 'pgTAP Dual-EAN PL', 'Dual Brand',
  'pgtap-test-cat', 'PL', 35, 'C'
) ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label
) VALUES (
  999991, '4015000969604', 'pgTAP Dual-EAN DE', 'Dual Brand',
  'pgtap-test-cat', 'DE', 30, 'B'
) ON CONFLICT (product_id) DO NOTHING;

-- DE user gets DE product (region-preferred)
SELECT is(
  ((public.api_record_scan('4015000969604', 'DE'))->>'product_id')::bigint,
  999991::bigint,
  'DE user gets DE product when same EAN exists in PL + DE (#926)'
);

-- PL user gets PL product (region-preferred)
SELECT is(
  ((public.api_record_scan('4015000969604', 'PL'))->>'product_id')::bigint,
  999990::bigint,
  'PL user gets PL product when same EAN exists in PL + DE (#926)'
);

-- Cross-country fallback: user in XX scans PL-only EAN
SELECT is(
  (public.api_record_scan('5901234123457', 'PL'))->>'found',
  'true',
  'cross-country fallback: PL user still finds XX-only product (#926)'
);

-- Deprecated products excluded from scan lookup
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, is_deprecated, deprecated_reason
) VALUES (
  999989, '4015000969611', 'pgTAP Deprecated Product', 'Dead Brand',
  'pgtap-test-cat', 'XX', 50, 'D', true, 'test-deprecated'
) ON CONFLICT (product_id) DO NOTHING;

SELECT is(
  (public.api_record_scan('4015000969611'))->>'found',
  'false',
  'deprecated product excluded from scan lookup (#926)'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- gs1_country_hint — GS1 prefix to country hint utility (#928)
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. PL prefix (590) → Poland
SELECT is(
  (public.gs1_country_hint('5901234123457'))->>'code',
  'PL',
  'gs1_country_hint: 590 prefix returns PL (#928)'
);

-- 2. DE prefix (400–440 range) → Germany
SELECT is(
  (public.gs1_country_hint('4000000000000'))->>'code',
  'DE',
  'gs1_country_hint: 400 prefix returns DE (#928)'
);

SELECT is(
  (public.gs1_country_hint('4400000000000'))->>'code',
  'DE',
  'gs1_country_hint: 440 prefix returns DE (#928)'
);

-- 3. FR prefix (300–379) → France
SELECT is(
  (public.gs1_country_hint('3000000000000'))->>'code',
  'FR',
  'gs1_country_hint: 300 prefix returns FR (#928)'
);

-- 4. GB prefix (50) → United Kingdom
SELECT is(
  (public.gs1_country_hint('5000000000000'))->>'code',
  'GB',
  'gs1_country_hint: 50 prefix returns GB (#928)'
);

-- 5. IE prefix (539) → Ireland
SELECT is(
  (public.gs1_country_hint('5390000000000'))->>'code',
  'IE',
  'gs1_country_hint: 539 prefix returns IE (#928)'
);

-- 6. IT prefix (800–839) → Italy
SELECT is(
  (public.gs1_country_hint('8000000000000'))->>'code',
  'IT',
  'gs1_country_hint: 800 prefix returns IT (#928)'
);

-- 7. ES prefix (840–849) → Spain
SELECT is(
  (public.gs1_country_hint('8400000000000'))->>'code',
  'ES',
  'gs1_country_hint: 840 prefix returns ES (#928)'
);

-- 8. Store-internal (020–029)
SELECT is(
  (public.gs1_country_hint('0200000000000'))->>'code',
  'STORE',
  'gs1_country_hint: 020 prefix returns STORE (#928)'
);

-- 9. Store-internal (200–299)
SELECT is(
  (public.gs1_country_hint('2000000000000'))->>'code',
  'STORE',
  'gs1_country_hint: 200 prefix returns STORE (#928)'
);

-- 10. Unknown prefix → UNKNOWN with prefix field
SELECT is(
  (public.gs1_country_hint('9990000000000'))->>'code',
  'UNKNOWN',
  'gs1_country_hint: unknown prefix returns UNKNOWN (#928)'
);

SELECT ok(
  (public.gs1_country_hint('9990000000000')) ? 'prefix',
  'gs1_country_hint: unknown result includes prefix field (#928)'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- Country-scoped pending submission uniqueness (#930)
-- ═══════════════════════════════════════════════════════════════════════════

-- Disable triggers for direct submission inserts (quality triage auto-resolves known EANs)
ALTER TABLE public.product_submissions DISABLE TRIGGER trg_trust_score_adjustment;
ALTER TABLE public.product_submissions DISABLE TRIGGER trg_submission_quality_triage;

-- Clean up any leftover test submissions from prior runs
DELETE FROM public.product_submissions WHERE ean = '9780000000002' AND product_name LIKE 'pgTAP 930%';

-- 1. Insert pending submission for EAN in PL → succeeds
INSERT INTO public.product_submissions (ean, product_name, status, suggested_country)
VALUES ('9780000000002', 'pgTAP 930 PL', 'pending', 'PL');

SELECT ok(
  EXISTS (SELECT 1 FROM public.product_submissions WHERE ean = '9780000000002' AND suggested_country = 'PL' AND status = 'pending' AND product_name = 'pgTAP 930 PL'),
  'pending submission for EAN in PL inserted successfully (#930)'
);

-- 2. Same EAN + different country (DE) → also succeeds (country-scoped uniqueness)
INSERT INTO public.product_submissions (ean, product_name, status, suggested_country)
VALUES ('9780000000002', 'pgTAP 930 DE', 'pending', 'DE');

SELECT ok(
  EXISTS (SELECT 1 FROM public.product_submissions WHERE ean = '9780000000002' AND suggested_country = 'DE' AND status = 'pending' AND product_name = 'pgTAP 930 DE'),
  'same EAN pending in DE allowed when PL already pending (#930)'
);

-- 3. Same EAN + same country (PL again) → blocked by unique index
SELECT throws_ok(
  $$INSERT INTO public.product_submissions (ean, product_name, status, suggested_country) VALUES ('9780000000002', 'pgTAP 930 PL dup', 'pending', 'PL')$$,
  '23505',
  NULL,
  'duplicate EAN+country pending blocked by idx_ps_ean_country_pending (#930)'
);

-- 4. NULL suggested_country inserts are allowed (NULLs excluded from unique index)
INSERT INTO public.product_submissions (ean, product_name, status, suggested_country)
VALUES ('9780000000002', 'pgTAP 930 NULL country', 'pending', NULL);

SELECT ok(
  EXISTS (SELECT 1 FROM public.product_submissions WHERE ean = '9780000000002' AND suggested_country IS NULL AND status = 'pending' AND product_name = 'pgTAP 930 NULL country'),
  'pending submission with NULL country allowed alongside PL/DE (#930)'
);

-- Clean up test submissions
DELETE FROM public.product_submissions WHERE ean = '9780000000002' AND product_name LIKE 'pgTAP 930%';

-- Re-enable triggers
ALTER TABLE public.product_submissions ENABLE TRIGGER trg_trust_score_adjustment;
ALTER TABLE public.product_submissions ENABLE TRIGGER trg_submission_quality_triage;

-- ─── api_record_scan has_pending_submission is country-scoped (#930) ─────────

-- Insert one pending submission for PL only
ALTER TABLE public.product_submissions DISABLE TRIGGER trg_trust_score_adjustment;
ALTER TABLE public.product_submissions DISABLE TRIGGER trg_submission_quality_triage;

INSERT INTO public.product_submissions (ean, product_name, status, suggested_country)
VALUES ('4006381333931', 'pgTAP 930 Scan PL', 'pending', 'PL');

-- 5. Scan with PL country → has_pending_submission = true
SELECT is(
  (public.api_record_scan('4006381333931', 'PL'))->>'has_pending_submission',
  'true',
  'api_record_scan: has_pending_submission true for PL where PL pending exists (#930)'
);

-- 6. Scan with DE country → has_pending_submission = false (only PL is pending)
SELECT is(
  (public.api_record_scan('4006381333931', 'DE'))->>'has_pending_submission',
  'false',
  'api_record_scan: has_pending_submission false for DE when only PL pending (#930)'
);

-- 7. Scan with NULL country → has_pending_submission = true (global fallback finds PL pending)
SELECT is(
  (public.api_record_scan('4006381333931'))->>'has_pending_submission',
  'true',
  'api_record_scan: has_pending_submission true for NULL country — global fallback (#930)'
);

-- Clean up
DELETE FROM public.product_submissions WHERE ean = '4006381333931' AND product_name LIKE 'pgTAP 930%';

ALTER TABLE public.product_submissions ENABLE TRIGGER trg_trust_score_adjustment;
ALTER TABLE public.product_submissions ENABLE TRIGGER trg_submission_quality_triage;

-- ─── Verify index exists ─────────────────────────────────────────────────────

-- 8. Old global index should not exist
SELECT ok(
  NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relname = 'idx_ps_ean_pending'
  ),
  'old global idx_ps_ean_pending no longer exists (#930)'
);

-- 9. New country-scoped index should exist
SELECT ok(
  EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public' AND c.relname = 'idx_ps_ean_country_pending'
  ),
  'new idx_ps_ean_country_pending exists (#930)'
);


-- ═══════════════════════════════════════════════════════════════════════════
-- Country-aware submission quality scoring — Signal 3 (#931)
-- ═══════════════════════════════════════════════════════════════════════════

-- Fixture product 999999 has EAN '5901234123457' in country 'XX'.
-- Using NULL brand/name to isolate Signal 3 (Signals 5/6 are penalty-only,
-- they don't fire when p_brand/p_product_name is NULL).

-- 1. Same-country EAN match → +15 (score 65)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', NULL, NULL, NULL, 'XX'
  ))->>'quality_score')::int,
  65,
  '_score_submission_quality: same-country EAN match gives +15 (#931)'
);

-- 2. Same-country signal name is ean_exists_same_country
SELECT ok(
  (_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', NULL, NULL, NULL, 'XX'
  ))->'signals' @> '[{"signal": "ean_exists_same_country"}]'::jsonb,
  '_score_submission_quality: same-country signal is ean_exists_same_country (#931)'
);

-- 3. Cross-country EAN match → +5 (score 55)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', NULL, NULL, NULL, 'DE'
  ))->>'quality_score')::int,
  55,
  '_score_submission_quality: cross-country EAN match gives +5 (#931)'
);

-- 4. Cross-country signal name is ean_exists_other_country
SELECT ok(
  (_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', NULL, NULL, NULL, 'DE'
  ))->'signals' @> '[{"signal": "ean_exists_other_country"}]'::jsonb,
  '_score_submission_quality: cross-country signal is ean_exists_other_country (#931)'
);

-- 5. Unknown EAN globally → +0 (score 50)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '0000000000000', NULL, NULL, NULL, 'PL'
  ))->>'quality_score')::int,
  50,
  '_score_submission_quality: unknown EAN gives +0 (#931)'
);

-- 6. NULL country fallback → global match → +15 (score 65)
SELECT is(
  ((_score_submission_quality(
    '00000000-0000-0000-0000-000000000099'::uuid,
    '5901234123457', NULL, NULL, NULL, NULL
  ))->>'quality_score')::int,
  65,
  '_score_submission_quality: NULL country fallback gives +15 for existing EAN (#931)'
);


SELECT * FROM finish();
ROLLBACK;

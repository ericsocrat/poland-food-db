-- ─── pgTAP: Scanner function tests ──────────────────────────────────────────
-- Tests api_record_scan and api_get_scan_history against the real database.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- These tests would have caught the nutri_score vs nutri_score_label bug.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(28);

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

SELECT * FROM finish();
ROLLBACK;

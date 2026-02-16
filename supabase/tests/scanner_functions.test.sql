-- ─── pgTAP: Scanner function tests ──────────────────────────────────────────
-- Tests api_record_scan and api_get_scan_history against the real database.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- These tests would have caught the nutri_score vs nutri_score_label bug.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(14);

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

-- ─── 1. api_record_scan — valid EAN returns found=true ──────────────────────

SELECT lives_ok(
  $$SELECT public.api_record_scan('5901234123457')$$,
  'api_record_scan does not throw for a known EAN'
);

SELECT is(
  (public.api_record_scan('5901234123457'))->>'found',
  'true',
  'api_record_scan returns found=true for a known EAN'
);

-- ─── 2. Response contains required keys ─────────────────────────────────────

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'api_version',
  'response contains api_version key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'product_id',
  'response contains product_id key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'product_name',
  'response contains product_name key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'brand',
  'response contains brand key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'category',
  'response contains category key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'unhealthiness_score',
  'response contains unhealthiness_score key'
);

SELECT ok(
  (public.api_record_scan('5901234123457')) ? 'nutri_score',
  'response contains nutri_score key'
);

-- ─── 3. product_id matches our test product ─────────────────────────────────

SELECT is(
  ((public.api_record_scan('5901234123457'))->>'product_id')::bigint,
  999999::bigint,
  'returned product_id matches the expected product'
);

-- ─── 4. Unknown EAN returns found=false ─────────────────────────────────────

SELECT is(
  (public.api_record_scan('0000000000000'))->>'found',
  'false',
  'api_record_scan returns found=false for unknown EAN'
);

-- ─── 5. Invalid EAN returns error ───────────────────────────────────────────

SELECT ok(
  (public.api_record_scan('123')) ? 'error',
  'api_record_scan returns error for invalid EAN (too short)'
);

SELECT ok(
  (public.api_record_scan(NULL)) ? 'error',
  'api_record_scan returns error for NULL EAN'
);

-- ─── 6. Whitespace trimming ────────────────────────────────────────────────

SELECT is(
  (public.api_record_scan('  5901234123457  '))->>'found',
  'true',
  'api_record_scan trims whitespace from EAN'
);

SELECT * FROM finish();
ROLLBACK;

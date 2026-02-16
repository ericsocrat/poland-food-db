-- ─── pgTAP: Comparison API function tests ────────────────────────────────────
-- Tests api_get_products_for_compare (no-auth, fully testable)
-- and auth-error branches for api_save_comparison, api_get_saved_comparisons,
-- api_delete_comparison, api_get_shared_comparison.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(18);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-cmp-cat', 'pgtap-cmp-cat', 'pgTAP Compare Cat', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-cmp-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999980, '5901234888001', 'pgTAP Compare A', 'CmpBrand',
  'pgtap-cmp-cat', 'XX', 30, 'A', '1'
) ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999981, '5901234888002', 'pgTAP Compare B', 'CmpBrand',
  'pgtap-cmp-cat', 'XX', 70, 'D', '4'
) ON CONFLICT (product_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_get_products_for_compare — fully testable (no auth required)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[])$$,
  'api_get_products_for_compare does not throw'
);

SELECT ok(
  (public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[])) ? 'api_version',
  'compare response has api_version'
);

SELECT ok(
  (public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[])) ? 'product_count',
  'compare response has product_count'
);

SELECT ok(
  (public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[])) ? 'products',
  'compare response has products array'
);

SELECT is(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->>'product_count')::int,
  2,
  'compare returns product_count = 2'
);

SELECT is(
  jsonb_array_length((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'),
  2,
  'compare returns 2 products'
);

-- Product item keys
SELECT ok(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'->0) ? 'product_id',
  'compare product has product_id'
);

SELECT ok(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'->0) ? 'product_name',
  'compare product has product_name'
);

SELECT ok(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'->0) ? 'nutri_score',
  'compare product has nutri_score'
);

SELECT ok(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'->0) ? 'unhealthiness_score',
  'compare product has unhealthiness_score'
);

SELECT ok(
  ((public.api_get_products_for_compare(ARRAY[999980, 999981]::bigint[]))->'products'->0) ? 'score_band',
  'compare product has score_band'
);

-- Single-product compare should return error (requires 2-4 products)
SELECT ok(
  (public.api_get_products_for_compare(ARRAY[999980]::bigint[])) ? 'error',
  'single product compare returns error'
);

-- Empty array should return error
SELECT ok(
  (public.api_get_products_for_compare(ARRAY[]::bigint[])) ? 'error',
  'empty array returns error'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Auth-required comparison functions — error branch (no auth.uid())
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  (public.api_save_comparison(ARRAY[999980, 999981]::bigint[], 'test'))->>'error',
  'Authentication required',
  'api_save_comparison requires auth'
);

SELECT is(
  (public.api_get_saved_comparisons())->>'error',
  'Authentication required',
  'api_get_saved_comparisons requires auth'
);

SELECT is(
  (public.api_delete_comparison('00000000-0000-0000-0000-000000000000'::uuid))->>'error',
  'Authentication required',
  'api_delete_comparison requires auth'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_get_shared_comparison — no auth required but invalid token
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_shared_comparison('invalid-token')$$,
  'api_get_shared_comparison does not throw for invalid token'
);

SELECT ok(
  (public.api_get_shared_comparison('invalid-token')) ? 'error',
  'api_get_shared_comparison returns error for invalid token'
);

SELECT * FROM finish();
ROLLBACK;

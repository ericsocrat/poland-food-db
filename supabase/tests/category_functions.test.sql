-- ─── pgTAP: Category API function tests ─────────────────────────────────────
-- Tests api_category_overview and api_category_listing.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(13);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-cat', 'pgtap-cat', 'pgTAP Category', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999998, '5901234123458', 'pgTAP Cat Product', 'Test Brand',
  'pgtap-cat', 'XX', 35, 'A', '1'
) ON CONFLICT (product_id) DO NOTHING;

-- ─── 1. api_category_overview — basic contract ─────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_category_overview()$$,
  'api_category_overview() does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_category_overview('XX')$$,
  'api_category_overview(XX) does not throw'
);

-- Response is a JSONB with api_version and categories array
SELECT ok(
  (public.api_category_overview('XX')) ? 'api_version',
  'overview response has api_version'
);

SELECT ok(
  (public.api_category_overview('XX')) ? 'categories',
  'overview response has categories array'
);

-- Categories should have at least 1 entry for XX
SELECT ok(
  jsonb_array_length((public.api_category_overview('XX'))->'categories') > 0,
  'overview returns at least 1 category for XX'
);

-- Each category has required keys (check first element)
SELECT ok(
  ((public.api_category_overview('XX'))->'categories'->0) ? 'category',
  'category object has "category" key'
);

SELECT ok(
  ((public.api_category_overview('XX'))->'categories'->0) ? 'slug',
  'category object has "slug" key'
);

SELECT ok(
  ((public.api_category_overview('XX'))->'categories'->0) ? 'display_name',
  'category object has "display_name" key'
);

SELECT ok(
  ((public.api_category_overview('XX'))->'categories'->0) ? 'product_count',
  'category object has "product_count" key'
);

-- ─── 2. api_category_listing — basic contract ──────────────────────────────
-- Note: must pass p_country 'XX' since resolve_effective_country defaults to 'PL'

SELECT lives_ok(
  $$SELECT public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')$$,
  'api_category_listing does not throw for valid slug'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'api_version',
  'listing response has api_version'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'products',
  'listing response has products array'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'total_count',
  'listing response has total_count'
);

SELECT * FROM finish();
ROLLBACK;

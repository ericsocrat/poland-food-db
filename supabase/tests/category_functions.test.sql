-- ─── pgTAP: Category API function tests ─────────────────────────────────────
-- Tests api_category_overview and api_category_listing.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(28);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-cat', 'pgtap-cat', 'pgTAP Category', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-cat';

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-empty-cat', 'pgtap-empty-cat', 'pgTAP Empty Cat', 998, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-empty-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999998, '5901234123458', 'pgTAP Cat Product A', 'Test Brand',
  'pgtap-cat', 'XX', 35, 'A', '1'
) ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999997, '5901234123459', 'pgTAP Cat Product B', 'Other Brand',
  'pgtap-cat', 'XX', 65, 'D', '4'
) ON CONFLICT (product_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_category_overview — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_category_overview()$$,
  'api_category_overview() does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_category_overview('XX')$$,
  'api_category_overview(XX) does not throw'
);

-- Top-level keys
SELECT ok(
  (public.api_category_overview('XX')) ? 'api_version',
  'overview has api_version'
);

SELECT ok(
  (public.api_category_overview('XX')) ? 'categories',
  'overview has categories array'
);

SELECT ok(
  (public.api_category_overview('XX')) ? 'country',
  'overview has country'
);

SELECT is(
  (public.api_category_overview('XX'))->>'api_version',
  '1.0',
  'overview api_version is 1.0'
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

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_category_listing — valid slug with products
-- Note: pass p_country 'XX' since resolve_effective_country defaults to 'PL'
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')$$,
  'api_category_listing does not throw for valid slug'
);

-- Top-level keys
SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'api_version',
  'listing has api_version'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'products',
  'listing has products array'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'total_count',
  'listing has total_count'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'category',
  'listing has category'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'country',
  'listing has country'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'sort_by',
  'listing has sort_by'
);

SELECT ok(
  (public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX')) ? 'sort_dir',
  'listing has sort_dir'
);

-- Verify total_count matches our fixture count
SELECT is(
  ((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->>'total_count')::int,
  2,
  'listing total_count equals 2 (our fixture products)'
);

-- Verify products array has 2 items
SELECT is(
  jsonb_array_length((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'),
  2,
  'listing products array has 2 items'
);

-- Product items have required keys
SELECT ok(
  ((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'->0) ? 'product_id',
  'product item has product_id'
);

SELECT ok(
  ((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'->0) ? 'nutri_score',
  'product item has nutri_score'
);

SELECT ok(
  ((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'->0) ? 'score_band',
  'product item has score_band'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_category_listing — sort direction
-- ═══════════════════════════════════════════════════════════════════════════

-- ASC: first product should have lower score
SELECT ok(
  (((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'->0->>'unhealthiness_score')::int)
  <=
  (((public.api_category_listing('pgtap-cat', 'score', 'asc', 20, 0, 'XX'))->'products'->1->>'unhealthiness_score')::int),
  'ASC sort: first product has lower or equal score'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_category_listing — invalid slug returns error
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  (public.api_category_listing('nonexistent-slug', 'score', 'asc', 20, 0, 'XX')) ? 'error',
  'listing returns error for unknown slug'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_category_listing — empty category returns zero products
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  ((public.api_category_listing('pgtap-empty-cat', 'score', 'asc', 20, 0, 'XX'))->>'total_count')::int,
  0,
  'empty category returns total_count = 0'
);

SELECT is(
  jsonb_array_length((public.api_category_listing('pgtap-empty-cat', 'score', 'asc', 20, 0, 'XX'))->'products'),
  0,
  'empty category returns empty products array'
);

SELECT * FROM finish();
ROLLBACK;

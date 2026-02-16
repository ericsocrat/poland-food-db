-- ─── pgTAP: Search API function tests ───────────────────────────────────────
-- Tests api_search_products, api_search_autocomplete, api_get_filter_options.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- The servings bug was caught by these tests and fixed in
-- 20260216000500_fix_search_servings_reference.sql.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(12);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-search-cat', 'pgtap-search-cat', 'pgTAP Search', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-search-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label
) VALUES (
  999995, '5901234123461', 'pgTAP Search Milk Product', 'Milk Brand',
  'pgtap-search-cat', 'XX', 30, 'A'
) ON CONFLICT (product_id) DO NOTHING;

-- ─── 1. api_search_products — basic contract ───────────────────────────────

-- Note: pass country 'XX' in filters since resolve_effective_country defaults to 'PL'

SELECT lives_ok(
  $$SELECT public.api_search_products('milk', '{"country":"XX"}'::jsonb)$$,
  'api_search_products does not throw for simple query'
);

SELECT ok(
  (public.api_search_products('milk', '{"country":"XX"}'::jsonb)) ? 'api_version',
  'search response has api_version'
);

SELECT ok(
  (public.api_search_products('milk', '{"country":"XX"}'::jsonb)) ? 'results',
  'search response has results array'
);

SELECT ok(
  (public.api_search_products('milk', '{"country":"XX"}'::jsonb)) ? 'total',
  'search response has total count'
);

SELECT ok(
  (public.api_search_products('milk', '{"country":"XX"}'::jsonb)) ? 'page',
  'search response has page number'
);

-- ─── 2. Search with filters ────────────────────────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_search_products(NULL, '{"country":"XX"}'::jsonb)$$,
  'api_search_products with country filter does not throw'
);

SELECT lives_ok(
  $$SELECT public.api_search_products('milk', '{"country":"XX","nutri_score":["A","B"]}'::jsonb)$$,
  'api_search_products with nutri_score filter does not throw'
);

-- ─── 3. api_search_autocomplete ────────────────────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_search_autocomplete('mil')$$,
  'api_search_autocomplete does not throw'
);

SELECT ok(
  (public.api_search_autocomplete('mil')) ? 'api_version',
  'autocomplete response has api_version'
);

SELECT ok(
  (public.api_search_autocomplete('mil')) ? 'suggestions',
  'autocomplete response has suggestions array'
);

-- ─── 4. api_get_filter_options ─────────────────────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_get_filter_options('XX')$$,
  'api_get_filter_options does not throw'
);

SELECT ok(
  (public.api_get_filter_options('XX')) ? 'api_version',
  'filter options response has api_version'
);

SELECT * FROM finish();
ROLLBACK;

-- ─── pgTAP: Search API function tests ────────────────────────────────────────
-- Tests api_search_products, api_search_autocomplete, api_get_filter_options.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(30);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-search-cat', 'pgtap-search-cat', 'pgTAP Search Cat', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-search-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999990, '5901234999001', 'pgTAP Searchable Widget', 'SearchBrand',
  'pgtap-search-cat', 'XX', 40, 'B', '2'
) ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999989, '5901234999002', 'pgTAP Another Widget', 'SearchBrand',
  'pgtap-search-cat', 'XX', 60, 'D', '4'
) ON CONFLICT (product_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_search_products — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)$$,
  'api_search_products does not throw'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'api_version',
  'search result has api_version'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'query',
  'search result has query'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'total',
  'search result has total'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'page',
  'search result has page'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'pages',
  'search result has pages'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'page_size',
  'search result has page_size'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'results',
  'search result has results array'
);

SELECT ok(
  (public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb)) ? 'filters_applied',
  'search result has filters_applied'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_search_products — result content validation
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->>'total')::int >= 1,
  'search for "pgTAP Searchable" finds at least 1 result'
);

-- First result should have product item keys
SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'product_id',
  'result item has product_id'
);

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'product_name',
  'result item has product_name'
);

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'brand',
  'result item has brand'
);

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'nutri_score',
  'result item has nutri_score'
);

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'score_band',
  'result item has score_band'
);

SELECT ok(
  ((public.api_search_products('pgTAP Searchable', '{"country":"XX"}'::jsonb))->'results'->0) ? 'unhealthiness_score',
  'result item has unhealthiness_score'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_search_products — broader query "Widget" finds both products
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
  ((public.api_search_products('Widget', '{"country":"XX"}'::jsonb))->>'total')::int >= 2,
  'search for "Widget" finds at least 2 results'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_search_products — no-match query returns zero results
-- ═══════════════════════════════════════════════════════════════════════════

SELECT is(
  ((public.api_search_products('zzzznonexistent999', '{"country":"XX"}'::jsonb))->>'total')::int,
  0,
  'search for nonsense returns total = 0'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_search_products — NULL/empty query = browse mode
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_search_products(NULL, '{"country":"XX"}'::jsonb)$$,
  'api_search_products with NULL query does not throw (browse mode)'
);

SELECT ok(
  (public.api_search_products(NULL, '{"country":"XX"}'::jsonb)) ? 'results',
  'browse mode still returns results key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_search_autocomplete — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_search_autocomplete('pgTAP')$$,
  'api_search_autocomplete does not throw'
);

SELECT ok(
  (public.api_search_autocomplete('pgTAP')) ? 'api_version',
  'autocomplete has api_version'
);

SELECT ok(
  (public.api_search_autocomplete('pgTAP')) ? 'query',
  'autocomplete has query'
);

SELECT ok(
  (public.api_search_autocomplete('pgTAP')) ? 'suggestions',
  'autocomplete has suggestions array'
);

-- Autocomplete contract: suggestions is an array (may be empty for fixture data
-- since autocomplete may use text-search indexes not populated in transaction)
SELECT ok(
  (public.api_search_autocomplete('pgTAP'))->'suggestions' IS NOT NULL,
  'autocomplete suggestions is not null'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. api_get_filter_options — basic contract
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_filter_options('XX')$$,
  'api_get_filter_options does not throw'
);

SELECT ok(
  (public.api_get_filter_options('XX')) ? 'api_version',
  'filter options has api_version'
);

SELECT ok(
  (public.api_get_filter_options('XX')) ? 'categories',
  'filter options has categories array'
);

SELECT ok(
  (public.api_get_filter_options('XX')) ? 'nutri_scores',
  'filter options has nutri_scores array'
);

-- Categories should include our test category
SELECT ok(
  jsonb_array_length((public.api_get_filter_options('XX'))->'categories') >= 1,
  'filter options returns at least 1 category for XX'
);

SELECT * FROM finish();
ROLLBACK;

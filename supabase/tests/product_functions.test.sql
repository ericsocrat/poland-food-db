-- ─── pgTAP: Product detail & alternatives tests ────────────────────────────
-- Tests api_product_detail_by_ean, api_better_alternatives,
-- api_product_health_warnings.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(15);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-prod-cat', 'pgtap-prod-cat', 'pgTAP Prod Cat', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-prod-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

-- Main test product
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999997, '5901234123459', 'pgTAP Detail Product', 'Test Brand',
  'pgtap-prod-cat', 'XX', 55, 'C', '3'
) ON CONFLICT (product_id) DO NOTHING;

-- A healthier alternative in same category
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification
) VALUES (
  999996, '5901234123460', 'pgTAP Healthy Alt', 'Alt Brand',
  'pgtap-prod-cat', 'XX', 20, 'A', '1'
) ON CONFLICT (product_id) DO NOTHING;

-- ─── 1. api_product_detail_by_ean ──────────────────────────────────────────
-- Note: must pass country 'XX' explicitly because resolve_effective_country
-- defaults to 'PL' when there's no auth context.

SELECT lives_ok(
  $$SELECT public.api_product_detail_by_ean('5901234123459', 'XX')$$,
  'api_product_detail_by_ean does not throw'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'api_version',
  'detail response has api_version'
);

-- api_product_detail returns flat keys (product_id, product_name, scores, etc.)
SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'product_id',
  'detail response has product_id'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'product_name',
  'detail response has product_name'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'scores',
  'detail response has scores object'
);

-- Scores sub-object has nutri_score
SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'unhealthiness_score',
  'scores has unhealthiness_score'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'nutri_score',
  'scores has nutri_score (mapped from nutri_score_label)'
);

-- ─── 2. Unknown EAN ────────────────────────────────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_product_detail_by_ean('0000000000000', 'XX')$$,
  'detail for unknown EAN does not throw'
);

SELECT is(
  (public.api_product_detail_by_ean('0000000000000', 'XX'))->>'found',
  'false',
  'unknown EAN returns found=false'
);

-- ─── 3. api_better_alternatives ────────────────────────────────────────────

SELECT lives_ok(
  $$SELECT public.api_better_alternatives(999997)$$,
  'api_better_alternatives does not throw'
);

SELECT ok(
  (public.api_better_alternatives(999997)) ? 'api_version',
  'alternatives response has api_version'
);

SELECT ok(
  (public.api_better_alternatives(999997)) ? 'alternatives',
  'alternatives response has alternatives array'
);

-- ─── 4. api_product_health_warnings ────────────────────────────────────────
-- Note: Without auth context (auth.uid() = NULL), this returns an error.
-- We verify the function is callable and returns the expected error shape.

SELECT lives_ok(
  $$SELECT public.api_product_health_warnings(999997)$$,
  'api_product_health_warnings does not throw'
);

SELECT ok(
  (public.api_product_health_warnings(999997)) ? 'api_version',
  'health warnings response has api_version'
);

SELECT ok(
  (public.api_product_health_warnings(999997)) ? 'error',
  'health warnings returns error without auth context'
);

SELECT * FROM finish();
ROLLBACK;

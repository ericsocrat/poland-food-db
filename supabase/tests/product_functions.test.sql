-- ─── pgTAP: Product detail, alternatives, score explanation & confidence ────
-- Tests api_product_detail_by_ean, api_product_detail, api_better_alternatives,
--       api_product_health_warnings, api_score_explanation, api_data_confidence,
--       api_get_product_profile, api_get_product_profile_by_ean.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(88);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-prod-cat', 'pgtap-prod-cat', 'pgTAP Prod Cat', 999, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-prod-cat';

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

-- Main test product (moderate score)
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification,
  high_salt_flag, high_sugar_flag, high_sat_fat_flag
) VALUES (
  999997, '5901234123459', 'pgTAP Detail Product', 'Test Brand',
  'pgtap-prod-cat', 'XX', 55, 'C', '3',
  'NO', 'YES', 'NO'
) ON CONFLICT (product_id) DO NOTHING;

-- A healthier alternative in same category
INSERT INTO public.products (
  product_id, ean, product_name, brand, category, country,
  unhealthiness_score, nutri_score_label, nova_classification,
  high_salt_flag, high_sugar_flag, high_sat_fat_flag
) VALUES (
  999996, '5901234123460', 'pgTAP Healthy Alt', 'Alt Brand',
  'pgtap-prod-cat', 'XX', 20, 'A', '1',
  'NO', 'NO', 'NO'
) ON CONFLICT (product_id) DO NOTHING;

-- Nutrition facts for both products
INSERT INTO public.nutrition_facts (product_id, calories, total_fat_g, saturated_fat_g, carbs_g, sugars_g, protein_g, salt_g)
VALUES (999997, '250', '12.0', '5.0', '30.0', '15.0', '8.0', '1.2')
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.nutrition_facts (product_id, calories, total_fat_g, saturated_fat_g, carbs_g, sugars_g, protein_g, salt_g)
VALUES (999996, '100', '2.0', '0.5', '15.0', '3.0', '10.0', '0.3')
ON CONFLICT (product_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. api_product_detail_by_ean — known EAN
-- Note: must pass country 'XX' because resolve_effective_country defaults to 'PL'
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_product_detail_by_ean('5901234123459', 'XX')$$,
  'api_product_detail_by_ean does not throw'
);

-- Top-level keys
SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'api_version',
  'detail response has api_version'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'product_id',
  'detail response has product_id'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'product_name',
  'detail response has product_name'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'brand',
  'detail response has brand'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'category',
  'detail response has category'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'country',
  'detail response has country'
);

-- Nested objects
SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'scores',
  'detail response has scores object'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'flags',
  'detail response has flags object'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'nutrition_per_100g',
  'detail response has nutrition_per_100g object'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'ingredients',
  'detail response has ingredients object'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'allergens',
  'detail response has allergens object'
);

SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'trust',
  'detail response has trust object'
);

-- Scan enrichment from api_product_detail_by_ean wrapper
SELECT ok(
  (public.api_product_detail_by_ean('5901234123459', 'XX')) ? 'scan',
  'detail response has scan metadata'
);

SELECT is(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scan'->>'found')::boolean,
  true,
  'scan.found is true for known EAN'
);

-- Scores sub-object keys
SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'unhealthiness_score',
  'scores has unhealthiness_score'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'nutri_score',
  'scores has nutri_score (mapped from nutri_score_label)'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'score_band',
  'scores has score_band'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores') ? 'nova_group',
  'scores has nova_group'
);

-- Verify actual data values from scores
SELECT is(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'scores'->>'nutri_score'),
  'C',
  'scores.nutri_score value matches fixture nutri_score_label'
);

-- Flags sub-object keys
SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'flags') ? 'high_salt',
  'flags has high_salt'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'flags') ? 'high_sugar',
  'flags has high_sugar'
);

-- Nutrition sub-object keys
SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'nutrition_per_100g') ? 'calories',
  'nutrition has calories'
);

SELECT ok(
  ((public.api_product_detail_by_ean('5901234123459', 'XX'))->'nutrition_per_100g') ? 'protein_g',
  'nutrition has protein_g'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. api_product_detail_by_ean — unknown EAN
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_product_detail_by_ean('0000000000000', 'XX')$$,
  'detail for unknown EAN does not throw'
);

SELECT is(
  (public.api_product_detail_by_ean('0000000000000', 'XX'))->>'found',
  'false',
  'unknown EAN returns found=false'
);

SELECT ok(
  (public.api_product_detail_by_ean('0000000000000', 'XX')) ? 'error',
  'unknown EAN returns error message'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. api_product_detail — by product_id
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_product_detail(999997)$$,
  'api_product_detail by product_id does not throw'
);

SELECT ok(
  (public.api_product_detail(999997)) ? 'api_version',
  'product_detail has api_version'
);

SELECT ok(
  (public.api_product_detail(999997)) ? 'scores',
  'product_detail has scores'
);

SELECT ok(
  (public.api_product_detail(999997)) ? 'nutrition_per_100g',
  'product_detail has nutrition_per_100g'
);

-- NULL for non-existent product_id
SELECT is(
  public.api_product_detail(0),
  NULL,
  'api_product_detail returns NULL for non-existent product_id'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. api_better_alternatives
-- ═══════════════════════════════════════════════════════════════════════════

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

SELECT ok(
  (public.api_better_alternatives(999997)) ? 'source_product',
  'alternatives response has source_product'
);

SELECT ok(
  (public.api_better_alternatives(999997)) ? 'alternatives_count',
  'alternatives response has alternatives_count'
);

SELECT ok(
  (public.api_better_alternatives(999997)) ? 'search_scope',
  'alternatives response has search_scope'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_product_health_warnings — requires auth
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_product_health_warnings(999997)$$,
  'api_product_health_warnings does not throw without auth'
);

SELECT ok(
  (public.api_product_health_warnings(999997)) ? 'api_version',
  'health warnings response has api_version'
);

SELECT ok(
  (public.api_product_health_warnings(999997)) ? 'error',
  'health warnings returns error without auth context'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_score_explanation
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_score_explanation(999997)$$,
  'api_score_explanation does not throw'
);

SELECT ok(
  (public.api_score_explanation(999997)) ? 'api_version',
  'score explanation has api_version'
);

SELECT ok(
  (public.api_score_explanation(999997)) ? 'score_breakdown',
  'score explanation has score_breakdown'
);

SELECT ok(
  (public.api_score_explanation(999997)) ? 'summary',
  'score explanation has summary'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. api_data_confidence
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_data_confidence(999997)$$,
  'api_data_confidence does not throw'
);

SELECT ok(
  (public.api_data_confidence(999997)) ? 'api_version',
  'data confidence has api_version'
);

SELECT ok(
  (public.api_data_confidence(999997)) ? 'confidence_score',
  'data confidence has confidence_score'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. api_get_product_profile — composite profile endpoint
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_product_profile(999997::bigint)$$,
  'api_get_product_profile does not throw'
);

-- Top-level keys
SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'api_version',
  'product profile has api_version'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'meta',
  'product profile has meta section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'product',
  'product profile has product section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'nutrition',
  'product profile has nutrition section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'ingredients',
  'product profile has ingredients section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'allergens',
  'product profile has allergens section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'scores',
  'product profile has scores section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'warnings',
  'product profile has warnings section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'quality',
  'product profile has quality section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'alternatives',
  'product profile has alternatives section'
);

SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'flags',
  'product profile has flags section'
);

-- meta sub-keys
SELECT is(
  ((public.api_get_product_profile(999997::bigint))->'meta'->>'product_id')::bigint,
  999997::bigint,
  'meta.product_id matches requested id'
);

-- product sub-keys
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'product') ? 'product_name',
  'product section has product_name'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'product') ? 'brand',
  'product section has brand'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'product') ? 'category',
  'product section has category'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'product') ? 'ean',
  'product section has ean'
);

-- scores sub-keys
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'scores') ? 'unhealthiness_score',
  'scores section has unhealthiness_score'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'scores') ? 'score_band',
  'scores section has score_band'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'scores') ? 'category_context',
  'scores section has category_context'
);

SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'scores') ? 'score_breakdown',
  'scores section has score_breakdown'
);

-- NULL for non-existent product
SELECT is(
  public.api_get_product_profile(0::bigint),
  NULL,
  'api_get_product_profile returns NULL for non-existent product_id'
);

-- with explicit language parameter
SELECT lives_ok(
  $$SELECT public.api_get_product_profile(999997::bigint, 'en')$$,
  'api_get_product_profile with language param does not throw'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. api_get_product_profile_by_ean — EAN-based lookup
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
  $$SELECT public.api_get_product_profile_by_ean('5901234123459')$$,
  'api_get_product_profile_by_ean does not throw for known EAN'
);

SELECT ok(
  (public.api_get_product_profile_by_ean('5901234123459')) ? 'product',
  'profile by EAN has product section'
);

-- Unknown EAN returns error envelope
SELECT lives_ok(
  $$SELECT public.api_get_product_profile_by_ean('0000000000000')$$,
  'profile by unknown EAN does not throw'
);

SELECT ok(
  (public.api_get_product_profile_by_ean('0000000000000')) ? 'error',
  'unknown EAN returns error key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Product Images — images key in api_get_product_profile
-- ═══════════════════════════════════════════════════════════════════════════

-- Profile should have images key
SELECT ok(
  (public.api_get_product_profile(999997::bigint)) ? 'images',
  'profile has images key'
);

-- images.has_image should be false when no images exist
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'images'->>'has_image')::boolean = false,
  'images.has_image is false when no images inserted'
);

-- images.primary should be null when no images exist
SELECT ok(
  (public.api_get_product_profile(999997::bigint))->'images'->'primary' IS NULL
  OR (public.api_get_product_profile(999997::bigint))->'images'->>'primary' = 'null',
  'images.primary is null when no images inserted'
);

-- images.additional should be empty array when no images exist
SELECT is(
  jsonb_array_length((public.api_get_product_profile(999997::bigint))->'images'->'additional'),
  0,
  'images.additional is empty array when no images inserted'
);

-- Insert test images
INSERT INTO public.product_images (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
VALUES
  (999997, 'https://images.openfoodfacts.org/images/products/123/front.jpg', 'off_api', 'front', true, 'Front of pgTAP product', 'front_pl.123.400'),
  (999997, 'https://images.openfoodfacts.org/images/products/123/ingredients.jpg', 'off_api', 'ingredients', false, 'Ingredients of pgTAP product', 'ingredients_pl.456.400'),
  (999997, 'https://images.openfoodfacts.org/images/products/123/nutrition.jpg', 'off_api', 'nutrition_label', false, 'Nutrition label of pgTAP product', 'nutrition_pl.789.400');

-- After insert: has_image should be true
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'images'->>'has_image')::boolean = true,
  'images.has_image is true after inserting images'
);

-- primary should not be null
SELECT ok(
  (public.api_get_product_profile(999997::bigint))->'images'->'primary' IS NOT NULL
  AND (public.api_get_product_profile(999997::bigint))->'images'->>'primary' <> 'null',
  'images.primary is not null after inserting primary image'
);

-- primary should have url
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'images'->'primary') ? 'url',
  'images.primary has url field'
);

-- primary image_type should be front
SELECT is(
  (public.api_get_product_profile(999997::bigint))->'images'->'primary'->>'image_type',
  'front',
  'primary image type is front'
);

-- additional should have 2 images (ingredients + nutrition_label)
SELECT is(
  jsonb_array_length((public.api_get_product_profile(999997::bigint))->'images'->'additional'),
  2,
  'images.additional has 2 non-primary images'
);

-- primary image url should match
SELECT is(
  (public.api_get_product_profile(999997::bigint))->'images'->'primary'->>'url',
  'https://images.openfoodfacts.org/images/products/123/front.jpg',
  'primary image url matches expected'
);

-- Cleanup test images (rollback handles it, but be explicit)
DELETE FROM public.product_images WHERE product_id = 999997;

-- After cleanup: has_image should be false again
SELECT ok(
  ((public.api_get_product_profile(999997::bigint))->'images'->>'has_image')::boolean = false,
  'images.has_image is false after removing images'
);

SELECT * FROM finish();
ROLLBACK;

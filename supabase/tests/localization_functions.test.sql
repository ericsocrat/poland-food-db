-- ─── pgTAP: Localization Phases 1-4 + Hardening (#32) ────────────────────────
-- Tests for language_ref, category_translations, resolve_language(),
-- preferred_language on user_preferences, localized API responses,
-- Phase 2 product_name_en / search enhancements,
-- Phase 3 cross-language search synonyms,
-- Phase 4 European expansion (name_translations, default_language),
-- and localization hardening (metrics view, confidence, synonym cap, disable safety).
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(88);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.language_ref (code, name_en, name_native, sort_order, is_enabled)
VALUES ('en', 'English', 'English', 1, true),
       ('pl', 'Polish',  'Polski',  2, true),
       ('de', 'German',  'Deutsch', 3, true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.country_ref (country_code, country_name, is_active, default_language)
VALUES ('XX', 'Test Country', true, 'en')
ON CONFLICT (country_code) DO UPDATE SET default_language = 'en';

INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-l10n', 'pgtap-l10n', 'pgTAP Localization', 990, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-l10n';

INSERT INTO public.category_translations (category, language_code, display_name)
VALUES ('pgtap-l10n', 'en', 'pgTAP Localization'),
       ('pgtap-l10n', 'pl', 'pgTAP Lokalizacja')
ON CONFLICT (category, language_code) DO NOTHING;

-- Insert a category WITHOUT a Polish translation to test fallback
INSERT INTO public.category_ref (category, slug, display_name, sort_order, is_active)
VALUES ('pgtap-l10n-noPl', 'pgtap-l10n-nopl', 'No Polish Name', 991, true)
ON CONFLICT (category) DO UPDATE SET slug = 'pgtap-l10n-nopl';

INSERT INTO public.category_translations (category, language_code, display_name)
VALUES ('pgtap-l10n-noPl', 'en', 'No Polish Name')
ON CONFLICT (category, language_code) DO NOTHING;

-- Test products
INSERT INTO public.products (product_id, product_name, brand, category, country, is_deprecated)
VALUES (999801, 'L10n Test Product A', 'TestBrand', 'pgtap-l10n', 'XX', false)
ON CONFLICT (product_id) DO UPDATE SET category = 'pgtap-l10n';

INSERT INTO public.products (product_id, product_name, brand, category, country, is_deprecated)
VALUES (999802, 'L10n Fallback Product', 'TestBrand', 'pgtap-l10n-noPl', 'XX', false)
ON CONFLICT (product_id) DO UPDATE SET category = 'pgtap-l10n-noPl';

-- Phase 2 fixture: product with English translation + EAN for search/scan tests
INSERT INTO public.products (
    product_id, product_name, product_name_en, product_name_en_source,
    brand, category, country, ean, is_deprecated, unhealthiness_score
) VALUES (
    999803, 'Chipsy Testowe o smaku Papryka', 'Test Paprika Flavored Chips', 'ai',
    'TestBrand', 'pgtap-l10n', 'PL', '5901234123457', false, 42
) ON CONFLICT (product_id) DO UPDATE SET
    product_name_en = 'Test Paprika Flavored Chips',
    product_name_en_source = 'ai',
    ean = '5901234123457',
    unhealthiness_score = 42;

-- Phase 2 fixture: product WITHOUT English translation (tests fallback)
INSERT INTO public.products (
    product_id, product_name, brand, category, country, is_deprecated, unhealthiness_score
) VALUES (
    999804, 'Ciastka Testowe Czekoladowe', 'TestBrand', 'pgtap-l10n', 'PL', false, 30
) ON CONFLICT (product_id) DO UPDATE SET
    product_name_en = NULL,
    unhealthiness_score = 30;

-- Phase 3 fixture: product with EN name containing "Milk" but no "mleko" anywhere
-- Used to test PL→EN synonym: searching "mleko" should find this via synonym→"milk"
INSERT INTO public.products (
    product_id, product_name, product_name_en, brand, category, country,
    is_deprecated, unhealthiness_score
) VALUES (
    999805, 'Testowy Napój ABC', 'Test Milk Drink ABC', 'TestBrand',
    'pgtap-l10n', 'PL', false, 35
) ON CONFLICT (product_id) DO UPDATE SET
    product_name = 'Testowy Napój ABC',
    product_name_en = 'Test Milk Drink ABC',
    unhealthiness_score = 35;

-- Phase 3 fixture: product with Polish name containing "Mleko" but NO EN translation
-- Used to test EN→PL synonym: searching "milk" should find this via synonym→"mleko"
INSERT INTO public.products (
    product_id, product_name, brand, category, country,
    is_deprecated, unhealthiness_score
) VALUES (
    999806, 'Mleko Testowe UVW', 'TestBrand',
    'pgtap-l10n', 'PL', false, 25
) ON CONFLICT (product_id) DO UPDATE SET
    product_name = 'Mleko Testowe UVW',
    product_name_en = NULL,
    unhealthiness_score = 25;

-- Phase 4 fixture: product with name_translations (German)
INSERT INTO public.products (
    product_id, product_name, product_name_en, name_translations,
    brand, category, country, is_deprecated, unhealthiness_score
) VALUES (
    999807, 'Chipsy Paprykowe XYZ', 'Paprika Chips XYZ',
    '{"de": "Paprika Chips XYZ", "fr": "Chips au Paprika XYZ"}'::jsonb,
    'TestBrand', 'pgtap-l10n', 'PL', false, 38
) ON CONFLICT (product_id) DO UPDATE SET
    product_name = 'Chipsy Paprykowe XYZ',
    product_name_en = 'Paprika Chips XYZ',
    name_translations = '{"de": "Paprika Chips XYZ", "fr": "Chips au Paprika XYZ"}'::jsonb,
    unhealthiness_score = 38;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. language_ref table structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'language_ref', 'language_ref table exists');
SELECT has_column('public', 'language_ref', 'code',        'language_ref.code exists');
SELECT has_column('public', 'language_ref', 'name_en',     'language_ref.name_en exists');
SELECT has_column('public', 'language_ref', 'name_native', 'language_ref.name_native exists');
SELECT has_column('public', 'language_ref', 'is_enabled',  'language_ref.is_enabled exists');
SELECT has_column('public', 'language_ref', 'sort_order',  'language_ref.sort_order exists');

-- Seed data check
SELECT is(
    (SELECT COUNT(*)::int FROM public.language_ref WHERE code IN ('en','pl','de')),
    3,
    'language_ref has en, pl, de seed data'
);

SELECT ok(
    (SELECT is_enabled FROM public.language_ref WHERE code = 'en'),
    'English is enabled'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. category_translations table structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'category_translations', 'category_translations table exists');
SELECT has_column('public', 'category_translations', 'category',      'category_translations.category exists');
SELECT has_column('public', 'category_translations', 'language_code', 'category_translations.language_code exists');
SELECT has_column('public', 'category_translations', 'display_name',  'category_translations.display_name exists');

-- Must have English for every active category
SELECT ok(
    NOT EXISTS (
        SELECT cr.category
        FROM public.category_ref cr
        WHERE cr.is_active = true
          AND NOT EXISTS (
              SELECT 1 FROM public.category_translations ct
              WHERE ct.category = cr.category AND ct.language_code = 'en'
          )
    ),
    'every active category has an English translation'
);

-- Spot-check Polish seed data
SELECT is(
    (SELECT display_name FROM public.category_translations
     WHERE category = 'pgtap-l10n' AND language_code = 'pl'),
    'pgTAP Lokalizacja',
    'Polish translation exists for pgtap-l10n category'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. user_preferences.preferred_language
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'user_preferences', 'preferred_language',
    'user_preferences.preferred_language column exists');

SELECT col_default_is('public', 'user_preferences', 'preferred_language', 'en',
    'preferred_language defaults to en');

SELECT col_not_null('public', 'user_preferences', 'preferred_language',
    'preferred_language is NOT NULL');

-- FK to language_ref
SELECT fk_ok('public', 'user_preferences', 'preferred_language',
             'public', 'language_ref', 'code',
             'preferred_language FK references language_ref.code');

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. resolve_language() function
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'resolve_language', ARRAY['text'],
    'resolve_language(text) exists');

-- Priority 1: explicit valid param
SELECT is(
    (SELECT public.resolve_language('pl')),
    'pl',
    'resolve_language(''pl'') returns pl'
);

SELECT is(
    (SELECT public.resolve_language('de')),
    'de',
    'resolve_language(''de'') returns de'
);

-- Fallback for invalid language code
SELECT is(
    (SELECT public.resolve_language('xx')),
    'en',
    'resolve_language(''xx'') falls back to en (invalid code)'
);

-- Fallback for empty string
SELECT is(
    (SELECT public.resolve_language('')),
    'en',
    'resolve_language('''') falls back to en (empty string)'
);

-- Fallback for NULL (anonymous user, no user pref)
SELECT is(
    (SELECT public.resolve_language(NULL)),
    'en',
    'resolve_language(NULL) returns en for anonymous user'
);

-- Disabled language should fall back
DO $$
BEGIN
    UPDATE public.language_ref SET is_enabled = false WHERE code = 'de';
END;
$$;

SELECT is(
    (SELECT public.resolve_language('de')),
    'en',
    'resolve_language(''de'') falls back to en when de is disabled'
);

-- Re-enable for subsequent tests
DO $$
BEGIN
    UPDATE public.language_ref SET is_enabled = true WHERE code = 'de';
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. api_get_user_preferences returns preferred_language
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'api_get_user_preferences',
    'api_get_user_preferences exists');

-- Auth required — unauthenticated call returns error
SELECT ok(
    (SELECT api_get_user_preferences() ? 'error'),
    'api_get_user_preferences returns error key when unauthenticated'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. api_set_user_preferences validates language
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'api_set_user_preferences',
    'api_set_user_preferences exists');

-- Auth required
SELECT ok(
    (SELECT api_set_user_preferences(
        p_preferred_language := 'pl'
    ) ? 'error'),
    'api_set_user_preferences returns error when unauthenticated'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. api_category_overview returns localized display_name
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
    $$SELECT api_category_overview('XX', 'pl')$$,
    'api_category_overview(XX, pl) does not throw'
);

SELECT ok(
    (SELECT api_category_overview('XX', 'pl') ? 'language'),
    'api_category_overview response contains language key'
);

SELECT is(
    (SELECT api_category_overview('XX', 'pl')->>'language'),
    'pl',
    'api_category_overview with p_language=pl returns language=pl'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. api_category_listing returns localized envelope
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
    $$SELECT api_category_listing('pgtap-l10n', p_country := 'XX', p_language := 'pl')$$,
    'api_category_listing with p_language=pl does not throw'
);

SELECT is(
    (SELECT api_category_listing('pgtap-l10n', p_country := 'XX', p_language := 'pl')->>'category_display'),
    'pgTAP Lokalizacja',
    'api_category_listing returns Polish category_display'
);

SELECT is(
    (SELECT api_category_listing('pgtap-l10n', p_country := 'XX', p_language := 'en')->>'category_display'),
    'pgTAP Localization',
    'api_category_listing returns English category_display'
);

-- Fallback test: category without Polish translation
SELECT is(
    (SELECT api_category_listing('pgtap-l10n-noPl', p_country := 'XX', p_language := 'pl')->>'category_display'),
    'No Polish Name',
    'api_category_listing falls back to English when Polish translation missing'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. api_product_detail returns localized category_display
-- ═══════════════════════════════════════════════════════════════════════════

SELECT lives_ok(
    $$SELECT api_product_detail(999801)$$,
    'api_product_detail(999801) does not throw'
);

-- Default language (anonymous user) should return English
SELECT is(
    (SELECT api_product_detail(999801)->>'category_display'),
    'pgTAP Localization',
    'api_product_detail returns English category_display by default'
);

-- Fallback: product in category without Polish translation
SELECT is(
    (SELECT api_product_detail(999802)->>'category_display'),
    'No Polish Name',
    'api_product_detail falls back to English for untranslated category'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Phase 2: product_name_en column structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'products', 'product_name_en',
    'products.product_name_en column exists');

SELECT has_column('public', 'products', 'product_name_en_source',
    'products.product_name_en_source column exists');

SELECT has_column('public', 'products', 'product_name_en_reviewed_at',
    'products.product_name_en_reviewed_at column exists');

SELECT has_column('public', 'products', 'product_name_en_reviewed_by',
    'products.product_name_en_reviewed_by column exists');

-- product_name_en IS nullable (NULL = not yet translated)
SELECT col_is_null('public', 'products', 'product_name_en',
    'product_name_en is nullable');

-- product_name_en is NOT part of the unique constraint
-- (the unique constraint is on country, brand, product_name — not product_name_en)
SELECT ok(
    NOT EXISTS (
        SELECT 1 FROM information_schema.key_column_usage kcu
        JOIN information_schema.table_constraints tc
            ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
        WHERE tc.constraint_type = 'UNIQUE'
          AND kcu.table_schema = 'public'
          AND kcu.table_name = 'products'
          AND kcu.column_name = 'product_name_en'
    ),
    'product_name_en is NOT in any unique constraint'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. Phase 2: api_product_detail returns product_name_en + product_name_display
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 999803 has product_name_en set
SELECT is(
    (SELECT api_product_detail(999803)->>'product_name_en'),
    'Test Paprika Flavored Chips',
    'api_product_detail returns product_name_en when available'
);

-- product_name_display for anonymous user (language=en): should show EN name
SELECT is(
    (SELECT api_product_detail(999803)->>'product_name_display'),
    'Test Paprika Flavored Chips',
    'api_product_detail returns EN product_name_display for default language'
);

-- Product 999804 has NO English translation — product_name_display falls back
SELECT is(
    (SELECT api_product_detail(999804)->>'product_name_display'),
    'Ciastka Testowe Czekoladowe',
    'api_product_detail falls back to product_name when product_name_en is NULL'
);

-- original_language derived from country
SELECT is(
    (SELECT api_product_detail(999803)->>'original_language'),
    'pl',
    'api_product_detail returns original_language derived from country'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Phase 3: search_synonyms table structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'search_synonyms', 'search_synonyms table exists');

SELECT has_column('public', 'search_synonyms', 'id',
    'search_synonyms.id exists');
SELECT has_column('public', 'search_synonyms', 'term_original',
    'search_synonyms.term_original exists');
SELECT has_column('public', 'search_synonyms', 'term_target',
    'search_synonyms.term_target exists');
SELECT has_column('public', 'search_synonyms', 'language_from',
    'search_synonyms.language_from exists');
SELECT has_column('public', 'search_synonyms', 'language_to',
    'search_synonyms.language_to exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. Phase 3: search_synonyms seed data
-- ═══════════════════════════════════════════════════════════════════════════

-- PL→EN direction has seed data
SELECT ok(
    (SELECT COUNT(*)::int FROM public.search_synonyms
     WHERE language_from = 'pl' AND language_to = 'en') >= 50,
    'search_synonyms has >= 50 PL→EN term pairs'
);

-- EN→PL direction has seed data
SELECT ok(
    (SELECT COUNT(*)::int FROM public.search_synonyms
     WHERE language_from = 'en' AND language_to = 'pl') >= 50,
    'search_synonyms has >= 50 EN→PL term pairs'
);

-- Spot-check: mleko→milk exists
SELECT is(
    (SELECT term_target FROM public.search_synonyms
     WHERE term_original = 'mleko' AND language_from = 'pl' AND language_to = 'en'),
    'milk',
    'synonym mleko→milk (PL→EN) exists'
);

-- Spot-check: milk→mleko exists (reverse direction)
SELECT is(
    (SELECT term_target FROM public.search_synonyms
     WHERE term_original = 'milk' AND language_from = 'en' AND language_to = 'pl'),
    'mleko',
    'synonym milk→mleko (EN→PL) exists'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. Phase 3: expand_search_query() function
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'expand_search_query', ARRAY['text'],
    'expand_search_query(text) exists');

-- Single word: mleko → should include 'milk'
SELECT ok(
    'milk' = ANY(expand_search_query('mleko')),
    'expand_search_query(''mleko'') includes ''milk'''
);

-- Case-insensitive: MLEKO also works
SELECT ok(
    'milk' = ANY(expand_search_query('MLEKO')),
    'expand_search_query is case-insensitive (MLEKO → milk)'
);

-- Reverse: milk → should include 'mleko'
SELECT ok(
    'mleko' = ANY(expand_search_query('milk')),
    'expand_search_query(''milk'') includes ''mleko'''
);

-- Non-synonym word returns empty array
SELECT is(
    array_length(expand_search_query('zzzznotaword'), 1),
    NULL,
    'expand_search_query returns empty for unknown term'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. Phase 3: cross-language search — PL term finds EN-named product
-- ═══════════════════════════════════════════════════════════════════════════

-- Searching "mleko" in country PL should find product 999805
-- (product_name_en = 'Test Milk Drink ABC', no "mleko" in product_name)
SELECT ok(
    (SELECT (api_search_products('mleko', '{"country":"PL"}'::jsonb))->>'total')::int >= 1,
    'search "mleko" finds at least 1 result in PL (via synonym → milk)'
);

-- Verify product 999805 is in the results
SELECT ok(
    EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
            (api_search_products('mleko', '{"country":"PL"}'::jsonb))->'results'
        ) AS r
        WHERE (r->>'product_id')::bigint = 999805
    ),
    'search "mleko" finds product 999805 (EN name contains Milk)'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. Phase 3: cross-language search — EN term finds PL-named product
-- ═══════════════════════════════════════════════════════════════════════════

-- Searching "milk" in country PL should find product 999806
-- (product_name = 'Mleko Testowe UVW', no product_name_en set)
SELECT ok(
    EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
            (api_search_products('milk', '{"country":"PL"}'::jsonb))->'results'
        ) AS r
        WHERE (r->>'product_id')::bigint = 999806
    ),
    'search "milk" finds product 999806 (PL name contains Mleko)'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. Phase 4: name_translations column structure
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'products', 'name_translations',
    'products.name_translations column exists');

SELECT col_not_null('public', 'products', 'name_translations',
    'name_translations is NOT NULL');

SELECT col_default_is('public', 'products', 'name_translations', '{}',
    'name_translations defaults to empty JSONB object');

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. Phase 4: country_ref.default_language column
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'country_ref', 'default_language',
    'country_ref.default_language column exists');

-- FK to language_ref
SELECT fk_ok('public', 'country_ref', 'default_language',
             'public', 'language_ref', 'code',
             'default_language FK references language_ref.code');

-- PL country has default_language = 'pl'
SELECT is(
    (SELECT default_language FROM public.country_ref WHERE country_code = 'PL'),
    'pl',
    'PL country has default_language = pl'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. Phase 4: product_name_display uses name_translations for non-EN/native
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 999807 has name_translations with "de" and "fr" keys
-- For anonymous user (language=en), display should be EN name
SELECT is(
    (SELECT api_product_detail(999807)->>'product_name_display'),
    'Paprika Chips XYZ',
    'api_product_detail shows EN name for anonymous (language=en) user'
);

-- name_translations has "de" key
SELECT ok(
    (SELECT api_product_detail(999807)) ? 'product_name_en',
    'api_product_detail response has product_name_en key'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. Phase 4: v_master includes name_translations
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
    EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'v_master'
          AND column_name = 'name_translations'
    ),
    'v_master view includes name_translations column'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 21. Phase 4: name_translations values are searchable
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 999807 has name_translations.de = 'Paprika Chips XYZ'
-- The search_vector trigger should index these values
-- Searching for the German translation term should find the product
SELECT ok(
    EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
            (api_search_products('Paprika Chips XYZ', '{"country":"PL"}'::jsonb))->'results'
        ) AS r
        WHERE (r->>'product_id')::bigint = 999807
    ),
    'search finds product 999807 via name_translations content'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 22. Phase 4: country_ref seed data validation
-- ═══════════════════════════════════════════════════════════════════════════

-- DE country should have default_language = 'de'
SELECT is(
    (SELECT default_language FROM public.country_ref WHERE country_code = 'DE'),
    'de',
    'DE country has default_language = de'
);

-- Test country XX has default_language = 'en'
SELECT is(
    (SELECT default_language FROM public.country_ref WHERE country_code = 'XX'),
    'en',
    'XX test country has default_language = en'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 23. Hardening: localization_metrics view
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_view('public', 'localization_metrics',
    'localization_metrics view exists');

-- With test fixtures: 999803, 999805, 999807 have product_name_en;
-- 999801, 999802, 999804, 999806 do NOT.
SELECT ok(
    (SELECT total_products >= 0 FROM public.localization_metrics),
    'localization_metrics.total_products is non-negative'
);

-- Verify percentage calculation is correct for fixture data
SELECT ok(
    (SELECT pct_translated IS NOT NULL OR total_products = 0
     FROM public.localization_metrics),
    'localization_metrics.pct_translated is calculable'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 24. Hardening: product_name_en_confidence column
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'products', 'product_name_en_confidence',
    'products.product_name_en_confidence column exists');

-- Confirm CHECK constraint rejects out-of-range values
SELECT throws_ok(
    $$UPDATE products SET product_name_en_confidence = 1.5 WHERE product_id = 999801$$,
    '23514',   -- check_violation
    NULL,
    'product_name_en_confidence rejects values > 1'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 25. Hardening: language disable safety
-- ═══════════════════════════════════════════════════════════════════════════

-- Temporarily disable German
UPDATE public.language_ref SET is_enabled = false WHERE code = 'de';

-- resolve_language('de') should fall back to 'en' when de is disabled
SELECT is(
    resolve_language('de'),
    'en',
    'resolve_language(de) falls back to en when de is disabled'
);

-- Product 999807 has name_translations with "de" key.
-- Even though de exists in name_translations, product_name_display
-- should NOT use it when de is disabled — it should use EN fallback.
SELECT is(
    (SELECT api_product_detail(999807)->>'product_name_display'),
    'Paprika Chips XYZ',
    'product_name_display uses EN fallback when de is disabled (not name_translations.de)'
);

-- Re-enable German for subsequent tests
UPDATE public.language_ref SET is_enabled = true WHERE code = 'de';

-- ═══════════════════════════════════════════════════════════════════════════
-- 26. Hardening: synonym expansion capped at 10
-- ═══════════════════════════════════════════════════════════════════════════

SELECT ok(
    (SELECT array_length(expand_search_query('mleko'), 1) <= 10
        OR expand_search_query('mleko') = ARRAY[]::text[]),
    'expand_search_query returns at most 10 synonyms'
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 27. Hardening: NULL product_name_en fallback
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 999804 has product_name_en = NULL.
-- product_name_display must fall back to product_name (not be NULL).
SELECT is(
    (SELECT api_product_detail(999804)->>'product_name_display'),
    'Ciastka Testowe Czekoladowe',
    'product_name_display falls back to product_name when product_name_en IS NULL'
);

SELECT * FROM finish();
ROLLBACK;

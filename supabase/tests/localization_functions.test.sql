-- ─── pgTAP: Localization Phase 1 (#32) ──────────────────────────────────────
-- Tests for language_ref, category_translations, resolve_language(),
-- preferred_language on user_preferences, and localized API responses.
-- Run via: supabase test db
--
-- Self-contained: inserts own fixture data so tests work on an empty DB.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(42);

-- ─── Fixtures ───────────────────────────────────────────────────────────────

INSERT INTO public.language_ref (code, name_en, name_native, sort_order, is_enabled)
VALUES ('en', 'English', 'English', 1, true),
       ('pl', 'Polish',  'Polski',  2, true),
       ('de', 'German',  'Deutsch', 3, true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.country_ref (country_code, country_name, is_active)
VALUES ('XX', 'Test Country', true)
ON CONFLICT (country_code) DO NOTHING;

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

SELECT * FROM finish();
ROLLBACK;

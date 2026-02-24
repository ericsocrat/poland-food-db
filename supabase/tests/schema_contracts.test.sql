-- ─── pgTAP: Schema contract tests ───────────────────────────────────────────
-- Validates the public schema: tables, columns, views, materialized views,
-- and functions that frontend/API relies on.
-- Run via: supabase test db
--
-- These tests catch accidental renames or drops of schema objects.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(117);

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Core data tables exist
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'products',          'table products exists');
SELECT has_table('public', 'nutrition_facts',    'table nutrition_facts exists');
SELECT has_table('public', 'category_ref',       'table category_ref exists');
SELECT has_table('public', 'country_ref',        'table country_ref exists');
SELECT has_table('public', 'nutri_score_ref',    'table nutri_score_ref exists');
SELECT has_table('public', 'concern_tier_ref',   'table concern_tier_ref exists');
SELECT has_table('public', 'ingredient_ref',     'table ingredient_ref exists');
SELECT has_table('public', 'product_ingredient', 'table product_ingredient exists');
SELECT has_table('public', 'product_allergen_info', 'table product_allergen_info exists');
SELECT has_table('public', 'product_field_provenance', 'table product_field_provenance exists');
SELECT has_table('public', 'source_nutrition',   'table source_nutrition exists');
SELECT has_table('public', 'language_ref',       'table language_ref exists');
SELECT has_table('public', 'category_translations', 'table category_translations exists');
SELECT has_table('public', 'search_synonyms',       'table search_synonyms exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. User / auth-related tables exist
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_table('public', 'user_preferences',       'table user_preferences exists');
SELECT has_table('public', 'user_health_profiles',   'table user_health_profiles exists');
SELECT has_table('public', 'user_product_lists',     'table user_product_lists exists');
SELECT has_table('public', 'user_product_list_items', 'table user_product_list_items exists');
SELECT has_table('public', 'user_comparisons',       'table user_comparisons exists');
SELECT has_table('public', 'user_saved_searches',    'table user_saved_searches exists');
SELECT has_table('public', 'scan_history',           'table scan_history exists');
SELECT has_table('public', 'product_submissions',    'table product_submissions exists');
SELECT has_table('public', 'analytics_events',       'table analytics_events exists');
SELECT has_table('public', 'allowed_event_names',    'table allowed_event_names exists');
SELECT has_table('public', 'user_product_views',     'table user_product_views exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Key columns on products table
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'products', 'product_id',          'products.product_id exists');
SELECT has_column('public', 'products', 'ean',                 'products.ean exists');
SELECT has_column('public', 'products', 'product_name',        'products.product_name exists');
SELECT has_column('public', 'products', 'brand',               'products.brand exists');
SELECT has_column('public', 'products', 'category',            'products.category exists');
SELECT has_column('public', 'products', 'country',             'products.country exists');
SELECT has_column('public', 'products', 'unhealthiness_score', 'products.unhealthiness_score exists');
SELECT has_column('public', 'products', 'nutri_score_label',   'products.nutri_score_label exists');
SELECT has_column('public', 'products', 'nova_classification', 'products.nova_classification exists');
SELECT has_column('public', 'products', 'product_name_en',        'products.product_name_en exists');
SELECT has_column('public', 'products', 'product_name_en_source', 'products.product_name_en_source exists');
SELECT has_column('public', 'products', 'product_name_en_reviewed_at', 'products.product_name_en_reviewed_at exists');
SELECT has_column('public', 'products', 'name_translations',             'products.name_translations exists');
SELECT has_column('public', 'user_preferences', 'preferred_language', 'user_preferences.preferred_language exists');
SELECT has_column('public', 'country_ref', 'default_language',             'country_ref.default_language exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Key columns on nutrition_facts table
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_column('public', 'nutrition_facts', 'product_id',      'nutrition_facts.product_id exists');
SELECT has_column('public', 'nutrition_facts', 'calories',         'nutrition_facts.calories exists');
SELECT has_column('public', 'nutrition_facts', 'total_fat_g',      'nutrition_facts.total_fat_g exists');
SELECT has_column('public', 'nutrition_facts', 'saturated_fat_g',  'nutrition_facts.saturated_fat_g exists');
SELECT has_column('public', 'nutrition_facts', 'carbs_g',          'nutrition_facts.carbs_g exists');
SELECT has_column('public', 'nutrition_facts', 'sugars_g',         'nutrition_facts.sugars_g exists');
SELECT has_column('public', 'nutrition_facts', 'protein_g',        'nutrition_facts.protein_g exists');
SELECT has_column('public', 'nutrition_facts', 'salt_g',           'nutrition_facts.salt_g exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Views exist
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_view('public', 'v_master',                       'view v_master exists');
SELECT has_view('public', 'v_api_category_overview',        'view v_api_category_overview exists');
SELECT has_view('public', 'v_api_category_overview_by_country', 'view v_api_category_overview_by_country exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Materialized views exist
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_materialized_view('public', 'mv_ingredient_frequency', 'materialized view mv_ingredient_frequency exists');
SELECT has_materialized_view('public', 'v_product_confidence',    'materialized view v_product_confidence exists');

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Core API functions exist (no-auth functions)
-- ═══════════════════════════════════════════════════════════════════════════

SELECT has_function('public', 'api_record_scan',           'function api_record_scan exists');
SELECT has_function('public', 'api_product_detail_by_ean', 'function api_product_detail_by_ean exists');
SELECT has_function('public', 'api_product_detail',        'function api_product_detail exists');
SELECT has_function('public', 'api_better_alternatives',   'function api_better_alternatives exists');
SELECT has_function('public', 'api_score_explanation',     'function api_score_explanation exists');
SELECT has_function('public', 'api_data_confidence',       'function api_data_confidence exists');
SELECT has_function('public', 'api_category_overview',     'function api_category_overview exists');
SELECT has_function('public', 'api_category_listing',      'function api_category_listing exists');
SELECT has_function('public', 'api_search_products',       'function api_search_products exists');
SELECT has_function('public', 'api_search_autocomplete',   'function api_search_autocomplete exists');
SELECT has_function('public', 'api_get_filter_options',    'function api_get_filter_options exists');
SELECT has_function('public', 'api_track_event',           'function api_track_event exists');
SELECT has_function('public', 'api_admin_get_event_summary', 'function api_admin_get_event_summary exists');
SELECT has_function('public', 'api_admin_get_top_events',  'function api_admin_get_top_events exists');
SELECT has_function('public', 'api_admin_get_funnel',      'function api_admin_get_funnel exists');
SELECT has_function('public', 'api_record_product_view',   'function api_record_product_view exists');
SELECT has_function('public', 'api_get_recently_viewed',   'function api_get_recently_viewed exists');
SELECT has_function('public', 'api_get_dashboard_data',    'function api_get_dashboard_data exists');
SELECT has_function('public', 'resolve_language',           'function resolve_language exists');
SELECT has_function('public', 'expand_search_query',        'function expand_search_query exists');

-- === Localization Hardening ===
SELECT has_view('public', 'localization_metrics',            'view localization_metrics exists');
SELECT has_column('public', 'products', 'product_name_en_confidence', 'column products.product_name_en_confidence exists');

-- === Canonical Product Profile API ===
SELECT has_function('public', 'api_get_product_profile',        'function api_get_product_profile exists');
SELECT has_function('public', 'api_get_product_profile_by_ean', 'function api_get_product_profile_by_ean exists');

-- === Product Images (#34) ===
SELECT has_table('public', 'product_images',                    'table product_images exists');
SELECT has_column('public', 'product_images', 'image_id',       'column product_images.image_id exists');
SELECT has_column('public', 'product_images', 'product_id',     'column product_images.product_id exists');
SELECT has_column('public', 'product_images', 'url',            'column product_images.url exists');
SELECT has_column('public', 'product_images', 'image_type',     'column product_images.image_type exists');
SELECT has_column('public', 'product_images', 'is_primary',     'column product_images.is_primary exists');
SELECT has_column('public', 'product_images', 'source',         'column product_images.source exists');
SELECT has_column('public', 'product_images', 'off_image_id',   'column product_images.off_image_id exists');
SELECT has_column('public', 'product_images', 'created_at',     'column product_images.created_at exists');

-- === Daily Value References (#37) ===
SELECT has_table('public', 'daily_value_ref',                    'table daily_value_ref exists');
SELECT has_column('public', 'daily_value_ref', 'nutrient',       'column daily_value_ref.nutrient exists');
SELECT has_column('public', 'daily_value_ref', 'regulation',     'column daily_value_ref.regulation exists');
SELECT has_column('public', 'daily_value_ref', 'daily_value',    'column daily_value_ref.daily_value exists');
SELECT has_column('public', 'daily_value_ref', 'unit',           'column daily_value_ref.unit exists');
SELECT has_column('public', 'daily_value_ref', 'source',         'column daily_value_ref.source exists');
SELECT has_column('public', 'daily_value_ref', 'updated_at',     'column daily_value_ref.updated_at exists');
SELECT has_function('public', 'compute_daily_value_pct',         'function compute_daily_value_pct exists');

-- ─── Ingredient Profile API (#36) ───────────────────────────────────────────
SELECT has_function('public', 'api_get_ingredient_profile',      'function api_get_ingredient_profile exists');
SELECT volatility_is('public', 'api_get_ingredient_profile', ARRAY['bigint','text'], 'stable', 'api_get_ingredient_profile is STABLE');

-- ─── Formula Registry (#198) ─────────────────────────────────────────────
SELECT has_table('public', 'formula_source_hashes',               'table formula_source_hashes exists');
SELECT has_view('public', 'v_formula_registry',                   'view v_formula_registry exists');
SELECT has_function('public', 'check_formula_drift',              'function check_formula_drift exists');
SELECT has_function('public', 'check_function_source_drift',      'function check_function_source_drift exists');
SELECT has_column('public', 'scoring_model_versions', 'weights_fingerprint', 'scoring_model_versions.weights_fingerprint exists');
SELECT has_column('public', 'search_ranking_config', 'weights_fingerprint', 'search_ranking_config.weights_fingerprint exists');

-- ─── Drift Detection Automation (#199) ───────────────────────────────────────
SELECT has_table('public', 'drift_check_results',                 'table drift_check_results exists');
SELECT has_column('public', 'drift_check_results', 'run_id',     'column drift_check_results.run_id exists');
SELECT has_function('public', 'governance_drift_check',           'function governance_drift_check exists');
SELECT has_function('public', 'log_drift_check',                  'function log_drift_check exists');

-- ─── Backfill Orchestration (#208) ────────────────────────────────────────────
SELECT has_table('public', 'backfill_registry',                   'table backfill_registry exists');
SELECT has_column('public', 'backfill_registry', 'backfill_id',  'column backfill_registry.backfill_id exists');
SELECT has_column('public', 'backfill_registry', 'name',         'column backfill_registry.name exists');
SELECT has_column('public', 'backfill_registry', 'status',       'column backfill_registry.status exists');
SELECT has_column('public', 'backfill_registry', 'rows_processed','column backfill_registry.rows_processed exists');
SELECT has_view('public', 'v_backfill_status',                   'view v_backfill_status exists');
SELECT has_function('public', 'register_backfill',               'function register_backfill exists');
SELECT has_function('public', 'start_backfill',                  'function start_backfill exists');
SELECT has_function('public', 'complete_backfill',               'function complete_backfill exists');

-- ─── Log Schema & Error Taxonomy (#210) ───────────────────────────────────────
SELECT has_table('public', 'log_level_ref',                      'table log_level_ref exists');
SELECT has_table('public', 'error_code_registry',                'table error_code_registry exists');
SELECT has_function('public', 'validate_log_entry',              'function validate_log_entry exists');

SELECT * FROM finish();
ROLLBACK;

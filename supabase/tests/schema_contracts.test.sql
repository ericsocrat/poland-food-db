-- ─── pgTAP: Schema contract tests ───────────────────────────────────────────
-- Validates the public schema: tables, columns, views, materialized views,
-- and functions that frontend/API relies on.
-- Run via: supabase test db
--
-- These tests catch accidental renames or drops of schema objects.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(237);

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
SELECT has_column('public', 'products', 'nutri_score_source',             'products.nutri_score_source exists');
SELECT has_column('public', 'user_preferences', 'preferred_language', 'user_preferences.preferred_language exists');
SELECT has_column('public', 'country_ref', 'default_language',             'country_ref.default_language exists');
SELECT has_column('public', 'country_ref', 'nutri_score_official',          'country_ref.nutri_score_official exists');

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

-- ─── Alert Escalation & Query Regression (#211) ─────────────────────────────────
SELECT has_table('public', 'query_performance_snapshots',        'table query_performance_snapshots exists');
SELECT has_function('public', 'snapshot_query_performance',      'function snapshot_query_performance exists');
SELECT has_view('public', 'v_query_regressions',                 'view v_query_regressions exists');
SELECT has_view('public', 'v_unused_indexes',                    'view v_unused_indexes exists');
SELECT has_view('public', 'v_missing_indexes',                   'view v_missing_indexes exists');
SELECT has_view('public', 'v_index_bloat_estimate',              'view v_index_bloat_estimate exists');

-- ─── Event Intelligence (#190) ───────────────────────────────────────────────
SELECT has_table('public', 'event_schema_registry',               'table event_schema_registry exists');
SELECT has_column('public', 'event_schema_registry', 'event_type',     'column event_schema_registry.event_type exists');
SELECT has_column('public', 'event_schema_registry', 'schema_version', 'column event_schema_registry.schema_version exists');
SELECT has_column('public', 'event_schema_registry', 'json_schema',    'column event_schema_registry.json_schema exists');
SELECT has_column('public', 'event_schema_registry', 'status',         'column event_schema_registry.status exists');
SELECT has_column('public', 'event_schema_registry', 'pii_fields',     'column event_schema_registry.pii_fields exists');
SELECT has_column('public', 'event_schema_registry', 'retention_days', 'column event_schema_registry.retention_days exists');
SELECT has_column('public', 'analytics_events', 'schema_version',      'column analytics_events.schema_version exists');
SELECT has_column('public', 'analytics_events', 'country',             'column analytics_events.country exists');
SELECT has_column('public', 'analytics_events', 'consent_level',       'column analytics_events.consent_level exists');
SELECT has_column('public', 'analytics_events', 'anonymous_id',        'column analytics_events.anonymous_id exists');
SELECT has_column('public', 'analytics_events', 'route',               'column analytics_events.route exists');
SELECT has_function('public', 'api_validate_event_schema',        'function api_validate_event_schema exists');
SELECT has_function('public', 'api_get_event_schemas',            'function api_get_event_schemas exists');

-- ─── Core Table Timestamps (#362) ─────────────────────────────────────────────
SELECT has_column('public', 'nutrition_facts',      'created_at',  'nutrition_facts.created_at exists');
SELECT has_column('public', 'nutrition_facts',      'updated_at',  'nutrition_facts.updated_at exists');
SELECT has_column('public', 'product_ingredient',   'created_at',  'product_ingredient.created_at exists');
SELECT has_column('public', 'product_ingredient',   'updated_at',  'product_ingredient.updated_at exists');
SELECT has_column('public', 'product_allergen_info', 'created_at', 'product_allergen_info.created_at exists');
SELECT has_column('public', 'product_allergen_info', 'updated_at', 'product_allergen_info.updated_at exists');
SELECT has_column('public', 'ingredient_ref',       'created_at',  'ingredient_ref.created_at exists');
SELECT has_column('public', 'ingredient_ref',       'updated_at',  'ingredient_ref.updated_at exists');
SELECT has_column('public', 'category_ref',         'created_at',  'category_ref.created_at exists');
SELECT has_column('public', 'category_ref',         'updated_at',  'category_ref.updated_at exists');
SELECT has_column('public', 'country_ref',          'created_at',  'country_ref.created_at exists');
SELECT has_column('public', 'country_ref',          'updated_at',  'country_ref.updated_at exists');

-- ─── FK Column Indexes (#363) ──────────────────────────────────────────────
SELECT has_index('public', 'products',            'idx_products_nutri_score_label',    'index idx_products_nutri_score_label exists');
SELECT has_index('public', 'user_preferences',    'idx_user_preferences_language',     'index idx_user_preferences_language exists');
SELECT has_index('public', 'country_ref',         'idx_country_ref_default_language',  'index idx_country_ref_default_language exists');
SELECT has_index('public', 'error_code_registry', 'idx_error_code_registry_severity',  'index idx_error_code_registry_severity exists');
SELECT has_index('public', 'products',            'idx_products_name_reviewed_by',     'index idx_products_name_reviewed_by exists');
SELECT has_index('public', 'product_submissions',  'idx_product_submissions_reviewed_by','index idx_product_submissions_reviewed_by exists');

-- ─── Completeness Gap Analysis (#376) ─────────────────────────────────────────
SELECT has_function('public', 'api_completeness_gap_analysis',    'function api_completeness_gap_analysis exists');

-- ─── Feature Flag Activation Roadmap (#372) ──────────────────────────────────
SELECT has_column('public', 'feature_flags', 'activation_criteria',  'feature_flags.activation_criteria exists');
SELECT has_column('public', 'feature_flags', 'activation_order',     'feature_flags.activation_order exists');
SELECT has_column('public', 'feature_flags', 'depends_on',           'feature_flags.depends_on exists');
SELECT has_function('public', 'check_flag_readiness',                'function check_flag_readiness exists');

-- ─── Store Architecture (#350) ────────────────────────────────────────────────
SELECT has_table('public', 'store_ref',                           'table store_ref exists');
SELECT has_column('public', 'store_ref', 'store_id',              'column store_ref.store_id exists');
SELECT has_column('public', 'store_ref', 'country',               'column store_ref.country exists');
SELECT has_column('public', 'store_ref', 'store_name',            'column store_ref.store_name exists');
SELECT has_column('public', 'store_ref', 'store_slug',            'column store_ref.store_slug exists');
SELECT has_column('public', 'store_ref', 'store_type',            'column store_ref.store_type exists');
SELECT has_column('public', 'store_ref', 'is_active',             'column store_ref.is_active exists');
SELECT has_table('public', 'product_store_availability',          'table product_store_availability exists');
SELECT has_column('public', 'product_store_availability', 'product_id', 'column product_store_availability.product_id exists');
SELECT has_column('public', 'product_store_availability', 'store_id',   'column product_store_availability.store_id exists');
SELECT has_column('public', 'product_store_availability', 'source',     'column product_store_availability.source exists');
SELECT has_function('public', 'api_product_stores',               'function api_product_stores exists');
SELECT has_function('public', 'api_store_products',               'function api_store_products exists');
SELECT has_function('public', 'api_list_stores',                  'function api_list_stores exists');

-- v_master store columns
SELECT has_column('public', 'v_master', 'nutri_score_source',     'v_master.nutri_score_source exists');
SELECT has_column('public', 'v_master', 'store_count',            'v_master.store_count exists');
SELECT has_column('public', 'v_master', 'store_names',            'v_master.store_names exists');

-- ─── Trigger Optimization (#374) ──────────────────────────────────────────────
SELECT has_trigger('products', 'trg_products_score_unified',      'unified score trigger exists on products');
SELECT has_trigger('products', 'products_30_change_audit',        'change audit trigger exists on products');
SELECT has_trigger('products', 'trg_products_search_vector_update', 'search vector trigger exists on products');
SELECT has_trigger('products', 'trg_products_updated_at',         'updated_at trigger exists on products');
SELECT has_function('public', 'trg_unified_score_change',         'function trg_unified_score_change exists');

-- Żabka deactivated
SELECT ok(
    NOT (SELECT is_active FROM category_ref WHERE category = 'Żabka'),
    'Żabka category is deactivated'
);
SELECT is(
    (SELECT COUNT(*)::int FROM products WHERE category = 'Żabka' AND is_deprecated = false),
    0,
    'no active products in Żabka category'
);

-- ─── Audit Log Retention (#371) ────────────────────────────────────────────
SELECT has_table('public', 'retention_policies',            'table retention_policies exists');
SELECT has_function('public', 'execute_retention_cleanup',  'function execute_retention_cleanup exists');
SELECT has_column('public', 'retention_policies', 'table_name', 'column retention_policies.table_name exists');

-- ─── MV Refresh Log (#377) ─────────────────────────────────────────────────
SELECT has_table('public', 'mv_refresh_log',                'table mv_refresh_log exists');
SELECT has_function('public', 'mv_last_refresh',            'function mv_last_refresh exists');
SELECT has_column('public', 'mv_refresh_log', 'mv_name',   'column mv_refresh_log.mv_name exists');

-- ─── GDPR Data Export & Deletion (#469) ────────────────────────────────────
SELECT has_function('public', 'api_export_user_data',       'function api_export_user_data exists');
SELECT has_function('public', 'api_delete_user_data',       'function api_delete_user_data exists');
SELECT has_table('public', 'deletion_audit_log',            'table deletion_audit_log exists');
SELECT has_column('public', 'deletion_audit_log', 'id',            'column deletion_audit_log.id exists');
SELECT has_column('public', 'deletion_audit_log', 'deleted_at',   'column deletion_audit_log.deleted_at exists');

-- ─── EAN Checksum Validation (#465) ──────────────────────────────────────────
SELECT has_function('public', 'is_valid_ean',                   'function is_valid_ean exists');
SELECT has_column('public', 'product_submissions', 'review_notes', 'column product_submissions.review_notes exists');
SELECT has_trigger('product_submissions', 'trg_submission_ean_check', 'EAN checksum trigger exists on product_submissions');

-- ─── Rate Limiting (#466) ────────────────────────────────────────────────────
SELECT has_function('public', 'check_submission_rate_limit',  'function check_submission_rate_limit exists');
SELECT has_function('public', 'check_scan_rate_limit',        'function check_scan_rate_limit exists');

-- ─── Submission Auto-Triage (#468) ───────────────────────────────────────────
SELECT has_function('public', 'score_submission_quality',         'function score_submission_quality exists');
SELECT has_function('public', '_score_submission_quality',        'function _score_submission_quality exists');
SELECT has_trigger('product_submissions', 'trg_submission_quality_triage', 'auto-triage trigger exists on product_submissions');

-- ─── API Rate Limiting (#472) ────────────────────────────────────────────────
SELECT has_table('public', 'api_rate_limits',              'table api_rate_limits exists');
SELECT has_table('public', 'api_rate_limit_log',           'table api_rate_limit_log exists');
SELECT has_function('public', 'check_api_rate_limit',      'function check_api_rate_limit exists');

-- ─── User Trust Scoring (#471) ───────────────────────────────────────────────
SELECT has_table('public', 'user_trust_scores',            'table user_trust_scores exists');
SELECT has_column('public', 'user_trust_scores', 'trust_score', 'user_trust_scores has trust_score column');
SELECT has_function('public', 'trig_adjust_trust_score',   'function trig_adjust_trust_score exists');

-- ─── Admin Submission Dashboard (#474) ────────────────────────────────────────
SELECT has_function('public', 'api_admin_batch_reject_user',     'function api_admin_batch_reject_user exists');
SELECT has_function('public', 'api_admin_submission_velocity',   'function api_admin_submission_velocity exists');

-- ─── Data Freshness Tracking (#357) ──────────────────────────────────────────
SELECT has_column('public', 'products', 'last_fetched_at',       'products.last_fetched_at exists');
SELECT has_column('public', 'products', 'off_revision',          'products.off_revision exists');
SELECT has_view('public', 'v_data_freshness_summary',            'view v_data_freshness_summary exists');
SELECT has_index('public', 'products', 'idx_products_last_fetched', 'index idx_products_last_fetched exists');

-- ─── Product Type Taxonomy (#354) ────────────────────────────────────────────
SELECT has_table('public', 'product_type_ref',                   'table product_type_ref exists');
SELECT has_column('public', 'product_type_ref', 'category',      'product_type_ref has category column');
SELECT has_column('public', 'product_type_ref', 'display_name',  'product_type_ref has display_name column');

-- ─── Cross-Country Product Links (#352) ──────────────────────────────────────
SELECT has_table('public', 'product_links',                      'table product_links exists');
SELECT has_column('public', 'product_links', 'product_id_a',     'product_links has product_id_a column');
SELECT has_column('public', 'product_links', 'product_id_b',     'product_links has product_id_b column');
SELECT has_column('public', 'product_links', 'link_type',        'product_links has link_type column');
SELECT has_column('public', 'product_links', 'confidence',       'product_links has confidence column');
SELECT has_function('public', 'api_get_cross_country_links',     'function api_get_cross_country_links exists');

-- ─── Brand Normalization (#356) ──────────────────────────────────────────────
SELECT has_table('public', 'brand_ref',                          'table brand_ref exists');
SELECT has_column('public', 'brand_ref', 'brand_name',           'brand_ref has brand_name column');
SELECT has_column('public', 'brand_ref', 'display_name',         'brand_ref has display_name column');
SELECT has_column('public', 'brand_ref', 'parent_company',       'brand_ref has parent_company column');
SELECT has_column('public', 'brand_ref', 'is_store_brand',       'brand_ref has is_store_brand column');

-- ─── Ingredient Translations (#355) ─────────────────────────────────────────
SELECT has_table('public', 'ingredient_translations',                       'table ingredient_translations exists');
SELECT has_column('public', 'ingredient_translations', 'ingredient_id',     'ingredient_translations has ingredient_id column');
SELECT has_column('public', 'ingredient_translations', 'language_code',     'ingredient_translations has language_code column');
SELECT has_column('public', 'ingredient_translations', 'name',              'ingredient_translations has name column');
SELECT has_column('public', 'ingredient_translations', 'source',            'ingredient_translations has source column');
SELECT has_column('public', 'ingredient_translations', 'reviewed_at',       'ingredient_translations has reviewed_at column');
SELECT has_function('public', 'resolve_ingredient_name',                    'function resolve_ingredient_name exists');

SELECT * FROM finish();
ROLLBACK;

-- ============================================================
-- DR Drill — Post-Drill Verification Queries
-- ============================================================
-- Run after each scenario (or after all scenarios) to confirm
-- the database is in a healthy state. These are READ-ONLY checks.
--
-- Run via: RUN_DR_DRILL.ps1 (automatic) or manually in psql
-- Environment: any (local, staging, production)
-- ============================================================

\echo '════════════════════════════════════════════════════════════'
\echo 'POST-DRILL VERIFICATION'
\echo '════════════════════════════════════════════════════════════'

-- ═══════════════════════════════════════════════════════════════
-- CHECK 1: Core table row counts
-- ═══════════════════════════════════════════════════════════════
\echo '[V-1] Core table row counts...'

SELECT 'products' AS tbl, COUNT(*) AS row_count FROM products
UNION ALL SELECT 'nutrition_facts', COUNT(*) FROM nutrition_facts
UNION ALL SELECT 'product_allergen_info', COUNT(*) FROM product_allergen_info
UNION ALL SELECT 'product_ingredient', COUNT(*) FROM product_ingredient
UNION ALL SELECT 'ingredient_ref', COUNT(*) FROM ingredient_ref
UNION ALL SELECT 'country_ref', COUNT(*) FROM country_ref
UNION ALL SELECT 'category_ref', COUNT(*) FROM category_ref
UNION ALL SELECT 'nutri_score_ref', COUNT(*) FROM nutri_score_ref
UNION ALL SELECT 'concern_tier_ref', COUNT(*) FROM concern_tier_ref
ORDER BY tbl;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 2: User data table row counts
-- ═══════════════════════════════════════════════════════════════
\echo '[V-2] User data table row counts...'

SELECT 'user_preferences' AS tbl, COUNT(*) AS row_count FROM user_preferences
UNION ALL SELECT 'user_health_profiles', COUNT(*) FROM user_health_profiles
UNION ALL SELECT 'user_product_lists', COUNT(*) FROM user_product_lists
UNION ALL SELECT 'user_product_list_items', COUNT(*) FROM user_product_list_items
UNION ALL SELECT 'user_comparisons', COUNT(*) FROM user_comparisons
UNION ALL SELECT 'user_saved_searches', COUNT(*) FROM user_saved_searches
UNION ALL SELECT 'scan_history', COUNT(*) FROM scan_history
UNION ALL SELECT 'product_submissions', COUNT(*) FROM product_submissions
ORDER BY tbl;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 3: Schema integrity — key columns exist
-- ═══════════════════════════════════════════════════════════════
\echo '[V-3] Schema integrity — key columns...'

SELECT t.tbl || '.' || t.col AS expected_column,
       CASE WHEN c.column_name IS NOT NULL THEN 'OK' ELSE 'MISSING' END AS status
FROM (VALUES
    ('products', 'id'),
    ('products', 'ean'),
    ('products', 'product_name'),
    ('products', 'health_score'),
    ('products', 'country_code'),
    ('products', 'category'),
    ('products', 'is_deprecated'),
    ('nutrition_facts', 'product_id'),
    ('nutrition_facts', 'energy_kcal'),
    ('user_preferences', 'user_id'),
    ('user_health_profiles', 'user_id')
) AS t(tbl, col)
LEFT JOIN information_schema.columns c
    ON c.table_schema = 'public'
    AND c.table_name = t.tbl
    AND c.column_name = t.col
ORDER BY t.tbl, t.col;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 4: RLS still enabled on core tables
-- ═══════════════════════════════════════════════════════════════
\echo '[V-4] RLS status on core tables...'

SELECT c.relname AS table_name,
       CASE WHEN c.relrowsecurity THEN 'ENABLED' ELSE 'DISABLED' END AS rls_status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN (
      'user_preferences', 'user_health_profiles',
      'user_product_lists', 'user_product_list_items',
      'user_comparisons', 'user_saved_searches',
      'scan_history', 'product_submissions'
  )
ORDER BY c.relname;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 5: Active product count meets threshold
-- ═══════════════════════════════════════════════════════════════
\echo '[V-5] Active product count (threshold >= 1000)...'

SELECT COUNT(*) AS active_products,
       CASE WHEN COUNT(*) >= 1000 THEN 'OK' ELSE 'BELOW THRESHOLD' END AS status
FROM products
WHERE is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 6: No duplicate active EANs
-- ═══════════════════════════════════════════════════════════════
\echo '[V-6] EAN uniqueness (expect 0 duplicates)...'

SELECT ean, COUNT(*) AS dup_count
FROM products
WHERE is_deprecated IS NOT TRUE
GROUP BY ean
HAVING COUNT(*) > 1
LIMIT 10;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 7: Latest migration version
-- ═══════════════════════════════════════════════════════════════
\echo '[V-7] Latest migration version...'

SELECT version, name
FROM supabase_migrations.schema_migrations
ORDER BY version DESC
LIMIT 3;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 8: API functions exist
-- ═══════════════════════════════════════════════════════════════
\echo '[V-8] Critical API functions exist...'

SELECT t.fn AS expected_function,
       CASE WHEN p.proname IS NOT NULL THEN 'OK' ELSE 'MISSING' END AS status
FROM (VALUES
    ('api_search_products'),
    ('api_get_product_detail'),
    ('api_get_health_profile'),
    ('api_upsert_health_profile'),
    ('api_barcode_lookup'),
    ('api_health_check')
) AS t(fn)
LEFT JOIN pg_proc p
    ON p.proname = t.fn
    AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY t.fn;

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo 'POST-DRILL VERIFICATION COMPLETE'
\echo '════════════════════════════════════════════════════════════'

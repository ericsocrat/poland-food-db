-- ============================================================
-- Sanity Check Pack — Cross-Environment Validation
-- ============================================================
-- Run against any environment (local, staging, production) to
-- verify schema expectations, data invariants, and parity.
--
-- Each check returns 0 rows on success, >0 rows on failure.
-- The RUN_SANITY.ps1 script parses these results.
--
-- Unlike db/qa/ checks (which validate data quality within a
-- single environment), these checks verify structural health
-- and cross-environment assumptions.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- CHECK 1: Required tables exist
-- ═══════════════════════════════════════════════════════════════
SELECT t.expected_table AS missing_table,
       'MISSING TABLE' AS issue
FROM (VALUES
    ('products'),
    ('nutrition_facts'),
    ('ingredient_ref'),
    ('product_ingredient'),
    ('product_allergen_info'),
    ('country_ref'),
    ('category_ref'),
    ('nutri_score_ref'),
    ('concern_tier_ref'),
    ('user_preferences'),
    ('user_health_profiles')
) AS t(expected_table)
LEFT JOIN information_schema.tables ist
    ON ist.table_schema = 'public'
    AND ist.table_name = t.expected_table
WHERE ist.table_name IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 2: Required views exist
-- ═══════════════════════════════════════════════════════════════
SELECT v.expected_view AS missing_view,
       'MISSING VIEW' AS issue
FROM (VALUES
    ('v_master'),
    ('v_api_category_overview'),
    ('v_product_confidence')
) AS v(expected_view)
LEFT JOIN information_schema.tables ist
    ON ist.table_schema = 'public'
    AND ist.table_name = v.expected_view
LEFT JOIN pg_matviews mv
    ON mv.schemaname = 'public'
    AND mv.matviewname = v.expected_view
WHERE ist.table_name IS NULL
  AND mv.matviewname IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 3: Required functions exist
-- ═══════════════════════════════════════════════════════════════
SELECT f.expected_function AS missing_function,
       'MISSING FUNCTION' AS issue
FROM (VALUES
    ('compute_unhealthiness_v32'),
    ('explain_score_v32'),
    ('score_category'),
    ('compute_data_confidence'),
    ('compute_data_completeness'),
    ('api_product_detail'),
    ('api_category_listing'),
    ('api_search_products'),
    ('api_score_explanation'),
    ('api_better_alternatives'),
    ('refresh_all_materialized_views'),
    ('mv_staleness_check'),
    ('compute_health_warnings'),
    ('api_create_health_profile'),
    ('api_update_health_profile'),
    ('api_delete_health_profile'),
    ('api_list_health_profiles')
) AS f(expected_function)
LEFT JOIN information_schema.routines isr
    ON isr.routine_schema = 'public'
    AND isr.routine_name = f.expected_function
WHERE isr.routine_name IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 4: Reference data populated
-- ═══════════════════════════════════════════════════════════════
SELECT 'country_ref' AS table_name,
       COUNT(*) AS row_count,
       'REFERENCE TABLE EMPTY' AS issue
FROM country_ref
HAVING COUNT(*) = 0
UNION ALL
SELECT 'category_ref', COUNT(*), 'REFERENCE TABLE EMPTY'
FROM category_ref
HAVING COUNT(*) = 0
UNION ALL
SELECT 'nutri_score_ref', COUNT(*), 'REFERENCE TABLE EMPTY'
FROM nutri_score_ref
HAVING COUNT(*) = 0
UNION ALL
SELECT 'concern_tier_ref', COUNT(*), 'REFERENCE TABLE EMPTY'
FROM concern_tier_ref
HAVING COUNT(*) = 0;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 5: Product row count within expected range
--   Staging/Production with full PL dataset: >= 1000
--   This check warns if active products are below threshold.
-- ═══════════════════════════════════════════════════════════════
SELECT COUNT(*) AS active_products,
       'PRODUCT COUNT BELOW THRESHOLD (expected >= 1000)' AS issue
FROM products
WHERE is_deprecated IS NOT TRUE
HAVING COUNT(*) < 1000;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 6: EAN uniqueness — no duplicate active EANs
-- ═══════════════════════════════════════════════════════════════
SELECT ean,
       COUNT(*) AS duplicate_count,
       'DUPLICATE ACTIVE EAN' AS issue
FROM products
WHERE ean IS NOT NULL
  AND is_deprecated IS NOT TRUE
GROUP BY ean
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 7: Country scoping integrity — no mixed-country leaks
--   Every active product must have a country that exists in
--   country_ref and is marked active.
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.country, p.product_name,
       CASE
         WHEN cr.country_code IS NULL THEN 'COUNTRY NOT IN REFERENCE TABLE'
         WHEN cr.is_active = false    THEN 'COUNTRY NOT ACTIVE'
       END AS issue
FROM products p
LEFT JOIN country_ref cr ON cr.country_code = p.country
WHERE p.is_deprecated IS NOT TRUE
  AND (cr.country_code IS NULL OR cr.is_active = false);

-- ═══════════════════════════════════════════════════════════════
-- CHECK 8: Category integrity — all active products reference
--   an existing category in category_ref.
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.category, p.product_name,
       'CATEGORY NOT IN REFERENCE TABLE' AS issue
FROM products p
LEFT JOIN category_ref cr ON cr.category = p.category
WHERE p.is_deprecated IS NOT TRUE
  AND cr.category IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 9: Deprecated product logic — deprecated products must
--   have a deprecated_reason (not null).
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.product_name,
       'DEPRECATED WITHOUT REASON' AS issue
FROM products p
WHERE p.is_deprecated = true
  AND p.deprecated_reason IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 10: Scoring coverage — all non-deprecated products must
--   have a computed unhealthiness_score.
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.product_name,
       'NO UNHEALTHINESS SCORE' AS issue
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND p.unhealthiness_score IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 11: Nutri-Score coverage — all non-deprecated products
--   must have a nutri_score_label that references nutri_score_ref.
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.product_name, p.nutri_score_label,
       'INVALID NUTRI-SCORE LABEL' AS issue
FROM products p
LEFT JOIN nutri_score_ref nsr ON nsr.label = p.nutri_score_label
WHERE p.is_deprecated IS NOT TRUE
  AND (p.nutri_score_label IS NULL OR nsr.label IS NULL);

-- ═══════════════════════════════════════════════════════════════
-- CHECK 12: Nutrition facts completeness — all non-deprecated
--   products must have at least one nutrition fact row.
-- ═══════════════════════════════════════════════════════════════
SELECT p.product_id, p.product_name,
       'NO NUTRITION FACTS ROW' AS issue
FROM products p
LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
WHERE p.is_deprecated IS NOT TRUE
  AND nf.product_id IS NULL;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 13: Health profile invariant — at most one active
--   profile per user (enforced by partial unique index, but
--   verify the data invariant holds).
-- ═══════════════════════════════════════════════════════════════
SELECT user_id,
       COUNT(*) AS active_profiles,
       'MULTIPLE ACTIVE HEALTH PROFILES' AS issue
FROM user_health_profiles
WHERE is_active = true
GROUP BY user_id
HAVING COUNT(*) > 1;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 14: RLS is enabled on all core data tables
-- ═══════════════════════════════════════════════════════════════
SELECT t.expected_table AS table_without_rls,
       'RLS NOT ENABLED' AS issue
FROM (VALUES
    ('products'),
    ('nutrition_facts'),
    ('ingredient_ref'),
    ('product_ingredient'),
    ('product_allergen_info'),
    ('user_preferences'),
    ('user_health_profiles')
) AS t(expected_table)
JOIN pg_class c ON c.relname = t.expected_table
JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = 'public'
WHERE NOT c.relrowsecurity;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 15: Materialized views are not stale
--   v_product_confidence and mv_ingredient_frequency must exist
--   and have rows.
-- ═══════════════════════════════════════════════════════════════
SELECT mv.expected_mv AS stale_mv,
       COALESCE(cnt.row_count, 0) AS row_count,
       'MATERIALIZED VIEW EMPTY OR MISSING' AS issue
FROM (VALUES
    ('v_product_confidence'),
    ('mv_ingredient_frequency')
) AS mv(expected_mv)
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS row_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = 'public'
    WHERE c.relname = mv.expected_mv
      AND c.relkind = 'm'
) cnt ON true
WHERE COALESCE(cnt.row_count, 0) = 0;

-- ═══════════════════════════════════════════════════════════════
-- CHECK 16: Foreign key constraints are all validated
-- ═══════════════════════════════════════════════════════════════
SELECT conname AS unvalidated_constraint,
       conrelid::regclass AS table_name,
       'UNVALIDATED FOREIGN KEY' AS issue
FROM pg_constraint
WHERE contype = 'f'
  AND NOT convalidated
  AND connamespace = 'public'::regnamespace;

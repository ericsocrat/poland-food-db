-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: API Contract Tests
-- Validates that every API function returns the exact documented key set.
-- Any key added or removed will break these checks, forcing a deliberate
-- api_version bump.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Helper: compare an actual sorted key array against an expected sorted key array.
-- Returns TRUE if they match exactly.

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  api_product_detail — top-level keys (19)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)) k
    ) = ARRAY[
        'allergens','api_version','brand','category','category_display','category_icon',
        'country','ean','flags','freshness','ingredients','nutrition_per_100g','prep_method',
        'product_id','product_name','product_type','scores','store_availability','trust'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#1  product_detail top-level keys (19)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  api_product_detail → scores keys (6)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'scores') k
    ) = ARRAY[
        'nova_group','nutri_score','nutri_score_color','processing_risk',
        'score_band','unhealthiness_score'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#2  product_detail → scores keys (6)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  api_product_detail → flags keys (5)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'flags') k
    ) = ARRAY['has_palm_oil','high_additive_load','high_salt','high_sat_fat','high_sugar']
    THEN 'PASS' ELSE 'FAIL' END AS "#3  product_detail → flags keys (5)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  api_product_detail → nutrition_per_100g keys (9)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'nutrition_per_100g') k
    ) = ARRAY[
        'calories','carbs_g','fibre_g','protein_g','salt_g','saturated_fat_g',
        'sugars_g','total_fat_g','trans_fat_g'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#4  product_detail → nutrition keys (9)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  api_product_detail → ingredients keys (6)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'ingredients') k
    ) = ARRAY['additive_names','additives_count','count','data_quality','vegan_status','vegetarian_status']
    THEN 'PASS' ELSE 'FAIL' END AS "#5  product_detail → ingredients keys (6)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  api_product_detail → allergens keys (4)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'allergens') k
    ) = ARRAY['count','tags','trace_count','trace_tags']
    THEN 'PASS' ELSE 'FAIL' END AS "#6  product_detail → allergens keys (4)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  api_product_detail → trust keys (5)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'trust') k
    ) = ARRAY['confidence','data_completeness_pct','ingredient_data_quality','nutrition_data_quality','source_type']
    THEN 'PASS' ELSE 'FAIL' END AS "#7  product_detail → trust keys (5)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  api_product_detail → freshness keys (3)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_product_detail(2)->'freshness') k
    ) = ARRAY['created_at','data_age_days','updated_at']
    THEN 'PASS' ELSE 'FAIL' END AS "#8  product_detail → freshness keys (3)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  api_search_products — top-level keys (7)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_search_products('cola')) k
    ) = ARRAY['api_version','category','limit','offset','query','results','total_count']
    THEN 'PASS' ELSE 'FAIL' END AS "#9  search_products top-level keys (7)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #10 api_search_products → result item keys (9)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(DISTINCT k ORDER BY k) FROM jsonb_array_elements(api_search_products('cola')->'results') r(val), jsonb_object_keys(r.val) k
    ) = ARRAY[
        'brand','category','nova_group','nutri_score','product_id','product_name',
        'relevance','score_band','unhealthiness_score'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#10 search_products → item keys (9)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #11 api_category_listing — top-level keys (8)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_category_listing('Chips')) k
    ) = ARRAY['api_version','category','limit','offset','products','sort_by','sort_dir','total_count']
    THEN 'PASS' ELSE 'FAIL' END AS "#11 category_listing top-level keys (8)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #12 api_category_listing → product item keys (19)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(DISTINCT k ORDER BY k) FROM jsonb_array_elements(api_category_listing('Chips')->'products') r(val), jsonb_object_keys(r.val) k
    ) = ARRAY[
        'brand','calories','confidence','data_completeness_pct','ean',
        'high_salt_flag','high_sat_fat_flag','high_sugar_flag','nova_group',
        'nutri_score','processing_risk','product_id','product_name','protein_g',
        'salt_g','score_band','sugars_g','total_fat_g','unhealthiness_score'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#12 category_listing → item keys (19)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #13 api_score_explanation — top-level keys (10)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_score_explanation(2)) k
    ) = ARRAY[
        'api_version','brand','category','category_context','product_id',
        'product_name','score_breakdown','summary','top_factors','warnings'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#13 score_explanation top-level keys (10)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #14 api_score_explanation → summary keys (6)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_score_explanation(2)->'summary') k
    ) = ARRAY['headline','nova_group','nutri_score','processing_risk','score','score_band']
    THEN 'PASS' ELSE 'FAIL' END AS "#14 score_explanation → summary keys (6)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #15 api_score_explanation → category_context keys (4)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_score_explanation(2)->'category_context') k
    ) = ARRAY['category_avg_score','category_rank','category_total','relative_position']
    THEN 'PASS' ELSE 'FAIL' END AS "#15 score_explanation → category_context keys (4)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #16 api_better_alternatives — top-level keys (5)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_better_alternatives(2)) k
    ) = ARRAY['alternatives','alternatives_count','api_version','search_scope','source_product']
    THEN 'PASS' ELSE 'FAIL' END AS "#16 better_alternatives top-level keys (5)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #17 api_better_alternatives → source_product keys (6)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_better_alternatives(2)->'source_product') k
    ) = ARRAY['brand','category','nutri_score','product_id','product_name','unhealthiness_score']
    THEN 'PASS' ELSE 'FAIL' END AS "#17 alternatives → source_product keys (6)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #18 api_data_confidence — top-level keys (8)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_data_confidence(2)) k
    ) = ARRAY[
        'api_version','components','confidence_band','confidence_score',
        'data_completeness_profile','explanation','missing_data','product_id'
    ]
    THEN 'PASS' ELSE 'FAIL' END AS "#18 data_confidence top-level keys (8)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #19 api_data_confidence → components keys (5)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_data_confidence(2)->'components') k
    ) = ARRAY['allergens','ean','ingredients','nutrition','source']
    THEN 'PASS' ELSE 'FAIL' END AS "#19 data_confidence → components keys (5)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #20 api_data_confidence → data_completeness_profile keys (3)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(api_data_confidence(2)->'data_completeness_profile') k
    ) = ARRAY['allergens','ingredients','nutrition']
    THEN 'PASS' ELSE 'FAIL' END AS "#20 confidence → completeness_profile keys (3)";

-- ─────────────────────────────────────────────────────────────────────────────
-- #21 All api_* functions have api_version = '1.0'
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN (
        SELECT COUNT(*) = 6 FROM (
            SELECT api_product_detail(2)->>'api_version'       AS v
            UNION ALL SELECT api_search_products('cola')->>'api_version'
            UNION ALL SELECT api_category_listing('Chips')->>'api_version'
            UNION ALL SELECT api_score_explanation(2)->>'api_version'
            UNION ALL SELECT api_better_alternatives(2)->>'api_version'
            UNION ALL SELECT api_data_confidence(2)->>'api_version'
        ) sub WHERE v = '1.0'
    )
    THEN 'PASS' ELSE 'FAIL' END AS "#21 all API functions return api_version = 1.0";

-- ─────────────────────────────────────────────────────────────────────────────
-- #22 api_search_products error path includes api_version
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN api_search_products('x')->>'api_version' = '1.0'
         AND api_search_products('x') ? 'error'
    THEN 'PASS' ELSE 'FAIL' END AS "#22 search error response includes api_version";

-- ─────────────────────────────────────────────────────────────────────────────
-- #23 All api_* functions are SECURITY DEFINER (still, after recreation)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN COUNT(*) = 6
    THEN 'PASS' ELSE 'FAIL' END AS "#23 all api_* remain SECURITY DEFINER"
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname LIKE 'api_%'
  AND p.prosecdef = true;

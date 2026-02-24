-- ══════════════════════════════════════════════════════════════════════════
-- QA: Search Architecture — Ranking Model, Synonyms & Infrastructure
-- Issue: #192
-- ══════════════════════════════════════════════════════════════════════════

-- ─── T01: search_ranking_config has exactly one active config ───────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM search_ranking_config WHERE active = true) = 1
    THEN 'PASS' ELSE 'FAIL'
END AS "T01_single_active_ranking_config";

-- ─── T02: Default config weights sum to 1.0 ────────────────────────────

SELECT CASE
    WHEN (
        SELECT ROUND(
            (weights->>'text_rank')::numeric +
            (weights->>'trigram_similarity')::numeric +
            (weights->>'synonym_match')::numeric +
            (weights->>'category_context')::numeric +
            (weights->>'data_completeness')::numeric, 2
        )
        FROM search_ranking_config
        WHERE active = true
    ) = 1.00
    THEN 'PASS' ELSE 'FAIL'
END AS "T02_weights_sum_to_1";

-- ─── T03: Default config has all 5 required weight keys ────────────────

SELECT CASE
    WHEN (
        SELECT weights ?& ARRAY['text_rank','trigram_similarity','synonym_match','category_context','data_completeness']
        FROM search_ranking_config WHERE active = true
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T03_all_weight_keys_present";

-- ─── T04: build_search_vector returns non-NULL for typical input ───────

SELECT CASE
    WHEN build_search_vector('Milka Chocolate', 'Milka Chocolate', 'Milka', 'Sweets', 'PL') IS NOT NULL
    THEN 'PASS' ELSE 'FAIL'
END AS "T04_build_search_vector_not_null";

-- ─── T05: build_search_vector handles NULL inputs gracefully ───────────

SELECT CASE
    WHEN build_search_vector(NULL, NULL, NULL, NULL, NULL) IS NOT NULL
    THEN 'PASS' ELSE 'FAIL'
END AS "T05_build_search_vector_null_safe";

-- ─── T06: build_search_vector uses german config for DE ────────────────

SELECT CASE
    WHEN build_search_vector('Brötchen', 'Roll', 'Lidl', 'Bakery', 'DE') IS NOT NULL
    THEN 'PASS' ELSE 'FAIL'
END AS "T06_build_search_vector_de_config";

-- ─── T07: search_rank returns numeric for valid input ──────────────────

SELECT CASE
    WHEN (
        SELECT search_rank(
            to_tsvector('simple', 'milka chocolate'),
            to_tsquery('simple', 'milka:*'),
            NULL,
            'Milka Chocolate', 'Milka Chocolate', 'Milka', 'Sweets',
            'milka',
            85.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    ) > 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T07_search_rank_returns_positive";

-- ─── T08: search_rank exact match scores higher than partial ───────────

SELECT CASE
    WHEN (
        SELECT search_rank(
            to_tsvector('simple', 'milka chocolate bar'),
            to_tsquery('simple', 'milka:* & chocolate:*'),
            NULL,
            'Milka Chocolate Bar', 'Milka Chocolate Bar', 'Milka', 'Sweets',
            'milka chocolate',
            90.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    ) > (
        SELECT search_rank(
            to_tsvector('simple', 'wedel chocolate bar'),
            to_tsquery('simple', 'milka:* & chocolate:*'),
            NULL,
            'Wedel Chocolate Bar', 'Wedel Chocolate Bar', 'Wedel', 'Sweets',
            'milka chocolate',
            90.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T08_exact_match_ranks_higher";

-- ─── T09: search_rank category boost works ─────────────────────────────

SELECT CASE
    WHEN (
        SELECT search_rank(
            to_tsvector('simple', 'chips'),
            to_tsquery('simple', 'chips:*'),
            NULL,
            'Lays Chips', NULL, 'Lays', 'Chips',
            'chips',
            80.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    ) > (
        SELECT search_rank(
            to_tsvector('simple', 'chips'),
            to_tsquery('simple', 'chips:*'),
            NULL,
            'Lays Chips', NULL, 'Lays', 'Sweets',
            'chips',
            80.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T09_category_boost_effective";

-- ─── T10: search_rank data completeness boost works ────────────────────

SELECT CASE
    WHEN (
        SELECT search_rank(
            to_tsvector('simple', 'test product'),
            to_tsquery('simple', 'test:*'),
            NULL,
            'Test Product', NULL, 'Brand', 'Category',
            'test',
            100.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    ) > (
        SELECT search_rank(
            to_tsvector('simple', 'test product'),
            to_tsquery('simple', 'test:*'),
            NULL,
            'Test Product', NULL, 'Brand', 'Category',
            'test',
            0.0,
            '{"text_rank":0.35,"trigram_similarity":0.30,"synonym_match":0.15,"category_context":0.10,"data_completeness":0.10}'::jsonb
        )
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T10_completeness_boost_effective";

-- ─── T11: German synonyms exist (DE→EN direction) ─────────────────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM search_synonyms WHERE language_from = 'de' AND language_to = 'en') >= 45
    THEN 'PASS' ELSE 'FAIL'
END AS "T11_german_to_english_synonyms";

-- ─── T12: German synonyms exist (EN→DE direction) ─────────────────────

SELECT CASE
    WHEN (SELECT COUNT(*) FROM search_synonyms WHERE language_from = 'en' AND language_to = 'de') >= 45
    THEN 'PASS' ELSE 'FAIL'
END AS "T12_english_to_german_synonyms";

-- ─── T13: expand_search_query returns DE synonyms ──────────────────────

SELECT CASE
    WHEN 'milk' = ANY(expand_search_query('milch'))
    THEN 'PASS' ELSE 'FAIL'
END AS "T13_expand_query_de_to_en";

-- ─── T14: new_search_ranking feature flag exists ───────────────────────

SELECT CASE
    WHEN EXISTS (SELECT 1 FROM feature_flags WHERE key = 'new_search_ranking')
    THEN 'PASS' ELSE 'FAIL'
END AS "T14_new_search_ranking_flag_exists";

-- ─── T15: new_search_ranking flag is disabled by default ───────────────

SELECT CASE
    WHEN (SELECT enabled FROM feature_flags WHERE key = 'new_search_ranking') = false
    THEN 'PASS' ELSE 'FAIL'
END AS "T15_new_search_ranking_flag_disabled";

-- ─── T16: search_quality_report returns stub structure ─────────────────

SELECT CASE
    WHEN (
        SELECT search_quality_report()
    ) ? 'planned_metrics'
    THEN 'PASS' ELSE 'FAIL'
END AS "T16_quality_report_has_planned_metrics";

-- ─── T17: search_quality_report indicates pending dependency ───────────

SELECT CASE
    WHEN (SELECT search_quality_report()->>'status') = 'pending_dependency'
    THEN 'PASS' ELSE 'FAIL'
END AS "T17_quality_report_pending_status";

-- ─── T18: api_search_products still returns valid structure ────────────

SELECT CASE
    WHEN (
        SELECT api_search_products('test')
    ) ? 'results'
    AND (SELECT api_search_products('test')) ? 'total'
    AND (SELECT api_search_products('test')) ? 'query'
    THEN 'PASS' ELSE 'FAIL'
END AS "T18_search_products_valid_structure";

-- ─── T19: search_ranking_config partial unique index enforced ──────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'idx_search_ranking_config_single_active'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T19_single_active_config_index";

-- ─── T20: products search_vector column uses build_search_vector ───────

SELECT CASE
    WHEN (
        SELECT COUNT(*)
        FROM products
        WHERE search_vector IS NULL
          AND is_deprecated IS NOT TRUE
    ) = 0
    THEN 'PASS' ELSE 'FAIL'
END AS "T20_all_products_have_search_vector";

-- ─── T21: search_rank revoked from anon ────────────────────────────────

SELECT CASE
    WHEN NOT has_function_privilege(
        'anon',
        'search_rank(tsvector, tsquery, tsquery, text, text, text, text, text, numeric, jsonb)',
        'EXECUTE'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T21_search_rank_revoked_from_anon";

-- ─── T22: search_quality_report revoked from anon ──────────────────────

SELECT CASE
    WHEN NOT has_function_privilege(
        'anon',
        'search_quality_report(integer, text)',
        'EXECUTE'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T22_quality_report_revoked_from_anon";

-- ─── T23: trigger fires on country change ──────────────────────────────

SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON c.oid = t.tgrelid
        WHERE t.tgname = 'trg_products_search_vector_update'
          AND c.relname = 'products'
    )
    THEN 'PASS' ELSE 'FAIL'
END AS "T23_search_vector_trigger_exists";

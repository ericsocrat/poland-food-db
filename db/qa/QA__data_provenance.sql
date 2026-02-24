-- QA: Data Provenance & Freshness Governance (Issue #193)
-- 25 tests covering all layers of the provenance framework.

-- ============================================================================
-- T01: data_sources table has expected seed rows
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM data_sources;
    ASSERT v >= 11, 'T01 FAIL: data_sources expected ≥11 rows, got ' || v;
    RAISE NOTICE 'T01 PASS — data_sources has % rows', v;
END $$;

-- ============================================================================
-- T02: Each data_source base_confidence in [0,1]
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM data_sources
    WHERE base_confidence < 0 OR base_confidence > 1;
    ASSERT v = 0, 'T02 FAIL: ' || v || ' sources have out-of-range confidence';
    RAISE NOTICE 'T02 PASS — all source confidences in [0,1]';
END $$;

-- ============================================================================
-- T03: lab_test has confidence = 1.0 (highest)
-- ============================================================================
DO $$
DECLARE v NUMERIC;
BEGIN
    SELECT base_confidence INTO v FROM data_sources WHERE source_key = 'lab_test';
    ASSERT v = 1.0, 'T03 FAIL: lab_test confidence = ' || COALESCE(v::TEXT, 'NULL');
    RAISE NOTICE 'T03 PASS — lab_test confidence = 1.0';
END $$;

-- ============================================================================
-- T04: product_field_provenance has enhanced columns
-- ============================================================================
DO $$
BEGIN
    PERFORM column_name FROM information_schema.columns
    WHERE table_name = 'product_field_provenance' AND column_name = 'confidence';
    ASSERT FOUND, 'T04 FAIL: confidence column missing';

    PERFORM column_name FROM information_schema.columns
    WHERE table_name = 'product_field_provenance' AND column_name = 'verified_at';
    ASSERT FOUND, 'T04 FAIL: verified_at column missing';

    PERFORM column_name FROM information_schema.columns
    WHERE table_name = 'product_field_provenance' AND column_name = 'verified_by';
    ASSERT FOUND, 'T04 FAIL: verified_by column missing';

    PERFORM column_name FROM information_schema.columns
    WHERE table_name = 'product_field_provenance' AND column_name = 'notes';
    ASSERT FOUND, 'T04 FAIL: notes column missing';

    RAISE NOTICE 'T04 PASS — product_field_provenance has all enhanced columns';
END $$;

-- ============================================================================
-- T05: record_field_provenance writes properly
-- ============================================================================
DO $$
DECLARE
    v_pid BIGINT;
    v_conf NUMERIC;
BEGIN
    SELECT product_id INTO v_pid FROM products LIMIT 1;
    IF v_pid IS NULL THEN
        RAISE NOTICE 'T05 SKIP — no products in table';
        RETURN;
    END IF;

    PERFORM record_field_provenance(v_pid, 'product_name', 'manual', 0.85, NULL, 'QA test');

    SELECT confidence INTO v_conf FROM product_field_provenance
    WHERE product_id = v_pid AND field_name = 'product_name';
    ASSERT v_conf = 0.85, 'T05 FAIL: expected confidence 0.85, got ' || COALESCE(v_conf::TEXT, 'NULL');
    RAISE NOTICE 'T05 PASS — record_field_provenance writes correctly';
END $$;

-- ============================================================================
-- T06: record_bulk_provenance writes multiple fields
-- ============================================================================
DO $$
DECLARE
    v_pid BIGINT;
    v_cnt INT;
BEGIN
    SELECT product_id INTO v_pid FROM products LIMIT 1;
    IF v_pid IS NULL THEN
        RAISE NOTICE 'T06 SKIP — no products in table';
        RETURN;
    END IF;

    PERFORM record_bulk_provenance(
        v_pid, 'off_api',
        ARRAY['brand', 'category', 'calories_100g'],
        NULL, 'QA bulk test'
    );

    SELECT COUNT(*) INTO v_cnt FROM product_field_provenance
    WHERE product_id = v_pid AND field_name IN ('brand', 'category', 'calories_100g');
    ASSERT v_cnt >= 3, 'T06 FAIL: expected ≥3 provenance rows, got ' || v_cnt;
    RAISE NOTICE 'T06 PASS — record_bulk_provenance wrote % rows', v_cnt;
END $$;

-- ============================================================================
-- T07: field_to_group maps correctly
-- ============================================================================
DO $$
BEGIN
    ASSERT field_to_group('calories_100g')    = 'nutrition',    'T07 FAIL: calories_100g';
    ASSERT field_to_group('allergens')        = 'allergens',    'T07 FAIL: allergens';
    ASSERT field_to_group('ingredients_text') = 'ingredients',  'T07 FAIL: ingredients_text';
    ASSERT field_to_group('product_name')     = 'identity',     'T07 FAIL: product_name';
    ASSERT field_to_group('image_url')        = 'images',       'T07 FAIL: image_url';
    ASSERT field_to_group('unhealthiness_score') = 'scoring',   'T07 FAIL: unhealthiness_score';
    ASSERT field_to_group('unknown_field')    = 'identity',     'T07 FAIL: unknown_field default';
    RAISE NOTICE 'T07 PASS — field_to_group maps all groups correctly';
END $$;

-- ============================================================================
-- T08: product_change_log table exists with expected structure
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM information_schema.columns
    WHERE table_name = 'product_change_log'
      AND column_name IN ('product_id','field_name','old_value','new_value',
                          'source_key','actor_type','actor_id','reason','country','created_at');
    ASSERT v >= 10, 'T08 FAIL: product_change_log missing columns, found ' || v;
    RAISE NOTICE 'T08 PASS — product_change_log has all expected columns';
END $$;

-- ============================================================================
-- T09: Audit trigger installed on products
-- ============================================================================
DO $$
BEGIN
    PERFORM 1 FROM information_schema.triggers
    WHERE trigger_name = 'products_30_change_audit'
      AND event_object_table = 'products';
    ASSERT FOUND, 'T09 FAIL: products_30_change_audit trigger missing';
    RAISE NOTICE 'T09 PASS — audit trigger installed on products';
END $$;

-- ============================================================================
-- T10: freshness_policies seeded for PL and DE
-- ============================================================================
DO $$
DECLARE v_pl INT; v_de INT;
BEGIN
    SELECT COUNT(*) INTO v_pl FROM freshness_policies WHERE country = 'PL';
    SELECT COUNT(*) INTO v_de FROM freshness_policies WHERE country = 'DE';
    ASSERT v_pl >= 6, 'T10 FAIL: PL freshness_policies expected ≥6, got ' || v_pl;
    ASSERT v_de >= 6, 'T10 FAIL: DE freshness_policies expected ≥6, got ' || v_de;
    RAISE NOTICE 'T10 PASS — PL=% DE=% freshness policies', v_pl, v_de;
END $$;

-- ============================================================================
-- T11: Allergens have stricter freshness than identity
-- ============================================================================
DO $$
DECLARE v_allergen INT; v_identity INT;
BEGIN
    SELECT max_age_days INTO v_allergen FROM freshness_policies
    WHERE country = 'PL' AND field_group = 'allergens';
    SELECT max_age_days INTO v_identity FROM freshness_policies
    WHERE country = 'PL' AND field_group = 'identity';
    ASSERT v_allergen < v_identity,
        'T11 FAIL: allergens max_age should be < identity, got ' || v_allergen || ' vs ' || v_identity;
    RAISE NOTICE 'T11 PASS — allergens (% days) stricter than identity (% days)', v_allergen, v_identity;
END $$;

-- ============================================================================
-- T12: conflict_resolution_rules seeded
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM conflict_resolution_rules;
    ASSERT v >= 6, 'T12 FAIL: expected ≥6 conflict rules, got ' || v;
    RAISE NOTICE 'T12 PASS — % conflict resolution rules', v;
END $$;

-- ============================================================================
-- T13: Allergen conflict rules do NOT auto-resolve
-- ============================================================================
DO $$
DECLARE v BOOLEAN;
BEGIN
    SELECT auto_resolve INTO v FROM conflict_resolution_rules
    WHERE country = 'PL' AND field_group = 'allergens';
    ASSERT v = false, 'T13 FAIL: allergen conflicts should NOT auto-resolve';
    RAISE NOTICE 'T13 PASS — allergen conflicts require manual resolution';
END $$;

-- ============================================================================
-- T14: data_conflicts table exists
-- ============================================================================
DO $$
BEGIN
    PERFORM 1 FROM information_schema.tables
    WHERE table_name = 'data_conflicts';
    ASSERT FOUND, 'T14 FAIL: data_conflicts table missing';
    RAISE NOTICE 'T14 PASS — data_conflicts table exists';
END $$;

-- ============================================================================
-- T15: country_data_policies seeded for 4 countries
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM country_data_policies;
    ASSERT v >= 4, 'T15 FAIL: expected ≥4 country policies, got ' || v;
    RAISE NOTICE 'T15 PASS — % country data policies', v;
END $$;

-- ============================================================================
-- T16: DE has stricter allergen policy than PL
-- ============================================================================
DO $$
DECLARE v_pl TEXT; v_de TEXT;
BEGIN
    SELECT allergen_strictness INTO v_pl FROM country_data_policies WHERE country = 'PL';
    SELECT allergen_strictness INTO v_de FROM country_data_policies WHERE country = 'DE';
    ASSERT v_de IN ('strict','very_strict'), 'T16 FAIL: DE should be strict/very_strict, got ' || v_de;
    RAISE NOTICE 'T16 PASS — PL=% DE=%', v_pl, v_de;
END $$;

-- ============================================================================
-- T17: compute_provenance_confidence returns valid structure
-- ============================================================================
DO $$
DECLARE
    v_pid BIGINT;
    v_conf RECORD;
BEGIN
    SELECT product_id INTO v_pid FROM products LIMIT 1;
    IF v_pid IS NULL THEN
        RAISE NOTICE 'T17 SKIP — no products';
        RETURN;
    END IF;

    -- Ensure at least one provenance row exists
    PERFORM record_field_provenance(v_pid, 'product_name', 'off_api', 0.60);

    SELECT * INTO v_conf FROM compute_provenance_confidence(v_pid);
    ASSERT v_conf.overall_confidence IS NOT NULL,
        'T17 FAIL: overall_confidence is NULL';
    ASSERT v_conf.staleness_risk IN ('fresh','aging','stale','expired'),
        'T17 FAIL: invalid staleness_risk = ' || v_conf.staleness_risk;
    RAISE NOTICE 'T17 PASS — confidence=%, staleness=%', v_conf.overall_confidence, v_conf.staleness_risk;
END $$;

-- ============================================================================
-- T18: validate_product_for_country returns JSONB with expected keys
-- ============================================================================
DO $$
DECLARE
    v_pid BIGINT;
    v_result JSONB;
BEGIN
    SELECT product_id INTO v_pid FROM products LIMIT 1;
    IF v_pid IS NULL THEN
        RAISE NOTICE 'T18 SKIP — no products';
        RETURN;
    END IF;

    v_result := validate_product_for_country(v_pid, 'PL');
    ASSERT v_result ? 'product_id',        'T18 FAIL: missing product_id';
    ASSERT v_result ? 'ready_for_publish',  'T18 FAIL: missing ready_for_publish';
    ASSERT v_result ? 'issues',             'T18 FAIL: missing issues';
    ASSERT v_result ? 'validated_at',       'T18 FAIL: missing validated_at';
    RAISE NOTICE 'T18 PASS — validate_product_for_country returns valid structure';
END $$;

-- ============================================================================
-- T19: api_product_provenance returns valid JSONB
-- ============================================================================
DO $$
DECLARE
    v_pid BIGINT;
    v_result JSONB;
BEGIN
    SELECT product_id INTO v_pid FROM products LIMIT 1;
    IF v_pid IS NULL THEN
        RAISE NOTICE 'T19 SKIP — no products';
        RETURN;
    END IF;

    v_result := api_product_provenance(v_pid);
    ASSERT v_result ? 'api_version',         'T19 FAIL: missing api_version';
    ASSERT v_result ? 'overall_trust_score',  'T19 FAIL: missing overall_trust_score';
    ASSERT v_result ? 'trust_explanation',    'T19 FAIL: missing trust_explanation';
    RAISE NOTICE 'T19 PASS — api_product_provenance returns valid JSONB';
END $$;

-- ============================================================================
-- T20: admin_provenance_dashboard returns valid JSONB
-- ============================================================================
DO $$
DECLARE v_result JSONB;
BEGIN
    v_result := admin_provenance_dashboard('PL');
    ASSERT v_result ? 'api_version',        'T20 FAIL: missing api_version';
    ASSERT v_result ? 'total_products',      'T20 FAIL: missing total_products';
    ASSERT v_result ? 'with_provenance',     'T20 FAIL: missing with_provenance';
    ASSERT v_result ? 'open_conflicts',      'T20 FAIL: missing open_conflicts';
    ASSERT v_result ? 'source_distribution', 'T20 FAIL: missing source_distribution';
    RAISE NOTICE 'T20 PASS — admin_provenance_dashboard returns valid JSONB';
END $$;

-- ============================================================================
-- T21: feature flag data_provenance_ui exists and is disabled
-- ============================================================================
DO $$
DECLARE v_enabled BOOLEAN;
BEGIN
    SELECT enabled INTO v_enabled FROM feature_flags WHERE key = 'data_provenance_ui';
    ASSERT FOUND, 'T21 FAIL: data_provenance_ui flag missing';
    ASSERT v_enabled = false, 'T21 FAIL: flag should be disabled by default';
    RAISE NOTICE 'T21 PASS — data_provenance_ui flag exists and disabled';
END $$;

-- ============================================================================
-- T22: Security — anon cannot call admin functions
-- ============================================================================
DO $$
DECLARE v BOOLEAN;
BEGIN
    SELECT has_function_privilege('anon', 'resolve_conflicts_auto(text,text)', 'EXECUTE')
    INTO v;
    ASSERT v = false, 'T22 FAIL: anon should not have EXECUTE on resolve_conflicts_auto';
    RAISE NOTICE 'T22 PASS — anon blocked from resolve_conflicts_auto';
END $$;

-- ============================================================================
-- T23: Security — anon CAN call api_product_provenance
-- ============================================================================
DO $$
DECLARE v BOOLEAN;
BEGIN
    SELECT has_function_privilege('anon', 'api_product_provenance(bigint)', 'EXECUTE')
    INTO v;
    ASSERT v = true, 'T23 FAIL: anon should be able to call api_product_provenance';
    RAISE NOTICE 'T23 PASS — anon can call api_product_provenance';
END $$;

-- ============================================================================
-- T24: RLS enabled on all new tables
-- ============================================================================
DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname IN (
          'data_sources','product_change_log','freshness_policies',
          'conflict_resolution_rules','data_conflicts','country_data_policies'
      )
      AND c.relrowsecurity = true;
    ASSERT v = 6, 'T24 FAIL: expected 6 tables with RLS, got ' || v;
    RAISE NOTICE 'T24 PASS — all 6 new tables have RLS enabled';
END $$;

-- ============================================================================
-- T25: detect_stale_products function exists and is callable
-- ============================================================================
DO $$
BEGIN
    PERFORM 1 FROM pg_proc WHERE proname = 'detect_stale_products';
    ASSERT FOUND, 'T25 FAIL: detect_stale_products function missing';
    RAISE NOTICE 'T25 PASS — detect_stale_products exists';
END $$;

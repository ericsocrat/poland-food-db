-- ============================================================================
-- Migration:  20260312000300_trigger_optimization.sql
-- Issue:      #374 — Merge & optimize products table triggers
-- Purpose:    1. Merge 2 overlapping score triggers into 1 unified trigger
--             2. Fix change log tracked fields (remove 13 non-existent columns)
--             3. Search vector guard — already implemented at trigger level (no changes)
-- Result:     Products triggers: 5 → 4 | Total DB triggers: 16 → 15
--             Tracked fields: 25 → 13 (eliminates 13 silent exception catches per row)
-- Rollback:   Run the function definitions from the original migrations:
--             - 20260225000000_canonical_scoring_engine.sql (trg_score_audit)
--             - 20260220000300_score_history_watchlist.sql  (record_score_change)
--             - 20260227000000_data_provenance.sql          (trg_product_change_log)
--             Then recreate the two dropped triggers:
--             CREATE TRIGGER trg_products_score_audit AFTER UPDATE ON products
--               FOR EACH ROW EXECUTE FUNCTION trg_score_audit();
--             CREATE TRIGGER trg_products_score_history AFTER UPDATE OF unhealthiness_score
--               ON products FOR EACH ROW EXECUTE FUNCTION record_score_change();
--             DROP TRIGGER IF EXISTS trg_products_score_unified ON products;
-- ============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 1: Merge overlapping score triggers (2 → 1)                      ║
-- ║  trg_score_audit + record_score_change → trg_unified_score_change       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- The merged function writes to BOTH score_audit_log and product_score_history
-- in a single trigger invocation, eliminating one trigger execution per row.

CREATE OR REPLACE FUNCTION public.trg_unified_score_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
    IF OLD.unhealthiness_score IS DISTINCT FROM NEW.unhealthiness_score THEN
        -- 1) Score audit log (field-level audit trail)
        INSERT INTO score_audit_log
            (product_id, field_name, old_value, new_value,
             model_version, country, trigger_type)
        VALUES (
            NEW.product_id,
            'unhealthiness_score',
            OLD.unhealthiness_score::text,
            NEW.unhealthiness_score::text,
            COALESCE(NEW.score_model_version, 'v3.2'),
            COALESCE(NEW.country, 'PL'),
            COALESCE(current_setting('app.score_trigger', true), 'pipeline')
        );

        -- 2) Score history snapshot (only when new score is not null)
        IF NEW.unhealthiness_score IS NOT NULL THEN
            INSERT INTO product_score_history (
                product_id, unhealthiness_score, nutri_score_label,
                nova_group, data_completeness_pct, score_delta, trigger_source
            ) VALUES (
                NEW.product_id,
                NEW.unhealthiness_score,
                NEW.nutri_score_label,
                NEW.nova_classification,
                NEW.data_completeness_pct,
                NEW.unhealthiness_score - COALESCE(OLD.unhealthiness_score, NEW.unhealthiness_score),
                'pipeline'
            )
            ON CONFLICT (product_id, recorded_at) DO UPDATE SET
                unhealthiness_score   = EXCLUDED.unhealthiness_score,
                nutri_score_label     = EXCLUDED.nutri_score_label,
                nova_group            = EXCLUDED.nova_group,
                data_completeness_pct = EXCLUDED.data_completeness_pct,
                score_delta           = EXCLUDED.score_delta;
        END IF;
    END IF;
    RETURN NEW;
END;
$function$;

-- Drop the two old triggers
DROP TRIGGER IF EXISTS trg_products_score_audit   ON products;
DROP TRIGGER IF EXISTS trg_products_score_history ON products;

-- Create the unified trigger (fires on unhealthiness_score changes only)
CREATE TRIGGER trg_products_score_unified
    AFTER UPDATE OF unhealthiness_score ON products
    FOR EACH ROW EXECUTE FUNCTION trg_unified_score_change();


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 2: Fix change log tracked fields (25 → 13)                      ║
-- ║  Remove 13 columns that don't exist on `products` table                 ║
-- ║  Fix column name: ingredient_concern_level → ingredient_concern_score   ║
-- ║  Add nova_classification (scoring-relevant, was missing)                ║
-- ║  Eliminates EXCEPTION WHEN undefined_column handler overhead            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.trg_product_change_log()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    v_field TEXT;
    -- Only columns that actually exist on the products table (13 fields).
    -- Removed 13 non-existent columns that were silently caught by exception
    -- handler on every row update (calories_100g, fat_100g, saturated_fat_100g,
    -- carbs_100g, sugars_100g, fiber_100g, protein_100g, salt_100g,
    -- trans_fat_100g, ingredients_text, allergens, additives, image_url).
    -- Fixed: ingredient_concern_level → ingredient_concern_score.
    -- Added: nova_classification (scoring-relevant).
    v_tracked_fields TEXT[] := ARRAY[
        'product_name', 'product_name_en', 'brand', 'category',
        'nutri_score_label', 'unhealthiness_score', 'nova_classification',
        'prep_method', 'controversies', 'ingredient_concern_score',
        'source_type', 'confidence', 'data_completeness_pct'
    ];
    v_old_val JSONB;
    v_new_val JSONB;
BEGIN
    FOREACH v_field IN ARRAY v_tracked_fields
    LOOP
        EXECUTE format('SELECT to_jsonb($1.%I), to_jsonb($2.%I)', v_field, v_field)
            INTO v_old_val, v_new_val USING OLD, NEW;

        IF v_old_val IS DISTINCT FROM v_new_val THEN
            INSERT INTO product_change_log (
                product_id, field_name, old_value, new_value,
                source_key, actor_type, actor_id, country
            ) VALUES (
                NEW.product_id, v_field, v_old_val, v_new_val,
                NEW.source_type,
                COALESCE(current_setting('app.actor_type', true), 'system'),
                current_setting('app.actor_id', true),
                COALESCE(NEW.country, 'PL')
            );
        END IF;
    END LOOP;

    RETURN NEW;
END;
$function$;

-- Note: The products_30_change_audit trigger already exists and points to
-- trg_product_change_log(). No trigger recreation needed — CREATE OR REPLACE
-- automatically updates the function the trigger calls.

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 3: Search vector guard — NO CHANGES NEEDED                      ║
-- ║  Already implemented at trigger level:                                  ║
-- ║  trg_products_search_vector_update fires only on                        ║
-- ║  INSERT OR UPDATE OF product_name, product_name_en, brand, category,    ║
-- ║  country — scoring-only updates skip it automatically.                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Verification                                                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

DO $$
DECLARE
    v_count INT;
BEGIN
    -- Verify unified trigger exists
    SELECT COUNT(*) INTO v_count
    FROM pg_trigger
    WHERE tgname = 'trg_products_score_unified'
      AND tgrelid = 'products'::regclass;
    ASSERT v_count = 1, 'trg_products_score_unified trigger not found';

    -- Verify old triggers are gone
    SELECT COUNT(*) INTO v_count
    FROM pg_trigger
    WHERE tgname IN ('trg_products_score_audit', 'trg_products_score_history')
      AND tgrelid = 'products'::regclass;
    ASSERT v_count = 0, 'Old score triggers still exist: expected 0, got ' || v_count;

    -- Verify change audit trigger still exists
    SELECT COUNT(*) INTO v_count
    FROM pg_trigger
    WHERE tgname = 'products_30_change_audit'
      AND tgrelid = 'products'::regclass;
    ASSERT v_count = 1, 'products_30_change_audit trigger missing';

    -- Verify total trigger count on products is 4 (was 5)
    SELECT COUNT(*) INTO v_count
    FROM pg_trigger
    WHERE tgrelid = 'products'::regclass
      AND NOT tgisinternal;
    ASSERT v_count = 4, 'Expected 4 triggers on products, found ' || v_count;

    RAISE NOTICE '✅ Trigger optimization verified: 5 → 4 triggers on products';
    RAISE NOTICE '✅ Unified score trigger active, old score triggers removed';
    RAISE NOTICE '✅ Change log function updated: 25 → 13 tracked fields';
END $$;

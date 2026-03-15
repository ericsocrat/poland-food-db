-- ═══════════════════════════════════════════════════════════════════════════════
-- Fix: compute_health_warnings — use >= for custom threshold comparisons
-- ═══════════════════════════════════════════════════════════════════════════════
-- Issue #887
-- Bug: Custom threshold comparisons used > instead of >=, causing products
--      with values exactly at the user's threshold to silently pass.
-- Fix:  4 comparisons changed from > to >= (sugar, salt, saturated fat, calories).
-- Rollback: Re-run the previous CREATE OR REPLACE from migration
--           20260215000100_health_profile_hardening.sql
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.compute_health_warnings(
    p_product_id bigint,
    p_profile_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id      uuid := auth.uid();
    v_profile      record;
    v_product      record;
    v_nutrition    record;
    v_warnings     jsonb := '[]'::jsonb;
    v_high_sugar   boolean;
    v_high_salt    boolean;
    v_high_sat_fat boolean;
BEGIN
    -- Resolve profile: explicit or active
    IF p_profile_id IS NOT NULL THEN
        SELECT * INTO v_profile
        FROM public.user_health_profiles
        WHERE profile_id = p_profile_id AND user_id = v_user_id;
    ELSE
        SELECT * INTO v_profile
        FROM public.user_health_profiles
        WHERE user_id = v_user_id AND is_active = true
        LIMIT 1;
    END IF;

    IF v_profile IS NULL THEN
        RETURN '[]'::jsonb;
    END IF;

    -- Get product data
    SELECT p.product_id, p.high_salt_flag, p.high_sugar_flag,
           p.high_sat_fat_flag, p.nova_classification
    INTO v_product
    FROM products p
    WHERE p.product_id = p_product_id
      AND p.is_deprecated IS NOT TRUE;

    IF v_product IS NULL THEN
        RETURN '[]'::jsonb;
    END IF;

    v_high_sugar   := (UPPER(COALESCE(v_product.high_sugar_flag, '')) = 'YES');
    v_high_salt    := (UPPER(COALESCE(v_product.high_salt_flag, '')) = 'YES');
    v_high_sat_fat := (UPPER(COALESCE(v_product.high_sat_fat_flag, '')) = 'YES');

    -- Get nutrition per 100g
    SELECT nf.calories, nf.sugars_g, nf.salt_g, nf.saturated_fat_g, nf.protein_g
    INTO v_nutrition
    FROM nutrition_facts nf
    WHERE nf.product_id = p_product_id
    LIMIT 1;

    -- ── Condition-based warnings ──

    -- Diabetes: high sugar, high carbs
    IF 'diabetes' = ANY(v_profile.health_conditions) THEN
        IF v_high_sugar THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'diabetes',
                'severity', 'high',
                'message', 'High sugar content — monitor blood glucose'
            );
        END IF;
        IF v_nutrition IS NOT NULL AND v_nutrition.sugars_g > 10 THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'diabetes',
                'severity', 'moderate',
                'message', format('Contains %.1fg sugar per 100g', v_nutrition.sugars_g)
            );
        END IF;
    END IF;

    -- Hypertension: high salt
    IF 'hypertension' = ANY(v_profile.health_conditions) THEN
        IF v_high_salt THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'hypertension',
                'severity', 'high',
                'message', 'High salt content — limit sodium intake'
            );
        END IF;
        IF v_nutrition IS NOT NULL AND v_nutrition.salt_g > 1.0 THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'hypertension',
                'severity', 'moderate',
                'message', format('Contains %.2fg salt per 100g', v_nutrition.salt_g)
            );
        END IF;
    END IF;

    -- Heart disease: high saturated fat + high salt
    IF 'heart_disease' = ANY(v_profile.health_conditions) THEN
        IF v_high_sat_fat THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'heart_disease',
                'severity', 'high',
                'message', 'High saturated fat — may impact cardiovascular health'
            );
        END IF;
        IF v_high_salt THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'heart_disease',
                'severity', 'moderate',
                'message', 'High salt — may raise blood pressure'
            );
        END IF;
    END IF;

    -- Celiac: check gluten allergen
    IF 'celiac_disease' = ANY(v_profile.health_conditions) THEN
        IF EXISTS (
            SELECT 1 FROM product_allergen_info pai
            WHERE pai.product_id = p_product_id
              AND pai.tag = 'en:gluten'
              AND pai.type = 'contains'
        ) THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'celiac_disease',
                'severity', 'critical',
                'message', 'Contains gluten — unsafe for celiac disease'
            );
        END IF;
    END IF;

    -- Gout: high protein
    IF 'gout' = ANY(v_profile.health_conditions) THEN
        IF v_nutrition IS NOT NULL AND v_nutrition.protein_g > 20 THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'gout',
                'severity', 'moderate',
                'message', format('High protein (%.1fg/100g) — may increase uric acid', v_nutrition.protein_g)
            );
        END IF;
    END IF;

    -- Kidney disease: high protein + high salt
    IF 'kidney_disease' = ANY(v_profile.health_conditions) THEN
        IF v_nutrition IS NOT NULL AND v_nutrition.protein_g > 15 THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'kidney_disease',
                'severity', 'moderate',
                'message', format('Protein: %.1fg/100g — discuss with doctor', v_nutrition.protein_g)
            );
        END IF;
        IF v_high_salt THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'kidney_disease',
                'severity', 'high',
                'message', 'High salt — limit sodium for kidney health'
            );
        END IF;
    END IF;

    -- IBS: ultra-processed NOVA 4
    IF 'ibs' = ANY(v_profile.health_conditions) THEN
        IF v_product.nova_classification::int = 4 THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'ibs',
                'severity', 'moderate',
                'message', 'Ultra-processed (NOVA 4) — may trigger IBS symptoms'
            );
        END IF;
    END IF;

    -- ── Custom threshold warnings (fixed: >= instead of >) ──

    IF v_nutrition IS NOT NULL THEN
        IF v_profile.max_sugar_g IS NOT NULL AND v_nutrition.sugars_g >= v_profile.max_sugar_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Sugar: %.1fg meets or exceeds your limit of %.1fg per 100g',
                                  v_nutrition.sugars_g, v_profile.max_sugar_g)
            );
        END IF;
        IF v_profile.max_salt_g IS NOT NULL AND v_nutrition.salt_g >= v_profile.max_salt_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Salt: %.2fg meets or exceeds your limit of %.2fg per 100g',
                                  v_nutrition.salt_g, v_profile.max_salt_g)
            );
        END IF;
        IF v_profile.max_saturated_fat_g IS NOT NULL AND v_nutrition.saturated_fat_g >= v_profile.max_saturated_fat_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Saturated fat: %.1fg meets or exceeds your limit of %.1fg per 100g',
                                  v_nutrition.saturated_fat_g, v_profile.max_saturated_fat_g)
            );
        END IF;
        IF v_profile.max_calories_kcal IS NOT NULL AND v_nutrition.calories >= v_profile.max_calories_kcal THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'moderate',
                'message', format('Calories: %.0f meets or exceeds your limit of %.0f per 100g',
                                  v_nutrition.calories, v_profile.max_calories_kcal)
            );
        END IF;
    END IF;

    RETURN v_warnings;
END;
$$;

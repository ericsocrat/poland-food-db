-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 5.1 — Health Profile Hardening & Stability
-- ═══════════════════════════════════════════════════════════════════════════════
-- Fixes:
--   1. compute_health_warnings: TEXT flag comparison (= 'YES' not = true)
--   2. Unique partial index enforcing one active profile per user
--   3. api_update_health_profile: explicit clear-to-NULL via p_clear_* flags
--   4. Defensive threshold validation in create/update RPCs
--   5. Upper-bound constraints on nutrient thresholds
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. FIX: compute_health_warnings — correct TEXT flag comparisons ────────
--    Flags (high_sugar_flag, high_salt_flag, high_sat_fat_flag) are TEXT
--    columns storing 'YES'/'NO', not boolean. The original code compared
--    them with = true, which always evaluates false for TEXT columns.

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
    -- Normalized boolean flags (TEXT 'YES' → true, anything else → false)
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

    -- No profile → no warnings
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

    -- Normalize TEXT flags to boolean once
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

    -- ── Custom threshold warnings ──

    IF v_nutrition IS NOT NULL THEN
        IF v_profile.max_sugar_g IS NOT NULL AND v_nutrition.sugars_g > v_profile.max_sugar_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Sugar: %.1fg exceeds your limit of %.1fg per 100g',
                                  v_nutrition.sugars_g, v_profile.max_sugar_g)
            );
        END IF;
        IF v_profile.max_salt_g IS NOT NULL AND v_nutrition.salt_g > v_profile.max_salt_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Salt: %.2fg exceeds your limit of %.2fg per 100g',
                                  v_nutrition.salt_g, v_profile.max_salt_g)
            );
        END IF;
        IF v_profile.max_saturated_fat_g IS NOT NULL AND v_nutrition.saturated_fat_g > v_profile.max_saturated_fat_g THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'high',
                'message', format('Saturated fat: %.1fg exceeds your limit of %.1fg per 100g',
                                  v_nutrition.saturated_fat_g, v_profile.max_saturated_fat_g)
            );
        END IF;
        IF v_profile.max_calories_kcal IS NOT NULL AND v_nutrition.calories > v_profile.max_calories_kcal THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'custom_threshold',
                'severity', 'moderate',
                'message', format('Calories: %.0f exceeds your limit of %.0f per 100g',
                                  v_nutrition.calories, v_profile.max_calories_kcal)
            );
        END IF;
    END IF;

    RETURN v_warnings;
END;
$$;

-- ─── 2. ENFORCE: Unique partial index — one active profile per user ─────────
--    The trigger deactivates other profiles, but is NOT concurrency-safe.
--    This unique partial index guarantees the invariant at the database level.
--    If duplicates already exist, this migration will fail cleanly — the DBA
--    must resolve duplicates before re-running.

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_profile_per_user
    ON public.user_health_profiles (user_id)
    WHERE is_active = true;

-- ─── 3. FIX: api_update_health_profile — allow clearing thresholds to NULL ──
--    Previous version used CASE WHEN p_max_X IS NOT NULL, which made it
--    impossible to clear a threshold back to NULL.
--    New version adds p_clear_max_* BOOLEAN DEFAULT FALSE parameters.
--    Fully backward compatible: existing callers omit the clear flags and
--    continue to work exactly as before.

-- First drop the old function signature so we can recreate with new params
DROP FUNCTION IF EXISTS public.api_update_health_profile(uuid, text, text[], boolean, numeric, numeric, numeric, numeric, text);

CREATE OR REPLACE FUNCTION public.api_update_health_profile(
    p_profile_id            uuid,
    p_profile_name          text        DEFAULT NULL,
    p_health_conditions     text[]      DEFAULT NULL,
    p_is_active             boolean     DEFAULT NULL,
    p_max_sugar_g           numeric     DEFAULT NULL,
    p_max_salt_g            numeric     DEFAULT NULL,
    p_max_saturated_fat_g   numeric     DEFAULT NULL,
    p_max_calories_kcal     numeric     DEFAULT NULL,
    p_notes                 text        DEFAULT NULL,
    -- Explicit clear flags (set to TRUE to clear a threshold to NULL)
    p_clear_max_sugar       boolean     DEFAULT FALSE,
    p_clear_max_salt        boolean     DEFAULT FALSE,
    p_clear_max_sat_fat     boolean     DEFAULT FALSE,
    p_clear_max_calories    boolean     DEFAULT FALSE
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_exists  boolean;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    -- Verify ownership
    SELECT EXISTS(
        SELECT 1 FROM public.user_health_profiles
        WHERE profile_id = p_profile_id AND user_id = v_user_id
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Profile not found'
        );
    END IF;

    -- Validate name if provided
    IF p_profile_name IS NOT NULL AND trim(p_profile_name) = '' THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Profile name cannot be empty'
        );
    END IF;

    -- Validate conditions if provided
    IF p_health_conditions IS NOT NULL AND NOT (p_health_conditions <@ ARRAY[
        'diabetes', 'hypertension', 'heart_disease',
        'celiac_disease', 'gout', 'kidney_disease', 'ibs'
    ]::text[]) THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid health condition'
        );
    END IF;

    -- Defensive: validate thresholds are non-negative when provided
    IF p_max_sugar_g IS NOT NULL AND p_max_sugar_g < 0 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_sugar_g must be non-negative'
        );
    END IF;
    IF p_max_salt_g IS NOT NULL AND p_max_salt_g < 0 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_salt_g must be non-negative'
        );
    END IF;
    IF p_max_saturated_fat_g IS NOT NULL AND p_max_saturated_fat_g < 0 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_saturated_fat_g must be non-negative'
        );
    END IF;
    IF p_max_calories_kcal IS NOT NULL AND p_max_calories_kcal < 0 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_calories_kcal must be non-negative'
        );
    END IF;

    -- Defensive: reject absurd upper bounds (per 100g limits)
    IF p_max_sugar_g IS NOT NULL AND p_max_sugar_g > 100 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_sugar_g cannot exceed 100g per 100g'
        );
    END IF;
    IF p_max_salt_g IS NOT NULL AND p_max_salt_g > 100 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_salt_g cannot exceed 100g per 100g'
        );
    END IF;
    IF p_max_saturated_fat_g IS NOT NULL AND p_max_saturated_fat_g > 100 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_saturated_fat_g cannot exceed 100g per 100g'
        );
    END IF;
    IF p_max_calories_kcal IS NOT NULL AND p_max_calories_kcal > 10000 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'max_calories_kcal cannot exceed 10000'
        );
    END IF;

    UPDATE public.user_health_profiles SET
        profile_name        = COALESCE(p_profile_name, profile_name),
        health_conditions   = COALESCE(p_health_conditions, health_conditions),
        is_active           = COALESCE(p_is_active, is_active),
        max_sugar_g         = CASE
            WHEN p_clear_max_sugar THEN NULL
            WHEN p_max_sugar_g IS NOT NULL THEN p_max_sugar_g
            ELSE max_sugar_g
        END,
        max_salt_g          = CASE
            WHEN p_clear_max_salt THEN NULL
            WHEN p_max_salt_g IS NOT NULL THEN p_max_salt_g
            ELSE max_salt_g
        END,
        max_saturated_fat_g = CASE
            WHEN p_clear_max_sat_fat THEN NULL
            WHEN p_max_saturated_fat_g IS NOT NULL THEN p_max_saturated_fat_g
            ELSE max_saturated_fat_g
        END,
        max_calories_kcal   = CASE
            WHEN p_clear_max_calories THEN NULL
            WHEN p_max_calories_kcal IS NOT NULL THEN p_max_calories_kcal
            ELSE max_calories_kcal
        END,
        notes               = CASE WHEN p_notes IS NOT NULL THEN p_notes ELSE notes END
    WHERE profile_id = p_profile_id
      AND user_id = v_user_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'profile_id', p_profile_id,
        'updated', true
    );
END;
$$;

-- ─── 4. Defensive validation in api_create_health_profile ───────────────────
--    Add upper-bound checks for absurd nutrient thresholds.

CREATE OR REPLACE FUNCTION public.api_create_health_profile(
    p_profile_name        text,
    p_health_conditions   text[]      DEFAULT '{}',
    p_is_active           boolean     DEFAULT false,
    p_max_sugar_g         numeric     DEFAULT NULL,
    p_max_salt_g          numeric     DEFAULT NULL,
    p_max_saturated_fat_g numeric     DEFAULT NULL,
    p_max_calories_kcal   numeric     DEFAULT NULL,
    p_notes               text        DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id    uuid := auth.uid();
    v_profile_id uuid;
    v_count      int;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    -- Validate name
    IF trim(COALESCE(p_profile_name, '')) = '' THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Profile name is required'
        );
    END IF;

    -- Limit: max 5 profiles per user
    SELECT COUNT(*) INTO v_count
    FROM public.user_health_profiles
    WHERE user_id = v_user_id;

    IF v_count >= 5 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Maximum 5 health profiles allowed'
        );
    END IF;

    -- Validate conditions
    IF NOT (p_health_conditions <@ ARRAY[
        'diabetes', 'hypertension', 'heart_disease',
        'celiac_disease', 'gout', 'kidney_disease', 'ibs'
    ]::text[]) THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid health condition. Allowed: diabetes, hypertension, heart_disease, celiac_disease, gout, kidney_disease, ibs'
        );
    END IF;

    -- Defensive: validate thresholds are non-negative
    IF p_max_sugar_g IS NOT NULL AND p_max_sugar_g < 0 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_sugar_g must be non-negative');
    END IF;
    IF p_max_salt_g IS NOT NULL AND p_max_salt_g < 0 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_salt_g must be non-negative');
    END IF;
    IF p_max_saturated_fat_g IS NOT NULL AND p_max_saturated_fat_g < 0 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_saturated_fat_g must be non-negative');
    END IF;
    IF p_max_calories_kcal IS NOT NULL AND p_max_calories_kcal < 0 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_calories_kcal must be non-negative');
    END IF;

    -- Defensive: reject absurd upper bounds
    IF p_max_sugar_g IS NOT NULL AND p_max_sugar_g > 100 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_sugar_g cannot exceed 100g per 100g');
    END IF;
    IF p_max_salt_g IS NOT NULL AND p_max_salt_g > 100 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_salt_g cannot exceed 100g per 100g');
    END IF;
    IF p_max_saturated_fat_g IS NOT NULL AND p_max_saturated_fat_g > 100 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_saturated_fat_g cannot exceed 100g per 100g');
    END IF;
    IF p_max_calories_kcal IS NOT NULL AND p_max_calories_kcal > 10000 THEN
        RETURN jsonb_build_object('api_version', '1.0', 'error', 'max_calories_kcal cannot exceed 10000');
    END IF;

    INSERT INTO public.user_health_profiles (
        user_id, profile_name, is_active, health_conditions,
        max_sugar_g, max_salt_g, max_saturated_fat_g, max_calories_kcal, notes
    ) VALUES (
        v_user_id, trim(p_profile_name), p_is_active, p_health_conditions,
        p_max_sugar_g, p_max_salt_g, p_max_saturated_fat_g, p_max_calories_kcal, p_notes
    )
    RETURNING profile_id INTO v_profile_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'profile_id', v_profile_id,
        'created', true
    );
END;
$$;

-- ─── 5. Re-grant permissions for the new function signatures ────────────────

GRANT EXECUTE ON FUNCTION public.api_update_health_profile(
    uuid, text, text[], boolean, numeric, numeric, numeric, numeric, text,
    boolean, boolean, boolean, boolean
) TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_update_health_profile(
    uuid, text, text[], boolean, numeric, numeric, numeric, numeric, text,
    boolean, boolean, boolean, boolean
) FROM PUBLIC, anon;

-- Re-grant for create (signature unchanged, but function recreated)
GRANT EXECUTE ON FUNCTION public.api_create_health_profile(text, text[], boolean, numeric, numeric, numeric, numeric, text)
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_create_health_profile(text, text[], boolean, numeric, numeric, numeric, numeric, text)
    FROM PUBLIC, anon;

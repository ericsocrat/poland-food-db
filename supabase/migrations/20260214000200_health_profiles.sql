-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 5 — Personal Health Profiles
-- ═══════════════════════════════════════════════════════════════════════════════
-- Adds user_health_profiles table, 5 CRUD RPCs, and a compute_health_warnings()
-- function that surfaces per-product warnings based on the user's active profile.
--
-- Health conditions supported:
--   diabetes, hypertension, heart_disease, celiac_disease, gout,
--   kidney_disease, ibs
--
-- Warnings are computed from nutrition_facts thresholds + existing product flags.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Table: user_health_profiles ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.user_health_profiles (
    profile_id          uuid        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id             uuid        NOT NULL DEFAULT auth.uid(),
    profile_name        text        NOT NULL,
    is_active           boolean     NOT NULL DEFAULT false,
    health_conditions   text[]      NOT NULL DEFAULT '{}',
    -- Optional per-100g nutrient thresholds (NULL = no limit)
    max_sugar_g         numeric(6,2)    NULL,
    max_salt_g          numeric(6,3)    NULL,
    max_saturated_fat_g numeric(6,2)    NULL,
    max_calories_kcal   numeric(7,1)    NULL,
    notes               text            NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),

    -- Each condition must be a known value
    CONSTRAINT chk_health_conditions CHECK (
        health_conditions <@ ARRAY[
            'diabetes', 'hypertension', 'heart_disease',
            'celiac_disease', 'gout', 'kidney_disease', 'ibs'
        ]::text[]
    ),
    -- Nutrient thresholds must be non-negative when set
    CONSTRAINT chk_max_sugar_positive       CHECK (max_sugar_g >= 0),
    CONSTRAINT chk_max_salt_positive        CHECK (max_salt_g >= 0),
    CONSTRAINT chk_max_sat_fat_positive     CHECK (max_saturated_fat_g >= 0),
    CONSTRAINT chk_max_calories_positive    CHECK (max_calories_kcal >= 0),
    -- Profile name must be non-empty
    CONSTRAINT chk_profile_name_nonempty    CHECK (trim(profile_name) <> '')
);

-- Index: fast lookup of user's profiles
CREATE INDEX IF NOT EXISTS idx_health_profiles_user_id
    ON public.user_health_profiles (user_id);

-- Index: fast lookup of active profile
CREATE INDEX IF NOT EXISTS idx_health_profiles_active
    ON public.user_health_profiles (user_id) WHERE is_active = true;

-- ─── 2. RLS Policies ───────────────────────────────────────────────────────

ALTER TABLE public.user_health_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_health_profiles FORCE ROW LEVEL SECURITY;

-- Users can only see/modify their own profiles
CREATE POLICY "health_profiles_select_own"
    ON public.user_health_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "health_profiles_insert_own"
    ON public.user_health_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "health_profiles_update_own"
    ON public.user_health_profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "health_profiles_delete_own"
    ON public.user_health_profiles FOR DELETE
    USING (auth.uid() = user_id);

-- Grants: same pattern as user_preferences
GRANT ALL ON public.user_health_profiles TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_health_profiles TO authenticated;
REVOKE ALL ON public.user_health_profiles FROM anon;

-- ─── 3. Trigger: enforce at most one active profile per user ────────────────

CREATE OR REPLACE FUNCTION trg_enforce_single_active_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- When activating a profile, deactivate all others for that user
    IF NEW.is_active = true THEN
        UPDATE public.user_health_profiles
        SET is_active = false, updated_at = now()
        WHERE user_id = NEW.user_id
          AND profile_id != NEW.profile_id
          AND is_active = true;
    END IF;
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_health_profile_active
    BEFORE INSERT OR UPDATE ON public.user_health_profiles
    FOR EACH ROW
    EXECUTE FUNCTION trg_enforce_single_active_profile();

-- ─── 4. RPC: api_list_health_profiles() ─────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_list_health_profiles()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_profiles jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'profile_id',        hp.profile_id,
            'profile_name',      hp.profile_name,
            'is_active',         hp.is_active,
            'health_conditions', hp.health_conditions,
            'max_sugar_g',       hp.max_sugar_g,
            'max_salt_g',        hp.max_salt_g,
            'max_saturated_fat_g', hp.max_saturated_fat_g,
            'max_calories_kcal', hp.max_calories_kcal,
            'notes',             hp.notes,
            'created_at',        hp.created_at,
            'updated_at',        hp.updated_at
        ) ORDER BY hp.is_active DESC, hp.created_at
    ), '[]'::jsonb) INTO v_profiles
    FROM public.user_health_profiles hp
    WHERE hp.user_id = v_user_id;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'profiles', v_profiles
    );
END;
$$;

-- ─── 5. RPC: api_get_active_health_profile() ───────────────────────────────

CREATE OR REPLACE FUNCTION public.api_get_active_health_profile()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_profile jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    SELECT jsonb_build_object(
        'profile_id',          hp.profile_id,
        'profile_name',        hp.profile_name,
        'is_active',           hp.is_active,
        'health_conditions',   hp.health_conditions,
        'max_sugar_g',         hp.max_sugar_g,
        'max_salt_g',          hp.max_salt_g,
        'max_saturated_fat_g', hp.max_saturated_fat_g,
        'max_calories_kcal',   hp.max_calories_kcal,
        'notes',               hp.notes,
        'created_at',          hp.created_at,
        'updated_at',          hp.updated_at
    ) INTO v_profile
    FROM public.user_health_profiles hp
    WHERE hp.user_id = v_user_id
      AND hp.is_active = true
    LIMIT 1;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'profile', v_profile  -- NULL if no active profile
    );
END;
$$;

-- ─── 6. RPC: api_create_health_profile() ────────────────────────────────────

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

-- ─── 7. RPC: api_update_health_profile() ────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_update_health_profile(
    p_profile_id          uuid,
    p_profile_name        text        DEFAULT NULL,
    p_health_conditions   text[]      DEFAULT NULL,
    p_is_active           boolean     DEFAULT NULL,
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

    UPDATE public.user_health_profiles SET
        profile_name        = COALESCE(p_profile_name, profile_name),
        health_conditions   = COALESCE(p_health_conditions, health_conditions),
        is_active           = COALESCE(p_is_active, is_active),
        max_sugar_g         = CASE WHEN p_max_sugar_g IS NOT NULL THEN p_max_sugar_g ELSE max_sugar_g END,
        max_salt_g          = CASE WHEN p_max_salt_g IS NOT NULL THEN p_max_salt_g ELSE max_salt_g END,
        max_saturated_fat_g = CASE WHEN p_max_saturated_fat_g IS NOT NULL THEN p_max_saturated_fat_g ELSE max_saturated_fat_g END,
        max_calories_kcal   = CASE WHEN p_max_calories_kcal IS NOT NULL THEN p_max_calories_kcal ELSE max_calories_kcal END,
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

-- ─── 8. RPC: api_delete_health_profile() ────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_delete_health_profile(
    p_profile_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_deleted boolean;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    DELETE FROM public.user_health_profiles
    WHERE profile_id = p_profile_id
      AND user_id = v_user_id;

    v_deleted := FOUND;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'profile_id', p_profile_id,
        'deleted', v_deleted
    );
END;
$$;

-- ─── 9. Function: compute_health_warnings() ─────────────────────────────────
--    Returns an array of warning objects for a given product based on the
--    user's active health profile conditions and nutrient thresholds.

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

    -- Get nutrition per 100g (serving_id = 1 convention for per-100g)
    SELECT nf.calories, nf.sugars_g, nf.salt_g, nf.saturated_fat_g, nf.protein_g
    INTO v_nutrition
    FROM nutrition_facts nf
    WHERE nf.product_id = p_product_id
    LIMIT 1;

    -- ── Condition-based warnings ──

    -- Diabetes: high sugar, high carbs
    IF 'diabetes' = ANY(v_profile.health_conditions) THEN
        IF v_product.high_sugar_flag = true THEN
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
        IF v_product.high_salt_flag = true THEN
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
        IF v_product.high_sat_fat_flag = true THEN
            v_warnings := v_warnings || jsonb_build_object(
                'condition', 'heart_disease',
                'severity', 'high',
                'message', 'High saturated fat — may impact cardiovascular health'
            );
        END IF;
        IF v_product.high_salt_flag = true THEN
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
        IF v_product.high_salt_flag = true THEN
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

-- ─── 10. RPC: api_product_health_warnings() ─────────────────────────────────
--     Standalone RPC to get health warnings for a product given the user's
--     active health profile. Usable independently of product detail.

CREATE OR REPLACE FUNCTION public.api_product_health_warnings(
    p_product_id  bigint,
    p_profile_id  uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id  uuid := auth.uid();
    v_warnings jsonb;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required'
        );
    END IF;

    v_warnings := compute_health_warnings(p_product_id, p_profile_id);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'product_id', p_product_id,
        'warning_count', jsonb_array_length(v_warnings),
        'warnings', v_warnings
    );
END;
$$;

-- ─── 11. Grant execute to authenticated ─────────────────────────────────────

GRANT EXECUTE ON FUNCTION public.api_list_health_profiles()              TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.api_get_active_health_profile()         TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.api_create_health_profile(text, text[], boolean, numeric, numeric, numeric, numeric, text)
    TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.api_update_health_profile(uuid, text, text[], boolean, numeric, numeric, numeric, numeric, text)
    TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.api_delete_health_profile(uuid)         TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.api_product_health_warnings(bigint, uuid)
    TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.compute_health_warnings(bigint, uuid)   TO authenticated, service_role;

-- Revoke from PUBLIC and anon (PostgreSQL grants EXECUTE to PUBLIC by default)
REVOKE EXECUTE ON FUNCTION public.api_list_health_profiles()              FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_get_active_health_profile()         FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_create_health_profile(text, text[], boolean, numeric, numeric, numeric, numeric, text)
    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_update_health_profile(uuid, text, text[], boolean, numeric, numeric, numeric, numeric, text)
    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_delete_health_profile(uuid)         FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.api_product_health_warnings(bigint, uuid)
    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.compute_health_warnings(bigint, uuid)   FROM PUBLIC, anon;

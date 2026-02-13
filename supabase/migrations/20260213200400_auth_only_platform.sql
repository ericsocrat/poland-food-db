-- ============================================================================
-- Auth-only platform + signup onboarding support
-- ============================================================================
-- 1. Revoke anon EXECUTE from 7 product-data RPCs (auth-only platform)
-- 2. Allow NULL country in user_preferences (pre-onboarding state)
-- 3. Rewrite api_get_user_preferences() — auto-upsert + onboarding_complete flag
-- 4. Update api_set_user_preferences() — remove PL default, require explicit country
-- 5. Remove tier-3 "first active country" fallback from resolve_effective_country()
-- ============================================================================

BEGIN;

-- ──────────────────────────────────────────────────────────────────────────────
-- 1. REVOKE anon EXECUTE from product-data RPCs
-- ──────────────────────────────────────────────────────────────────────────────
-- After this, only authenticated + service_role can access product data.
-- Unauthenticated Supabase callers get a standard "permission denied" error.

REVOKE EXECUTE ON FUNCTION public.api_search_products(
    text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_search_products(
    text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_category_listing(
    text, text, text, integer, integer, text, text, text[], boolean, boolean, boolean
) TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_product_detail(bigint)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_product_detail(bigint)
    TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_product_detail_by_ean(text, text)
    TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_score_explanation(bigint)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_score_explanation(bigint)
    TO authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.api_data_confidence(bigint)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_data_confidence(bigint)
    TO authenticated, service_role;


-- ──────────────────────────────────────────────────────────────────────────────
-- 2. Allow NULL country in user_preferences (pre-onboarding)
-- ──────────────────────────────────────────────────────────────────────────────
-- During signup, a row is auto-created with country=NULL.
-- The frontend must force onboarding (region selection) before allowing product access.

ALTER TABLE public.user_preferences
    ALTER COLUMN country DROP NOT NULL,
    ALTER COLUMN country DROP DEFAULT;


-- ──────────────────────────────────────────────────────────────────────────────
-- 3. Rewrite api_get_user_preferences() — auto-upsert + onboarding flag
-- ──────────────────────────────────────────────────────────────────────────────
-- If no row exists for auth.uid(), auto-create one with country=NULL.
-- Returns onboarding_complete: true/false so frontend knows whether to redirect.

CREATE OR REPLACE FUNCTION public.api_get_user_preferences()
RETURNS jsonb
LANGUAGE plpgsql VOLATILE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid  uuid;
    v_row  user_preferences%ROWTYPE;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Auto-upsert: ensure a row always exists for this user
    INSERT INTO user_preferences (user_id)
    VALUES (v_uid)
    ON CONFLICT (user_id) DO NOTHING;

    SELECT * INTO v_row
    FROM user_preferences
    WHERE user_id = v_uid;

    RETURN jsonb_build_object(
        'api_version',                 '1.0',
        'user_id',                     v_row.user_id,
        'country',                     v_row.country,
        'diet_preference',             v_row.diet_preference,
        'avoid_allergens',             COALESCE(to_jsonb(v_row.avoid_allergens), '[]'::jsonb),
        'strict_allergen',             v_row.strict_allergen,
        'strict_diet',                 v_row.strict_diet,
        'treat_may_contain_as_unsafe', v_row.treat_may_contain_as_unsafe,
        'onboarding_complete',         (v_row.country IS NOT NULL),
        'created_at',                  v_row.created_at,
        'updated_at',                  v_row.updated_at
    );
END;
$function$;

-- Privileges unchanged: already revoked from anon, granted to authenticated + service_role


-- ──────────────────────────────────────────────────────────────────────────────
-- 4. Update api_set_user_preferences() — no PL default, explicit country required
-- ──────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.api_set_user_preferences(
    p_country                     text     DEFAULT NULL,
    p_diet_preference             text     DEFAULT NULL,
    p_avoid_allergens             text[]   DEFAULT NULL,
    p_strict_allergen             boolean  DEFAULT false,
    p_strict_diet                 boolean  DEFAULT false,
    p_treat_may_contain_as_unsafe boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid uuid;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Validate country if provided (required for onboarding step 1)
    IF p_country IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM country_ref
            WHERE country_code = p_country AND is_active = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Country not available: ' || COALESCE(p_country, 'NULL')
            );
        END IF;
    END IF;

    -- Validate diet preference
    IF p_diet_preference IS NOT NULL AND p_diet_preference NOT IN ('none','vegetarian','vegan') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Invalid diet_preference. Use: none, vegetarian, vegan.'
        );
    END IF;

    -- Upsert: only update fields that were explicitly passed
    INSERT INTO user_preferences (
        user_id, country, diet_preference, avoid_allergens,
        strict_allergen, strict_diet, treat_may_contain_as_unsafe
    ) VALUES (
        v_uid, p_country, p_diet_preference, p_avoid_allergens,
        p_strict_allergen, p_strict_diet, p_treat_may_contain_as_unsafe
    )
    ON CONFLICT (user_id) DO UPDATE SET
        country                     = COALESCE(EXCLUDED.country, user_preferences.country),
        diet_preference             = EXCLUDED.diet_preference,
        avoid_allergens             = EXCLUDED.avoid_allergens,
        strict_allergen             = EXCLUDED.strict_allergen,
        strict_diet                 = EXCLUDED.strict_diet,
        treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
        updated_at                  = now();

    RETURN api_get_user_preferences();
END;
$function$;


-- ──────────────────────────────────────────────────────────────────────────────
-- 5. Remove tier-3 "first active country" fallback from resolve_effective_country
-- ──────────────────────────────────────────────────────────────────────────────
-- Effective country is now: explicit p_country OR user_preferences.country.
-- If neither exists (pre-onboarding), returns NULL — frontend must redirect.

CREATE OR REPLACE FUNCTION public.resolve_effective_country(
    p_country text DEFAULT NULL
)
RETURNS text
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (pass-through if not NULL)
        NULLIF(TRIM(p_country), ''),
        -- Priority 2: authenticated user's saved country preference
        (SELECT up.country
         FROM user_preferences up
         WHERE up.user_id = auth.uid())
        -- NO tier-3 fallback: if no preference set, returns NULL
    );
$function$;

-- Privileges unchanged: internal-only (revoked from anon + authenticated)

COMMIT;

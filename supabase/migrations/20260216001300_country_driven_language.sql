-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration 96: Country-Driven Language Selection
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Each country offers exactly 2 language options: native + English.
-- When a user changes country, their preferred_language auto-resets to the
-- country's default_language.
--
-- Changes:
--   1. Verify country_ref.default_language is populated (idempotent backfill)
--   2. Update resolve_language() — fallback includes country_ref.default_language
--   3. Update api_set_user_preferences() — auto-set language on country change
--
-- Backward-compatible: all function signatures unchanged, new behavior is additive.
-- Idempotent: safe to re-run.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Ensure country_ref.default_language is populated ────────────────────

DO $$
BEGIN
    -- Backfill any NULL default_language values
    UPDATE public.country_ref SET default_language = 'pl'
    WHERE country_code = 'PL' AND (default_language IS NULL OR default_language = '');

    UPDATE public.country_ref SET default_language = 'de'
    WHERE country_code = 'DE' AND (default_language IS NULL OR default_language = '');
END;
$$;

-- ─── 2. Update resolve_language() — add country_ref.default_language tier ───
--
-- New fallback chain:
--   1. Explicit p_language param (validated)
--   2. Authenticated user's preferred_language
--   3. User's country → country_ref.default_language
--   4. 'en' (ultimate fallback for anon / unknown)

CREATE OR REPLACE FUNCTION public.resolve_language(p_language text DEFAULT NULL)
RETURNS text
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
    SELECT COALESCE(
        -- Priority 1: explicit parameter (validated against language_ref)
        (SELECT lr.code
         FROM language_ref lr
         WHERE lr.code = NULLIF(TRIM(p_language), '')
           AND lr.is_enabled = true),
        -- Priority 2: authenticated user's saved language preference
        (SELECT up.preferred_language
         FROM user_preferences up
         WHERE up.user_id = auth.uid()),
        -- Priority 3: user's country default language
        (SELECT cr.default_language
         FROM user_preferences up
         JOIN country_ref cr ON cr.country_code = up.country
         WHERE up.user_id = auth.uid()
           AND cr.default_language IS NOT NULL),
        -- Priority 4: default to English
        'en'
    );
$func$;

COMMENT ON FUNCTION public.resolve_language(text) IS
'Resolves the effective UI language. Priority: explicit (validated) → user pref → country default → ''en''. '
'Invalid or disabled language codes gracefully fall back. Safe for anonymous users.';

-- ─── 3. Update api_set_user_preferences() ───────────────────────────────────
--
-- When p_country changes, auto-set preferred_language to the new country's
-- default_language (unless user explicitly passes a language in the same call).
-- Signature is unchanged (7 params, all with DEFAULTs).

CREATE OR REPLACE FUNCTION public.api_set_user_preferences(
    p_country                     text     DEFAULT NULL,
    p_diet_preference             text     DEFAULT NULL,
    p_avoid_allergens             text[]   DEFAULT NULL,
    p_strict_allergen             boolean  DEFAULT false,
    p_strict_diet                 boolean  DEFAULT false,
    p_treat_may_contain_as_unsafe boolean  DEFAULT false,
    p_preferred_language          text     DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_uid uuid;
    v_current_country text;
    v_effective_language text;
    v_country_default_lang text;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error', 'Authentication required.'
        );
    END IF;

    -- Validate country if provided
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

    -- Validate preferred_language against language_ref (data-driven, not hardcoded)
    IF p_preferred_language IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM language_ref
            WHERE code = p_preferred_language AND is_enabled = true
        ) THEN
            RETURN jsonb_build_object(
                'api_version', '1.0',
                'error', 'Invalid preferred_language. Enabled: ' ||
                    (SELECT string_agg(code, ', ' ORDER BY sort_order)
                     FROM language_ref WHERE is_enabled = true)
            );
        END IF;
    END IF;

    -- Determine if country is changing (auto-set language on country change)
    IF p_country IS NOT NULL AND p_preferred_language IS NULL THEN
        -- Get user's current country (NULL if new user)
        SELECT country INTO v_current_country
        FROM user_preferences
        WHERE user_id = v_uid;

        -- If country is actually changing, auto-set language to new country's default
        IF v_current_country IS NULL OR v_current_country <> p_country THEN
            SELECT default_language INTO v_country_default_lang
            FROM country_ref
            WHERE country_code = p_country;

            IF v_country_default_lang IS NOT NULL THEN
                v_effective_language := v_country_default_lang;
            END IF;
        END IF;
    END IF;

    -- Final language: explicit param > auto-set from country > existing pref > 'en'
    v_effective_language := COALESCE(p_preferred_language, v_effective_language);

    -- Upsert
    INSERT INTO user_preferences (
        user_id, country, diet_preference, avoid_allergens,
        strict_allergen, strict_diet, treat_may_contain_as_unsafe,
        preferred_language
    ) VALUES (
        v_uid, p_country, p_diet_preference, p_avoid_allergens,
        p_strict_allergen, p_strict_diet, p_treat_may_contain_as_unsafe,
        COALESCE(v_effective_language, 'en')
    )
    ON CONFLICT (user_id) DO UPDATE SET
        country                     = COALESCE(EXCLUDED.country, user_preferences.country),
        diet_preference             = EXCLUDED.diet_preference,
        avoid_allergens             = EXCLUDED.avoid_allergens,
        strict_allergen             = EXCLUDED.strict_allergen,
        strict_diet                 = EXCLUDED.strict_diet,
        treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
        preferred_language          = COALESCE(
                                        v_effective_language,
                                        user_preferences.preferred_language
                                    ),
        updated_at                  = now();

    RETURN api_get_user_preferences();
END;
$function$;

COMMENT ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text) IS
'Create or update user preferences. When country changes (and no explicit language given), '
'preferred_language auto-resets to the new country''s default_language.';

-- Grants unchanged
GRANT EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text)
    TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.api_set_user_preferences(text, text, text[], boolean, boolean, boolean, text)
    FROM PUBLIC, anon;

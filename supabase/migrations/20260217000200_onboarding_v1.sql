-- ─── Onboarding v1 — Wizard Infrastructure ──────────────────────────────────
-- Issue #42: Adds explicit onboarding tracking columns, health goals,
-- favorite categories, and three new RPC functions.
-- Replaces computed onboarding_complete with a stored column.

BEGIN;

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 1. Schema changes to user_preferences                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE public.user_preferences
  ADD COLUMN IF NOT EXISTS onboarding_completed    boolean     NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS onboarding_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS onboarding_skipped      boolean     NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS health_goals            text[]      NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS favorite_categories     text[]      NOT NULL DEFAULT '{}';

-- Backfill: existing users who already have a country set are considered onboarded.
UPDATE public.user_preferences
SET onboarding_completed    = true,
    onboarding_completed_at = updated_at
WHERE country IS NOT NULL
  AND onboarding_completed  = false;

-- Validate health_goals values (allowed set)
ALTER TABLE public.user_preferences
  ADD CONSTRAINT chk_health_goals CHECK (
    health_goals <@ ARRAY[
      'diabetes',
      'low_sodium',
      'heart_health',
      'weight_management',
      'general_wellness'
    ]::text[]
  );

-- Validate favorite_categories against category_ref slugs
-- (loose check — array values should match category_ref.slug)
-- We use a trigger instead of a CHECK constraint because CHECK can't
-- reference another table.

CREATE OR REPLACE FUNCTION trg_validate_favorite_categories()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_invalid text[];
BEGIN
  IF NEW.favorite_categories IS NOT NULL AND array_length(NEW.favorite_categories, 1) > 0 THEN
    SELECT array_agg(fc)
    INTO v_invalid
    FROM unnest(NEW.favorite_categories) AS fc
    WHERE NOT EXISTS (
      SELECT 1 FROM category_ref WHERE slug = fc
    );

    IF v_invalid IS NOT NULL AND array_length(v_invalid, 1) > 0 THEN
      RAISE EXCEPTION 'Invalid favorite_categories: %', v_invalid;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_fav_cats ON public.user_preferences;
CREATE TRIGGER trg_validate_fav_cats
  BEFORE INSERT OR UPDATE OF favorite_categories ON public.user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION trg_validate_favorite_categories();

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 2. api_get_onboarding_status()                                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.api_get_onboarding_status()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid;
  v_row record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required.');
  END IF;

  SELECT onboarding_completed, onboarding_skipped, onboarding_completed_at
  INTO v_row
  FROM user_preferences
  WHERE user_id = v_uid;

  -- No row yet = brand new user
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'api_version', '1.0',
      'completed',    false,
      'skipped',      false,
      'completed_at', NULL
    );
  END IF;

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'completed',    v_row.onboarding_completed,
    'skipped',      v_row.onboarding_skipped,
    'completed_at', v_row.onboarding_completed_at
  );
END;
$$;

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 3. api_complete_onboarding(p_preferences jsonb)                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.api_complete_onboarding(
  p_preferences jsonb DEFAULT '{}'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid                uuid;
  v_country            text;
  v_language           text;
  v_diet               text;
  v_allergens          text[];
  v_strict_allergen    boolean;
  v_strict_diet        boolean;
  v_may_contain        boolean;
  v_health_goals       text[];
  v_fav_cats           text[];
  v_default_lang       text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required.');
  END IF;

  -- Extract preferences from JSONB
  v_country         := p_preferences->>'country';
  v_language        := p_preferences->>'language';
  v_diet            := COALESCE(p_preferences->>'diet', 'none');
  v_strict_allergen := COALESCE((p_preferences->>'strict_allergen')::boolean, false);
  v_strict_diet     := COALESCE((p_preferences->>'strict_diet')::boolean, false);
  v_may_contain     := COALESCE((p_preferences->>'treat_may_contain_as_unsafe')::boolean, false);

  -- Extract arrays
  SELECT COALESCE(array_agg(val), '{}')
  INTO v_allergens
  FROM jsonb_array_elements_text(COALESCE(p_preferences->'allergens', '[]'::jsonb)) AS val;

  SELECT COALESCE(array_agg(val), '{}')
  INTO v_health_goals
  FROM jsonb_array_elements_text(COALESCE(p_preferences->'health_goals', '[]'::jsonb)) AS val;

  SELECT COALESCE(array_agg(val), '{}')
  INTO v_fav_cats
  FROM jsonb_array_elements_text(COALESCE(p_preferences->'favorite_categories', '[]'::jsonb)) AS val;

  -- Validate country (required for onboarding completion)
  IF v_country IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Country is required.');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM country_ref WHERE country_code = v_country AND is_active = true
  ) THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Country not available: ' || v_country);
  END IF;

  -- Validate diet preference
  IF v_diet IS NOT NULL AND v_diet NOT IN ('none', 'vegetarian', 'vegan') THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Invalid diet preference.');
  END IF;

  -- Determine language: explicit > country default > 'en'
  IF v_language IS NULL THEN
    SELECT default_language INTO v_default_lang
    FROM country_ref WHERE country_code = v_country;
    v_language := COALESCE(v_default_lang, 'en');
  END IF;

  -- Validate language
  IF NOT EXISTS (
    SELECT 1 FROM language_ref WHERE code = v_language AND is_enabled = true
  ) THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Invalid language.');
  END IF;

  -- Upsert user_preferences with all onboarding data
  INSERT INTO user_preferences (
    user_id, country, preferred_language, diet_preference, avoid_allergens,
    strict_allergen, strict_diet, treat_may_contain_as_unsafe,
    health_goals, favorite_categories,
    onboarding_completed, onboarding_completed_at, onboarding_skipped,
    updated_at
  ) VALUES (
    v_uid, v_country, v_language, v_diet, v_allergens,
    v_strict_allergen, v_strict_diet, v_may_contain,
    v_health_goals, v_fav_cats,
    true, now(), false,
    now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    country                     = EXCLUDED.country,
    preferred_language          = EXCLUDED.preferred_language,
    diet_preference             = EXCLUDED.diet_preference,
    avoid_allergens             = EXCLUDED.avoid_allergens,
    strict_allergen             = EXCLUDED.strict_allergen,
    strict_diet                 = EXCLUDED.strict_diet,
    treat_may_contain_as_unsafe = EXCLUDED.treat_may_contain_as_unsafe,
    health_goals                = EXCLUDED.health_goals,
    favorite_categories         = EXCLUDED.favorite_categories,
    onboarding_completed        = true,
    onboarding_completed_at     = now(),
    onboarding_skipped          = false,
    updated_at                  = now();

  -- ── Auto-create health profile from goals ─────────────────────────────
  IF array_length(v_health_goals, 1) > 0 THEN
    DECLARE
      v_conditions  text[] := '{}';
      v_sugar       numeric(6,2);
      v_salt        numeric(6,3);
      v_sat_fat     numeric(6,2);
    BEGIN
      IF 'diabetes' = ANY(v_health_goals) THEN
        v_conditions := array_append(v_conditions, 'diabetes');
        v_sugar := 25;
      END IF;
      IF 'low_sodium' = ANY(v_health_goals) THEN
        v_conditions := array_append(v_conditions, 'hypertension');
        v_salt := 1.5;  -- 1500mg = 1.5g
      END IF;
      IF 'heart_health' = ANY(v_health_goals) THEN
        v_conditions := array_append(v_conditions, 'heart_disease');
        v_sat_fat := 16;
      END IF;

      -- Only create profile if we have concrete conditions
      IF array_length(v_conditions, 1) > 0 THEN
        INSERT INTO user_health_profiles (
          user_id, profile_name, is_active, health_conditions,
          max_sugar_g, max_salt_g, max_saturated_fat_g
        ) VALUES (
          v_uid, 'Onboarding Profile', true, v_conditions,
          v_sugar, v_salt, v_sat_fat
        )
        ON CONFLICT DO NOTHING;  -- Don't fail if profile already exists
      END IF;
    END;
  END IF;

  RETURN api_get_user_preferences();
END;
$$;

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 4. api_skip_onboarding()                                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.api_skip_onboarding()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required.');
  END IF;

  -- Upsert: mark as skipped (NOT completed), set country to PL as default
  INSERT INTO user_preferences (
    user_id, country, onboarding_completed, onboarding_skipped, updated_at
  ) VALUES (
    v_uid, 'PL', false, true, now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    country            = COALESCE(user_preferences.country, 'PL'),
    onboarding_skipped = true,
    updated_at         = now();

  RETURN jsonb_build_object(
    'api_version', '1.0',
    'completed',    false,
    'skipped',      true,
    'completed_at', NULL
  );
END;
$$;

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 5. Update api_get_user_preferences to use stored column                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.api_get_user_preferences()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid  uuid;
  v_row  user_preferences%ROWTYPE;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('api_version', '1.0', 'error', 'Authentication required.');
  END IF;

  -- Auto-upsert for first-time callers
  INSERT INTO user_preferences (user_id, country)
  VALUES (v_uid, NULL)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO v_row FROM user_preferences WHERE user_id = v_uid;

  RETURN jsonb_build_object(
    'api_version',                '1.0',
    'user_id',                    v_row.user_id,
    'country',                    v_row.country,
    'preferred_language',         v_row.preferred_language,
    'diet_preference',            v_row.diet_preference,
    'avoid_allergens',            COALESCE(v_row.avoid_allergens, '{}'),
    'strict_allergen',            v_row.strict_allergen,
    'strict_diet',                v_row.strict_diet,
    'treat_may_contain_as_unsafe',v_row.treat_may_contain_as_unsafe,
    'health_goals',               COALESCE(v_row.health_goals, '{}'),
    'favorite_categories',        COALESCE(v_row.favorite_categories, '{}'),
    'onboarding_complete',        v_row.onboarding_completed OR v_row.onboarding_skipped,
    'onboarding_completed',       v_row.onboarding_completed,
    'onboarding_skipped',         v_row.onboarding_skipped,
    'created_at',                 v_row.created_at,
    'updated_at',                 v_row.updated_at
  );
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.api_get_onboarding_status() TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_complete_onboarding(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_skip_onboarding() TO authenticated;

COMMIT;

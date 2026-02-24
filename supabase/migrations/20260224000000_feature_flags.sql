-- ─── Feature Flag Framework (Issue #191) ───────────────────────────────────
-- Supabase-backed feature flags with targeting rules, overrides, audit log,
-- lifecycle management, and admin RPCs.
-- To roll back: DROP TABLE flag_audit_log, flag_overrides, feature_flags CASCADE;
-- ────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Feature flag definitions
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.feature_flags (
  id            SERIAL PRIMARY KEY,
  key           TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  description   TEXT,
  flag_type     TEXT NOT NULL DEFAULT 'boolean',
  enabled       BOOLEAN NOT NULL DEFAULT false,

  -- Targeting rules
  percentage    INT DEFAULT 100,
  countries     TEXT[] DEFAULT '{}',
  roles         TEXT[] DEFAULT '{}',
  environments  TEXT[] DEFAULT '{}',

  -- Variants (for multivariate flags)
  variants      JSONB DEFAULT '[]',

  -- Lifecycle
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  expires_at    TIMESTAMPTZ,
  created_by    TEXT DEFAULT current_user,

  -- Metadata
  tags          TEXT[] DEFAULT '{}',
  jira_ref      TEXT,

  CONSTRAINT valid_percentage CHECK (percentage BETWEEN 0 AND 100),
  CONSTRAINT valid_type CHECK (flag_type IN ('boolean', 'percentage', 'variant'))
);

COMMENT ON TABLE public.feature_flags IS 'Feature flag definitions with targeting rules (#191)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. User/session/country overrides
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.flag_overrides (
  id              SERIAL PRIMARY KEY,
  flag_key        TEXT NOT NULL REFERENCES public.feature_flags(key) ON DELETE CASCADE,
  target_type     TEXT NOT NULL,
  target_value    TEXT NOT NULL,
  override_value  JSONB NOT NULL,
  reason          TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  expires_at      TIMESTAMPTZ,
  UNIQUE(flag_key, target_type, target_value),
  CONSTRAINT valid_target_type CHECK (target_type IN ('user', 'session', 'country'))
);

COMMENT ON TABLE public.flag_overrides IS 'Per-user/session/country flag overrides (#191)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Audit log
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.flag_audit_log (
  id          BIGSERIAL PRIMARY KEY,
  flag_key    TEXT NOT NULL,
  action      TEXT NOT NULL,
  old_value   JSONB,
  new_value   JSONB,
  changed_by  TEXT DEFAULT current_user,
  changed_at  TIMESTAMPTZ DEFAULT now(),
  reason      TEXT,
  CONSTRAINT valid_action CHECK (action IN (
    'created', 'enabled', 'disabled', 'updated', 'expired', 'deleted'
  ))
);

COMMENT ON TABLE public.flag_audit_log IS 'Immutable audit trail for flag state changes (#191)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Indexes
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_flags_key_enabled
  ON public.feature_flags(key) WHERE enabled = true;

CREATE INDEX IF NOT EXISTS idx_flags_expires
  ON public.feature_flags(expires_at) WHERE expires_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_overrides_flag
  ON public.flag_overrides(flag_key, target_type);

CREATE INDEX IF NOT EXISTS idx_flag_audit_key_time
  ON public.flag_audit_log(flag_key, changed_at DESC);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Row Level Security
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flag_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flag_audit_log ENABLE ROW LEVEL SECURITY;

-- Flags: readable by everyone (anon + authenticated), writable by service_role only
DROP POLICY IF EXISTS flags_select ON public.feature_flags;
CREATE POLICY flags_select ON public.feature_flags
  FOR SELECT USING (true);

DROP POLICY IF EXISTS flags_admin ON public.feature_flags;
CREATE POLICY flags_admin ON public.feature_flags
  FOR ALL USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- Overrides: service_role only
DROP POLICY IF EXISTS overrides_admin ON public.flag_overrides;
CREATE POLICY overrides_admin ON public.flag_overrides
  FOR ALL USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- Audit log: read by service_role, insert via trigger
DROP POLICY IF EXISTS audit_select ON public.flag_audit_log;
CREATE POLICY audit_select ON public.flag_audit_log
  FOR SELECT USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS audit_insert ON public.flag_audit_log;
CREATE POLICY audit_insert ON public.flag_audit_log
  FOR INSERT WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Grants
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT SELECT ON public.feature_flags TO anon, authenticated;
GRANT ALL    ON public.feature_flags TO service_role;
GRANT ALL    ON public.flag_overrides TO service_role;
GRANT ALL    ON public.flag_audit_log TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.feature_flags_id_seq TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.flag_overrides_id_seq TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.flag_audit_log_id_seq TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. Auto-audit trigger
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.trg_flag_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.flag_audit_log (flag_key, action, new_value)
    VALUES (NEW.key, 'created', to_jsonb(NEW));
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO public.flag_audit_log (flag_key, action, old_value, new_value)
    VALUES (
      NEW.key,
      CASE
        WHEN OLD.enabled IS DISTINCT FROM NEW.enabled THEN
          CASE WHEN NEW.enabled THEN 'enabled' ELSE 'disabled' END
        ELSE 'updated'
      END,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO public.flag_audit_log (flag_key, action, old_value)
    VALUES (OLD.key, 'deleted', to_jsonb(OLD));
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS flag_changes ON public.feature_flags;
CREATE TRIGGER flag_changes
  AFTER INSERT OR UPDATE OR DELETE ON public.feature_flags
  FOR EACH ROW EXECUTE FUNCTION public.trg_flag_audit();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. Lifecycle functions
-- ═══════════════════════════════════════════════════════════════════════════════

-- Auto-expire flags past their expiration date
CREATE OR REPLACE FUNCTION public.expire_stale_flags()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_count INT;
BEGIN
  WITH expired AS (
    UPDATE public.feature_flags
    SET enabled = false, updated_at = now()
    WHERE enabled = true
      AND expires_at IS NOT NULL
      AND expires_at < now()
    RETURNING key
  )
  SELECT count(*) INTO v_count FROM expired;

  RETURN v_count;
END;
$$;

COMMENT ON FUNCTION public.expire_stale_flags IS 'Disable flags past expires_at. Returns count of expired flags.';

-- Flag health report (detect stale flags)
CREATE OR REPLACE FUNCTION public.flag_health_report()
RETURNS TABLE(
  flag_key TEXT,
  status TEXT,
  age_days INT,
  issue TEXT,
  recommendation TEXT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY

  -- Flags older than 90 days with no recent changes
  SELECT f.key, 'stale'::TEXT,
    EXTRACT(DAY FROM now() - f.created_at)::INT,
    'Flag older than 90 days with no toggle in 60+ days'::TEXT,
    'Review and either permanent-enable or remove'::TEXT
  FROM public.feature_flags f
  LEFT JOIN public.flag_audit_log a
    ON a.flag_key = f.key AND a.changed_at > now() - INTERVAL '60 days'
  WHERE f.created_at < now() - INTERVAL '90 days'
    AND a.id IS NULL

  UNION ALL

  -- Flags at 100% for 30+ days (should be permanent)
  SELECT f.key, 'graduate'::TEXT,
    EXTRACT(DAY FROM now() - f.updated_at)::INT,
    'Flag at 100% rollout for 30+ days'::TEXT,
    'Hardcode flag value and remove flag'::TEXT
  FROM public.feature_flags f
  WHERE f.enabled = true AND f.percentage = 100
    AND f.updated_at < now() - INTERVAL '30 days'

  UNION ALL

  -- Flags with no expiration set
  SELECT f.key, 'no_expiry'::TEXT,
    EXTRACT(DAY FROM now() - f.created_at)::INT,
    'Flag has no expiration date'::TEXT,
    'Set expires_at to prevent flag sprawl'::TEXT
  FROM public.feature_flags f
  WHERE f.expires_at IS NULL
    AND f.created_at < now() - INTERVAL '14 days'

  ORDER BY 3 DESC;
END;
$$;

COMMENT ON FUNCTION public.flag_health_report IS 'Detect stale, graduate-ready, and no-expiry flags.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. Admin RPCs
-- ═══════════════════════════════════════════════════════════════════════════════

-- Toggle a flag on/off
CREATE OR REPLACE FUNCTION public.admin_toggle_flag(
  p_key TEXT,
  p_enabled BOOLEAN,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_flag RECORD;
BEGIN
  UPDATE public.feature_flags
  SET enabled = p_enabled, updated_at = now()
  WHERE key = p_key
  RETURNING * INTO v_flag;

  IF v_flag IS NULL THEN
    RAISE EXCEPTION 'Flag not found: %', p_key;
  END IF;

  -- Log reason if provided
  IF p_reason IS NOT NULL THEN
    UPDATE public.flag_audit_log
    SET reason = p_reason
    WHERE flag_key = p_key
      AND changed_at = (SELECT max(changed_at) FROM public.flag_audit_log WHERE flag_key = p_key);
  END IF;

  RETURN jsonb_build_object(
    'key', v_flag.key,
    'enabled', v_flag.enabled,
    'updated_at', v_flag.updated_at
  );
END;
$$;

COMMENT ON FUNCTION public.admin_toggle_flag IS 'Toggle a feature flag on/off with optional reason.';

-- Set rollout percentage
CREATE OR REPLACE FUNCTION public.admin_set_rollout(
  p_key TEXT,
  p_percentage INT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_flag RECORD;
BEGIN
  UPDATE public.feature_flags
  SET percentage = p_percentage, updated_at = now()
  WHERE key = p_key
  RETURNING * INTO v_flag;

  IF v_flag IS NULL THEN
    RAISE EXCEPTION 'Flag not found: %', p_key;
  END IF;

  RETURN jsonb_build_object(
    'key', v_flag.key,
    'percentage', v_flag.percentage,
    'updated_at', v_flag.updated_at
  );
END;
$$;

COMMENT ON FUNCTION public.admin_set_rollout IS 'Set rollout percentage (0-100) for a feature flag.';

-- Flag overview (list all flags with status)
CREATE OR REPLACE FUNCTION public.admin_flag_overview()
RETURNS TABLE(
  key TEXT,
  name TEXT,
  enabled BOOLEAN,
  percentage INT,
  countries TEXT[],
  age_days INT,
  expires_in_days INT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    f.key, f.name, f.enabled, f.percentage, f.countries,
    EXTRACT(DAY FROM now() - f.created_at)::INT,
    CASE
      WHEN f.expires_at IS NOT NULL
      THEN EXTRACT(DAY FROM f.expires_at - now())::INT
      ELSE NULL
    END
  FROM public.feature_flags f
  ORDER BY f.updated_at DESC;
END;
$$;

COMMENT ON FUNCTION public.admin_flag_overview IS 'List all flags with status, rollout, and expiration info.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. Seed initial flags (all disabled)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.feature_flags (key, name, description, flag_type, enabled, countries, tags, expires_at)
VALUES
  ('scoring_v4', 'Scoring Engine v4', 'Enable v4 scoring model (shadow mode first)', 'boolean', false, '{}', ARRAY['scoring'], now() + INTERVAL '6 months'),
  ('new_search_ui', 'New Search UI', 'Redesigned search with autocomplete', 'percentage', false, '{}', ARRAY['search', 'ui'], now() + INTERVAL '3 months'),
  ('de_country_launch', 'Germany Launch', 'Enable DE-specific features', 'boolean', false, ARRAY['DE'], ARRAY['multi-country'], now() + INTERVAL '6 months'),
  ('allergen_v2', 'Allergen Filter v2', 'Enhanced allergen filtering UX', 'boolean', false, '{}', ARRAY['allergen', 'ui'], now() + INTERVAL '3 months'),
  ('maintenance_mode', 'Maintenance Mode', 'Redirect all traffic to maintenance page', 'boolean', false, '{}', ARRAY['ops'], NULL),
  ('qa_mode', 'QA Mode', 'Suppress animations and analytics for testing', 'boolean', false, '{}', ARRAY['testing'], NULL)
ON CONFLICT (key) DO NOTHING;

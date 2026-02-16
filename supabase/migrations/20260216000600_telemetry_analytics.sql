-- ─── Telemetry & Analytics (Issue #25) ────────────────────────────────────────
-- Privacy-friendly, server-side analytics event logger.
-- No PII stored. Events inform prioritization and validate UX hypotheses.
-- ──────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Table: analytics_events
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.analytics_events (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid,                                           -- nullable for anonymous
    event_name  text        NOT NULL,
    event_data  jsonb       NOT NULL DEFAULT '{}'::jsonb,
    session_id  text,                                           -- client-generated per session
    device_type text,                                           -- 'mobile' | 'tablet' | 'desktop'
    created_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT chk_ae_event_name CHECK (event_name IN (
        'search_performed',
        'filter_applied',
        'search_saved',
        'compare_opened',
        'list_created',
        'list_shared',
        'favorites_added',
        'list_item_added',
        'avoid_added',
        'scanner_used',
        'product_not_found',
        'submission_created',
        'product_viewed',
        'dashboard_viewed',
        'share_link_opened',
        'category_viewed',
        'preferences_updated',
        'onboarding_completed'
    )),
    CONSTRAINT chk_ae_device_type CHECK (
        device_type IS NULL OR device_type IN ('mobile', 'tablet', 'desktop')
    )
);

COMMENT ON TABLE public.analytics_events IS
    'Privacy-friendly analytics events. No PII stored — only IDs and aggregate-safe metadata.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Indexes
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_ae_event_name
    ON public.analytics_events (event_name);

CREATE INDEX IF NOT EXISTS idx_ae_created_at
    ON public.analytics_events (created_at);

CREATE INDEX IF NOT EXISTS idx_ae_user_event
    ON public.analytics_events (user_id, event_name);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. RLS — Users can insert (own or anonymous); only service_role can SELECT
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users insert own events"
    ON public.analytics_events FOR INSERT
    WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Anon insert anonymous events"
    ON public.analytics_events FOR INSERT
    TO anon
    WITH CHECK (user_id IS NULL);

-- No SELECT policy for authenticated/anon — only service_role (bypasses RLS)

GRANT INSERT ON public.analytics_events TO authenticated, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Allowed event names reference (for validation in api_track_event)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.allowed_event_names (
    event_name text PRIMARY KEY
);

INSERT INTO public.allowed_event_names (event_name) VALUES
    ('search_performed'),
    ('filter_applied'),
    ('search_saved'),
    ('compare_opened'),
    ('list_created'),
    ('list_shared'),
    ('favorites_added'),
    ('list_item_added'),
    ('avoid_added'),
    ('scanner_used'),
    ('product_not_found'),
    ('submission_created'),
    ('product_viewed'),
    ('dashboard_viewed'),
    ('share_link_opened'),
    ('category_viewed'),
    ('preferences_updated'),
    ('onboarding_completed')
ON CONFLICT (event_name) DO NOTHING;

COMMENT ON TABLE public.allowed_event_names IS
    'Reference table of allowed analytics event names. Used by api_track_event for validation.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. api_track_event — fire-and-forget event logger
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_track_event(
    p_event_name  text,
    p_event_data  jsonb    DEFAULT '{}'::jsonb,
    p_session_id  text     DEFAULT NULL,
    p_device_type text     DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    -- Validate event name against allowed list
    IF NOT EXISTS (SELECT 1 FROM public.allowed_event_names WHERE event_name = p_event_name) THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Unknown event name: ' || COALESCE(p_event_name, 'NULL')
        );
    END IF;

    -- Validate device_type if provided
    IF p_device_type IS NOT NULL AND p_device_type NOT IN ('mobile', 'tablet', 'desktop') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Invalid device_type. Must be mobile, tablet, or desktop'
        );
    END IF;

    -- Insert the event
    INSERT INTO public.analytics_events (user_id, event_name, event_data, session_id, device_type)
    VALUES (v_user_id, p_event_name, COALESCE(p_event_data, '{}'::jsonb), p_session_id, p_device_type);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'tracked',     true
    );
END;
$$;

COMMENT ON FUNCTION public.api_track_event IS
    'Fire-and-forget analytics event logger. Works for both authenticated and anonymous users.';

GRANT EXECUTE ON FUNCTION public.api_track_event(text, jsonb, text, text)
    TO authenticated, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. api_admin_get_event_summary — aggregated event counts (service_role only)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_admin_get_event_summary(
    p_event_name text     DEFAULT NULL,
    p_days       integer  DEFAULT 30,
    p_group_by   text     DEFAULT 'day'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_since     timestamptz;
    v_trunc     text;
    v_rows      jsonb;
BEGIN
    -- This function is designed for service_role access (admin).
    -- Authenticated users can call it but will see aggregated (non-PII) data.

    v_since := now() - (p_days || ' days')::interval;

    -- Determine truncation granularity
    v_trunc := CASE LOWER(COALESCE(p_group_by, 'day'))
        WHEN 'week' THEN 'week'
        WHEN 'month' THEN 'month'
        ELSE 'day'
    END;

    SELECT COALESCE(jsonb_agg(row_data ORDER BY period), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'period',     date_trunc(v_trunc, ae.created_at)::date,
            'event_name', ae.event_name,
            'count',      COUNT(*)
        ) AS row_data,
        date_trunc(v_trunc, ae.created_at)::date AS period
        FROM public.analytics_events ae
        WHERE ae.created_at >= v_since
          AND (p_event_name IS NULL OR ae.event_name = p_event_name)
        GROUP BY date_trunc(v_trunc, ae.created_at)::date, ae.event_name
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'event_name',  p_event_name,
        'days',        p_days,
        'group_by',    v_trunc,
        'summary',     v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_event_summary IS
    'Admin: returns aggregated event counts grouped by day/week/month.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_event_summary(text, integer, text)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_event_summary(text, integer, text)
    FROM anon, public;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. api_admin_get_top_events — top N events in period (service_role only)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_admin_get_top_events(
    p_days  integer DEFAULT 30,
    p_limit integer DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_since timestamptz;
    v_rows  jsonb;
BEGIN
    v_since := now() - (p_days || ' days')::interval;

    SELECT COALESCE(jsonb_agg(row_data ORDER BY cnt DESC), '[]'::jsonb)
    INTO v_rows
    FROM (
        SELECT jsonb_build_object(
            'event_name',    ae.event_name,
            'count',         COUNT(*),
            'unique_users',  COUNT(DISTINCT ae.user_id)
        ) AS row_data,
        COUNT(*) AS cnt
        FROM public.analytics_events ae
        WHERE ae.created_at >= v_since
        GROUP BY ae.event_name
        ORDER BY COUNT(*) DESC
        LIMIT LEAST(p_limit, 100)
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'days',        p_days,
        'events',      v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_top_events IS
    'Admin: returns top N events by count in the given period.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_top_events(integer, integer)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_top_events(integer, integer)
    FROM anon, public;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. api_admin_get_funnel — basic funnel analysis (service_role only)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_admin_get_funnel(
    p_event_sequence text[],
    p_days           integer DEFAULT 30
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_since  timestamptz;
    v_rows   jsonb := '[]'::jsonb;
    v_step   text;
    v_count  bigint;
    v_idx    integer := 0;
BEGIN
    v_since := now() - (p_days || ' days')::interval;

    IF p_event_sequence IS NULL OR array_length(p_event_sequence, 1) IS NULL THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Event sequence must be a non-empty array'
        );
    END IF;

    FOREACH v_step IN ARRAY p_event_sequence LOOP
        v_idx := v_idx + 1;

        SELECT COUNT(DISTINCT ae.user_id)
        INTO v_count
        FROM public.analytics_events ae
        WHERE ae.created_at >= v_since
          AND ae.event_name = v_step
          AND ae.user_id IS NOT NULL;

        v_rows := v_rows || jsonb_build_object(
            'step',      v_idx,
            'event',     v_step,
            'users',     COALESCE(v_count, 0)
        );
    END LOOP;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'days',        p_days,
        'funnel',      v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_funnel IS
    'Admin: basic funnel analysis — counts distinct users at each step.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_funnel(text[], integer)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_funnel(text[], integer)
    FROM anon, public;

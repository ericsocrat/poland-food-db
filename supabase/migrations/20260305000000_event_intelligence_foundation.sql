-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Event Intelligence Foundation (Phase 1 + Phase 2)
-- Issue: #190 — Event-Based Product Intelligence Layer
--
-- Creates:
--   1. event_schema_registry — schema-versioned event type definitions
--   2. Evolves analytics_events — adds country, consent, schema versioning
--   3. Updates api_track_event() — backward-compatible new params
--   4. Adds api_validate_event_schema() — validates event data against registry
--   5. Updates admin functions — country-scoped filtering
--
-- Backward compatibility:
--   - All new columns have defaults — existing callers unaffected
--   - api_track_event() keeps existing 4-param signature; new params are optional
--   - allowed_event_names table retained (not dropped) for gradual migration
--   - Existing CHECK constraint on event_name preserved
--
-- Rollback:
--   DROP FUNCTION IF EXISTS api_validate_event_schema(text, integer, jsonb);
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS schema_version;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS anonymous_id;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS country;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS locale;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS route;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS app_version;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS consent_level;
--   ALTER TABLE analytics_events DROP COLUMN IF EXISTS client_timestamp;
--   ALTER TABLE analytics_events DROP CONSTRAINT IF EXISTS chk_ae_consent_level;
--   ALTER TABLE analytics_events DROP CONSTRAINT IF EXISTS chk_ae_event_country;
--   DROP TABLE IF EXISTS event_schema_registry;
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 1: Event Schema Registry
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.event_schema_registry (
    id              serial      PRIMARY KEY,
    event_type      text        NOT NULL,
    schema_version  integer     NOT NULL DEFAULT 1,
    status          text        NOT NULL DEFAULT 'active',
    json_schema     jsonb       NOT NULL,
    description     text,
    pii_fields      text[]      DEFAULT '{}',
    retention_days  integer     DEFAULT 90,
    created_at      timestamptz NOT NULL DEFAULT now(),

    UNIQUE (event_type, schema_version),
    CONSTRAINT chk_esr_status CHECK (status IN ('active', 'deprecated', 'retired')),
    CONSTRAINT chk_esr_retention CHECK (retention_days > 0 AND retention_days <= 3650),
    CONSTRAINT chk_esr_version CHECK (schema_version > 0)
);

COMMENT ON TABLE public.event_schema_registry IS
    'Schema-versioned event type definitions. Each event type has a JSON Schema '
    'for its event_data payload, PII field declarations, and retention policy. '
    'Replaces allowed_event_names as the authoritative event type registry.';

COMMENT ON COLUMN public.event_schema_registry.json_schema IS
    'JSON Schema (draft-07 compatible) defining the expected shape of event_data.';
COMMENT ON COLUMN public.event_schema_registry.pii_fields IS
    'Array of field paths within event_data that contain PII and need scrubbing before export.';
COMMENT ON COLUMN public.event_schema_registry.retention_days IS
    'How long raw events of this type are kept before purging.';

-- RLS: read for authenticated, write for service_role only
ALTER TABLE public.event_schema_registry ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'event_schema_registry' AND policyname = 'Authenticated read schema registry'
    ) THEN
        CREATE POLICY "Authenticated read schema registry"
            ON public.event_schema_registry FOR SELECT
            TO authenticated
            USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'event_schema_registry' AND policyname = 'Service role manages schema registry'
    ) THEN
        CREATE POLICY "Service role manages schema registry"
            ON public.event_schema_registry FOR ALL
            TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

GRANT SELECT ON public.event_schema_registry TO authenticated;
GRANT ALL    ON public.event_schema_registry TO service_role;

-- Index for lookups by event_type + active status
CREATE INDEX IF NOT EXISTS idx_esr_active
    ON public.event_schema_registry (event_type)
    WHERE status = 'active';

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 1b: Seed event schema registry
-- ═══════════════════════════════════════════════════════════════════════════════

-- Migrate existing allowed_event_names into the registry with minimal schemas
INSERT INTO public.event_schema_registry (event_type, schema_version, json_schema, description, retention_days)
SELECT
    event_name,
    1,
    '{"type": "object", "additionalProperties": true}'::jsonb,
    'Migrated from allowed_event_names',
    90
FROM public.allowed_event_names
ON CONFLICT (event_type, schema_version) DO NOTHING;

-- Add enhanced schemas for key event types (from #190 spec)
INSERT INTO public.event_schema_registry (event_type, schema_version, json_schema, description, pii_fields, retention_days)
VALUES
    -- Search events: capture query, result count, filters, click-through
    ('search_performed', 2, '{
        "type": "object",
        "required": ["query", "result_count"],
        "properties": {
            "query":                    {"type": "string", "maxLength": 200},
            "result_count":             {"type": "integer", "minimum": 0},
            "filters_active":           {"type": "array", "items": {"type": "string"}},
            "sort_by":                  {"type": "string"},
            "page":                     {"type": "integer", "minimum": 1},
            "time_to_first_result_ms":  {"type": "integer", "minimum": 0},
            "clicked_product_id":       {"type": ["integer", "null"]},
            "clicked_position":         {"type": ["integer", "null"]}
        }
    }'::jsonb,
    'User performs product search (v2: structured with click-through tracking)',
    '{}', 180),

    -- Product view: capture source, dwell time, scroll depth
    ('product_viewed', 2, '{
        "type": "object",
        "required": ["product_id"],
        "properties": {
            "product_id":        {"type": "integer"},
            "source":            {"type": "string", "enum": ["search", "category", "comparison", "alternative", "direct", "scan", "list"]},
            "dwell_time_ms":     {"type": ["integer", "null"], "minimum": 0},
            "scroll_depth_pct":  {"type": ["integer", "null"], "minimum": 0, "maximum": 100},
            "sections_viewed":   {"type": "array", "items": {"type": "string"}}
        }
    }'::jsonb,
    'User views product detail page (v2: structured with engagement tracking)',
    '{}', 180),

    -- Allergen filter toggle
    ('filter_applied', 2, '{
        "type": "object",
        "required": ["filter_type", "action"],
        "properties": {
            "filter_type":           {"type": "string"},
            "filter_value":          {"type": "string"},
            "action":                {"type": "string", "enum": ["add", "remove", "clear"]},
            "result_count_before":   {"type": "integer", "minimum": 0},
            "result_count_after":    {"type": "integer", "minimum": 0}
        }
    }'::jsonb,
    'User toggles a filter (v2: structured with before/after counts)',
    '{}', 180),

    -- Score explanation view
    ('score_explanation_viewed', 1, '{
        "type": "object",
        "required": ["product_id"],
        "properties": {
            "product_id":          {"type": "integer"},
            "score":               {"type": "integer", "minimum": 1, "maximum": 100},
            "factors_expanded":    {"type": "array", "items": {"type": "string"}},
            "time_on_page_ms":     {"type": ["integer", "null"], "minimum": 0}
        }
    }'::jsonb,
    'User views score explanation breakdown',
    '{}', 90),

    -- Comparison event
    ('compare_opened', 2, '{
        "type": "object",
        "required": ["product_ids"],
        "properties": {
            "product_ids":         {"type": "array", "items": {"type": "integer"}, "minItems": 2, "maxItems": 4},
            "comparison_source":   {"type": "string"},
            "winner_product_id":   {"type": ["integer", "null"]},
            "time_on_page_ms":     {"type": ["integer", "null"], "minimum": 0}
        }
    }'::jsonb,
    'User compares products (v2: structured with outcome tracking)',
    '{}', 180),

    -- Alternative click — user clicks a healthier alternative
    ('alternative_clicked', 1, '{
        "type": "object",
        "required": ["source_product_id", "target_product_id"],
        "properties": {
            "source_product_id":   {"type": "integer"},
            "target_product_id":   {"type": "integer"},
            "score_improvement":   {"type": "integer"},
            "rank_position":       {"type": "integer", "minimum": 1},
            "source_type":         {"type": "string", "enum": ["healthier_alternative", "similar_product"]}
        }
    }'::jsonb,
    'User clicks a healthier alternative or similar product',
    '{}', 180),

    -- Page view — generic page navigation tracking
    ('page_view', 1, '{
        "type": "object",
        "required": ["route"],
        "properties": {
            "route":            {"type": "string", "maxLength": 200},
            "referrer_route":   {"type": ["string", "null"]},
            "load_time_ms":     {"type": ["integer", "null"], "minimum": 0},
            "viewport_width":   {"type": "integer", "minimum": 0},
            "viewport_height":  {"type": "integer", "minimum": 0}
        }
    }'::jsonb,
    'User navigates to a page',
    '{}', 60),

    -- Client error capture
    ('client_error', 1, '{
        "type": "object",
        "required": ["error_type", "message"],
        "properties": {
            "error_type":   {"type": "string"},
            "message":      {"type": "string", "maxLength": 500},
            "route":        {"type": "string"},
            "component":    {"type": ["string", "null"]},
            "stack_hash":   {"type": ["string", "null"]}
        }
    }'::jsonb,
    'Client-side error captured (allowed at essential consent level)',
    '{}', 30)
ON CONFLICT (event_type, schema_version) DO NOTHING;

-- Also register new event types in allowed_event_names for backward compat
INSERT INTO public.allowed_event_names (event_name) VALUES
    ('score_explanation_viewed'),
    ('alternative_clicked'),
    ('page_view'),
    ('client_error')
ON CONFLICT (event_name) DO NOTHING;

-- Update the CHECK constraint to include new event names
ALTER TABLE public.analytics_events DROP CONSTRAINT IF EXISTS chk_ae_event_name;
ALTER TABLE public.analytics_events ADD CONSTRAINT chk_ae_event_name CHECK (event_name IN (
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
    'onboarding_completed',
    'image_search_performed',
    'offline_cache_cleared',
    'push_notification_enabled',
    'push_notification_disabled',
    'push_notification_denied',
    'push_notification_dismissed',
    'pwa_install_prompted',
    'pwa_install_accepted',
    'pwa_install_dismissed',
    'user_data_exported',
    'account_deleted',
    'onboarding_step',
    'recipe_view',
    -- New event types from #190
    'score_explanation_viewed',
    'alternative_clicked',
    'page_view',
    'client_error'
));

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 2: Evolve analytics_events table
-- ═══════════════════════════════════════════════════════════════════════════════

-- Add new columns with defaults (backward compatible — existing INSERT calls unaffected)
ALTER TABLE public.analytics_events
    ADD COLUMN IF NOT EXISTS schema_version  integer     NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS anonymous_id    uuid,
    ADD COLUMN IF NOT EXISTS country         text        NOT NULL DEFAULT 'PL',
    ADD COLUMN IF NOT EXISTS locale          text        NOT NULL DEFAULT 'pl',
    ADD COLUMN IF NOT EXISTS route           text,
    ADD COLUMN IF NOT EXISTS app_version     text,
    ADD COLUMN IF NOT EXISTS consent_level   text        NOT NULL DEFAULT 'analytics',
    ADD COLUMN IF NOT EXISTS client_timestamp timestamptz;

-- Constraints on new columns
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_ae_consent_level'
    ) THEN
        ALTER TABLE public.analytics_events
            ADD CONSTRAINT chk_ae_consent_level
            CHECK (consent_level IN ('essential', 'analytics', 'full'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_ae_event_country'
    ) THEN
        ALTER TABLE public.analytics_events
            ADD CONSTRAINT chk_ae_event_country
            CHECK (country IN ('PL', 'DE'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_ae_schema_version'
    ) THEN
        ALTER TABLE public.analytics_events
            ADD CONSTRAINT chk_ae_schema_version
            CHECK (schema_version > 0);
    END IF;
END $$;

COMMENT ON COLUMN public.analytics_events.schema_version IS
    'Version of the event schema used — maps to event_schema_registry(event_type, schema_version).';
COMMENT ON COLUMN public.analytics_events.anonymous_id IS
    'Device-level anonymous ID (UUID v7). No PII linkage.';
COMMENT ON COLUMN public.analytics_events.country IS
    'Country context for the event (PL or DE).';
COMMENT ON COLUMN public.analytics_events.locale IS
    'User locale when the event was fired (e.g., pl, en, de).';
COMMENT ON COLUMN public.analytics_events.route IS
    'Page route when the event occurred (e.g., /app/product/42).';
COMMENT ON COLUMN public.analytics_events.app_version IS
    'Frontend app version string.';
COMMENT ON COLUMN public.analytics_events.consent_level IS
    'GDPR consent level: essential (errors only), analytics (usage data), full (all events incl. experiments).';
COMMENT ON COLUMN public.analytics_events.client_timestamp IS
    'Timestamp captured on the client device (may differ from server_timestamp/created_at).';

-- New indexes for country-scoped and consent queries
CREATE INDEX IF NOT EXISTS idx_ae_country_event
    ON public.analytics_events (country, event_name, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ae_anonymous
    ON public.analytics_events (anonymous_id)
    WHERE anonymous_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ae_consent
    ON public.analytics_events (consent_level, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ae_event_data_gin
    ON public.analytics_events USING gin (event_data jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_ae_route
    ON public.analytics_events (route, created_at DESC)
    WHERE route IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 2b: Update api_track_event — backward-compatible new params
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old function signature cleanly, then recreate with extended params
DROP FUNCTION IF EXISTS public.api_track_event(text, jsonb, text, text);

CREATE OR REPLACE FUNCTION public.api_track_event(
    p_event_name        text,
    p_event_data        jsonb       DEFAULT '{}'::jsonb,
    p_session_id        text        DEFAULT NULL,
    p_device_type       text        DEFAULT NULL,
    p_anonymous_id      uuid        DEFAULT NULL,
    p_country           text        DEFAULT 'PL',
    p_locale            text        DEFAULT 'pl',
    p_route             text        DEFAULT NULL,
    p_app_version       text        DEFAULT NULL,
    p_consent_level     text        DEFAULT 'analytics',
    p_client_timestamp  timestamptz DEFAULT NULL,
    p_schema_version    integer     DEFAULT 1
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

    -- Validate consent_level
    IF p_consent_level NOT IN ('essential', 'analytics', 'full') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Invalid consent_level. Must be essential, analytics, or full'
        );
    END IF;

    -- Validate country
    IF p_country NOT IN ('PL', 'DE') THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Invalid country. Must be PL or DE'
        );
    END IF;

    -- Validate schema_version
    IF p_schema_version < 1 THEN
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'error',       'Invalid schema_version. Must be >= 1'
        );
    END IF;

    -- Consent-based gating: essential level only allows error events
    IF p_consent_level = 'essential' AND p_event_name NOT IN ('client_error') THEN
        -- Silently accept but do not store non-error events at essential consent
        RETURN jsonb_build_object(
            'api_version', '1.0',
            'tracked',     false,
            'reason',      'Event suppressed by consent_level=essential'
        );
    END IF;

    -- Insert the event with all columns
    INSERT INTO public.analytics_events (
        user_id, event_name, event_data, session_id, device_type,
        schema_version, anonymous_id, country, locale, route,
        app_version, consent_level, client_timestamp
    ) VALUES (
        v_user_id, p_event_name, COALESCE(p_event_data, '{}'::jsonb),
        p_session_id, p_device_type,
        COALESCE(p_schema_version, 1), p_anonymous_id, p_country, p_locale, p_route,
        p_app_version, p_consent_level, p_client_timestamp
    );

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'tracked',     true
    );
END;
$$;

COMMENT ON FUNCTION public.api_track_event IS
    'Fire-and-forget analytics event logger with consent gating, country scoping, '
    'and schema versioning. Backward compatible: first 4 params match original signature. '
    'Events at consent_level=essential are suppressed except for client_error. '
    'Default consent_level is analytics for backward compatibility with existing callers.';

GRANT EXECUTE ON FUNCTION public.api_track_event(
    text, jsonb, text, text, uuid, text, text, text, text, text, timestamptz, integer
) TO authenticated, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 2c: api_validate_event_schema — validates event_data against registry
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_validate_event_schema(
    p_event_type     text,
    p_schema_version integer DEFAULT NULL,
    p_event_data     jsonb   DEFAULT '{}'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_registry record;
    v_required text[];
    v_key      text;
    v_missing  text[] := '{}';
BEGIN
    -- Look up the schema (latest active version if version not specified)
    SELECT * INTO v_registry
    FROM public.event_schema_registry
    WHERE event_type = p_event_type
      AND (p_schema_version IS NULL OR schema_version = p_schema_version)
      AND status = 'active'
    ORDER BY schema_version DESC
    LIMIT 1;

    IF v_registry IS NULL THEN
        RETURN jsonb_build_object(
            'valid',   false,
            'errors',  jsonb_build_array('Unknown event_type or no active schema: ' || COALESCE(p_event_type, 'NULL'))
        );
    END IF;

    -- Basic required-field validation from json_schema.required
    IF v_registry.json_schema ? 'required' AND jsonb_typeof(v_registry.json_schema -> 'required') = 'array' THEN
        SELECT array_agg(r::text)
        INTO v_required
        FROM jsonb_array_elements_text(v_registry.json_schema -> 'required') r;

        IF v_required IS NOT NULL THEN
            FOREACH v_key IN ARRAY v_required LOOP
                IF NOT (p_event_data ? v_key) THEN
                    v_missing := array_append(v_missing, v_key);
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF array_length(v_missing, 1) > 0 THEN
        RETURN jsonb_build_object(
            'valid',   false,
            'errors',  to_jsonb(v_missing),
            'message', 'Missing required fields'
        );
    END IF;

    RETURN jsonb_build_object(
        'valid',          true,
        'event_type',     v_registry.event_type,
        'schema_version', v_registry.schema_version,
        'retention_days', v_registry.retention_days
    );
END;
$$;

COMMENT ON FUNCTION public.api_validate_event_schema IS
    'Validates event_data against the registered JSON Schema for an event type. '
    'Checks required fields. Returns {valid: true/false, errors: [...]}. '
    'If p_schema_version is NULL, uses the latest active version.';

GRANT EXECUTE ON FUNCTION public.api_validate_event_schema(text, integer, jsonb)
    TO authenticated, anon;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 2d: Update admin functions for country scoping
-- ═══════════════════════════════════════════════════════════════════════════════

-- Drop old signatures to avoid overload ambiguity
DROP FUNCTION IF EXISTS public.api_admin_get_event_summary(text, integer, text);
DROP FUNCTION IF EXISTS public.api_admin_get_top_events(integer, integer);
DROP FUNCTION IF EXISTS public.api_admin_get_funnel(text[], integer);

-- Enhanced event summary with optional country filter
CREATE OR REPLACE FUNCTION public.api_admin_get_event_summary(
    p_event_name text     DEFAULT NULL,
    p_days       integer  DEFAULT 30,
    p_group_by   text     DEFAULT 'day',
    p_country    text     DEFAULT NULL
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
    v_since := now() - (p_days || ' days')::interval;

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
            'country',    ae.country,
            'count',      COUNT(*)
        ) AS row_data,
        date_trunc(v_trunc, ae.created_at)::date AS period
        FROM public.analytics_events ae
        WHERE ae.created_at >= v_since
          AND (p_event_name IS NULL OR ae.event_name = p_event_name)
          AND (p_country IS NULL OR ae.country = p_country)
        GROUP BY date_trunc(v_trunc, ae.created_at)::date, ae.event_name, ae.country
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'event_name',  p_event_name,
        'country',     p_country,
        'days',        p_days,
        'group_by',    v_trunc,
        'summary',     v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_event_summary IS
    'Admin: returns aggregated event counts grouped by day/week/month, optionally filtered by country.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_event_summary(text, integer, text, text)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_event_summary(text, integer, text, text)
    FROM anon, public;

-- Enhanced top events with country filter
CREATE OR REPLACE FUNCTION public.api_admin_get_top_events(
    p_days    integer DEFAULT 30,
    p_limit   integer DEFAULT 10,
    p_country text    DEFAULT NULL
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
            'unique_users',  COUNT(DISTINCT ae.user_id),
            'unique_sessions', COUNT(DISTINCT ae.session_id)
        ) AS row_data,
        COUNT(*) AS cnt
        FROM public.analytics_events ae
        WHERE ae.created_at >= v_since
          AND (p_country IS NULL OR ae.country = p_country)
        GROUP BY ae.event_name
        ORDER BY COUNT(*) DESC
        LIMIT LEAST(p_limit, 100)
    ) sub;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'days',        p_days,
        'country',     p_country,
        'events',      v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_top_events IS
    'Admin: returns top N events by count in the given period, optionally filtered by country.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_top_events(integer, integer, text)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_top_events(integer, integer, text)
    FROM anon, public;

-- Enhanced funnel with country filter
CREATE OR REPLACE FUNCTION public.api_admin_get_funnel(
    p_event_sequence text[],
    p_days           integer DEFAULT 30,
    p_country        text    DEFAULT NULL
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
          AND ae.user_id IS NOT NULL
          AND (p_country IS NULL OR ae.country = p_country);

        v_rows := v_rows || jsonb_build_object(
            'step',      v_idx,
            'event',     v_step,
            'users',     COALESCE(v_count, 0)
        );
    END LOOP;

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'days',        p_days,
        'country',     p_country,
        'funnel',      v_rows
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_funnel IS
    'Admin: basic funnel analysis — counts distinct users at each step, optionally filtered by country.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_funnel(text[], integer, text)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_funnel(text[], integer, text)
    FROM anon, public;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Phase 2e: api_get_event_schemas — list registered event schemas
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_get_event_schemas(
    p_event_type text    DEFAULT NULL,
    p_status     text    DEFAULT 'active'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_rows jsonb;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'event_type',     esr.event_type,
            'schema_version', esr.schema_version,
            'status',         esr.status,
            'description',    esr.description,
            'json_schema',    esr.json_schema,
            'pii_fields',     esr.pii_fields,
            'retention_days', esr.retention_days
        ) ORDER BY esr.event_type, esr.schema_version
    ), '[]'::jsonb)
    INTO v_rows
    FROM public.event_schema_registry esr
    WHERE (p_event_type IS NULL OR esr.event_type = p_event_type)
      AND (p_status IS NULL OR esr.status = p_status);

    RETURN jsonb_build_object(
        'api_version', '1.0',
        'schemas',     v_rows,
        'count',       jsonb_array_length(COALESCE(v_rows, '[]'::jsonb))
    );
END;
$$;

COMMENT ON FUNCTION public.api_get_event_schemas IS
    'Returns registered event schemas, optionally filtered by event_type and status.';

GRANT EXECUTE ON FUNCTION public.api_get_event_schemas(text, text)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION public.api_get_event_schemas(text, text)
    FROM anon, public;

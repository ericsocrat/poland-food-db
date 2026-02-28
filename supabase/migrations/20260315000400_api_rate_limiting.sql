-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260315000400_api_rate_limiting.sql
-- Ticket:    #472 — API abuse rate limiting (search, events, EAN enumeration)
-- ═══════════════════════════════════════════════════════════════════════════
-- Adds generic per-endpoint rate limiting to 6 API functions.
--
-- Phase 1: Configuration + tracking tables + generic check function
-- Phase 2: Inject rate limit checks into 5 plpgsql API functions
-- Phase 3: Convert api_better_alternatives (SQL → plpgsql) with rate limit
-- Phase 4: Retention policy (2-day cleanup)
-- Phase 5: RLS + grants
-- ═══════════════════════════════════════════════════════════════════════════
-- To roll back: DROP TABLE IF EXISTS api_rate_limit_log, api_rate_limits CASCADE;
--               then redeploy functions from their previous migrations.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── Phase 1A: Rate limit configuration table ──────────────────────────────

CREATE TABLE IF NOT EXISTS public.api_rate_limits (
    endpoint       text    PRIMARY KEY,
    max_requests   integer NOT NULL
        CONSTRAINT chk_arl_max_positive CHECK (max_requests > 0),
    window_seconds integer NOT NULL
        CONSTRAINT chk_arl_window_positive CHECK (window_seconds > 0),
    description    text
);

COMMENT ON TABLE public.api_rate_limits IS
    'Per-endpoint rate limit configuration. Each row defines max_requests '
    'within a sliding window of window_seconds for authenticated users.';

-- Seed default limits
INSERT INTO api_rate_limits (endpoint, max_requests, window_seconds, description) VALUES
    ('api_search_products',        30,   60, 'Search: 30 requests per minute'),
    ('api_search_autocomplete',    60,   60, 'Autocomplete: 60 requests per minute'),
    ('api_product_detail_by_ean', 100, 3600, 'EAN lookup: 100 per hour'),
    ('api_track_event',           500, 3600, 'Events: 500 per hour'),
    ('api_get_filter_options',     10,   60, 'Filter options: 10 per minute'),
    ('api_better_alternatives',    30,   60, 'Alternatives: 30 per minute')
ON CONFLICT (endpoint) DO UPDATE SET
    max_requests   = EXCLUDED.max_requests,
    window_seconds = EXCLUDED.window_seconds,
    description    = EXCLUDED.description;


-- ─── Phase 1B: Rate limit tracking log ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.api_rate_limit_log (
    id        bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id   uuid        NOT NULL,
    endpoint  text        NOT NULL,
    called_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.api_rate_limit_log IS
    'Ephemeral request log for rate limit enforcement. '
    'Cleaned by retention_policies (2-day window). '
    'Not FK-constrained to api_rate_limits for cleanup flexibility.';

CREATE INDEX IF NOT EXISTS idx_rate_limit_log_lookup
    ON api_rate_limit_log (user_id, endpoint, called_at DESC);


-- ─── Phase 1C: Generic rate limit check function ───────────────────────────

CREATE OR REPLACE FUNCTION public.check_api_rate_limit(
    p_user_id  uuid,
    p_endpoint text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_max_requests   integer;
    v_window_seconds integer;
    v_count          integer;
    v_oldest         timestamptz;
    v_window         interval;
BEGIN
    -- NULL user → always allowed (anon users not rate-limited at DB level)
    IF p_user_id IS NULL THEN
        RETURN jsonb_build_object('allowed', true);
    END IF;

    -- Lookup endpoint configuration
    SELECT arl.max_requests, arl.window_seconds
    INTO   v_max_requests, v_window_seconds
    FROM   api_rate_limits arl
    WHERE  arl.endpoint = p_endpoint;

    -- No limit configured → allow
    IF NOT FOUND THEN
        RETURN jsonb_build_object('allowed', true);
    END IF;

    v_window := make_interval(secs => v_window_seconds);

    -- Count recent calls within window
    SELECT COUNT(*), MIN(l.called_at)
    INTO   v_count, v_oldest
    FROM   api_rate_limit_log l
    WHERE  l.user_id  = p_user_id
      AND  l.endpoint = p_endpoint
      AND  l.called_at > now() - v_window;

    -- Over limit → reject
    IF v_count >= v_max_requests THEN
        RETURN jsonb_build_object(
            'allowed',            false,
            'current_count',      v_count,
            'max_allowed',        v_max_requests,
            'window_seconds',     v_window_seconds,
            'retry_after_seconds', GREATEST(0,
                EXTRACT(EPOCH FROM (v_oldest + v_window - now()))::integer)
        );
    END IF;

    -- Under limit → log and allow
    INSERT INTO api_rate_limit_log (user_id, endpoint)
    VALUES (p_user_id, p_endpoint);

    RETURN jsonb_build_object(
        'allowed',   true,
        'remaining', v_max_requests - v_count - 1
    );
END;
$$;

COMMENT ON FUNCTION public.check_api_rate_limit(uuid, text) IS
    'Generic per-endpoint rate limiter. Returns {allowed, remaining} or '
    '{allowed:false, retry_after_seconds, current_count, max_allowed, window_seconds}. '
    'NULL user_id always returns allowed:true (anon bypass). '
    'Unconfigured endpoints always return allowed:true.';


-- ─── Phase 2: Inject rate limit checks into 5 plpgsql API functions ────────
-- Uses pg_get_functiondef() to dynamically patch existing function bodies.
-- This avoids duplicating ~500 lines of function source in the migration.
-- Idempotent: skips functions that already contain check_api_rate_limit.

DO $patch$
DECLARE
    v_funcs   text[] := ARRAY[
        'api_search_products',
        'api_search_autocomplete',
        'api_product_detail_by_ean',
        'api_track_event',
        'api_get_filter_options'
    ];
    v_func    text;
    v_def     text;
    v_patched text;
    v_block   text;
BEGIN
    FOREACH v_func IN ARRAY v_funcs LOOP
        -- Get current function definition
        SELECT pg_get_functiondef(p.oid)
        INTO   v_def
        FROM   pg_proc p
        WHERE  p.proname = v_func
          AND  p.pronamespace = 'public'::regnamespace;

        IF v_def IS NULL THEN
            RAISE EXCEPTION 'Function public.% not found', v_func;
        END IF;

        -- Skip if already patched (idempotency)
        IF v_def LIKE '%check_api_rate_limit%' THEN
            RAISE NOTICE 'Function % already has rate limit check, skipping', v_func;
            CONTINUE;
        END IF;

        -- Build the rate limit injection block
        v_block := '    -- Rate limit enforcement (#472)' || chr(10)
                || '    v_rate_check := check_api_rate_limit(auth.uid(), '
                || quote_literal(v_func) || ');' || chr(10)
                || '    IF NOT (v_rate_check->>''allowed'')::boolean THEN' || chr(10)
                || '        RETURN jsonb_build_object(' || chr(10)
                || '            ''api_version'',         ''1.0'',' || chr(10)
                || '            ''error'',               ''rate_limit_exceeded'',' || chr(10)
                || '            ''message'',             ''Too many requests. Please try again later.'',' || chr(10)
                || '            ''retry_after_seconds'', (v_rate_check->>''retry_after_seconds'')::integer,' || chr(10)
                || '            ''current_count'',       (v_rate_check->>''current_count'')::integer,' || chr(10)
                || '            ''max_allowed'',         (v_rate_check->>''max_allowed'')::integer' || chr(10)
                || '        );' || chr(10)
                || '    END IF;' || chr(10) || chr(10);

        v_patched := v_def;

        -- Add v_rate_check variable to DECLARE section
        v_patched := regexp_replace(
            v_patched,
            'DECLARE' || chr(10),
            'DECLARE' || chr(10) || '    v_rate_check  jsonb;' || chr(10)
        );

        -- Inject rate limit check block after BEGIN
        v_patched := regexp_replace(
            v_patched,
            'BEGIN' || chr(10),
            'BEGIN' || chr(10) || v_block
        );

        -- Verify the patch was applied
        IF v_patched NOT LIKE '%check_api_rate_limit%' THEN
            RAISE EXCEPTION 'Failed to patch % — rate limit check not found in output', v_func;
        END IF;

        -- Execute the patched CREATE OR REPLACE FUNCTION
        EXECUTE v_patched;
        RAISE NOTICE 'Patched % with rate limit check', v_func;
    END LOOP;
END;
$patch$;


-- ─── Phase 3: Convert api_better_alternatives to plpgsql with rate limit ───
-- Original was LANGUAGE sql — cannot inject IF/THEN logic without conversion.

CREATE OR REPLACE FUNCTION public.api_better_alternatives(
    p_product_id              bigint,
    p_same_category           boolean  DEFAULT true,
    p_limit                   integer  DEFAULT 5,
    p_diet_preference         text     DEFAULT NULL,
    p_avoid_allergens         text[]   DEFAULT NULL,
    p_strict_diet             boolean  DEFAULT false,
    p_strict_allergen         boolean  DEFAULT false,
    p_treat_may_contain       boolean  DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    v_rate_check jsonb;
    v_result     jsonb;
BEGIN
    -- Rate limit enforcement (#472)
    v_rate_check := check_api_rate_limit(auth.uid(), 'api_better_alternatives');
    IF NOT (v_rate_check->>'allowed')::boolean THEN
        RETURN jsonb_build_object(
            'api_version',         '1.0',
            'error',               'rate_limit_exceeded',
            'message',             'Too many requests. Please try again later.',
            'retry_after_seconds', (v_rate_check->>'retry_after_seconds')::integer,
            'current_count',       (v_rate_check->>'current_count')::integer,
            'max_allowed',         (v_rate_check->>'max_allowed')::integer
        );
    END IF;

    -- Original SQL body preserved as SELECT ... INTO
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'source_product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'brand',              m.brand,
            'category',           m.category,
            'unhealthiness_score',m.unhealthiness_score,
            'nutri_score',        m.nutri_score_label
        ),
        'search_scope',    CASE WHEN p_same_category THEN 'same_category' ELSE 'all_categories' END,
        'alternatives',    COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_improvement',  alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity,
                'shared_ingredients', alt.shared_ingredients
            ))
            FROM find_better_alternatives(
                p_product_id, p_same_category,
                LEAST(GREATEST(p_limit, 1), 20),
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain
            ) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives(
                p_product_id, p_same_category,
                LEAST(GREATEST(p_limit, 1), 20),
                p_diet_preference, p_avoid_allergens,
                p_strict_diet, p_strict_allergen, p_treat_may_contain
            )
        ), 0)
    )
    INTO v_result
    FROM v_master m
    WHERE m.product_id = p_product_id;

    RETURN v_result;
END;
$function$;

COMMENT ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) IS
    'Healthier alternatives with optional diet/allergen filtering. '
    'Country isolation is automatic (inferred from source product). '
    'All preference params default to NULL/false — existing callers unaffected. '
    'Rate-limited via check_api_rate_limit (#472).';


-- ─── Phase 4: Retention policy for rate limit log ──────────────────────────

INSERT INTO retention_policies (table_name, timestamp_column, active_retention_days, is_enabled)
VALUES ('api_rate_limit_log', 'called_at', 2, true)
ON CONFLICT (table_name) DO UPDATE SET
    active_retention_days = EXCLUDED.active_retention_days,
    is_enabled            = EXCLUDED.is_enabled;


-- ─── Phase 5: RLS + grants ─────────────────────────────────────────────────

-- api_rate_limits: config table — read for authenticated, full for service_role
ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'api_rate_limits_select_authenticated') THEN
        CREATE POLICY api_rate_limits_select_authenticated
            ON api_rate_limits FOR SELECT TO authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'api_rate_limits_all_service') THEN
        CREATE POLICY api_rate_limits_all_service
            ON api_rate_limits FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

GRANT SELECT ON api_rate_limits TO authenticated;
GRANT ALL    ON api_rate_limits TO service_role;

-- api_rate_limit_log: ephemeral tracking — no direct access for users, full for service_role
ALTER TABLE public.api_rate_limit_log ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'api_rate_limit_log_all_service') THEN
        CREATE POLICY api_rate_limit_log_all_service
            ON api_rate_limit_log FOR ALL TO service_role USING (true) WITH CHECK (true);
    END IF;
END $$;

GRANT ALL ON api_rate_limit_log TO service_role;

-- check_api_rate_limit: callable by authenticated users and service_role
REVOKE EXECUTE ON FUNCTION public.check_api_rate_limit(uuid, text) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.check_api_rate_limit(uuid, text) TO authenticated, service_role;

-- Preserve existing grants on patched functions (CREATE OR REPLACE preserves them,
-- but explicitly ensure api_better_alternatives retains correct grants after
-- SQL → plpgsql conversion)
REVOKE EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.api_better_alternatives(
    bigint, boolean, integer, text, text[], boolean, boolean, boolean
) TO authenticated, service_role;

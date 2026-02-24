-- ─── Business-Level Metrics Dashboard (Issue #188) ─────────────────────────
-- Pre-aggregation table, 10 core business metric functions, nightly
-- aggregation, and admin RPC wrappers for the /admin/metrics dashboard.
-- ────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. New event types
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.allowed_event_names (event_name) VALUES
    ('onboarding_step'),
    ('recipe_view')
ON CONFLICT (event_name) DO NOTHING;

-- Update the CHECK constraint on analytics_events to include new event types
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
    -- New for #188
    'onboarding_step',
    'recipe_view'
));

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Pre-Aggregation Table: analytics_daily
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.analytics_daily (
    date     date    NOT NULL,
    metric   text    NOT NULL,
    value    numeric NOT NULL DEFAULT 0,
    metadata jsonb   NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (date, metric)
);

COMMENT ON TABLE public.analytics_daily IS
    'Pre-aggregated daily metrics for fast dashboard queries. Populated by aggregate_daily_metrics().';

-- RLS: no SELECT policy for authenticated/anon — only service_role + SECURITY DEFINER functions
ALTER TABLE public.analytics_daily ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.analytics_daily TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Core Business Metric Functions (10 of 10)
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Daily Active Users ──────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_dau(target_date date DEFAULT CURRENT_DATE)
RETURNS bigint
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT count(DISTINCT user_id)
    FROM analytics_events
    WHERE created_at::date = target_date
      AND user_id IS NOT NULL;
$$;

COMMENT ON FUNCTION public.metric_dau IS 'Returns count of distinct authenticated users active on target_date.';

-- ─── 2. Searches Per Day ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_searches_per_day(target_date date DEFAULT CURRENT_DATE)
RETURNS bigint
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT count(*)
    FROM analytics_events
    WHERE event_name = 'search_performed'
      AND created_at::date = target_date;
$$;

COMMENT ON FUNCTION public.metric_searches_per_day IS 'Total search events on target_date.';

-- ─── 3. Top Search Queries ──────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_top_queries(
    target_date date DEFAULT CURRENT_DATE,
    limit_count int  DEFAULT 20
)
RETURNS TABLE(query text, count bigint)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        event_data->>'query' AS query,
        count(*)             AS count
    FROM analytics_events
    WHERE event_name = 'search_performed'
      AND created_at::date = target_date
      AND event_data->>'query' IS NOT NULL
      AND event_data->>'query' <> ''
    GROUP BY event_data->>'query'
    ORDER BY count DESC
    LIMIT limit_count;
$$;

COMMENT ON FUNCTION public.metric_top_queries IS 'Top N search queries on target_date.';

-- ─── 4. Failed Searches (Zero Results) ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_failed_searches(target_date date DEFAULT CURRENT_DATE)
RETURNS TABLE(query text, count bigint)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        event_data->>'query' AS query,
        count(*)             AS count
    FROM analytics_events
    WHERE event_name = 'search_performed'
      AND created_at::date = target_date
      AND (event_data->>'result_count')::int = 0
    GROUP BY event_data->>'query'
    ORDER BY count DESC
    LIMIT 50;
$$;

COMMENT ON FUNCTION public.metric_failed_searches IS 'Search queries that returned 0 results on target_date.';

-- ─── 5. Top Viewed Products ─────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_top_products(
    target_date date DEFAULT CURRENT_DATE,
    limit_count int  DEFAULT 20
)
RETURNS TABLE(product_id text, product_name text, views bigint)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        event_data->>'product_id'   AS product_id,
        event_data->>'product_name' AS product_name,
        count(*)                    AS views
    FROM analytics_events
    WHERE event_name = 'product_viewed'
      AND created_at::date = target_date
    GROUP BY event_data->>'product_id', event_data->>'product_name'
    ORDER BY views DESC
    LIMIT limit_count;
$$;

COMMENT ON FUNCTION public.metric_top_products IS 'Top N products by view count on target_date.';

-- ─── 6. Allergen Profile Distribution ───────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_allergen_distribution()
RETURNS TABLE(allergen text, user_count bigint, percentage numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    WITH total AS (
        SELECT count(DISTINCT user_id)::numeric AS total_users
        FROM user_preferences
        WHERE avoid_allergens IS NOT NULL
          AND cardinality(avoid_allergens) > 0
    ),
    allergen_counts AS (
        SELECT
            unnest(avoid_allergens) AS allergen,
            count(DISTINCT user_id) AS user_count
        FROM user_preferences
        WHERE avoid_allergens IS NOT NULL
          AND cardinality(avoid_allergens) > 0
        GROUP BY unnest(avoid_allergens)
    )
    SELECT
        ac.allergen,
        ac.user_count,
        CASE WHEN t.total_users > 0
             THEN round(ac.user_count / t.total_users * 100, 1)
             ELSE 0
        END AS percentage
    FROM allergen_counts ac, total t
    ORDER BY ac.user_count DESC;
$$;

COMMENT ON FUNCTION public.metric_allergen_distribution IS
    'Distribution of allergen avoidances across user_preferences.avoid_allergens.';

-- ─── 7. Feature Usage Distribution ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_feature_usage(
    start_date date DEFAULT CURRENT_DATE - 7,
    end_date   date DEFAULT CURRENT_DATE
)
RETURNS TABLE(feature text, usage_count bigint, unique_users bigint)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        event_name          AS feature,
        count(*)            AS usage_count,
        count(DISTINCT user_id) AS unique_users
    FROM analytics_events
    WHERE created_at::date BETWEEN start_date AND end_date
    GROUP BY event_name
    ORDER BY usage_count DESC;
$$;

COMMENT ON FUNCTION public.metric_feature_usage IS 'Event usage breakdown with unique user counts.';

-- ─── 8. Scan vs Search Ratio ────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_scan_vs_search(target_date date DEFAULT CURRENT_DATE)
RETURNS TABLE(method text, count bigint, percentage numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    WITH counts AS (
        SELECT
            event_name,
            count(*) AS cnt
        FROM analytics_events
        WHERE event_name IN ('scanner_used', 'search_performed')
          AND created_at::date = target_date
        GROUP BY event_name
    ),
    total AS (
        SELECT sum(cnt)::numeric AS total_cnt FROM counts
    )
    SELECT
        c.event_name,
        c.cnt,
        CASE WHEN t.total_cnt > 0
             THEN round(c.cnt / t.total_cnt * 100, 1)
             ELSE 0
        END
    FROM counts c, total t
    ORDER BY c.cnt DESC;
$$;

COMMENT ON FUNCTION public.metric_scan_vs_search IS 'Ratio of barcode scans to text searches on target_date.';

-- ─── 9. Onboarding Completion Rate ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_onboarding_funnel(
    start_date date DEFAULT CURRENT_DATE - 30,
    end_date   date DEFAULT CURRENT_DATE
)
RETURNS TABLE(step text, user_count bigint, completion_rate numeric)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    WITH steps AS (
        SELECT
            COALESCE(event_data->>'step', event_name) AS step,
            count(DISTINCT user_id) AS user_count
        FROM analytics_events
        WHERE event_name IN ('onboarding_step', 'onboarding_completed')
          AND created_at::date BETWEEN start_date AND end_date
        GROUP BY COALESCE(event_data->>'step', event_name)
    ),
    first_step AS (
        SELECT GREATEST(max(user_count), 1)::numeric AS total FROM steps
    )
    SELECT
        s.step,
        s.user_count,
        round(s.user_count / f.total * 100, 1) AS completion_rate
    FROM steps s, first_step f
    ORDER BY s.user_count DESC;
$$;

COMMENT ON FUNCTION public.metric_onboarding_funnel IS 'Onboarding step completion funnel with drop-off rates.';

-- ─── 10. Category Popularity ────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.metric_category_popularity(target_date date DEFAULT CURRENT_DATE)
RETURNS TABLE(category text, views bigint, unique_users bigint)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
    SELECT
        event_data->>'category' AS category,
        count(*)                AS views,
        count(DISTINCT user_id) AS unique_users
    FROM analytics_events
    WHERE event_name IN ('product_viewed', 'category_viewed')
      AND created_at::date = target_date
      AND event_data->>'category' IS NOT NULL
    GROUP BY event_data->>'category'
    ORDER BY views DESC;
$$;

COMMENT ON FUNCTION public.metric_category_popularity IS 'Category popularity by view count on target_date.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Nightly Aggregation Function
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.aggregate_daily_metrics(target_date date DEFAULT CURRENT_DATE - 1)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- DAU
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'dau', (SELECT metric_dau(target_date)))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Total searches
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'searches', (SELECT metric_searches_per_day(target_date)))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Total scans
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'scans', (
        SELECT count(*) FROM analytics_events
        WHERE event_name = 'scanner_used' AND created_at::date = target_date
    ))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Total product views
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'product_views', (
        SELECT count(*) FROM analytics_events
        WHERE event_name = 'product_viewed' AND created_at::date = target_date
    ))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Failed searches
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'failed_searches', (
        SELECT count(*) FROM analytics_events
        WHERE event_name = 'search_performed'
          AND (event_data->>'result_count')::int = 0
          AND created_at::date = target_date
    ))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Onboarding completions
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'onboarding_completions', (
        SELECT count(*) FROM analytics_events
        WHERE event_name = 'onboarding_completed'
          AND created_at::date = target_date
    ))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;

    -- Unique scanners
    INSERT INTO analytics_daily (date, metric, value)
    VALUES (target_date, 'unique_scanners', (
        SELECT count(DISTINCT user_id) FROM analytics_events
        WHERE event_name = 'scanner_used'
          AND created_at::date = target_date
          AND user_id IS NOT NULL
    ))
    ON CONFLICT (date, metric) DO UPDATE SET value = EXCLUDED.value;
END;
$$;

COMMENT ON FUNCTION public.aggregate_daily_metrics IS
    'Nightly job: pre-aggregates core metrics into analytics_daily for fast dashboard queries.';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Admin API: Single RPC for Dashboard Data
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.api_admin_get_business_metrics(
    p_date  date    DEFAULT CURRENT_DATE,
    p_days  integer DEFAULT 7
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_start_date  date := p_date - p_days;
    v_dau         bigint;
    v_searches    bigint;
    v_top_queries jsonb;
    v_failed      jsonb;
    v_top_prods   jsonb;
    v_allergens   jsonb;
    v_features    jsonb;
    v_scan_search jsonb;
    v_funnel      jsonb;
    v_categories  jsonb;
    v_trend       jsonb;
BEGIN
    -- 1. DAU
    SELECT metric_dau(p_date) INTO v_dau;

    -- 2. Searches
    SELECT metric_searches_per_day(p_date) INTO v_searches;

    -- 3. Top queries
    SELECT coalesce(jsonb_agg(jsonb_build_object('query', t.query, 'count', t.count)), '[]'::jsonb)
    INTO v_top_queries
    FROM metric_top_queries(p_date, 20) t;

    -- 4. Failed searches
    SELECT coalesce(jsonb_agg(jsonb_build_object('query', t.query, 'count', t.count)), '[]'::jsonb)
    INTO v_failed
    FROM metric_failed_searches(p_date) t;

    -- 5. Top products
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'product_id', t.product_id,
        'product_name', t.product_name,
        'views', t.views
    )), '[]'::jsonb)
    INTO v_top_prods
    FROM metric_top_products(p_date, 20) t;

    -- 6. Allergen distribution
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'allergen', t.allergen,
        'user_count', t.user_count,
        'percentage', t.percentage
    )), '[]'::jsonb)
    INTO v_allergens
    FROM metric_allergen_distribution() t;

    -- 7. Feature usage
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'feature', t.feature,
        'usage_count', t.usage_count,
        'unique_users', t.unique_users
    )), '[]'::jsonb)
    INTO v_features
    FROM metric_feature_usage(v_start_date, p_date) t;

    -- 8. Scan vs Search
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'method', t.method,
        'count', t.count,
        'percentage', t.percentage
    )), '[]'::jsonb)
    INTO v_scan_search
    FROM metric_scan_vs_search(p_date) t;

    -- 9. Onboarding funnel
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'step', t.step,
        'user_count', t.user_count,
        'completion_rate', t.completion_rate
    )), '[]'::jsonb)
    INTO v_funnel
    FROM metric_onboarding_funnel(v_start_date, p_date) t;

    -- 10. Category popularity
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'category', t.category,
        'views', t.views,
        'unique_users', t.unique_users
    )), '[]'::jsonb)
    INTO v_categories
    FROM metric_category_popularity(p_date) t;

    -- Trend data from analytics_daily
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'date', ad.date,
        'metric', ad.metric,
        'value', ad.value
    ) ORDER BY ad.date), '[]'::jsonb)
    INTO v_trend
    FROM analytics_daily ad
    WHERE ad.date BETWEEN v_start_date AND p_date;

    RETURN jsonb_build_object(
        'api_version',           '1.0',
        'date',                  p_date,
        'days',                  p_days,
        'dau',                   coalesce(v_dau, 0),
        'searches',              coalesce(v_searches, 0),
        'top_queries',           v_top_queries,
        'failed_searches',       v_failed,
        'top_products',          v_top_prods,
        'allergen_distribution', v_allergens,
        'feature_usage',         v_features,
        'scan_vs_search',        v_scan_search,
        'onboarding_funnel',     v_funnel,
        'category_popularity',   v_categories,
        'trend',                 v_trend
    );
END;
$$;

COMMENT ON FUNCTION public.api_admin_get_business_metrics IS
    'Admin dashboard: returns all 10 business metrics + trend data in a single call.';

GRANT EXECUTE ON FUNCTION public.api_admin_get_business_metrics(date, integer)
    TO service_role, authenticated;
REVOKE EXECUTE ON FUNCTION public.api_admin_get_business_metrics(date, integer)
    FROM anon, public;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Grants for metric functions (service_role + authenticated via SECURITY DEFINER)
-- ═══════════════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION public.metric_dau(date)                      TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_searches_per_day(date)         TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_top_queries(date, int)         TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_failed_searches(date)          TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_top_products(date, int)        TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_allergen_distribution()        TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_feature_usage(date, date)      TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_scan_vs_search(date)           TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_onboarding_funnel(date, date)  TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.metric_category_popularity(date)      TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.aggregate_daily_metrics(date)         TO service_role;

REVOKE EXECUTE ON FUNCTION public.metric_dau(date)                      FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_searches_per_day(date)         FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_top_queries(date, int)         FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_failed_searches(date)          FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_top_products(date, int)        FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_allergen_distribution()        FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_feature_usage(date, date)      FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_scan_vs_search(date)           FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_onboarding_funnel(date, date)  FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.metric_category_popularity(date)      FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.aggregate_daily_metrics(date)         FROM anon, public;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. pg_cron schedule for nightly aggregation (if extension available)
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        PERFORM cron.schedule(
            'aggregate-daily-metrics',
            '0 1 * * *',
            'SELECT aggregate_daily_metrics()'
        );
    END IF;
END;
$$;

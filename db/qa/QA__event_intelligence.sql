-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Event Intelligence Integrity — 18 checks
--
-- Validates event_schema_registry, analytics_events evolution,
-- and function behavior for the Event Intelligence Layer (#190 Phase 1+2).
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. event_schema_registry: every row must have a non-empty json_schema
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-01: schema registry entries missing json_schema' AS issue,
    event_type || ' v' || schema_version AS detail
FROM public.event_schema_registry
WHERE json_schema IS NULL OR json_schema = '{}'::jsonb;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. event_schema_registry: status must be valid
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-02: schema registry invalid status' AS issue,
    event_type || ' v' || schema_version || ': ' || status AS detail
FROM public.event_schema_registry
WHERE status NOT IN ('active', 'deprecated', 'retired');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. event_schema_registry: retention_days must be positive
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-03: schema registry invalid retention_days' AS issue,
    event_type || ' v' || schema_version || ': ' || retention_days AS detail
FROM public.event_schema_registry
WHERE retention_days IS NULL OR retention_days <= 0;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. event_schema_registry: no duplicate active schemas per event_type
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-04: duplicate active schema versions' AS issue,
    event_type || ' has ' || count(*) || ' active versions' AS detail
FROM public.event_schema_registry
WHERE status = 'active'
GROUP BY event_type
HAVING count(*) > 2;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. allowed_event_names ↔ schema registry parity
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-05: allowed_event_name missing from schema registry' AS issue,
    aen.event_name AS detail
FROM public.allowed_event_names aen
LEFT JOIN public.event_schema_registry esr
    ON esr.event_type = aen.event_name AND esr.status = 'active'
WHERE esr.id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. analytics_events: country must be valid
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-06: analytics_events with invalid country' AS issue,
    id::text || ': country=' || country AS detail
FROM public.analytics_events
WHERE country NOT IN ('PL', 'DE');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. analytics_events: consent_level must be valid
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-07: analytics_events with invalid consent_level' AS issue,
    id::text || ': consent_level=' || consent_level AS detail
FROM public.analytics_events
WHERE consent_level NOT IN ('essential', 'analytics', 'full');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. analytics_events: schema_version must be positive
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-08: analytics_events with invalid schema_version' AS issue,
    id::text || ': schema_version=' || schema_version AS detail
FROM public.analytics_events
WHERE schema_version < 1;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. analytics_events: event_name must match allowed_event_names
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-09: analytics_events with unregistered event_name' AS issue,
    ae.id::text || ': ' || ae.event_name AS detail
FROM public.analytics_events ae
LEFT JOIN public.allowed_event_names aen ON aen.event_name = ae.event_name
WHERE aen.event_name IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. analytics_events: essential consent should only have client_error events
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-10: non-error events at essential consent level' AS issue,
    id::text || ': ' || event_name || ' at essential consent' AS detail
FROM public.analytics_events
WHERE consent_level = 'essential'
  AND event_name != 'client_error';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 11. event_schema_registry: enhanced schemas have required fields defined
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-11: v2+ schema missing required fields array' AS issue,
    event_type || ' v' || schema_version AS detail
FROM public.event_schema_registry
WHERE schema_version >= 2
  AND (NOT (json_schema ? 'required') OR jsonb_typeof(json_schema -> 'required') != 'array');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 12. event_schema_registry: all schemas must have type: object
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-12: schema missing type=object declaration' AS issue,
    event_type || ' v' || schema_version AS detail
FROM public.event_schema_registry
WHERE json_schema ->> 'type' IS DISTINCT FROM 'object';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 13. analytics_events: RLS must be enabled
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'AE-13: RLS not enabled on analytics_events' AS issue,
    'analytics_events' AS detail
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname = 'analytics_events'
  AND NOT c.relrowsecurity;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 14. event_schema_registry: RLS must be enabled
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'ESR-14: RLS not enabled on event_schema_registry' AS issue,
    'event_schema_registry' AS detail
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname = 'event_schema_registry'
  AND NOT c.relrowsecurity;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 15. api_track_event function must exist with correct param count
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'FN-15: api_track_event function missing or wrong param count' AS issue,
    'Expected 12 params' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = 'api_track_event'
      AND cardinality(p.proargtypes) = 12
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 16. api_validate_event_schema function must exist
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'FN-16: api_validate_event_schema function missing' AS issue,
    'Expected function' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = 'api_validate_event_schema'
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 17. api_get_event_schemas function must exist
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'FN-17: api_get_event_schemas function missing' AS issue,
    'Expected function' AS detail
WHERE NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = 'api_get_event_schemas'
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 18. Required indexes on analytics_events exist
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    'IDX-18: missing required index on analytics_events' AS issue,
    expected_name AS detail
FROM (VALUES
    ('idx_ae_country_event'),
    ('idx_ae_anonymous'),
    ('idx_ae_consent'),
    ('idx_ae_event_data_gin'),
    ('idx_ae_route')
) AS expected(expected_name)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'analytics_events'
      AND indexname = expected_name
);

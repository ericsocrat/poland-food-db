-- Migration: Add 5 scanner event names to analytics telemetry
-- Issue: #889 — scanner error taxonomy observation
-- Root cause: PR #900 added scanner telemetry instrumentation but did not
--   update the DB constraint or event registry. All 5 scanner events are
--   silently rejected by both the allowed_event_names lookup in
--   api_track_event() and the CHECK constraint on analytics_events.
-- Rollback: DROP the constraint and re-ADD with the previous 34 event names;
--   DELETE FROM allowed_event_names / event_schema_registry WHERE event_name
--   IN ('scanner_init_start', 'scanner_stream_ready', 'scanner_init_error',
--       'scanner_scan_success', 'scanner_scan_not_found');

-- ═══════════════════════════════════════════════════════════════════════════════
-- Step 1: Register scanner events in allowed_event_names
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.allowed_event_names (event_name) VALUES
    ('scanner_init_start'),
    ('scanner_stream_ready'),
    ('scanner_init_error'),
    ('scanner_scan_success'),
    ('scanner_scan_not_found')
ON CONFLICT (event_name) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Step 2: Register in event_schema_registry (minimal v1 schema)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO public.event_schema_registry (event_type, schema_version, json_schema, description, retention_days)
VALUES
    ('scanner_init_start',      1, '{"type": "object", "additionalProperties": true}'::jsonb,
     'Scanner initialization started (camera permission, stream setup)', 90),
    ('scanner_stream_ready',    1, '{"type": "object", "additionalProperties": true}'::jsonb,
     'Camera stream ready and barcode scanning active', 90),
    ('scanner_init_error',      1, '{"type": "object", "additionalProperties": true}'::jsonb,
     'Scanner initialization failed (permission denied, no camera, etc.)', 90),
    ('scanner_scan_success',    1, '{"type": "object", "additionalProperties": true}'::jsonb,
     'Barcode successfully scanned and matched to a product', 90),
    ('scanner_scan_not_found',  1, '{"type": "object", "additionalProperties": true}'::jsonb,
     'Barcode scanned but no matching product found in database', 90)
ON CONFLICT (event_type, schema_version) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Step 3: Update CHECK constraint to include scanner events
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.analytics_events DROP CONSTRAINT IF EXISTS chk_ae_event_name;
ALTER TABLE public.analytics_events ADD CONSTRAINT chk_ae_event_name CHECK (event_name IN (
    -- Original event names (telemetry_analytics migration)
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
    -- Event intelligence foundation (#190)
    'score_explanation_viewed',
    'alternative_clicked',
    'page_view',
    'client_error',
    -- Scanner telemetry (#889)
    'scanner_init_start',
    'scanner_stream_ready',
    'scanner_init_error',
    'scanner_scan_success',
    'scanner_scan_not_found'
));

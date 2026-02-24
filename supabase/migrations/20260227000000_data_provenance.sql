-- Data Provenance & Freshness Governance (Issue #193)
-- Layers: Source Registry, Enhanced Provenance, Audit Trail, Freshness Engine,
--         Conflict Resolution, Composite Confidence, Country Policies, APIs
BEGIN;

-- ============================================================================
-- LAYER 1: Data Source Registry
-- ============================================================================
CREATE TABLE IF NOT EXISTS data_sources (
    source_key       TEXT PRIMARY KEY,
    display_name     TEXT NOT NULL,
    source_type      TEXT NOT NULL CHECK (source_type IN (
        'api', 'manual', 'community', 'retailer', 'official', 'derived'
    )),
    base_confidence  NUMERIC(3,2) NOT NULL CHECK (base_confidence BETWEEN 0 AND 1),
    refresh_capable  BOOLEAN DEFAULT false,
    api_endpoint     TEXT,
    rate_limit_per_hour INT,
    active           BOOLEAN DEFAULT true,
    country_coverage TEXT[] DEFAULT '{}',
    metadata         JSONB DEFAULT '{}',
    created_at       TIMESTAMPTZ DEFAULT now(),
    updated_at       TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE data_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_sources FORCE  ROW LEVEL SECURITY;
CREATE POLICY allow_select_data_sources ON data_sources FOR SELECT USING (true);

COMMENT ON TABLE data_sources IS
    'Canonical registry of all data sources with confidence levels and capabilities.';

INSERT INTO data_sources (source_key, display_name, source_type, base_confidence, refresh_capable, country_coverage) VALUES
    ('off_api',                'Open Food Facts API',   'api',       0.60, true,  ARRAY['PL','DE','CZ','UK']),
    ('off_search',             'Open Food Facts Search', 'api',      0.55, true,  ARRAY['PL','DE','CZ','UK']),
    ('manual',                 'Manual Research',        'manual',   0.85, false, ARRAY['PL']),
    ('label_scan',             'Package / Label Scan',   'manual',   0.95, false, ARRAY['PL','DE','CZ','UK']),
    ('retailer_api',           'Retailer API (generic)', 'retailer', 0.80, true,  ARRAY['PL']),
    ('retailer_biedronka',     'Biedronka API',          'retailer', 0.80, true,  ARRAY['PL']),
    ('retailer_zabka',         'Żabka API',              'retailer', 0.80, true,  ARRAY['PL']),
    ('user_contribution',      'User Contribution',      'community',0.40, false, ARRAY['PL','DE','CZ','UK']),
    ('official_manufacturer',  'Manufacturer Data',      'official', 0.90, false, ARRAY['PL','DE','CZ','UK']),
    ('lab_test',               'Laboratory Test',        'official', 1.00, false, ARRAY['PL','DE','CZ','UK']),
    ('derived_calculation',    'Derived / Calculated',   'derived',  0.70, false, ARRAY['PL','DE','CZ','UK'])
ON CONFLICT (source_key) DO NOTHING;

GRANT SELECT ON data_sources TO anon, authenticated, service_role;
GRANT ALL    ON data_sources TO service_role;

-- ============================================================================
-- LAYER 2: Enhanced Field-Level Provenance
-- Extend the existing product_field_provenance table with richer columns.
-- ============================================================================
ALTER TABLE product_field_provenance
    ADD COLUMN IF NOT EXISTS confidence   NUMERIC(3,2),
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS verified_by  UUID,
    ADD COLUMN IF NOT EXISTS notes        TEXT;

-- Relax the CHECK constraint to allow new source keys from data_sources
ALTER TABLE product_field_provenance DROP CONSTRAINT IF EXISTS chk_fp_source_type;
ALTER TABLE product_field_provenance ADD CONSTRAINT chk_fp_source_type
    CHECK (source_type IN (
        'off_api','off_search','manual','label_scan','retailer_api',
        'retailer_biedronka','retailer_zabka','user_contribution',
        'official_manufacturer','lab_test','derived_calculation'
    ));

-- Add index for staleness queries (recorded_at)
CREATE INDEX IF NOT EXISTS idx_field_provenance_recorded
    ON product_field_provenance (recorded_at);

-- ============================================================================
-- LAYER 3: Audit Trail — product_change_log
-- ============================================================================
CREATE TABLE IF NOT EXISTS product_change_log (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id  BIGINT NOT NULL,
    field_name  TEXT   NOT NULL,
    old_value   JSONB,
    new_value   JSONB,
    source_key  TEXT,
    actor_type  TEXT   NOT NULL CHECK (actor_type IN (
        'pipeline', 'manual', 'user', 'system', 'conflict_resolution'
    )),
    actor_id    TEXT,
    reason      TEXT,
    country     TEXT   NOT NULL DEFAULT 'PL',
    metadata    JSONB  DEFAULT '{}',
    created_at  TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_change_log_product
    ON product_change_log (product_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_change_log_field
    ON product_change_log (field_name, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_change_log_source
    ON product_change_log (source_key, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_change_log_actor
    ON product_change_log (actor_type, actor_id);

ALTER TABLE product_change_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_change_log FORCE  ROW LEVEL SECURITY;

-- Admin-only read access; service_role full access
CREATE POLICY allow_service_change_log ON product_change_log
    FOR ALL USING (
        current_setting('role', true) = 'service_role'
    );

COMMENT ON TABLE product_change_log IS
    'Immutable audit trail for tracked product field changes (actor, reason, old/new values).';

GRANT SELECT ON product_change_log TO service_role;
GRANT ALL    ON product_change_log TO service_role;

-- Audit trigger — logs tracked field changes on UPDATE
CREATE OR REPLACE FUNCTION trg_product_change_log()
RETURNS TRIGGER AS $$
DECLARE
    v_field TEXT;
    v_tracked_fields TEXT[] := ARRAY[
        'product_name', 'product_name_en', 'brand', 'category',
        'calories_100g', 'fat_100g', 'saturated_fat_100g', 'carbs_100g',
        'sugars_100g', 'fiber_100g', 'protein_100g', 'salt_100g',
        'trans_fat_100g', 'ingredients_text', 'allergens', 'additives',
        'nutri_score_label', 'unhealthiness_score', 'image_url',
        'prep_method', 'controversies', 'ingredient_concern_level',
        'source_type', 'confidence', 'data_completeness_pct'
    ];
    v_old_val JSONB;
    v_new_val JSONB;
BEGIN
    FOREACH v_field IN ARRAY v_tracked_fields
    LOOP
        BEGIN
            EXECUTE format('SELECT to_jsonb($1.%I), to_jsonb($2.%I)', v_field, v_field)
                INTO v_old_val, v_new_val USING OLD, NEW;
        EXCEPTION WHEN undefined_column THEN
            CONTINUE;
        END;

        IF v_old_val IS DISTINCT FROM v_new_val THEN
            INSERT INTO product_change_log (
                product_id, field_name, old_value, new_value,
                source_key, actor_type, actor_id, country
            ) VALUES (
                NEW.product_id, v_field, v_old_val, v_new_val,
                NEW.source_type,
                COALESCE(current_setting('app.actor_type', true), 'system'),
                current_setting('app.actor_id', true),
                COALESCE(NEW.country, 'PL')
            );
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Install audit trigger (position 30 — after existing triggers)
DROP TRIGGER IF EXISTS products_30_change_audit ON products;
CREATE TRIGGER products_30_change_audit
    AFTER UPDATE ON products FOR EACH ROW
    EXECUTE FUNCTION trg_product_change_log();

REVOKE EXECUTE ON FUNCTION trg_product_change_log() FROM PUBLIC, anon;

-- ============================================================================
-- LAYER 4: Freshness & Staleness Engine
-- ============================================================================
CREATE TABLE IF NOT EXISTS freshness_policies (
    id                  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country             TEXT NOT NULL,
    field_group         TEXT NOT NULL CHECK (field_group IN (
        'nutrition', 'allergens', 'ingredients', 'identity', 'images', 'scoring'
    )),
    max_age_days        INT NOT NULL,
    warning_age_days    INT NOT NULL,
    critical_age_days   INT NOT NULL,
    refresh_strategy    TEXT NOT NULL CHECK (refresh_strategy IN (
        'auto_api', 'manual_review', 'user_verification', 'no_refresh'
    )),
    priority            INT NOT NULL DEFAULT 1,
    created_at          TIMESTAMPTZ DEFAULT now(),
    UNIQUE(country, field_group)
);

ALTER TABLE freshness_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE freshness_policies FORCE  ROW LEVEL SECURITY;
CREATE POLICY allow_select_freshness ON freshness_policies FOR SELECT USING (true);

COMMENT ON TABLE freshness_policies IS
    'Per-country, per-field-group staleness thresholds and refresh strategies.';

INSERT INTO freshness_policies (country, field_group, max_age_days, warning_age_days, critical_age_days, refresh_strategy, priority) VALUES
    -- Poland
    ('PL', 'nutrition',    180, 120, 150, 'auto_api',       5),
    ('PL', 'allergens',     90,  60,  75, 'manual_review',  5),
    ('PL', 'ingredients',  180, 120, 150, 'auto_api',       4),
    ('PL', 'identity',     365, 300, 350, 'auto_api',       2),
    ('PL', 'images',       365, 300, 350, 'manual_review',  1),
    ('PL', 'scoring',       30,  20,  25, 'auto_api',       5),
    -- Germany (stricter)
    ('DE', 'nutrition',    120,  80, 100, 'auto_api',       5),
    ('DE', 'allergens',     60,  40,  50, 'manual_review',  5),
    ('DE', 'ingredients',  120,  80, 100, 'auto_api',       4),
    ('DE', 'identity',     365, 300, 350, 'auto_api',       2),
    ('DE', 'images',       365, 300, 350, 'manual_review',  1),
    ('DE', 'scoring',       30,  20,  25, 'auto_api',       5)
ON CONFLICT (country, field_group) DO NOTHING;

GRANT SELECT ON freshness_policies TO anon, authenticated, service_role;
GRANT ALL    ON freshness_policies TO service_role;

-- ============================================================================
-- LAYER 5: Conflict Resolution Engine
-- ============================================================================
CREATE TABLE IF NOT EXISTS conflict_resolution_rules (
    id              INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country         TEXT NOT NULL,
    field_group     TEXT NOT NULL,
    source_priority JSONB NOT NULL,
    auto_resolve    BOOLEAN DEFAULT false,
    tolerance       JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE(country, field_group)
);

ALTER TABLE conflict_resolution_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE conflict_resolution_rules FORCE  ROW LEVEL SECURITY;
CREATE POLICY allow_select_conflict_rules ON conflict_resolution_rules FOR SELECT USING (true);

INSERT INTO conflict_resolution_rules (country, field_group, source_priority, auto_resolve, tolerance) VALUES
    ('PL', 'nutrition',    '["lab_test","label_scan","official_manufacturer","manual","retailer_api","off_api","user_contribution"]', true,  '{"numeric_tolerance_pct": 10}'),
    ('PL', 'allergens',    '["lab_test","label_scan","official_manufacturer","manual","off_api","user_contribution"]',                false, '{"text": "exact"}'),
    ('PL', 'ingredients',  '["label_scan","official_manufacturer","manual","off_api","user_contribution"]',                          true,  '{"text": "fuzzy"}'),
    ('PL', 'identity',     '["label_scan","official_manufacturer","retailer_api","off_api","manual","user_contribution"]',            true,  '{"text": "exact"}'),
    ('DE', 'nutrition',    '["lab_test","label_scan","official_manufacturer","manual","off_api","user_contribution"]',                true,  '{"numeric_tolerance_pct": 10}'),
    ('DE', 'allergens',    '["lab_test","label_scan","official_manufacturer","manual","off_api","user_contribution"]',                false, '{"text": "exact"}')
ON CONFLICT (country, field_group) DO NOTHING;

GRANT SELECT ON conflict_resolution_rules TO anon, authenticated, service_role;
GRANT ALL    ON conflict_resolution_rules TO service_role;

-- Data conflicts table
CREATE TABLE IF NOT EXISTS data_conflicts (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id          BIGINT NOT NULL,
    field_name          TEXT   NOT NULL,
    conflicting_values  JSONB  NOT NULL,
    status              TEXT   NOT NULL DEFAULT 'open' CHECK (status IN (
        'open', 'auto_resolved', 'manually_resolved', 'dismissed'
    )),
    resolution          JSONB,
    country             TEXT   NOT NULL,
    severity            TEXT   NOT NULL DEFAULT 'low' CHECK (severity IN (
        'low', 'medium', 'high', 'critical'
    )),
    created_at          TIMESTAMPTZ DEFAULT now(),
    resolved_at         TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_conflicts_status
    ON data_conflicts (status, severity, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conflicts_product
    ON data_conflicts (product_id);

ALTER TABLE data_conflicts ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_conflicts FORCE  ROW LEVEL SECURITY;
CREATE POLICY allow_service_conflicts ON data_conflicts
    FOR ALL USING (current_setting('role', true) = 'service_role');

COMMENT ON TABLE data_conflicts IS
    'Detected and resolved conflicts when multiple sources disagree beyond tolerance.';

GRANT SELECT ON data_conflicts TO service_role;
GRANT ALL    ON data_conflicts TO service_role;

-- ============================================================================
-- LAYER 6: Country Data Policies
-- ============================================================================
CREATE TABLE IF NOT EXISTS country_data_policies (
    id                          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country                     TEXT NOT NULL UNIQUE,
    primary_sources             TEXT[] NOT NULL,
    regulatory_framework        TEXT,
    allergen_strictness         TEXT DEFAULT 'standard' CHECK (
        allergen_strictness IN ('standard', 'strict', 'very_strict')
    ),
    requires_local_language     BOOLEAN DEFAULT true,
    default_refresh_cadence_days INT DEFAULT 180,
    min_confidence_for_publish  NUMERIC(3,2) DEFAULT 0.50,
    dispute_escalation_email    TEXT,
    active                      BOOLEAN DEFAULT false,
    created_at                  TIMESTAMPTZ DEFAULT now(),
    metadata                    JSONB DEFAULT '{}'
);

ALTER TABLE country_data_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE country_data_policies FORCE  ROW LEVEL SECURITY;
CREATE POLICY allow_select_country_policies ON country_data_policies FOR SELECT USING (true);

INSERT INTO country_data_policies (country, primary_sources, regulatory_framework, allergen_strictness, active) VALUES
    ('PL', ARRAY['off_api','retailer_api','manual'],   'EU_FIC_1169_2011', 'standard', true),
    ('DE', ARRAY['off_api','manual'],                  'EU_FIC_1169_2011', 'strict',   false),
    ('CZ', ARRAY['off_api','manual'],                  'EU_FIC_1169_2011', 'standard', false),
    ('UK', ARRAY['off_api','manual'],                  'UK_FIR',           'strict',   false)
ON CONFLICT (country) DO NOTHING;

GRANT SELECT ON country_data_policies TO anon, authenticated, service_role;
GRANT ALL    ON country_data_policies TO service_role;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- field_to_group: maps a field name to its governance group
CREATE OR REPLACE FUNCTION field_to_group(p_field_name TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN CASE
        WHEN p_field_name IN (
            'calories_100g','fat_100g','saturated_fat_100g','carbs_100g',
            'sugars_100g','fiber_100g','protein_100g','salt_100g','trans_fat_100g'
        ) THEN 'nutrition'
        WHEN p_field_name IN ('allergens','allergen_tags') THEN 'allergens'
        WHEN p_field_name IN (
            'ingredients_text','additives','additive_count','ingredient_concern_level'
        ) THEN 'ingredients'
        WHEN p_field_name IN (
            'product_name','product_name_en','brand','ean','category'
        ) THEN 'identity'
        WHEN p_field_name IN ('image_url','image_nutrition_url') THEN 'images'
        WHEN p_field_name IN (
            'unhealthiness_score','nutri_score_label','confidence','data_completeness_pct'
        ) THEN 'scoring'
        ELSE 'identity'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

REVOKE EXECUTE ON FUNCTION field_to_group(TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION field_to_group(TEXT) TO authenticated, service_role;

-- record_field_provenance: records provenance for a single field
CREATE OR REPLACE FUNCTION record_field_provenance(
    p_product_id  BIGINT,
    p_field_name  TEXT,
    p_source_key  TEXT,
    p_confidence  NUMERIC DEFAULT NULL,
    p_verified_by UUID    DEFAULT NULL,
    p_notes       TEXT    DEFAULT NULL,
    p_source_url  TEXT    DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_conf NUMERIC;
BEGIN
    IF p_confidence IS NULL THEN
        SELECT base_confidence INTO v_conf
        FROM data_sources WHERE source_key = p_source_key;
    ELSE
        v_conf := p_confidence;
    END IF;

    INSERT INTO product_field_provenance (
        product_id, field_name, source_type, source_url,
        confidence, verified_at, verified_by, notes, recorded_at
    ) VALUES (
        p_product_id, p_field_name, p_source_key, p_source_url,
        v_conf,
        CASE WHEN p_verified_by IS NOT NULL THEN now() ELSE NULL END,
        p_verified_by, p_notes, now()
    )
    ON CONFLICT (product_id, field_name) DO UPDATE SET
        source_type  = EXCLUDED.source_type,
        source_url   = EXCLUDED.source_url,
        confidence   = EXCLUDED.confidence,
        verified_at  = EXCLUDED.verified_at,
        verified_by  = EXCLUDED.verified_by,
        notes        = EXCLUDED.notes,
        recorded_at  = EXCLUDED.recorded_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION record_field_provenance(BIGINT,TEXT,TEXT,NUMERIC,UUID,TEXT,TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION record_field_provenance(BIGINT,TEXT,TEXT,NUMERIC,UUID,TEXT,TEXT) TO authenticated, service_role;

-- record_bulk_provenance: records provenance for multiple fields at once
CREATE OR REPLACE FUNCTION record_bulk_provenance(
    p_product_id  BIGINT,
    p_source_key  TEXT,
    p_fields      TEXT[],
    p_verified_by UUID DEFAULT NULL,
    p_notes       TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_field TEXT;
    v_conf  NUMERIC;
BEGIN
    SELECT base_confidence INTO v_conf
    FROM data_sources WHERE source_key = p_source_key;

    FOREACH v_field IN ARRAY p_fields
    LOOP
        INSERT INTO product_field_provenance (
            product_id, field_name, source_type, confidence,
            verified_at, verified_by, notes, recorded_at
        ) VALUES (
            p_product_id, v_field, p_source_key, v_conf,
            CASE WHEN p_verified_by IS NOT NULL THEN now() ELSE NULL END,
            p_verified_by, p_notes, now()
        )
        ON CONFLICT (product_id, field_name) DO UPDATE SET
            source_type  = EXCLUDED.source_type,
            confidence   = EXCLUDED.confidence,
            verified_at  = EXCLUDED.verified_at,
            verified_by  = EXCLUDED.verified_by,
            notes        = EXCLUDED.notes,
            recorded_at  = EXCLUDED.recorded_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION record_bulk_provenance(BIGINT,TEXT,TEXT[],UUID,TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION record_bulk_provenance(BIGINT,TEXT,TEXT[],UUID,TEXT) TO authenticated, service_role;

-- detect_stale_products: identifies products with stale fields
CREATE OR REPLACE FUNCTION detect_stale_products(
    p_country  TEXT DEFAULT 'PL',
    p_severity TEXT DEFAULT 'warning',
    p_limit    INT  DEFAULT 100
)
RETURNS TABLE(
    product_id         BIGINT,
    product_name       TEXT,
    stale_fields       JSONB,
    max_staleness_days INT,
    staleness_severity TEXT,
    recommended_action TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH field_ages AS (
        SELECT
            pf.product_id,
            p.product_name,
            pf.field_name,
            field_to_group(pf.field_name) AS field_group,
            EXTRACT(EPOCH FROM (now() - pf.recorded_at))::INT / 86400 AS age_days
        FROM product_field_provenance pf
        JOIN products p ON p.product_id = pf.product_id
        WHERE p.country = p_country
    ),
    stale AS (
        SELECT
            fa.product_id,
            fa.product_name,
            fa.field_name,
            fa.age_days,
            fp.max_age_days,
            fp.refresh_strategy,
            CASE
                WHEN fa.age_days >= fp.max_age_days     THEN 'expired'
                WHEN fa.age_days >= fp.critical_age_days THEN 'critical'
                WHEN fa.age_days >= fp.warning_age_days  THEN 'warning'
                ELSE 'fresh'
            END AS severity
        FROM field_ages fa
        JOIN freshness_policies fp
            ON fp.country = p_country AND fp.field_group = fa.field_group
    )
    SELECT
        s.product_id,
        s.product_name,
        jsonb_agg(jsonb_build_object(
            'field', s.field_name,
            'age_days', s.age_days,
            'max_age', s.max_age_days,
            'severity', s.severity
        )) AS stale_fields,
        MAX(s.age_days)::INT AS max_staleness_days,
        MAX(s.severity) AS staleness_severity,
        CASE WHEN bool_or(s.refresh_strategy = 'auto_api') THEN 'auto_refresh'
             WHEN bool_or(s.refresh_strategy = 'manual_review') THEN 'queue_for_review'
             ELSE 'user_verification'
        END AS recommended_action
    FROM stale s
    WHERE s.severity != 'fresh'
        AND (p_severity = 'warning'  OR s.severity IN ('critical','expired'))
        AND (p_severity != 'expired' OR s.severity = 'expired')
    GROUP BY s.product_id, s.product_name
    ORDER BY MAX(s.age_days) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION detect_stale_products(TEXT,TEXT,INT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION detect_stale_products(TEXT,TEXT,INT) TO authenticated, service_role;

-- detect_conflict: checks if a new value conflicts with existing data
CREATE OR REPLACE FUNCTION detect_conflict(
    p_product_id    BIGINT,
    p_field_name    TEXT,
    p_new_source    TEXT,
    p_new_value     JSONB
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_value JSONB;
    v_current_source TEXT;
    v_country TEXT;
    v_tolerance JSONB;
    v_numeric_tol NUMERIC;
    v_is_conflict BOOLEAN := false;
BEGIN
    SELECT country INTO v_country FROM products WHERE product_id = p_product_id;

    BEGIN
        EXECUTE format('SELECT to_jsonb(p.%I) FROM products p WHERE p.product_id = $1', p_field_name)
            INTO v_current_value USING p_product_id;
    EXCEPTION WHEN undefined_column THEN
        RETURN false;
    END;

    IF v_current_value IS NULL OR v_current_value = p_new_value THEN
        RETURN false;
    END IF;

    SELECT pf.source_type INTO v_current_source
    FROM product_field_provenance pf
    WHERE pf.product_id = p_product_id AND pf.field_name = p_field_name;

    SELECT cr.tolerance INTO v_tolerance
    FROM conflict_resolution_rules cr
    WHERE cr.country = v_country AND cr.field_group = field_to_group(p_field_name);

    IF jsonb_typeof(v_current_value) = 'number' AND jsonb_typeof(p_new_value) = 'number' THEN
        v_numeric_tol := COALESCE((v_tolerance->>'numeric_tolerance_pct')::NUMERIC, 5) / 100;
        IF ABS(v_current_value::TEXT::NUMERIC - p_new_value::TEXT::NUMERIC) /
           NULLIF(GREATEST(ABS(v_current_value::TEXT::NUMERIC), ABS(p_new_value::TEXT::NUMERIC)), 0)
           > v_numeric_tol
        THEN
            v_is_conflict := true;
        END IF;
    ELSIF v_current_value IS DISTINCT FROM p_new_value THEN
        v_is_conflict := true;
    END IF;

    IF v_is_conflict THEN
        INSERT INTO data_conflicts (product_id, field_name, conflicting_values, country, severity)
        VALUES (
            p_product_id, p_field_name,
            jsonb_build_array(
                jsonb_build_object('source_key', v_current_source, 'value', v_current_value, 'at', now()::TEXT),
                jsonb_build_object('source_key', p_new_source,     'value', p_new_value,     'at', now()::TEXT)
            ),
            v_country,
            CASE field_to_group(p_field_name)
                WHEN 'allergens'   THEN 'critical'
                WHEN 'nutrition'   THEN 'high'
                WHEN 'ingredients' THEN 'medium'
                ELSE 'low'
            END
        );
    END IF;

    RETURN v_is_conflict;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION detect_conflict(BIGINT,TEXT,TEXT,JSONB) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION detect_conflict(BIGINT,TEXT,TEXT,JSONB) TO authenticated, service_role;

-- resolve_conflicts_auto: auto-resolve open conflicts using priority rules
CREATE OR REPLACE FUNCTION resolve_conflicts_auto(
    p_country      TEXT DEFAULT 'PL',
    p_max_severity TEXT DEFAULT 'medium'
)
RETURNS INT AS $$
DECLARE
    v_resolved INT := 0;
    v_conflict RECORD;
    v_priority JSONB;
    v_best_source TEXT;
    v_best_value  JSONB;
BEGIN
    FOR v_conflict IN
        SELECT dc.*
        FROM data_conflicts dc
        WHERE dc.status  = 'open'
          AND dc.country = p_country
          AND (
            (p_max_severity = 'critical') OR
            (p_max_severity = 'high'   AND dc.severity IN ('low','medium','high')) OR
            (p_max_severity = 'medium' AND dc.severity IN ('low','medium')) OR
            (p_max_severity = 'low'    AND dc.severity = 'low')
          )
    LOOP
        SELECT cr.source_priority INTO v_priority
        FROM conflict_resolution_rules cr
        WHERE cr.country     = p_country
          AND cr.field_group = field_to_group(v_conflict.field_name)
          AND cr.auto_resolve = true;

        IF v_priority IS NULL THEN CONTINUE; END IF;

        SELECT cv->>'source_key', cv->'value'
        INTO v_best_source, v_best_value
        FROM jsonb_array_elements(v_conflict.conflicting_values) cv
        ORDER BY (
            SELECT idx FROM jsonb_array_elements_text(v_priority)
                WITH ORDINALITY AS t(val, idx)
            WHERE t.val = cv->>'source_key'
        ) ASC NULLS LAST
        LIMIT 1;

        UPDATE data_conflicts SET
            status      = 'auto_resolved',
            resolution  = jsonb_build_object(
                'chosen_source_key', v_best_source,
                'chosen_value',      v_best_value,
                'resolved_by',       'system',
                'reason',            'Auto-resolved by source priority: ' || v_best_source
            ),
            resolved_at = now()
        WHERE id = v_conflict.id;

        v_resolved := v_resolved + 1;
    END LOOP;

    RETURN v_resolved;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION resolve_conflicts_auto(TEXT,TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION resolve_conflicts_auto(TEXT,TEXT) TO service_role;

-- ============================================================================
-- LAYER 7: Composite Confidence with Freshness Decay
-- ============================================================================
CREATE OR REPLACE FUNCTION compute_provenance_confidence(
    p_product_id BIGINT
)
RETURNS TABLE(
    overall_confidence       NUMERIC,
    confidence_breakdown     JSONB,
    staleness_risk           TEXT,
    data_completeness        NUMERIC,
    source_diversity         INT,
    weakest_field            TEXT,
    weakest_field_confidence NUMERIC
) AS $$
DECLARE
    v_country        TEXT;
    v_rec            RECORD;
    v_total_conf     NUMERIC := 0;
    v_field_count    INT     := 0;
    v_min_conf       NUMERIC := 1;
    v_min_field      TEXT;
    v_max_age        INT     := 0;
    v_sources        TEXT[]  := '{}';
    v_breakdown      JSONB   := '{}';
BEGIN
    SELECT p.country INTO v_country FROM products p WHERE p.product_id = p_product_id;

    IF v_country IS NULL THEN
        overall_confidence := 0;
        confidence_breakdown := '{}'::JSONB;
        staleness_risk := 'expired';
        data_completeness := 0;
        source_diversity := 0;
        weakest_field := 'all';
        weakest_field_confidence := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    FOR v_rec IN
        SELECT pf.field_name,
               pf.source_type,
               COALESCE(pf.confidence, ds.base_confidence, 0.5) AS base_conf,
               EXTRACT(EPOCH FROM (now() - pf.recorded_at))::INT / 86400 AS age_days
        FROM product_field_provenance pf
        LEFT JOIN data_sources ds ON ds.source_key = pf.source_type
        WHERE pf.product_id = p_product_id
    LOOP
        DECLARE
            v_penalty  NUMERIC := 1.0;
            v_eff_conf NUMERIC;
            v_policy   RECORD;
        BEGIN
            SELECT * INTO v_policy FROM freshness_policies
            WHERE country = v_country AND field_group = field_to_group(v_rec.field_name)
            LIMIT 1;

            IF v_policy IS NOT NULL THEN
                v_penalty := CASE
                    WHEN v_rec.age_days <= v_policy.warning_age_days  THEN 1.0
                    WHEN v_rec.age_days <= v_policy.critical_age_days THEN 0.8
                    WHEN v_rec.age_days <= v_policy.max_age_days      THEN 0.5
                    ELSE 0.2
                END;
            END IF;

            v_eff_conf := v_rec.base_conf * v_penalty;
            v_total_conf := v_total_conf + v_eff_conf;
            v_field_count := v_field_count + 1;

            IF v_eff_conf < v_min_conf THEN
                v_min_conf  := v_eff_conf;
                v_min_field := v_rec.field_name;
            END IF;

            IF v_rec.age_days > v_max_age THEN
                v_max_age := v_rec.age_days;
            END IF;

            IF v_rec.source_type IS NOT NULL AND NOT (v_rec.source_type = ANY(v_sources)) THEN
                v_sources := array_append(v_sources, v_rec.source_type);
            END IF;

            v_breakdown := jsonb_set(v_breakdown, ARRAY[v_rec.field_name],
                jsonb_build_object(
                    'source',              v_rec.source_type,
                    'base_confidence',     v_rec.base_conf,
                    'freshness_penalty',   v_penalty,
                    'effective_confidence', ROUND(v_eff_conf, 3),
                    'age_days',            v_rec.age_days
                ));
        END;
    END LOOP;

    IF v_field_count = 0 THEN
        overall_confidence := 0;
        confidence_breakdown := '{}'::JSONB;
        staleness_risk := 'expired';
        data_completeness := 0;
        source_diversity := 0;
        weakest_field := 'all';
        weakest_field_confidence := 0;
    ELSE
        overall_confidence   := ROUND(v_total_conf / v_field_count, 3);
        confidence_breakdown := v_breakdown;
        staleness_risk := CASE
            WHEN v_max_age > 365 THEN 'expired'
            WHEN v_max_age > 180 THEN 'stale'
            WHEN v_max_age >  90 THEN 'aging'
            ELSE 'fresh'
        END;
        data_completeness    := ROUND(v_field_count::NUMERIC / 15 * 100, 1);
        source_diversity     := COALESCE(array_length(v_sources, 1), 0);
        weakest_field        := v_min_field;
        weakest_field_confidence := v_min_conf;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION compute_provenance_confidence(BIGINT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION compute_provenance_confidence(BIGINT) TO authenticated, service_role;

-- ============================================================================
-- LAYER 8: Country Product Validation
-- ============================================================================
CREATE OR REPLACE FUNCTION validate_product_for_country(
    p_product_id BIGINT,
    p_country    TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_policy     RECORD;
    v_confidence RECORD;
    v_product    RECORD;
    v_issues     JSONB := '[]'::JSONB;
    v_fail_count INT;
BEGIN
    SELECT * INTO v_policy FROM country_data_policies WHERE country = p_country;
    SELECT * INTO v_product FROM products WHERE product_id = p_product_id;
    SELECT * INTO v_confidence FROM compute_provenance_confidence(p_product_id);

    IF v_policy IS NULL THEN
        RETURN jsonb_build_object(
            'product_id', p_product_id, 'country', p_country,
            'ready_for_publish', false,
            'issues', jsonb_build_array(jsonb_build_object(
                'check', 'country_policy', 'status', 'fail',
                'detail', 'No data policy configured for country ' || p_country
            ))
        );
    END IF;

    IF v_confidence.overall_confidence < v_policy.min_confidence_for_publish THEN
        v_issues := v_issues || jsonb_build_array(jsonb_build_object(
            'check', 'minimum_confidence', 'status', 'fail',
            'detail', format('Confidence %.2f below minimum %.2f',
                v_confidence.overall_confidence, v_policy.min_confidence_for_publish)
        ));
    END IF;

    IF v_policy.requires_local_language AND v_product.product_name IS NULL THEN
        v_issues := v_issues || jsonb_build_array(jsonb_build_object(
            'check', 'local_language_name', 'status', 'fail',
            'detail', 'Product name in local language is required'
        ));
    END IF;

    IF v_policy.allergen_strictness IN ('strict', 'very_strict')
       AND v_product.allergens IS NULL THEN
        v_issues := v_issues || jsonb_build_array(jsonb_build_object(
            'check', 'allergen_data', 'status', 'fail',
            'detail', 'Allergen data required for ' || p_country ||
                      ' (strictness: ' || v_policy.allergen_strictness || ')'
        ));
    END IF;

    IF v_confidence.staleness_risk IN ('stale', 'expired') THEN
        v_issues := v_issues || jsonb_build_array(jsonb_build_object(
            'check', 'data_freshness', 'status', 'warning',
            'detail', 'Data staleness risk: ' || v_confidence.staleness_risk
        ));
    END IF;

    SELECT COUNT(*) INTO v_fail_count
    FROM jsonb_array_elements(v_issues) elem
    WHERE elem->>'status' = 'fail';

    RETURN jsonb_build_object(
        'product_id',          p_product_id,
        'country',             p_country,
        'ready_for_publish',   v_fail_count = 0,
        'overall_confidence',  v_confidence.overall_confidence,
        'staleness_risk',      v_confidence.staleness_risk,
        'source_diversity',    v_confidence.source_diversity,
        'issues',              v_issues,
        'validated_at',        now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION validate_product_for_country(BIGINT,TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION validate_product_for_country(BIGINT,TEXT) TO authenticated, service_role;

-- ============================================================================
-- LAYER 9: User-Facing & Admin APIs
-- ============================================================================

-- api_product_provenance: public provenance summary for a product
CREATE OR REPLACE FUNCTION api_product_provenance(p_product_id BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_result     JSONB;
    v_confidence RECORD;
BEGIN
    SELECT * INTO v_confidence FROM compute_provenance_confidence(p_product_id);

    SELECT jsonb_build_object(
        'api_version',       '2026-02-27',
        'product_id',        p.product_id,
        'product_name',      p.product_name,
        'overall_trust_score', v_confidence.overall_confidence,
        'freshness_status',  v_confidence.staleness_risk,
        'source_count',      v_confidence.source_diversity,
        'data_completeness_pct', v_confidence.data_completeness,
        'field_sources', (
            SELECT COALESCE(jsonb_object_agg(
                pf.field_name,
                jsonb_build_object(
                    'source',       COALESCE(ds.display_name, pf.source_type),
                    'last_updated', pf.recorded_at,
                    'confidence',   ROUND(COALESCE(pf.confidence, ds.base_confidence, 0.5), 2)
                )
            ), '{}'::JSONB)
            FROM product_field_provenance pf
            LEFT JOIN data_sources ds ON ds.source_key = pf.source_type
            WHERE pf.product_id = p_product_id
        ),
        'trust_explanation', CASE
            WHEN v_confidence.overall_confidence >= 0.8
                THEN 'Data from high-confidence sources with recent verification'
            WHEN v_confidence.overall_confidence >= 0.6
                THEN 'Data from multiple sources with moderate confidence'
            WHEN v_confidence.overall_confidence >= 0.4
                THEN 'Some fields have limited source verification'
            ELSE 'Data confidence is low — treat values as estimates'
        END,
        'weakest_area', jsonb_build_object(
            'field',      v_confidence.weakest_field,
            'confidence', v_confidence.weakest_field_confidence
        )
    ) INTO v_result
    FROM products p
    WHERE p.product_id = p_product_id;

    RETURN COALESCE(v_result, jsonb_build_object(
        'api_version', '2026-02-27', 'error', 'product_not_found'
    ));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION api_product_provenance(BIGINT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION api_product_provenance(BIGINT) TO anon, authenticated, service_role;

-- admin_provenance_dashboard: health overview per country
CREATE OR REPLACE FUNCTION admin_provenance_dashboard(
    p_country TEXT DEFAULT 'PL'
)
RETURNS JSONB AS $$
BEGIN
    RETURN jsonb_build_object(
        'api_version',       '2026-02-27',
        'country',           p_country,
        'generated_at',      now(),
        'total_products',    (SELECT COUNT(*) FROM products WHERE country = p_country),
        'with_provenance',   (
            SELECT COUNT(DISTINCT pf.product_id)
            FROM product_field_provenance pf
            JOIN products p ON p.product_id = pf.product_id
            WHERE p.country = p_country
        ),
        'without_provenance', (
            SELECT COUNT(*)
            FROM products p
            WHERE p.country = p_country
              AND NOT EXISTS (
                  SELECT 1 FROM product_field_provenance pf
                  WHERE pf.product_id = p.product_id
              )
        ),
        'open_conflicts',    (SELECT COUNT(*) FROM data_conflicts
                              WHERE country = p_country AND status = 'open'),
        'critical_conflicts',(SELECT COUNT(*) FROM data_conflicts
                              WHERE country = p_country AND status = 'open' AND severity = 'critical'),
        'source_distribution', (
            SELECT COALESCE(jsonb_object_agg(source_key, cnt), '{}'::JSONB)
            FROM (
                SELECT pf.source_type AS source_key, COUNT(*) AS cnt
                FROM product_field_provenance pf
                JOIN products p ON p.product_id = pf.product_id
                WHERE p.country = p_country
                GROUP BY pf.source_type
                ORDER BY cnt DESC
            ) src
        ),
        'policies', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'field_group',     fp.field_group,
                'max_age_days',    fp.max_age_days,
                'warning_age_days', fp.warning_age_days,
                'refresh_strategy', fp.refresh_strategy
            )), '[]'::JSONB)
            FROM freshness_policies fp
            WHERE fp.country = p_country
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION admin_provenance_dashboard(TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION admin_provenance_dashboard(TEXT) TO authenticated, service_role;

-- ============================================================================
-- FEATURE FLAG: data_provenance_ui
-- ============================================================================
INSERT INTO feature_flags (key, name, description, flag_type, enabled, environments, tags, expires_at)
VALUES (
    'data_provenance_ui',
    'Data Provenance UI',
    'Show provenance trust badges and field source attribution on product pages (Issue #193)',
    'boolean',
    false,
    ARRAY['staging'],
    ARRAY['#193','provenance','trust'],
    now() + INTERVAL '6 months'
)
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
    v_count INT;
BEGIN
    -- 1. data_sources seeded
    SELECT COUNT(*) INTO v_count FROM data_sources;
    ASSERT v_count >= 11, 'data_sources must have ≥11 rows, got ' || v_count;

    -- 2. product_field_provenance has new columns
    PERFORM column_name FROM information_schema.columns
    WHERE table_name = 'product_field_provenance' AND column_name = 'confidence';
    ASSERT FOUND, 'product_field_provenance.confidence column missing';

    -- 3. product_change_log exists
    PERFORM 1 FROM information_schema.tables
    WHERE table_name = 'product_change_log';
    ASSERT FOUND, 'product_change_log table missing';

    -- 4. freshness_policies seeded
    SELECT COUNT(*) INTO v_count FROM freshness_policies;
    ASSERT v_count >= 12, 'freshness_policies must have ≥12 rows, got ' || v_count;

    -- 5. conflict_resolution_rules seeded
    SELECT COUNT(*) INTO v_count FROM conflict_resolution_rules;
    ASSERT v_count >= 6, 'conflict_resolution_rules must have ≥6 rows, got ' || v_count;

    -- 6. country_data_policies seeded
    SELECT COUNT(*) INTO v_count FROM country_data_policies;
    ASSERT v_count >= 4, 'country_data_policies must have ≥4 rows, got ' || v_count;

    -- 7. data_conflicts table exists
    PERFORM 1 FROM information_schema.tables
    WHERE table_name = 'data_conflicts';
    ASSERT FOUND, 'data_conflicts table missing';

    -- 8. feature flag seeded
    SELECT COUNT(*) INTO v_count FROM feature_flags WHERE key = 'data_provenance_ui';
    ASSERT v_count = 1, 'data_provenance_ui feature flag missing';

    -- 9. audit trigger installed
    PERFORM 1 FROM information_schema.triggers
    WHERE trigger_name = 'products_30_change_audit';
    ASSERT FOUND, 'products_30_change_audit trigger missing';

    -- 10. functions exist
    PERFORM 1 FROM pg_proc WHERE proname = 'field_to_group';
    ASSERT FOUND, 'field_to_group function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'record_field_provenance';
    ASSERT FOUND, 'record_field_provenance function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'record_bulk_provenance';
    ASSERT FOUND, 'record_bulk_provenance function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'detect_stale_products';
    ASSERT FOUND, 'detect_stale_products function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'detect_conflict';
    ASSERT FOUND, 'detect_conflict function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'resolve_conflicts_auto';
    ASSERT FOUND, 'resolve_conflicts_auto function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'compute_provenance_confidence';
    ASSERT FOUND, 'compute_provenance_confidence function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'validate_product_for_country';
    ASSERT FOUND, 'validate_product_for_country function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'api_product_provenance';
    ASSERT FOUND, 'api_product_provenance function missing';
    PERFORM 1 FROM pg_proc WHERE proname = 'admin_provenance_dashboard';
    ASSERT FOUND, 'admin_provenance_dashboard function missing';

    RAISE NOTICE '✅ All #193 data provenance verification checks passed';
END $$;

COMMIT;

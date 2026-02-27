-- ============================================================
-- Migration: Feature Flag Activation Roadmap (#372)
-- Purpose:   Add activation criteria, dependency graph, and
--            readiness-check function to feature_flags.
-- Rollback:  ALTER TABLE feature_flags
--              DROP COLUMN IF EXISTS activation_criteria,
--              DROP COLUMN IF EXISTS activation_order,
--              DROP COLUMN IF EXISTS depends_on;
--            DROP FUNCTION IF EXISTS check_flag_readiness();
-- ============================================================

-- ─── Phase 1: Add activation metadata columns ───────────────

ALTER TABLE public.feature_flags
  ADD COLUMN IF NOT EXISTS activation_criteria jsonb,
  ADD COLUMN IF NOT EXISTS activation_order   integer,
  ADD COLUMN IF NOT EXISTS depends_on         text[];

COMMENT ON COLUMN public.feature_flags.activation_criteria
  IS 'JSONB describing prerequisites (data checks, issue deps, manual approval) that must be satisfied before enabling this flag';

COMMENT ON COLUMN public.feature_flags.activation_order
  IS 'Recommended sequential activation order (lower = earlier). NULL for permanent utility flags.';

COMMENT ON COLUMN public.feature_flags.depends_on
  IS 'Array of feature_flag keys that must be enabled before this flag can be activated';


-- ─── Phase 2: Seed activation criteria for all 8 flags ──────

-- 1. qa_mode — immediate, no dependencies
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '[]'::jsonb,
    'data_checks',         '[]'::jsonb,
    'manual_approval',     false,
    'notes',               'Testing utility. Safe to enable immediately.'
  ),
  activation_order = 1,
  depends_on       = NULL
WHERE key = 'qa_mode';

-- 2. maintenance_mode — emergency only, no order
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '[]'::jsonb,
    'data_checks',         '[]'::jsonb,
    'manual_approval',     true,
    'notes',               'Emergency toggle. Enable only during planned maintenance or outages.'
  ),
  activation_order = NULL,
  depends_on       = NULL
WHERE key = 'maintenance_mode';

-- 3. de_country_launch — requires DE enrichment
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '["#360"]'::jsonb,
    'data_checks',         '["DE product count >= 200", "DE ingredient coverage >= 80%"]'::jsonb,
    'manual_approval',     true,
    'notes',               'DE micro-pilot has 252 products across 5 categories. Ready when enrichment is validated.'
  ),
  activation_order = 2,
  depends_on       = NULL
WHERE key = 'de_country_launch';

-- 4. data_provenance_ui — requires source coverage
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '[]'::jsonb,
    'data_checks',         '["source_url coverage >= 95%", "source_type NOT NULL for all active products"]'::jsonb,
    'manual_approval',     true,
    'notes',               'Source coverage is ~96%. Frontend trust badge components exist.'
  ),
  activation_order = 3,
  depends_on       = NULL
WHERE key = 'data_provenance_ui';

-- 5. new_search_ranking — requires synonym coverage
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '["#378"]'::jsonb,
    'data_checks',         '["search_synonyms >= 250 rows", "DE synonyms >= 50"]'::jsonb,
    'manual_approval',     true,
    'notes',               'Configurable 5-signal search_rank() ready. Needs synonym coverage for DE before enabling.'
  ),
  activation_order = 4,
  depends_on       = NULL
WHERE key = 'new_search_ranking';

-- 6. allergen_v2 — requires allergen normalization
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '["#351"]'::jsonb,
    'data_checks',         '["allergen coverage >= 60%", "allergen normalization complete"]'::jsonb,
    'manual_approval',     true,
    'notes',               'Enhanced allergen filtering UX. Requires normalized allergen tags from #351.'
  ),
  activation_order = 5,
  depends_on       = NULL
WHERE key = 'allergen_v2';

-- 7. new_search_ui — depends on new_search_ranking being validated
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '[]'::jsonb,
    'data_checks',         '["new_search_ranking validated for >= 14 days"]'::jsonb,
    'manual_approval',     true,
    'notes',               'Redesigned search with autocomplete. Must validate ranking backend before shipping new UI.'
  ),
  activation_order = 6,
  depends_on       = ARRAY['new_search_ranking']
WHERE key = 'new_search_ui';

-- 8. scoring_v4 — last, requires shadow mode validation
UPDATE public.feature_flags SET
  activation_criteria = jsonb_build_object(
    'prerequisite_issues', '[]'::jsonb,
    'data_checks',         '["shadow mode comparison shows < 5% score drift", "scoring regression suite passes", "product anchor scores stable within +/-2"]'::jsonb,
    'manual_approval',     true,
    'notes',               'Highest-risk flag. Must run shadow mode first, compare against v3.2 baselines, pass full regression suite.'
  ),
  activation_order = 7,
  depends_on       = NULL
WHERE key = 'scoring_v4';


-- ─── Phase 3: Readiness check function ──────────────────────

CREATE OR REPLACE FUNCTION public.check_flag_readiness()
RETURNS TABLE(
  flag_key           text,
  is_enabled         boolean,
  activation_order   integer,
  depends_on         text[],
  dependencies_met   boolean,
  expires_at         timestamptz,
  days_until_expiry  integer,
  status             text        -- 'enabled', 'expired', 'blocked', 'ready'
)
LANGUAGE sql STABLE SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    ff.key,
    ff.enabled,
    ff.activation_order,
    ff.depends_on,
    -- Check if all dependency flags are enabled
    NOT EXISTS (
      SELECT 1
      FROM unnest(ff.depends_on) AS dep(dep_key)
      WHERE NOT EXISTS (
        SELECT 1 FROM public.feature_flags f2
        WHERE f2.key = dep.dep_key AND f2.enabled = true
      )
    ) AS dependencies_met,
    ff.expires_at,
    CASE
      WHEN ff.expires_at IS NOT NULL
      THEN EXTRACT(DAY FROM ff.expires_at - now())::integer
      ELSE NULL
    END AS days_until_expiry,
    CASE
      WHEN ff.enabled                     THEN 'enabled'
      WHEN ff.expires_at < now()          THEN 'expired'
      WHEN EXISTS (
        SELECT 1
        FROM unnest(ff.depends_on) AS dep(dep_key)
        WHERE NOT EXISTS (
          SELECT 1 FROM public.feature_flags f2
          WHERE f2.key = dep.dep_key AND f2.enabled = true
        )
      )                                   THEN 'blocked'
      ELSE                                     'ready'
    END AS status
  FROM public.feature_flags ff
  ORDER BY ff.activation_order NULLS LAST, ff.key;
$$;

COMMENT ON FUNCTION public.check_flag_readiness()
  IS 'Returns activation readiness status for all feature flags, including dependency resolution and expiry tracking';

-- Restrict to authenticated only (admin utility)
REVOKE EXECUTE ON FUNCTION public.check_flag_readiness() FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.check_flag_readiness() TO authenticated;
GRANT  EXECUTE ON FUNCTION public.check_flag_readiness() TO service_role;

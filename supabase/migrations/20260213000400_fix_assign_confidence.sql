-- Fix assign_confidence() — previously returned 'estimated' for all products ≥70%
-- The 'verified' band was never reachable (dead code in if-else branches).
-- Now: verified = ≥90% completeness + recognized source, estimated = ≥70%, low = <70%/null.

CREATE OR REPLACE FUNCTION public.assign_confidence(
    p_data_completeness_pct numeric,
    p_source_type text
)
RETURNS text
LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
    IF p_data_completeness_pct IS NULL THEN
        RETURN 'low';
    END IF;

    IF p_data_completeness_pct < 70 THEN
        RETURN 'low';
    END IF;

    -- High completeness + a recognized data source → verified
    IF p_data_completeness_pct >= 90
       AND p_source_type IN ('off_api', 'openfoodfacts', 'manual') THEN
        RETURN 'verified';
    END IF;

    -- Everything else ≥70% → estimated
    RETURN 'estimated';
END;
$$;

-- Re-apply confidence to all active products
UPDATE products
SET    confidence = assign_confidence(data_completeness_pct, COALESCE(source_type, 'off_api'))
WHERE  is_deprecated IS NOT TRUE;

-- Refresh materialized views that depend on confidence
SELECT refresh_all_materialized_views();

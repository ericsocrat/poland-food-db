-- Migration: Update confidence levels based on data_completeness_pct
-- Previously all 560 products had confidence = 'estimated' regardless of completeness.
-- Per SCORING_METHODOLOGY.md §6.3:
--   100% completeness → 'verified'  (all data from primary label source)
--   70-99%            → 'estimated' (some values estimated)
--   <70%              → 'low'       (insufficient data)

UPDATE scores
SET confidence = CASE
  WHEN data_completeness_pct::int = 100 THEN 'verified'
  WHEN data_completeness_pct::int >= 70  THEN 'estimated'
  ELSE 'low'
END
WHERE confidence IS DISTINCT FROM (
  CASE
    WHEN data_completeness_pct::int = 100 THEN 'verified'
    WHEN data_completeness_pct::int >= 70  THEN 'estimated'
    ELSE 'low'
  END
);

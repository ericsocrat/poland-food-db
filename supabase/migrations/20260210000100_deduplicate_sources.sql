-- Deduplicate sources table: 8 categories had 2 rows each from
-- overlapping seed scripts (original pipeline inserts + migration 000100).
-- Keep the lowest source_id per brand, delete the rest.
-- Also add a unique index to prevent future duplicates.

DELETE FROM sources
WHERE source_id NOT IN (
  SELECT MIN(source_id) FROM sources GROUP BY brand
);

-- Prevent future duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_sources_brand_unique
  ON sources (brand);

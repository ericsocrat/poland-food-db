-- Clean up orphan ingredient_ref entries (no product_ingredient links)
-- These are dictionary entries from earlier enrichment runs whose product links
-- were lost during db reset cycles (BEGIN/COMMIT conflict in migration 20260313000100).
-- Removing ~3,177 unused entries. Enrichment pipeline will re-add any needed ones
-- via ON CONFLICT on next run.
--
-- Rollback: Re-run enrichment pipeline (enrich_ingredients.py) to repopulate.

DELETE FROM ingredient_ref ir
WHERE NOT EXISTS (
    SELECT 1 FROM product_ingredient pi
    WHERE pi.ingredient_id = ir.ingredient_id
);

-- Deduplicate product_ingredient rows sharing the same (product_id, position)
-- caused by case-variant ingredient_ref entries (e.g., ROGGENflocken vs Roggenflocken).
-- Keeps the entry with the lower ingredient_id; deletes the duplicate.
WITH dupes AS (
    SELECT product_id, position, MIN(ingredient_id) AS keep_id
    FROM product_ingredient
    GROUP BY product_id, position
    HAVING COUNT(*) > 1
)
DELETE FROM product_ingredient pi
USING dupes d
WHERE pi.product_id = d.product_id
  AND pi.position = d.position
  AND pi.ingredient_id != d.keep_id;

-- Clean up any newly orphaned ingredient_ref entries from dedup
DELETE FROM ingredient_ref ir
WHERE NOT EXISTS (
    SELECT 1 FROM product_ingredient pi
    WHERE pi.ingredient_id = ir.ingredient_id
);

-- Re-score affected categories after ingredient count changes
-- The dedup changes additive counts, which affects unhealthiness scores.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT DISTINCT p.category, p.country
        FROM product_ingredient pi
        JOIN products p ON p.product_id = pi.product_id
        WHERE p.is_deprecated IS NOT TRUE
    LOOP
        CALL score_category(r.category, 100, r.country);
    END LOOP;
END;
$$;

-- Refresh materialized views that depend on ingredient_ref
SELECT refresh_all_materialized_views();

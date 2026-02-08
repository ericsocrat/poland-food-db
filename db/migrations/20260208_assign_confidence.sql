-- FUNCTION: Auto-assign confidence level based on data completeness and source coverage
-- Implements confidence workflow from DATA_SOURCES.md §8
-- Created: 2026-02-08

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Create confidence assignment function
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.assign_confidence(
    p_data_completeness_pct NUMERIC,
    p_source_type TEXT
) RETURNS TEXT AS $$
BEGIN
    -- Confidence workflow from DATA_SOURCES.md §8:
    --
    -- Current state: All products are single-source (openfoodfacts only)
    -- Future: When ≥ 2 independent sources exist, can return 'verified'
    --
    -- Logic:
    -- 1. data_completeness < 70% → 'low'
    -- 2. data_completeness 70-89% → 'estimated'
    -- 3. data_completeness ≥ 90% + single source (OFF only) → 'estimated'
    -- 4. data_completeness ≥ 90% + multiple sources (future) → 'verified'
    -- 5. NULL data_completeness → 'low'
    
    IF p_data_completeness_pct IS NULL THEN
        RETURN 'low';
    END IF;
    
    IF p_data_completeness_pct < 70 THEN
        RETURN 'low';
    END IF;
    
    IF p_data_completeness_pct >= 90 THEN
        -- In future: check if multiple sources exist → 'verified'
        -- For now: single-source (openfoodfacts) → 'estimated'
        IF p_source_type = 'openfoodfacts' THEN
            RETURN 'estimated';  -- Single source, needs cross-validation
        ELSE
            -- If we ever add 'label' or 'manufacturer' sources
            RETURN 'estimated';  -- Conservative until multi-source
        END IF;
    END IF;
    
    -- data_completeness 70-89%
    RETURN 'estimated';
    
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION public.assign_confidence IS 
'Auto-assigns confidence level based on data completeness percentage and source type.
Returns: verified | estimated | low
Current logic: All single-source products return "estimated" (need cross-validation).
Future enhancement: When products have ≥2 independent sources, return "verified" for data_completeness ≥ 90%.';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Apply confidence to all existing products
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE scores sc
SET confidence = assign_confidence(
    sc.data_completeness_pct,
    (SELECT src.source_type 
     FROM products p
     LEFT JOIN sources src ON src.brand LIKE '%(' || p.category || ')%'
     WHERE p.product_id = sc.product_id
     LIMIT 1)
)
WHERE sc.confidence IS NULL
  AND sc.product_id IN (
      SELECT product_id FROM products WHERE is_deprecated IS NOT TRUE
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Verification query
-- ═══════════════════════════════════════════════════════════════════════════

-- Count products by confidence level
SELECT 
    confidence,
    COUNT(*) AS product_count,
    ROUND(AVG(data_completeness_pct), 1) AS avg_completeness
FROM scores sc
JOIN products p ON p.product_id = sc.product_id
WHERE p.is_deprecated IS NOT TRUE
GROUP BY confidence
ORDER BY 
    CASE confidence
        WHEN 'verified' THEN 1
        WHEN 'estimated' THEN 2
        WHEN 'low' THEN 3
        ELSE 4
    END;

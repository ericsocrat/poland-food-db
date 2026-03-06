-- Fix mv_staleness_check() source count for mv_ingredient_frequency
-- Bug: source_rows counted ALL product_ingredient rows (including deprecated products)
--       but the MV itself filters to active products only (is_deprecated IS NOT TRUE).
--       This caused a persistent 1-row "staleness" false positive.
-- Rollback: Re-deploy the previous version of mv_staleness_check() from migration 20260210003000

CREATE OR REPLACE FUNCTION mv_staleness_check()
RETURNS jsonb
LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'checked_at', NOW(),
        'views', jsonb_build_array(
            jsonb_build_object(
                'name', 'mv_ingredient_frequency',
                'mv_rows', (SELECT COUNT(*) FROM mv_ingredient_frequency),
                'source_rows', (SELECT COUNT(DISTINCT pi.ingredient_id)
                                FROM product_ingredient pi
                                JOIN products p ON p.product_id = pi.product_id
                                WHERE p.is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM mv_ingredient_frequency) !=
                            (SELECT COUNT(DISTINCT pi.ingredient_id)
                             FROM product_ingredient pi
                             JOIN products p ON p.product_id = pi.product_id
                             WHERE p.is_deprecated IS NOT TRUE)
            ),
            jsonb_build_object(
                'name', 'v_product_confidence',
                'mv_rows', (SELECT COUNT(*) FROM v_product_confidence),
                'source_rows', (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE),
                'is_stale', (SELECT COUNT(*) FROM v_product_confidence) !=
                            (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE)
            )
        )
    );
$$;

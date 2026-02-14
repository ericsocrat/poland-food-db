-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Scale Guardrails
-- Roadmap item #5 — Prepare for growth to 5-10K products + multi-country
--
-- Changes:
--   1. Role-level statement_timeout (5s for API roles, unlimited for service)
--   2. Role-level idle_in_transaction_session_timeout (30s for API roles)
--   3. Clamp api_better_alternatives p_limit to 1-20
--   4. Auto-refresh materialized views in score_category procedure
--   5. Non-negative CHECK on source_nutrition
--   6. Remove hardcoded country CHECK (FK to country_ref suffices)
--   7. Row count ceiling function for monitoring
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Statement timeouts on API roles
--    Prevents runaway queries from anonymous/authenticated users.
--    service_role and postgres remain unlimited for pipeline operations.
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
    role_name text;
BEGIN
    FOREACH role_name IN ARRAY ARRAY['anon', 'authenticated', 'authenticator']
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
            EXECUTE format('ALTER ROLE %I SET statement_timeout = %L', role_name, '5s');
        END IF;
    END LOOP;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Idle-in-transaction timeout
--    Kills sessions that hold transactions open without activity.
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
    role_name text;
BEGIN
    FOREACH role_name IN ARRAY ARRAY['anon', 'authenticated', 'authenticator']
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
            EXECUTE format(
                'ALTER ROLE %I SET idle_in_transaction_session_timeout = %L',
                role_name,
                '30s'
            );
        END IF;
    END LOOP;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Clamp api_better_alternatives limit to 1-20
--    Without this, a caller could pass p_limit=10000 and force a full-table
--    Jaccard similarity scan.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION api_better_alternatives(
    p_product_id bigint,
    p_same_category boolean DEFAULT true,
    p_limit integer DEFAULT 5
)
RETURNS jsonb
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $function$
    SELECT jsonb_build_object(
        'api_version',     '1.0',
        'source_product', jsonb_build_object(
            'product_id',         m.product_id,
            'product_name',       m.product_name,
            'brand',              m.brand,
            'category',           m.category,
            'unhealthiness_score',m.unhealthiness_score,
            'nutri_score',        m.nutri_score_label
        ),
        'search_scope',    CASE WHEN p_same_category THEN 'same_category' ELSE 'all_categories' END,
        'alternatives',    COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'product_id',         alt.alt_product_id,
                'product_name',       alt.product_name,
                'brand',              alt.brand,
                'category',           alt.category,
                'unhealthiness_score',alt.unhealthiness_score,
                'score_improvement',  alt.score_improvement,
                'nutri_score',        alt.nutri_score_label,
                'similarity',         alt.jaccard_similarity,
                'shared_ingredients', alt.shared_ingredients
            ))
            FROM find_better_alternatives(p_product_id, p_same_category,
                                          LEAST(GREATEST(p_limit, 1), 20)) alt
        ), '[]'::jsonb),
        'alternatives_count', COALESCE((
            SELECT COUNT(*)::int
            FROM find_better_alternatives(p_product_id, p_same_category,
                                          LEAST(GREATEST(p_limit, 1), 20))
        ), 0)
    )
    FROM v_master m
    WHERE m.product_id = p_product_id;
$function$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Auto-refresh MVs in score_category
--    After every scoring run, materialized views are refreshed concurrently
--    so downstream API queries always see fresh data.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE PROCEDURE score_category(
    p_category      text,
    p_data_completeness integer DEFAULT 100   -- kept for signature compat; ignored
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- 0. DEFAULT concern score for products without ingredient data
    UPDATE products
    SET    ingredient_concern_score = 0
    WHERE  country = 'PL'
      AND  category = p_category
      AND  is_deprecated IS NOT TRUE
      AND  ingredient_concern_score IS NULL;

    -- 1. COMPUTE unhealthiness_score (v3.2 — 9 factors)
    UPDATE products p
    SET    unhealthiness_score = compute_unhealthiness_v32(
               nf.saturated_fat_g,
               nf.sugars_g,
               nf.salt_g,
               nf.calories,
               nf.trans_fat_g,
               ia.additives_count,
               p.prep_method,
               p.controversies,
               p.ingredient_concern_score
           )
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 4. Health-risk flags + DYNAMIC data_completeness_pct
    UPDATE products p
    SET    high_salt_flag    = CASE WHEN nf.salt_g >= 1.5 THEN 'YES' ELSE 'NO' END,
           high_sugar_flag   = CASE WHEN nf.sugars_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_sat_fat_flag = CASE WHEN nf.saturated_fat_g >= 5.0 THEN 'YES' ELSE 'NO' END,
           high_additive_load = CASE WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END,
           data_completeness_pct = compute_data_completeness(p.product_id)
    FROM   nutrition_facts nf
    LEFT JOIN (
        SELECT pi.product_id,
               COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
        FROM   product_ingredient pi
        JOIN   ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
        GROUP BY pi.product_id
    ) ia ON ia.product_id = nf.product_id
    WHERE  nf.product_id = p.product_id
      AND  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 5. SET confidence level (now uses dynamic completeness)
    UPDATE products p
    SET    confidence = assign_confidence(p.data_completeness_pct, 'openfoodfacts')
    WHERE  p.country = 'PL'
      AND  p.category = p_category
      AND  p.is_deprecated IS NOT TRUE;

    -- 6. AUTO-REFRESH materialized views (new in scale guardrails)
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ingredient_frequency;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_confidence;
END;
$procedure$;

COMMENT ON PROCEDURE score_category(text, int) IS
'Consolidated scoring procedure for a given category. '
'Steps: 0 (concern defaults), 1 (unhealthiness v3.2), 4 (flags + dynamic data_completeness), '
'5 (confidence), 6 (auto-refresh MVs). '
'The p_data_completeness parameter is retained for backward compatibility but is now ignored — '
'completeness is always computed dynamically via compute_data_completeness().';

-- 5. (skipped — source_nutrition table is defined in migration but not deployed locally)

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Remove hardcoded country CHECK
--    FK fk_products_country → country_ref.country_code already enforces
--    valid values. The CHECK constraint blocked multi-country expansion.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE products DROP CONSTRAINT IF EXISTS chk_products_country;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. Row count ceiling function for monitoring
--    Returns per-table row counts with ceiling thresholds so QA can alert
--    when growth exceeds expected bounds.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION check_table_ceilings()
RETURNS TABLE(
    table_name text,
    current_rows bigint,
    ceiling bigint,
    pct_of_ceiling numeric,
    status text
)
LANGUAGE sql STABLE
SECURITY DEFINER
SET search_path = public
AS $fn$
    WITH ceilings(tbl, cap) AS (VALUES
        ('products',             15000::bigint),
        ('nutrition_facts',      15000),
        ('product_ingredient',   200000),
        ('ingredient_ref',       10000),
        ('product_allergen_info', 50000)
    ),
    counts AS (
        SELECT 'products' AS tbl,             COUNT(*) AS n FROM products
        UNION ALL
        SELECT 'nutrition_facts',             COUNT(*) FROM nutrition_facts
        UNION ALL
        SELECT 'product_ingredient',          COUNT(*) FROM product_ingredient
        UNION ALL
        SELECT 'ingredient_ref',              COUNT(*) FROM ingredient_ref
        UNION ALL
        SELECT 'product_allergen_info',       COUNT(*) FROM product_allergen_info
    )
    SELECT c.tbl,
           ct.n,
           c.cap,
           ROUND(100.0 * ct.n / c.cap, 1),
           CASE
               WHEN ct.n > c.cap       THEN 'EXCEEDED'
               WHEN ct.n > c.cap * 0.8 THEN 'WARNING'
               ELSE 'OK'
           END
    FROM ceilings c
    JOIN counts ct ON ct.tbl = c.tbl
    ORDER BY ROUND(100.0 * ct.n / c.cap, 1) DESC;
$fn$;

COMMENT ON FUNCTION check_table_ceilings IS
'Returns per-table row counts against growth ceiling thresholds. '
'Used by scale guardrails QA suite to detect unexpected data growth.';

-- Grant to API roles (read-only monitoring)
GRANT EXECUTE ON FUNCTION check_table_ceilings() TO anon, authenticated, service_role;

-- Revoke from PUBLIC (defense in depth)
REVOKE EXECUTE ON FUNCTION check_table_ceilings() FROM PUBLIC;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Performance Regression
-- Validates that key API functions complete within generous CI thresholds.
-- These are NOT the production P95 targets (search <150ms, autocomplete <50ms);
-- they are smoke-level bounds that catch catastrophic regressions (hangs,
-- sequential scans) in Docker-based CI environments.
--
-- Production P95 targets are documented in docs/PERFORMANCE_GUARDRAILS.md
-- and enforced via scheduled monitoring (not per-PR CI).
--
-- NON-BLOCKING — timing varies by environment; failures are informational.
-- 6 checks.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Search: api_search_products completes in < 5s
-- Production target: < 150ms P95
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '1. search completes in < 5s (production target: 150ms)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 5
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (SELECT api_search_products('mleko', NULL, 20, 0, 'PL')) q(r);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Autocomplete: api_search_autocomplete completes in < 3s
-- Production target: < 50ms P95
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '2. autocomplete completes in < 3s (production target: 50ms)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 3
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (SELECT api_search_autocomplete('mle', 5)) q(r);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Category listing: api_category_listing completes in < 5s
-- Production target: < 200ms P95
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '3. category listing completes in < 5s (production target: 200ms)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 5
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (SELECT api_category_listing('Chips', 'score', 'asc', 50, 0, 'PL')) q(r);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Product detail: api_product_detail completes in < 2s
-- Production target: < 100ms P95
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '4. product detail completes in < 2s (production target: 100ms)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 2
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (
    SELECT api_product_detail(
        (SELECT product_id FROM products WHERE is_deprecated IS NOT TRUE LIMIT 1)
    )
) q(r);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Score computation: 100 products scored in < 5s
-- Production target: < 50ms per product
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '5. 100 score computations in < 5s (production target: 50ms/ea)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 5
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (
    SELECT COUNT(*) AS cnt
    FROM (
        SELECT compute_unhealthiness_v32(
            p_saturated_fat      := nf.saturated_fat,
            p_sugars             := nf.sugars,
            p_salt               := nf.salt,
            p_calories           := nf.calories,
            p_trans_fat          := nf.trans_fat,
            p_additive_count     := COALESCE(p.additive_count, 0),
            p_prep_method        := p.prep_method,
            p_controversies      := p.controversies,
            p_ingredient_concern := COALESCE(p.ingredient_concern_score, 0)
        ) AS score
        FROM products p
        JOIN nutrition_facts nf ON nf.product_id = p.product_id
        WHERE p.is_deprecated IS NOT TRUE
        LIMIT 100
    ) scored
) q(cnt);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. Better alternatives: api_better_alternatives completes in < 5s
-- Production target: < 300ms P95
-- ═══════════════════════════════════════════════════════════════════════════════
SELECT '6. better alternatives completes in < 5s (production target: 300ms)' AS check_name,
       CASE WHEN extract(epoch FROM clock_timestamp() - t.s) < 5
            THEN 0 ELSE 1 END AS violations
FROM (SELECT clock_timestamp() AS s) t,
LATERAL (
    SELECT api_better_alternatives(
        (SELECT product_id FROM products
         WHERE is_deprecated IS NOT TRUE AND unhealthiness_score > 30
         LIMIT 1)
    )
) q(r);

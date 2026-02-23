-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: EXPLAIN Plan Analysis
-- Validates query plan quality for critical RPC functions.
-- Checks for sequential scans on large tables and estimates plan quality.
-- Issue: #185
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  check_plan_quality function exists and is callable
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. check_plan_quality function exists' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid
           WHERE n.nspname = 'public'
             AND p.proname = 'check_plan_quality'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  check_plan_quality has expected return columns
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. check_plan_quality has correct return type' AS check_name,
       CASE WHEN (
           SELECT COUNT(*) = 6
           FROM pg_proc p
           JOIN pg_namespace n ON p.pronamespace = n.oid,
           LATERAL unnest(proargnames) AS col
           WHERE n.nspname = 'public'
             AND p.proname = 'check_plan_quality'
             AND col IN ('plan_node','node_type','estimated_rows','actual_rows','loops','warning')
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  Products table uses index scan for single-row lookups
--     EXPLAIN on a PK lookup should NOT show Seq Scan.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. products PK lookup uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM products WHERE product_id = 1'
           ) WHERE node_type = 'Seq Scan'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  Category-filtered queries use index
--     Category listing is one of the most frequent operations.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. category filter uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM products WHERE category = ''dairy'' AND is_deprecated IS NOT TRUE LIMIT 10'
           ) WHERE node_type = 'Seq Scan'
             AND estimated_rows > 100
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  EAN lookup uses index (barcode scanner critical path)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. EAN lookup uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM products WHERE ean = ''5900000000000'''
           ) WHERE node_type = 'Seq Scan'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  Servings per-100g lookup uses partial index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. servings per-100g uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM servings WHERE product_id = 1 AND serving_basis = ''per 100 g'''
           ) WHERE node_type = 'Seq Scan'
             AND estimated_rows > 100
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  product_ingredient FK join uses index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. product_ingredient join uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM product_ingredient WHERE product_id = 1'
           ) WHERE node_type = 'Seq Scan'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  No critical plan warnings on product detail query pattern
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. product detail pattern has no critical warnings' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT p.*, s.calories, s.fat, s.carbs, s.protein '
               || 'FROM products p '
               || 'LEFT JOIN servings s ON s.product_id = p.product_id '
               || 'AND s.serving_basis = ''per 100 g'' '
               || 'WHERE p.product_id = 1'
           ) WHERE warning LIKE '%Sequential scan%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  Confidence MV lookup uses index (high-frequency operation)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. confidence MV lookup uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM v_product_confidence WHERE product_id = 1'
           ) WHERE node_type = 'Seq Scan'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  Allergen info lookup uses index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. allergen info lookup uses index' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM check_plan_quality(
               'SELECT * FROM product_allergen_info WHERE product_id = 1'
           ) WHERE node_type = 'Seq Scan'
       ) THEN 0 ELSE 1 END AS violations;

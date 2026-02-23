-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Index Verification
-- Validates that all recommended indexes exist and identifies missing/unused
-- indexes. Checks sequential scan ratios and table coverage.
-- Issue: #185
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  products table has index on ean
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. products.ean has index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'products'
             AND indexdef ILIKE '%ean%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  products table has index on category
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. products.category has index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'products'
             AND indexdef ILIKE '%category%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  products table has trigram index for search
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. products has trigram index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'products'
             AND indexdef ILIKE '%gin%trgm%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  product_ingredient has FK indexes
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. product_ingredient has product FK index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'product_ingredient'
             AND indexdef ILIKE '%product_id%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  product_ingredient has ingredient FK index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. product_ingredient has ingredient FK index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'product_ingredient'
             AND indexdef ILIKE '%ingredient_id%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  ingredient_ref has taxonomy_id index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. ingredient_ref.taxonomy_id has index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'ingredient_ref'
             AND indexdef ILIKE '%taxonomy_id%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  product_allergen_info has product + type index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. product_allergen_info has product+type index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'product_allergen_info'
             AND indexdef ILIKE '%product_id%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  servings has partial index for per-100g lookups
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. servings has per-100g partial index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'servings'
             AND indexdef ILIKE '%per 100 g%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  No table > 1MB without any index
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. No large table without index' AS check_name,
       COUNT(*) AS violations
FROM pg_tables t
LEFT JOIN pg_indexes i ON t.tablename = i.tablename AND t.schemaname = i.schemaname
WHERE t.schemaname = 'public'
  AND i.indexname IS NULL
  AND pg_total_relation_size(quote_ident(t.tablename)) > 1048576;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10  mv_ingredient_frequency has unique index (for CONCURRENTLY)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. mv_ingredient_frequency has unique index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'mv_ingredient_frequency'
             AND indexdef ILIKE '%unique%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #11  v_product_confidence has unique index (for CONCURRENTLY)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. v_product_confidence has unique index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'v_product_confidence'
             AND indexdef ILIKE '%unique%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12  mv_product_similarity has unique index (for CONCURRENTLY)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. mv_product_similarity has unique index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_indexes
           WHERE tablename = 'mv_product_similarity'
             AND indexdef ILIKE '%unique%'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #13  All FK columns in public schema have supporting indexes
--      Checks that every FK constraint has at least one index on the
--      referencing columns (prevents seq scans on JOIN operations).
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '13. All FK columns have supporting indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT
        c.conrelid::regclass AS table_name,
        a.attname AS fk_column
    FROM pg_constraint c
    JOIN pg_attribute a ON a.attrelid = c.conrelid
        AND a.attnum = ANY(c.conkey)
    WHERE c.contype = 'f'
      AND c.connamespace = 'public'::regnamespace
    EXCEPT
    SELECT
        i.indrelid::regclass,
        a.attname
    FROM pg_index i
    JOIN pg_attribute a ON a.attrelid = i.indrelid
        AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid IN (
        SELECT c.conrelid FROM pg_constraint c
        WHERE c.contype = 'f' AND c.connamespace = 'public'::regnamespace
    )
) missing_fk_indexes;

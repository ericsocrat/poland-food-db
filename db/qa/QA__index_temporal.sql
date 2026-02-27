-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Index Coverage & Temporal Integrity
-- Validates that performance-critical indexes exist on all high-traffic
-- tables, that timestamp columns are consistent and non-future, and that
-- updated_at triggers fire correctly.
-- 19 checks — all BLOCKING.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- #1  products table has indexes on EAN, category, and country
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '1. products has ean/category/country indexes' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY['ean', 'category', 'country']) AS col
) expected
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_index i
    JOIN pg_class ic ON ic.oid = i.indexrelid
    JOIN pg_attribute a ON a.attrelid = i.indrelid
                       AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid = 'public.products'::regclass
      AND a.attname = expected.col
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #2  nutrition_facts has an index on product_id
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '2. nutrition_facts has product_id index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1
           FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid
                              AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = 'public.nutrition_facts'::regclass
             AND a.attname = 'product_id'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #3  product_ingredient has an index on product_id
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '3. product_ingredient has product_id index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1
           FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid
                              AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = 'public.product_ingredient'::regclass
             AND a.attname = 'product_id'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #4  product_allergen_info has an index on product_id
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '4. product_allergen_info has product_id index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1
           FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid
                              AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = 'public.product_allergen_info'::regclass
             AND a.attname = 'product_id'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #5  product_field_provenance has an index on product_id
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '5. product_field_provenance has product_id index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1
           FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid
                              AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = 'public.product_field_provenance'::regclass
             AND a.attname = 'product_id'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #6  source_nutrition has an index on product_id
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '6. source_nutrition has product_id index' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1
           FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid
                              AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = 'public.source_nutrition'::regclass
             AND a.attname = 'product_id'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #7  products.created_at is never NULL for non-deprecated products
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '7. products.created_at is non-null' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND created_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- #8  products.updated_at is never NULL for non-deprecated products
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '8. products.updated_at is non-null' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND updated_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- #9  products.updated_at >= created_at (temporal consistency)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '9. products updated_at >= created_at' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND updated_at < created_at;

-- ─────────────────────────────────────────────────────────────────────────────
-- #10 No products have created_at more than 1 day in the future
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '10. No future-dated products' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND created_at > now() + interval '1 day';

-- ─────────────────────────────────────────────────────────────────────────────
-- #11 products.updated_at trigger (trg_set_updated_at) exists
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '11. products has updated_at trigger' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM pg_trigger t
           JOIN pg_class c ON t.tgrelid = c.oid
           JOIN pg_namespace n ON c.relnamespace = n.oid
           WHERE n.nspname = 'public'
             AND c.relname = 'products'
             AND t.tgname = 'trg_products_updated_at'
       ) THEN 0 ELSE 1 END AS violations;

-- ─────────────────────────────────────────────────────────────────────────────
-- #12 user_product_lists timestamp consistency (updated_at >= created_at)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '12. user_product_lists updated_at >= created_at' AS check_name,
       COUNT(*) AS violations
FROM user_product_lists
WHERE updated_at < created_at;

-- ─────────────────────────────────────────────────────────────────────────────
-- #13 Every FK column on high-traffic tables is indexed
--     (checks that no FK referencing products is missing a supporting index)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '13. FK columns referencing products are indexed' AS check_name,
       COUNT(*) AS violations
FROM pg_constraint con
JOIN pg_class c ON con.conrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND con.contype = 'f'
  AND con.confrelid = 'public.products'::regclass
  AND NOT EXISTS (
      SELECT 1
      FROM pg_index idx
      WHERE idx.indrelid = con.conrelid
        AND idx.indkey[0] = con.conkey[1]
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- #14 Deprecated products excluded from API search results
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '14. Deprecated products excluded from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('', '{}'::jsonb, 1, 1000)->'results'
    ) r(val)
) search_results
JOIN products p ON p.product_id = search_results.pid::bigint
WHERE p.is_deprecated = true;

-- ─────────────────────────────────────────────────────────────────────────────
-- #19 All FK columns on all public tables are indexed
--     (nutri_score_label, preferred_language, default_language, severity, etc.)
--     Excludes parent_ingredient_id — intentionally unindexed (PR #394 audit).
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '19. All FK columns have supporting indexes' AS check_name,
       COUNT(*) AS violations
FROM pg_constraint con
JOIN pg_class c ON con.conrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND con.contype = 'f'
  AND con.conname <> 'product_ingredient_parent_ingredient_id_fkey'
  AND NOT EXISTS (
      SELECT 1
      FROM pg_index idx
      JOIN pg_attribute a ON a.attrelid = idx.indrelid
                         AND a.attnum = ANY(idx.indkey)
      WHERE idx.indrelid = con.conrelid
        AND a.attnum = con.conkey[1]
  );
-- ─────────────────────────────────────────────────────────────────────────────
-- #16 Core tables have updated_at triggers
--     (6 data tables + products + user_product_lists = 8 expected)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '16. updated_at triggers exist on core tables' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT unnest(ARRAY[
        'nutrition_facts',
        'product_ingredient',
        'product_allergen_info',
        'ingredient_ref',
        'category_ref',
        'country_ref'
    ]) AS tbl
) expected
WHERE NOT EXISTS (
    SELECT 1 FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND c.relname = expected.tbl
      AND t.tgname = 'trg_' || expected.tbl || '_updated_at'
      AND NOT t.tgisinternal
);

-- ─────────────────────────────────────────────────────────────────────────────
-- #17 No NULL updated_at on core tables with data
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '17. no NULL updated_at on core tables' AS check_name,
       COALESCE(SUM(violations), 0)::bigint AS violations
FROM (
    SELECT COUNT(*) AS violations FROM nutrition_facts       WHERE updated_at IS NULL
    UNION ALL
    SELECT COUNT(*) FROM ingredient_ref                      WHERE updated_at IS NULL
    UNION ALL
    SELECT COUNT(*) FROM category_ref                        WHERE updated_at IS NULL
    UNION ALL
    SELECT COUNT(*) FROM country_ref                         WHERE updated_at IS NULL
) sub;

-- ─────────────────────────────────────────────────────────────────────────────
-- #18 No future timestamps on core table updated_at columns
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '18. no future updated_at on core tables' AS check_name,
       COALESCE(SUM(violations), 0)::bigint AS violations
FROM (
    SELECT COUNT(*) AS violations FROM nutrition_facts       WHERE updated_at > now() + interval '1 minute'
    UNION ALL
    SELECT COUNT(*) FROM ingredient_ref                      WHERE updated_at > now() + interval '1 minute'
    UNION ALL
    SELECT COUNT(*) FROM category_ref                        WHERE updated_at > now() + interval '1 minute'
    UNION ALL
    SELECT COUNT(*) FROM country_ref                         WHERE updated_at > now() + interval '1 minute'
) sub;

-- ─────────────────────────────────────────────────────────────────────────────
-- #15 Deprecated products excluded from category listing
-- ─────────────────────────────────────────────────────────────────────────────
SELECT '15. Deprecated products excluded from category listing' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM (
        SELECT DISTINCT category FROM products WHERE is_deprecated IS NOT TRUE LIMIT 1
    ) cat
    CROSS JOIN LATERAL jsonb_array_elements(
        api_category_listing(cat.category, 'score', 'asc', 1000, 0)->'products'
    ) r(val)
) listing_results
JOIN products p ON p.product_id = listing_results.pid::bigint
WHERE p.is_deprecated = true;

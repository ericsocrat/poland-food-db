-- ═══════════════════════════════════════════════════════════════════════════════
-- QA Suite: Allergen Filtering
-- Validates allergen exclusion, may-contain handling, and strict mode.
-- 6 checks.
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Avoiding gluten excludes products that contain gluten
SELECT '1. gluten avoidance excludes gluten-containing from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', NULL, 100, 0, NULL, NULL, ARRAY['en:gluten'])->'results'
    ) r(val)
) search_results
WHERE EXISTS (
    SELECT 1 FROM product_allergen_info ai
    WHERE ai.product_id = search_results.pid::bigint
      AND ai.type = 'contains'
      AND ai.tag = 'en:gluten'
);

-- 2. Avoiding milk excludes products that contain milk
SELECT '2. milk avoidance excludes milk-containing from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', NULL, 100, 0, NULL, NULL, ARRAY['en:milk'])->'results'
    ) r(val)
) search_results
WHERE EXISTS (
    SELECT 1 FROM product_allergen_info ai
    WHERE ai.product_id = search_results.pid::bigint
      AND ai.type = 'contains'
      AND ai.tag = 'en:milk'
);

-- 3. May-contain toggle excludes trace allergens when enabled
SELECT '3. treat_may_contain excludes traces from search' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_search_products('a', NULL, 100, 0, NULL, NULL, ARRAY['en:gluten'], false, false, true)->'results'
    ) r(val)
) search_results
WHERE EXISTS (
    SELECT 1 FROM product_allergen_info ai
    WHERE ai.product_id = search_results.pid::bigint
      AND ai.type IN ('contains','traces')
      AND ai.tag = 'en:gluten'
);

-- 4. Allergen filter works on category listing
SELECT '4. allergen filter excludes from category listing' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT r.val->>'product_id' AS pid
    FROM jsonb_array_elements(
        api_category_listing('Chips', 'score', 'asc', 100, 0, NULL, NULL, ARRAY['en:milk'])->'products'
    ) r(val)
) listing_results
WHERE EXISTS (
    SELECT 1 FROM product_allergen_info ai
    WHERE ai.product_id = listing_results.pid::bigint
      AND ai.type = 'contains'
      AND ai.tag = 'en:milk'
);

-- 5. Allergen filter works on better alternatives
SELECT '5. allergen filter excludes from better alternatives' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT p.product_id
    FROM products p
    WHERE p.is_deprecated IS NOT TRUE AND p.unhealthiness_score > 20
    LIMIT 3
) sample
CROSS JOIN LATERAL find_better_alternatives(
    sample.product_id, true, 5, NULL, ARRAY['en:milk']
) AS alt
WHERE EXISTS (
    SELECT 1 FROM product_allergen_info ai
    WHERE ai.product_id = alt.alt_product_id
      AND ai.type = 'contains'
      AND ai.tag = 'en:milk'
);

-- 6. Without allergen filter, products with allergens appear normally
SELECT '6. no allergen filter includes all products' AS check_name,
       CASE WHEN (
           SELECT COUNT(*)
           FROM (
               SELECT r.val->>'product_id' AS pid
               FROM jsonb_array_elements(
                   api_search_products('ch', NULL, 100, 0)->'results'
               ) r(val)
           ) search_results
           WHERE EXISTS (
               SELECT 1 FROM product_allergen_info ai
               WHERE ai.product_id = search_results.pid::bigint
                 AND ai.type = 'contains'
           )
       ) > 0
       THEN 0 ELSE 1 END AS violations;

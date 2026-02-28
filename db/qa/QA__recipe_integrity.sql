-- ============================================================
-- QA: Recipe Data Integrity
-- Validates recipe tables, FK relationships, and data quality.
-- 6 checks — all BLOCKING.
-- Issue: #364 — Recipe system completion
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. All recipe_step rows reference existing recipes
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. recipe_step.recipe_id references recipe' AS check_name,
       COUNT(*) AS violations
FROM recipe_step rs
LEFT JOIN recipe r ON r.id = rs.recipe_id
WHERE r.id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. All recipe_ingredient rows reference existing recipes
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. recipe_ingredient.recipe_id references recipe' AS check_name,
       COUNT(*) AS violations
FROM recipe_ingredient ri
LEFT JOIN recipe r ON r.id = ri.recipe_id
WHERE r.id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. All recipe_ingredient_product rows reference active products
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. recipe_ingredient_product references active products' AS check_name,
       COUNT(*) AS violations
FROM recipe_ingredient_product rip
JOIN products p ON p.product_id = rip.product_id
WHERE p.is_deprecated = TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Published recipes must have at least 1 ingredient and 1 step
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. published recipes have ingredients and steps' AS check_name,
       COUNT(*) AS violations
FROM recipe r
WHERE r.is_published = TRUE
  AND (
    NOT EXISTS (SELECT 1 FROM recipe_ingredient ri WHERE ri.recipe_id = r.id)
    OR
    NOT EXISTS (SELECT 1 FROM recipe_step rs WHERE rs.recipe_id = r.id)
  );

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. No duplicate step numbers within a recipe
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. no duplicate step numbers per recipe' AS check_name,
       COUNT(*) AS violations
FROM (
    SELECT rs.recipe_id, rs.step_number, COUNT(*) AS cnt
    FROM recipe_step rs
    GROUP BY rs.recipe_id, rs.step_number
    HAVING COUNT(*) > 1
) dupes;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. API functions exist and are callable
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. recipe API functions exist' AS check_name,
       3 - COUNT(*)::int AS violations
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
    'api_get_recipes',
    'api_get_recipe_detail',
    'api_get_recipe_nutrition'
  );

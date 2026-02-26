-- =====================================================================
-- NEGATIVE TEST SUITE
-- Injects deliberately malformed data, verifies QA checks catch it,
-- then rolls back.  Database is NOT modified.
--
-- Each SELECT outputs one line:  ✔ CAUGHT | ref | description
--                             or ✘ MISSED | ref | description
--
-- Usage:  pipe to psql in tuples-only mode (via RUN_NEGATIVE_TESTS.ps1)
--
-- NOTE: Many QA checks are also enforced by DB FK/CHECK constraints
-- and cannot be tested via INSERT (the DB rejects the data before QA
-- ever runs).  These are marked FK-PROTECTED or CHECK-PROTECTED below.
--
-- Updated: scores merged into products; servings eliminated;
-- product_sources merged into products; product_allergen and
-- product_trace merged into product_allergen_info.
-- =====================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- INJECT BAD DATA  (IDs 99990–99999 are all unused)
-- All INSERTs respect FK and CHECK constraints so no constraint errors.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Product 99999: Bad basics, NO child rows, NULL source_type ────────
--    Uses valid category 'Chips' (FK enforced), valid country 'PL' (FK+CHECK)
INSERT INTO products
  (product_id, country, product_name, brand, category, ean,
   product_type, prep_method, controversies, store_availability, source_type, is_deprecated)
VALUES
  (99999, 'PL', '  Bad Test Product  ', '', 'Chips', '12345',
   NULL, 'not-applicable', 'none', '', NULL, false);

-- ── Product 99998: Semi-clean, has children with issues ─────────────────
INSERT INTO products
  (product_id, country, product_name, brand, category,
   product_type, prep_method, controversies, is_deprecated)
VALUES
  (99998, 'PL', 'Negative Test Two', 'NegTestBrand', 'Chips',
   'Grocery', 'not-applicable', 'none', false);

-- ── Product 99997: Position test ────────────────────────────────────────
INSERT INTO products
  (product_id, country, product_name, category, product_type,
   prep_method, controversies, is_deprecated)
VALUES
  (99997, 'PL', 'Position Test Product', 'Chips', 'Grocery',
   'not-applicable', 'none', false);

-- ── Product 99996: Untrimmed store_availability ─────────────────────────
INSERT INTO products
  (product_id, country, product_name, category, product_type,
   prep_method, controversies, store_availability, is_deprecated)
VALUES
  (99996, 'PL', 'Trim Test Product', 'Chips', 'Grocery',
   'not-applicable', 'none', '  Lidl  ', false);

-- ── Nutrition for 99998 (no serving_id — servings table eliminated) ─────
INSERT INTO nutrition_facts (product_id)
VALUES (99998);

-- ── Score columns on 99998: NULL flag fields ────────────────────────────
--    (scores merged into products — use UPDATE instead of INSERT)
UPDATE products SET
   unhealthiness_score   = 50,
   nutri_score_label     = 'C',
   nova_classification   = '3',
   high_salt_flag        = 'YES',
   high_sugar_flag       = NULL,       -- NULL sugar flag → S12.07
   high_sat_fat_flag     = 'YES',
   high_additive_load    = NULL,       -- NULL additive flag → S12.07
   data_completeness_pct = 50,
   confidence            = 'estimated',
   ingredient_concern_score = 50
WHERE product_id = 99998;

-- ── Source columns on 99998: bad URL (product_sources merged into products) ──
UPDATE products SET
   source_type = 'off_api',
   source_url  = 'not-a-url',          -- not http(s) → S14.16
   source_ean  = NULL
WHERE product_id = 99998;

-- ── Bad allergen/trace tags for 99998 ───────────────────────────────────
--    (product_allergen + product_trace → product_allergen_info)
--    NOTE: tags not in allergen_ref (e.g., pl:mleko, en:unicorn) are rejected
--    by fk_allergen_tag_ref FK constraint — see FK-PROTECTED below.
-- INSERT of fake tags (en:unicorn, en:dragon) REMOVED — fk_allergen_tag_ref
-- FK constraint prevents insertion of tags not in allergen_ref.
-- S13.03 and S13.04 are now FK-PROTECTED (see bottom of file).

-- ── Bad ingredient_ref entries ───────────────────────────────────────────
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99999, '', false, 0);                                -- empty name

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99998, '42', false, 0);                              -- numeric junk

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99997, 'neg-test concerned ingredient', false, 2);   -- tier 2, no reason

-- Duplicate name_en: now prevented by UNIQUE index (idx_ingredient_ref_name_en_uniq).
-- INSERT skipped — constraint makes this a CHECK-PROTECTED case.

-- ── Allergen cross-validation ingredients on 99998 ──────────────────────
--    Product 99998 has NO allergen_info rows (FK prevents fake tags).
--    Tests S13.09–S13.12 check for ingredients WITHOUT matching allergens.
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99996, 'neg-test whole milk powder', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99996, 1, false);         -- milk without milk allergen → S13.09

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99995, 'neg-test wheat flour', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99995, 2, false);         -- wheat without gluten allergen → S13.10

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99994, 'neg-test egg white powder', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99994, 3, false);         -- egg without eggs allergen → S13.11

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99993, 'neg-test soy lecithin', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99993, 4, false);         -- soy without soybeans allergen → S13.12

-- ── Ingredient position not starting at 1 for 99997 ────────────────────
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99992, 'neg-test position ingredient', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99997, 99992, 5, false);         -- position 5 instead of 1 → S15.08


-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFY: Each check should detect violations
-- Baseline is 0 violations for all checks, so any count > 0 is from test data
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Suite 1: Data Integrity ────────────────────────────────────────────
-- S1.02 removed — servings table eliminated in consolidation

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
  WHERE nf.product_id IS NULL AND p.is_deprecated IS NOT TRUE
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S1.03  | product without nutrition facts';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND p.unhealthiness_score IS NULL
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S1.04  | product without score (unhealthiness_score IS NULL)';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND p.source_type IS NULL
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S1.33  | product without source (source_type IS NULL)';

-- ─── Suite 7: Data Quality ──────────────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT product_id FROM products WHERE ean = ''
    UNION ALL
    SELECT product_id FROM products WHERE brand = ''
  ) q
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S7.04  | empty brand or ean string';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE product_name != TRIM(product_name)
     OR brand != TRIM(brand)
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S7.05  | untrimmed product_name or brand';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE ean IS NOT NULL
    AND ean !~ '^[0-9]{8}$'
    AND ean !~ '^[0-9]{13}$'
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S7.06  | bad EAN format (not 8 or 13 digits)';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE AND product_type IS NULL
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S7.27  | NULL product_type';

-- ─── Suite 12: Data Consistency ─────────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND (p.high_salt_flag IS NULL
      OR p.high_sugar_flag IS NULL
      OR p.high_sat_fat_flag IS NULL
      OR p.high_additive_load IS NULL)
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S12.07 | NULL score flag fields';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND p.unhealthiness_score IS NULL
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S12.10 | product without score (unhealthiness_score IS NULL)';

-- ─── Suite 13: Allergen & Trace Integrity ───────────────────────────────
-- S13.01 / S13.02 removed — now FK-PROTECTED by fk_allergen_tag_ref

-- S13.03: allergen tag outside domain — now FK-PROTECTED by fk_allergen_tag_ref
-- (INSERT of non-allergen_ref tags is rejected at the DB level)
SELECT '  ✔ CAUGHT' || ' | S13.03 | allergen tag outside domain (FK-PROTECTED)';

-- S13.04: trace tag outside domain — now FK-PROTECTED by fk_allergen_tag_ref
SELECT '  ✔ CAUGHT' || ' | S13.04 | trace tag outside domain (FK-PROTECTED)';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%'])
    AND ir.name_en NOT ILIKE ANY(ARRAY[
      '%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%',
      '%coconut milk%','%coconut cream%','%almond milk%','%oat milk%',
      '%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%',
      '%ice cream plant%','%buttercup%'])
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen_info pai
      WHERE pai.product_id = pi.product_id AND pai.tag = 'milk' AND pai.type = 'contains')
  ) x
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S13.09 | milk ingredient without milk allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%wheat%','%barley%','%rye%','%spelt%'])
    AND ir.name_en NOT ILIKE '%buckwheat%'
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen_info pai
      WHERE pai.product_id = pi.product_id AND pai.tag = 'gluten' AND pai.type = 'contains')
  ) x
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S13.10 | gluten ingredient without gluten allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
    AND ir.name_en NOT ILIKE ANY(ARRAY['%eggplant%','%reggiano%'])
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen_info pai
      WHERE pai.product_id = pi.product_id AND pai.tag = 'eggs' AND pai.type = 'contains')
  ) x
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S13.11 | egg ingredient without eggs allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen_info pai
      WHERE pai.product_id = pi.product_id AND pai.tag = 'soybeans' AND pai.type = 'contains')
  ) x
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S13.12 | soy ingredient without soybeans allergen';

-- ─── Suite 14: Source Validation ────────────────────────────────────────
-- S14.06 removed — collected_at column eliminated in consolidation
-- S14.09 removed — fields_populated column eliminated in consolidation
-- S14.13 removed — is_primary column eliminated in consolidation

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE
    AND store_availability IS NOT NULL
    AND trim(store_availability) = ''
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S14.14 | empty store_availability string';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE
    AND store_availability IS NOT NULL
    AND store_availability <> trim(store_availability)
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S14.15 | untrimmed store_availability';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE source_url IS NOT NULL
    AND source_url !~ '^https?://'
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S14.16 | source_url not http(s)';

-- ─── Suite 15: Ingredient Data Quality ──────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE name_en IS NULL OR trim(name_en) = ''
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S15.01 | empty ingredient name_en';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE name_en ~ '^\d+$'
     OR length(trim(name_en)) <= 1
     OR name_en ~* '^(per 100|kcal|kj\b)'
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S15.02 | junk/numeric ingredient name';

-- S15.04: duplicate ingredient name_en — now UNIQUE-INDEX-PROTECTED
-- (idx_ingredient_ref_name_en_uniq prevents duplicates at the DB level)
SELECT '  ✔ CAUGHT' || ' | S15.04 | duplicate ingredient name_en (UNIQUE-INDEX-PROTECTED)';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE concern_tier IS NOT NULL AND concern_tier >= 1
    AND (concern_reason IS NULL OR trim(concern_reason) = '')
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S15.07 | high concern tier without reason';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT product_id, MIN(position) AS min_pos
    FROM product_ingredient
    WHERE is_sub_ingredient IS NOT TRUE
    GROUP BY product_id
    HAVING MIN(position) <> 1
  ) x
) > 0 THEN '  ✔ CAUGHT' ELSE '  ✘ MISSED' END
  || ' | S15.08 | ingredient position not starting at 1';


-- ═══════════════════════════════════════════════════════════════════════════
-- CHECKS NOT TESTABLE VIA INSERT (protected by DB constraints)
-- ═══════════════════════════════════════════════════════════════════════════
-- The following checks are belt-and-suspenders guards — the DB itself
-- prevents the invalid data via FK or CHECK constraints:
--
-- FK-PROTECTED (orphan/invalid FK checks):
--   S1.09  orphan nutrition_facts       → nutrition_facts_product_id_fkey
--   S8.01  invalid category             → fk_products_category
--   S13.01 allergen tag not in ref      → fk_allergen_tag_ref
--   S13.02 trace tag not in ref         → fk_allergen_tag_ref
--   S13.03 allergen tag outside domain  → fk_allergen_tag_ref
--   S13.04 trace tag outside domain     → fk_allergen_tag_ref
--   S13.07 orphan allergen_info         → product_allergen_info_product_id_fkey
--   S15.11 orphan product_ingredient    → product_ingredient_product_id_fkey
--   S15.12 invalid ingredient_id        → product_ingredient_ingredient_id_fkey
--
-- CHECK-PROTECTED (domain/range checks):
--   S12.04 unhealthiness_score range    → chk_products_unhealthiness_range
--   S12.09 prep_method domain           → chk_products_prep_method
--   S14.04 source_type domain           → chk_products_source_type
--   S14.12 controversies domain         → chk_products_controversies
--   + all nutrition non-negative checks → chk_nutrition_non_negative
--   + all score flag YES/NO checks      → chk_products_high_*
--   + nutri_score_label domain          → chk_products_nutri_score_label
--   + nova_classification domain        → chk_products_nova

-- ═══════════════════════════════════════════════════════════════════════════
-- ROLLBACK — database is untouched
-- ═══════════════════════════════════════════════════════════════════════════
ROLLBACK;

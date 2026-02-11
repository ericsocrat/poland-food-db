-- =====================================================================
-- NEGATIVE TEST SUITE
-- Injects deliberately malformed data, verifies QA checks catch it,
-- then rolls back.  Database is NOT modified.
--
-- Each SELECT outputs one line:  ✓ CAUGHT | ref | description
--                             or ✗ MISSED | ref | description
--
-- Usage:  pipe to psql in tuples-only mode (via RUN_NEGATIVE_TESTS.ps1)
--
-- NOTE: Many QA checks are also enforced by DB FK/CHECK constraints
-- and cannot be tested via INSERT (the DB rejects the data before QA
-- ever runs).  These are marked FK-PROTECTED or CHECK-PROTECTED below.
-- =====================================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- INJECT BAD DATA  (IDs 99990–99999 are all unused)
-- All INSERTs respect FK and CHECK constraints so no constraint errors.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Product 99999: Bad basics, NO child rows ──────────────────────────────
--    Uses valid category 'Chips' (FK enforced), valid country 'PL' (FK+CHECK)
INSERT INTO products
  (product_id, country, product_name, brand, category, ean,
   product_type, prep_method, controversies, store_availability, is_deprecated)
VALUES
  (99999, 'PL', '  Bad Test Product  ', '', 'Chips', '12345',
   NULL, 'not-applicable', 'none', '', false);

-- ── Product 99998: Semi-clean, has children with issues ───────────────────
INSERT INTO products
  (product_id, country, product_name, brand, category,
   product_type, prep_method, controversies, is_deprecated)
VALUES
  (99998, 'PL', 'Negative Test Two', 'NegTestBrand', 'Chips',
   'Grocery', 'not-applicable', 'none', false);

-- ── Product 99997: Position test ──────────────────────────────────────────
INSERT INTO products
  (product_id, country, product_name, category, product_type,
   prep_method, controversies, is_deprecated)
VALUES
  (99997, 'PL', 'Position Test Product', 'Chips', 'Grocery',
   'not-applicable', 'none', false);

-- ── Product 99996: Untrimmed store_availability ───────────────────────────
INSERT INTO products
  (product_id, country, product_name, category, product_type,
   prep_method, controversies, store_availability, is_deprecated)
VALUES
  (99996, 'PL', 'Trim Test Product', 'Chips', 'Grocery',
   'not-applicable', 'none', '  Lidl  ', false);

-- ── Serving for 99998 ─────────────────────────────────────────────────────
INSERT INTO servings (serving_id, product_id, serving_basis)
VALUES (99999, 99998, 'per 100 g');

-- ── Nutrition for 99998 ───────────────────────────────────────────────────
INSERT INTO nutrition_facts (product_id, serving_id)
VALUES (99998, 99999);

-- ── Score for 99998: NULL flag fields ─────────────────────────────────────
INSERT INTO scores
  (product_id, unhealthiness_score, nutri_score_label, nova_classification,
   high_salt_flag, high_sugar_flag, high_sat_fat_flag, high_additive_load,
   data_completeness_pct, confidence, ingredient_concern_score)
VALUES
  (99998, 50, 'C', '3',
   'YES', NULL, 'YES', NULL,          -- NULL sugar & additive flags → S12.07
   50, 'estimated', 50);

-- ── Source for 99998: bad URL, empty fields, future date, not primary ─────
INSERT INTO product_sources
  (product_source_id, product_id, source_type, source_url,
   fields_populated, collected_at, is_primary, confidence_pct)
OVERRIDING SYSTEM VALUE
VALUES
  (99999, 99998, 'off_api', 'not-a-url',
   '{}', '2027-06-15'::timestamptz, false, 80);

-- ── Bad allergen/trace tags for 99998 ─────────────────────────────────────
INSERT INTO product_allergen VALUES (99998, 'pl:mleko');     -- non-en prefix
INSERT INTO product_allergen VALUES (99998, 'en:unicorn');   -- outside domain
INSERT INTO product_trace   VALUES (99998, 'fr:lait');       -- non-en prefix
INSERT INTO product_trace   VALUES (99998, 'en:dragon');     -- outside domain

-- ── Bad ingredient_ref entries ────────────────────────────────────────────
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99999, '', false, 0);                                -- empty name

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99998, '42', false, 0);                              -- numeric junk

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99997, 'neg-test concerned ingredient', false, 2);   -- tier 2, no reason

-- Duplicate name_en: copy first existing ingredient's name
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
SELECT 99991, ir.name_en, false, 0
FROM ingredient_ref ir
WHERE ir.ingredient_id NOT BETWEEN 99990 AND 99999
ORDER BY ir.ingredient_id LIMIT 1;

-- ── Allergen cross-validation ingredients on 99998 ────────────────────────
--    Product 99998 has allergens pl:mleko + en:unicorn but NOT
--    en:milk / en:gluten / en:eggs / en:soybeans
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99996, 'neg-test whole milk powder', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99996, 1, false);         -- milk without en:milk → S13.09

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99995, 'neg-test wheat flour', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99995, 2, false);         -- wheat without en:gluten → S13.10

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99994, 'neg-test egg white powder', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99994, 3, false);         -- egg without en:eggs → S13.11

INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99993, 'neg-test soy lecithin', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99998, 99993, 4, false);         -- soy without en:soybeans → S13.12

-- ── Ingredient position not starting at 1 for 99997 ──────────────────────
INSERT INTO ingredient_ref (ingredient_id, name_en, is_additive, concern_tier)
OVERRIDING SYSTEM VALUE
VALUES (99992, 'neg-test position ingredient', false, 0);
INSERT INTO product_ingredient (product_id, ingredient_id, position, is_sub_ingredient)
VALUES (99997, 99992, 5, false);         -- position 5 instead of 1 → S15.08


-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFY: Each check should detect violations
-- Baseline is 0 violations for all checks, so any count > 0 is from test data
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Suite 1: Data Integrity ──────────────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  LEFT JOIN servings sv ON sv.product_id = p.product_id
  WHERE sv.serving_id IS NULL AND p.is_deprecated IS NOT TRUE
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S1.02  | product without serving row';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  LEFT JOIN nutrition_facts nf ON nf.product_id = p.product_id
  WHERE nf.product_id IS NULL AND p.is_deprecated IS NOT TRUE
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S1.03  | product without nutrition facts';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  LEFT JOIN scores sc ON sc.product_id = p.product_id
  WHERE sc.product_id IS NULL AND p.is_deprecated IS NOT TRUE
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S1.04  | product without score row';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  LEFT JOIN product_sources ps ON ps.product_id = p.product_id
  WHERE p.is_deprecated IS NOT TRUE AND ps.product_source_id IS NULL
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S1.33  | product without source row';

-- ─── Suite 7: Data Quality ────────────────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT product_id FROM products WHERE ean = ''
    UNION ALL
    SELECT product_id FROM products WHERE brand = ''
  ) q
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S7.04  | empty brand or ean string';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE product_name != TRIM(product_name)
     OR brand != TRIM(brand)
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S7.05  | untrimmed product_name or brand';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE ean IS NOT NULL
    AND ean !~ '^[0-9]{8}$'
    AND ean !~ '^[0-9]{13}$'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S7.06  | bad EAN format (not 8 or 13 digits)';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE AND product_type IS NULL
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S7.27  | NULL product_type';

-- ─── Suite 12: Data Consistency ───────────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM scores s
  JOIN products p ON p.product_id = s.product_id AND p.is_deprecated IS NOT TRUE
  WHERE s.high_salt_flag IS NULL
     OR s.high_sugar_flag IS NULL
     OR s.high_sat_fat_flag IS NULL
     OR s.high_additive_load IS NULL
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S12.07 | NULL score flag fields';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products p
  WHERE p.is_deprecated IS NOT TRUE
    AND NOT EXISTS (SELECT 1 FROM scores s WHERE s.product_id = p.product_id)
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S12.10 | product without score row';

-- ─── Suite 13: Allergen & Trace Integrity ─────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_allergen WHERE allergen_tag NOT LIKE 'en:%'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.01 | allergen tag non-en: prefix';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_trace WHERE trace_tag NOT LIKE 'en:%'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.02 | trace tag non-en: prefix';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_allergen
  WHERE allergen_tag NOT IN (
    'en:gluten','en:milk','en:eggs','en:fish','en:crustaceans','en:molluscs',
    'en:peanuts','en:nuts','en:soybeans','en:celery','en:mustard',
    'en:sesame-seeds','en:lupin','en:sulphur-dioxide-and-sulphites',
    'en:kiwi','en:pork','en:none','en:peach')
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.03 | allergen tag outside domain';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_trace
  WHERE trace_tag NOT IN (
    'en:gluten','en:milk','en:eggs','en:fish','en:crustaceans','en:molluscs',
    'en:peanuts','en:nuts','en:soybeans','en:celery','en:mustard',
    'en:sesame-seeds','en:lupin','en:sulphur-dioxide-and-sulphites',
    'en:kiwi','en:pork','en:none')
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.04 | trace tag outside domain';

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
      SELECT 1 FROM product_allergen pa
      WHERE pa.product_id = pi.product_id AND pa.allergen_tag = 'en:milk')
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.09 | milk ingredient without en:milk allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%wheat%','%barley%','%rye%','%spelt%'])
    AND ir.name_en NOT ILIKE '%buckwheat%'
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen pa
      WHERE pa.product_id = pi.product_id AND pa.allergen_tag = 'en:gluten')
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.10 | gluten ingredient without en:gluten allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
    AND ir.name_en NOT ILIKE ANY(ARRAY['%eggplant%','%reggiano%'])
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen pa
      WHERE pa.product_id = pi.product_id AND pa.allergen_tag = 'en:eggs')
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.11 | egg ingredient without en:eggs allergen';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT DISTINCT pi.product_id
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
    WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
    AND NOT EXISTS (
      SELECT 1 FROM product_allergen pa
      WHERE pa.product_id = pi.product_id AND pa.allergen_tag = 'en:soybeans')
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S13.12 | soy ingredient without en:soybeans allergen';

-- ─── Suite 14: Serving & Source Validation ────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_sources
  WHERE collected_at > NOW() + INTERVAL '1 day'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.06 | future collected_at';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_sources
  WHERE fields_populated IS NULL
     OR array_length(fields_populated, 1) IS NULL
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.09 | empty fields_populated array';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT ps.product_id
    FROM product_sources ps
    GROUP BY ps.product_id
    HAVING bool_or(is_primary) IS NOT TRUE
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.13 | product with no primary source';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE
    AND store_availability IS NOT NULL
    AND trim(store_availability) = ''
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.14 | empty store_availability string';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM products
  WHERE is_deprecated IS NOT TRUE
    AND store_availability IS NOT NULL
    AND store_availability <> trim(store_availability)
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.15 | untrimmed store_availability';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM product_sources
  WHERE source_url IS NOT NULL
    AND source_url !~ '^https?://'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S14.16 | source_url not http(s)';

-- ─── Suite 15: Ingredient Data Quality ────────────────────────────────────
SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE name_en IS NULL OR trim(name_en) = ''
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S15.01 | empty ingredient name_en';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE name_en ~ '^\d+$'
     OR length(trim(name_en)) <= 1
     OR name_en ~* '^(per 100|kcal|kj\b)'
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S15.02 | junk/numeric ingredient name';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT name_en FROM ingredient_ref
    GROUP BY name_en HAVING COUNT(*) > 1
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S15.04 | duplicate ingredient name_en';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM ingredient_ref
  WHERE concern_tier IS NOT NULL AND concern_tier >= 1
    AND (concern_reason IS NULL OR trim(concern_reason) = '')
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S15.07 | high concern tier without reason';

SELECT CASE WHEN (
  SELECT COUNT(*) FROM (
    SELECT product_id, MIN(position) AS min_pos
    FROM product_ingredient
    WHERE is_sub_ingredient IS NOT TRUE
    GROUP BY product_id
    HAVING MIN(position) <> 1
  ) x
) > 0 THEN '  ✓ CAUGHT' ELSE '  ✗ MISSED' END
  || ' | S15.08 | ingredient position not starting at 1';


-- ═══════════════════════════════════════════════════════════════════════════
-- CHECKS NOT TESTABLE VIA INSERT (protected by DB constraints)
-- ═══════════════════════════════════════════════════════════════════════════
-- The following checks are belt-and-suspenders guards — the DB itself
-- prevents the invalid data via FK or CHECK constraints:
--
-- FK-PROTECTED (orphan/invalid FK checks):
--   S1.08  orphan servings              → servings_product_id_fkey
--   S1.09  orphan nutrition_facts       → nutrition_facts_product_id_fkey
--   S1.12  orphan scores               → scores_product_id_fkey
--   S8.01  invalid category             → fk_products_category
--   S8.18  invalid serving_id           → nutrition_facts_serving_id_fkey
--   S12.17 orphan serving               → servings_product_id_fkey
--   S12.18 orphan score                 → scores_product_id_fkey
--   S13.07 orphan allergen              → product_allergen_product_id_fkey
--   S13.08 orphan trace                 → product_trace_product_id_fkey
--   S15.11 orphan product_ingredient    → product_ingredient_product_id_fkey
--   S15.12 invalid ingredient_id        → product_ingredient_ingredient_id_fkey
--
-- CHECK-PROTECTED (domain/range checks):
--   S12.04 unhealthiness_score range    → chk_scores_unhealthiness_range
--   S12.09 prep_method domain           → chk_products_prep_method
--   S14.01 serving_basis domain         → chk_servings_basis
--   S14.04 source_type domain           → chk_ps_source_type
--   S14.12 controversies domain         → chk_products_controversies
--   + all nutrition non-negative checks → chk_nutrition_non_negative
--   + all score flag YES/NO checks      → chk_scores_high_*
--   + nutri_score_label domain          → chk_scores_nutri_score_label
--   + nova_classification domain        → chk_scores_nova

-- ═══════════════════════════════════════════════════════════════════════════
-- ROLLBACK — database is untouched
-- ═══════════════════════════════════════════════════════════════════════════
ROLLBACK;

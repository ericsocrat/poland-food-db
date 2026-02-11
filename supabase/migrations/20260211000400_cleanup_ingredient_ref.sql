-- Migration: cleanup_ingredient_ref
-- Date: 2026-02-11
-- Audit phase: ingredient ecosystem standardisation
--
-- Problems discovered during column-by-column audit:
--   1. taxonomy_id — 13 language-prefix variants (en:, pl:, fr:, …), never
--      queried by any function/view/MV. Redundant with name_en.
--   2. is_in_taxonomy — never queried anywhere.
--   3. created_at — all 1 257 rows share the same timestamp; never queried.
--   4. 64 duplicate name_en groups (same English ingredient from different
--      OFF language tags, e.g. en:salt vs pl:sol → both "salt"). 72 extra
--      rows to merge away; some have inconsistent vegan/vegetarian metadata.
--   5. 23 junk/parser-artefact entries ("and", "", "l", "f", "ii",
--      "footnote", "may contain …", etc.) with 29 product_ingredient rows.
--   6. 14 Żabka products have additives_count > 0 but no ingredients_raw
--      and zero product_ingredient rows — unverifiable; set to 0 and re-score.
--
-- Post-cleanup targets:
--   ingredient_ref : 1 257 → ~1 162 rows,  11 → 8 columns
--   product_ingredient : 7 435 → ~7 403 rows
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 1: Clean up junk entries
-- 23 parser-artefact rows + 29 product_ingredient rows pointing to them.
-- 4 of these are used as parent_ingredient_id → set NULL first.
-- ─────────────────────────────────────────────────────────────────────────

-- Collect junk ingredient_ids into a temp table for reuse
CREATE TEMP TABLE _junk_ids AS
SELECT ingredient_id
FROM ingredient_ref
WHERE name_en IN ('and', 'l', '', 'f', 'ii', 'footnote')
   OR name_en LIKE 'may contain%'
   OR name_en LIKE 'and %'
   OR name_en LIKE 'the product%'
   OR name_en LIKE 'product may%'
   OR name_en LIKE 'in total%'
   OR name_en LIKE '%traces of%';

-- 1a. Delete product_ingredient rows whose ingredient IS junk (29 rows).
--     Must happen BEFORE nulling parents, because some of these rows are
--     sub-ingredients of junk parents and clearing the parent first would
--     violate chk_sub_has_parent.
DELETE FROM product_ingredient
WHERE  ingredient_id IN (SELECT ingredient_id FROM _junk_ids);

-- 1b. For remaining rows whose parent is junk: clear the meaningless
--     parent link AND demote from sub-ingredient (satisfies chk_sub_has_parent).
UPDATE product_ingredient
SET    parent_ingredient_id = NULL,
       is_sub_ingredient    = false
WHERE  parent_ingredient_id IN (SELECT ingredient_id FROM _junk_ids);

-- 1c. Delete the junk ingredient_ref rows themselves (23 rows)
DELETE FROM ingredient_ref
WHERE  ingredient_id IN (SELECT ingredient_id FROM _junk_ids);

DROP TABLE _junk_ids;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 2: Merge duplicate name_en groups
-- 64 groups where the same English name appears on multiple ingredient_ref
-- rows (different language-prefix taxonomy_ids).  Keep the row with the
-- lowest ingredient_id (canonical — almost always the en: variant which
-- has the best vegan/vegetarian/palm_oil metadata).
-- ─────────────────────────────────────────────────────────────────────────

-- Build mapping: non-canonical ingredient_id → canonical ingredient_id
CREATE TEMP TABLE _dup_map AS
SELECT ir.ingredient_id AS old_id,
       (SELECT MIN(ir2.ingredient_id)
        FROM   ingredient_ref ir2
        WHERE  ir2.name_en = ir.name_en) AS new_id
FROM   ingredient_ref ir
WHERE  ir.ingredient_id != (
         SELECT MIN(ir2.ingredient_id)
         FROM   ingredient_ref ir2
         WHERE  ir2.name_en = ir.name_en
       );

-- 2a. Remap parent_ingredient_id refs to canonical (84 rows)
UPDATE product_ingredient pi
SET    parent_ingredient_id = dm.new_id
FROM   _dup_map dm
WHERE  pi.parent_ingredient_id = dm.old_id;

-- 2b. For product_ingredient rows pointing to non-canonical ingredient_id:
--     delete rows where the product already has the canonical ingredient
--     (avoids semantic duplicates). 3 known conflict rows.
DELETE FROM product_ingredient pi
USING  _dup_map dm
WHERE  pi.ingredient_id = dm.old_id
  AND  EXISTS (
         SELECT 1 FROM product_ingredient pi2
         WHERE  pi2.product_id = pi.product_id
           AND  pi2.ingredient_id = dm.new_id
       );

-- 2c. Remap remaining product_ingredient rows to canonical id
UPDATE product_ingredient pi
SET    ingredient_id = dm.new_id
FROM   _dup_map dm
WHERE  pi.ingredient_id = dm.old_id;

-- 2d. Delete the non-canonical ingredient_ref rows (72 rows)
DELETE FROM ingredient_ref
WHERE  ingredient_id IN (SELECT old_id FROM _dup_map);

DROP TABLE _dup_map;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 3: Drop unused columns from ingredient_ref
-- taxonomy_id, is_in_taxonomy, created_at — none queried anywhere.
-- Must drop the UNIQUE index on taxonomy_id first.
-- ─────────────────────────────────────────────────────────────────────────

ALTER TABLE ingredient_ref DROP CONSTRAINT IF EXISTS ingredient_ref_taxonomy_id_key;
ALTER TABLE ingredient_ref DROP COLUMN taxonomy_id;
ALTER TABLE ingredient_ref DROP COLUMN is_in_taxonomy;
ALTER TABLE ingredient_ref DROP COLUMN created_at;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 4: Zero out unverifiable Żabka additives_count and re-score
-- 14 products with additives_count > 0 but no ingredients_raw and zero
-- product_ingredient rows — the counts are unverifiable estimates.
-- ─────────────────────────────────────────────────────────────────────────

UPDATE ingredients i
SET    additives_count = 0
FROM   products p
WHERE  p.product_id = i.product_id
  AND  i.additives_count > 0
  AND  (i.ingredients_raw IS NULL OR i.ingredients_raw = '')
  AND  NOT EXISTS (
         SELECT 1 FROM product_ingredient pi WHERE pi.product_id = i.product_id
       );

-- Re-score those 14 products so unhealthiness_score reflects 0 additives
UPDATE scores sc
SET    unhealthiness_score = compute_unhealthiness_v32(
           nf.saturated_fat_g,
           nf.sugars_g,
           nf.salt_g,
           nf.calories,
           nf.trans_fat_g,
           0,  -- additives_count is now 0
           p.prep_method,
           p.controversies,
           sc.ingredient_concern_score
       ),
       high_additive_load = 'NO',
       scored_at       = CURRENT_DATE,
       scoring_version = 'v3.2'
FROM   products p
JOIN   servings sv  ON sv.product_id = p.product_id AND sv.serving_basis = 'per 100 g'
JOIN   nutrition_facts nf ON nf.product_id = p.product_id AND nf.serving_id = sv.serving_id
WHERE  p.product_id = sc.product_id
  AND  p.product_id IN (
         SELECT i2.product_id
         FROM   ingredients i2
         WHERE  i2.additives_count = 0
           AND  (i2.ingredients_raw IS NULL OR i2.ingredients_raw = '')
           AND  NOT EXISTS (
                  SELECT 1 FROM product_ingredient pi2 WHERE pi2.product_id = i2.product_id
                )
       );

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 5: Refresh materialised views
-- ─────────────────────────────────────────────────────────────────────────

REFRESH MATERIALIZED VIEW mv_ingredient_frequency;
REFRESH MATERIALIZED VIEW v_product_confidence;

-- ─────────────────────────────────────────────────────────────────────────
-- STEP 6: Verification
-- ─────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  v_ref_count     int;
  v_pi_count      int;
  v_col_count     int;
  v_dup_count     int;
  v_junk_count    int;
  v_bad_add_count int;
BEGIN
  SELECT count(*) INTO v_ref_count FROM ingredient_ref;
  SELECT count(*) INTO v_pi_count  FROM product_ingredient;

  SELECT count(*) INTO v_col_count
  FROM   information_schema.columns
  WHERE  table_name = 'ingredient_ref' AND table_schema = 'public';

  -- No duplicate name_en should remain
  SELECT count(*) INTO v_dup_count
  FROM   (SELECT name_en FROM ingredient_ref GROUP BY name_en HAVING count(*) > 1) x;

  -- No junk entries should remain
  SELECT count(*) INTO v_junk_count
  FROM   ingredient_ref
  WHERE  name_en IN ('and', 'l', '', 'f', 'ii', 'footnote')
     OR  name_en LIKE 'may contain%'
     OR  name_en LIKE 'and %'
     OR  name_en LIKE 'the product%'
     OR  name_en LIKE 'product may%'
     OR  name_en LIKE 'in total%'
     OR  name_en LIKE '%traces of%';

  -- No unverifiable additives_count should remain
  SELECT count(*) INTO v_bad_add_count
  FROM   ingredients i
  WHERE  i.additives_count > 0
    AND  (i.ingredients_raw IS NULL OR i.ingredients_raw = '')
    AND  NOT EXISTS (
           SELECT 1 FROM product_ingredient pi WHERE pi.product_id = i.product_id
         );

  RAISE NOTICE '── ingredient_ref cleanup verification ──';
  RAISE NOTICE 'ingredient_ref rows : % (expected ~1162)', v_ref_count;
  RAISE NOTICE 'product_ingredient  : % (expected ~7403)', v_pi_count;
  RAISE NOTICE 'ingredient_ref cols : % (expected 8)',      v_col_count;
  RAISE NOTICE 'duplicate name_en   : % (expected 0)',      v_dup_count;
  RAISE NOTICE 'junk entries left   : % (expected 0)',      v_junk_count;
  RAISE NOTICE 'bad additives_count : % (expected 0)',      v_bad_add_count;

  IF v_dup_count > 0 THEN
    RAISE EXCEPTION 'FAIL: % duplicate name_en groups remain', v_dup_count;
  END IF;
  IF v_junk_count > 0 THEN
    RAISE EXCEPTION 'FAIL: % junk entries remain', v_junk_count;
  END IF;
  IF v_bad_add_count > 0 THEN
    RAISE EXCEPTION 'FAIL: % unverifiable additives_count remain', v_bad_add_count;
  END IF;
END $$;

COMMIT;

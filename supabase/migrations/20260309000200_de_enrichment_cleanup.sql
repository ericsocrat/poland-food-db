-- DE Enrichment Cleanup
-- Fixes data quality issues from OFF API enrichment of DE categories:
--   1. Merge German Kakaobutter variants → existing Cocoa Butter (id 4063)
--   2. Rename OCR-garbage compound ingredient to Cocoa Mass
--   3. Rename HAFERspelzenfaser → Oat Husk Fiber
--   4. Delete junk ingredients: Kcal, Produced In A Factory Which Handles Milk
--   5. Normalize 22 German/French/garbage allergen tags → canonical English
--   6. Delete garbage allergen entries (en:none, en:isento-de-gluten, en:orange, en:en-eggs-en-peanuts)
--   7. Insert missing allergen declarations for cross-reference compliance
--
-- Rollback: re-run the enrichment pipeline for DE; no destructive schema changes.

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Merge Kakaobutter variants into existing Cocoa Butter (ingredient_id 4063)
-- ═══════════════════════════════════════════════════════════════════════════

-- Re-point product_ingredient rows from German variants → canonical Cocoa Butter
UPDATE product_ingredient
SET ingredient_id = 4063
WHERE ingredient_id IN (12892, 12893, 12894)                     -- Kakaobutter, Kakaobutter*", Kakaobutter¹
  AND NOT EXISTS (
    SELECT 1 FROM product_ingredient pi2
    WHERE pi2.product_id = product_ingredient.product_id
      AND pi2.ingredient_id = 4063
      AND pi2.position = product_ingredient.position
  );

-- Delete any remaining orphan references (if a product already had Cocoa Butter at same position)
DELETE FROM product_ingredient
WHERE ingredient_id IN (12892, 12893, 12894);

-- Remove the now-unused German ingredient_ref entries
DELETE FROM ingredient_ref
WHERE ingredient_id IN (12892, 12893, 12894);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Merge OCR-garbage compound ingredient into existing Cocoa Mass (id 4066)
-- ═══════════════════════════════════════════════════════════════════════════

-- Re-point product_ingredient rows from garbage compound → canonical Cocoa Mass
UPDATE product_ingredient
SET ingredient_id = 4066
WHERE ingredient_id = 12896                                      -- Kakaomasse*1 Zucker ■ Kakaobutter
  AND NOT EXISTS (
    SELECT 1 FROM product_ingredient pi2
    WHERE pi2.product_id = product_ingredient.product_id
      AND pi2.ingredient_id = 4066
      AND pi2.position = product_ingredient.position
  );

-- Delete any remaining orphan references
DELETE FROM product_ingredient
WHERE ingredient_id = 12896;

-- Remove the now-unused ingredient_ref entry
DELETE FROM ingredient_ref
WHERE ingredient_id = 12896;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Rename HAFERspelzenfaser → Oat Husk Fiber
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE ingredient_ref
SET name_en = 'Oat Husk Fiber'
WHERE ingredient_id = 12861
  AND name_en != 'Oat Husk Fiber';  -- idempotent guard

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Delete junk ingredients
-- ═══════════════════════════════════════════════════════════════════════════

-- 4a. Delete product_ingredient references first (FK constraint)
DELETE FROM product_ingredient
WHERE ingredient_id IN (
  12912,  -- Kcal
  5637    -- Produced In A Factory Which Handles Milk
);

-- 4b. Delete from ingredient_ref
DELETE FROM ingredient_ref
WHERE ingredient_id IN (
  12912,  -- Kcal
  5637    -- Produced In A Factory Which Handles Milk
);

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Normalize German/French allergen tags → canonical English
--    Strategy: INSERT canonical + DELETE old (handles duplicates safely)
-- ═══════════════════════════════════════════════════════════════════════════

-- 5a. Gluten group (German wheat/spelt/malt/cereal variants)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:gluten', type
FROM product_allergen_info
WHERE tag IN (
  'en:dinkelvollkornsauerteig',   -- spelt sourdough
  'en:dinkelweizenmalzflocken',   -- spelt-wheat malt flakes
  'en:malzextrakt',               -- malt extract
  'en:getreide'                   -- cereals (generic)
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN (
  'en:dinkelvollkornsauerteig',
  'en:dinkelweizenmalzflocken',
  'en:malzextrakt',
  'en:getreide'
);

-- 5b. Wheat (German wheat flour variants)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:wheat', type
FROM product_allergen_info
WHERE tag IN (
  'en:weizenart',              -- wheat type
  'en:weizenröstmalzmehl',     -- roasted wheat malt flour
  'en:weizenvollkommehl'       -- wheat wholemeal flour
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN (
  'en:weizenart',
  'en:weizenröstmalzmehl',
  'en:weizenvollkommehl'
);

-- 5c. Rye
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:rye', type
FROM product_allergen_info
WHERE tag = 'en:rogenvollkornmehl'    -- rye wholemeal flour
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag = 'en:rogenvollkornmehl';

-- 5d. Oats (German oat variants)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:oats', type
FROM product_allergen_info
WHERE tag IN (
  'en:haferkerne',              -- oat kernels
  'en:haferpflanzenfaser'       -- oat plant fiber
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN (
  'en:haferkerne',
  'en:haferpflanzenfaser'
);

-- 5e. Lupin
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:lupin', type
FROM product_allergen_info
WHERE tag = 'en:lupinen'              -- German for lupin
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag = 'en:lupinen';

-- 5f. Soybeans (OCR/typo variants)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:soybeans', type
FROM product_allergen_info
WHERE tag IN (
  'en:s0ja',                    -- OCR error (zero instead of O)
  'en:sonja'                    -- German typo for Soja
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN ('en:s0ja', 'en:sonja');

-- 5g. Eggs (German hen egg white)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:eggs', type
FROM product_allergen_info
WHERE tag = 'en:hünerei-eiweiß'       -- hen egg white
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag = 'en:hünerei-eiweiß';

-- 5h. Nuts (German/French tree nut declarations)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:nuts', type
FROM product_allergen_info
WHERE tag IN (
  'en:schalenfrüchte-keine-erdnüsse',  -- tree nuts excl. peanuts
  'en:fruits-à-coque'                   -- French: tree nuts
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN (
  'en:schalenfrüchte-keine-erdnüsse',
  'en:fruits-à-coque'
);

-- 5i. Sesame (typos and double-prefix)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:sesame-seeds', type
FROM product_allergen_info
WHERE tag IN (
  'en:seasam',                  -- typo
  'en:en-sesame-seeds'          -- double en: prefix
)
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag IN ('en:seasam', 'en:en-sesame-seeds');

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Delete garbage allergen entries
-- ═══════════════════════════════════════════════════════════════════════════

-- en:none — not an allergen
DELETE FROM product_allergen_info WHERE tag = 'en:none';

-- en:isento-de-gluten — Portuguese for "gluten-free", not an allergen
DELETE FROM product_allergen_info WHERE tag = 'en:isento-de-gluten';

-- en:orange — not an EU-14 allergen
DELETE FROM product_allergen_info WHERE tag = 'en:orange';

-- en:en-eggs-en-peanuts — malformed compound tag
-- Product 1362 already has separate en:eggs + en:peanuts as traces
DELETE FROM product_allergen_info WHERE tag = 'en:en-eggs-en-peanuts';

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Insert missing allergen declarations (cross-reference compliance)
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 1176 (Eiweißbrot): has Soja ingredient, soybeans only as traces → add contains
INSERT INTO product_allergen_info (product_id, tag, type)
VALUES (1176, 'en:soybeans', 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Product 1639 (Grießpudding High-Protein): has Soja ingredient, soybeans only as traces → add contains
INSERT INTO product_allergen_info (product_id, tag, type)
VALUES (1639, 'en:soybeans', 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Product 1687 (Barista Oat Drink): has Oats ingredient, no allergen declarations at all → add gluten
INSERT INTO product_allergen_info (product_id, tag, type)
VALUES (1687, 'en:gluten', 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Products 1178, 1197 (Haferbrot): have Haferflocken ingredient, missing en:gluten declaration
INSERT INTO product_allergen_info (product_id, tag, type)
VALUES (1178, 'en:gluten', 'contains'),
       (1197, 'en:gluten', 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Re-score affected DE categories + refresh materialized views
-- ═══════════════════════════════════════════════════════════════════════════

CALL score_category('Bread', 100, 'DE');
CALL score_category('Dairy', 100, 'DE');
CALL score_category('Drinks', 100, 'DE');
CALL score_category('Sweets', 100, 'DE');

SELECT refresh_all_materialized_views();

COMMIT;

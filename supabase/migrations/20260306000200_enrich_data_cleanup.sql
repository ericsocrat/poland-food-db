-- ══════════════════════════════════════════════════════════════════════════════
-- Post-enrichment data cleanup
-- Fixes: duplicate ingredient_ref entries, duplicate product_ingredient rows,
--         junk ingredient names, non-standard allergen tags.
-- Rollback: restore from backup; data-only changes, no DDL beyond UNIQUE index.
-- ══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 1: Deduplicate ingredient_ref (same name_en → keep min ingredient_id)
-- Since both the original and duplicate row exist in product_ingredient,
-- we DELETE rows referencing the higher (duplicate) ID, then delete the
-- duplicate ingredient_ref entry.
-- ────────────────────────────────────────────────────────────────────────────

-- 1a. Identify duplicate ingredient_ids to remove (keep the lowest per name_en)
CREATE TEMP TABLE _ingredient_dupes AS
SELECT ingredient_id AS dup_id
FROM ingredient_ref ir
WHERE EXISTS (
    SELECT 1 FROM ingredient_ref keeper
    WHERE keeper.name_en = ir.name_en
      AND keeper.ingredient_id < ir.ingredient_id
);

-- 1b. Delete product_ingredient rows referencing the duplicate IDs
DELETE FROM product_ingredient
WHERE ingredient_id IN (SELECT dup_id FROM _ingredient_dupes);

-- 1c. Delete the duplicate ingredient_ref entries
DELETE FROM ingredient_ref
WHERE ingredient_id IN (SELECT dup_id FROM _ingredient_dupes);

DROP TABLE _ingredient_dupes;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 2: Clean junk ingredient names (symbols, Cyrillic, non-Latin only)
-- ────────────────────────────────────────────────────────────────────────────

-- Delete product_ingredient rows pointing to junk ingredients
DELETE FROM product_ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id FROM ingredient_ref
    WHERE name_en ~ '^[^a-zA-Z]*$'           -- no Latin letters at all (%, +, ¹⁾)
       OR name_en ~ '^[\u0400-\u04FF\s]+$'   -- purely Cyrillic
       OR name_en ~ '^[\u0E00-\u0E7F\s]+$'   -- purely Thai
       OR LENGTH(TRIM(name_en)) < 2           -- too short
);

-- Delete the junk ingredient_ref entries themselves
DELETE FROM ingredient_ref
WHERE name_en ~ '^[^a-zA-Z]*$'
   OR name_en ~ '^[\u0400-\u04FF\s]+$'
   OR name_en ~ '^[\u0E00-\u0E7F\s]+$'
   OR LENGTH(TRIM(name_en)) < 2;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 3: Normalize non-standard allergen tags to EU standard codes
-- ────────────────────────────────────────────────────────────────────────────

-- 3a. Allergen tag normalization mapping
CREATE TEMP TABLE _allergen_map (old_tag text PRIMARY KEY, new_tag text NOT NULL);
INSERT INTO _allergen_map (old_tag, new_tag) VALUES
    -- Milk / lactose variants
    ('en:laktoza',        'en:milk'),
    ('en:laktose',        'en:milk'),
    ('en:milch',          'en:milk'),
    ('en:milcheiweiss',   'en:milk'),
    ('en:pochodne-mleka', 'en:milk'),
    ('en:edamski',        'en:milk'),
    -- Gluten / wheat / grain variants
    ('en:gliten',         'en:gluten'),
    ('en:pszenna',        'en:wheat'),
    ('en:pszenny',        'en:wheat'),
    ('en:pszeniczny',     'en:wheat'),
    ('en:pszennego',      'en:wheat'),
    ('en:weizen',         'en:wheat'),
    ('en:weizenstarke',   'en:wheat'),
    ('en:żytnia',         'en:rye'),
    ('en:zboża',          'en:gluten'),
    ('en:zboże',          'en:gluten'),
    ('en:jeczmienne',     'en:barley'),
    ('en:jęczmienny',     'en:barley'),
    ('en:mąka-owsiana',   'en:oats'),
    ('en:owsa',           'en:oats'),
    ('en:owsiana',        'en:oats'),
    ('en:owsiany',        'en:oats'),
    -- Soy
    ('en:sojowego',       'en:soybeans'),
    ('en:en-soybeans',    'en:soybeans'),
    -- Nuts / tree nuts
    ('en:migdałów',       'en:almonds'),
    ('en:laskowe',        'en:hazelnuts'),
    ('en:orzeszki-laskowe','en:hazelnuts'),
    ('en:orzechów-pekan', 'en:pecan-nuts'),
    ('en:łupiny-orzechów','en:nuts'),
    -- Fish
    ('en:tunczyk',        'en:fish'),
    -- Eggs
    ('en:fenyloalaniny',  'en:eggs'),
    -- Sulphites
    ('en:pirosiarczyn',   'en:sulphur-dioxide-and-sulphites'),
    -- Grain (generic)
    ('en:grain',          'en:gluten');

-- 3b. Delete ALL non-standard rows that would conflict with an existing standard tag
--     OR with another non-standard row mapping to the same target
DELETE FROM product_allergen_info pai
USING _allergen_map m
WHERE pai.tag = m.old_tag
  AND (
      -- Case 1: standard tag already exists for this product+type
      EXISTS (
          SELECT 1 FROM product_allergen_info existing
          WHERE existing.product_id = pai.product_id
            AND existing.tag = m.new_tag
            AND existing.type = pai.type
      )
      OR
      -- Case 2: another non-standard row for the same product+type maps to the same target
      --         and has a "lower" old_tag (keep one, delete the rest)
      EXISTS (
          SELECT 1 FROM product_allergen_info other
          JOIN _allergen_map om ON om.old_tag = other.tag
          WHERE other.product_id = pai.product_id
            AND other.type = pai.type
            AND om.new_tag = m.new_tag
            AND other.tag < pai.tag  -- lexicographic tie-break: keep the "lower" tag
      )
  );

-- 3c. Update the remaining rows to standard tags
UPDATE product_allergen_info pai
SET tag = m.new_tag
FROM _allergen_map m
WHERE pai.tag = m.old_tag;

-- 3d. Delete truly unrecognizable allergen tags (no mapping possible)
DELETE FROM product_allergen_info
WHERE tag IN (
    'en:none', 'en:brak',                                              -- "none" in Polish/English
    'en:cukier', 'en:sok',                                             -- not allergens (sugar, juice)
    'en:s',                                                            -- garbled
    'en:en-eggs-en-nuts-en-peanuts-en-sesame-seeds-en-soybeans',       -- malformed compound tag
    'en:produkty-pochodne',                                            -- "derivatives" (too vague)
    'en:produkt-może-zwierać-fragmenty-lub-całe-pestki',               -- legal disclaimer, not allergen
    'en:pestki-owoców',                                                -- "fruit pits" (not a standard allergen)
    'en:pork',                                                         -- not an EU allergen
    'en:kiwi',                                                         -- not a standard EU allergen tag
    'en:peach'                                                         -- not a standard EU allergen tag
);

-- Delete tags with non-Latin scripts (Thai, etc.)
DELETE FROM product_allergen_info
WHERE tag ~ '[\u0E00-\u0E7F]'     -- Thai
   OR tag ~ '[\u0400-\u04FF]';    -- Cyrillic

DROP TABLE _allergen_map;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 4: Backfill missing allergen declarations inferred from ingredients
-- ────────────────────────────────────────────────────────────────────────────

-- Products with milk/egg/fish/gluten/soy ingredients but missing allergen tags.
-- Cross-referenced by QA__allergen_integrity.sql checks 9-14.
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%'])
  AND NOT (ir.name_en ILIKE ANY(ARRAY[
    '%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%',
    '%coconut milk%','%coconut cream%','%almond milk%','%oat milk%',
    '%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%',
    '%ice cream plant%','%buttercup%','%lactic acid%','%cream soda%',
    '%factory%handles%','%produced%facility%'
  ]))
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:milk' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:eggs', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
  AND NOT (ir.name_en ILIKE ANY(ARRAY['%eggplant%','%reggiano%','%egg noodle%']))
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:eggs' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%wheat%','%barley%','%rye%','%spelt%'])
  AND ir.name_en NOT ILIKE '%buckwheat%'
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:gluten' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:soybeans', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:soybeans' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:fish', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%fish%','%salmon%','%tuna%','%herring%','%mackerel%','%anchov%','%cod %','%trout%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:fish' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 5: Add UNIQUE constraint on ingredient_ref.name_en (prevent future duplication)
-- ────────────────────────────────────────────────────────────────────────────

DROP INDEX IF EXISTS idx_ingredient_ref_name;
CREATE UNIQUE INDEX IF NOT EXISTS idx_ingredient_ref_name_en_uniq
    ON ingredient_ref (name_en);

COMMIT;

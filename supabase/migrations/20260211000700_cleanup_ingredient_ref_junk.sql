-- Comprehensive ingredient_ref cleanup (pattern-based, ID-independent)
-- Removes junk entries created by OFF parser artifacts

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════
-- A. DELETE pure junk entries using name patterns
--    First detach parent references, then delete product_ingredient rows,
--    then delete ingredient_ref entries.
-- ═══════════════════════════════════════════════════════════════════════════

-- A0. Collect IDs of all junk entries into a temp table
CREATE TEMP TABLE junk_ids AS
SELECT ingredient_id FROM ingredient_ref
WHERE
    -- Empty / single-char / two-char entries
    length(trim(name_en)) <= 2
    -- Bare numbers, percentages, nutritional info
    OR name_en ~* '^\d+\s*(kcal|kj|g\s|per cent|beans|farming)'
    OR name_en ~* '^\d+\s*$'
    OR name_en ~* '^per 100'
    OR name_en IN ('161', 'minimum', 'product', '23 beans', '5 per cent')
    -- Polish/Czech/French label text, barcodes
    OR name_en ~* '^\d{5,}'              -- barcode fragments
    OR name_en ~* 'kcal|kj\b'           -- nutritional values
    OR name_en ~* 'porcj[eę]|sugerowanych' -- Polish serving text
    OR name_en ~* 'indeks da produktu|purella' -- Polish product labels
    OR name_en ~* 'nahrwertangaben'       -- German nutrition label
    OR name_en ~* 'vztiahnute|obsahzložky' -- Czech label text
    OR name_en ~* 'urella'               -- brand fragment
    -- Packaging / atmosphere notices
    OR name_en ~* 'atmosph[eè]re|protectrice|conditionn'
    OR name_en ~* 'pasteurized product'
    -- Sentence fragments and qualifiers
    OR name_en ~* '^from \d+'
    OR name_en IN (
        'from 26 farming', 'from mik flaxseed',
        'in the alpine milk chocolate', 'in raspberry filling',
        'in cocoa coating', 'in chocolate',
        'the filling with the cocoa powder',
        'the cocoa filling contains 7 low fat cocoa powder',
        'tomatoes used per 100 g of product',
        'milk chocolate contains vegetable fats in addition to cocoa fat',
        '1 concentrated raspberry juice in the filling',
        '6 refer to the content components in the entire product',
        'in variable proportions',
        'obtained from controlled oil palm plantations',
        'that do not threaten tropical forests and their inhabitants',
        'salt compared to the average content of salted pistachios on the market',
        'contains naturally occurring sugars',
        'contains milk proteins including lactose',
        'including chicken breast meat',
        'may additionally contain',
        'may contain other nuts',
        'may also contain other gluten-containing cereals',
        'in total product produc contain traces of',
        'from concentrated orange juice',
        'from carrots 25 vitamin c'
    )
    -- Entries that look like packaging disclaimers
    OR name_en ~* 'skimmed milk powder was packed'
    OR name_en ~* 'filling contains \d'
;

-- A1. Detach parent references
UPDATE product_ingredient
SET parent_ingredient_id = NULL, is_sub_ingredient = false
WHERE parent_ingredient_id IN (SELECT ingredient_id FROM junk_ids);

-- A2. Delete product_ingredient rows
DELETE FROM product_ingredient
WHERE ingredient_id IN (SELECT ingredient_id FROM junk_ids);

-- A3. Delete ingredient_ref entries
DELETE FROM ingredient_ref
WHERE ingredient_id IN (SELECT ingredient_id FROM junk_ids);

DROP TABLE junk_ids;

-- ═══════════════════════════════════════════════════════════════════════════
-- B. MERGE duplicates / rename salvageable entries
-- ═══════════════════════════════════════════════════════════════════════════

-- B1. 'from soya' → merge to 'soya' if exists, else rename
DO $$
DECLARE t_id int; s_id int;
BEGIN
    SELECT ingredient_id INTO s_id FROM ingredient_ref WHERE name_en = 'from soya' LIMIT 1;
    IF s_id IS NOT NULL THEN
        SELECT ingredient_id INTO t_id FROM ingredient_ref WHERE name_en = 'soya' AND ingredient_id != s_id LIMIT 1;
        IF t_id IS NOT NULL THEN
            UPDATE product_ingredient SET parent_ingredient_id = t_id WHERE parent_ingredient_id = s_id;
            UPDATE product_ingredient SET ingredient_id = t_id WHERE ingredient_id = s_id;
            DELETE FROM ingredient_ref WHERE ingredient_id = s_id;
            RAISE NOTICE 'Merged from soya → soya (id=%)', t_id;
        ELSE
            UPDATE ingredient_ref SET name_en = 'soya' WHERE ingredient_id = s_id;
            RAISE NOTICE 'Renamed from soya → soya';
        END IF;
    END IF;
END $$;

-- B2. 'freeze dried fruits 2 5 in variable proportions' → 'freeze-dried fruit'
DO $$
DECLARE t_id int; s_id int;
BEGIN
    SELECT ingredient_id INTO s_id FROM ingredient_ref WHERE name_en LIKE 'freeze dried fruits%variable%' LIMIT 1;
    IF s_id IS NOT NULL THEN
        SELECT ingredient_id INTO t_id FROM ingredient_ref WHERE name_en IN ('freeze-dried fruit', 'freeze dried fruit') AND ingredient_id != s_id LIMIT 1;
        IF t_id IS NOT NULL THEN
            UPDATE product_ingredient SET parent_ingredient_id = t_id WHERE parent_ingredient_id = s_id;
            UPDATE product_ingredient SET ingredient_id = t_id WHERE ingredient_id = s_id;
            DELETE FROM ingredient_ref WHERE ingredient_id = s_id;
        ELSE
            UPDATE ingredient_ref SET name_en = 'freeze-dried fruit' WHERE ingredient_id = s_id;
        END IF;
    END IF;
END $$;

-- B3. 'high-oleic in variable proportions' → 'high-oleic sunflower oil' if it has 0 usages
DO $$
DECLARE s_id int; cnt int;
BEGIN
    SELECT ingredient_id INTO s_id FROM ingredient_ref WHERE name_en = 'high-oleic in variable proportions' LIMIT 1;
    IF s_id IS NOT NULL THEN
        SELECT COUNT(*) INTO cnt FROM product_ingredient WHERE ingredient_id = s_id;
        IF cnt = 0 THEN
            DELETE FROM ingredient_ref WHERE ingredient_id = s_id;
        ELSE
            UPDATE ingredient_ref SET name_en = 'high-oleic sunflower oil' WHERE ingredient_id = s_id;
        END IF;
    END IF;
END $$;

-- B4. '5 rybonukleotydy sodowe' → merge to 'e635' (disodium 5'-ribonucleotides)
DO $$
DECLARE t_id int; s_id int;
BEGIN
    SELECT ingredient_id INTO s_id FROM ingredient_ref WHERE name_en = '5 rybonukleotydy sodowe' LIMIT 1;
    IF s_id IS NOT NULL THEN
        SELECT ingredient_id INTO t_id FROM ingredient_ref WHERE name_en = 'e635' LIMIT 1;
        IF t_id IS NOT NULL THEN
            UPDATE product_ingredient SET parent_ingredient_id = t_id WHERE parent_ingredient_id = s_id;
            UPDATE product_ingredient SET ingredient_id = t_id WHERE ingredient_id = s_id;
            DELETE FROM ingredient_ref WHERE ingredient_id = s_id;
            RAISE NOTICE 'Merged 5 rybonukleotydy sodowe → e635';
        ELSE
            UPDATE ingredient_ref SET name_en = 'e635', is_additive = true WHERE ingredient_id = s_id;
        END IF;
    END IF;
END $$;

-- B5. 'milk proteins including lactose' → remove if unused
DO $$
DECLARE s_id int; cnt int;
BEGIN
    SELECT ingredient_id INTO s_id FROM ingredient_ref WHERE name_en = 'milk proteins including lactose' LIMIT 1;
    IF s_id IS NOT NULL THEN
        SELECT COUNT(*) INTO cnt FROM product_ingredient WHERE ingredient_id = s_id;
        IF cnt = 0 THEN
            DELETE FROM ingredient_ref WHERE ingredient_id = s_id;
        END IF;
    END IF;
END $$;

-- B6. 'product derived from cereals' → 'cereal products'
UPDATE ingredient_ref SET name_en = 'cereal products'
WHERE name_en = 'product derived from cereals';


-- ═══════════════════════════════════════════════════════════════════════════
-- C. Dedup product_ingredient after merges (only affected ingredient_ids)
-- ═══════════════════════════════════════════════════════════════════════════

-- Get merge-target ingredient_ids
DELETE FROM product_ingredient pi
WHERE pi.ingredient_id IN (
    SELECT ingredient_id FROM ingredient_ref
    WHERE name_en IN ('soya', 'freeze-dried fruit', 'e635')
)
AND EXISTS (
    SELECT 1 FROM product_ingredient pi2
    WHERE pi2.product_id = pi.product_id
      AND pi2.ingredient_id = pi.ingredient_id
      AND pi2.position < pi.position
);


-- ═══════════════════════════════════════════════════════════════════════════
-- D. Clean up orphaned ingredient_ref entries (0 usages)
--    Only remove entries that match junk-like patterns
-- ═══════════════════════════════════════════════════════════════════════════

DELETE FROM ingredient_ref ir
WHERE NOT EXISTS (SELECT 1 FROM product_ingredient pi WHERE pi.ingredient_id = ir.ingredient_id)
  AND (
    length(trim(name_en)) <= 2
    OR name_en ~* '^\d'
    OR name_en ~* 'variable proportions'
    OR name_en ~* 'milk proteins including'
  );


-- ═══════════════════════════════════════════════════════════════════════════
-- E. Verification
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
    ref_count int;
    pi_count int;
    orphan_count int;
    junk_remain int;
BEGIN
    SELECT COUNT(*) INTO ref_count FROM ingredient_ref;
    SELECT COUNT(*) INTO pi_count FROM product_ingredient;

    SELECT COUNT(*) INTO orphan_count FROM product_ingredient pi
    LEFT JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.ingredient_id IS NULL;

    IF orphan_count > 0 THEN
        RAISE EXCEPTION '% orphaned product_ingredient rows found', orphan_count;
    END IF;

    -- Check for remaining obvious junk
    SELECT COUNT(*) INTO junk_remain FROM ingredient_ref
    WHERE length(trim(name_en)) <= 1
       OR name_en ~* '^\d+\s*(kcal|kj)'
       OR name_en ~* 'nahrwertangaben|urella';

    IF junk_remain > 0 THEN
        RAISE NOTICE 'WARNING: % entries still look like junk, manual review may be needed', junk_remain;
    END IF;

    RAISE NOTICE '✓ ingredient_ref: % rows', ref_count;
    RAISE NOTICE '✓ product_ingredient: % rows', pi_count;
    RAISE NOTICE '✓ 0 orphaned junction rows';
END $$;

-- Refresh materialized views
REFRESH MATERIALIZED VIEW v_product_confidence;

COMMIT;

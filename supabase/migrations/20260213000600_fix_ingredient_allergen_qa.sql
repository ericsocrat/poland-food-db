-- Fix ingredient & allergen QA failures after initial enrichment
-- Addresses: Suite 1 (orphan refs), Suite 2 (additive scoring), Suite 7 (score drift),
--            Suite 13 (allergen tags), Suite 15 (ingredient quality)

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- Step 1: Delete junk ingredient_ref entries (QA Suite 15, check 2)
-- ═══════════════════════════════════════════════════════════════

DELETE FROM product_ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id FROM ingredient_ref
    WHERE name_en ~ '^\d+$'
       OR length(trim(name_en)) <= 1
       OR name_en ~* '^(per 100|kcal|kj\b)'
);

DELETE FROM ingredient_ref
WHERE name_en ~ '^\d+$'
   OR length(trim(name_en)) <= 1
   OR name_en ~* '^(per 100|kcal|kj\b)';

-- ═══════════════════════════════════════════════════════════════
-- Step 2: Fix is_additive flag — only e-number names are true additives
--         (QA Suite 15, check 13)
-- ═══════════════════════════════════════════════════════════════

UPDATE ingredient_ref
SET is_additive = false
WHERE is_additive = true
  AND name_en !~* '^e\d';

-- Normalize uppercase E-number names to lowercase (e.g. E330 → e330)
UPDATE ingredient_ref
SET name_en = lower(name_en)
WHERE is_additive = true
  AND name_en ~ '^E\d';

-- ═══════════════════════════════════════════════════════════════
-- Step 3: Delete orphan ingredient_ref entries (QA Suite 1, check 23)
-- ═══════════════════════════════════════════════════════════════

DELETE FROM ingredient_ref ir
WHERE NOT EXISTS (
    SELECT 1 FROM product_ingredient pi
    WHERE pi.ingredient_id = ir.ingredient_id
);

-- ═══════════════════════════════════════════════════════════════
-- Step 4: Normalize allergen/trace tags (QA Suite 13, checks 1-4)
-- ═══════════════════════════════════════════════════════════════

-- 4a. Insert canonical en:-prefixed rows for all mappable tags, then delete originals
-- This avoids PK violations from UPDATE when en: row already exists

-- Create temp mapping table
CREATE TEMP TABLE tag_map (old_tag text, new_tag text);
INSERT INTO tag_map (old_tag, new_tag) VALUES
    -- EU-14 tags that just need en: prefix
    ('gluten', 'en:gluten'), ('milk', 'en:milk'), ('soybeans', 'en:soybeans'),
    ('nuts', 'en:nuts'), ('eggs', 'en:eggs'), ('peanuts', 'en:peanuts'),
    ('fish', 'en:fish'), ('celery', 'en:celery'), ('mustard', 'en:mustard'),
    ('sesame-seeds', 'en:sesame-seeds'),
    ('sulphur-dioxide-and-sulphites', 'en:sulphur-dioxide-and-sulphites'),
    ('crustaceans', 'en:crustaceans'), ('lupin', 'en:lupin'),
    ('molluscs', 'en:molluscs'), ('kiwi', 'en:kiwi'), ('pork', 'en:pork'),
    ('peach', 'en:peach'), ('none', 'en:none'),
    -- Polish/locale mappings
    ('laktoza', 'en:milk'), ('edamski', 'en:milk'), ('pochodne-mleka', 'en:milk'),
    ('pszennego', 'en:gluten'), ('pszenna', 'en:gluten'), ('pszeniczny', 'en:gluten'),
    ('pszenny', 'en:gluten'), ('mąka-owsiana', 'en:gluten'), ('owsiana', 'en:gluten'),
    ('owsiany', 'en:gluten'), ('owsa', 'en:gluten'), ('jeczmienne', 'en:gluten'),
    ('jęczmienny', 'en:gluten'), ('żytnia', 'en:gluten'), ('zboża', 'en:gluten'),
    ('zboże', 'en:gluten'), ('grain', 'en:gluten'), ('gliten', 'en:gluten'),
    ('sojowego', 'en:soybeans'),
    ('migdałów', 'en:nuts'), ('laskowe', 'en:nuts'), ('orzechów-pekan', 'en:nuts'),
    ('łupiny-orzechów', 'en:nuts'), ('orzeszki-laskowe', 'en:nuts'),
    ('pirosiarczyn', 'en:sulphur-dioxide-and-sulphites'),
    ('tunczyk', 'en:fish'),
    ('brak', 'en:none'),
    -- Composite tag (will be handled separately)
    ('en-eggs-en-nuts-en-peanuts-en-sesame-seeds-en-soybeans', NULL);

-- Insert canonical rows (skip composite which is NULL)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pai.product_id, tm.new_tag, pai.type
FROM product_allergen_info pai
JOIN tag_map tm ON tm.old_tag = pai.tag
WHERE tm.new_tag IS NOT NULL
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Handle composite tag — split into individual entries
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, unnest(ARRAY['en:eggs','en:nuts','en:peanuts','en:sesame-seeds','en:soybeans']), type
FROM product_allergen_info
WHERE tag = 'en-eggs-en-nuts-en-peanuts-en-sesame-seeds-en-soybeans'
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Delete all non-en: tags (originals + unmappable junk)
DELETE FROM product_allergen_info
WHERE tag NOT LIKE 'en:%';

DROP TABLE tag_map;

-- ═══════════════════════════════════════════════════════════════
-- Step 5: Insert missing allergen declarations from ingredients
--         (QA Suite 13, checks 9-14)
-- ═══════════════════════════════════════════════════════════════

-- 5a. Milk ingredients → en:milk
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%','%mleko%','%masło%','%ser %','%śmietana%','%jogurt%'])
  AND ir.name_en NOT ILIKE ANY(ARRAY['%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%','%coconut milk%','%coconut cream%','%almond milk%','%oat milk%','%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%','%buttercup%','%masło kakaowe%','%mleko kokosowe%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:milk' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- 5b. Gluten ingredients → en:gluten
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%wheat%','%barley%','%rye%','%spelt%','%oat%','%pszenica%','%żyto%','%jęczmień%','%owies%','%orkisz%'])
  AND ir.name_en NOT ILIKE ANY(ARRAY['%buckwheat%','%gryka%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:gluten' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- 5c. Egg ingredients → en:eggs
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:eggs', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%egg%','%jaj%'])
  AND ir.name_en NOT ILIKE ANY(ARRAY['%eggplant%','%reggiano%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:eggs' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- 5d. Soy ingredients → en:soybeans
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

-- 5e. Peanut ingredients → en:peanuts
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:peanuts', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%peanut%','%arachid%','%orzech ziemn%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:peanuts' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- 5f. Fish ingredients → en:fish
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:fish', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%fish%','%salmon%','%tuna%','%herring%','%mackerel%','%anchov%','%cod %','%trout%','%ryba%','%łosoś%','%tuńczyk%','%śledź%','%dorsz%','%pstrąg%'])
  AND NOT EXISTS (
    SELECT 1 FROM product_allergen_info pai
    WHERE pai.product_id = pi.product_id AND pai.tag = 'en:fish' AND pai.type = 'contains'
  )
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- Step 6: Recalculate high_additive_load flag (QA Suite 2)
-- ═══════════════════════════════════════════════════════════════

-- Products WITH ingredients: recalculate from actual additive count
UPDATE products p
SET high_additive_load = CASE
    WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES'
    ELSE 'NO'
END
FROM (
    SELECT pi.product_id,
           COUNT(*) FILTER (WHERE ir.is_additive) AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia
WHERE ia.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- Products WITHOUT ingredients: keep existing flag
-- (no change needed)

-- ═══════════════════════════════════════════════════════════════
-- Step 7: Re-score products to sync unhealthiness_score (QA Suite 7)
-- ═══════════════════════════════════════════════════════════════

UPDATE products p
SET unhealthiness_score = (
    explain_score_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g,
        COALESCE(ia.additives_count, 0)::numeric,
        p.prep_method, p.controversies, p.ingredient_concern_score
    )->>'final_score'
)::int
FROM nutrition_facts nf
LEFT JOIN LATERAL (
    SELECT COUNT(*) FILTER (WHERE ir.is_additive) AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE pi.product_id = nf.product_id
) ia ON true
WHERE nf.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- ═══════════════════════════════════════════════════════════════
-- Step 8: Refresh materialized views
-- ═══════════════════════════════════════════════════════════════

SELECT refresh_all_materialized_views();

COMMIT;

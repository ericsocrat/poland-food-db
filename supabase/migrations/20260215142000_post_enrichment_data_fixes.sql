-- ═══════════════════════════════════════════════════════════════════════════
-- Post-enrichment data fixes
-- ═══════════════════════════════════════════════════════════════════════════
-- PURPOSE: Clean up and normalize data from the OFF API ingredient/allergen
--          enrichment (20260215141000_populate_ingredients_allergens.sql).
--
-- Fixes applied:
--   1. EFSA concern tier classification for new additives (by E-number and
--      natural language names in EN/PL/DE)
--   2. Concern reason text for all tier 1-3 ingredients
--   3. Allergen tag normalization (Polish/German/Thai → EU-14 standard)
--   4. Allergen cross-validation (auto-declare from ingredient signals)
--   5. Junk ingredient cleanup (parser artifacts from OFF API)
--   6. Score recalculation (ingredient_concern_score, unhealthiness_score,
--      high_additive_load, data_completeness_pct, confidence)
--
-- Safe to run multiple times (fully idempotent).
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─── 1. EFSA concern tier classification ─────────────────────────────────
-- E-number format (case-insensitive)

-- Tier 1 — low concern
UPDATE ingredient_ref SET concern_tier = 1
WHERE concern_tier = 0 AND LOWER(name_en) IN (
    'e150','e172','e200','e202','e281','e282','e338','e339','e340','e341',
    'e407a','e420','e425','e445','e450','e450i','e451','e451i','e452','e452i',
    'e461','e471','e472b','e472e','e475','e476','e481','e482','e492',
    'e627','e631','e635','e920','e960','e960a','e965','e1420'
);

-- Tier 2 — moderate concern
UPDATE ingredient_ref SET concern_tier = 2
WHERE concern_tier = 0 AND LOWER(name_en) IN (
    'e133','e150d','e211','e220','e223','e319','e385','e407','e466',
    'e621','e950','e951','e954','e955'
);

-- Tier 3 — high concern
UPDATE ingredient_ref SET concern_tier = 3
WHERE concern_tier = 0 AND LOWER(name_en) IN ('e250','e252');

-- Natural language names (EN/PL/DE)

-- Tier 1 — natural language
UPDATE ingredient_ref SET concern_tier = 1
WHERE concern_tier = 0 AND is_additive = true AND LOWER(name_en) IN (
    'sorbic acid','potassium sorbate','sodium propionate','calcium propionate',
    'phosphoric acid','sodium phosphates','potassium phosphates','calcium phosphates',
    'sorbitol','konjac','diphosphates','triphosphates','polyphosphates',
    'methylcellulose','mono- and diglycerides of fatty acids',
    'polyglycerol esters of fatty acids','pgpr','polyglycerol polyricinoleate',
    'sodium stearoyl-2-lactylate','calcium stearoyl-2-lactylate',
    'sorbitan tristearate','disodium guanylate','disodium inosinate',
    'l-cysteine','steviol glycosides','maltitol','acetylated starch',
    'caramel color','iron oxides','datem',
    'mono- and diglycerides','disodium 5''-ribonucleotides',
    'glycerol esters of wood rosin','processed eucheuma seaweed',
    'kwas sorbowy','sorbinian potasu','maltitol syrup',
    'disodium diphosphate','pentasodium triphosphate','sodium polyphosphate'
);

-- Tier 2 — natural language
UPDATE ingredient_ref SET concern_tier = 2
WHERE concern_tier = 0 AND is_additive = true AND LOWER(name_en) IN (
    'brilliant blue fcf','sodium benzoate','sulphur dioxide','sodium metabisulphite',
    'tbhq','tert-butylhydroquinone','calcium disodium edta','carrageenan',
    'carboxymethyl cellulose','monosodium glutamate','msg',
    'acesulfame k','acesulfame potassium','aspartame','saccharin','sucralose',
    'sulphite ammonia caramel','glutaminian sodu','acesulfam k',
    'sodium metabisulfite','sodium sulfite','carrageenan gum',
    'aspartam','sacharyna','sukraloza','benzoesan sodu',
    'ditlenek siarki','metabisiarczan sodu','edta wapniowo-disodowy'
);

-- Tier 3 — natural language
UPDATE ingredient_ref SET concern_tier = 3
WHERE concern_tier = 0 AND is_additive = true AND LOWER(name_en) IN (
    'sodium nitrite','potassium nitrate','azotan potasu','azotyn sodu',
    'potassium nitrite','sodium nitrate'
);

-- ─── 2. Concern reason text ─────────────────────────────────────────────

UPDATE ingredient_ref SET concern_reason = 'EFSA-recognized food additive with generally safe profile'
WHERE concern_tier = 1 AND concern_reason IS NULL;

UPDATE ingredient_ref SET concern_reason = 'EFSA-monitored additive with reduced ADI or ongoing evaluation'
WHERE concern_tier = 2 AND concern_reason IS NULL;

UPDATE ingredient_ref SET concern_reason = 'IARC Group 2A carcinogen pathway (nitrosamine formation)'
WHERE concern_tier = 3 AND concern_reason IS NULL;

-- ─── 3. Allergen tag normalization ──────────────────────────────────────
-- Polish/German/Thai variants → EU-14 standard tags

-- Milk derivatives
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:milk', type
FROM product_allergen_info
WHERE tag IN ('en:laktoza','en:laktose','en:milch','en:milcheiweiss','en:edamski','en:pochodne-mleka')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Soybeans
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:soybeans', type
FROM product_allergen_info
WHERE tag IN ('en:sojowego','en:en-soybeans')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Gluten (wheat, barley, oats, rye, grain)
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:gluten', type
FROM product_allergen_info
WHERE tag IN ('en:pszennego','en:pszenna','en:pszenny','en:pszeniczny','en:gliten',
              'en:jeczmienne','en:jęczmienny','en:mąka-owsiana','en:owsa','en:owsiana',
              'en:owsiany','en:weizen','en:weizenstarke','en:żytnia','en:zboża','en:zboże','en:grain')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Nuts
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:nuts', type
FROM product_allergen_info
WHERE tag IN ('en:migdałów','en:laskowe','en:orzechów-pekan','en:łupiny-orzechów','en:orzeszki-laskowe')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Fish
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:fish', type
FROM product_allergen_info
WHERE tag = 'en:tunczyk'
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Sulphites
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT product_id, 'en:sulphur-dioxide-and-sulphites', type
FROM product_allergen_info
WHERE tag = 'en:pirosiarczyn'
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Delete the remapped non-standard tags
DELETE FROM product_allergen_info
WHERE tag IN (
  'en:laktoza','en:laktose','en:milch','en:milcheiweiss','en:edamski','en:pochodne-mleka',
  'en:sojowego','en:en-soybeans',
  'en:pszennego','en:pszenna','en:pszenny','en:pszeniczny','en:gliten',
  'en:jeczmienne','en:jęczmienny','en:mąka-owsiana','en:owsa','en:owsiana',
  'en:owsiany','en:weizen','en:weizenstarke','en:żytnia','en:zboża','en:zboże','en:grain',
  'en:migdałów','en:laskowe','en:orzechów-pekan','en:łupiny-orzechów','en:orzeszki-laskowe',
  'en:tunczyk','en:pirosiarczyn'
);

-- Delete junk/non-EU14 tags
DELETE FROM product_allergen_info
WHERE tag IN (
  'en:fenyloalaniny','en:kiwi','en:peach','en:pork',
  'en:none','en:brak','en:cukier','en:sok','en:s',
  'en:pestki-owoców','en:produkt-może-zwierać-fragmenty-lub-całe-pestki',
  'en:produkty-pochodne','en:en-eggs-en-nuts-en-peanuts-en-sesame-seeds-en-soybeans'
);

-- Delete Thai junk tags
DELETE FROM product_allergen_info
WHERE tag LIKE 'en:ไ%' OR tag LIKE 'en:หอ%';

-- ─── 4. Allergen cross-validation ───────────────────────────────────────
-- Auto-declare missing allergens inferred from ingredient signals

-- Milk
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:milk', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%milk%','%cream%','%butter%','%cheese%','%whey%','%lactose%','%casein%'])
AND ir.name_en NOT ILIKE ANY(ARRAY['%cocoa butter%','%shea butter%','%peanut butter%','%nut butter%','%coconut milk%','%coconut cream%','%almond milk%','%oat milk%','%soy milk%','%rice milk%','%cashew milk%','%cream of tartar%','%ice cream plant%','%buttercup%'])
AND NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = pi.product_id AND pai.tag = 'en:milk' AND pai.type = 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Gluten
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:gluten', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%wheat%','%barley%','%rye%','%spelt%'])
AND ir.name_en NOT ILIKE '%buckwheat%'
AND NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = pi.product_id AND pai.tag = 'en:gluten' AND pai.type = 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Eggs
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:eggs', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%egg%'])
AND ir.name_en NOT ILIKE ANY(ARRAY['%eggplant%','%reggiano%'])
AND NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = pi.product_id AND pai.tag = 'en:eggs' AND pai.type = 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Soybeans
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:soybeans', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%soy%','%soja%'])
AND NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = pi.product_id AND pai.tag = 'en:soybeans' AND pai.type = 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- Fish
INSERT INTO product_allergen_info (product_id, tag, type)
SELECT DISTINCT pi.product_id, 'en:fish', 'contains'
FROM product_ingredient pi
JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
JOIN products p ON p.product_id = pi.product_id AND p.is_deprecated IS NOT TRUE
WHERE ir.name_en ILIKE ANY(ARRAY['%fish%','%salmon%','%tuna%','%herring%','%mackerel%','%anchov%','%cod %','%trout%'])
AND NOT EXISTS (SELECT 1 FROM product_allergen_info pai WHERE pai.product_id = pi.product_id AND pai.tag = 'en:fish' AND pai.type = 'contains')
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ─── 5. Junk ingredient cleanup ─────────────────────────────────────────
-- Remove OFF API parser artifacts (single-char or numeric-only names)

DELETE FROM product_ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id FROM ingredient_ref
    WHERE name_en ~ '^\d+$' OR length(trim(name_en)) <= 1
);

DELETE FROM ingredient_ref
WHERE name_en ~ '^\d+$' OR length(trim(name_en)) <= 1;

-- ─── 6. Score recalculation ─────────────────────────────────────────────
-- Recompute ingredient_concern_score from concern tiers

UPDATE products p
SET ingredient_concern_score = COALESCE(concern.score, 0)
FROM (
    SELECT pi.product_id,
           LEAST(100, SUM(
               CASE ir.concern_tier
                   WHEN 1 THEN 15
                   WHEN 2 THEN 40
                   WHEN 3 THEN 100
                   ELSE 0
               END
           ))::int AS score
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    WHERE ir.concern_tier > 0
    GROUP BY pi.product_id
) concern
WHERE concern.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- Recompute unhealthiness_score
UPDATE products p
SET unhealthiness_score = compute_unhealthiness_v32(
        nf.saturated_fat_g, nf.sugars_g, nf.salt_g, nf.calories,
        nf.trans_fat_g, COALESCE(ia.additives_count, 0),
        p.prep_method, p.controversies, p.ingredient_concern_score
    )
FROM nutrition_facts nf
LEFT JOIN (
    SELECT pi.product_id,
           COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = nf.product_id
WHERE nf.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- Recompute high_additive_load flag
UPDATE products p
SET high_additive_load = CASE WHEN COALESCE(ia.additives_count, 0) >= 5 THEN 'YES' ELSE 'NO' END
FROM nutrition_facts nf
LEFT JOIN (
    SELECT pi.product_id,
           COUNT(*) FILTER (WHERE ir.is_additive)::int AS additives_count
    FROM product_ingredient pi
    JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
    GROUP BY pi.product_id
) ia ON ia.product_id = nf.product_id
WHERE nf.product_id = p.product_id
  AND p.is_deprecated IS NOT TRUE;

-- Recompute data_completeness_pct and confidence
UPDATE products p
SET data_completeness_pct = compute_data_completeness(p.product_id)
WHERE p.is_deprecated IS NOT TRUE
  AND p.data_completeness_pct != compute_data_completeness(p.product_id);

UPDATE products p
SET confidence = assign_confidence(p.data_completeness_pct, p.source_type)
WHERE p.is_deprecated IS NOT TRUE
  AND p.confidence != assign_confidence(p.data_completeness_pct, p.source_type);

-- Refresh materialized views
SELECT refresh_all_materialized_views();

COMMIT;

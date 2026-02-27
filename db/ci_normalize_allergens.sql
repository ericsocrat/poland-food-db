-- ═══════════════════════════════════════════════════════════════════════════
-- CI: Normalize allergen tags after enrichment replay
-- ═══════════════════════════════════════════════════════════════════════════
-- The enrichment migrations insert allergen tags with the raw en: prefix
-- (e.g., en:gluten, en:milk) plus many junk tags from OFF API (Polish,
-- German, Thai words, typos, malformed entries).  The allergen_tag_
-- normalization migration (20260310000200) originally handled this, but
-- ran on 0 rows (products didn't exist yet).  This script applies the
-- same normalization rules plus garbage cleanup so the FK to
-- allergen_ref(allergen_id) can be re-established.
--
-- Strategy: build a mapping temp table, then INSERT canonical tags
-- (ON CONFLICT DO NOTHING) and DELETE all variant rows.  This avoids
-- all PK violations from UPDATE — even when a product has multiple
-- variant tags that all map to the same canonical allergen.
--
-- Safe to run multiple times (fully idempotent).
-- Run AFTER enrichment replay and BEFORE ci_post_enrichment.sql.
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- 1. Preserve original tag in source_tag for traceability
UPDATE product_allergen_info
SET source_tag = tag
WHERE source_tag IS NULL;

-- ─── 2. Build variant → canonical mapping ───────────────────────────────
CREATE TEMP TABLE _tag_map (variant text PRIMARY KEY, canonical text NOT NULL);

-- Gluten variants (Polish, German, sub-allergens, typos)
INSERT INTO _tag_map (variant, canonical) VALUES
    ('en:gliten',                       'gluten'),
    ('en:pszeniczny',                   'gluten'),
    ('en:pszenna',                      'gluten'),
    ('en:pszennego',                    'gluten'),
    ('en:pszenny',                      'gluten'),
    ('en:weizen',                       'gluten'),
    ('en:weizenstarke',                 'gluten'),
    ('en:owsa',                         'gluten'),
    ('en:owsiana',                      'gluten'),
    ('en:owsiany',                      'gluten'),
    ('en:mąka-owsiana',                 'gluten'),
    ('en:jeczmienne',                   'gluten'),
    ('en:jęczmienny',                   'gluten'),
    ('en:żytnia',                       'gluten'),
    ('en:getreide',                     'gluten'),
    ('en:grain',                        'gluten'),
    ('en:zboża',                        'gluten'),
    ('en:zboże',                        'gluten'),
    ('en:dinkelvollkornsauerteig',      'gluten'),
    ('en:dinkelweizenmalzflocken',      'gluten'),
    ('en:haferkerne',                   'gluten'),
    ('en:haferpflanzenfaser',           'gluten'),
    ('en:rogenvollkornmehl',            'gluten'),
    ('en:weizenröstmalzmehl',           'gluten'),
    ('en:weizenvollkommehl',            'gluten'),
    ('en:malzextrakt',                  'gluten'),
    ('en:weizenart',                    'gluten'),
    ('en:isento-de-gluten',             'gluten'),
    ('en:wheat',                        'gluten'),
    ('en:oats',                         'gluten'),
    ('en:barley',                       'gluten'),
    ('en:rye',                          'gluten'),
    ('en:spelt',                        'gluten'),
    ('en:kamut',                        'gluten'),
    -- Milk variants
    ('en:milch',                        'milk'),
    ('en:milcheiweiss',                 'milk'),
    ('en:laktose',                      'milk'),
    ('en:laktoza',                      'milk'),
    ('en:pochodne-mleka',               'milk'),
    ('en:edamski',                      'milk'),
    -- Tree-nut variants
    ('en:laskowe',                      'tree-nuts'),
    ('en:orzeszki-laskowe',             'tree-nuts'),
    ('en:migdałów',                     'tree-nuts'),
    ('en:orzechów-pekan',               'tree-nuts'),
    ('en:łupiny-orzechów',              'tree-nuts'),
    ('en:fruits-à-coque',              'tree-nuts'),
    ('en:schalenfrüchte-keine-erdnüsse','tree-nuts'),
    ('en:nuts',                         'tree-nuts'),
    ('en:almonds',                      'tree-nuts'),
    ('en:hazelnuts',                    'tree-nuts'),
    ('en:walnuts',                      'tree-nuts'),
    ('en:cashew-nuts',                  'tree-nuts'),
    ('en:pistachio-nuts',               'tree-nuts'),
    ('en:pecan-nuts',                   'tree-nuts'),
    ('en:brazil-nuts',                  'tree-nuts'),
    ('en:macadamia-nuts',               'tree-nuts'),
    -- Soy variants
    ('en:sojowego',                     'soybeans'),
    ('en:s0ja',                         'soybeans'),
    ('en:sonja',                        'soybeans'),
    ('en:en-soybeans',                  'soybeans'),
    -- Sesame variants
    ('en:seasam',                       'sesame'),
    ('en:en-sesame-seeds',              'sesame'),
    ('en:sesame-seeds',                 'sesame'),
    -- Sulphite variants
    ('en:pirosiarczyn',                 'sulphites'),
    ('en:sulphur-dioxide-and-sulphites','sulphites'),
    -- Lupin variants
    ('en:lupinen',                      'lupin'),
    -- Malformed multi-allergen tags → first canonical
    ('en:en-eggs-en-nuts-en-peanuts-en-sesame-seeds-en-soybeans', 'eggs'),
    ('en:en-eggs-en-peanuts',           'eggs'),
    -- Foreign scripts
    ('en:ไข่-และอาจมี-นม',                'eggs'),
    ('en:หอย',                          'molluscs')
ON CONFLICT DO NOTHING;

-- ─── 3. Insert canonical tags for all variant rows (ON CONFLICT skip) ───
INSERT INTO product_allergen_info (product_id, tag, type, source_tag)
SELECT DISTINCT ON (pai.product_id, m.canonical, pai.type)
       pai.product_id, m.canonical, pai.type, pai.tag
FROM product_allergen_info pai
JOIN _tag_map m ON m.variant = pai.tag
ON CONFLICT (product_id, tag, type) DO NOTHING;

-- ─── 4. Delete all variant rows (canonical is now guaranteed to exist) ──
DELETE FROM product_allergen_info pai
USING _tag_map m
WHERE pai.tag = m.variant;

DROP TABLE _tag_map;

-- ─── 5. Strip en: prefix from standard canonical tags ───────────────────
-- Map en:gluten → gluten, en:milk → milk, etc.
-- Insert the bare version, then delete the en:-prefixed version.
INSERT INTO product_allergen_info (product_id, tag, type, source_tag)
SELECT product_id, REPLACE(tag, 'en:', ''), type, tag
FROM product_allergen_info
WHERE tag LIKE 'en:%'
ON CONFLICT (product_id, tag, type) DO NOTHING;

DELETE FROM product_allergen_info
WHERE tag LIKE 'en:%';

-- ─── 6. Delete rows with tags not in allergen_ref (junk from OFF API) ───
DELETE FROM product_allergen_info
WHERE NOT EXISTS (
    SELECT 1 FROM allergen_ref ar WHERE ar.allergen_id = product_allergen_info.tag
);

-- ─── 7. Re-add FK to allergen_ref ──────────────────────────────────────
ALTER TABLE product_allergen_info
    DROP CONSTRAINT IF EXISTS fk_allergen_tag_ref;

ALTER TABLE product_allergen_info
    ADD CONSTRAINT fk_allergen_tag_ref
    FOREIGN KEY (tag) REFERENCES allergen_ref(allergen_id);

COMMIT;

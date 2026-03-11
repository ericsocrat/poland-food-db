-- Migration: Data quality cleanup — fix naming issues, nutrition errors,
--            backfill nutri_score_source, seed product_type_ref + brand_ref
-- Rollback: Revert individual UPDATEs; DELETE from brand_ref / product_type_ref
-- Idempotency: All operations use WHERE guards and ON CONFLICT DO NOTHING

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Fix HTML entities in product names and brands
--    Affected: product 11, 1020 (product_name), 1876, 2398 (brand)
--    Safety: deprecate HTML-encoded duplicates before renaming to avoid
--            unique constraint violations on (country, brand, product_name)
-- ═══════════════════════════════════════════════════════════════════════════

-- 1a. Deprecate HTML-encoded products whose decoded name collides with
--     an existing clean product (same country + brand + decoded name)
UPDATE products AS p1
SET is_deprecated = true,
    deprecated_reason = 'Duplicate after HTML entity decode — clean version already exists'
WHERE p1.product_name ~ '&(amp|lt|gt|quot|#\d+);'
  AND p1.is_deprecated IS NOT TRUE
  AND EXISTS (
    SELECT 1 FROM products p2
    WHERE p2.country = p1.country
      AND p2.brand = p1.brand
      AND p2.product_name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
          p1.product_name,
          '&quot;', '"'),
          '&amp;', '&'),
          '&lt;', '<'),
          '&gt;', '>'),
          '&#39;', '''')
      AND p2.product_id <> p1.product_id
      AND p2.is_deprecated IS NOT TRUE
  );

-- 1b. Fix HTML entities in remaining (non-deprecated, non-colliding) product names
UPDATE products
SET product_name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    product_name,
    '&quot;', '"'),
    '&amp;', '&'),
    '&lt;', '<'),
    '&gt;', '>'),
    '&#39;', '''')
WHERE product_name ~ '&(amp|lt|gt|quot|#\d+);'
  AND is_deprecated IS NOT TRUE;

-- 1c. Fix HTML entities in brands (no unique constraint on brand alone)
UPDATE products
SET brand = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    brand,
    '&quot;', '"'),
    '&amp;', '&'),
    '&lt;', '<'),
    '&gt;', '>'),
    '&#39;', '''')
WHERE brand ~ '&(amp|lt|gt|quot|#\d+);';

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Fix trailing punctuation in product names
--    Skip: product 1948 (g.g.A. — German geographic indication abbreviation)
--    Skip: product 2519 (Hot Cheese Dip! — brand identity)
--    Deprecate: product 1078 (name = '.' — bad OFF data)
--    Deprecate: product 514 (duplicate of 2168 after period strip — Graal Tuńczyk)
-- ═══════════════════════════════════════════════════════════════════════════

-- Deprecate the product with name '.' (bad OFF data)
UPDATE products
SET is_deprecated = true,
    deprecated_reason = 'Bad OFF data: product name is just a period'
WHERE product_id = 1078
  AND product_name = '.'
  AND is_deprecated IS NOT TRUE;

-- Deprecate duplicate that would collide after period strip
UPDATE products
SET is_deprecated = true,
    deprecated_reason = 'Duplicate of product 2168 after trailing period removal'
WHERE product_id = 514
  AND is_deprecated IS NOT TRUE;

-- Deprecate any product whose period-stripped name would collide
UPDATE products AS p1
SET is_deprecated = true,
    deprecated_reason = 'Duplicate after trailing period removal — clean version already exists'
WHERE p1.is_deprecated IS NOT TRUE
  AND p1.product_name ~ '\.\s*$'
  AND p1.product_id NOT IN (1948)
  AND LENGTH(RTRIM(p1.product_name, '. ')) > 0
  AND EXISTS (
    SELECT 1 FROM products p2
    WHERE p2.country = p1.country
      AND p2.brand = p1.brand
      AND p2.product_name = RTRIM(p1.product_name, '. ')
      AND p2.product_id <> p1.product_id
      AND p2.is_deprecated IS NOT TRUE
  );

-- Strip trailing periods from remaining non-deprecated products
-- (After HTML entity fix, products 11 and 1020 no longer end with ';')
UPDATE products
SET product_name = RTRIM(product_name, '. ')
WHERE is_deprecated IS NOT TRUE
  AND product_name ~ '\.\s*$'
  AND product_id NOT IN (1948)  -- g.g.A. is legitimate
  AND LENGTH(RTRIM(product_name, '. ')) > 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Fix nutrition data errors
-- ═══════════════════════════════════════════════════════════════════════════

-- Product 1220 (Żywiec Zdrój NGaz 1l): mineral water has carbs=21.3g (should be 0)
UPDATE nutrition_facts
SET carbs_g = 0, sugars_g = 0
WHERE product_id = 1220
  AND carbs_g = 21.3;

-- Product 201 (Chleb wieloziarnisty Złoty Łan): salt=13.0g (likely decimal error → 1.3g)
UPDATE nutrition_facts
SET salt_g = 1.3
WHERE product_id = 201
  AND salt_g = 13.0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Backfill nutri_score_source for all scored products from OFF API
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE products
SET nutri_score_source = 'off_computed'
WHERE is_deprecated IS NOT TRUE
  AND nutri_score_label IN ('A', 'B', 'C', 'D', 'E')
  AND nutri_score_source IS NULL
  AND source_type = 'off_api';

-- NOT-APPLICABLE and UNKNOWN labels: mark source as 'unknown'
UPDATE products
SET nutri_score_source = 'unknown'
WHERE is_deprecated IS NOT TRUE
  AND nutri_score_label IN ('NOT-APPLICABLE', 'UNKNOWN')
  AND nutri_score_source IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Seed product_type_ref for Oils & Vinegars and Spreads & Dips
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO product_type_ref (product_type, category, display_name, sort_order)
VALUES
  ('olive-oil',          'Oils & Vinegars', 'Olive Oil',       1),
  ('rapeseed-oil',       'Oils & Vinegars', 'Rapeseed Oil',    2),
  ('sunflower-oil',      'Oils & Vinegars', 'Sunflower Oil',   3),
  ('coconut-oil',        'Oils & Vinegars', 'Coconut Oil',     4),
  ('vinegar',            'Oils & Vinegars', 'Vinegar',         5),
  ('other-oil',          'Oils & Vinegars', 'Other Oil/Vinegar', 99),
  ('hummus',             'Spreads & Dips',  'Hummus',          1),
  ('pate',               'Spreads & Dips',  'Pâté',            2),
  ('cream-cheese-spread','Spreads & Dips',  'Cream Cheese Spread', 3),
  ('guacamole',          'Spreads & Dips',  'Guacamole',       4),
  ('dip',                'Spreads & Dips',  'Dip',             5),
  ('other-spread',       'Spreads & Dips',  'Other Spread/Dip', 99)
ON CONFLICT (product_type) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Seed brand_ref from all active product brands
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO brand_ref (brand_name, display_name)
SELECT DISTINCT ON (LOWER(brand)) brand, brand
FROM products
WHERE is_deprecated IS NOT TRUE
  AND brand IS NOT NULL
ORDER BY LOWER(brand), brand
ON CONFLICT (brand_name) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7a. E-number concern tiers (case-insensitive fix)
--     Migration 20260210001900 used lowercase ('e211') but ingredient_ref
--     stores uppercase ('E211'). Re-apply with LOWER() matching.
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE ingredient_ref SET concern_tier = 1
WHERE LOWER(name_en) IN (
    'e150','e172','e200','e202','e281','e282','e338','e339','e340','e341',
    'e407a','e420','e425','e445','e450','e450i','e451','e451i','e452','e452i',
    'e461','e471','e472b','e472e','e475','e476','e481','e482','e492',
    'e627','e631','e635','e920','e960','e960a','e965','e1420'
) AND concern_tier = 0;

UPDATE ingredient_ref SET concern_tier = 2
WHERE LOWER(name_en) IN (
    'e133','e150d','e211','e220','e223','e319','e385','e407','e466',
    'e621','e950','e951','e954','e955'
) AND concern_tier = 0;

UPDATE ingredient_ref SET concern_tier = 3
WHERE LOWER(name_en) IN ('e250','e252')
  AND concern_tier = 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 7b. Text-name concern tier mappings
--     Products link to text-name entries (e.g., "Monosodium Glutamate"),
--     not E-number entries (e.g., "E621"). Both exist as separate rows
--     in ingredient_ref. Concern tiers from migration 20260210001900
--     only cover E-numbers — text-name equivalents need matching tiers.
-- ═══════════════════════════════════════════════════════════════════════════

-- Tier 2 (moderate concern): MSG, Sodium Benzoate, Saccharins
UPDATE ingredient_ref
SET concern_tier = 2
WHERE name_en IN ('Monosodium Glutamate', 'Sodium Benzoate', 'Saccharins')
  AND concern_tier = 0;

-- Tier 1 (low concern): 9 additives matching E-number counterparts
UPDATE ingredient_ref
SET concern_tier = 1
WHERE name_en IN (
    'Calcium Propionate',
    'Disodium 5''-Ribonucleotides',
    'Disodium Guanylate',
    'Disodium Inosinate',
    'Mono- And Diglycerides Of Fatty Acids',
    'Potassium Sorbate',
    'Sodium Phosphates',
    'Triphosphates',
    'Polyglycerol Esters Of Fatty Acids'
  )
  AND concern_tier = 0;

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Populate concern_reason for all concern-tier entries
--    Both E-number and text-name entries require reason text.
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE ingredient_ref
SET concern_reason = 'EFSA ADI review — low concern additive'
WHERE concern_tier = 1
  AND (concern_reason IS NULL OR concern_reason = '');

UPDATE ingredient_ref
SET concern_reason = 'EFSA safety assessment — moderate concern; potential adverse effects at high intake'
WHERE concern_tier = 2
  AND (concern_reason IS NULL OR concern_reason = '');

UPDATE ingredient_ref
SET concern_reason = 'EFSA high concern — strong evidence of adverse health effects'
WHERE concern_tier = 3
  AND (concern_reason IS NULL OR concern_reason = '');

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Brand normalization — ensure all product brands exist in brand_ref
--    DISTINCT ON picks one canonical form per case group. Then normalize
--    products to use the canonical brand_name from brand_ref.
-- ═══════════════════════════════════════════════════════════════════════════

-- Deprecate non-canonical brand duplicates that would collide after normalization
-- (p1 has the wrong-case brand; p2 already has the canonical brand)
UPDATE products AS p1
SET is_deprecated = true,
    deprecated_reason = 'Duplicate after brand case normalization — canonical version already exists'
WHERE p1.is_deprecated IS NOT TRUE
  AND EXISTS (
    SELECT 1 FROM brand_ref br
    WHERE LOWER(p1.brand) = LOWER(br.brand_name)
      AND p1.brand != br.brand_name  -- p1 has non-canonical case
  )
  AND EXISTS (
    SELECT 1 FROM products p2
    JOIN brand_ref br2 ON p2.brand = br2.brand_name  -- p2 already has canonical brand
    WHERE p2.country = p1.country
      AND p2.product_name = p1.product_name
      AND p2.product_id <> p1.product_id
      AND p2.is_deprecated IS NOT TRUE
      AND LOWER(p2.brand) = LOWER(p1.brand)
  );

-- Normalize product brands to match existing brand_ref entries
-- (skip products where normalization would cause a unique constraint collision)
UPDATE products p
SET brand = br.brand_name
FROM brand_ref br
WHERE LOWER(p.brand) = LOWER(br.brand_name)
  AND p.brand != br.brand_name
  AND p.is_deprecated IS NOT TRUE
  AND NOT EXISTS (
    SELECT 1 FROM products p2
    WHERE p2.country = p.country
      AND p2.brand = br.brand_name
      AND p2.product_name = p.product_name
      AND p2.product_id <> p.product_id
  );

-- Insert any remaining brands not yet in brand_ref (new brands from pipeline)
INSERT INTO brand_ref (brand_name, display_name)
SELECT DISTINCT brand, brand
FROM products
WHERE is_deprecated IS NOT TRUE
  AND brand IS NOT NULL
  AND brand NOT IN (SELECT brand_name FROM brand_ref)
ON CONFLICT (brand_name) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Re-score all categories
--     Concern tier changes + nutrition fixes affect scores across categories.
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT DISTINCT category, country
    FROM products
    WHERE is_deprecated IS NOT TRUE
    ORDER BY country, category
  LOOP
    CALL score_category(rec.category, 100, rec.country);
  END LOOP;
END
$$;

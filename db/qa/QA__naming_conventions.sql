-- ============================================================
-- QA: Naming Conventions & Grammar
-- Validates product_name and brand fields follow Title Case
-- conventions, have no ALL CAPS, no trailing punctuation,
-- no double spaces, and start with a capital letter.
-- All checks are BLOCKING.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. Product names must not be ALL CAPS (>3 chars to exclude abbreviations)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '1. product_name not ALL CAPS' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND length(product_name) > 3
  AND product_name = upper(product_name);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. Brand names must not be ALL CAPS (>3 chars to exclude abbreviations)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '2. brand not ALL CAPS' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND length(brand) > 3
  AND brand = upper(brand)
  AND brand ~ '[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ]';  -- exclude non-Latin script brands

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Product names must start with an uppercase letter (Latin or Polish)
--    Allows digits (e.g. "7UP") and special chars
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '3. product_name starts with uppercase' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND product_name ~ '^[a-ząćęłńóśźżäöüàèéêîôùûâïëæœ]';

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Brand names must start with an uppercase letter
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '4. brand starts with uppercase' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND brand IS NOT NULL
  AND brand ~ '^[a-ząćęłńóśźżäöüàèéêîôùûâïëæœ]'
  AND brand !~ '\.[a-z]{2,}$';  -- exclude domain-style brands (e.g. brat.pl)

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. No double (or more) consecutive spaces in product names or brands
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '5. no double spaces in names/brands' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND (product_name ~ '\s{2,}' OR brand ~ '\s{2,}');

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. No trailing punctuation in product names (period, comma, semicolon)
--    Parentheses and % are acceptable (e.g. "Czekolada 80%")
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '6. no trailing punctuation in product_name' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND product_name ~ '[.,;:!]\s*$';

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Product names should not contain tab or newline characters
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '7. no control characters in product_name' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND (product_name ~ E'[\t\n\r]' OR brand ~ E'[\t\n\r]');

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Product names should not be just a barcode / numeric string
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '8. product_name is not a barcode' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND product_name ~ '^\d{5,}$';

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. Brand should not equal "Unknown" with all-lowercase product_name
--    (indicates unprocessed OFF import data)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '9. Unknown brand products should have proper names' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND brand = 'Unknown'
  AND product_name = lower(product_name)
  AND length(product_name) > 3;

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. Category names must be in Title Case (reference table consistency)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '10. category_ref names in expected format' AS check_name,
       COUNT(*) AS violations
FROM category_ref
WHERE category ~ '^[a-z]'
   OR category = upper(category) AND length(category) > 3;

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. No HTML entities or encoding artifacts in product names
--     e.g., &amp;, &#39;, Ã©, Ã¶ (mojibake)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '11. no HTML entities or encoding artifacts' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND (product_name ~ '&(amp|lt|gt|quot|#\d+);'
    OR product_name ~ 'Ã[©¶¼]'
    OR brand ~ '&(amp|lt|gt|quot|#\d+);'
    OR brand ~ 'Ã[©¶¼]');

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. Brand name should not be duplicated inside product_name prefix
--     e.g., brand="Tymbark", product_name="Tymbark Tymbark jabłko"
-- ═══════════════════════════════════════════════════════════════════════════
SELECT '12. no stuttered brand in product_name' AS check_name,
       COUNT(*) AS violations
FROM products
WHERE is_deprecated IS NOT TRUE
  AND brand IS NOT NULL
  AND length(brand) > 2
  AND product_name ILIKE brand || ' ' || brand || '%';


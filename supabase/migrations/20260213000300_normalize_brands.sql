-- Brand normalization: standardize casing, diacriticals, and duplicates.
--
-- Canonical brand forms chosen based on majority usage, proper Polish
-- diacriticals, and conventional title-casing for brand names.

BEGIN;

-- === Deprecate brand-variant duplicates ===
UPDATE public.products
  SET is_deprecated = true,
      deprecated_reason = 'duplicate of product_id 161 (brand typo: Raspodia → Rapsodia)'
WHERE product_id = 160;

UPDATE public.products
  SET is_deprecated = true,
      deprecated_reason = 'duplicate of product_id 706 (brand variant: Baka D''or → Bakador)'
WHERE product_id = 702;

UPDATE public.products
  SET is_deprecated = true,
      deprecated_reason = 'duplicate of product_id 731 (brand variant + product name casing)'
WHERE product_id = 724;

-- === Case-only fixes ===
UPDATE public.products SET brand = 'Bakalland'         WHERE brand = 'BakallanD';
UPDATE public.products SET brand = 'BoboVita'          WHERE brand = 'Bobovita';
UPDATE public.products SET brand = 'Dobra Kaloria'     WHERE brand = 'Dobra kaloria';
UPDATE public.products SET brand = 'Go Active'         WHERE brand IN ('Go active', 'GO Active');
UPDATE public.products SET brand = 'Go Vege'           WHERE brand IN ('Go vege', 'GoVege');
UPDATE public.products SET brand = 'GustoBello'        WHERE brand = 'Gustobello';
UPDATE public.products SET brand = 'House of Asia'     WHERE brand IN ('House of asia', 'House Od Asia');
UPDATE public.products SET brand = 'Łosoś Ustka'       WHERE brand = 'Łosoś ustka';
UPDATE public.products SET brand = 'Mleczna Dolina'    WHERE brand = 'Mleczna dolina';
UPDATE public.products SET brand = 'Nasza Spiżarnia'   WHERE brand = 'Nasza spiżarnia';
UPDATE public.products SET brand = 'One Day More'      WHERE brand IN ('One day more', 'OneDayMore');
UPDATE public.products SET brand = 'Owolovo'           WHERE brand = 'OwoLovo';
UPDATE public.products SET brand = 'Plony Natury'      WHERE brand = 'Plony natury';
UPDATE public.products SET brand = 'Polskie Przetwory' WHERE brand = 'Polskie przetwory';
UPDATE public.products SET brand = 'Promienie Słońca'  WHERE brand = 'Promienie słońca';
UPDATE public.products SET brand = 'Top'               WHERE brand = 'TOP';
UPDATE public.products SET brand = 'Vital Fresh'       WHERE brand = 'Vital FRESH';
UPDATE public.products SET brand = 'Z Dobrej Piekarni' WHERE brand = 'Z dobrej piekarni';

-- === Spacing / punctuation fixes ===
UPDATE public.products SET brand = '7 Days'            WHERE brand = '7days';
UPDATE public.products SET brand = 'Bakador'           WHERE brand = 'BakaD''Or' AND product_id IN (694, 722);
UPDATE public.products SET brand = 'Dr. Oetker'        WHERE brand = 'Dr.Oetker';
UPDATE public.products SET brand = 'E. Wedel'          WHERE brand = 'E.Wedel';
UPDATE public.products SET brand = 'MegaRyba'          WHERE brand = 'Mega ryba';

-- === Diacritical / typo fixes ===
UPDATE public.products SET brand = 'Kraina Wędlin'     WHERE brand = 'Kraina Wedlin';
UPDATE public.products SET brand = 'Łomża'             WHERE brand = 'Lomża';
UPDATE public.products SET brand = 'Mroźna Kraina'     WHERE brand = 'Morźna Kraina';
UPDATE public.products SET brand = 'Żywiec Zdrój'      WHERE brand = 'Zywiec Zdroj';

-- === Additional brand normalization ===
UPDATE public.products SET brand = 'Kubuś'             WHERE brand IN ('Kubuš', 'Kubus');
UPDATE public.products SET brand = 'Sante'             WHERE brand IN ('Santé', 'Sante A. Kowalski sp. j');

-- Note: BakaD'Or product 1841 cannot be renamed to Bakador because
-- deprecated product 715 (same brand+name) blocks the unique constraint.

REFRESH MATERIALIZED VIEW public.v_product_confidence;

COMMIT;

-- PIPELINE (Nuts, Seeds & Legumes): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('BakaD''Or', 'Mieszanka orzechów prażonych', 'https://world.openfoodfacts.org/product/5905617001561', '5905617001561'),
    ('Bakador', 'Pistacje niesolone prażone', 'https://world.openfoodfacts.org/product/5900749430043', '5900749430043'),
    ('Top', 'Orzechy ziemne prażone nieslone', 'https://world.openfoodfacts.org/product/5900617041807', '5900617041807'),
    ('Bakallino', 'Migdały', 'https://world.openfoodfacts.org/product/5900587043504', '5900587043504'),
    ('Makar Bakalie', 'Migdały', 'https://world.openfoodfacts.org/product/5900775200627', '5900775200627'),
    ('Top', 'Orzeszki ziemne prażone smak ostra papryka', 'https://world.openfoodfacts.org/product/5904917980057', '5904917980057'),
    ('Bakador', 'BakaDOr. Orzechy włoskie', 'https://world.openfoodfacts.org/product/5900587042545', '5900587042545'),
    ('Spar', 'Orzeszki ziemne prażone', 'https://world.openfoodfacts.org/product/5901125006296', '5901125006296'),
    ('Baka D''or', 'Orzechy włoskie', 'https://world.openfoodfacts.org/product/5905617002544', '5905617002544'),
    ('Felix', 'Orzeszki ziemne prażone bez soli', 'https://world.openfoodfacts.org/product/5900571000070', '5900571000070'),
    ('Felix', 'Orzeszki ziemne smażone i solone', 'https://world.openfoodfacts.org/product/5900571001039', '5900571001039'),
    ('DJ Snack', 'Orzeszki ziemne smażone w chrupkiej skorupce o smaku paprykowym', 'https://world.openfoodfacts.org/product/5908235949116', '5908235949116'),
    ('Bakador', 'Orzechy włoskie', 'https://world.openfoodfacts.org/product/5900749440639', '5900749440639'),
    ('Felix', 'Orzeszki długo prażone extra chrupkie', 'https://world.openfoodfacts.org/product/5900571100909', '5900571100909'),
    ('Bakalland', 'Orzechy makadamia łuskane', 'https://world.openfoodfacts.org/product/5900749010337', '5900749010337'),
    ('Bakallino', 'Migdały łuskane', 'https://world.openfoodfacts.org/product/5900587019288', '5900587019288'),
    ('Unknown', 'Orzechy nerkowca połówki', 'https://world.openfoodfacts.org/product/5902115193187', '5902115193187'),
    ('Kresto', 'Mix orzechów', 'https://world.openfoodfacts.org/product/5902451106032', '5902451106032'),
    ('Felix', 'Carmelove z wiórkami kokosowymi', 'https://world.openfoodfacts.org/product/5900571101975', '5900571101975'),
    ('Felix', 'Orzeszki ziemne prażone', 'https://world.openfoodfacts.org/product/5900571001206', '5900571001206'),
    ('Aga Holtex', 'Migdały', 'https://world.openfoodfacts.org/product/5905027000192', '5905027000192'),
    ('BakaD''Or', 'Migdały łuskane kalifornijskie', 'https://world.openfoodfacts.org/product/5900587042514', '5900587042514'),
    ('Felix', 'Orzeszki z pieca z solą', 'https://world.openfoodfacts.org/product/5900571101005', '5900571101005'),
    ('Ecobi', 'Orzechy włoskie łuskane', 'https://world.openfoodfacts.org/product/5902751531237', '5902751531237'),
    ('Green Essence', 'Migdały naturalne całe', 'https://world.openfoodfacts.org/product/5902315400757', '5902315400757'),
    ('brat.pl', 'Orzechy brazylijskie połówki', 'https://world.openfoodfacts.org/product/5906721136910', '5906721136910'),
    ('Carrefour Extra', 'Migdały łuskane', 'https://world.openfoodfacts.org/product/5905784358062', '5905784358062'),
    ('Felix', 'Felix orzeszki ziemne', 'https://world.openfoodfacts.org/product/5900571000025', '5900571000025'),
    ('BakaD''Or', 'Mieszanka egzotyczna', 'https://world.openfoodfacts.org/product/5900587043122', '5900587043122'),
    ('Felix', 'Orzeszki ziemne lekko solone', 'https://world.openfoodfacts.org/product/5900571103436', '5900571103436'),
    ('BakaD''Or', 'Orzechy Nerkowca', 'https://world.openfoodfacts.org/product/5900749440646', '5900749440646'),
    ('Bakador', 'Orzechy pekan', 'https://world.openfoodfacts.org/product/5905617002650', '5905617002650'),
    ('Top', 'Orzeszki Top smak papryka', 'https://world.openfoodfacts.org/product/5900571902275', '5900571902275'),
    ('Bakador', 'Mieszanka orzechowa', 'https://world.openfoodfacts.org/product/5905617001769', '5905617001769'),
    ('Top Biedronka', 'Orzeszki ziemne prażone', 'https://world.openfoodfacts.org/product/5900571902299', '5900571902299'),
    ('Bakador', 'Orzechy brazylijskie', 'https://world.openfoodfacts.org/product/5905617003558', '5905617003558'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku wasabi', 'https://world.openfoodfacts.org/product/5900571904774', '5900571904774'),
    ('Bakador', 'Orzechy nerkowca', 'https://world.openfoodfacts.org/product/5905617002537', '5905617002537'),
    ('Unknown', 'Migdały łuskane', 'https://world.openfoodfacts.org/product/5905617002520', '5905617002520'),
    ('Helio S.A.', 'Mieszanka Studencka', 'https://world.openfoodfacts.org/product/5905617001905', '5905617001905'),
    ('Asia Flavours', 'Orzeszki ziemne w skorupce o smaku curry', 'https://world.openfoodfacts.org/product/5900571904781', '5900571904781'),
    ('Makar', 'Orzechy Brazylijskie', 'https://world.openfoodfacts.org/product/5900775200931', '5900775200931'),
    ('Spar', 'Mieszanka Studencka', 'https://world.openfoodfacts.org/product/5905617001127', '5905617001127'),
    ('Felix', 'Orzeszki ziemne solone', 'https://world.openfoodfacts.org/product/5900571001176', '5900571001176'),
    ('Alesto Lidl', 'Orzeszki ziemne prażone, niesolone', 'https://world.openfoodfacts.org/product/20984205', '20984205'),
    ('Felix', 'FUSION Peanuts love Curry Orient Style', 'https://world.openfoodfacts.org/product/5900571103948', '5900571103948')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Nuts, Seeds & Legumes' AND p.is_deprecated IS NOT TRUE;

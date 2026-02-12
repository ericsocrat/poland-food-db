-- PIPELINE (Seafood & Fish): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'https://world.openfoodfacts.org/product/5901576058059', '5901576058059'),
    ('Marinero', 'Łosoś wędzony na zimno', 'https://world.openfoodfacts.org/product/5906730621100', '5906730621100'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 'https://world.openfoodfacts.org/product/5903895631418', '5903895631418'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'https://world.openfoodfacts.org/product/5900344000337', '5900344000337'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'https://world.openfoodfacts.org/product/5903475460131', '5903475460131'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'https://world.openfoodfacts.org/product/5904468000228', '5904468000228'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 'https://world.openfoodfacts.org/product/5900344901825', '5900344901825'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 'https://world.openfoodfacts.org/product/5900344016697', '5900344016697'),
    ('Jantar', 'Szprot wędzony na gorąco', 'https://world.openfoodfacts.org/product/5906395035717', '5906395035717'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'https://world.openfoodfacts.org/product/5900344901832', '5900344901832'),
    ('Lisner', 'Szybki Śledzik w sosie śmietankowym', 'https://world.openfoodfacts.org/product/5900344000375', '5900344000375'),
    ('Fischer King', 'Stek z łososia', 'https://world.openfoodfacts.org/product/5901576050404', '5901576050404'),
    ('Dega', 'Ryba śledź po grecku', 'https://world.openfoodfacts.org/product/5900672012606', '5900672012606'),
    ('Kong Oskar', 'Tuńczyk w kawałkach w oleju roślinnym', 'https://world.openfoodfacts.org/product/5901489215273', '5901489215273'),
    ('Auchan', 'ŁOSOŚ PACYFICZNY DZIKI', 'https://world.openfoodfacts.org/product/5904215131335', '5904215131335'),
    ('GRAAL', 'Tuńczyk Mexicans z warzywami', 'https://world.openfoodfacts.org/product/5903895632491', '5903895632491'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 'https://world.openfoodfacts.org/product/5900344000429', '5900344000429'),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', 'https://world.openfoodfacts.org/product/5900344030129', '5900344030129'),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', 'https://world.openfoodfacts.org/product/5903496036971', '5903496036971'),
    ('Śledzie od serca', 'Śledzie po żydowsku', 'https://world.openfoodfacts.org/product/5901576051876', '5901576051876'),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'https://world.openfoodfacts.org/product/5906730601614', '5906730601614'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'https://world.openfoodfacts.org/product/5903475450132', '5903475450132'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'https://world.openfoodfacts.org/product/5900344992175', '5900344992175'),
    ('Pescadero', 'Filety z pstrąga', 'https://world.openfoodfacts.org/product/5906395035953', '5906395035953'),
    ('Contimax', 'Wiejskie filety śledziowe marynowane z cebulą', 'https://world.openfoodfacts.org/product/5901576044724', '5901576044724'),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', 'https://world.openfoodfacts.org/product/5906730601058', '5906730601058'),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'https://world.openfoodfacts.org/product/5900344026597', '5900344026597'),
    ('Marinero', 'Łosoś łagodny', 'https://world.openfoodfacts.org/product/5903475440133', '5903475440133'),
    ('Lisner', 'Śledzik na raz Pikantny', 'https://world.openfoodfacts.org/product/5900344902266', '5900344902266'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5901596471005', '5901596471005'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895039009', '5903895039009'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895080018', '5903895080018'),
    ('Lisner', 'Marinated Herring in mushroom sauce', 'https://world.openfoodfacts.org/product/5900344009293', '5900344009293'),
    ('Suempol', 'Gniazda z łososia', 'https://world.openfoodfacts.org/product/5906730601850', '5906730601850'),
    ('Koryb', 'Łosoś atlantycki', 'https://world.openfoodfacts.org/product/5902020533115', '5902020533115'),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', 'https://world.openfoodfacts.org/product/5901529089642', '5901529089642'),
    ('Unknown', 'Łosoś wędzony na gorąco', 'https://world.openfoodfacts.org/product/5906730621155', '5906730621155'),
    ('Lisner', 'Herring single portion with onion', 'https://world.openfoodfacts.org/product/5900344901818', '5900344901818'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895010237', '5903895010237'),
    ('Lisner', 'Herring Snack', 'https://world.openfoodfacts.org/product/5900344901788', '5900344901788'),
    ('nautica', 'Śledzie Wiejskie', 'https://world.openfoodfacts.org/product/20544508', '20544508'),
    ('Well done', 'Łosoś atlantycki', 'https://world.openfoodfacts.org/product/2098765853199', '2098765853199'),
    ('Graal', 'Szprot w sosie pomidorowym', 'https://world.openfoodfacts.org/product/5903895010169', '5903895010169'),
    ('Marinero', 'Filety śledziowe a''la Matjas', 'https://world.openfoodfacts.org/product/20503031', '20503031'),
    ('Marinero', 'Paluszki z fileta z dorsza', 'https://world.openfoodfacts.org/product/5908257108836', '5908257108836'),
    ('Asia Flavours', 'Sushi Nori', 'https://world.openfoodfacts.org/product/5903050791537', '5903050791537'),
    ('House Od Asia', 'Nori', 'https://world.openfoodfacts.org/product/5907599956204', '5907599956204'),
    ('Purella', 'Chlorella detoks', 'https://world.openfoodfacts.org/product/5903246561913', '5903246561913'),
    ('Asia Flavours', 'Dried wakame', 'https://world.openfoodfacts.org/product/5905118020511', '5905118020511'),
    ('Marinero', 'Tuńczyk kawałki w sosie własnym', 'https://world.openfoodfacts.org/product/8429583014433', '8429583014433')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE;

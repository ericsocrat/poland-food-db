-- PIPELINE (Seafood & Fish): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Seafood & Fish'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Marinero', 'Łosoś wędzony na zimno', 'https://images.openfoodfacts.org/images/products/590/673/062/1100/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906730621100', 'front_5906730621100'),
    ('Marinero', 'Łosoś atlantycki marynowany plastry', 'https://images.openfoodfacts.org/images/products/590/673/062/1148/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906730621148', 'front_5906730621148'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'https://images.openfoodfacts.org/images/products/590/347/546/0131/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903475460131', 'front_5903475460131'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym', 'https://images.openfoodfacts.org/images/products/590/389/563/1418/front_pl.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895631418', 'front_5903895631418'),
    ('Lisner', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'https://images.openfoodfacts.org/images/products/590/034/400/0337/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344000337', 'front_5900344000337'),
    ('Lisner', 'Filety śledziowe w oleju a''la Matjas', 'https://images.openfoodfacts.org/images/products/590/034/401/6697/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344016697', 'front_5900344016697'),
    ('Jantar', 'Szprot wędzony na gorąco', 'https://images.openfoodfacts.org/images/products/590/639/503/5717/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906395035717', 'front_5906395035717'),
    ('Lisner', 'Szybki Śledzik w sosie śmietankowym', 'https://images.openfoodfacts.org/images/products/590/034/400/0375/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344000375', 'front_5900344000375'),
    ('Fischer King', 'Stek z łososia', 'https://images.openfoodfacts.org/images/products/590/157/605/0404/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901576050404', 'front_5901576050404'),
    ('Lisner', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'https://images.openfoodfacts.org/images/products/590/034/490/1832/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344901832', 'front_5900344901832'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/590/034/490/1825/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344901825', 'front_5900344901825'),
    ('Auchan', 'Łosoś Pacyficzny Dziki', 'https://images.openfoodfacts.org/images/products/590/421/513/1335/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215131335', 'front_5904215131335'),
    ('Marinero', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'https://images.openfoodfacts.org/images/products/590/157/605/8059/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901576058059', 'front_5901576058059'),
    ('Komersmag', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'https://images.openfoodfacts.org/images/products/590/446/800/0228/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904468000228', 'front_5904468000228'),
    ('Kong Oskar', 'Tuńczyk w kawałkach w oleju roślinnym', 'https://images.openfoodfacts.org/images/products/590/148/921/5273/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901489215273', 'front_5901489215273'),
    ('Jantar', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'https://images.openfoodfacts.org/images/products/590/421/513/8518/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215138518', 'front_5904215138518'),
    ('Northlantica', 'Śledź filet (wędzony z przyprawami)', 'https://images.openfoodfacts.org/images/products/590/578/434/7943/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784347943', 'front_5905784347943'),
    ('Dega', 'Ryba śledź po grecku', 'https://images.openfoodfacts.org/images/products/590/067/201/2606/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900672012606', 'front_5900672012606'),
    ('Graal', 'Tuńczyk Mexicans z warzywami', 'https://images.openfoodfacts.org/images/products/590/389/563/2491/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895632491', 'front_5903895632491'),
    ('Lisner', 'Śledzik na raz w sosie grzybowym kurki', 'https://images.openfoodfacts.org/images/products/590/034/403/0129/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344030129', 'front_5900344030129'),
    ('Marinero', 'Wiejskie filety śledziowe z cebulką', 'https://images.openfoodfacts.org/images/products/590/034/400/0429/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344000429', 'front_5900344000429'),
    ('Suempol Pan Łosoś', 'Łosoś Wędzony Plastrowany', 'https://images.openfoodfacts.org/images/products/590/673/060/1058/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906730601058', 'front_5906730601058'),
    ('Marinero', 'Łosoś łagodny', 'https://images.openfoodfacts.org/images/products/590/347/544/0133/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903475440133', 'front_5903475440133'),
    ('Marinero', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'https://images.openfoodfacts.org/images/products/590/347/545/0132/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903475450132', 'front_5903475450132'),
    ('Pescadero', 'Filety z pstrąga', 'https://images.openfoodfacts.org/images/products/590/639/503/5953/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906395035953', 'front_5906395035953'),
    ('Orka', 'Filety śledziowe w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/823/595/5582/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908235955582', 'front_5908235955582'),
    ('Homar', 'Filet śledziowy a''la matjas', 'https://images.openfoodfacts.org/images/products/590/307/500/0126/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903075000126', 'front_5903075000126'),
    ('Lisner', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'https://images.openfoodfacts.org/images/products/590/034/499/2175/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344992175', 'front_5900344992175'),
    ('Suempol', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'https://images.openfoodfacts.org/images/products/590/673/060/1614/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906730601614', 'front_5906730601614'),
    ('Marinero', 'Śledź filety z suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/590/349/603/6971/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903496036971', 'front_5903496036971'),
    ('Fisher King', 'Pstrąg łososiowy wędzony w plastrach', 'https://images.openfoodfacts.org/images/products/590/157/605/1616/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901576051616', 'front_5901576051616'),
    ('Śledzie od serca', 'Śledzie po żydowsku', 'https://images.openfoodfacts.org/images/products/590/157/605/1876/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901576051876', 'front_5901576051876'),
    ('Lisner', 'Śledzik na raz Pikantny', 'https://images.openfoodfacts.org/images/products/590/034/490/2266/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344902266', 'front_5900344902266'),
    ('Mirko', 'Koreczki śledziowe z papryką chilli', 'https://images.openfoodfacts.org/images/products/590/349/603/6582/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903496036582', 'front_5903496036582'),
    ('Lisner', 'Filety śledziowe a''la Matjas', 'https://images.openfoodfacts.org/images/products/590/034/430/1090/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344301090', 'front_5900344301090'),
    ('Marinero', 'Łosoś plastry, wędzony na zimno', 'https://images.openfoodfacts.org/images/products/590/347/547/1106/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903475471106', 'front_5903475471106'),
    ('Auchan', 'Łosoś atlantycki wędzony na zimno plastry', 'https://images.openfoodfacts.org/images/products/590/421/516/3299/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215163299', 'front_5904215163299'),
    ('Suempol', 'Łosoś atlantycki marynowany', 'https://images.openfoodfacts.org/images/products/590/578/434/6748/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784346748', 'front_5905784346748'),
    ('Lisner', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'https://images.openfoodfacts.org/images/products/590/034/402/6597/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344026597', 'front_5900344026597'),
    ('Seko', 'Filety z makreli smażone w zalewie octowej', 'https://images.openfoodfacts.org/images/products/590/235/300/6102/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902353006102', 'front_5902353006102'),
    ('Baltica', 'Filety śledziowe w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/159/647/1005/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901596471005', 'front_5901596471005'),
    ('Lisner', 'Marinated Herring in mushroom sauce', 'https://images.openfoodfacts.org/images/products/590/034/400/9293/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344009293', 'front_5900344009293'),
    ('Marinero', 'Filety z makreli w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/503/9009/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895039009', 'front_5903895039009'),
    ('SuperFish', 'Smoked Salmon', 'https://images.openfoodfacts.org/images/products/590/033/500/4733/front_es.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900335004733', 'front_5900335004733'),
    ('MegaRyba', 'Szprot w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/508/0018/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895080018', 'front_5903895080018'),
    ('Lisner', 'Herring single portion with onion', 'https://images.openfoodfacts.org/images/products/590/034/490/1818/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344901818', 'front_5900344901818'),
    ('Suempol', 'Gniazda z łososia', 'https://images.openfoodfacts.org/images/products/590/673/060/1850/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906730601850', 'front_5906730601850'),
    ('Port netto', 'Łosoś atlantycki wędzony na zimno', 'https://images.openfoodfacts.org/images/products/590/152/908/9642/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901529089642', 'front_5901529089642'),
    ('Vital Food', 'Chlorella', 'https://images.openfoodfacts.org/images/products/590/234/097/1444/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902340971444', 'front_5902340971444'),
    ('Graal', 'Filety z makreli w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/501/0237/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010237', 'front_5903895010237'),
    ('King Oscar', 'Filety z makreli w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/148/903/7707/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901489037707', 'front_5901489037707'),
    ('Lisner', 'Herring Snack', 'https://images.openfoodfacts.org/images/products/590/034/490/1788/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344901788', 'front_5900344901788'),
    ('Nautica', 'Śledzie Wiejskie', 'https://images.openfoodfacts.org/images/products/000/002/054/4508/front_pl.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 20544508', 'front_20544508'),
    ('Marinero', 'Paluszki z fileta z dorsza', 'https://images.openfoodfacts.org/images/products/590/825/710/8836/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908257108836', 'front_5908257108836'),
    ('Asia Flavours', 'Sushi Nori', 'https://images.openfoodfacts.org/images/products/590/305/079/1537/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903050791537', 'front_5903050791537'),
    ('House Od Asia', 'Nori', 'https://images.openfoodfacts.org/images/products/590/759/995/6204/front_ru.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907599956204', 'front_5907599956204'),
    ('Marinero', 'Tuńczyk jednolity w sosie własnym', 'https://images.openfoodfacts.org/images/products/841/260/498/9308/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 8412604989308', 'front_8412604989308'),
    ('Graal', 'Szprot w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/501/0169/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010169', 'front_5903895010169'),
    ('Marinero', 'Tuńczyk kawałki w sosie własnym', 'https://images.openfoodfacts.org/images/products/842/958/301/4433/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8429583014433', 'front_8429583014433'),
    ('Well done', 'Łosoś atlantycki', 'https://images.openfoodfacts.org/images/products/209/876/585/3199/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 2098765853199', 'front_2098765853199'),
    ('House of Asia', 'Wakame', 'https://images.openfoodfacts.org/images/products/590/821/999/4774/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908219994774', 'front_5908219994774'),
    ('Purella', 'Chlorella detoks', 'https://images.openfoodfacts.org/images/products/590/324/656/1913/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903246561913', 'front_5903246561913'),
    ('Marinero', 'Filety śledziowe a''la Matjas', 'https://images.openfoodfacts.org/images/products/000/002/050/3031/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 20503031', 'front_20503031'),
    ('K-Classic', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'https://images.openfoodfacts.org/images/products/406/336/701/8657/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367018657', 'front_4063367018657'),
    ('Biedronka', 'Filet z makreli wędzony z posypką', 'https://images.openfoodfacts.org/images/products/298/214/200/1740/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 2982142001740', 'front_2982142001740'),
    ('Marinero', 'Świeży pstrąg tęczowy łososiowy filet', 'https://images.openfoodfacts.org/images/products/297/423/600/4614/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 2974236004614', 'front_2974236004614'),
    ('Nautica', 'Opiekane filety śledziowe w zalewie octowej', 'https://images.openfoodfacts.org/images/products/000/002/069/1332/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 20691332', 'front_20691332'),
    ('Graal', 'Thon', 'https://images.openfoodfacts.org/images/products/590/389/502/0045/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895020045', 'front_5903895020045'),
    ('Nautica', 'Filety śledziowe w sosie śmietanowym', 'https://images.openfoodfacts.org/images/products/000/002/041/1671/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 20411671', 'front_20411671'),
    ('Targroch', 'Agar-Agar proszek', 'https://images.openfoodfacts.org/images/products/590/322/900/4994/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903229004994', 'front_5903229004994'),
    ('Asia Flavours', 'Dried wakame', 'https://images.openfoodfacts.org/images/products/590/511/802/0511/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905118020511', 'front_5905118020511'),
    ('Lisner', 'Herring rolls with onion in rapeseed oil', 'https://images.openfoodfacts.org/images/products/590/034/490/1276/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344901276', 'front_5900344901276'),
    ('K classic', 'Filety Śledziowe w sosie koperkowym', 'https://images.openfoodfacts.org/images/products/433/718/525/4635/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337185254635', 'front_4337185254635'),
    ('Baltica', 'Filety z makreli w oleju', 'https://images.openfoodfacts.org/images/products/590/159/647/0404/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901596470404', 'front_5901596470404'),
    ('Nautica', 'Łosoś plastry', 'https://images.openfoodfacts.org/images/products/405/648/961/9499/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489619499', 'front_4056489619499'),
    ('Nautica', 'Koreczki Śledziowe Po Kaszubsku', 'https://images.openfoodfacts.org/images/products/405/648/981/3286/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489813286', 'front_4056489813286'),
    ('Nautica', 'Koreczki śledziowe po giżycku', 'https://images.openfoodfacts.org/images/products/405/648/981/3262/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489813262', 'front_4056489813262'),
    ('Nautica', 'Koreczki śledziowe w oleju', 'https://images.openfoodfacts.org/images/products/405/648/981/3279/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489813279', 'front_4056489813279'),
    ('Nautica', 'Filety śledziowe wiejskie', 'https://images.openfoodfacts.org/images/products/000/002/093/3692/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 20933692', 'front_20933692'),
    ('Nautica', 'Krajanka śledziowa z żurawiną i brzoskwinią', 'https://images.openfoodfacts.org/images/products/000/002/014/5668/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 20145668', 'front_20145668'),
    ('Nautica', 'Krajanka śledziowa z kolorowym piperzem', 'https://images.openfoodfacts.org/images/products/000/002/014/5651/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20145651', 'front_20145651'),
    ('Nautica', 'Krajanka śledziowa z suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/000/002/014/5675/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20145675', 'front_20145675'),
    ('Fjord', 'Łosoś Pieczony', 'https://images.openfoodfacts.org/images/products/288/703/800/1883/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 2887038001883', 'front_2887038001883'),
    ('SuperFish', 'Łosoś atlantycki pieczony', 'https://images.openfoodfacts.org/images/products/287/043/000/1544/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 2870430001544', 'front_2870430001544'),
    ('Golden Seafood', 'Filety Z Tuńczyka W Oleju Słonecznikowym', 'https://images.openfoodfacts.org/images/products/406/870/610/9607/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706109607', 'front_4068706109607'),
    ('Blue bay', 'Łosoś Norweski', 'https://images.openfoodfacts.org/images/products/284/262/000/3362/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 2842620003362', 'front_2842620003362'),
    ('Nautica', 'Filety śledziowe w sosie koperkowym', 'https://images.openfoodfacts.org/images/products/000/002/041/9073/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 20419073', 'front_20419073'),
    ('Almare Seafood', 'Filet z tuńczyka w sosie własnym', 'https://images.openfoodfacts.org/images/products/000/002/802/9588/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 28029588', 'front_28029588'),
    ('Marinero', 'Filety z pstrąga tęczowego wędzonego na gorąco', 'https://images.openfoodfacts.org/images/products/292/084/900/1410/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 2920849001410', 'front_2920849001410'),
    ('Biedronka', 'Łosos pacyficzny filet ze skórą', 'https://images.openfoodfacts.org/images/products/293/286/100/3068/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 2932861003068', 'front_2932861003068')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

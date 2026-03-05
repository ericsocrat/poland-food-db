-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906730621100', '5906730621148', '5903475460131', '5903895631418', '5900344000337', '5900344016697', '5906395035717', '5900344000375', '5901576050404', '5900344901832', '5900344901825', '5904215131335', '5901576058059', '5904468000228', '5901489215273', '5904215138518', '5905784347943', '5900672012606', '5903895632491', '5900344030129', '5900344000429', '5906730601058', '5903475440133', '5903475450132', '5906395035953', '5908235955582', '5903075000126', '5900344992175', '5906730601614', '5903496036971', '5901576051616', '5901576051876', '5900344902266', '5903496036582', '5900344301090', '5903475471106', '5904215163299', '5905784346748', '5901576044724', '5900344026597', '5902353006102', '5901596471005', '5900344009293', '5903895039009', '5900335004733', '5903895080018', '5900344901818', '5906730601850', '5902020533115', '5901529089642', '5906730621155', '5902340971444', '5903895010237', '5901489037707', '5900344901788', '20544508', '5908257108836', '5903050791537', '5907599956204', '8412604989308', '5903895010169', '8429583014433', '2098765853199', '5908219994774', '5903246561913', '20503031', '4063367018657', '2982142001740', '2974236004614', '20691332', '5903895020045', '20411671', '5902353003248', '5903229004994', '5905118020511', '5900344901276', '4337185254635', '5901596470404', '4056489619499', '4056489813286', '4056489813262', '4056489813279', '20933692', '20145668', '20145651', '20145675', '5903111025397', '2887038001883', '2870430001544', '4068706109607', '2842620003362', '20419073', '28029588', '2920849001410', '2932861003068')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na zimno', 'smoked', 'Biedronka', 'none', '5906730621100'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki marynowany plastry', 'marinated', 'Biedronka', 'none', '5906730621148'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'smoked', 'Biedronka', 'none', '5903475460131'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '5903895631418'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'not-applicable', 'Biedronka', 'none', '5900344000337'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w oleju a''la Matjas', 'not-applicable', 'Tesco', 'none', '5900344016697'),
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Szprot wędzony na gorąco', 'smoked', 'Auchan', 'none', '5906395035717'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki Śledzik w sosie śmietankowym', 'not-applicable', 'Biedronka', 'none', '5900344000375'),
  ('PL', 'Fischer King', 'Grocery', 'Seafood & Fish', 'Stek z łososia', 'not-applicable', 'Netto', 'none', '5901576050404'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'not-applicable', 'Biedronka', 'none', '5900344901832'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami', 'not-applicable', 'Biedronka', 'none', '5900344901825'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Łosoś Pacyficzny Dziki', 'smoked', 'Auchan', 'none', '5904215131335'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'smoked', 'Biedronka', 'none', '5901576058059'),
  ('PL', 'Komersmag', 'Grocery', 'Seafood & Fish', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'fried', 'Auchan', 'none', '5904468000228'),
  ('PL', 'Kong Oskar', 'Grocery', 'Seafood & Fish', 'Tuńczyk w kawałkach w oleju roślinnym', 'not-applicable', 'Auchan', 'none', '5901489215273'),
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'smoked', 'Auchan', 'none', '5904215138518'),
  ('PL', 'Northlantica', 'Grocery', 'Seafood & Fish', 'Śledź filet (wędzony z przyprawami)', 'smoked', 'Carrefour', 'none', '5905784347943'),
  ('PL', 'Dega', 'Grocery', 'Seafood & Fish', 'Ryba śledź po grecku', 'not-applicable', 'Lewiatan', 'none', '5900672012606'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk Mexicans z warzywami', 'not-applicable', null, 'none', '5903895632491'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz w sosie grzybowym kurki', 'not-applicable', null, 'none', '5900344030129'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe z cebulką', 'not-applicable', null, 'none', '5900344000429'),
  ('PL', 'Suempol Pan Łosoś', 'Grocery', 'Seafood & Fish', 'Łosoś Wędzony Plastrowany', 'smoked', null, 'none', '5906730601058'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś łagodny', 'smoked', null, 'none', '5903475440133'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'smoked', null, 'none', '5903475450132'),
  ('PL', 'Pescadero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga', 'not-applicable', null, 'none', '5906395035953'),
  ('PL', 'Orka', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', null, 'none', '5908235955582'),
  ('PL', 'Homar', 'Grocery', 'Seafood & Fish', 'Filet śledziowy a''la matjas', 'not-applicable', null, 'none', '5903075000126'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'not-applicable', null, 'none', '5900344992175'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'smoked', null, 'none', '5906730601614'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Śledź filety z suszonymi pomidorami', 'not-applicable', null, 'none', '5903496036971'),
  ('PL', 'Fisher King', 'Grocery', 'Seafood & Fish', 'Pstrąg łososiowy wędzony w plastrach', 'smoked', null, 'none', '5901576051616'),
  ('PL', 'Śledzie od serca', 'Grocery', 'Seafood & Fish', 'Śledzie po żydowsku', 'not-applicable', null, 'none', '5901576051876'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz Pikantny', 'not-applicable', null, 'none', '5900344902266'),
  ('PL', 'Mirko', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe z papryką chilli', 'not-applicable', null, 'none', '5903496036582'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', 'not-applicable', null, 'none', '5900344301090'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś plastry, wędzony na zimno', 'smoked', null, 'none', '5903475471106'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno plastry', 'smoked', null, 'none', '5904215163299'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki marynowany', 'smoked', null, 'none', '5905784346748'),
  ('PL', 'Contimax', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe marynowane z cebulą', 'not-applicable', null, 'none', '5901576044724'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'not-applicable', null, 'none', '5900344026597'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Filety z makreli smażone w zalewie octowej', 'fried', null, 'none', '5902353006102'),
  ('PL', 'Baltica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', null, 'none', '5901596471005'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marinated Herring in mushroom sauce', 'marinated', 'Auchan', 'none', '5900344009293'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895039009'),
  ('PL', 'SuperFish', 'Grocery', 'Seafood & Fish', 'Smoked Salmon', 'smoked', 'Kaufland', 'none', '5900335004733'),
  ('PL', 'MegaRyba', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5903895080018'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring single portion with onion', 'not-applicable', 'Biedronka', 'none', '5900344901818'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Gniazda z łososia', 'not-applicable', null, 'none', '5906730601850'),
  ('PL', 'Koryb', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', null, 'none', '5902020533115'),
  ('PL', 'Port netto', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno', 'smoked', null, 'none', '5901529089642'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco', 'smoked', null, 'none', '5906730621155'),
  ('PL', 'Vital Food', 'Grocery', 'Seafood & Fish', 'Chlorella', 'dried', 'Auchan', 'none', '5902340971444'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010237'),
  ('PL', 'King Oscar', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', null, 'none', '5901489037707'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring Snack', 'not-applicable', null, 'none', '5900344901788'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Śledzie Wiejskie', 'not-applicable', 'Lidl', 'none', '20544508'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Paluszki z fileta z dorsza', 'not-applicable', null, 'none', '5908257108836'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Sushi Nori', 'dried', null, 'none', '5903050791537'),
  ('PL', 'House Od Asia', 'Grocery', 'Seafood & Fish', 'Nori', 'not-applicable', null, 'none', '5907599956204'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Tuńczyk jednolity w sosie własnym', 'not-applicable', 'Biedronka', 'none', '8412604989308'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010169'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '8429583014433'),
  ('PL', 'Well done', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', 'Stokrotka', 'none', '2098765853199'),
  ('PL', 'House of Asia', 'Grocery', 'Seafood & Fish', 'Wakame', 'dried', null, 'none', '5908219994774'),
  ('PL', 'Purella', 'Grocery', 'Seafood & Fish', 'Chlorella detoks', 'dried', null, 'none', '5903246561913'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', 'not-applicable', 'Biedronka', 'none', '20503031'),
  ('PL', 'K-Classic', 'Grocery', 'Seafood & Fish', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'smoked', 'Kaufland', 'none', '4063367018657'),
  ('PL', 'Biedronka', 'Grocery', 'Seafood & Fish', 'Filet z makreli wędzony z posypką', 'smoked', 'Biedronka', 'none', '2982142001740'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Świeży pstrąg tęczowy łososiowy filet', 'not-applicable', 'Biedronka', 'none', '2974236004614'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Opiekane filety śledziowe w zalewie octowej', 'not-applicable', 'Lidl', 'none', '20691332'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Thon', 'not-applicable', null, 'none', '5903895020045'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie śmietanowym', 'not-applicable', 'Lidl', 'none', '20411671'),
  ('PL', 'Seko', 'Grocery', 'Seafood & Fish', 'Ryba po grecku', 'not-applicable', null, 'none', '5902353003248'),
  ('PL', 'Targroch', 'Grocery', 'Seafood & Fish', 'Agar-Agar proszek', 'not-applicable', null, 'none', '5903229004994'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Dried wakame', 'dried', null, 'none', '5905118020511'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring rolls with onion in rapeseed oil', 'not-applicable', null, 'none', '5900344901276'),
  ('PL', 'K classic', 'Grocery', 'Seafood & Fish', 'Filety Śledziowe w sosie koperkowym', 'not-applicable', 'Kaufland', 'none', '4337185254635'),
  ('PL', 'Baltica', 'Grocery', 'Seafood & Fish', 'Filety z makreli w oleju', 'not-applicable', null, 'none', '5901596470404'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Łosoś plastry', 'smoked', null, 'none', '4056489619499'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki Śledziowe Po Kaszubsku', 'not-applicable', null, 'none', '4056489813286'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe po giżycku', 'not-applicable', null, 'none', '4056489813262'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Koreczki śledziowe w oleju', 'not-applicable', null, 'none', '4056489813279'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe wiejskie', 'not-applicable', null, 'none', '20933692'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z żurawiną i brzoskwinią', 'not-applicable', null, 'none', '20145668'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z kolorowym piperzem', 'not-applicable', null, 'none', '20145651'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Krajanka śledziowa z suszonymi pomidorami', 'not-applicable', null, 'none', '20145675'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Kimbab surimi', 'not-applicable', null, 'none', '5903111025397'),
  ('PL', 'Fjord', 'Grocery', 'Seafood & Fish', 'Łosoś Pieczony', 'roasted', null, 'none', '2887038001883'),
  ('PL', 'SuperFish', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki pieczony', 'roasted', null, 'none', '2870430001544'),
  ('PL', 'Golden Seafood', 'Grocery', 'Seafood & Fish', 'Filety Z Tuńczyka W Oleju Słonecznikowym', 'not-applicable', null, 'none', '4068706109607'),
  ('PL', 'Blue bay', 'Grocery', 'Seafood & Fish', 'Łosoś Norweski', 'not-applicable', null, 'none', '2842620003362'),
  ('PL', 'Nautica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie koperkowym', 'not-applicable', null, 'none', '20419073'),
  ('PL', 'Almare Seafood', 'Grocery', 'Seafood & Fish', 'Filet z tuńczyka w sosie własnym', 'not-applicable', null, 'none', '28029588'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga tęczowego wędzonego na gorąco', 'smoked', null, 'none', '2920849001410'),
  ('PL', 'Biedronka', 'Grocery', 'Seafood & Fish', 'Łosos pacyficzny filet ze skórą', 'not-applicable', null, 'none', '2932861003068')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Seafood & Fish'
  and is_deprecated is not true
  and product_name not in ('Łosoś wędzony na zimno', 'Łosoś atlantycki marynowany plastry', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'Tuńczyk kawałki w sosie własnym', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'Filety śledziowe w oleju a''la Matjas', 'Szprot wędzony na gorąco', 'Szybki Śledzik w sosie śmietankowym', 'Stek z łososia', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'Śledzik na raz z suszonymi pomidorami', 'Łosoś Pacyficzny Dziki', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'Tuńczyk w kawałkach w oleju roślinnym', 'Filet z pstrąga wędzonego na gorąco z pieprzem', 'Śledź filet (wędzony z przyprawami)', 'Ryba śledź po grecku', 'Tuńczyk Mexicans z warzywami', 'Śledzik na raz w sosie grzybowym kurki', 'Wiejskie filety śledziowe z cebulką', 'Łosoś Wędzony Plastrowany', 'Łosoś łagodny', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'Filety z pstrąga', 'Filety śledziowe w sosie pomidorowym', 'Filet śledziowy a''la matjas', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'Śledź filety z suszonymi pomidorami', 'Pstrąg łososiowy wędzony w plastrach', 'Śledzie po żydowsku', 'Śledzik na raz Pikantny', 'Koreczki śledziowe z papryką chilli', 'Filety śledziowe a''la Matjas', 'Łosoś plastry, wędzony na zimno', 'Łosoś atlantycki wędzony na zimno plastry', 'Łosoś atlantycki marynowany', 'Wiejskie filety śledziowe marynowane z cebulą', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'Filety z makreli smażone w zalewie octowej', 'Filety śledziowe w sosie pomidorowym', 'Marinated Herring in mushroom sauce', 'Filety z makreli w sosie pomidorowym', 'Smoked Salmon', 'Szprot w sosie pomidorowym', 'Herring single portion with onion', 'Gniazda z łososia', 'Łosoś atlantycki', 'Łosoś atlantycki wędzony na zimno', 'Łosoś wędzony na gorąco', 'Chlorella', 'Filety z makreli w sosie pomidorowym', 'Filety z makreli w sosie pomidorowym', 'Herring Snack', 'Śledzie Wiejskie', 'Paluszki z fileta z dorsza', 'Sushi Nori', 'Nori', 'Tuńczyk jednolity w sosie własnym', 'Szprot w sosie pomidorowym', 'Tuńczyk kawałki w sosie własnym', 'Łosoś atlantycki', 'Wakame', 'Chlorella detoks', 'Filety śledziowe a''la Matjas', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'Filet z makreli wędzony z posypką', 'Świeży pstrąg tęczowy łososiowy filet', 'Opiekane filety śledziowe w zalewie octowej', 'Thon', 'Filety śledziowe w sosie śmietanowym', 'Ryba po grecku', 'Agar-Agar proszek', 'Dried wakame', 'Herring rolls with onion in rapeseed oil', 'Filety Śledziowe w sosie koperkowym', 'Filety z makreli w oleju', 'Łosoś plastry', 'Koreczki Śledziowe Po Kaszubsku', 'Koreczki śledziowe po giżycku', 'Koreczki śledziowe w oleju', 'Filety śledziowe wiejskie', 'Krajanka śledziowa z żurawiną i brzoskwinią', 'Krajanka śledziowa z kolorowym piperzem', 'Krajanka śledziowa z suszonymi pomidorami', 'Kimbab surimi', 'Łosoś Pieczony', 'Łosoś atlantycki pieczony', 'Filety Z Tuńczyka W Oleju Słonecznikowym', 'Łosoś Norweski', 'Filety śledziowe w sosie koperkowym', 'Filet z tuńczyka w sosie własnym', 'Filety z pstrąga tęczowego wędzonego na gorąco', 'Łosos pacyficzny filet ze skórą');

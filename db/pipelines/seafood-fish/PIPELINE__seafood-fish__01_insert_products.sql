-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901576058059', '5906730621100', '5903895631418', '5900344000337', '5903475460131', '5904468000228', '5900344901825', '5900344016697', '5906395035717', '5900344901832', '5900344000375', '5901576050404', '5900672012606', '5901489215273', '5904215131335', '5903895632491', '5900344000429', '5900344030129', '5903496036971', '5901576051876', '5906730601614', '5903475450132', '5900344992175', '5906395035953', '5901576044724', '5906730601058', '5900344026597', '5903475440133', '5900344902266', '5901596471005', '5903895039009', '5903895080018', '5900344009293', '5906730601850', '5902020533115', '5901529089642', '5906730621155', '5900344901818', '5903895010237', '5900344901788', '20544508', '2098765853199', '5903895010169', '20503031', '5908257108836', '5903050791537', '5907599956204', '5903246561913', '5905118020511', '8429583014433')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'marinero', 'Grocery', 'Seafood & Fish', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'smoked', 'Biedronka', 'none', '5901576058059'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na zimno', 'smoked', 'Biedronka', 'none', '5906730621100'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '5903895631418'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'not-applicable', 'Biedronka', 'none', '5900344000337'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'smoked', 'Biedronka', 'none', '5903475460131'),
  ('PL', 'Komersmag', 'Grocery', 'Seafood & Fish', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'fried', 'Auchan', 'none', '5904468000228'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami', 'not-applicable', 'Biedronka', 'none', '5900344901825'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w oleju a''la Matjas', 'not-applicable', 'Tesco', 'none', '5900344016697'),
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Szprot wędzony na gorąco', 'smoked', 'Auchan', 'none', '5906395035717'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'not-applicable', 'Biedronka', 'none', '5900344901832'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki Śledzik w sosie śmietankowym', 'not-applicable', 'Biedronka', 'none', '5900344000375'),
  ('PL', 'Fischer King', 'Grocery', 'Seafood & Fish', 'Stek z łososia', 'not-applicable', 'Netto', 'none', '5901576050404'),
  ('PL', 'Dega', 'Grocery', 'Seafood & Fish', 'Ryba śledź po grecku', 'not-applicable', 'Lewiatan', 'none', '5900672012606'),
  ('PL', 'Kong Oskar', 'Grocery', 'Seafood & Fish', 'Tuńczyk w kawałkach w oleju roślinnym', 'not-applicable', 'Auchan', 'none', '5901489215273'),
  ('PL', 'Auchan', 'Grocery', 'Seafood & Fish', 'ŁOSOŚ PACYFICZNY DZIKI', 'smoked', 'Auchan', 'none', '5904215131335'),
  ('PL', 'GRAAL', 'Grocery', 'Seafood & Fish', 'Tuńczyk Mexicans z warzywami', 'not-applicable', null, 'none', '5903895632491'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe z cebulką', 'not-applicable', null, 'none', '5900344000429'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz w sosie grzybowym kurki', 'not-applicable', null, 'none', '5900344030129'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Śledź filety z suszonymi pomidorami', 'not-applicable', null, 'none', '5903496036971'),
  ('PL', 'Śledzie od serca', 'Grocery', 'Seafood & Fish', 'Śledzie po żydowsku', 'not-applicable', null, 'none', '5901576051876'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'smoked', null, 'none', '5906730601614'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'smoked', null, 'none', '5903475450132'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'not-applicable', null, 'none', '5900344992175'),
  ('PL', 'Pescadero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga', 'not-applicable', null, 'none', '5906395035953'),
  ('PL', 'Contimax', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe marynowane z cebulą', 'not-applicable', null, 'none', '5901576044724'),
  ('PL', 'Suempol Pan Łosoś', 'Grocery', 'Seafood & Fish', 'Łosoś Wędzony Plastrowany', 'smoked', null, 'none', '5906730601058'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'not-applicable', null, 'none', '5900344026597'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś łagodny', 'smoked', null, 'none', '5903475440133'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz Pikantny', 'not-applicable', null, 'none', '5900344902266'),
  ('PL', 'Baltica', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w sosie pomidorowym', 'not-applicable', null, 'none', '5901596471005'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', 'Biedronka', 'none', '5903895039009'),
  ('PL', 'MegaRyba', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', 'not-applicable', 'Auchan', 'none', '5903895080018'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marinated Herring in mushroom sauce', 'marinated', 'Auchan', 'none', '5900344009293'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Gniazda z łososia', 'not-applicable', null, 'none', '5906730601850'),
  ('PL', 'Koryb', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', null, 'none', '5902020533115'),
  ('PL', 'Port netto', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno', 'smoked', null, 'none', '5901529089642'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco', 'smoked', null, 'none', '5906730621155'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring single portion with onion', 'not-applicable', 'Biedronka', 'none', '5900344901818'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010237'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring Snack', 'not-applicable', null, 'none', '5900344901788'),
  ('PL', 'nautica', 'Grocery', 'Seafood & Fish', 'Śledzie Wiejskie', 'not-applicable', 'Lidl', 'none', '20544508'),
  ('PL', 'Well done', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', 'smoked', 'Stokrotka', 'none', '2098765853199'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', 'not-applicable', null, 'none', '5903895010169'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', 'not-applicable', 'Biedronka', 'none', '20503031'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Paluszki z fileta z dorsza', 'not-applicable', null, 'none', '5908257108836'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Sushi Nori', 'dried', null, 'none', '5903050791537'),
  ('PL', 'House Od Asia', 'Grocery', 'Seafood & Fish', 'Nori', 'not-applicable', null, 'none', '5907599956204'),
  ('PL', 'Purella', 'Grocery', 'Seafood & Fish', 'Chlorella detoks', 'dried', null, 'none', '5903246561913'),
  ('PL', 'Asia Flavours', 'Grocery', 'Seafood & Fish', 'Dried wakame', 'dried', null, 'none', '5905118020511'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', 'not-applicable', 'Biedronka', 'none', '8429583014433')
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
  and product_name not in ('Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'Łosoś wędzony na zimno', 'Tuńczyk kawałki w sosie własnym', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'Śledzik na raz z suszonymi pomidorami', 'Filety śledziowe w oleju a''la Matjas', 'Szprot wędzony na gorąco', 'Marynowane, krojone filety bez skórki ze śledzia atlantyckiego z ogórkiem konserwowym i czosnkiem w oleju rzepakowym.', 'Szybki Śledzik w sosie śmietankowym', 'Stek z łososia', 'Ryba śledź po grecku', 'Tuńczyk w kawałkach w oleju roślinnym', 'ŁOSOŚ PACYFICZNY DZIKI', 'Tuńczyk Mexicans z warzywami', 'Wiejskie filety śledziowe z cebulką', 'Śledzik na raz w sosie grzybowym kurki', 'Śledź filety z suszonymi pomidorami', 'Śledzie po żydowsku', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'Filety z pstrąga', 'Wiejskie filety śledziowe marynowane z cebulą', 'Łosoś Wędzony Plastrowany', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'Łosoś łagodny', 'Śledzik na raz Pikantny', 'Filety śledziowe w sosie pomidorowym', 'Filety z makreli w sosie pomidorowym', 'Szprot w sosie pomidorowym', 'Marinated Herring in mushroom sauce', 'Gniazda z łososia', 'Łosoś atlantycki', 'Łosoś atlantycki wędzony na zimno', 'Łosoś wędzony na gorąco', 'Herring single portion with onion', 'Filety z makreli w sosie pomidorowym', 'Herring Snack', 'Śledzie Wiejskie', 'Łosoś atlantycki', 'Szprot w sosie pomidorowym', 'Filety śledziowe a''la Matjas', 'Paluszki z fileta z dorsza', 'Sushi Nori', 'Nori', 'Chlorella detoks', 'Dried wakame', 'Tuńczyk kawałki w sosie własnym');

-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5901576058059', '5906730621100', '5903895631418', '5900344000337', '5903475460131', '5904468000228', '5900344901825', '5900344016697', '5903895632491', '5900344000429', '5900344030129', '5903496036971', '5901576051876', '5906730601614', '5903475450132', '5900344992175', '5906395035953', '5901576044724', '5906730601058', '5900344026597', '5903475440133', '5903895039009', '5903895080018', '5900344009293', '5906730601850', '5902020533115', '5901529089642', '5906730621155', '5900344901818', '5903895010237', '5900344901788', '20544508', '2098765853199', '5903895010169', '20503031')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'marinero', 'Grocery', 'Seafood & Fish', 'Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', null, 'Biedronka', 'none', '5901576058059'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na zimno', null, 'Biedronka', 'none', '5906730621100'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Tuńczyk kawałki w sosie własnym', null, 'Biedronka', 'none', '5903895631418'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', null, 'Biedronka', 'none', '5900344000337'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem z drewna bukowego', null, 'Biedronka', 'none', '5903475460131'),
  ('PL', 'Komersmag', 'Grocery', 'Seafood & Fish', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'fried', 'Auchan', 'none', '5904468000228'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami', null, 'Biedronka', 'none', '5900344901825'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Filety śledziowe w oleju a''la Matjas', null, 'Tesco', 'none', '5900344016697'),
  ('PL', 'GRAAL', 'Grocery', 'Seafood & Fish', 'Tuńczyk Mexicans z warzywami', null, null, 'none', '5903895632491'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe z cebulką', null, null, 'none', '5900344000429'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz w sosie grzybowym kurki', null, null, 'none', '5900344030129'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Śledź filety z suszonymi pomidorami', null, null, 'none', '5903496036971'),
  ('PL', 'Śledzie od serca', 'Grocery', 'Seafood & Fish', 'Śledzie po żydowsku', null, null, 'none', '5901576051876'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki, wędzony na zimno, plastrowany', null, null, 'none', '5906730601614'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco dymem drewna bukowego', null, null, 'none', '5903475450132'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', null, null, 'none', '5900344992175'),
  ('PL', 'Pescadero', 'Grocery', 'Seafood & Fish', 'Filety z pstrąga', null, null, 'none', '5906395035953'),
  ('PL', 'Contimax', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe marynowane z cebulą', null, null, 'none', '5901576044724'),
  ('PL', 'Suempol Pan Łosoś', 'Grocery', 'Seafood & Fish', 'Łosoś Wędzony Plastrowany', null, null, 'none', '5906730601058'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', null, null, 'none', '5900344026597'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Łosoś łagodny', null, null, 'none', '5903475440133'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', null, 'Biedronka', 'none', '5903895039009'),
  ('PL', 'MegaRyba', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', null, 'Auchan', 'none', '5903895080018'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marinated Herring in mushroom sauce', null, 'Auchan', 'none', '5900344009293'),
  ('PL', 'Suempol', 'Grocery', 'Seafood & Fish', 'Gniazda z łososia', null, null, 'none', '5906730601850'),
  ('PL', 'Koryb', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', null, null, 'none', '5902020533115'),
  ('PL', 'Port netto', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki wędzony na zimno', null, null, 'none', '5901529089642'),
  ('PL', 'Unknown', 'Grocery', 'Seafood & Fish', 'Łosoś wędzony na gorąco', null, null, 'none', '5906730621155'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring single portion with onion', null, 'Biedronka', 'none', '5900344901818'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', null, null, 'none', '5903895010237'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring Snack', null, null, 'none', '5900344901788'),
  ('PL', 'nautica', 'Grocery', 'Seafood & Fish', 'Śledzie Wiejskie', null, 'Lidl', 'none', '20544508'),
  ('PL', 'Well done', 'Grocery', 'Seafood & Fish', 'Łosoś atlantycki', null, 'Stokrotka', 'none', '2098765853199'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', null, null, 'none', '5903895010169'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety śledziowe a''la Matjas', null, 'Biedronka', 'none', '20503031')
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
  and product_name not in ('Pstrąg Tęczowy Łososiowy Wędzony Na Zimno', 'Łosoś wędzony na zimno', 'Tuńczyk kawałki w sosie własnym', 'Szybki śledzik w sosie czosnkowym z ziołami prowansalskimi', 'Łosoś wędzony na gorąco dymem z drewna bukowego', 'Filety śledziowe panierowane i smażone w zalewie octowej.', 'Śledzik na raz z suszonymi pomidorami', 'Filety śledziowe w oleju a''la Matjas', 'Tuńczyk Mexicans z warzywami', 'Wiejskie filety śledziowe z cebulką', 'Śledzik na raz w sosie grzybowym kurki', 'Śledź filety z suszonymi pomidorami', 'Śledzie po żydowsku', 'Łosoś atlantycki, wędzony na zimno, plastrowany', 'Łosoś wędzony na gorąco dymem drewna bukowego', 'Śledzik na raz z suszonymi pomidorami i ziołami włoskimi', 'Filety z pstrąga', 'Wiejskie filety śledziowe marynowane z cebulą', 'Łosoś Wędzony Plastrowany', 'Tuńczyk Stek Z Kropla Oliwy Z Oliwek', 'Łosoś łagodny', 'Filety z makreli w sosie pomidorowym', 'Szprot w sosie pomidorowym', 'Marinated Herring in mushroom sauce', 'Gniazda z łososia', 'Łosoś atlantycki', 'Łosoś atlantycki wędzony na zimno', 'Łosoś wędzony na gorąco', 'Herring single portion with onion', 'Filety z makreli w sosie pomidorowym', 'Herring Snack', 'Śledzie Wiejskie', 'Łosoś atlantycki', 'Szprot w sosie pomidorowym', 'Filety śledziowe a''la Matjas');

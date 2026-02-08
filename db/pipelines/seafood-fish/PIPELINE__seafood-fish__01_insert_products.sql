-- PIPELINE (Seafood & Fish): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Seafood & Fish'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Jantar', 'Grocery', 'Seafood & Fish', 'Szprot wędzony na gorąco', null, 'Auchan', 'none', '5906395035717'),
  ('PL', 'Dega', 'Grocery', 'Seafood & Fish', 'Ryba śledź po grecku', null, 'Lewiatan', 'none', '5900672012606'),
  ('PL', 'GRAAL', 'Grocery', 'Seafood & Fish', 'Tuńczyk Mexicans z warzywami', null, null, 'none', '5903895632491'),
  ('PL', 'Fisher King', 'Grocery', 'Seafood & Fish', 'Pstrąg łososiowy wędzony w plastrach', null, null, 'none', '5901576051616'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Wiejskie filety śledziowe z cebulką', null, null, 'none', '5900344000429'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Pastella - pasta z łososia', null, null, 'none', '5900344035278'),
  ('PL', 'Marinero', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', null, 'Biedronka', 'none', '5903895039009'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Marinated Herring in mushroom sauce', null, 'Auchan', 'none', '5900344009293'),
  ('PL', 'MegaRyba', 'Grocery', 'Seafood & Fish', 'Szprot w sosie pomidorowym', null, 'Auchan', 'none', '5903895080018'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring single portion with onion', null, 'Biedronka', 'none', '5900344901818'),
  ('PL', 'Graal', 'Grocery', 'Seafood & Fish', 'Filety z makreli w sosie pomidorowym', null, null, 'none', '5903895010237'),
  ('PL', 'nautica', 'Grocery', 'Seafood & Fish', 'Śledzie Wiejskie', null, 'Lidl', 'none', '20544508'),
  ('PL', 'Lisner', 'Grocery', 'Seafood & Fish', 'Herring Snack', null, null, 'none', '5900344901788'),
  ('PL', 'K-Classic', 'Grocery', 'Seafood & Fish', 'Pstrąg tęczowy, wędzony na zimno w plastrach', null, 'Kaufland', 'none', '4063367018657'),
  ('PL', 'Carrefour Discount', 'Grocery', 'Seafood & Fish', 'Bâtonnets saveur crabe', null, 'Carrefour,carrefour.fr', 'none', '3560071099251'),
  ('PL', 'ocean sea', 'Grocery', 'Seafood & Fish', 'Paluszki surimi', null, 'lidl', 'none', '4056489025115'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Queues de crevettes CRUES', null, 'Carrefour,carrefour.fr', 'none', '3560070422067'),
  ('PL', 'Carrefour', 'Grocery', 'Seafood & Fish', 'Crevettes sauvages décortiquées cuites', null, 'Carrefour,carrefour.fr', 'none', '3560071013493'),
  ('PL', 'Vici', 'Grocery', 'Seafood & Fish', 'Classic surimi sticks', null, null, 'none', '4770190041980'),
  ('PL', 'Rio Mare', 'Grocery', 'Seafood & Fish', 'Insalatissime Sicily Edition', null, null, 'none', '8004030476004')
on conflict (country, brand, product_name) do update set
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
  and product_name not in ('Szprot wędzony na gorąco', 'Ryba śledź po grecku', 'Tuńczyk Mexicans z warzywami', 'Pstrąg łososiowy wędzony w plastrach', 'Wiejskie filety śledziowe z cebulką', 'Pastella - pasta z łososia', 'Filety z makreli w sosie pomidorowym', 'Marinated Herring in mushroom sauce', 'Szprot w sosie pomidorowym', 'Herring single portion with onion', 'Filety z makreli w sosie pomidorowym', 'Śledzie Wiejskie', 'Herring Snack', 'Pstrąg tęczowy, wędzony na zimno w plastrach', 'Bâtonnets saveur crabe', 'Paluszki surimi', 'Queues de crevettes CRUES', 'Crevettes sauvages décortiquées cuites', 'Classic surimi sticks', 'Insalatissime Sicily Edition');

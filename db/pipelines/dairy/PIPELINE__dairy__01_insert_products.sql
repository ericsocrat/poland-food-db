-- PIPELINE (Dairy): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Dairy'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900531000508', '5900820000011', '5900531004018', '5902409703887', '5900820009854', '5900120005136', '5900531004704', '5904903000677', '5900531001130', '5901753000628', '5901939000770', '5900512850023', '5902899101651', '5900820012229', '5900820021955', '5902208001252', '5906040063225', '5900691031114', '5900531000300', '5901939006048', '5900691031329', '5901939006017', '5900197023842', '5902899141688', '5902057001748', '5900512320359', '5900531004537', '5901939103068', '5901939103099', '5901939103075', '5908312380078', '5900531004544', '5900531001031', '5906040063515', '5900820000042', '5902899117225', '5900512320625', '5902208000811', '5900120010277', '5900512300320', '5900531004735', '5900512700014', '5902899104652', '5900512320335', '5900512320618', '5900531011023', '5900512350080', '5900120072480', '5907180315847', '5900120011199')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twój Smak Serek śmietankowy', 'fermented', 'Żabka', 'none', '5900531000508'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Łaciate 3,2%', 'pasteurized', 'Carrefour', 'none', '5900820000011'),
  ('PL', 'PIĄTNICA', 'Grocery', 'Dairy', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 'fermented', 'Carrefour', 'none', '5900531004018'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'fermented', 'Biedronka', 'none', '5902409703887'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko Świeże 2,0%', 'not-applicable', 'Biedronka', 'none', '5900820009854'),
  ('PL', 'Biedronka', 'Grocery', 'Dairy', 'Kefir naturalny 1,5 % tłuszczu', 'fermented', 'Biedronka', 'none', '5900120005136'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr z mango i marakują', 'fermented', 'Kaufland', 'none', '5900531004704'),
  ('PL', 'Wieluń', 'Grocery', 'Dairy', 'twarożek &quot;Mój ulubiony&quot;', 'fermented', 'Auchan', 'none', '5904903000677'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Śmietana 18%', 'fermented', null, 'none', '5900531001130'),
  ('PL', 'Sierpc', 'Grocery', 'Dairy', 'Ser królewski', 'fermented', null, 'none', '5901753000628'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Mleko wieskie świeże 2%', 'not-applicable', null, 'none', '5901939000770'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko Polskie SPOŻYWCZE', 'not-applicable', null, 'none', '5900512850023'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Serek Almette z ziołami', 'fermented', null, 'none', '5902899101651'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Świeże mleko', 'not-applicable', null, 'none', '5900820012229'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Twarożek grani klasyczny', 'fermented', null, 'none', '5900820021955'),
  ('PL', 'Ryki', 'Grocery', 'Dairy', 'ser żółty Active Protein Plus', 'fermented', null, 'none', '5902208001252'),
  ('PL', 'Zott', 'Grocery', 'Dairy', 'Primo śmietanka 30%', 'fermented', null, 'none', '5906040063225'),
  ('PL', 'Gostyńskie', 'Grocery', 'Dairy', 'Mleko zagęszczone słodzone', 'not-applicable', null, 'none', '5900691031114'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twarożek Domowy grani naturalny', 'fermented', null, 'none', '5900531000300'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'koktajl spożywczy', 'fermented', null, 'none', '5901939006048'),
  ('PL', 'SM Gostyń', 'Grocery', 'Dairy', 'Kajmak masa krówkowa gostyńska', 'fermented', null, 'none', '5900691031329'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Koktail Białkowy malina & granat', 'fermented', null, 'none', '5901939006017'),
  ('PL', 'Bakoma', 'Grocery', 'Dairy', 'Jogurt kremowy z malinami i granolą', 'fermented', null, 'none', '5900197023842'),
  ('PL', 'Hochland', 'Grocery', 'Dairy', 'Ser żółty w plastrach Gouda', 'fermented', null, 'none', '5902899141688'),
  ('PL', 'Krasnystaw', 'Grocery', 'Dairy', 'kefir', 'fermented', 'Biedronka', 'none', '5902057001748'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko WYPASIONE 3,2%', 'not-applicable', 'Tesco', 'none', '5900512320359'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt typu islandzkiego waniliowy', 'fermented', 'Lidl', 'none', '5900531004537'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'fermented', 'Kaufland', 'none', '5901939103068'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'fermented', 'Auchan', 'none', '5901939103099'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr Wanilia', 'fermented', 'Kaufland', 'none', '5901939103075'),
  ('PL', 'Robico', 'Grocery', 'Dairy', 'Kefir Robcio', 'fermented', null, 'none', '5908312380078'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr Naturalny', 'fermented', 'Lidl', 'none', '5900531004544'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Soured cream 18%', 'fermented', 'Biedronka', 'none', '5900531001031'),
  ('PL', 'Zott', 'Grocery', 'Dairy', 'Jogurt naturalny', 'fermented', 'Auchan', 'none', '5906040063515'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Mleko UHT 2%', 'pasteurized', 'Tesco', 'none', '5900820000042'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Puszysty Serek Jogurtowy', 'fermented', 'Kaufland', 'none', '5902899117225'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'mleko UHT 3,2%', 'pasteurized', 'Biedronka', 'none', '5900512320625'),
  ('PL', 'Spółdzielnia Mleczarska Ryki', 'Grocery', 'Dairy', 'Ser Rycki Edam kl.I', 'fermented', 'Auchan', 'none', '5902208000811'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko 1,5% bez laktozy', 'pasteurized', 'Biedronka', 'none', '5900120010277'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', '.', 'pasteurized', 'Dino', 'none', '5900512300320'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Icelandic type yoghurt natural', 'fermented', 'Kaufland', 'none', '5900531004735'),
  ('PL', 'Favita', 'Grocery', 'Dairy', 'Favita', 'fermented', 'Lidl', 'none', '5900512700014'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Almette z chrzanem', 'fermented', 'Auchan', 'none', '5902899104652'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko 2%', 'not-applicable', 'Żabka', 'none', '5900512320335'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko 1,5%', 'pasteurized', 'Biedronka', 'none', '5900512320618'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Serek homogenizowany truskawkowy', 'fermented', 'Lidl', 'none', '5900531011023'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Jogurt Grecki naturalny', 'fermented', 'Kaufland', 'none', '5900512350080'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Delikate Serek Smetankowy', 'fermented', 'Biedronka', 'none', '5900120072480'),
  ('PL', 'Mleczna dolina', 'Grocery', 'Dairy', 'Śmietana', 'fermented', null, 'none', '5907180315847'),
  ('PL', 'OSM Łowicz', 'Grocery', 'Dairy', 'Mleko UHT 3,2', 'pasteurized', 'Tesco', 'none', '5900120011199')
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
where country = 'PL' and category = 'Dairy'
  and is_deprecated is not true
  and product_name not in ('Twój Smak Serek śmietankowy', 'Łaciate 3,2%', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'Mleko Świeże 2,0%', 'Kefir naturalny 1,5 % tłuszczu', 'Skyr z mango i marakują', 'twarożek &quot;Mój ulubiony&quot;', 'Śmietana 18%', 'Ser królewski', 'Mleko wieskie świeże 2%', 'Mleko Polskie SPOŻYWCZE', 'Serek Almette z ziołami', 'Świeże mleko', 'Twarożek grani klasyczny', 'ser żółty Active Protein Plus', 'Primo śmietanka 30%', 'Mleko zagęszczone słodzone', 'Twarożek Domowy grani naturalny', 'koktajl spożywczy', 'Kajmak masa krówkowa gostyńska', 'Koktail Białkowy malina & granat', 'Jogurt kremowy z malinami i granolą', 'Ser żółty w plastrach Gouda', 'kefir', 'Mleko WYPASIONE 3,2%', 'Skyr jogurt typu islandzkiego waniliowy', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'Skyr Wanilia', 'Kefir Robcio', 'Skyr Naturalny', 'Soured cream 18%', 'Jogurt naturalny', 'Mleko UHT 2%', 'Puszysty Serek Jogurtowy', 'mleko UHT 3,2%', 'Ser Rycki Edam kl.I', 'Mleko 1,5% bez laktozy', '.', 'Icelandic type yoghurt natural', 'Favita', 'Almette z chrzanem', 'Mleko 2%', 'Mleko 1,5%', 'Serek homogenizowany truskawkowy', 'Jogurt Grecki naturalny', 'Delikate Serek Smetankowy', 'Śmietana', 'Mleko UHT 3,2');

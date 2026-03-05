-- PIPELINE (Dairy): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Dairy'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900820000011', '5900531000508', '5900531004018', '5902409703887', '5900531004704', '5901939103402', '5902495002055', '5900820009854', '5900512700090', '5900531004049', '5902899143873', '5900820021962', '5900120005136', '5903111943240', '5900820005528', '5907627471532', '5900512988016', '5900531105036', '5907809286084', '5904903000677', '5900820011512', '5903767007488', '5900820000554', '5900512501680', '5900120072251', '5900531001130', '5901939000770', '5900512850023', '5900820012229', '5901753000628', '5902899101651', '5900820001506', '5907180352682', '5906040063225', '5901939006048', '5900197028298', '5902899143835', '5900531000300', '5900197002595', '5900643047385', '5900531001079', '5901005007269', '5900197027901', '5901939006017', '5900820000158', '5900197023842', '5901753000642', '5900691031329', '5900820021955', '5902409703047', '5902899141701', '5900512983677', '5900120072879', '5900691031114', '5900531009655', '5900120022553', '5900120072817', '5900531003370', '5902057001748', '5900531001031', '5901939103068', '5901939103075', '5901939103099', '5900531004735', '5900531004537', '5900512320359', '5903767002971', '5900512350080', '5906040063515', '5902899117225', '5900531011023', '5900120010970', '5900531004544', '5908312380078', '5900512320625', '5900512320335', '5900512300320', '5900120011199', '5900120010277', '5900512981178', '5900001421611', '5902208000811', '5900512984513', '5904716013277', '5900820005504', '5903767003459', '5900120072480', '5900512110394', '5903767003176', '5902057005623', '5900512700014', '5902899104652', '5900820022280', '5908275688587', '5907180315847')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Mleko łaciate 3.2%', 'pasteurized', 'Carrefour', 'none', '5900820000011'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twój Smak Serek śmietankowy', 'fermented', 'Żabka', 'none', '5900531000508'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twaróg Wiejski Półtłusty', 'fermented', 'Carrefour', 'none', '5900531004018'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'fermented', 'Biedronka', 'none', '5902409703887'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr z mango i marakują', 'fermented', 'Kaufland', 'none', '5900531004704'),
  ('PL', 'Piatnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'fermented', 'Kaufland', 'none', '5901939103402'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Serek Wiejski Wysokobiałkowy', 'fermented', 'Biedronka', 'none', '5902495002055'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko Świeże 2,0%', 'not-applicable', 'Biedronka', 'none', '5900820009854'),
  ('PL', 'Tolonis', 'Grocery', 'Dairy', 'Ser sałatkowo-kanapkowy półtłusty', 'fermented', 'Biedronka', 'none', '5900512700090'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twaróg wiejski', 'fermented', 'Carrefour', 'none', '5900531004049'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Serek twarogowy z ziołami', 'fermented', 'Kaufland', 'none', '5902899143873'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Twaróg Klinek (Chudy)', 'fermented', 'Biedronka', 'none', '5900820021962'),
  ('PL', 'Biedronka', 'Grocery', 'Dairy', 'Kefir naturalny 1,5 % tłuszczu', 'fermented', 'Biedronka', 'none', '5900120005136'),
  ('PL', 'Tutti', 'Grocery', 'Dairy', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'not-applicable', 'Biedronka', 'none', '5903111943240'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Królewski z Kolna - ser w plastrach', 'fermented', 'Tesco', 'none', '5900820005528'),
  ('PL', 'Euroser', 'Grocery', 'Dairy', 'Holenderski ser kozi półtwardy ser podpuszczkowy z mleka koziego, w plastrach.', 'fermented', 'Auchan', 'none', '5907627471532'),
  ('PL', 'Pilos', 'Grocery', 'Dairy', 'Mleko spożywcze 3,2%', 'not-applicable', 'Lidl', 'none', '5900512988016'),
  ('PL', 'Piatnica', 'Grocery', 'Dairy', 'Twaróg Półtłusty', 'fermented', 'Lidl', 'none', '5900531105036'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Capreggio serek typu włoskiego', 'fermented', 'Biedronka', 'none', '5907809286084'),
  ('PL', 'Wieluń', 'Grocery', 'Dairy', 'Twarożek &quot;Mój ulubiony&quot;', 'fermented', 'Auchan', 'none', '5904903000677'),
  ('PL', 'Łaciaty', 'Grocery', 'Dairy', 'Serek śmietankowy z cebulą i szczypiorkiem', 'fermented', 'Żabka', 'none', '5900820011512'),
  ('PL', 'Jovi', 'Grocery', 'Dairy', 'Napój jogurtowy Duet Banan-Truskawka', 'fermented', 'Biedronka', 'none', '5903767007488'),
  ('PL', 'Łaciate', 'Grocery', 'Dairy', 'Łaciate mleko', 'dried', 'Biedronka', 'none', '5900820000554'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Twaróg klinek chudy', 'fermented', 'Biedronka', 'none', '5900512501680'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Twaróg chudy', 'fermented', 'Biedronka', 'none', '5900120072251'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Śmietana 18%', 'fermented', null, 'none', '5900531001130'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Mleko wieskie świeże 2%', 'not-applicable', null, 'none', '5901939000770'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko Polskie SPOŻYWCZE', 'not-applicable', null, 'none', '5900512850023'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Świeże mleko', 'not-applicable', null, 'none', '5900820012229'),
  ('PL', 'Sierpc', 'Grocery', 'Dairy', 'Ser królewski', 'fermented', null, 'none', '5901753000628'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Serek Almette z ziołami', 'fermented', null, 'none', '5902899101651'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Maślanka Mrągowska', 'fermented', null, 'none', '5900820001506'),
  ('PL', 'Gustobello', 'Grocery', 'Dairy', 'Grana Padano Wiórki', 'fermented', null, 'none', '5907180352682'),
  ('PL', 'Zott', 'Grocery', 'Dairy', 'Primo śmietanka 30%', 'fermented', null, 'none', '5906040063225'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Koktajl spożywczy', 'fermented', null, 'none', '5901939006048'),
  ('PL', 'Bakoma', 'Grocery', 'Dairy', 'Jogurt naturalny gęsty', 'fermented', null, 'none', '5900197028298'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Almette śmietankowy bez laktozy', 'fermented', null, 'none', '5902899143835'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twarożek Domowy grani naturalny', 'fermented', null, 'none', '5900531000300'),
  ('PL', 'Bakoma', 'Grocery', 'Dairy', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'fermented', null, 'none', '5900197002595'),
  ('PL', 'Fantasia', 'Grocery', 'Dairy', 'Fantasia z płatkami w czekoladzie', 'fermented', null, 'none', '5900643047385'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Śmietanka 30%', 'fermented', null, 'none', '5900531001079'),
  ('PL', 'Włoszczowa', 'Grocery', 'Dairy', 'Ser Włoszczowski typu szwajcarskiego', 'fermented', null, 'none', '5901005007269'),
  ('PL', 'Fruvita (Bakoma)', 'Grocery', 'Dairy', 'Jogurt Wiśniowy', 'fermented', null, 'none', '5900197027901'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Koktail Białkowy malina & granat', 'fermented', null, 'none', '5901939006017'),
  ('PL', 'Łaciate', 'Grocery', 'Dairy', 'Łaciate Uht Milk 2.0% Fat 0.5 L', 'pasteurized', null, 'none', '5900820000158'),
  ('PL', 'Bakoma', 'Grocery', 'Dairy', 'Jogurt kremowy z malinami i granolą', 'fermented', null, 'none', '5900197023842'),
  ('PL', 'Sierpc', 'Grocery', 'Dairy', 'Ser Królewski Light', 'fermented', null, 'none', '5901753000642'),
  ('PL', 'SM Gostyń', 'Grocery', 'Dairy', 'Kajmak masa krówkowa gostyńska', 'fermented', null, 'none', '5900691031329'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Twarożek grani klasyczny', 'fermented', null, 'none', '5900820021955'),
  ('PL', 'Tutti', 'Grocery', 'Dairy', 'Serek Tutti Prosty Skład', 'fermented', null, 'none', '5902409703047'),
  ('PL', 'Hochland', 'Grocery', 'Dairy', 'Ser kremowy ze śmietanką', 'fermented', null, 'none', '5902899141701'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Ser Cheddar wiórki', 'fermented', null, 'none', '5900512983677'),
  ('PL', 'Pilos', 'Grocery', 'Dairy', 'Serek śmietankowy ze szczypiorkiem', 'fermented', null, 'none', '5900120072879'),
  ('PL', 'Gostyńskie', 'Grocery', 'Dairy', 'Mleko zagęszczone słodzone', 'not-applicable', null, 'none', '5900691031114'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Serek śmietanowy klasyczny', 'fermented', null, 'none', '5900531009655'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Śmietanka UHT', 'pasteurized', null, 'none', '5900120022553'),
  ('PL', 'Pilos', 'Grocery', 'Dairy', 'Serek śmietankowy', 'fermented', null, 'none', '5900120072817'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt wysokobiałkowy low carb waniliowy', 'fermented', null, 'none', '5900531003370'),
  ('PL', 'Krasnystaw', 'Grocery', 'Dairy', 'Kefir', 'fermented', 'Biedronka', 'none', '5902057001748'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Soured cream 18%', 'fermented', 'Biedronka', 'none', '5900531001031'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'fermented', 'Kaufland', 'none', '5901939103068'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr Wanilia', 'fermented', 'Kaufland', 'none', '5901939103075'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'fermented', 'Auchan', 'none', '5901939103099'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Icelandic type yoghurt natural', 'fermented', 'Kaufland', 'none', '5900531004735'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt typu islandzkiego waniliowy', 'fermented', 'Lidl', 'none', '5900531004537'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko WYPASIONE 3,2%', 'not-applicable', 'Tesco', 'none', '5900512320359'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt Naturalny Kremowy', 'fermented', 'Biedronka', 'none', '5903767002971'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Jogurt Grecki naturalny', 'fermented', 'Kaufland', 'none', '5900512350080'),
  ('PL', 'Zott', 'Grocery', 'Dairy', 'Jogurt naturalny', 'fermented', 'Auchan', 'none', '5906040063515'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Puszysty Serek Jogurtowy', 'fermented', 'Kaufland', 'none', '5902899117225'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Serek homogenizowany truskawkowy', 'fermented', 'Lidl', 'none', '5900531011023'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Milk Lactose free 3.2% UHT', 'pasteurized', 'Biedronka', 'none', '5900120010970'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr Naturalny', 'fermented', 'Lidl', 'none', '5900531004544'),
  ('PL', 'Robico', 'Grocery', 'Dairy', 'Kefir Robcio', 'fermented', null, 'none', '5908312380078'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko UHT 3,2%', 'pasteurized', 'Biedronka', 'none', '5900512320625'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko 2%', 'not-applicable', 'Żabka', 'none', '5900512320335'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', '.', 'pasteurized', 'Dino', 'none', '5900512300320'),
  ('PL', 'OSM Łowicz', 'Grocery', 'Dairy', 'Mleko UHT 3,2', 'pasteurized', 'Tesco', 'none', '5900120011199'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Mleko 1,5% bez laktozy', 'pasteurized', 'Biedronka', 'none', '5900120010277'),
  ('PL', 'Flavita', 'Grocery', 'Dairy', 'Lactose Free Milk', 'not-applicable', 'Auchan', 'none', '5900512981178'),
  ('PL', 'Unknown', 'Grocery', 'Dairy', 'Roslinne Nie Mleko', 'not-applicable', 'Biedronka', 'none', '5900001421611'),
  ('PL', 'Spółdzielnia Mleczarska Ryki', 'Grocery', 'Dairy', 'Ser Rycki Edam kl.I', 'fermented', 'Auchan', 'none', '5902208000811'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Ser Rycerski z dziurami dojrzewajacy', 'fermented', 'Biedronka', 'none', '5900512984513'),
  ('PL', 'Światowid', 'Grocery', 'Dairy', 'Ser topiony tostowy', 'fermented', 'Biedronka', 'none', '5904716013277'),
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Ser Gouda w plastrach', 'fermented', 'Kaufland', 'none', '5900820005504'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt jagodowy', 'fermented', 'Biedronka', 'none', '5903767003459'),
  ('PL', 'Delikate', 'Grocery', 'Dairy', 'Delikate Serek Smetankowy', 'fermented', 'Biedronka', 'none', '5900120072480'),
  ('PL', 'Światowid', 'Grocery', 'Dairy', 'Gouda', 'fermented', 'Biedronka', 'none', '5900512110394'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Skyr Pitny Wanilia', 'fermented', 'Biedronka', 'none', '5903767003176'),
  ('PL', 'Go Active', 'Grocery', 'Dairy', 'Kefir Proteinowy', 'fermented', 'Biedronka', 'none', '5902057005623'),
  ('PL', 'Favita', 'Grocery', 'Dairy', 'Favita', 'fermented', 'Lidl', 'none', '5900512700014'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Almette z chrzanem', 'fermented', 'Auchan', 'none', '5902899104652'),
  ('PL', 'Pilos', 'Grocery', 'Dairy', 'Serek Wiejski Lekki', 'fermented', 'Lidl', 'none', '5900820022280'),
  ('PL', 'Président', 'Grocery', 'Dairy', 'Twarog sernikowy', 'fermented', 'Kaufland', 'none', '5908275688587'),
  ('PL', 'Mleczna dolina', 'Grocery', 'Dairy', 'Śmietana', 'fermented', null, 'none', '5907180315847')
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
  and product_name not in ('Mleko łaciate 3.2%', 'Twój Smak Serek śmietankowy', 'Twaróg Wiejski Półtłusty', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'Skyr z mango i marakują', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'Serek Wiejski Wysokobiałkowy', 'Mleko Świeże 2,0%', 'Ser sałatkowo-kanapkowy półtłusty', 'Twaróg wiejski', 'Serek twarogowy z ziołami', 'Twaróg Klinek (Chudy)', 'Kefir naturalny 1,5 % tłuszczu', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'Królewski z Kolna - ser w plastrach', 'Holenderski ser kozi półtwardy ser podpuszczkowy z mleka koziego, w plastrach.', 'Mleko spożywcze 3,2%', 'Twaróg Półtłusty', 'Capreggio serek typu włoskiego', 'Twarożek &quot;Mój ulubiony&quot;', 'Serek śmietankowy z cebulą i szczypiorkiem', 'Napój jogurtowy Duet Banan-Truskawka', 'Łaciate mleko', 'Twaróg klinek chudy', 'Twaróg chudy', 'Śmietana 18%', 'Mleko wieskie świeże 2%', 'Mleko Polskie SPOŻYWCZE', 'Świeże mleko', 'Ser królewski', 'Serek Almette z ziołami', 'Maślanka Mrągowska', 'Grana Padano Wiórki', 'Primo śmietanka 30%', 'Koktajl spożywczy', 'Jogurt naturalny gęsty', 'Almette śmietankowy bez laktozy', 'Twarożek Domowy grani naturalny', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'Fantasia z płatkami w czekoladzie', 'Śmietanka 30%', 'Ser Włoszczowski typu szwajcarskiego', 'Jogurt Wiśniowy', 'Koktail Białkowy malina & granat', 'Łaciate Uht Milk 2.0% Fat 0.5 L', 'Jogurt kremowy z malinami i granolą', 'Ser Królewski Light', 'Kajmak masa krówkowa gostyńska', 'Twarożek grani klasyczny', 'Serek Tutti Prosty Skład', 'Ser kremowy ze śmietanką', 'Ser Cheddar wiórki', 'Serek śmietankowy ze szczypiorkiem', 'Mleko zagęszczone słodzone', 'Serek śmietanowy klasyczny', 'Śmietanka UHT', 'Serek śmietankowy', 'Jogurt wysokobiałkowy low carb waniliowy', 'Kefir', 'Soured cream 18%', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Skyr Wanilia', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'Icelandic type yoghurt natural', 'Skyr jogurt typu islandzkiego waniliowy', 'Mleko WYPASIONE 3,2%', 'Jogurt Naturalny Kremowy', 'Jogurt Grecki naturalny', 'Jogurt naturalny', 'Puszysty Serek Jogurtowy', 'Serek homogenizowany truskawkowy', 'Milk Lactose free 3.2% UHT', 'Skyr Naturalny', 'Kefir Robcio', 'Mleko UHT 3,2%', 'Mleko 2%', '.', 'Mleko UHT 3,2', 'Mleko 1,5% bez laktozy', 'Lactose Free Milk', 'Roslinne Nie Mleko', 'Ser Rycki Edam kl.I', 'Ser Rycerski z dziurami dojrzewajacy', 'Ser topiony tostowy', 'Ser Gouda w plastrach', 'Jogurt jagodowy', 'Delikate Serek Smetankowy', 'Gouda', 'Skyr Pitny Wanilia', 'Kefir Proteinowy', 'Favita', 'Almette z chrzanem', 'Serek Wiejski Lekki', 'Twarog sernikowy', 'Śmietana');

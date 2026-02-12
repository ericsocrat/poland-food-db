-- PIPELINE (Sauces): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Sauces'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900783003616', '5900397732889', '5901713005441', '5901713004642', '5901713003928', '5901713003904', '5901713003911', '5901986081326', '5901619150399', '5901044020434', '5900783009885', '5900783008567', '5900854002913', '5900397016590', '5906716208240', '5901713011695', '5901044030532', '5900783009717', '5900854003187', '5904378243708', '5901882210394', '5906716207373', '5906716207359', '5901713009135', '5901619150436', '5901713012227', '5905784348506', '5900397735897', '5906425142958', '5901044024647', '5906425143702', '5906425143719', '5901882210226', '5906425141944', '5901713012210', '5901044023084', '5900397016255', '5900783003609', '5900397016224', '5901713016270', '5900783002138', '5900397749252', '5901044030488', '5901844100473', '5906716204679', '5901044019650', '5900919015063', '5907544131847', '5902166728161', '5901044030525', '5901044030549', '5900397756625', '5900783008758', '5904378642754', '5907544131052', '5901135000949', '5906425142835', '5901044024661', '8714100855171', '5906425141760', '5907501005105', '5902898823332', '5901801581116', '5901752703346', '5901044023060', '5901044022223', '5901044028737', '5900385502241', '5906716206253', '5902256006827', '7613037091380', '8001060025837', '3856020242442', '5902166745861', '5901713021724', '4823097405420', '5902693180593', '5901044022254', '5901619925546', '5906425143856', '8715700209890', '7613038848167', '5901044022216', '20164041', '8005110519000', '8005476006220', '4316268604062', '4056489447160', '2098765745579', '3560071357733', '20069490', '8076809513753', '3245413808196', '8015559000915', '4056489204183', '8410066120017', '20026752', '8715035110809', '80042563', '8002920016606')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Pudliszki', 'Grocery', 'Sauces', 'Po Bolońsku sos do spaghetti', 'not-applicable', 'Biedronka', 'none', '5900783003616'),
  ('PL', 'Culineo', 'Grocery', 'Sauces', 'Sos meksykański', 'not-applicable', 'Biedronka', 'none', '5900397732889'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos do spaghetti pomidorowo-śmietankowy', 'not-applicable', 'Kaufland', 'none', '5901713005441'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos Neapolitański z papryką', 'not-applicable', 'Auchan', 'none', '5901713004642'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos Boloński z ziołami', 'not-applicable', 'Kaufland', 'none', '5901713003928'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos meksykański', 'not-applicable', 'Kaufland', 'none', '5901713003904'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos słodko-kwaśny z ananasem', 'not-applicable', 'Kaufland', 'none', '5901713003911'),
  ('PL', 'Polskie Przetwory', 'Grocery', 'Sauces', 'Sos Boloński z bazylią', 'not-applicable', 'Lewiatan', 'none', '5901986081326'),
  ('PL', 'Międzychód', 'Grocery', 'Sauces', 'Sos Boloński z mięsem', 'not-applicable', 'Lewiatan', 'none', '5901619150399'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos tysiąca wysp', 'not-applicable', 'Kaufland', 'none', '5901044020434'),
  ('PL', 'Heinz', 'Grocery', 'Sauces', 'Sos tysiąca wysp', 'not-applicable', 'Biedronka', 'none', '5900783009885'),
  ('PL', 'Heinz', 'Grocery', 'Sauces', 'Sos Barbecue. Sos do grilla z cebulą i papryką', 'not-applicable', 'Biedronka', 'none', '5900783008567'),
  ('PL', 'Fanex', 'Grocery', 'Sauces', 'Sos meksykański', 'not-applicable', null, 'none', '5900854002913'),
  ('PL', 'Łowicz', 'Grocery', 'Sauces', 'Sos Boloński', 'not-applicable', null, 'none', '5900397016590'),
  ('PL', 'Culineo', 'Grocery', 'Sauces', 'Sos boloński', 'not-applicable', null, 'none', '5906716208240'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos do pizzy z ziołami', 'not-applicable', null, 'none', '5901713011695'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos pomidor + miód + limonka + nasiona chia', 'not-applicable', null, 'none', '5901044030532'),
  ('PL', 'Pudliszki', 'Grocery', 'Sauces', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', 'not-applicable', null, 'none', '5900783009717'),
  ('PL', 'Fanex', 'Grocery', 'Sauces', 'Sos tysiąc wysp', 'not-applicable', null, 'none', '5900854003187'),
  ('PL', 'Vital FRESH', 'Grocery', 'Sauces', 'Sałatka w stylu greckim', 'not-applicable', null, 'none', '5904378243708'),
  ('PL', 'Vifon', 'Grocery', 'Sauces', 'Sos chili tajski słodko-pikantny', 'not-applicable', null, 'none', '5901882210394'),
  ('PL', 'Sottile Gusto', 'Grocery', 'Sauces', 'Passata z czosnkiem', 'not-applicable', 'Biedronka', 'none', '5906716207373'),
  ('PL', 'Sottile Gusto', 'Grocery', 'Sauces', 'Passata', 'not-applicable', 'Biedronka', 'none', '5906716207359'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos Pomidorowy do Makaronu', 'not-applicable', 'Kaufland', 'none', '5901713009135'),
  ('PL', 'Międzychód', 'Grocery', 'Sauces', 'Sos pomidorowy', 'not-applicable', 'Lewiatan', 'none', '5901619150436'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos Curry', 'not-applicable', 'Kaufland', 'none', '5901713012227'),
  ('PL', 'Carrefour', 'Grocery', 'Sauces', 'Przecier pomidorowy', 'not-applicable', 'Carrefour', 'none', '5905784348506'),
  ('PL', 'Culineo', 'Grocery', 'Sauces', 'SOS Spaghetti', 'not-applicable', 'Biedronka', 'none', '5900397735897'),
  ('PL', 'Develey', 'Grocery', 'Sauces', 'Sos 1000 wysp', 'not-applicable', 'Biedronka', 'none', '5906425142958'),
  ('PL', 'Madero', 'Grocery', 'Sauces', 'Sos jogurtowy z ziołami', 'not-applicable', null, 'none', '5901044024647'),
  ('PL', 'Go Vege', 'Grocery', 'Sauces', 'Sos z jalapeño', 'not-applicable', 'Biedronka', 'none', '5906425143702'),
  ('PL', 'Biedronka', 'Grocery', 'Sauces', 'Sos z chili', 'not-applicable', 'Biedronka', 'none', '5906425143719'),
  ('PL', 'Vifon', 'Grocery', 'Sauces', 'Sos chili pikantny', 'not-applicable', 'Auchan', 'none', '5901882210226'),
  ('PL', 'Develey', 'Grocery', 'Sauces', 'Sos jalapeño', 'not-applicable', 'Biedronka', 'none', '5906425141944'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos BBQ', 'not-applicable', 'Kaufland', 'none', '5901713012210'),
  ('PL', 'Madero', 'Grocery', 'Sauces', 'Sos BBQ z chipotle', 'not-applicable', 'Biedronka', 'none', '5901044023084'),
  ('PL', 'Łowicz', 'Grocery', 'Sauces', 'Sos Spaghetti', 'not-applicable', null, 'none', '5900397016255'),
  ('PL', 'Pudliszki', 'Grocery', 'Sauces', 'Sos Do Spaghetti Oryginalny', 'not-applicable', null, 'none', '5900783003609'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Passata rustica', 'not-applicable', null, 'none', '5901713016270'),
  ('PL', 'Pudliszki', 'Grocery', 'Sauces', 'Przecier pomidorowy', 'not-applicable', null, 'none', '5900783002138'),
  ('PL', 'Łowicz', 'Grocery', 'Sauces', 'Leczo', 'not-applicable', null, 'none', '5900397749252'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Avocaboo', 'not-applicable', null, 'none', '5901044030488'),
  ('PL', 'Sottile Gusto', 'Grocery', 'Sauces', 'Przecier pomidorowy', 'not-applicable', null, 'none', '5901844100473'),
  ('PL', 'Jamar', 'Grocery', 'Sauces', 'Passata - przecier pomidorowy klasyczny', 'not-applicable', null, 'none', '5906716204679'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos do kurczaka z czosnkiem', 'not-applicable', null, 'none', '5901044019650'),
  ('PL', 'Rolnik', 'Grocery', 'Sauces', 'Passata', 'not-applicable', null, 'none', '5900919015063'),
  ('PL', 'GustoBello', 'Grocery', 'Sauces', 'Arrabbiata Bruschetta', 'not-applicable', null, 'none', '5907544131847'),
  ('PL', 'Helcom', 'Grocery', 'Sauces', 'Dip in mexicana style', 'not-applicable', null, 'none', '5902166728161'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos pomidor + czarnuszka ostry', 'not-applicable', null, 'none', '5901044030525'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos pomidor + jagody goji', 'not-applicable', null, 'none', '5901044030549'),
  ('PL', 'MW Food', 'Grocery', 'Sauces', 'Sauce tomate', 'not-applicable', null, 'none', '5900397756625'),
  ('PL', 'Pudliszki', 'Grocery', 'Sauces', 'Bolonski', 'not-applicable', null, 'none', '5900783008758'),
  ('PL', 'Biedronka', 'Grocery', 'Sauces', 'Pesto Zielone. Sos na bazie bazyli', 'not-applicable', null, 'none', '5904378642754'),
  ('PL', 'GustoBello', 'Grocery', 'Sauces', 'White wine vinegar cream with pesto alla genovese', 'not-applicable', null, 'none', '5907544131052'),
  ('PL', 'Kucharek', 'Grocery', 'Sauces', 'Kucharek', 'not-applicable', null, 'none', '5901135000949'),
  ('PL', 'Develey', 'Grocery', 'Sauces', 'Sos 1000 Wysp', 'not-applicable', null, 'none', '5906425142835'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos vinaigrette', 'not-applicable', null, 'none', '5901044024661'),
  ('PL', 'Knorr', 'Grocery', 'Sauces', 'Sos sałatkowy paprykowo-ziołowy', 'not-applicable', 'Biedronka', 'none', '8714100855171'),
  ('PL', 'Madero', 'Grocery', 'Sauces', 'Sos chilli pikantny', 'not-applicable', null, 'none', '5906425141760'),
  ('PL', 'Asia Flavours', 'Grocery', 'Sauces', 'Sos Sriracha mayo', 'not-applicable', null, 'none', '5907501005105'),
  ('PL', 'House of asia', 'Grocery', 'Sauces', 'Sos Sriracha', 'not-applicable', null, 'none', '5902898823332'),
  ('PL', 'Asia Flavours', 'Grocery', 'Sauces', 'Sos Sambal Oelek', 'not-applicable', null, 'none', '5901801581116'),
  ('PL', 'House of Asia', 'Grocery', 'Sauces', 'Sos z Czarnym Pieprzem', 'not-applicable', null, 'none', '5901752703346'),
  ('PL', 'Madero', 'Grocery', 'Sauces', 'Sos BBQ z miodem gryczanym', 'not-applicable', null, 'none', '5901044023060'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'BBQ sos whisky', 'not-applicable', 'Netto', 'none', '5901044022223'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Texas sos BBQ', 'not-applicable', null, 'none', '5901044028737'),
  ('PL', 'Kotlin', 'Grocery', 'Sauces', 'Sos BBQ', 'not-applicable', null, 'none', '5900385502241'),
  ('PL', 'Jamar', 'Grocery', 'Sauces', 'Passata klasyczna', 'not-applicable', null, 'none', '5906716206253'),
  ('PL', 'Waldi Ben', 'Grocery', 'Sauces', 'Koncentrat pomidorowy 30%', 'not-applicable', null, 'none', '5902256006827'),
  ('PL', 'Winiary', 'Grocery', 'Sauces', 'Spaghetti sos z pomidorów', 'not-applicable', null, 'none', '7613037091380'),
  ('PL', 'Pingo Doce', 'Grocery', 'Sauces', 'Sos pomidorowy z bazylią', 'not-applicable', null, 'none', '8001060025837'),
  ('PL', 'Podravka', 'Grocery', 'Sauces', 'Przecier pomidorowy z bazylią', 'not-applicable', null, 'none', '3856020242442'),
  ('PL', 'Helcom', 'Grocery', 'Sauces', 'Sauce a la mexicaine', 'not-applicable', null, 'none', '5902166745861'),
  ('PL', 'Dawtona', 'Grocery', 'Sauces', 'Sos pomidorowy ostry z papryczkami jalapeño', 'not-applicable', null, 'none', '5901713021724'),
  ('PL', 'Schedro', 'Grocery', 'Sauces', 'Sos Chersoński', 'not-applicable', null, 'none', '4823097405420'),
  ('PL', 'Unknown', 'Grocery', 'Sauces', 'Pesto all Genovese', 'not-applicable', null, 'none', '5902693180593'),
  ('PL', 'Pure Line', 'Grocery', 'Sauces', 'Sos jogurtowy z czosnkiem', 'not-applicable', null, 'none', '5901044022254'),
  ('PL', 'Asia Flavours', 'Grocery', 'Sauces', 'Sos Sriracha', 'not-applicable', null, 'none', '5901619925546'),
  ('PL', 'Develey', 'Grocery', 'Sauces', 'Sos Mayo Sriracha z chili i czosnkiem', 'not-applicable', null, 'none', '5906425143856'),
  ('PL', 'Heinz', 'Grocery', 'Sauces', 'Słodki sos barbecue', 'not-applicable', null, 'none', '8715700209890'),
  ('PL', 'Winiary', 'Grocery', 'Sauces', 'Sos amerykański BBQ', 'not-applicable', null, 'none', '7613038848167'),
  ('PL', 'Roleski', 'Grocery', 'Sauces', 'Sos BBQ dark beer', 'not-applicable', null, 'none', '5901044022216'),
  ('PL', 'Italiamo', 'Grocery', 'Sauces', 'Sugo al pomodoro con basilico', 'not-applicable', 'Lidl', 'none', '20164041'),
  ('PL', 'Mutti', 'Grocery', 'Sauces', 'Sauce Tomate aux légumes grillés', 'not-applicable', 'Carrefour', 'none', '8005110519000'),
  ('PL', 'Auchan', 'Grocery', 'Sauces', 'Passata con basilico', 'not-applicable', 'Auchan', 'none', '8005476006220'),
  ('PL', 'Mondo Italiano', 'Grocery', 'Sauces', 'Passierte Tomaten', 'not-applicable', 'Netto', 'none', '4316268604062'),
  ('PL', 'Combino', 'Grocery', 'Sauces', 'Sauce tomate bio à la napolitaine', 'not-applicable', 'Lidl', 'none', '4056489447160'),
  ('PL', 'Extra Line', 'Grocery', 'Sauces', 'Passata garlic', 'not-applicable', 'Stokrotka', 'none', '2098765745579'),
  ('PL', 'Carrefour', 'Grocery', 'Sauces', 'Tomates basilic', 'not-applicable', 'Carrefour', 'none', '3560071357733'),
  ('PL', 'Baresa', 'Grocery', 'Sauces', 'Pesto alla Genovese', 'not-applicable', 'Lidl', 'none', '20069490'),
  ('PL', 'Barilla', 'Grocery', 'Sauces', 'Pesto alla Genovese', 'not-applicable', 'Carrefour', 'none', '8076809513753'),
  ('PL', 'Carrefour', 'Grocery', 'Sauces', 'Pesto verde', 'not-applicable', 'Carrefour', 'none', '3245413808196'),
  ('PL', 'Go Vege', 'Grocery', 'Sauces', 'Pesto z tofu', 'not-applicable', 'Biedronka', 'none', '8015559000915'),
  ('PL', 'Deluxe', 'Grocery', 'Sauces', 'Pesto con rucola', 'not-applicable', 'Lidl', 'none', '4056489204183'),
  ('PL', 'Heinz', 'Grocery', 'Sauces', 'Sauce Salade Caesar', 'not-applicable', 'Carrefour', 'none', '8410066120017'),
  ('PL', 'Sol & Mar', 'Grocery', 'Sauces', 'Piri-Piri', 'not-applicable', 'Lidl', 'none', '20026752'),
  ('PL', 'Kikkoman', 'Grocery', 'Sauces', 'Kikkoman Sojasauce', 'not-applicable', 'Biedronka', 'none', '8715035110809'),
  ('PL', 'Mutti', 'Grocery', 'Sauces', 'Passierte Tomaten', 'not-applicable', null, 'none', '80042563'),
  ('PL', 'Gustobello', 'Grocery', 'Sauces', 'Passata', 'not-applicable', null, 'none', '8002920016606')
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
where country = 'PL' and category = 'Sauces'
  and is_deprecated is not true
  and product_name not in ('Po Bolońsku sos do spaghetti', 'Sos meksykański', 'Sos do spaghetti pomidorowo-śmietankowy.', 'Sos Neapolitański z papryką', 'Sos Boloński z ziołami', 'Sos meksykański', 'Sos słodko-kwaśny z ananasem', 'Sos Boloński z bazylią', 'Sos Boloński z mięsem', 'Sos tysiąca wysp', 'Sos tysiąca wysp', 'Sos Barbecue. Sos do grilla z cebulą i papryką', 'Sos meksykański', 'Sos Boloński', 'Sos boloński', 'Sos do pizzy z ziołami', 'Sos pomidor + miód + limonka + nasiona chia', 'Duszone pomidory o smaku smażonej cebuli i czosnku, z olejem', 'Sos tysiąc wysp', 'Sałatka w stylu greckim', 'Sos chili tajski słodko-pikantny', 'Passata z czosnkiem', 'Passata', 'Sos Pomidorowy do Makaronu', 'Sos pomidorowy', 'Sos Curry', 'Przecier pomidorowy', 'SOS Spaghetti', 'Sos 1000 wysp', 'Sos jogurtowy z ziołami', 'Sos z jalapeño', 'Sos z chili', 'Sos chili pikantny', 'Sos jalapeño', 'Sos BBQ', 'Sos BBQ z chipotle', 'Sos Spaghetti', 'Sos Do Spaghetti Oryginalny', 'Sos Spaghetti', 'Passata rustica', 'Przecier pomidorowy', 'Leczo', 'Avocaboo!', 'Przecier pomidorowy', 'Passata - przecier pomidorowy klasyczny', 'Sos do kurczaka z czosnkiem', 'Passata', 'Arrabbiata Bruschetta', 'Dip in mexicana style', 'Sos pomidor + czarnuszka ostry', 'Sos pomidor + jagody goji', 'Sauce tomate', 'Bolonski', 'Pesto Zielone. Sos na bazie bazyli.', 'White wine vinegar cream with pesto alla genovese', 'Kucharek', 'Sos 1000 Wysp', 'Sos vinaigrette', 'Sos sałatkowy paprykowo-ziołowy', 'Sos chilli pikantny', 'Sos Sriracha mayo', 'Sos Sriracha', 'Sos Sambal Oelek', 'Sos z Czarnym Pieprzem', 'Sos BBQ z miodem gryczanym', 'BBQ sos whisky', 'Texas sos BBQ', 'Sos BBQ', 'Passata klasyczna', 'Koncentrat pomidorowy 30%', 'Spaghetti sos z pomidorów', 'Sos pomidorowy z bazylią', 'Przecier pomidorowy z bazylią', 'Sauce a la mexicaine', 'Sos pomidorowy ostry z papryczkami jalapeño', 'Sos Chersoński', 'Pesto all Genovese', 'Sos jogurtowy z czosnkiem', 'Sos Sriracha', 'Sos Mayo Sriracha z chili i czosnkiem', 'słodki sos barbecue', 'Sos amerykański BBQ', 'Sos BBQ dark beer', 'Sugo al pomodoro con basilico', 'Sauce Tomate aux légumes grillés', 'Passata con basilico', 'passierte Tomaten', 'Sauce tomate bio à la napolitaine', 'Passata garlic', 'Tomates basilic', 'Pesto alla Genovese', 'Pesto alla Genovese', 'Pesto verde', 'Pesto z tofu', 'Pesto con rucola', 'Sauce Salade Caesar', 'Piri-Piri', 'Kikkoman Sojasauce', 'Passierte Tomaten', 'Passata');

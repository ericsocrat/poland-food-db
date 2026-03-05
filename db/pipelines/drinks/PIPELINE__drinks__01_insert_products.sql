-- PIPELINE (Drinks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Drinks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900500031397', '5900379139460', '5905669653534', '5901088012983', '5901088012990', '5900334012685', '5900334012753', '5901088013133', '5905669653473', '5900352015798', '5903899246434', '5900001421697', '5900334006233', '5900500031434', '5901067406604', '5901067401548', '5900334016195', '5900334000286', '5901939105000', '5900334002242', '5900001421673', '5901886044001', '5900014003477', '5900334001733', '5900541011181', '5903899246557', '5900497312004', '5900497302005', '5901886039427', '5900541009461', '5900334006738', '5900497300506', '5900334007780', '5900059010317', '5902403941674', '5900552053163', '5900541011099', '5901886038550', '5900300550159', '5900168530959', '5900446019015', '5900552053156', '5900541011853', '5900334000200', '5901886041505', '5901154043163', '5900334005939', '5901154049387', '5900699102663', '5902176738655', '5900552014713', '5908260254834', '5901713020307', '5900334008206', '5908260251963', '5900497030212', '5908260251987', '5900497043380', '5900334013378', '5900497300339', '5908260253813', '5900497311502', '5900497310505', '5900352015347', '5900497043243', '5900552021865', '5900334012869', '4056489315605', '5908260253578', '5901713020314', '5900617041104', '5902860410744', '5901886044087', '5900497019316', '5908260251574', '5902078001109', '5908260253431', '5900334000736', '5901886038277', '5900552085805', '5900334020116', '5900001421635', '5900552077718', '5900500031496', '5908260258016', '5900334014443', '5900552032373', '5901067403764', '5900334017468', '5900497043182', '5900497045216', '5904988311071', '5904988310524', '5903839075933', '5900497019323')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Sok jabłkowy', 'not-applicable', 'Dino', 'none', '5900500031397'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% pomarańcza z witaminą C', 'not-applicable', 'Biedronka', 'none', '5900379139460'),
  ('PL', 'Bracia Sadownicy', 'Grocery', 'Drinks', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'not-applicable', 'Biedronka', 'none', '5905669653534'),
  ('PL', 'Polaris', 'Grocery', 'Drinks', 'Napój gazowany Vital Red', 'not-applicable', 'Biedronka', 'none', '5901088012983'),
  ('PL', 'Polaris', 'Grocery', 'Drinks', 'Napój gazowany Vital Green', 'not-applicable', 'Biedronka', 'none', '5901088012990'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% Pomarańcza', 'not-applicable', null, 'none', '5900334012685'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% jabłko', 'not-applicable', null, 'none', '5900334012753'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% jabłko', 'not-applicable', null, 'none', '5901088013133'),
  ('PL', 'Bracia Sadownicy', 'Grocery', 'Drinks', 'Tłoczone Jabłko słodkie odmiany', 'not-applicable', null, 'none', '5905669653473'),
  ('PL', 'Hellena', 'Grocery', 'Drinks', 'Oranżada czerwona', 'not-applicable', null, 'none', '5900352015798'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Napój Aloesowy z Cząstkami Aloesu', 'not-applicable', null, 'none', '5903899246434'),
  ('PL', 'Go Vege', 'Grocery', 'Drinks', 'Napój roślinny Owies Bio', 'not-applicable', null, 'none', '5900001421697'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko Wiśnia 2l', 'not-applicable', null, 'none', '5900334006233'),
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Sok 100% pomarańcza', 'not-applicable', null, 'none', '5900500031434'),
  ('PL', 'MWS', 'Grocery', 'Drinks', 'Kubuś Waterrr Truskawka', 'not-applicable', null, 'none', '5901067406604'),
  ('PL', 'Kubuš', 'Grocery', 'Drinks', '100% jabłko', 'not-applicable', null, 'none', '5901067401548'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Vitamini JABŁKO MARCHEW MALINA', 'not-applicable', null, 'none', '5900334016195'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko-Wiśnia', 'not-applicable', null, 'none', '5900334000286'),
  ('PL', 'Piątnica', 'Grocery', 'Drinks', 'Napój owsiany z wapnem i witaminami', 'not-applicable', null, 'none', '5901939105000'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Sok pomarańczowy 100% 1l', 'not-applicable', null, 'none', '5900334002242'),
  ('PL', 'GoVege (Biedronka)', 'Grocery', 'Drinks', 'Napój Roślinny - Midgał', 'not-applicable', null, 'none', '5900001421673'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Napój o smaku Kaktus - Jabłko - Limonka', 'not-applicable', null, 'none', '5901886044001'),
  ('PL', 'Zatecky', 'Grocery', 'Drinks', 'Żatecky 0,0% nealko', 'not-applicable', null, 'none', '5900014003477'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok pomarańczowy 100%', 'not-applicable', null, 'none', '5900334001733'),
  ('PL', 'Żywiec Zdrój', 'Grocery', 'Drinks', 'Z nutą truskawki', 'not-applicable', null, 'none', '5900541011181'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', '100% Coconut Water', 'not-applicable', 'Biedronka', 'none', '5903899246557'),
  ('PL', 'Pepsico', 'Grocery', 'Drinks', 'Pepsi', 'not-applicable', 'Netto', 'none', '5900497312004'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi Zero', 'not-applicable', 'Lidl', 'none', '5900497302005'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% multiwitamina', 'not-applicable', 'Biedronka', 'none', '5901886039427'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Żywiec Zdrój NGaz 1l', 'not-applicable', null, 'none', '5900541009461'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko Wiśnia', 'not-applicable', null, 'none', '5900334006738'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi Max 0.5', 'not-applicable', 'Żabka', 'none', '5900497300506'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Multifruit mango flavoured still drink', 'not-applicable', 'Auchan', 'none', '5900334007780'),
  ('PL', 'Fortuna', 'Grocery', 'Drinks', 'Sok 100% pomidor', 'not-applicable', 'Auchan', 'none', '5900059010317'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Cola original zero', 'not-applicable', 'Biedronka', 'none', '5902403941674'),
  ('PL', 'Frugo', 'Grocery', 'Drinks', 'Ultra black', 'not-applicable', 'Dino', 'none', '5900552053163'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Zywiec zdróy z nuta cytryny', 'not-applicable', null, 'none', '5900541011099'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Jus d''orange 100%', 'not-applicable', 'Biedronka', 'none', '5901886038550'),
  ('PL', 'Unilever', 'Grocery', 'Drinks', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'not-applicable', 'Biedronka', 'none', '5900300550159'),
  ('PL', 'Vemondo', 'Grocery', 'Drinks', 'Owsiane smoothie owoce lata', 'fermented', 'Lidl', 'none', '5900168530959'),
  ('PL', 'Cola', 'Grocery', 'Drinks', 'Cola original intense zero', 'not-applicable', 'Biedronka', 'none', '5900446019015'),
  ('PL', 'Frugo', 'Grocery', 'Drinks', 'Frugo ultragreen', 'not-applicable', 'Dino', 'none', '5900552053156'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Żywiec Zdrój Minerals', 'not-applicable', null, 'none', '5900541011853'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok pomidorowy pikantny', 'not-applicable', 'Auchan', 'none', '5900334000200'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% pomidorowo-warzywny', 'not-applicable', 'Biedronka', 'none', '5901886041505'),
  ('PL', 'Inka', 'Grocery', 'Drinks', 'Mleko owsiane', 'not-applicable', 'Dino', 'none', '5901154043163'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark 100% jablko', 'not-applicable', 'Dino', 'none', '5900334005939'),
  ('PL', 'Grana', 'Grocery', 'Drinks', 'Owsiane', 'not-applicable', 'Lidl', 'none', '5901154049387'),
  ('PL', 'Heineken', 'Grocery', 'Drinks', 'Heineken 0.0%', 'not-applicable', 'Żabka', 'none', '5900699102663'),
  ('PL', 'WK Dzik', 'Grocery', 'Drinks', 'Dzik Energy Zero calorie', 'not-applicable', 'Biedronka', 'none', '5902176738655'),
  ('PL', 'Black', 'Grocery', 'Drinks', 'Black Energy', 'not-applicable', null, 'none', '5900552014713'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Oshee Vitamin Water', 'not-applicable', null, 'none', '5908260254834'),
  ('PL', 'Dawtona', 'Grocery', 'Drinks', 'Sok pomidorowy', 'not-applicable', null, 'none', '5901713020307'),
  ('PL', 'Tiger', 'Grocery', 'Drinks', 'TIGER Energy drink', 'not-applicable', null, 'none', '5900334008206'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Oshee Multifruit', 'not-applicable', null, 'none', '5908260251963'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi puszka', 'not-applicable', null, 'none', '5900497030212'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Oshee Grapefruit', 'not-applicable', null, 'none', '5908260251987'),
  ('PL', 'Lipton', 'Grocery', 'Drinks', 'Lipton Green 1,5L', 'not-applicable', null, 'none', '5900497043380'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% Multiwitamina', 'not-applicable', null, 'none', '5900334013378'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi 330ML Max Soft Drink', 'not-applicable', null, 'none', '5900497300339'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Vitamin Water', 'not-applicable', null, 'none', '5908260253813'),
  ('PL', 'Pepsico', 'Grocery', 'Drinks', 'Pepsi 1.5', 'not-applicable', null, 'none', '5900497311502'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi 0.5', 'not-applicable', null, 'none', '5900497310505'),
  ('PL', 'Hellena', 'Grocery', 'Drinks', 'Helena zero', 'not-applicable', null, 'none', '5900352015347'),
  ('PL', 'Lipton', 'Grocery', 'Drinks', 'Ice Tea Peach', 'not-applicable', null, 'none', '5900497043243'),
  ('PL', 'Black', 'Grocery', 'Drinks', 'Black Zero Sugar', 'not-applicable', null, 'none', '5900552021865'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok pomidorowy 100%', 'not-applicable', null, 'none', '5900334012869'),
  ('PL', 'Lidl', 'Grocery', 'Drinks', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'not-applicable', 'Lidl', 'none', '4056489315605'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Vitamin Water zero', 'not-applicable', null, 'none', '5908260253578'),
  ('PL', 'Dawtona', 'Grocery', 'Drinks', 'Sok pomidorowy pikantny', 'not-applicable', null, 'none', '5901713020314'),
  ('PL', 'I♥Vege', 'Grocery', 'Drinks', 'Owsiane', 'not-applicable', null, 'none', '5900617041104'),
  ('PL', 'Schweppes', 'Grocery', 'Drinks', 'Indian Tonic', 'not-applicable', null, 'none', '5902860410744'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok Marchew Banan Jablko', 'not-applicable', null, 'none', '5901886044087'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi 0.85', 'not-applicable', null, 'none', '5900497019316'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'OSHEE Zero', 'not-applicable', null, 'none', '5908260251574'),
  ('PL', 'Cisowianka', 'Grocery', 'Drinks', 'Cisowianka gazowana', 'not-applicable', null, 'none', '5902078001109'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Vitamin Tea Zero Peach Flavour', 'not-applicable', null, 'none', '5908260253431'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Apple watermelon', 'not-applicable', null, 'none', '5900334000736'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok Pomidor Pikantny', 'not-applicable', null, 'none', '5901886038277'),
  ('PL', '4move', 'Grocery', 'Drinks', '4move sports wild cherry', 'not-applicable', null, 'none', '5900552085805'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Just Plants Owies', 'not-applicable', null, 'none', '5900334020116'),
  ('PL', 'GoVege', 'Grocery', 'Drinks', 'Barista salted caramel', 'not-applicable', null, 'none', '5900001421635'),
  ('PL', '4move', 'Grocery', 'Drinks', 'Activevitamin', 'not-applicable', null, 'none', '5900552077718'),
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Nektar z czarnych porzeczek', 'not-applicable', null, 'none', '5900500031496'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Oshee lemonade Malina-Grejpfrut', 'not-applicable', null, 'none', '5908260258016'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Mousse', 'not-applicable', null, 'none', '5900334014443'),
  ('PL', 'Black', 'Grocery', 'Drinks', 'Black Energy - Mojito flavour', 'not-applicable', null, 'none', '5900552032373'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Dr witt multivitamin', 'not-applicable', null, 'none', '5901067403764'),
  ('PL', 'Alcalia', 'Grocery', 'Drinks', 'Alcalia Naturalna Woda Mineralna Naturalnie Alkaiczna', 'not-applicable', null, 'none', '5900334017468'),
  ('PL', 'Lipton', 'Grocery', 'Drinks', 'Green Ice Tea', 'not-applicable', null, 'none', '5900497043182'),
  ('PL', 'Lipton', 'Grocery', 'Drinks', 'Lipton green', 'not-applicable', null, 'none', '5900497045216'),
  ('PL', 'Wk Dzik', 'Grocery', 'Drinks', 'Dzik Vitamind Drink Cranberry', 'not-applicable', null, 'none', '5904988311071'),
  ('PL', 'Energy Drink', 'Grocery', 'Drinks', 'Dzik', 'not-applicable', null, 'none', '5904988310524'),
  ('PL', 'Swigo', 'Grocery', 'Drinks', 'Sok grejpfrutowy HPP', 'not-applicable', null, 'none', '5903839075933'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi', 'not-applicable', null, 'none', '5900497019323')
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
where country = 'PL' and category = 'Drinks'
  and is_deprecated is not true
  and product_name not in ('Sok jabłkowy', 'Sok 100% pomarańcza z witaminą C', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'Napój gazowany Vital Red', 'Napój gazowany Vital Green', 'Sok 100% Pomarańcza', 'Sok 100% jabłko', 'Sok 100% jabłko', 'Tłoczone Jabłko słodkie odmiany', 'Oranżada czerwona', 'Napój Aloesowy z Cząstkami Aloesu', 'Napój roślinny Owies Bio', 'Tymbark Jabłko Wiśnia 2l', 'Sok 100% pomarańcza', 'Kubuś Waterrr Truskawka', '100% jabłko', 'Vitamini JABŁKO MARCHEW MALINA', 'Tymbark Jabłko-Wiśnia', 'Napój owsiany z wapnem i witaminami', 'Tymbark Sok pomarańczowy 100% 1l', 'Napój Roślinny - Midgał', 'Napój o smaku Kaktus - Jabłko - Limonka', 'Żatecky 0,0% nealko', 'Sok pomarańczowy 100%', 'Z nutą truskawki', '100% Coconut Water', 'Pepsi', 'Pepsi Zero', 'Sok 100% multiwitamina', 'Żywiec Zdrój NGaz 1l', 'Tymbark Jabłko Wiśnia', 'Pepsi Max 0.5', 'Multifruit mango flavoured still drink', 'Sok 100% pomidor', 'Cola original zero', 'Ultra black', 'Zywiec zdróy z nuta cytryny', 'Jus d''orange 100%', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'Owsiane smoothie owoce lata', 'Cola original intense zero', 'Frugo ultragreen', 'Żywiec Zdrój Minerals', 'Sok pomidorowy pikantny', 'Sok 100% pomidorowo-warzywny', 'Mleko owsiane', 'Tymbark 100% jablko', 'Owsiane', 'Heineken 0.0%', 'Dzik Energy Zero calorie', 'Black Energy', 'Oshee Vitamin Water', 'Sok pomidorowy', 'TIGER Energy drink', 'Oshee Multifruit', 'Pepsi puszka', 'Oshee Grapefruit', 'Lipton Green 1,5L', 'Sok 100% Multiwitamina', 'Pepsi 330ML Max Soft Drink', 'Vitamin Water', 'Pepsi 1.5', 'Pepsi 0.5', 'Helena zero', 'Ice Tea Peach', 'Black Zero Sugar', 'Sok pomidorowy 100%', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'Vitamin Water zero', 'Sok pomidorowy pikantny', 'Owsiane', 'Indian Tonic', 'Sok Marchew Banan Jablko', 'Pepsi 0.85', 'OSHEE Zero', 'Cisowianka gazowana', 'Vitamin Tea Zero Peach Flavour', 'Apple watermelon', 'Sok Pomidor Pikantny', '4move sports wild cherry', 'Just Plants Owies', 'Barista salted caramel', 'Activevitamin', 'Nektar z czarnych porzeczek', 'Oshee lemonade Malina-Grejpfrut', 'Mousse', 'Black Energy - Mojito flavour', 'Dr witt multivitamin', 'Alcalia Naturalna Woda Mineralna Naturalnie Alkaiczna', 'Green Ice Tea', 'Lipton green', 'Dzik Vitamind Drink Cranberry', 'Dzik', 'Sok grejpfrutowy HPP', 'Pepsi');

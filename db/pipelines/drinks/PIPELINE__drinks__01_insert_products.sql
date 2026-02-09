-- PIPELINE (Drinks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Drinks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900500031397', '5900379139460', '5900001421437', '5901088012983', '5905669653534', '5901886038161', '5900334012685', '5900334012753', '5901067401548', '5900541000062', '5900500031434', '5905669653473', '5900334000286', '5900001421307', '5901067406604', '5900334006233', '5901088013133', '5900334000255', '5900541000000', '5900497312004', '5900334001047', '5900541009461', '5900541011853', '5900334005939', '5901886039427', '5900001421475', '5900552053156', '5901067404600', '5900497302005', '5901886038550', '5901886042694', '5900334020468', '5900334006738', '5900334013378', '5908260254834', '5900552014713', '5900552077718', '5901713020307', '5908260258016', '5900497311502', '5900552077695', '8410261718217', '5908260251963', '5900334008206', '5908260253578', '5900334013774', '5900497300339', '5900497310505', '8410261718316', '5900552021865', '5900497301503', '5904378644413', '5908260251574', '5900541000499', '5900334005496', '5900617041104', '5900334014443', '4056489315605', '5900500032899', '5900956000633')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Sok jabłkowy', null, 'Dino', 'none', '5900500031397'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% pomarańcza z witaminą C', null, 'Biedronka', 'none', '5900379139460'),
  ('PL', 'go VEGE', 'Grocery', 'Drinks', 'Napój roślinny owies bio', null, 'Biedronka', 'none', '5900001421437'),
  ('PL', 'Polaris', 'Grocery', 'Drinks', 'Napój gazowany Vital Red', null, 'Biedronka', 'none', '5901088012983'),
  ('PL', 'Bracia Sadownicy', 'Grocery', 'Drinks', 'Sok 100% tłoczony tłoczone jabłko z marchewką', null, 'Biedronka', 'none', '5905669653534'),
  ('PL', 'Rivia', 'Grocery', 'Drinks', 'Rivia Marchew Brzoskwinia Jabkło', null, 'Biedronka', 'none', '5901886038161'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% Pomarańcza', null, null, 'none', '5900334012685'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% jabłko', null, null, 'none', '5900334012753'),
  ('PL', 'kubuš', 'Grocery', 'Drinks', '100% jabłko', null, null, 'none', '5901067401548'),
  ('PL', 'Żywiec Zdrój', 'Grocery', 'Drinks', 'Żywiec Zdrój NGaz 0.5', null, null, 'none', '5900541000062'),
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Sok 100% pomarańcza', null, null, 'none', '5900500031434'),
  ('PL', 'Bracia Sadownicy', 'Grocery', 'Drinks', 'Tłoczone Jabłko słodkie odmiany', null, null, 'none', '5905669653473'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko-Wiśnia', null, null, 'none', '5900334000286'),
  ('PL', 'GoVege', 'Grocery', 'Drinks', 'Ryż', null, null, 'none', '5900001421307'),
  ('PL', 'MWS', 'Grocery', 'Drinks', 'Kubuś Waterrr Truskawka', null, null, 'none', '5901067406604'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko Wiśnia 2l', null, null, 'none', '5900334006233'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% jabłko', null, null, 'none', '5901088013133'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jablko Mięta 0.5', null, 'Noz', 'none', '5900334000255'),
  ('PL', 'Żywiec Zdrój', 'Grocery', 'Drinks', 'Niegazowany', null, 'Biedronka,Żabka,Lidl', 'none', '5900541000000'),
  ('PL', 'pepsico', 'Grocery', 'Drinks', 'pepsi', null, 'Netto', 'none', '5900497312004'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Cactus', null, 'Auchan', 'none', '5900334001047'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Żywiec Zdrój NGaz 1l', null, null, 'none', '5900541009461'),
  ('PL', 'Unknown', 'Grocery', 'Drinks', 'Żywiec Zdrój Minerals', null, null, 'none', '5900541011853'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark 100% jablko', null, 'Dino,carrefour', 'none', '5900334005939'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Sok 100% multiwitamina', null, 'KIWI,Biedronka,Kaufland', 'none', '5901886039427'),
  ('PL', 'Go vege', 'Grocery', 'Drinks', 'Barista owies', null, 'Biedronka', 'none', '5900001421475'),
  ('PL', 'Frugo', 'Grocery', 'Drinks', 'Frugo ultragreen', null, 'Dino', 'none', '5900552053156'),
  ('PL', 'kubus', 'Grocery', 'Drinks', 'Kubus Play Malina', null, 'biedronka', 'none', '5901067404600'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi Zero', null, 'Billa,Billa Plus,Lidl', 'none', '5900497302005'),
  ('PL', 'Riviva', 'Grocery', 'Drinks', 'Jus d''orange 100%', null, 'Biedronka', 'none', '5901886038550'),
  ('PL', 'Vitanella', 'Grocery', 'Drinks', 'Vitanella Breakfast Smoothie', null, 'Biedronka', 'none', '5901886042694'),
  ('PL', 'Tiger', 'Grocery', 'Drinks', 'Tiger placebo classic', null, 'Żapka,Biedronka', 'none', '5900334020468'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark Jabłko Wiśnia', null, null, 'none', '5900334006738'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% Multiwitamina', null, null, 'none', '5900334013378'),
  ('PL', 'OSHEE', 'Grocery', 'Drinks', 'OSHEE VITAMIN WATER', null, null, 'none', '5908260254834'),
  ('PL', 'Black', 'Grocery', 'Drinks', 'Black Energy', null, null, 'none', '5900552014713'),
  ('PL', '4move', 'Grocery', 'Drinks', 'Activevitamin', null, null, 'none', '5900552077718'),
  ('PL', 'Dawtona', 'Grocery', 'Drinks', 'Sok pomidorowy', null, null, 'none', '5901713020307'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Oshee lemonade Malina-Grejpfrut', null, null, 'none', '5908260258016'),
  ('PL', 'Pepsico', 'Grocery', 'Drinks', 'Pepsi 1.5', null, null, 'none', '5900497311502'),
  ('PL', 'active vitamin', 'Grocery', 'Drinks', '4move', null, null, 'none', '5900552077695'),
  ('PL', 'Vital FRESH', 'Grocery', 'Drinks', 'smoothie Mango Jabłko Banan Marakuja', null, 'Biedronka', 'none', '8410261718217'),
  ('PL', 'oshee', 'Grocery', 'Drinks', 'Oshee Multifruit', null, 'YES! Stores', 'none', '5908260251963'),
  ('PL', 'Tiger', 'Grocery', 'Drinks', 'TIGER Energy drink', null, null, 'none', '5900334008206'),
  ('PL', 'Oshee', 'Grocery', 'Drinks', 'Vitamin Water zero', null, null, 'none', '5908260253578'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Tymbark nektar czerwony grejpfrut', null, null, 'none', '5900334013774'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi 330ML Max Soft Drink', null, null, 'none', '5900497300339'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi 0.5', null, null, 'none', '5900497310505'),
  ('PL', 'Vital FRESH', 'Grocery', 'Drinks', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', null, 'Biedronka', 'none', '8410261718316'),
  ('PL', 'Black', 'Grocery', 'Drinks', 'Black Zero Sugar', null, null, 'none', '5900552021865'),
  ('PL', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi Max 1.5', null, null, 'none', '5900497301503'),
  ('PL', 'Asia Flavours', 'Grocery', 'Drinks', 'Coconut Milk', null, null, 'none', '5904378644413'),
  ('PL', 'OSHEE', 'Grocery', 'Drinks', 'OSHEE Zero', null, 'Home Bargains', 'none', '5908260251574'),
  ('PL', 'zywiec zdroj', 'Grocery', 'Drinks', 'Zywiec Woda Srednio Gazowana', null, null, 'none', '5900541000499'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Jablko Arbuz', null, null, 'none', '5900334005496'),
  ('PL', 'I♥Vege', 'Grocery', 'Drinks', 'Owsiane', null, null, 'none', '5900617041104'),
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Mousse', null, null, 'none', '5900334014443'),
  ('PL', 'Lidl', 'Grocery', 'Drinks', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', null, 'Lidl', 'none', '4056489315605'),
  ('PL', 'Hortex', 'Grocery', 'Drinks', 'Ananas nektar', null, null, 'none', '5900500032899'),
  ('PL', 'Herbapol', 'Grocery', 'Drinks', 'Malina', null, null, 'none', '5900956000633')
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
  and product_name not in ('Sok jabłkowy', 'Sok 100% pomarańcza z witaminą C', 'Napój roślinny owies bio', 'Napój gazowany Vital Red', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'Rivia Marchew Brzoskwinia Jabkło', 'Sok 100% Pomarańcza', 'Sok 100% jabłko', '100% jabłko', 'Żywiec Zdrój NGaz 0.5', 'Sok 100% pomarańcza', 'Tłoczone Jabłko słodkie odmiany', 'Tymbark Jabłko-Wiśnia', 'Ryż', 'Kubuś Waterrr Truskawka', 'Tymbark Jabłko Wiśnia 2l', 'Sok 100% jabłko', 'Tymbark Jablko Mięta 0.5', 'Niegazowany', 'pepsi', 'Cactus', 'Żywiec Zdrój NGaz 1l', 'Żywiec Zdrój Minerals', 'Tymbark 100% jablko', 'Sok 100% multiwitamina', 'Barista owies', 'Frugo ultragreen', 'Kubus Play Malina', 'Pepsi Zero', 'Jus d''orange 100%', 'Vitanella Breakfast Smoothie', 'Tiger placebo classic', 'Tymbark Jabłko Wiśnia', 'Sok 100% Multiwitamina', 'OSHEE VITAMIN WATER', 'Black Energy', 'Activevitamin', 'Sok pomidorowy', 'Oshee lemonade Malina-Grejpfrut', 'Pepsi 1.5', '4move', 'smoothie Mango Jabłko Banan Marakuja', 'Oshee Multifruit', 'TIGER Energy drink', 'Vitamin Water zero', 'Tymbark nektar czerwony grejpfrut', 'Pepsi 330ML Max Soft Drink', 'Pepsi 0.5', 'smoothie Marchewka Ananas Brzoskwinia Pomarańcza', 'Black Zero Sugar', 'Pepsi Max 1.5', 'Coconut Milk', 'OSHEE Zero', 'Zywiec Woda Srednio Gazowana', 'Jablko Arbuz', 'Owsiane', 'Mousse', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'Ananas nektar', 'Malina');

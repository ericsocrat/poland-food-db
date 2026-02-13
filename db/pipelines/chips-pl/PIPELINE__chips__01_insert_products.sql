-- PIPELINE (Chips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Chips'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900073020262', '5905187114760', '5900672001693', '5905187108981', '5900073020217', '5900073020118', '5900073020187', '5900672001723', '5900259087898', '5900073020293', '5900073020415', '5905187114685', '5905187114883', '5905187114708', '5900928088607', '5905187114753', '5900672001709', '5900073020583', '5905187120013', '5900259099686', '5902596484637', '5900259071170', '5900073020576', '5900259097552', '5900928081219', '5905187906259', '5900259099914', '5900073060152', '5900259128898', '5900259128409', '5900259133366', '5900259133311', '5905187114845', '5900073021269', '5904569550332', '5900259127778', '5900259127600', '5900259094728', '5900259115355', '5902180000137', '5905187114746', '5900259099235', '5900259117564', '5900672002577', '5905187120990', '5900259135360', '5900259135339', '5905187001985', '5905187003897', '5905187109025')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Intersnack', 'Grocery', 'Chips', 'Prażynki solone', 'not-applicable', 'Carrefour', 'none', '5900073020262'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Pieczone Żeberka', 'roasted', 'Żabka', 'none', '5905187114760'),
  ('PL', 'Miami', 'Grocery', 'Chips', 'Pałeczki kukurydziane', 'not-applicable', 'Biedronka', 'none', '5900672001693'),
  ('PL', 'The Lorenz Bahlsen Snack-World Sp. z o.o', 'Grocery', 'Chips', 'Wiejskie ziemniaczki - smak masło z solą', 'not-applicable', null, 'none', '5905187108981'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Prażynki bekonowe', 'not-applicable', null, 'none', '5900073020217'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Chipsy w kotle prażone', 'not-applicable', null, 'none', '5900073020118'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Przysnacki Chipsy w kotle prażone', 'not-applicable', null, 'none', '5900073020187'),
  ('PL', 'Erosnack', 'Grocery', 'Chips', 'Prażynki o smaku aromatyczny fromage', 'not-applicable', null, 'none', '5900672001723'),
  ('PL', 'Star', 'Grocery', 'Chips', 'Maczugi', 'not-applicable', 'Żabka', 'none', '5900259087898'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Chrupki o smaku zielona cebulka', 'not-applicable', 'Kaufland', 'none', '5900073020293'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Chrupki o smaku keczupu', 'not-applicable', 'Kaufland', 'none', '5900073020415'),
  ('PL', 'Crunchips', 'Grocery', 'Chips', 'Crunchips X-CUT, Papryka', 'not-applicable', 'Żabka', 'none', '5905187114685'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Sticks Ketchup', 'not-applicable', 'Biedronka', 'none', '5905187114883'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips X-cut Chakalaka', 'not-applicable', 'Auchan', 'none', '5905187114708'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Tortilla', 'not-applicable', 'Biedronka', 'none', '5900928088607'),
  ('PL', 'Crunchips', 'Grocery', 'Chips', 'Crunchips o smaku zielona cebulka', 'not-applicable', 'Auchan', 'none', '5905187114753'),
  ('PL', 'Miami', 'Grocery', 'Chips', 'Chrupki kukurydziane', 'not-applicable', 'Biedronka', 'none', '5900672001709'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Sticks smak ketchup', 'not-applicable', 'Biedronka', 'none', '5900073020583'),
  ('PL', 'Curly', 'Grocery', 'Chips', 'Curly Mexican style', 'not-applicable', 'Żabka', 'none', '5905187120013'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Oven Baked Grilled paprika flavoured', 'grilled', 'Biedronka', 'none', '5900259099686'),
  ('PL', 'Sunny Family', 'Grocery', 'Chips', 'Trips kukurydziane', 'not-applicable', 'Lidl', 'none', '5902596484637'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Chipsy ziemniaczane o smaku papryki', 'not-applicable', 'Biedronka', 'none', '5900259071170'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Top Sticks', 'not-applicable', 'Biedronka', 'none', '5900073020576'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Chipsy ziemniaczane solone', 'not-applicable', 'Biedronka', 'none', '5900259097552'),
  ('PL', 'Go Vege', 'Grocery', 'Chips', 'Tortilla Chips Buraczane', 'not-applicable', 'Biedronka', 'none', '5900928081219'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Chrupki ziemniaczane o smaku paprykowym', 'not-applicable', 'Biedronka', 'none', '5905187906259'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Karbowane Papryka', 'not-applicable', 'Biedronka', 'none', '5900259099914'),
  ('PL', 'Unknown', 'Grocery', 'Chips', 'Na Maxa Chrupki kukurydziane orzechowe', 'not-applicable', 'Biedronka', 'none', '5900073060152'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lay''s green onion flavoured', 'not-applicable', null, 'none', '5900259128898'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Fromage flavoured chips', 'not-applicable', null, 'none', '5900259128409'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lay''s Oven Baked Grilled Paprika', 'grilled', null, 'none', '5900259133366'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays Papryka', 'not-applicable', null, 'none', '5900259133311'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Chipsy smak serek Fromage', 'not-applicable', null, 'none', '5900073021269'),
  ('PL', 'Zdrowidło', 'Grocery', 'Chips', 'Loopeas light o smaku papryki', 'not-applicable', null, 'none', '5904569550332'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays strong', 'not-applicable', null, 'none', '5900259127778'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays solone', 'not-applicable', null, 'none', '5900259127600'),
  ('PL', 'Doritos', 'Grocery', 'Chips', 'Hot Corn', 'not-applicable', null, 'none', '5900259094728'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Oven Baked krakersy', 'baked', 'Żabka', 'none', '5900259115355'),
  ('PL', 'Sonko', 'Grocery', 'Chips', 'Chipsy z ciecierzycy', 'dried', null, 'none', '5902180000137'),
  ('PL', 'Crunchips', 'Grocery', 'Chips', 'Potato crisps with paprika flavour', 'not-applicable', null, 'none', '5905187114746'),
  ('PL', 'PepsiCo Inc', 'Grocery', 'Chips', 'Lays Mini Zielona Cebulka Chipsy', 'not-applicable', null, 'none', '5900259099235'),
  ('PL', 'Doritos', 'Grocery', 'Chips', 'Doriros Sweet Chili Flavoured 100g', 'not-applicable', null, 'none', '5900259117564'),
  ('PL', 'Eurosnack', 'Grocery', 'Chips', 'Chrupki kukurydziane Pufuleti Sea salt', 'not-applicable', null, 'none', '5900672002577'),
  ('PL', 'Crunchips', 'Grocery', 'Chips', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 'not-applicable', null, 'none', '5905187120990'),
  ('PL', 'Cheetos', 'Grocery', 'Chips', 'Cheetos Flamin Hot', 'not-applicable', null, 'none', '5900259135360'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Flamin'' Hot', 'not-applicable', null, 'none', '5900259135339'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Peppies Bacon Flavour', 'not-applicable', null, 'none', '5905187001985'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Monster Munch Mr BIG', 'not-applicable', null, 'none', '5905187003897'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Wiejskie Ziemniaczki Cebulka', 'not-applicable', null, 'none', '5905187109025')
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
where country = 'PL' and category = 'Chips'
  and is_deprecated is not true
  and product_name not in ('Prażynki solone', 'Crunchips Pieczone Żeberka', 'Pałeczki kukurydziane', 'Wiejskie ziemniaczki - smak masło z solą', 'Prażynki bekonowe', 'Chipsy w kotle prażone', 'Przysnacki Chipsy w kotle prażone', 'Prażynki o smaku aromatyczny fromage', 'Maczugi', 'Chrupki o smaku zielona cebulka', 'Chrupki o smaku keczupu', 'Crunchips X-CUT, Papryka', 'Crunchips Sticks Ketchup', 'Crunchips X-cut Chakalaka', 'Tortilla', 'Crunchips o smaku zielona cebulka', 'Chrupki kukurydziane', 'Sticks smak ketchup', 'Curly Mexican style', 'Oven Baked Grilled paprika flavoured', 'Trips kukurydziane', 'Chipsy ziemniaczane o smaku papryki', 'Top Sticks', 'Chipsy ziemniaczane solone', 'Tortilla Chips Buraczane', 'Chrupki ziemniaczane o smaku paprykowym', 'Karbowane Papryka', 'Na Maxa Chrupki kukurydziane orzechowe', 'Lay''s green onion flavoured', 'Fromage flavoured chips', 'Lay''s Oven Baked Grilled Paprika', 'Lays Papryka', 'Crunchips X-CUT Chakalaka', 'Chipsy smak serek Fromage', 'Loopeas light o smaku papryki', 'Lays strong', 'Lays solone', 'Hot Corn', 'Oven Baked krakersy', 'Chipsy z ciecierzycy', 'Potato crisps with paprika flavour', 'Lays Mini Zielona Cebulka Chipsy', 'Doriros Sweet Chili Flavoured 100g', 'Chrupki kukurydziane Pufuleti Sea salt', 'Chipsy ziemniaczane o smaku fajity z kurczakiem', 'Cheetos Flamin Hot', 'Flamin'' Hot', 'Peppies Bacon Flavour', 'Monster Munch Mr BIG', 'Wiejskie Ziemniaczki Cebulka');

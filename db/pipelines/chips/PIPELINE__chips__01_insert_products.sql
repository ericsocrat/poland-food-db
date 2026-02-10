-- PIPELINE (Chips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Chips'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Intersnack', 'Grocery', 'Chips', 'Prażynki solone', null, 'Carrefour', 'none', '5900073020262'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Pieczone Żeberka', null, 'Żabka', 'none', '5905187114760'),
  ('PL', 'The Lorenz Bahlsen Snack-World Sp. z o.o.', 'Grocery', 'Chips', 'Wiejskie ziemniaczki - smak masło z solą', null, null, 'none', '5905187108981'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Chrupki o smaku zielona cebulka', null, 'Kaufland', 'none', '5900073020293'),
  ('PL', 'Star', 'Grocery', 'Chips', 'Maczugi', null, 'Żabka', 'none', '5900259087898'),
  ('PL', 'Przysnacki', 'Grocery', 'Chips', 'Chrupki o smaku keczupu', null, 'Kaufland', 'none', '5900073020415'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Sticks Ketchup', null, 'Biedronka', 'none', '5905187114883'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Fromage flavoured chips', null, null, 'none', '5900259128409'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays solone', null, null, 'none', '5900259127600'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lay''s green onion flavoured', null, null, 'none', '5900259128898'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays Papryka', null, null, 'none', '5900259133311'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays strong', null, null, 'none', '5900259127778'),
  ('PL', 'Doritos', 'Grocery', 'Chips', 'Doriros Sweet Chili Flavoured 100g', null, null, 'none', '5900259117564'),
  ('PL', 'Lay’s', 'Grocery', 'Chips', 'Lay''s Oven Baked Grilled Paprika', 'baked', null, 'none', '5900259133366'),
  ('PL', 'Doritos', 'Grocery', 'Chips', 'Flamingo Hot', null, null, 'none', '5900259135391'),
  ('PL', 'Doritos', 'Grocery', 'Chips', 'Hot Corn', null, null, 'none', '5900259094728'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays gr. priesk. zolel. sk.', null, null, 'none', '5900259128423'),
  ('PL', 'Cheetos', 'Grocery', 'Chips', 'Cheetos Flamin Hot', null, null, 'none', '5900259135360'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Cheetos Cheese', null, null, 'none', '5900259029041'),
  ('PL', 'Crunchips', 'Grocery', 'Chips', 'Potato crisps with paprika flavour.', null, null, 'none', '5905187114746'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays MAXX cheese & onion', null, null, 'none', '5900259127754'),
  ('PL', 'Top', 'Grocery', 'Chips', 'Chipsy smak serek Fromage', null, null, 'none', '5900073021269'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Lays Green Onion', null, null, 'none', '5900259099358'),
  ('PL', 'Lorenz', 'Grocery', 'Chips', 'Crunchips X-CUT Chakalaka', null, null, 'none', '5905187114845'),
  ('PL', 'zdrowidło', 'Grocery', 'Chips', 'Loopeas light o smaku papryki', null, null, 'none', '5904569550332'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Flamin'' Hot', null, null, 'none', '5900259135339'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Oven Baked Chanterelles in a cream sauce flavoured', 'baked', null, 'none', '5900259128546'),
  ('PL', 'Lay''s', 'Grocery', 'Chips', 'Chips', null, null, 'none', '5900259128706')
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
  and product_name not in ('Prażynki solone', 'Crunchips Pieczone Żeberka', 'Wiejskie ziemniaczki - smak masło z solą', 'Chrupki o smaku zielona cebulka', 'Maczugi', 'Chrupki o smaku keczupu', 'Crunchips Sticks Ketchup', 'Fromage flavoured chips', 'Lays solone', 'Lay''s green onion flavoured', 'Lays Papryka', 'Lays strong', 'Doriros Sweet Chili Flavoured 100g', 'Lay''s Oven Baked Grilled Paprika', 'Flamingo Hot', 'Hot Corn', 'Lays gr. priesk. zolel. sk.', 'Cheetos Flamin Hot', 'Cheetos Cheese', 'Potato crisps with paprika flavour.', 'Lays MAXX cheese & onion', 'Chipsy smak serek Fromage', 'Lays Green Onion', 'Crunchips X-CUT Chakalaka', 'Loopeas light o smaku papryki', 'Flamin'' Hot', 'Oven Baked Chanterelles in a cream sauce flavoured', 'Chips');

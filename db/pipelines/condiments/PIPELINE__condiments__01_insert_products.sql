-- PIPELINE (Condiments): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Condiments'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup Łagodny', null, 'Netto', 'none', '5900385012573'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Ketchup łagodny', null, 'Biedronka', 'none', '5900783004996'),
  ('PL', 'Go Vege', 'Grocery', 'Condiments', 'Majonez sałatkowy wegański', null, 'Biedronka', 'none', '5901044021875'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny', null, 'Asda', 'none', '5900783000424'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup łagodny', null, null, 'none', '5900385500148'),
  ('PL', 'Winiary', 'Grocery', 'Condiments', 'Majonez Dekoracyjny', null, 'Tesco', 'none', '5900085011012'),
  ('PL', 'Kamis', 'Grocery', 'Condiments', 'Musztarda sarepska ostra', null, 'Tesco', 'none', '5900084229395'),
  ('PL', 'Winiary', 'Grocery', 'Condiments', 'Mayonnaise Decorative', null, 'Lewiatan', 'none', '5900085011029'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup hot', null, 'Netto,Stokrotka', 'none', '5900385012528'),
  ('PL', 'Społem Kielce', 'Grocery', 'Condiments', 'Majonez Kielecki', null, 'Tesco', 'none', '5900242001610'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Moutarde Dijon', null, 'intermarché,E-Leclerc', 'none', '5901044016840'),
  ('PL', 'Krakus', 'Grocery', 'Condiments', 'Chrzan', null, 'Kaufland,Auchan', 'none', '5900397731554'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Majonez', null, 'Biedronka', 'none', '5906425150335'),
  ('PL', 'Nestlé', 'Grocery', 'Condiments', 'Przyprawa Maggi', null, null, 'none', '5900085011180'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Heinz Zero Sel Ajoute', null, null, 'none', '5900783010287'),
  ('PL', 'Kielecki', 'Grocery', 'Condiments', 'Mayonnaise Kielecki', null, null, 'none', '5900242003089'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'ketchup pikantny', null, null, 'none', '5900783008697'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup pikantny', null, 'Asda', 'none', '5900783000417'),
  ('PL', 'Prymat', 'Grocery', 'Condiments', 'Musztarda sarepska ostra', null, null, 'none', '5901135025737'),
  ('PL', 'Kamis', 'Grocery', 'Condiments', 'Musztarda delikatesowa', null, null, 'none', '5900084229456'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup Lagodny', null, null, 'none', '5900783003418'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Sos czosnkowy', null, null, 'none', '5906425144587'),
  ('PL', 'Barilla', 'Grocery', 'Condiments', 'Pesto alla Genovese', null, 'carrefour.fr,Denner AG,Carrefour,Super U,Coop Obs', 'none', '8076809513753'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Tomato Ketchup', null, 'Magasins U,carrefour.fr,Leclerc', 'none', '87157215'),
  ('PL', 'Kikkoman', 'Grocery', 'Condiments', 'Kikkoman Sojasauce', null, 'toko,asian supermarket,carrefour.fr,Biedronka,Tesco', 'none', '8715035110809'),
  ('PL', 'Kikkoman', 'Grocery', 'Condiments', 'Teriyakisauce', null, 'Carrefour,Irma.dk', 'none', '8715035210301'),
  ('PL', 'Italiamo', 'Grocery', 'Condiments', 'Sugo al pomodoro con basilico', null, 'Lidl', 'none', '20164041'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Heinz Mayonesa', null, 'EDEKA,Lidl', 'none', '8715700117829')
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
where country = 'PL' and category = 'Condiments'
  and is_deprecated is not true
  and product_name not in ('Ketchup Łagodny', 'Ketchup łagodny', 'Majonez sałatkowy wegański', 'Ketchup łagodny', 'Ketchup łagodny', 'Majonez Dekoracyjny', 'Musztarda sarepska ostra', 'Mayonnaise Decorative', 'Ketchup hot', 'Majonez Kielecki', 'Moutarde Dijon', 'Chrzan', 'Majonez', 'Przyprawa Maggi', 'Heinz Zero Sel Ajoute', 'Mayonnaise Kielecki', 'ketchup pikantny', 'Ketchup pikantny', 'Musztarda sarepska ostra', 'Musztarda delikatesowa', 'Ketchup Lagodny', 'Sos czosnkowy', 'Pesto alla Genovese', 'Tomato Ketchup', 'Kikkoman Sojasauce', 'Teriyakisauce', 'Sugo al pomodoro con basilico', 'Heinz Mayonesa');

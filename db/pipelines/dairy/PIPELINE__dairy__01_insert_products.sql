-- PIPELINE (Dairy): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Dairy'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Mlekpol', 'Grocery', 'Dairy', 'Łaciate 3,2%', null, 'Carrefour,Delikatesy Centrum', 'none', '5900820000011'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'Masło ekstra', null, 'Biedronka', 'none', '5900512220130'),
  ('PL', 'PIĄTNICA', 'Grocery', 'Dairy', 'TWARÓG WIEJSKI PÓŁTŁUSTY', null, 'Carrefour', 'none', '5900531004018'),
  ('PL', 'Piatnica', 'Grocery', 'Dairy', 'Serek Wiejski wysokobiałkowy', null, 'Lidl,biedronka,żabka,Carrefour,Stokrotka,Auchan', 'none', '5900531007019'),
  ('PL', 'Łaciate', 'Grocery', 'Dairy', 'Łaciaty serek śmietankowy', null, 'Stokrotka,Żabka', 'none', '5900820011468'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Twój Smak Serek śmietankowy', null, 'Stokrotka,Żabka', 'none', '5900531000508'),
  ('PL', 'Łaciate', 'Grocery', 'Dairy', 'Masło extra Łaciate', null, 'Biedronka,Żabka,Stokrotka', 'none', '5900820000257'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', null, 'Biedronka', 'none', '5902409703887'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Śmietana 18%', null, null, 'none', '5900531001130'),
  ('PL', 'Sierpc', 'Grocery', 'Dairy', 'Ser królewski', null, null, 'none', '5901753000628'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Serek Almette z ziołami', null, null, 'none', '5902899101651'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Mleko wieskie świeże 2%', null, null, 'none', '5901939000770'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko Polskie SPOŻYWCZE', null, 'Mila,Alta', 'none', '5900512850023'),
  ('PL', 'PIĄTNICA', 'Grocery', 'Dairy', 'SEREK WIEJSKI', null, 'Auchan,Żabka,Biedronka', 'none', '5900531000010'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'Mleko WYPASIONE 3,2%', null, 'Tesco', 'none', '5900512320359'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny typu islandzkiego Jagoda', null, 'Auchan', 'none', '5901939103099'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt typu islandzkiego waniliowy', null, 'Lidl', 'none', '5900531004537'),
  ('PL', 'Favita', 'Grocery', 'Dairy', 'Favita', null, 'Lidl', 'none', '5900512700014'),
  ('PL', 'Mleczna Dolina', 'Grocery', 'Dairy', 'mleko UHT 3,2%', null, 'Biedronka', 'none', '5900512320625'),
  ('PL', 'MLEKOVITA', 'Grocery', 'Dairy', 'Butter', null, null, 'none', '5900512300108'),
  ('PL', 'Almette', 'Grocery', 'Dairy', 'Hochland Almette Soft Cheese 150G', null, null, 'none', '5902899101637'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Serek homogenizowany waniliowy', null, null, 'none', '5900531011016'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny Naturalny', null, null, 'none', '5901939103105'),
  ('PL', 'Mlekovita', 'Grocery', 'Dairy', 'hleko', null, null, 'none', '5900512850016'),
  ('PL', 'Pilos', 'Grocery', 'Dairy', 'Mleko zagęszczone 7,5%', null, 'Lidl', 'none', '20037680'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr jogurt pitny', null, null, 'none', '5901939103235'),
  ('PL', 'Piątnica', 'Grocery', 'Dairy', 'Skyr - jogurt typu islandzkiego z truskawkami', null, null, 'none', '5900531004506'),
  ('PL', 'Fruvita', 'Grocery', 'Dairy', 'Jogurt Grecki', null, null, 'none', '5900512901091')
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
where country = 'PL' and category = 'Dairy'
  and is_deprecated is not true
  and product_name not in ('Łaciate 3,2%', 'Masło ekstra', 'TWARÓG WIEJSKI PÓŁTŁUSTY', 'Serek Wiejski wysokobiałkowy', 'Łaciaty serek śmietankowy', 'Twój Smak Serek śmietankowy', 'Masło extra Łaciate', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'Śmietana 18%', 'Ser królewski', 'Serek Almette z ziołami', 'Mleko wieskie świeże 2%', 'Mleko Polskie SPOŻYWCZE', 'SEREK WIEJSKI', 'Mleko WYPASIONE 3,2%', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'Skyr jogurt typu islandzkiego waniliowy', 'Favita', 'mleko UHT 3,2%', 'Butter', 'Hochland Almette Soft Cheese 150G', 'Serek homogenizowany waniliowy', 'Skyr jogurt pitny Naturalny', 'hleko', 'Mleko zagęszczone 7,5%', 'Skyr jogurt pitny', 'Skyr - jogurt typu islandzkiego z truskawkami', 'Jogurt Grecki');

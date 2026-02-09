-- PIPELINE (Drinks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Drinks'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Tymbark', 'Grocery', 'Drinks', 'Sok 100% Pomarańcza', null, null, 'none', '5900334012685'),
  ('PL', 'Mlekovita', 'Grocery', 'Drinks', 'Kefir', null, 'Tesco', 'none', '5900512850290'),
  ('PL', 'Krasnystaw', 'Grocery', 'Drinks', 'kefir', null, 'Intermarche,Morrisons,Biedronka', 'none', '5902057001748'),
  ('PL', 'Żywiec Zdrój', 'Grocery', 'Drinks', 'Niegazowany', null, 'Biedronka,Żabka,Lidl', 'none', '5900541000000'),
  ('PL', 'Piątnica', 'Grocery', 'Drinks', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', null, 'Auchan,Carrefour,Kaufland', 'none', '5901939103068'),
  ('PL', 'Krasnystaw', 'Grocery', 'Drinks', 'Kefir', null, null, 'none', '5902057003285'),
  ('PL', 'oshee', 'Grocery', 'Drinks', 'Oshee Multifruit', null, 'YES! Stores', 'none', '5908260251963'),
  ('PL', 'Lidl', 'Grocery', 'Drinks', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', null, 'Lidl', 'none', '4056489315605'),
  ('PL', 'Coca-Cola', 'Grocery', 'Drinks', 'Napój gazowany o smaku cola', null, null, 'none', '5449000158895'),
  ('PL', 'Coca-Cola', 'Grocery', 'Drinks', 'Coca-Cola Original Taste', null, 'Magasins U,Żabka,Biedronka,Hofer,Billa,Spar', 'none', '54491472'),
  ('PL', 'Danone', 'Grocery', 'Drinks', 'Geröstete Mandel Ohne Zucker', null, 'Edeka,Carrefour,REMA 1000,Spar,K-Supermarket,Pingo Doce,Eroski,Netto,Konsum', 'none', '5411188112709'),
  ('PL', 'Millbona', 'Grocery', 'Drinks', 'HIGH PROTEIN Caramel Pudding', null, 'Carrefour,Mercadona,Spar,Amazon,Billa', 'none', '5449000131805'),
  ('PL', 'Coca-Cola', 'Grocery', 'Drinks', 'Coca Cola Original taste', null, 'Cora,E.leclerc,Auchan,Lidl,Carrefour Market,Magasin U,Monoprix,Métro,Spar', 'none', '5449000000439'),
  ('PL', 'Vemondo', 'Grocery', 'Drinks', 'Almond Drink', null, 'Lidl', 'none', '4056489346357'),
  ('PL', 'Oatly', 'Grocery', 'Drinks', 'Haferdrink Barista', null, 'Albert Heijn,kaufland', 'none', '7394376616501'),
  ('PL', 'alpro', 'Grocery', 'Drinks', 'Coco Délicieuse et Tropicale', null, 'Intermarché,Biedronka,Tesco', 'none', '5411188116592'),
  ('PL', 'Milbona', 'Grocery', 'Drinks', 'High Protein Drink Cacao', null, 'Lidl', 'none', '4056489406679'),
  ('PL', 'Vemondo', 'Grocery', 'Drinks', 'Bio Hafer', null, 'Lidl', 'none', '4056489997511'),
  ('PL', 'Milbona', 'Grocery', 'Drinks', 'High Protein Drink Gusto Vaniglia', null, 'Lidl', 'none', '4056489406662'),
  ('PL', 'Kikkoman', 'Grocery', 'Drinks', 'Kikkoman Sojasauce', null, 'toko,asian supermarket,carrefour.fr,Biedronka,Tesco', 'none', '8715035110809'),
  ('PL', 'Kikkoman', 'Grocery', 'Drinks', 'Teriyakisauce', null, 'Carrefour,Irma.dk', 'none', '8715035210301'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Drinks', 'Avoine', null, 'Carrefour,carrefour.fr', 'none', '3245413451804'),
  ('PL', 'Vemondo', 'Grocery', 'Drinks', 'Boisson au soja', null, 'Lidl', 'none', '4056489695387'),
  ('PL', 'Club Mate', 'Grocery', 'Drinks', 'Club-Mate Original', null, 'Späti,Piwna strefa,Delhaize,REWE,nahkauf,Carrefour', 'none', '4029764001807'),
  ('PL', 'Coca-Cola', 'Grocery', 'Drinks', 'coca cola 1,75', null, 'Spar', 'none', '5449000130389'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Drinks', 'Amande Sans sucres', null, 'Carrefour,carrefour.fr', 'none', '3560071014094'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Drinks', 'SOJA Sans sucres ajoutés', null, 'Carrefour,carrefour.fr', 'none', '3270190128717'),
  ('PL', 'Naturis', 'Grocery', 'Drinks', 'Apple Juice', null, 'Lidl', 'none', '20569105')
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
  and product_name not in ('Sok 100% Pomarańcza', 'Kefir', 'kefir', 'Niegazowany', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Kefir', 'Oshee Multifruit', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'Napój gazowany o smaku cola', 'Coca-Cola Original Taste', 'Geröstete Mandel Ohne Zucker', 'HIGH PROTEIN Caramel Pudding', 'Coca Cola Original taste', 'Almond Drink', 'Haferdrink Barista', 'Coco Délicieuse et Tropicale', 'High Protein Drink Cacao', 'Bio Hafer', 'High Protein Drink Gusto Vaniglia', 'Kikkoman Sojasauce', 'Teriyakisauce', 'Avoine', 'Boisson au soja', 'Club-Mate Original', 'coca cola 1,75', 'Amande Sans sucres', 'SOJA Sans sucres ajoutés', 'Apple Juice');

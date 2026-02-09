-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Baby'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900852041129', '5900852999383', '5900852150005', '5900852245251', '5900852032592', '5900852061417', '5900852434006', '5900852071881', '5900852068812', '5900852038112', '4062300279773', '5900852922671', '8591119253835', '5900852394003', '5900852245244', '5900852066504', '7613033629303', '7613035507142', '8000300435351', '7613287173997', '8445291546851', '8436550903003', '8445291546967')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', null, null, 'none', '5900852041129'),
  ('PL', 'Nutricia', 'Grocery', 'Baby', 'Kaszka zbożowa jabłko, śliwka.', null, 'Mila', 'none', '5900852999383'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Pomidorowa z kurczakiem i ryżem', null, null, 'none', '5900852150005'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kaszka ryżowa bobovita', null, null, 'none', '5900852245251'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kaszka zbożowa Jabłko Śliwka', null, null, 'none', '5900852032592'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kaszka Mleczna Ryżowa Kakao', null, null, 'none', '5900852061417'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'Kaszka Ryżowa Banan', null, null, 'none', '5900852434006'),
  ('PL', 'bobovita', 'Grocery', 'Baby', 'kaszka mleczno-ryżowa straciatella', null, null, 'none', '5900852071881'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Delikatne jabłka z bananem', null, null, 'none', '5900852068812'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'Kaszka Mleczna Ryżowa 3 Owoce', null, null, 'none', '5900852038112'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Kaszka mleczna z biszkoptami i jabłkami', null, null, 'none', '4062300279773'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kaszka manna', null, null, 'none', '5900852922671'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'BoboVita Jabłka z marchewka', null, null, 'none', '8591119253835'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Bobovita', null, null, 'none', '5900852394003'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kaszka Ryzowa Malina', null, null, 'none', '5900852245244'),
  ('PL', 'Bobovita', 'Grocery', 'Baby', 'Kasza Manna', null, null, 'none', '5900852066504'),
  ('PL', 'Nestle Gerber', 'Grocery', 'Baby', 'owoce jabłka z truskawkami i jagodami', null, null, 'none', '7613033629303'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Leczo z mozzarellą i kluseczkami', null, null, 'none', '7613035507142'),
  ('PL', 'Gerber organic', 'Grocery', 'Baby', 'Krakersy z pomidorem po 12 miesiącu', null, null, 'none', '8000300435351'),
  ('PL', 'Gerber', 'Grocery', 'Baby', 'Pełnia Zbóż Owsianka 5 Zbóż', null, null, 'none', '7613287173997'),
  ('PL', 'Gerber', 'Grocery', 'Baby', 'Bukiet warzyw z łososiem w sosie pomidorowym', null, null, 'none', '8445291546851'),
  ('PL', 'dada baby food', 'Grocery', 'Baby', 'bio mus kokos', null, null, 'none', '8436550903003'),
  ('PL', 'Gerber', 'Grocery', 'Baby', 'Warzywa  z delikatnym indykiem w pomidorach', null, null, 'none', '8445291546967')
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
where country = 'PL' and category = 'Baby'
  and is_deprecated is not true
  and product_name not in ('Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'Kaszka zbożowa jabłko, śliwka.', 'Pomidorowa z kurczakiem i ryżem', 'Kaszka ryżowa bobovita', 'Kaszka zbożowa Jabłko Śliwka', 'Kaszka Mleczna Ryżowa Kakao', 'Kaszka Ryżowa Banan', 'kaszka mleczno-ryżowa straciatella', 'Delikatne jabłka z bananem', 'Kaszka Mleczna Ryżowa 3 Owoce', 'Kaszka mleczna z biszkoptami i jabłkami', 'Kaszka manna', 'BoboVita Jabłka z marchewka', 'Bobovita', 'Kaszka Ryzowa Malina', 'Kasza Manna', 'owoce jabłka z truskawkami i jagodami', 'Leczo z mozzarellą i kluseczkami', 'Krakersy z pomidorem po 12 miesiącu', 'Pełnia Zbóż Owsianka 5 Zbóż', 'Bukiet warzyw z łososiem w sosie pomidorowym', 'bio mus kokos', 'Warzywa  z delikatnym indykiem w pomidorach');

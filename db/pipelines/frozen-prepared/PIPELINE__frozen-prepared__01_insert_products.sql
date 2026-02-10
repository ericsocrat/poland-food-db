-- PIPELINE (Frozen & Prepared): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Frozen & Prepared'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900437007137', '5901398069936', '5902121011765', '5903548004262', '5907439112135', '5900477000846', '5901581232413', '5900437009988', '5900437007113', '5907377116578', '5902966009002', '5901537003142', '5900477012795', '5900972003960', '5901581232352', '5901028916616', '5901028908055', '5903154542622', '5901028917422', '5901028917941', '5901028917378', '5901028913479', '5901028917354', '5908280713045', '5901028917972', '5900437205137', '5907377116646', '5900130015835', '5901028913103', '5902533424665', '5907439112067', '5907377116677', '5900477000839', '5902121009793', '5901028913387')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza 4 sery, głęboko mrożona.', null, 'Tesco', 'none', '5900437007137'),
  ('PL', 'Swojska Chata', 'Grocery', 'Frozen & Prepared', 'Pierogi z kapustą i grzybami', null, 'Biedronka', 'none', '5901398069936'),
  ('PL', 'Koral', 'Grocery', 'Frozen & Prepared', 'Lody śmietankowe - kostka śnieżna', null, 'Biedronka', 'none', '5902121011765'),
  ('PL', 'Dobra kaloria', 'Grocery', 'Frozen & Prepared', 'Roślinna kaszanka', null, 'Lidl', 'none', '5903548004262'),
  ('PL', 'Grycan', 'Grocery', 'Frozen & Prepared', 'Lody śmietankowe', null, null, 'none', '5907439112135'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię', null, 'Kaufland', 'none', '5900477000846'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię z ziemniakami', null, 'Biedronka', 'none', '5901581232413'),
  ('PL', 'Dr.Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', null, 'Auchan', 'none', '5900437009988'),
  ('PL', 'Dr.Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza z szynką i sosem pesto, głęboko mrożona.', null, 'Auchan', 'none', '5900437007113'),
  ('PL', 'Biedronka', 'Grocery', 'Frozen & Prepared', 'Rożek z czekoladą', null, 'Biedronka', 'none', '5907377116578'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Jagody leśne', null, 'Biedronka', 'none', '5902966009002'),
  ('PL', 'MaxTop Sławków', 'Grocery', 'Frozen & Prepared', 'Pizza głęboko mrożona z szynką i pieczarkami.', null, 'Dino', 'none', '5901537003142'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Makaron na patelnię penne z sosem serowym', null, 'Auchan', 'none', '5900477012795'),
  ('PL', 'Fish Time', 'Grocery', 'Frozen & Prepared', 'Ryba z piekarnika z sosem brokułowym', null, 'Biedronka', 'none', '5900972003960'),
  ('PL', 'Morźna Kraina', 'Grocery', 'Frozen & Prepared', 'Włoszczyzna w słupkach', null, 'Biedronka', 'none', '5901581232352'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Fasolka szparagowa żółta i zielona, cała', null, null, 'none', '5901028916616'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Trio warzywne z mini marchewką', null, null, 'none', '5901028908055'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po włosku', 'fried', null, 'none', '5903154542622'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Kalafior różyczki', null, null, 'none', '5901028917422'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię letnie', null, null, 'none', '5901028917941'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Polskie wiśnie bez pestek', null, null, 'none', '5901028917378'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po meksykańsku', null, null, 'none', '5901028913479'),
  ('PL', 'Asia Flavours', 'Grocery', 'Frozen & Prepared', 'Mieszanka chińska', null, null, 'none', '5901028917354'),
  ('PL', 'NewIce', 'Grocery', 'Frozen & Prepared', 'Plombie Śnieżynka', null, null, 'none', '5908280713045'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po europejsku', null, null, 'none', '5901028917972'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza Guseppe z szynką i pieczarkami', null, null, 'none', '5900437205137'),
  ('PL', 'Kilargo', 'Grocery', 'Frozen & Prepared', 'Marletto Almond', null, 'Biedronka', 'none', '5907377116646'),
  ('PL', 'Zielona Budka', 'Grocery', 'Frozen & Prepared', 'Lody Truskawkowe', null, 'Auchan', 'none', '5900130015835'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie z ziemniakami', null, 'Biedronka', 'none', '5901028913103'),
  ('PL', 'Unknown', 'Grocery', 'Frozen & Prepared', 'Lody proteinowe śmietankowe go active', null, null, 'none', '5902533424665'),
  ('PL', 'Grycan', 'Grocery', 'Frozen & Prepared', 'Lody truskawkowe', null, 'Auchan', 'none', '5907439112067'),
  ('PL', 'Kilargo', 'Grocery', 'Frozen & Prepared', 'Marletto Salted Caramel Lava', null, 'Biedronka', 'none', '5907377116677'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie', null, 'Auchan', 'none', '5900477000839'),
  ('PL', 'Koral', 'Grocery', 'Frozen & Prepared', 'Lody Kukułka', null, null, 'none', '5902121009793'),
  ('PL', 'Mroźna kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie', null, 'Biedronka', 'none', '5901028913387')
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
where country = 'PL' and category = 'Frozen & Prepared'
  and is_deprecated is not true
  and product_name not in ('Pizza 4 sery, głęboko mrożona.', 'Pierogi z kapustą i grzybami', 'Lody śmietankowe - kostka śnieżna', 'Roślinna kaszanka', 'Lody śmietankowe', 'Warzywa na patelnię', 'Warzywa na patelnię z ziemniakami', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona.', 'Pizza z szynką i sosem pesto, głęboko mrożona.', 'Rożek z czekoladą', 'Jagody leśne', 'Pizza głęboko mrożona z szynką i pieczarkami.', 'Makaron na patelnię penne z sosem serowym', 'Ryba z piekarnika z sosem brokułowym', 'Włoszczyzna w słupkach', 'Fasolka szparagowa żółta i zielona, cała', 'Trio warzywne z mini marchewką', 'Warzywa na patelnię po włosku', 'Kalafior różyczki', 'Warzywa na patelnię letnie', 'Polskie wiśnie bez pestek', 'Warzywa na patelnię po meksykańsku', 'Mieszanka chińska', 'Plombie Śnieżynka', 'Warzywa na patelnię po europejsku', 'Pizza Guseppe z szynką i pieczarkami', 'Marletto Almond', 'Lody Truskawkowe', 'Warzywa na patelnie z ziemniakami', 'Lody proteinowe śmietankowe go active', 'Lody truskawkowe', 'Marletto Salted Caramel Lava', 'Warzywa na patelnie', 'Lody Kukułka', 'Warzywa na patelnie');

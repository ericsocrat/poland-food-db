-- PIPELINE (Frozen & Prepared): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Frozen & Prepared'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900437007137', '5901398069936', '5902121011765', '5903548004262', '5907439112135', '5900477000846', '5901581232413', '5900437009988', '5900437007113', '5907377116578', '5902966009002', '5901537003142', '5900477012795', '5900972003960', '5901581232352', '5907377115113', '5902162120716', '5902121022204', '5900437005010', '5900972010647', '5900437007151', '5902729241199', '5901028916616', '5901028908055', '5903154542622', '5901028917422', '5901028917941', '5901028917378', '5901028913479', '5901028917354', '5908280713045', '5901028917972', '5907555217431', '5900477013747', '5902121018955', '5900972008293', '5902121024116', '5902162105713', '5907377114758', '5901028915541', '5900437205137', '5907377116646', '5900130015835', '5901028913103', '5902533424665', '5907439112067', '5907377116677', '5900477000839', '5902121009793', '5901028913387')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza 4 sery, głęboko mrożona', 'not-applicable', 'Tesco', 'none', '5900437007137'),
  ('PL', 'Swojska Chata', 'Grocery', 'Frozen & Prepared', 'Pierogi z kapustą i grzybami', 'not-applicable', 'Biedronka', 'none', '5901398069936'),
  ('PL', 'Koral', 'Grocery', 'Frozen & Prepared', 'Lody śmietankowe - kostka śnieżna', 'not-applicable', 'Biedronka', 'none', '5902121011765'),
  ('PL', 'Dobra kaloria', 'Grocery', 'Frozen & Prepared', 'Roślinna kaszanka', 'not-applicable', 'Lidl', 'none', '5903548004262'),
  ('PL', 'Grycan', 'Grocery', 'Frozen & Prepared', 'Lody śmietankowe', 'not-applicable', null, 'none', '5907439112135'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię', 'not-applicable', 'Kaufland', 'none', '5900477000846'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię z ziemniakami', 'not-applicable', 'Biedronka', 'none', '5901581232413'),
  ('PL', 'Dr.Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona', 'not-applicable', 'Auchan', 'none', '5900437009988'),
  ('PL', 'Dr.Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza z szynką i sosem pesto, głęboko mrożona', 'not-applicable', 'Auchan', 'none', '5900437007113'),
  ('PL', 'Biedronka', 'Grocery', 'Frozen & Prepared', 'Rożek z czekoladą', 'not-applicable', 'Biedronka', 'none', '5907377116578'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Jagody leśne', 'not-applicable', 'Biedronka', 'none', '5902966009002'),
  ('PL', 'MaxTop Sławków', 'Grocery', 'Frozen & Prepared', 'Pizza głęboko mrożona z szynką i pieczarkami', 'not-applicable', 'Dino', 'none', '5901537003142'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Makaron na patelnię penne z sosem serowym', 'not-applicable', 'Auchan', 'none', '5900477012795'),
  ('PL', 'Fish Time', 'Grocery', 'Frozen & Prepared', 'Ryba z piekarnika z sosem brokułowym', 'not-applicable', 'Biedronka', 'none', '5900972003960'),
  ('PL', 'Morźna Kraina', 'Grocery', 'Frozen & Prepared', 'Włoszczyzna w słupkach', 'not-applicable', 'Biedronka', 'none', '5901581232352'),
  ('PL', 'Marletto', 'Grocery', 'Frozen & Prepared', 'Lody o smaku śmietankowym', 'not-applicable', 'Biedronka', 'none', '5907377115113'),
  ('PL', 'Iglotex', 'Grocery', 'Frozen & Prepared', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony', 'not-applicable', 'Auchan', 'none', '5902162120716'),
  ('PL', 'Bracia Koral', 'Grocery', 'Frozen & Prepared', 'Lody śmietankowe z ciasteczkami', 'not-applicable', 'Lewiatan', 'none', '5902121022204'),
  ('PL', 'Feliciana', 'Grocery', 'Frozen & Prepared', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona', 'not-applicable', 'Biedronka', 'none', '5900437005010'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię letnie', 'not-applicable', 'Biedronka', 'none', '5900972010647'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza z salami i chorizo, głęboko mrożona', 'not-applicable', null, 'none', '5900437007151'),
  ('PL', 'Gotszlik', 'Grocery', 'Frozen & Prepared', 'Rożek Dolce Giacomo', 'not-applicable', 'Kaufland', 'none', '5902729241199'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Fasolka szparagowa żółta i zielona, cała', 'not-applicable', null, 'none', '5901028916616'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Trio warzywne z mini marchewką', 'not-applicable', null, 'none', '5901028908055'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po włosku', 'fried', null, 'none', '5903154542622'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Kalafior różyczki', 'not-applicable', null, 'none', '5901028917422'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Polskie wiśnie bez pestek', 'not-applicable', null, 'none', '5901028917378'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po meksykańsku', 'not-applicable', null, 'none', '5901028913479'),
  ('PL', 'Asia Flavours', 'Grocery', 'Frozen & Prepared', 'Mieszanka chińska', 'not-applicable', null, 'none', '5901028917354'),
  ('PL', 'NewIce', 'Grocery', 'Frozen & Prepared', 'Plombie Śnieżynka', 'not-applicable', null, 'none', '5908280713045'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnię po europejsku', 'not-applicable', null, 'none', '5901028917972'),
  ('PL', 'Abramczyk', 'Grocery', 'Frozen & Prepared', 'Kapitańskie paluszki rybne', 'not-applicable', null, 'none', '5907555217431'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Maliny mrożone', 'not-applicable', null, 'none', '5900477013747'),
  ('PL', 'Bracia Koral', 'Grocery', 'Frozen & Prepared', 'Lody Jak Dawniej Śmietankowe', 'not-applicable', null, 'none', '5902121018955'),
  ('PL', 'Frosta', 'Grocery', 'Frozen & Prepared', 'Złote Paluszki Rybne z Fileta', 'not-applicable', null, 'none', '5900972008293'),
  ('PL', 'Bracia Koral', 'Grocery', 'Frozen & Prepared', 'Lody czekoladowe z wiśniami', 'not-applicable', null, 'none', '5902121024116'),
  ('PL', 'Iglotex', 'Grocery', 'Frozen & Prepared', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie', 'not-applicable', null, 'none', '5902162105713'),
  ('PL', 'Diuna', 'Grocery', 'Frozen & Prepared', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', 'not-applicable', null, 'none', '5907377114758'),
  ('PL', 'Unknown', 'Grocery', 'Frozen & Prepared', 'Jagody leśne', 'not-applicable', null, 'none', '5901028915541'),
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza Guseppe z szynką i pieczarkami', 'not-applicable', null, 'none', '5900437205137'),
  ('PL', 'Kilargo', 'Grocery', 'Frozen & Prepared', 'Marletto Almond', 'not-applicable', 'Biedronka', 'none', '5907377116646'),
  ('PL', 'Zielona Budka', 'Grocery', 'Frozen & Prepared', 'Lody Truskawkowe', 'not-applicable', 'Auchan', 'none', '5900130015835'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie z ziemniakami', 'not-applicable', 'Biedronka', 'none', '5901028913103'),
  ('PL', 'Unknown', 'Grocery', 'Frozen & Prepared', 'Lody proteinowe śmietankowe go active', 'not-applicable', null, 'none', '5902533424665'),
  ('PL', 'Grycan', 'Grocery', 'Frozen & Prepared', 'Lody truskawkowe', 'not-applicable', 'Auchan', 'none', '5907439112067'),
  ('PL', 'Kilargo', 'Grocery', 'Frozen & Prepared', 'Marletto Salted Caramel Lava', 'not-applicable', 'Biedronka', 'none', '5907377116677'),
  ('PL', 'Hortex', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie', 'not-applicable', 'Auchan', 'none', '5900477000839'),
  ('PL', 'Koral', 'Grocery', 'Frozen & Prepared', 'Lody Kukułka', 'not-applicable', null, 'none', '5902121009793'),
  ('PL', 'Mroźna Kraina', 'Grocery', 'Frozen & Prepared', 'Warzywa na patelnie', 'not-applicable', 'Biedronka', 'none', '5901028913387')
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
  and product_name not in ('Pizza 4 sery, głęboko mrożona', 'Pierogi z kapustą i grzybami', 'Lody śmietankowe - kostka śnieżna', 'Roślinna kaszanka', 'Lody śmietankowe', 'Warzywa na patelnię', 'Warzywa na patelnię z ziemniakami', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona', 'Pizza z szynką i sosem pesto, głęboko mrożona', 'Rożek z czekoladą', 'Jagody leśne', 'Pizza głęboko mrożona z szynką i pieczarkami', 'Makaron na patelnię penne z sosem serowym', 'Ryba z piekarnika z sosem brokułowym', 'Włoszczyzna w słupkach', 'Lody o smaku śmietankowym', 'Pizza z pieczarkami na podpieczonym spodzie. Produkt głęboko mrożony', 'Lody śmietankowe z ciasteczkami', 'Pizza z szynką, pieczarkami i salami, głęboko mrożona', 'Warzywa na patelnię letnie', 'Pizza z salami i chorizo, głęboko mrożona', 'Rożek Dolce Giacomo', 'Fasolka szparagowa żółta i zielona, cała', 'Trio warzywne z mini marchewką', 'Warzywa na patelnię po włosku', 'Kalafior różyczki', 'Warzywa na patelnię letnie', 'Polskie wiśnie bez pestek', 'Warzywa na patelnię po meksykańsku', 'Mieszanka chińska', 'Plombie Śnieżynka', 'Warzywa na patelnię po europejsku', 'Kapitańskie paluszki rybne', 'Maliny mrożone', 'Lody Jak Dawniej Śmietankowe', 'Złote Paluszki Rybne z Fileta', 'Lody czekoladowe z wiśniami', 'Pizza z mięsem z kurczaka i szpinakiem, na podpieczonym spodzie', 'Diuna o smaku brzoskwiniowo, śmietankowo, gruszkowym', 'Jagody leśne', 'Pizza Guseppe z szynką i pieczarkami', 'Marletto Almond', 'Lody Truskawkowe', 'Warzywa na patelnie z ziemniakami', 'Lody proteinowe śmietankowe go active', 'Lody truskawkowe', 'Marletto Salted Caramel Lava', 'Warzywa na patelnie', 'Lody Kukułka', 'Warzywa na patelnie');

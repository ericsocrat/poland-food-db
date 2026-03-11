-- PIPELINE (Cereals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Cereals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000540000108', '4000540011050', '4018077006203', '4000540000306', '4021700900021', '4061464911895', '4000540000641', '4056489665519', '4000540005028', '4000540011081', '4061459674101', '4061463845337', '4000540091069', '4061464912014', '4311501043646', '4337256379519', '4067796001839', '4066447663075', '4337256415965', '7613033212949', '20003166', '4260582961519', '3387390339499', '4311501720073', '4337256783132', '4337256739689', '4337256436649', '4311501492246', '7613287433633', '5059319023670', '4337256782531', '7394376621703', '4104420254756', '7394376617904', '5010029000023', '4104420238244')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Cereals by pipeline',
    ean = null
where country = 'DE'
  and category != 'Cereals'
  and identity_key in ('06682990554df75fce02636e077e5d80', '1037efaac3a62d7f3b8bce1b95e45fe8', '16d860a378ad9fd61d341fc32628a427', '17db3ee119f93f55060bcbb8d918671e', '1846b9128ca2bd3beef2872370ca1e37', '1d976418852c5a06407b7a3e170613f6', '1e0c3f1bbdbceca377d1334c01b19c15', '2571cf69b78af816f623193e6fce1fc8', '2b470833d6e7411f20fb3c3223e1cc1a', '2b8377625daa1ff9366871cc97d2e486', '2e8e81f7fabcf5149b6fa74b36ab7c00', '3fe14f569562499a31ffee6180697ba4', '474fef30c23866d5ecf657f1b59fb4d0', '4c3eb15182e86c2016e11e10f443fbfd', '4d0dc5e6850ffd5d09a6aea86c6ad3d1', '51098405ba288bae60741206934e38cf', '57281e825993e949b0cd36990092e92c', '8c16364eb3913a24b4b3738f647cef5d', '901eac9da15f144beb97528f446ab12f', '9d489238349eeedbba3ab382d729c363', 'a80695788841420cbfc6f4bf8839a7aa', 'af07419e344602f6bc53075141dd5766', 'b1f563c50c454024ee7c7752e17371d1', 'b5d2a28383c4ebdce69228cf1c8d9487', 'bb6097a3b208e7ce455b5f8ad0e07971', 'c3f74e1b9ffa0722cedfbe7c1ad755f4', 'cd1433921cf07912db7cfc757f6667fb', 'cf958d4664fd1ca85399f6acf5b8e472', 'd888b01ac64a50576dd63e3a1670a0c4', 'dee447ead7bf610342f3480aa71879a3', 'e112d1cc248052b70e713563c1eb1f77', 'e6352643fc6f18ad12057530dfc9db23', 'eced4ed0ea96f59eaf219f48e9f5d0b3', 'edf862ea7f813dffac40deab7187975d', 'ef584c4fab0cf610511d751a577af1b4', 'f1cd7680e75d6cbbb2a5d721fd866082')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferflocken, Blütenzarte Köllnflocken', 'not-applicable', null, 'none', '4000540000108'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'E Knusprige Haferfleks Klassik Kölln', 'not-applicable', 'Aldi', 'none', '4000540011050'),
  ('DE', 'Lorenz', 'Grocery', 'Cereals', 'Erdnußlocken Classic', 'not-applicable', 'Lidl', 'none', '4018077006203'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Kernige Haferflocken', 'not-applicable', null, 'none', '4000540000306'),
  ('DE', 'Nippon', 'Grocery', 'Cereals', 'Puffreis mit Schokolade', 'not-applicable', 'Lidl', 'none', '4021700900021'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Zarte Haferflocken', 'not-applicable', 'Aldi', 'none', '4061464911895'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Bio-Haferflocken zart', 'not-applicable', 'Netto', 'none', '4000540000641'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Bio Haferflocken zart', 'not-applicable', 'Lidl', 'none', '4056489665519'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'not-applicable', 'Penny', 'none', '4000540005028'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Vollkorn Haferfleks', 'not-applicable', null, 'none', '4000540011081'),
  ('DE', 'DE-VAU-GE Gesundkostwerk', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', 'Aldi', 'none', '4061459674101'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Cereals', 'Haferflocken zart', 'not-applicable', null, 'none', '4061463845337'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Knusprige Haferfleks Schoko', 'not-applicable', null, 'none', '4000540091069'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Haferflocken kernig', 'not-applicable', null, 'none', '4061464912014'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Cereals', 'Cornflakes ungesüßt', 'not-applicable', null, 'none', '4311501043646'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Dinkel gepufft mit Honig gesüßt', 'not-applicable', null, 'none', '4337256379519'),
  ('DE', 'EnerBiO', 'Grocery', 'Cereals', 'Dinkel Gepufft', 'not-applicable', null, 'none', '4067796001839'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Fruchtringe', 'not-applicable', null, 'none', '4066447663075'),
  ('DE', 'Ja', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4337256415965'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK Cerealien', 'not-applicable', null, 'none', '7613033212949'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Flocons d''Avoine', 'not-applicable', 'Lidl', 'none', '20003166'),
  ('DE', 'Wholey', 'Grocery', 'Cereals', 'Chillo Pillows - Bio-Kakaokissen', 'not-applicable', 'Aldi', 'none', '4260582961519'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'FITNESS Cerealien', 'not-applicable', 'Auchan', 'none', '3387390339499'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Cereals', 'Nougat Bits', 'not-applicable', null, 'none', '4311501720073'),
  ('DE', 'Rewe Bio', 'Grocery', 'Cereals', 'Rewe Bio Haferflocken zart', 'not-applicable', null, 'none', '4337256783132'),
  ('DE', 'Rewe Bio', 'Grocery', 'Cereals', 'Dinkel Flakes', 'not-applicable', null, 'none', '4337256739689'),
  ('DE', 'De-Vau-Ge', 'Grocery', 'Cereals', 'Cornflakes - Nougat Bits', 'not-applicable', null, 'none', '4337256436649'),
  ('DE', 'Edeka', 'Grocery', 'Cereals', 'Haferflocken extra zart', 'not-applicable', null, 'none', '4311501492246'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK WAVES Cerealien', 'not-applicable', 'Lidl', 'none', '7613287433633'),
  ('DE', 'Kellogg''s', 'Grocery', 'Cereals', 'Kellogg''s Smacks', 'not-applicable', 'Aldi', 'none', '5059319023670'),
  ('DE', 'Ja!', 'Grocery', 'Cereals', 'Chico Chips', 'not-applicable', null, 'none', '4337256782531'),
  ('DE', 'Oat-Ly!', 'Grocery', 'Cereals', 'Hafer Barista light', 'not-applicable', null, 'none', '7394376621703'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Dinkel Crunchy', 'not-applicable', null, 'none', '4104420254756'),
  ('DE', 'Oatly!', 'Grocery', 'Cereals', 'Oatly Hafer Barista Edition', 'not-applicable', null, 'none', '7394376617904'),
  ('DE', 'Weetabix', 'Grocery', 'Cereals', 'Weetabix produit à base de blé complet 100%', 'not-applicable', null, 'none', '5010029000023'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Schoko Hafer Crunchy', 'not-applicable', null, 'none', '4104420238244')
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
where country = 'DE' and category = 'Cereals'
  and is_deprecated is not true
  and product_name not in ('Haferflocken, Blütenzarte Köllnflocken', 'E Knusprige Haferfleks Klassik Kölln', 'Erdnußlocken Classic', 'Kernige Haferflocken', 'Puffreis mit Schokolade', 'Zarte Haferflocken', 'Bio-Haferflocken zart', 'Bio Haferflocken zart', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'Vollkorn Haferfleks', 'Cornflakes', 'Haferflocken zart', 'Knusprige Haferfleks Schoko', 'Haferflocken kernig', 'Cornflakes ungesüßt', 'Dinkel gepufft mit Honig gesüßt', 'Dinkel Gepufft', 'Fruchtringe', 'Haferflocken', 'NESTLE NESQUIK Cerealien', 'Flocons d''Avoine', 'Chillo Pillows - Bio-Kakaokissen', 'FITNESS Cerealien', 'Nougat Bits', 'Rewe Bio Haferflocken zart', 'Dinkel Flakes', 'Cornflakes - Nougat Bits', 'Haferflocken extra zart', 'NESTLE NESQUIK WAVES Cerealien', 'Kellogg''s Smacks', 'Chico Chips', 'Hafer Barista light', 'Dinkel Crunchy', 'Oatly Hafer Barista Edition', 'Weetabix produit à base de blé complet 100%', 'Schoko Hafer Crunchy');

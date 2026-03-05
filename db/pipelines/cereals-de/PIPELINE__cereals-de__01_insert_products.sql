-- PIPELINE (Cereals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Cereals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000540000108', '4000540011050', '4018077006203', '4000540000306', '4021700900021', '4061464911895', '4000540000641', '4056489665519', '4000540005028', '4000540011081', '4061459674101', '4061463845337', '4000540091069', '4061464912014', '4311501043646', '4337256379519', '4067796001839', '4337256415965', '7613033212949', '20003166', '4260582961519', '3387390339499', '4311501720073', '4337256783132', '4337256739689', '4337256436649', '4311501492246', '7613287433633', '5411188124689', '7394376621680', '7394376621703', '4104420254756', '7394376617904', '5010029000023', '4104420238244')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferflocken Blütenzart', 'not-applicable', null, 'none', '4000540000108'),
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
  ('DE', 'Dm Bio', 'Grocery', 'Cereals', 'Dinkel Gepufft', 'not-applicable', null, 'none', '4067796001839'),
  ('DE', 'Ja', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4337256415965'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK Cerealien', 'not-applicable', null, 'none', '7613033212949'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Flocons d''Avoine', 'not-applicable', 'Lidl', 'none', '20003166'),
  ('DE', 'Wholey', 'Grocery', 'Cereals', 'Chillo Pillows - Bio-Kakaokissen', 'not-applicable', 'Aldi', 'none', '4260582961519'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'FITNESS Cerealien', 'not-applicable', 'Auchan', 'none', '3387390339499'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Cereals', 'Nougat Bits', 'not-applicable', null, 'none', '4311501720073'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Rewe Bio Haferflocken zart', 'not-applicable', null, 'none', '4337256783132'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Dinkel Flakes', 'not-applicable', null, 'none', '4337256739689'),
  ('DE', 'De-Vau-Ge', 'Grocery', 'Cereals', 'Cornflakes - Nougat Bits', 'not-applicable', null, 'none', '4337256436649'),
  ('DE', 'Edeka', 'Grocery', 'Cereals', 'Haferflocken extra zart', 'not-applicable', null, 'none', '4311501492246'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK WAVES Cerealien', 'not-applicable', 'Lidl', 'none', '7613287433633'),
  ('DE', 'Alpro', 'Grocery', 'Cereals', 'Hafer Milch', 'not-applicable', null, 'none', '5411188124689'),
  ('DE', 'Oatly!', 'Grocery', 'Cereals', 'Haferdrink Barista Bio', 'not-applicable', null, 'none', '7394376621680'),
  ('DE', 'Oatly!', 'Grocery', 'Cereals', 'Hafer Barista light', 'not-applicable', null, 'none', '7394376621703'),
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
  and product_name not in ('Haferflocken Blütenzart', 'E Knusprige Haferfleks Klassik Kölln', 'Erdnußlocken Classic', 'Kernige Haferflocken', 'Puffreis mit Schokolade', 'Zarte Haferflocken', 'Bio-Haferflocken zart', 'Bio Haferflocken zart', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'Vollkorn Haferfleks', 'Cornflakes', 'Haferflocken zart', 'Knusprige Haferfleks Schoko', 'Haferflocken kernig', 'Cornflakes ungesüßt', 'Dinkel gepufft mit Honig gesüßt', 'Dinkel Gepufft', 'Haferflocken', 'NESTLE NESQUIK Cerealien', 'Flocons d''Avoine', 'Chillo Pillows - Bio-Kakaokissen', 'FITNESS Cerealien', 'Nougat Bits', 'Rewe Bio Haferflocken zart', 'Dinkel Flakes', 'Cornflakes - Nougat Bits', 'Haferflocken extra zart', 'NESTLE NESQUIK WAVES Cerealien', 'Hafer Milch', 'Haferdrink Barista Bio', 'Hafer Barista light', 'Dinkel Crunchy', 'Oatly Hafer Barista Edition', 'Weetabix produit à base de blé complet 100%', 'Schoko Hafer Crunchy');

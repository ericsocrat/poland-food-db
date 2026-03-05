-- PIPELINE (Snacks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Snacks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000522105210', '4000381003030', '4011800523312', '4001518104064', '4011800523213', '4001518006450', '4017100706004', '4011800593810', '4018077620003', '4011800521226', '4008258051030', '4056489703990', '4011800523220', '4067796140309', '4008404001001', '5410041001204', '7311070346916', '4104420231658', '20005702', '20045852', '4260654789119', '4260718295884', '4337256723923', '5410041066005', '4250519646527', '3800205872924')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Pom-Bär', 'Grocery', 'Snacks', 'POM-BÄR Original', 'not-applicable', 'Netto', 'none', '4000522105210'),
  ('DE', 'Huober', 'Grocery', 'Snacks', 'Original schwäbische Knusper Brezel', 'not-applicable', null, 'none', '4000381003030'),
  ('DE', 'Schwartauer Corny', 'Grocery', 'Snacks', 'Haferkraft Cranberry Kürbiskern', 'not-applicable', 'Netto', 'none', '4011800523312'),
  ('DE', 'Leicht & Cross', 'Grocery', 'Snacks', 'Leicht & Cross Vollkorn Knäckebrot', 'not-applicable', null, 'none', '4001518104064'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'not-applicable', null, 'none', '4011800523213'),
  ('DE', 'Leicht & Cross', 'Grocery', 'Snacks', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'not-applicable', null, 'none', '4001518006450'),
  ('DE', 'Lorenz', 'Grocery', 'Snacks', 'Lorenz Saltletts Sticks', 'not-applicable', 'Lidl', 'none', '4017100706004'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Haferkraft Zero - Kakao 4er-Pack', 'not-applicable', null, 'none', '4011800593810'),
  ('DE', 'Lorenz', 'Grocery', 'Snacks', 'Clubs Cracker', 'not-applicable', 'Lidl', 'none', '4018077620003'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Corny Schoko', 'not-applicable', 'Netto', 'none', '4011800521226'),
  ('DE', 'Seeberger', 'Grocery', 'Snacks', 'Nuts''n Berries', 'dried', 'Carrefour', 'none', '4008258051030'),
  ('DE', 'Rivercote', 'Grocery', 'Snacks', 'Knusperbrot Weizen', 'not-applicable', null, 'none', '4056489703990'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Corny - Schoko-Banane', 'not-applicable', null, 'none', '4011800523220'),
  ('DE', 'DmBio', 'Grocery', 'Snacks', 'Schoko Reiswaffeln Zartbitter', 'not-applicable', null, 'none', '4067796140309'),
  ('DE', 'Leicht & Cross', 'Grocery', 'Snacks', 'Knusperbrot Goldweizen', 'not-applicable', null, 'none', '4008404001001'),
  ('DE', 'Tuc', 'Grocery', 'Snacks', 'Tuc Original', 'not-applicable', 'Auchan', 'palm oil', '5410041001204'),
  ('DE', 'Pågen', 'Grocery', 'Snacks', 'Gifflar Cannelle', 'not-applicable', 'Carrefour', 'none', '7311070346916'),
  ('DE', 'Alnatura', 'Grocery', 'Snacks', 'Linsenwaffeln', 'not-applicable', null, 'none', '4104420231658'),
  ('DE', 'Alesto', 'Grocery', 'Snacks', 'Cruspies Paprika', 'not-applicable', 'Lidl', 'none', '20005702'),
  ('DE', 'Snack Day', 'Grocery', 'Snacks', 'Erdnuss Flips', 'not-applicable', 'Lidl', 'none', '20045852'),
  ('DE', 'KoRo', 'Grocery', 'Snacks', 'Vegan Protein Bar Chocolate Brownie', 'not-applicable', null, 'none', '4260654789119'),
  ('DE', 'KoRo', 'Grocery', 'Snacks', 'Protein Bar Deluxe', 'not-applicable', null, 'none', '4260718295884'),
  ('DE', 'REWE Bio', 'Grocery', 'Snacks', 'Dattel-Erdnuss Riegel (3er)', 'not-applicable', null, 'none', '4337256723923'),
  ('DE', 'Mondelez', 'Grocery', 'Snacks', 'Paprika', 'not-applicable', null, 'none', '5410041066005'),
  ('DE', 'ESN', 'Grocery', 'Snacks', 'ESN Designer protein bar hazelnut nougat', 'not-applicable', null, 'none', '4250519646527'),
  ('DE', 'Maretti', 'Grocery', 'Snacks', 'Bruschette', 'not-applicable', null, 'none', '3800205872924')
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
where country = 'DE' and category = 'Snacks'
  and is_deprecated is not true
  and product_name not in ('POM-BÄR Original', 'Original schwäbische Knusper Brezel', 'Haferkraft Cranberry Kürbiskern', 'Leicht & Cross Vollkorn Knäckebrot', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'Lorenz Saltletts Sticks', 'Haferkraft Zero - Kakao 4er-Pack', 'Clubs Cracker', 'Corny Schoko', 'Nuts''n Berries', 'Knusperbrot Weizen', 'Corny - Schoko-Banane', 'Schoko Reiswaffeln Zartbitter', 'Knusperbrot Goldweizen', 'Tuc Original', 'Gifflar Cannelle', 'Linsenwaffeln', 'Cruspies Paprika', 'Erdnuss Flips', 'Vegan Protein Bar Chocolate Brownie', 'Protein Bar Deluxe', 'Dattel-Erdnuss Riegel (3er)', 'Paprika', 'ESN Designer protein bar hazelnut nougat', 'Bruschette');

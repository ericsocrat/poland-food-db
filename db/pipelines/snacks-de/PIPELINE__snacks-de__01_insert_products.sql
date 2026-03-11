-- PIPELINE (Snacks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Snacks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000522105210', '4000381003030', '4011800523312', '4001518104064', '4011800523213', '4001518006450', '4017100706004', '4011800593810', '4018077620003', '4008258051030', '4011800549411', '4011800562212', '4056489703990', '4011800521219', '4011800523220', '4067796140309', '4008404001001', '4066447599466', '5410041001204', '7311070346916', '4104420231658', '20005702', '20045852', '4260654789119', '4260718295884', '4337256723923', '5410041066005', '4250519646527', '3800205872924')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Snacks by pipeline',
    ean = null
where country = 'DE'
  and category != 'Snacks'
  and identity_key in ('0db304534f536b8ab83237f22071aca3', '1e7eeab37dd72c286b5860b0383eef17', '2e4922df619e4a643c5fd6548895070f', '349a64cfbf6e78d7537eb35046f10d44', '372e0ee969020a73b5c3c0d2504f7c04', '440b899a3e1911441134b90d586d4325', '4ace69faa9a9747d1e695b4e49fa6781', '53af11c66f8ae06ef324eaa998f1c981', '631611f230ff8035d57ad0313c4095a9', '6b158d63961b0acd160ff463c6de62df', '7b4e05f14d9d7d476e1e5e94a7dc957e', '8bade5b6f6b275c94f612ac316c1844c', '8cd7c46cd24ef622532cc01313c6ebbe', '9081f35c0cba4a1fd588511d90649f1e', '9d90ea4d6dc892d589a47e1c429ba50d', 'aec8173455d84cd8b8df3a5318a3c653', 'b0bd4710ef59d8ffa804dc425db5d011', 'b4b649cf395704c87ab472f828485ff5', 'b642c59c7771ebdd07f87590f811d5a3', 'b6c1fa6d09678f9824ccc645be1813e1', 'cd34113e20e4b9a0ff204fc8ac2d9dae', 'd81f2464af2077801e7ec31d324b5578', 'ded8d61db7a4a3b0fdc7877dedd2c364', 'e02820889b285440795ffa0cc7ee2c8d', 'e0d647ea48a88edcbf2bfadbf7ba7696', 'e4a04809eae9c51c95cb47df3f27113a', 'f8fe7d3737d102ff8d3e82ac013dc991', 'f9c95185266201b980015be840e849ad', 'f9febfe6ca18c1eff3605aa0673a483c')
  and is_deprecated is not true;

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
  ('DE', 'Seeberger', 'Grocery', 'Snacks', 'Nuts''n Berries', 'dried', 'Carrefour', 'none', '4008258051030'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Nussvoll Nuss &Traube', 'not-applicable', null, 'none', '4011800549411'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Milch Classic', 'not-applicable', null, 'none', '4011800562212'),
  ('DE', 'Rivercote', 'Grocery', 'Snacks', 'Knusperbrot Weizen', 'not-applicable', null, 'none', '4056489703990'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'CORNY Schoko', 'not-applicable', null, 'none', '4011800521219'),
  ('DE', 'Corny', 'Grocery', 'Snacks', 'Corny - Schoko-Banane', 'not-applicable', null, 'none', '4011800523220'),
  ('DE', 'DmBio', 'Grocery', 'Snacks', 'Schoko Reiswaffeln Zartbitter', 'not-applicable', null, 'none', '4067796140309'),
  ('DE', 'Leicht & Cross', 'Grocery', 'Snacks', 'Knusperbrot Goldweizen', 'not-applicable', null, 'none', '4008404001001'),
  ('DE', 'DmBio', 'Grocery', 'Snacks', 'Dinkel Mini brezeln', 'not-applicable', null, 'none', '4066447599466'),
  ('DE', 'Tuc', 'Grocery', 'Snacks', 'Tuc Original', 'not-applicable', 'Auchan', 'palm oil', '5410041001204'),
  ('DE', 'Pågen', 'Grocery', 'Snacks', 'Gifflar Cannelle', 'not-applicable', 'Carrefour', 'none', '7311070346916'),
  ('DE', 'Alnatura', 'Grocery', 'Snacks', 'Linsenwaffeln', 'not-applicable', null, 'none', '4104420231658'),
  ('DE', 'Alesto', 'Grocery', 'Snacks', 'Cruspies Paprika', 'not-applicable', 'Lidl', 'none', '20005702'),
  ('DE', 'Snack Day', 'Grocery', 'Snacks', 'Erdnuss Flips', 'not-applicable', 'Lidl', 'none', '20045852'),
  ('DE', 'KoRo', 'Grocery', 'Snacks', 'Vegan Protein Bar Chocolate Brownie', 'not-applicable', null, 'none', '4260654789119'),
  ('DE', 'KoRo', 'Grocery', 'Snacks', 'Protein Bar Deluxe', 'not-applicable', null, 'none', '4260718295884'),
  ('DE', 'REWE Bio', 'Grocery', 'Snacks', 'Dattel-Erdnuss Riegel (3er)', 'not-applicable', null, 'none', '4337256723923'),
  ('DE', 'Mondelez', 'Grocery', 'Snacks', 'Paprika', 'not-applicable', null, 'none', '5410041066005'),
  ('DE', 'ESN', 'Grocery', 'Snacks', 'Designer Protein Bar', 'not-applicable', null, 'none', '4250519646527'),
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
  and product_name not in ('POM-BÄR Original', 'Original schwäbische Knusper Brezel', 'Haferkraft Cranberry Kürbiskern', 'Leicht & Cross Vollkorn Knäckebrot', 'Corny Schoko-Banane 4011800523213 Müsliriegel', 'Knäckebrot Vital: Vitamine und Mehrkorn', 'Lorenz Saltletts Sticks', 'Haferkraft Zero - Kakao 4er-Pack', 'Clubs Cracker', 'Nuts''n Berries', 'Nussvoll Nuss &Traube', 'Milch Classic', 'Knusperbrot Weizen', 'CORNY Schoko', 'Corny - Schoko-Banane', 'Schoko Reiswaffeln Zartbitter', 'Knusperbrot Goldweizen', 'Dinkel Mini brezeln', 'Tuc Original', 'Gifflar Cannelle', 'Linsenwaffeln', 'Cruspies Paprika', 'Erdnuss Flips', 'Vegan Protein Bar Chocolate Brownie', 'Protein Bar Deluxe', 'Dattel-Erdnuss Riegel (3er)', 'Paprika', 'Designer Protein Bar', 'Bruschette');

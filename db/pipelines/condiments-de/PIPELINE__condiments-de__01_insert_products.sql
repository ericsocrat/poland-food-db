-- PIPELINE (Condiments): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Condiments'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4027400148008', '4061458084185', '4400139000241', '4061458084192', '4061458032070', '4027400070361', '4027400148343', '4027400148244', '4027400148596', '4006824998819', '4027400148398', '4027400148121', '4027400148091', '4027400148060', '4061463721204', '4056489139393', '4058172287459', '4056489617181', '4400139000067', '4056489604471', '4061459416329', '4061462342639', '4056489640585', '4400139000647', '4400139006540', '4005009101303', '4061459416176', '4061463502391', '4027400168105', '4021851557242', '4006824003551', '4400139006045', '4012860004582', '4027400102116', '4400139000838', '4063367537813', '4061462342448', '4018462157701', '4063367508011', '4400139018536', '4027400102055', '4400191061563', '4002442820815', '4400191050017', '4005009106759', '4027400172805', '4019736003748', '4006824002639', '4337185752339', '4400139018178', '4021851556603')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürzketchup Curry', 'not-applicable', 'Kaufland', 'none', '4027400148008'),
  ('DE', 'Aldi', 'Grocery', 'Condiments', 'Curry-Gewürzketchup - delikat', 'not-applicable', 'Aldi', 'none', '4061458084185'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Gewürz Ketchup', 'not-applicable', 'Netto', 'none', '4400139000241'),
  ('DE', 'Delikato', 'Grocery', 'Condiments', 'Curry-Gewürzketchup - scharf', 'not-applicable', 'Aldi', 'none', '4061458084192'),
  ('DE', 'American', 'Grocery', 'Condiments', 'Würzsauce 2 in 1 - Ketchup & Senf', 'not-applicable', 'Aldi', 'none', '4061458032070'),
  ('DE', 'HELA Gewürz Ketchup', 'Grocery', 'Condiments', 'Gewürz Ketchup Curry Scharf', 'not-applicable', 'Netto', 'none', '4027400070361'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürz Ketchup Curry', 'not-applicable', null, 'none', '4027400148343'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürz Ketchup Curry Delikat 30%', 'not-applicable', null, 'none', '4027400148244'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Soße Curry Ketchup', 'not-applicable', null, 'none', '4027400148596'),
  ('DE', 'Develey', 'Grocery', 'Condiments', 'VW Ketchup Gewürz', 'not-applicable', null, 'none', '4006824998819'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürz Ketchup Curry Leicht Scharf', 'not-applicable', null, 'none', '4027400148398'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürzketchup Tomate', 'not-applicable', null, 'none', '4027400148121'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Hela Schaschlik Gewürz- Ketchup', 'not-applicable', null, 'none', '4027400148091'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Gewürz Ketchup Curry Extra Scharf', 'not-applicable', null, 'none', '4027400148060'),
  ('DE', 'Delikato', 'Grocery', 'Condiments', 'Tomatenketchup', 'not-applicable', 'Aldi', 'none', '4061463721204'),
  ('DE', 'Kania', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', 'Lidl', 'none', '4056489139393'),
  ('DE', 'DmBio', 'Grocery', 'Condiments', 'Jemný kečup', 'not-applicable', null, 'none', '4058172287459'),
  ('DE', 'Kania', 'Grocery', 'Condiments', 'Tomato Ketchup', 'not-applicable', 'Lidl', 'none', '4056489617181'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Tomatenketchup von Werder', 'not-applicable', 'Kaufland', 'none', '4400139000067'),
  ('DE', 'Jütro', 'Grocery', 'Condiments', 'Tomaten Ketchup', 'not-applicable', 'Lidl', 'none', '4056489604471'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Condiments', 'Bio-Tomatenketchup - Klassik', 'not-applicable', 'Aldi', 'none', '4061459416329'),
  ('DE', 'Delikato', 'Grocery', 'Condiments', 'Tomatenketchup Light', 'not-applicable', 'Aldi', 'none', '4061462342639'),
  ('DE', 'Kania', 'Grocery', 'Condiments', 'Kečup', 'not-applicable', 'Lidl', 'none', '4056489640585'),
  ('DE', 'La Vialla', 'Grocery', 'Condiments', 'Premium Tomatenketchup', 'not-applicable', 'Kaufland', 'none', '4400139000647'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Barbecue Sauce', 'not-applicable', 'Netto', 'none', '4400139006540'),
  ('DE', 'Bio Zentrale', 'Grocery', 'Condiments', 'Tomaten Ketchup', 'not-applicable', null, 'none', '4005009101303'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Condiments', 'Bio-Tomatenketchup - Curry', 'not-applicable', 'Aldi', 'none', '4061459416176'),
  ('DE', 'Gourmet Finest Cuisine', 'Grocery', 'Condiments', 'Steakhouse-Ketchup mit Fleur de Sel', 'not-applicable', 'Aldi', 'none', '4061463502391'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Curry Ketchup', 'not-applicable', 'Aldi', 'none', '4027400168105'),
  ('DE', 'Dennree', 'Grocery', 'Condiments', 'Gewürz Ketchup', 'not-applicable', null, 'none', '4021851557242'),
  ('DE', 'Develey', 'Grocery', 'Condiments', 'Ketchup - Tomaten Ketchup', 'not-applicable', null, 'none', '4006824003551'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Tomatenketchup ohne Zuckerzusatz', 'not-applicable', null, 'none', '4400139006045'),
  ('DE', 'Bautz''ner', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', null, 'none', '4012860004582'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Tomaten-Ketchup', 'not-applicable', null, 'none', '4027400102116'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Tomaten Ketchup', 'not-applicable', null, 'none', '4400139000838'),
  ('DE', 'K-Bio', 'Grocery', 'Condiments', 'Tomatenketchup', 'not-applicable', null, 'none', '4063367537813'),
  ('DE', 'Delikato', 'Grocery', 'Condiments', 'Tomatenketchup Hot Chili', 'not-applicable', null, 'none', '4061462342448'),
  ('DE', 'Byodo', 'Grocery', 'Condiments', 'Kinder ketchup', 'not-applicable', null, 'none', '4018462157701'),
  ('DE', 'K-Classic', 'Grocery', 'Condiments', 'Tomatenketchup', 'not-applicable', null, 'none', '4063367508011'),
  ('DE', 'Curry36', 'Grocery', 'Condiments', 'Tomatenketchup', 'not-applicable', null, 'none', '4400139018536'),
  ('DE', 'Tomatenketchup', 'Grocery', 'Condiments', 'Tomatenketchup Original Bio', 'not-applicable', null, 'none', '4027400102055'),
  ('DE', 'Born', 'Grocery', 'Condiments', 'Tomatenketchup', 'not-applicable', null, 'none', '4400191061563'),
  ('DE', 'Kaufland Classic', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', null, 'none', '4002442820815'),
  ('DE', 'Born', 'Grocery', 'Condiments', 'Tomaten Ketchup', 'not-applicable', null, 'none', '4400191050017'),
  ('DE', 'Bio-Zentrale', 'Grocery', 'Condiments', 'Biokids Tomatenketchup', 'not-applicable', null, 'none', '4005009106759'),
  ('DE', 'Hela', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', null, 'none', '4027400172805'),
  ('DE', 'Zwergenwiese', 'Grocery', 'Condiments', 'Tomatensauce', 'not-applicable', null, 'none', '4019736003748'),
  ('DE', 'Develey', 'Grocery', 'Condiments', 'Ketchup develey', 'not-applicable', null, 'none', '4006824002639'),
  ('DE', 'K-Classic', 'Grocery', 'Condiments', 'Curry Gewürz Ketchup scharf', 'not-applicable', 'Kaufland', 'none', '4337185752339'),
  ('DE', 'Werder', 'Grocery', 'Condiments', 'Kinder Bio Ketchup', 'not-applicable', null, 'none', '4400139018178'),
  ('DE', 'Dennree', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', null, 'none', '4021851556603')
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
where country = 'DE' and category = 'Condiments'
  and is_deprecated is not true
  and product_name not in ('Gewürzketchup Curry', 'Curry-Gewürzketchup - delikat', 'Gewürz Ketchup', 'Curry-Gewürzketchup - scharf', 'Würzsauce 2 in 1 - Ketchup & Senf', 'Gewürz Ketchup Curry Scharf', 'Gewürz Ketchup Curry', 'Gewürz Ketchup Curry Delikat 30%', 'Soße Curry Ketchup', 'VW Ketchup Gewürz', 'Gewürz Ketchup Curry Leicht Scharf', 'Gewürzketchup Tomate', 'Hela Schaschlik Gewürz- Ketchup', 'Gewürz Ketchup Curry Extra Scharf', 'Tomatenketchup', 'Ketchup', 'Jemný kečup', 'Tomato Ketchup', 'Tomatenketchup von Werder', 'Tomaten Ketchup', 'Bio-Tomatenketchup - Klassik', 'Tomatenketchup Light', 'Kečup', 'Premium Tomatenketchup', 'Barbecue Sauce', 'Tomaten Ketchup', 'Bio-Tomatenketchup - Curry', 'Steakhouse-Ketchup mit Fleur de Sel', 'Curry Ketchup', 'Gewürz Ketchup', 'Ketchup - Tomaten Ketchup', 'Tomatenketchup ohne Zuckerzusatz', 'Ketchup', 'Tomaten-Ketchup', 'Tomaten Ketchup', 'Tomatenketchup', 'Tomatenketchup Hot Chili', 'Kinder ketchup', 'Tomatenketchup', 'Tomatenketchup', 'Tomatenketchup Original Bio', 'Tomatenketchup', 'Ketchup', 'Tomaten Ketchup', 'Biokids Tomatenketchup', 'Ketchup', 'Tomatensauce', 'Ketchup develey', 'Curry Gewürz Ketchup scharf', 'Kinder Bio Ketchup', 'Ketchup');

-- PIPELINE (Canned Goods): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Canned Goods'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4056489254676', '40081410', '4061459714517', '4012200046654', '4061458024501', '4037300108217', '40804651', '4012712001547', '4037300108293', '4037300108491', '4061458020015', '4005500330318', '4037300108231', '4037300104356', '4047247086769', '4037300103236', '4012200417409', '4056489254683', '4020500922011', '4061463307743', '4061462630682', '4061462529290', '40081076', '4061461968052', '40081236', '4006922000407', '4061458004244', '4037300104011', '4058172268717', '4037300108248', '4006922001602', '40081922', '4056489152736', '4020500922127', '4020500922158', '4037300104004', '4047247495820', '40081243', '4061458004114', '4009239608694', '4047247097161', '20153229', '4337256353014', '4037300108309', '4061459112061', '4063367379833', '4005500339403', '4311596446117', '8005110060007', '4061459999075', '4037300108460')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Nixe - LIDL', 'Grocery', 'Canned Goods', 'Thunfisch Filets in Sonnenblumenöl', 'not-applicable', 'Lidl', 'none', '4056489254676'),
  ('DE', 'Hengstenberg', 'Grocery', 'Canned Goods', 'KNAX Gewürzgurken', 'not-applicable', null, 'none', '40081410'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Bio-Gewürzgurken', 'not-applicable', 'Aldi', 'none', '4061459714517'),
  ('DE', 'Kuehne', 'Grocery', 'Canned Goods', 'Schlemmertöpfchen gew. Gurken', 'not-applicable', null, 'none', '4012200046654'),
  ('DE', 'Wonnemeyer', 'Grocery', 'Canned Goods', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 'not-applicable', 'Aldi', 'none', '4061458024501'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Grüne-Bohnen-Eintopf', 'not-applicable', 'Lidl', 'none', '4037300108217'),
  ('DE', 'Kühne', 'Grocery', 'Canned Goods', 'Gewürzgurken', 'not-applicable', null, 'none', '40804651'),
  ('DE', 'Spreewaldhof', 'Grocery', 'Canned Goods', 'Spreelinge Gewürzgurken', 'not-applicable', null, 'none', '4012712001547'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Linseneintopf mit Würstchen', 'not-applicable', null, 'none', '4037300108293'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Erasco Kartoffelsuppe m. Würstchen', 'not-applicable', null, 'none', '4037300108491'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Sardinen in Sonnenblumenöl - Klassik', 'not-applicable', null, 'none', '4061458020015'),
  ('DE', 'Nestlé', 'Grocery', 'Canned Goods', 'Ravioli Gemüse', 'not-applicable', null, 'none', '4005500330318'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Westfälische Linsen Eintopf', 'not-applicable', null, 'none', '4037300108231'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Hühner Reis-Topf', 'not-applicable', null, 'none', '4037300104356'),
  ('DE', 'King''s Crown', 'Grocery', 'Canned Goods', 'Erbsen und Möhren sehr fein', 'not-applicable', null, 'none', '4047247086769'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'not-applicable', null, 'none', '4037300103236'),
  ('DE', 'Kühne', 'Grocery', 'Canned Goods', 'Gurken Sauer Honig Schlemmertöpfchen', 'not-applicable', null, 'none', '4012200417409'),
  ('DE', 'Nixe', 'Grocery', 'Canned Goods', 'Thunfisch', 'not-applicable', 'Lidl', 'none', '4056489254683'),
  ('DE', 'Appel', 'Grocery', 'Canned Goods', 'Zarte Filets vom Hering in Tomaten-Creme', 'not-applicable', 'Netto', 'none', '4020500922011'),
  ('DE', 'KING''S CROWN (Aldi)', 'Grocery', 'Canned Goods', 'Tomatenmark', 'not-applicable', 'Aldi', 'none', '4061463307743'),
  ('DE', 'Almare Seafood', 'Grocery', 'Canned Goods', 'Thunfisch Filets in eigenen Saft', 'not-applicable', 'Aldi', 'none', '4061462630682'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Tomatenmark', 'not-applicable', 'Aldi', 'none', '4061462529290'),
  ('DE', 'Oro Di Parma', 'Grocery', 'Canned Goods', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'not-applicable', 'Netto', 'none', '40081076'),
  ('DE', 'King''s Crown', 'Grocery', 'Canned Goods', 'Tomaten gehackt', 'not-applicable', 'Aldi', 'none', '4061461968052'),
  ('DE', 'Oro Di Parma', 'Grocery', 'Canned Goods', 'Tomaten', 'not-applicable', 'Kaufland', 'none', '40081236'),
  ('DE', 'Hawesta', 'Grocery', 'Canned Goods', 'Heringsfilets - Tomaten-Creme', 'not-applicable', null, 'none', '4006922000407'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Cornichons', 'not-applicable', 'Aldi', 'none', '4061458004244'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Vegetarischer linsen-eintopf', 'not-applicable', 'Lidl', 'none', '4037300104011'),
  ('DE', 'DmBio', 'Grocery', 'Canned Goods', 'Tomatenmark', 'not-applicable', null, 'none', '4058172268717'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Erbsensuppe Hubertus', 'not-applicable', 'Lidl', 'none', '4037300108248'),
  ('DE', 'Hawesta', 'Grocery', 'Canned Goods', 'Heringsfilets - Pfeffercreme', 'not-applicable', null, 'none', '4006922001602'),
  ('DE', 'Hengstenberg', 'Grocery', 'Canned Goods', 'Mildes Weinsauerkraut', 'fermented', null, 'none', '40081922'),
  ('DE', 'Bio Organic', 'Grocery', 'Canned Goods', 'Rote Beete', 'raw', 'Lidl', 'none', '4056489152736'),
  ('DE', 'Appel', 'Grocery', 'Canned Goods', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'not-applicable', 'Kaufland', 'none', '4020500922127'),
  ('DE', 'Appel', 'Grocery', 'Canned Goods', 'Zarte Filets vom Hering Tomate-Mozzarella', 'not-applicable', null, 'none', '4020500922158'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Erbseneintopf', 'not-applicable', null, 'none', '4037300104004'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Mais', 'not-applicable', 'Aldi', 'none', '4047247495820'),
  ('DE', 'Hengstenberg', 'Grocery', 'Canned Goods', 'Tomaten - Passiert', 'not-applicable', 'Kaufland', 'none', '40081243'),
  ('DE', 'Sweet Valley', 'Grocery', 'Canned Goods', 'Pfirsiche halbe Frucht, leicht gezuckert', 'not-applicable', 'Aldi', 'none', '4061458004114'),
  ('DE', 'Deutsche See', 'Grocery', 'Canned Goods', 'Thunfisch im Aufguss', 'not-applicable', null, 'none', '4009239608694'),
  ('DE', 'King''s Crown', 'Grocery', 'Canned Goods', 'Rote Beete in Kugeln', 'not-applicable', 'Aldi', 'none', '4047247097161'),
  ('DE', 'Freshona', 'Grocery', 'Canned Goods', 'Sonnenmais natursüß', 'not-applicable', 'Lidl', 'none', '20153229'),
  ('DE', 'REWE Bio', 'Grocery', 'Canned Goods', 'Tomaten in Stücken', 'not-applicable', null, 'none', '4337256353014'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Erasco Erbsen-Eintopf 4037300108309', 'not-applicable', null, 'none', '4037300108309'),
  ('DE', 'Aldi', 'Grocery', 'Canned Goods', 'Gehackte Tomaten', 'not-applicable', null, 'none', '4061459112061'),
  ('DE', 'K-Classic', 'Grocery', 'Canned Goods', 'Thunfisch Filets I.E.S', 'not-applicable', null, 'none', '4063367379833'),
  ('DE', 'Nestlé', 'Grocery', 'Canned Goods', 'Dosen Ravioli', 'not-applicable', null, 'none', '4005500339403'),
  ('DE', 'Edeka', 'Grocery', 'Canned Goods', 'Delikatess Gewürzgurken', 'not-applicable', null, 'none', '4311596446117'),
  ('DE', 'Mutti', 'Grocery', 'Canned Goods', 'Geschälte Italienische Tomaten', 'not-applicable', 'Tesco', 'none', '8005110060007'),
  ('DE', 'Sweet Valley', 'Grocery', 'Canned Goods', 'ALDI SWEET VALLEY OBST Ananas in Scheiben ohne Zuckerzusatz', 'not-applicable', null, 'none', '4061459999075'),
  ('DE', 'Erasco', 'Grocery', 'Canned Goods', 'Serbische Bohnensuppe', 'not-applicable', null, 'none', '4037300108460')
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
where country = 'DE' and category = 'Canned Goods'
  and is_deprecated is not true
  and product_name not in ('Thunfisch Filets in Sonnenblumenöl', 'KNAX Gewürzgurken', 'Bio-Gewürzgurken', 'Schlemmertöpfchen gew. Gurken', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 'Grüne-Bohnen-Eintopf', 'Gewürzgurken', 'Spreelinge Gewürzgurken', 'Linseneintopf mit Würstchen', 'Erasco Kartoffelsuppe m. Würstchen', 'Sardinen in Sonnenblumenöl - Klassik', 'Ravioli Gemüse', 'Westfälische Linsen Eintopf', 'Hühner Reis-Topf', 'Erbsen und Möhren sehr fein', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'Gurken Sauer Honig Schlemmertöpfchen', 'Thunfisch', 'Zarte Filets vom Hering in Tomaten-Creme', 'Tomatenmark', 'Thunfisch Filets in eigenen Saft', 'Tomatenmark', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'Tomaten gehackt', 'Tomaten', 'Heringsfilets - Tomaten-Creme', 'Cornichons', 'Vegetarischer linsen-eintopf', 'Tomatenmark', 'Erbsensuppe Hubertus', 'Heringsfilets - Pfeffercreme', 'Mildes Weinsauerkraut', 'Rote Beete', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'Zarte Filets vom Hering Tomate-Mozzarella', 'Erbseneintopf', 'Mais', 'Tomaten - Passiert', 'Pfirsiche halbe Frucht, leicht gezuckert', 'Thunfisch im Aufguss', 'Rote Beete in Kugeln', 'Sonnenmais natursüß', 'Tomaten in Stücken', 'Erasco Erbsen-Eintopf 4037300108309', 'Gehackte Tomaten', 'Thunfisch Filets I.E.S', 'Dosen Ravioli', 'Delikatess Gewürzgurken', 'Geschälte Italienische Tomaten', 'ALDI SWEET VALLEY OBST Ananas in Scheiben ohne Zuckerzusatz', 'Serbische Bohnensuppe');

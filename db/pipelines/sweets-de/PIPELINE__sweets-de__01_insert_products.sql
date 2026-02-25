-- PIPELINE (Sweets): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-25

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Sweets'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('40084060', '4000417693310', '40084107', '4056489471264', '4061458021630', '4000417693815', '4061462044809', '40896243', '4061458021593', '4000417602015', '4000417602510', '4061459208078', '4000417601810', '4000417602619', '4000539150869', '4000417670014', '4000607151200', '4061462452772', '4000417602114', '4006814001796', '4030387760866', '4061458021616', '4061458022002', '4061458160964', '4000417670915', '4000539003509', '40896250', '4000417629418', '4000417693211', '4000417670410', '4000539671203', '4000607151002', '4008400524023', '4000417602718', '4000417602213', '4000417621412', '4025700001450', '4000417601216', '4061458021753', '4061458021883', '4006040488897', '4000417622211', '4000417623713', '4000607730900', '4000417601513', '4008400511825', '4014400917956', '4061458021647', '4000417106100', '4000417670311', '4000417628510')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'not-applicable', 'Lidl', 'none', '40084060'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao-Klasse Die Kräftige 74%', 'not-applicable', null, 'none', '4000417693310'),
  ('DE', 'Kinder', 'Grocery', 'Sweets', 'Überraschung', 'not-applicable', null, 'none', '40084107'),
  ('DE', 'J. D. Gross', 'Grocery', 'Sweets', 'Edelbitter Mild 90%', 'not-applicable', 'Lidl', 'none', '4056489471264'),
  ('DE', 'Moser Roth', 'Grocery', 'Sweets', 'Edelbitter-Schokolade 85 % Cacao', 'not-applicable', 'Aldi', 'none', '4061458021630'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao Klasse die Starke - 81%', 'not-applicable', 'Aldi', 'none', '4000417693815'),
  ('DE', 'Moser Roth', 'Grocery', 'Sweets', 'Edelbitter 90 % Cacao', 'not-applicable', 'Aldi', 'none', '4061462044809'),
  ('DE', 'Lidl', 'Grocery', 'Sweets', 'Lidl Organic Dark Chocolate', 'not-applicable', 'Lidl', 'none', '40896243'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Edelbitter-Schokolade 70% Cacao', 'not-applicable', 'Aldi', 'none', '4061458021593'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Schokolade Halbbitter', 'not-applicable', null, 'none', '4000417602015'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Marzipan', 'not-applicable', 'Lidl', 'none', '4000417602510'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Edelbitter- Schokolade', 'not-applicable', 'Aldi', 'none', '4061459208078'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Alpenmilch', 'not-applicable', 'Netto', 'none', '4000417601810'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport Nugat', 'not-applicable', 'Netto', 'none', '4000417602619'),
  ('DE', 'Lindt', 'Grocery', 'Sweets', 'Lindt Dubai Style Chocolade', 'not-applicable', null, 'none', '4000539150869'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport Voll-Nuss', 'not-applicable', null, 'none', '4000417670014'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Schogetten originals: Edel-Zartbitter', 'not-applicable', null, 'none', '4000607151200'),
  ('DE', 'Choceur', 'Grocery', 'Sweets', 'Aldi-Gipfel', 'not-applicable', 'Aldi', 'none', '4061462452772'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Edel-Vollmilch', 'not-applicable', 'Kaufland', 'none', '4000417602114'),
  ('DE', 'Müller & Müller GmbH', 'Grocery', 'Sweets', 'Blockschokolade', 'not-applicable', null, 'none', '4006814001796'),
  ('DE', 'Sarotti', 'Grocery', 'Sweets', 'Mild 85%', 'not-applicable', null, 'none', '4030387760866'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Nussknacker - Vollmilchschokolade', 'not-applicable', 'Aldi', 'none', '4061458021616'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Nussknacker - Zartbitterschokolade', 'not-applicable', 'Aldi', 'none', '4061458022002'),
  ('DE', 'Back Family', 'Grocery', 'Sweets', 'Schoko-Chunks - Zartbitter', 'not-applicable', 'Aldi', 'none', '4061458160964'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Pistachio', 'not-applicable', 'Tesco', 'none', '4000417670915'),
  ('DE', 'Lindt', 'Grocery', 'Sweets', 'Excellence Mild 70%', 'not-applicable', null, 'none', '4000539003509'),
  ('DE', 'Fairglobe', 'Grocery', 'Sweets', 'Bio Vollmilch-Schokolade', 'not-applicable', 'Lidl', 'none', '40896250'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao-Mousse', 'not-applicable', null, 'none', '4000417629418'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao Klasse 61 die feine aus Nicaragua', 'not-applicable', null, 'none', '4000417693211'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport Honig Salz Mandel', 'not-applicable', 'Netto', 'none', '4000417670410'),
  ('DE', 'Lindt', 'Grocery', 'Sweets', 'Gold Bunny', 'not-applicable', 'Kaufland', 'none', '4000539671203'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Schogetten - Edel-Alpenvollmilchschokolade', 'not-applicable', null, 'none', '4000607151002'),
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Kinder Osterhase - Harry Hase', 'not-applicable', 'Netto', 'none', '4008400524023'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Joghurt', 'not-applicable', 'Netto', 'none', '4000417602718'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Trauben Nuss', 'not-applicable', 'Netto', 'none', '4000417602213'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Knusperkeks', 'not-applicable', null, 'none', '4000417621412'),
  ('DE', 'Milka', 'Grocery', 'Sweets', 'Schokolade Joghurt', 'not-applicable', 'Żabka', 'none', '4025700001450'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Rum Trauben Nuss Schokolade', 'not-applicable', null, 'none', '4000417601216'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Schokolade (Alpen-Sahne-)', 'not-applicable', 'Aldi', 'none', '4061458021753'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Erdbeer-Joghurt', 'not-applicable', 'Aldi', 'none', '4061458021883'),
  ('DE', 'Rapunzel', 'Grocery', 'Sweets', 'Nirwana Vegan', 'not-applicable', null, 'none', '4006040488897'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Haselnuss', 'not-applicable', null, 'none', '4000417622211'),
  ('DE', 'Ritter SPORT', 'Grocery', 'Sweets', 'Ritter Sport Erdbeer', 'not-applicable', null, 'none', '4000417623713'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Schogetten Edel-Zartbitter-Haselnuss', 'not-applicable', 'Kaufland', 'none', '4000607730900'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Amicelli', 'not-applicable', null, 'none', '4000417601513'),
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Kinder Weihnachtsmann', 'not-applicable', null, 'none', '4008400511825'),
  ('DE', 'Merci', 'Grocery', 'Sweets', 'Finest Selection Mandel Knusper Vielfalt', 'not-applicable', null, 'none', '4014400917956'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Rahm Mandel', 'not-applicable', 'Aldi', 'none', '4061458021647'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Vegan Roasted Peanut', 'roasted', null, 'none', '4000417106100'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Nussklasse Ganze Mandel', 'not-applicable', null, 'none', '4000417670311'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport Lemon', 'not-applicable', null, 'none', '4000417628510')
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
where country = 'DE' and category = 'Sweets'
  and is_deprecated is not true
  and product_name not in ('Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'Kakao-Klasse Die Kräftige 74%', 'Überraschung', 'Edelbitter Mild 90%', 'Edelbitter-Schokolade 85 % Cacao', 'Kakao Klasse die Starke - 81%', 'Edelbitter 90 % Cacao', 'Lidl Organic Dark Chocolate', 'Edelbitter-Schokolade 70% Cacao', 'Schokolade Halbbitter', 'Marzipan', 'Edelbitter- Schokolade', 'Alpenmilch', 'Ritter Sport Nugat', 'Lindt Dubai Style Chocolade', 'Ritter Sport Voll-Nuss', 'Schogetten originals: Edel-Zartbitter', 'Aldi-Gipfel', 'Edel-Vollmilch', 'Blockschokolade', 'Mild 85%', 'Nussknacker - Vollmilchschokolade', 'Nussknacker - Zartbitterschokolade', 'Schoko-Chunks - Zartbitter', 'Pistachio', 'Excellence Mild 70%', 'Bio Vollmilch-Schokolade', 'Kakao-Mousse', 'Kakao Klasse 61 die feine aus Nicaragua', 'Ritter Sport Honig Salz Mandel', 'Gold Bunny', 'Schogetten - Edel-Alpenvollmilchschokolade', 'Kinder Osterhase - Harry Hase', 'Joghurt', 'Trauben Nuss', 'Knusperkeks', 'Schokolade Joghurt', 'Rum Trauben Nuss Schokolade', 'Schokolade (Alpen-Sahne-)', 'Erdbeer-Joghurt', 'Nirwana Vegan', 'Haselnuss', 'Ritter Sport Erdbeer', 'Schogetten Edel-Zartbitter-Haselnuss', 'Amicelli', 'Kinder Weihnachtsmann', 'Finest Selection Mandel Knusper Vielfalt', 'Rahm Mandel', 'Vegan Roasted Peanut', 'Nussklasse Ganze Mandel', 'Ritter Sport Lemon');

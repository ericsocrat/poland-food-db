-- PIPELINE (Sweets): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Sweets'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('40084060', '4061458160971', '4008400230726', '4000607850011', '4000607167706', '4002809024306', '4000417693310', '40084107', '4000417670113', '4014400932904', '4061463588951', '40084909', '4001743760219', '4006040202844', '4061458021630', '4000417693815', '40896243', '4061458021593', '4000417602015', '4000417602510', '4061459208078', '4000417601810', '4000417602619', '4000539150869', '4000417670014', '4000607151200', '4061462452772', '4000417602114', '4006814001796', '4030387760866', '4061458021616', '4061458022002', '4061458160964', '4000417670915', '4000539003509', '40896250', '4000417629418', '4000417693211', '4000417670410', '4000539671203', '4000607151002', '4008400524023', '4000417602718', '4000417602213', '4000417621412', '4025700001450', '4000417601216', '4061458021753', '4061458021883', '4006040488897', '4000417622211', '4000417623713', '4000607730900', '4000417601513', '4008400511825', '4014400917956', '4061458021647', '4000417106100', '4000417670311', '4047247273459', '4000417628510', '4061458042963', '4021700903053', '4000417629616', '4061458021555', '4013320185629', '4000417628411', '4056489117841', '4013320033333', '4000417622310', '4056489345909', '4000417602817', '4061458021913', '4000417107107', '4030387760606', '4000417103109', '4001743760196', '4056489005827', '4061459139860', '4068134089168', '4061458021579', '4061459605853', '4013320066393', '4013320185742', '4056489242512', '4061459605686', '40084244', '4012362024507', '4000607163609', '4000521007027', '4056489577294', '4000539113185', '4000417694218', '4013320066379', '4305615972374')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'not-applicable', 'Lidl', 'none', '40084060'),
  ('DE', 'Back Family', 'Grocery', 'Sweets', 'Schoko-Tröpfchen - Zartbitter', 'not-applicable', 'Aldi', 'none', '4061458160971'),
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Kinder Überraschung Maxi', 'not-applicable', null, 'none', '4008400230726'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Weiße Pistazie', 'not-applicable', null, 'none', '4000607850011'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Weiße Schokolade', 'not-applicable', null, 'none', '4000607167706'),
  ('DE', 'RUF', 'Grocery', 'Sweets', 'Schoko Tröpfchen', 'not-applicable', null, 'none', '4002809024306'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao-Klasse Die Kräftige 74%', 'not-applicable', null, 'none', '4000417693310'),
  ('DE', 'Kinder', 'Grocery', 'Sweets', 'Überraschung', 'not-applicable', null, 'none', '40084107'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Weiße Nuss', 'not-applicable', null, 'none', '4000417670113'),
  ('DE', 'August Storck KG', 'Grocery', 'Sweets', 'Merci Finest Selection Große Vielfalt', 'not-applicable', null, 'none', '4014400932904'),
  ('DE', 'Back Family', 'Grocery', 'Sweets', 'Kuvertüre Zartbitter', 'not-applicable', null, 'none', '4061463588951'),
  ('DE', 'Kinder', 'Grocery', 'Sweets', 'Kinder Überraschung', 'not-applicable', null, 'none', '40084909'),
  ('DE', 'Alpia', 'Grocery', 'Sweets', 'Zarte Weiße Schokolade', 'not-applicable', null, 'none', '4001743760219'),
  ('DE', 'Rapunzel', 'Grocery', 'Sweets', 'Nirwana Noir 55% Kakao mit dunkler Praliné-​Füllung', 'not-applicable', null, 'none', '4006040202844'),
  ('DE', 'Moser Roth', 'Grocery', 'Sweets', 'Edelbitter-Schokolade 85 % Cacao', 'not-applicable', 'Aldi', 'none', '4061458021630'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Kakao Klasse die Starke - 81%', 'not-applicable', 'Aldi', 'none', '4000417693815'),
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
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport Erdbeer', 'not-applicable', null, 'none', '4000417623713'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Schogetten Edel-Zartbitter-Haselnuss', 'not-applicable', 'Kaufland', 'none', '4000607730900'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Amicelli', 'not-applicable', null, 'none', '4000417601513'),
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Kinder Weihnachtsmann', 'not-applicable', null, 'none', '4008400511825'),
  ('DE', 'Merci', 'Grocery', 'Sweets', 'Finest Selection Mandel Knusper Vielfalt', 'not-applicable', null, 'none', '4014400917956'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Rahm Mandel', 'not-applicable', 'Aldi', 'none', '4061458021647'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Vegan Roasted Peanut', 'roasted', null, 'none', '4000417106100'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Nussklasse Ganze Mandel', 'not-applicable', null, 'none', '4000417670311'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Feinherbe Schokolade', 'not-applicable', 'Aldi', 'none', '4047247273459'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Ritter Sport White Lemon', 'not-applicable', null, 'none', '4000417628510'),
  ('DE', 'Choceur', 'Grocery', 'Sweets', 'Vollmilchschokolade Alpenmilch', 'not-applicable', 'Aldi', 'none', '4061458042963'),
  ('DE', 'Romy', 'Grocery', 'Sweets', 'Kokos-Schoko-Creme', 'not-applicable', null, 'none', '4021700903053'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Gebrannte Mandel', 'not-applicable', 'Kaufland', 'none', '4000417629616'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Zartbitterschokolade - Chili', 'not-applicable', 'Aldi', 'none', '4061458021555'),
  ('DE', 'Gepa', 'Grocery', 'Sweets', 'Zartbitter Mild Pur 60%', 'not-applicable', null, 'none', '4013320185629'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Groovy ritter', 'not-applicable', null, 'none', '4000417628411'),
  ('DE', 'Belbake', 'Grocery', 'Sweets', 'Schokochunks Zartbitter', 'not-applicable', 'Lidl', 'none', '4056489117841'),
  ('DE', 'Gepa', 'Grocery', 'Sweets', 'Grand Chocolat Matcha Blanc', 'not-applicable', null, 'none', '4013320033333'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Weisse Lakritz', 'not-applicable', null, 'none', '4000417622310'),
  ('DE', 'Lidl', 'Grocery', 'Sweets', 'Vegane helle Cookies', 'not-applicable', 'Lidl', 'none', '4056489345909'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Pfefferminz', 'not-applicable', 'Netto', 'none', '4000417602817'),
  ('DE', 'Choceur', 'Grocery', 'Sweets', 'Feine Weisse', 'not-applicable', 'Aldi', 'none', '4061458021913'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Salted Caramel Vegan', 'not-applicable', null, 'none', '4000417107107'),
  ('DE', 'Eszet', 'Grocery', 'Sweets', 'Schnitten- Zartbitter Schokolade', 'not-applicable', null, 'none', '4030387760606'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Crunchy Mandel', 'not-applicable', null, 'none', '4000417103109'),
  ('DE', 'Alpia', 'Grocery', 'Sweets', 'Feine Zartbitter Schokolade', 'not-applicable', null, 'none', '4001743760196'),
  ('DE', 'Belbake', 'Grocery', 'Sweets', 'Dark Chocolate Drops', 'not-applicable', 'Lidl', 'none', '4056489005827'),
  ('DE', 'Choceur', 'Grocery', 'Sweets', 'Mandelknacker - Zartbitterschokolade', 'not-applicable', 'Aldi', 'none', '4061459139860'),
  ('DE', 'EnerBio', 'Grocery', 'Sweets', 'Feine Edelbitter Schokolade 70%', 'not-applicable', 'Rossmann', 'none', '4068134089168'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Edel-Vollmilch', 'not-applicable', 'Aldi', 'none', '4061458021579'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Zartbitter Schokolade 70%', 'not-applicable', 'Aldi', 'none', '4061459605853'),
  ('DE', 'GEPA Grand Noir', 'Grocery', 'Sweets', 'GEPA Grand Noir Zarte Bitter 70% 4013320066393 Bio Bitterschokolade', 'not-applicable', null, 'none', '4013320066393'),
  ('DE', 'Gepa', 'Grocery', 'Sweets', 'Vollmilch Schokolade, Espresso & Karamell', 'not-applicable', null, 'none', '4013320185742'),
  ('DE', 'Fin Carré', 'Grocery', 'Sweets', 'Vegane Helle mit Haselnuss', 'not-applicable', 'Lidl', 'none', '4056489242512'),
  ('DE', 'Aldi', 'Grocery', 'Sweets', 'Choco Changer Salted Caramel', 'not-applicable', 'Aldi', 'none', '4061459605686'),
  ('DE', 'Ferrero', 'Grocery', 'Sweets', 'Yogurette', 'not-applicable', 'Lidl', 'none', '40084244'),
  ('DE', 'Zetti', 'Grocery', 'Sweets', 'Edel Bitter 75% Kakao', 'not-applicable', null, 'none', '4012362024507'),
  ('DE', 'Schogetten', 'Grocery', 'Sweets', 'Schokolade Caramel Brownie', 'not-applicable', 'Lidl', 'none', '4000607163609'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Sweets', 'Couverture fine gloss aigre-doux', 'not-applicable', null, 'none', '4000521007027'),
  ('DE', 'Fin CARRE', 'Grocery', 'Sweets', 'Mandel Kracher', 'not-applicable', 'Lidl', 'none', '4056489577294'),
  ('DE', 'Lindt', 'Grocery', 'Sweets', 'Excellence 50% cacao Zartbitter', 'not-applicable', null, 'none', '4000539113185'),
  ('DE', 'Ritter Sport', 'Grocery', 'Sweets', 'Schokolade Crunchy Creamy Winter', 'not-applicable', null, 'none', '4000417694218'),
  ('DE', 'Gepa', 'Grocery', 'Sweets', 'Grand Noir Edelbitter 85%', 'not-applicable', null, 'none', '4013320066379'),
  ('DE', 'Rossmann', 'Grocery', 'Sweets', 'RAW Chocolate mit Dattelsüsse', 'raw', 'Rossmann', 'none', '4305615972374')
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
  and product_name not in ('Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'Schoko-Tröpfchen - Zartbitter', 'Kinder Überraschung Maxi', 'Weiße Pistazie', 'Weiße Schokolade', 'Schoko Tröpfchen', 'Kakao-Klasse Die Kräftige 74%', 'Überraschung', 'Weiße Nuss', 'Merci Finest Selection Große Vielfalt', 'Kuvertüre Zartbitter', 'Kinder Überraschung', 'Zarte Weiße Schokolade', 'Nirwana Noir 55% Kakao mit dunkler Praliné-​Füllung', 'Edelbitter-Schokolade 85 % Cacao', 'Kakao Klasse die Starke - 81%', 'Lidl Organic Dark Chocolate', 'Edelbitter-Schokolade 70% Cacao', 'Schokolade Halbbitter', 'Marzipan', 'Edelbitter- Schokolade', 'Alpenmilch', 'Ritter Sport Nugat', 'Lindt Dubai Style Chocolade', 'Ritter Sport Voll-Nuss', 'Schogetten originals: Edel-Zartbitter', 'Aldi-Gipfel', 'Edel-Vollmilch', 'Blockschokolade', 'Mild 85%', 'Nussknacker - Vollmilchschokolade', 'Nussknacker - Zartbitterschokolade', 'Schoko-Chunks - Zartbitter', 'Pistachio', 'Excellence Mild 70%', 'Bio Vollmilch-Schokolade', 'Kakao-Mousse', 'Kakao Klasse 61 die feine aus Nicaragua', 'Ritter Sport Honig Salz Mandel', 'Gold Bunny', 'Schogetten - Edel-Alpenvollmilchschokolade', 'Kinder Osterhase - Harry Hase', 'Joghurt', 'Trauben Nuss', 'Knusperkeks', 'Schokolade Joghurt', 'Rum Trauben Nuss Schokolade', 'Schokolade (Alpen-Sahne-)', 'Erdbeer-Joghurt', 'Nirwana Vegan', 'Haselnuss', 'Ritter Sport Erdbeer', 'Schogetten Edel-Zartbitter-Haselnuss', 'Amicelli', 'Kinder Weihnachtsmann', 'Finest Selection Mandel Knusper Vielfalt', 'Rahm Mandel', 'Vegan Roasted Peanut', 'Nussklasse Ganze Mandel', 'Feinherbe Schokolade', 'Ritter Sport White Lemon', 'Vollmilchschokolade Alpenmilch', 'Kokos-Schoko-Creme', 'Gebrannte Mandel', 'Zartbitterschokolade - Chili', 'Zartbitter Mild Pur 60%', 'Groovy ritter', 'Schokochunks Zartbitter', 'Grand Chocolat Matcha Blanc', 'Weisse Lakritz', 'Vegane helle Cookies', 'Pfefferminz', 'Feine Weisse', 'Salted Caramel Vegan', 'Schnitten- Zartbitter Schokolade', 'Crunchy Mandel', 'Feine Zartbitter Schokolade', 'Dark Chocolate Drops', 'Mandelknacker - Zartbitterschokolade', 'Feine Edelbitter Schokolade 70%', 'Edel-Vollmilch', 'Zartbitter Schokolade 70%', 'GEPA Grand Noir Zarte Bitter 70% 4013320066393 Bio Bitterschokolade', 'Vollmilch Schokolade, Espresso & Karamell', 'Vegane Helle mit Haselnuss', 'Choco Changer Salted Caramel', 'Yogurette', 'Edel Bitter 75% Kakao', 'Schokolade Caramel Brownie', 'Couverture fine gloss aigre-doux', 'Mandel Kracher', 'Excellence 50% cacao Zartbitter', 'Schokolade Crunchy Creamy Winter', 'Grand Noir Edelbitter 85%', 'RAW Chocolate mit Dattelsüsse');

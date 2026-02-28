-- PIPELINE (Sweets): source provenance
-- Generated: 2026-02-25

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Ferrero', 'Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'https://world.openfoodfacts.org/product/40084060', '40084060'),
    ('Ritter Sport', 'Kakao-Klasse Die Kräftige 74%', 'https://world.openfoodfacts.org/product/4000417693310', '4000417693310'),
    ('Kinder', 'Überraschung', 'https://world.openfoodfacts.org/product/40084107', '40084107'),
    ('J. D. Gross', 'Edelbitter Mild 90%', 'https://world.openfoodfacts.org/product/4056489471264', '4056489471264'),
    ('Moser Roth', 'Edelbitter-Schokolade 85 % Cacao', 'https://world.openfoodfacts.org/product/4061458021630', '4061458021630'),
    ('Ritter Sport', 'Kakao Klasse die Starke - 81%', 'https://world.openfoodfacts.org/product/4000417693815', '4000417693815'),
    ('Moser Roth', 'Edelbitter 90 % Cacao', 'https://world.openfoodfacts.org/product/4061462044809', '4061462044809'),
    ('Lidl', 'Lidl Organic Dark Chocolate', 'https://world.openfoodfacts.org/product/40896243', '40896243'),
    ('Aldi', 'Edelbitter-Schokolade 70% Cacao', 'https://world.openfoodfacts.org/product/4061458021593', '4061458021593'),
    ('Ritter Sport', 'Schokolade Halbbitter', 'https://world.openfoodfacts.org/product/4000417602015', '4000417602015'),
    ('Ritter Sport', 'Marzipan', 'https://world.openfoodfacts.org/product/4000417602510', '4000417602510'),
    ('Aldi', 'Edelbitter- Schokolade', 'https://world.openfoodfacts.org/product/4061459208078', '4061459208078'),
    ('Ritter Sport', 'Alpenmilch', 'https://world.openfoodfacts.org/product/4000417601810', '4000417601810'),
    ('Ritter Sport', 'Ritter Sport Nugat', 'https://world.openfoodfacts.org/product/4000417602619', '4000417602619'),
    ('Lindt', 'Lindt Dubai Style Chocolade', 'https://world.openfoodfacts.org/product/4000539150869', '4000539150869'),
    ('Ritter Sport', 'Ritter Sport Voll-Nuss', 'https://world.openfoodfacts.org/product/4000417670014', '4000417670014'),
    ('Schogetten', 'Schogetten originals: Edel-Zartbitter', 'https://world.openfoodfacts.org/product/4000607151200', '4000607151200'),
    ('Choceur', 'Aldi-Gipfel', 'https://world.openfoodfacts.org/product/4061462452772', '4061462452772'),
    ('Ritter Sport', 'Edel-Vollmilch', 'https://world.openfoodfacts.org/product/4000417602114', '4000417602114'),
    ('Müller & Müller GmbH', 'Blockschokolade', 'https://world.openfoodfacts.org/product/4006814001796', '4006814001796'),
    ('Sarotti', 'Mild 85%', 'https://world.openfoodfacts.org/product/4030387760866', '4030387760866'),
    ('Aldi', 'Nussknacker - Vollmilchschokolade', 'https://world.openfoodfacts.org/product/4061458021616', '4061458021616'),
    ('Aldi', 'Nussknacker - Zartbitterschokolade', 'https://world.openfoodfacts.org/product/4061458022002', '4061458022002'),
    ('Back Family', 'Schoko-Chunks - Zartbitter', 'https://world.openfoodfacts.org/product/4061458160964', '4061458160964'),
    ('Ritter Sport', 'Pistachio', 'https://world.openfoodfacts.org/product/4000417670915', '4000417670915'),
    ('Lindt', 'Excellence Mild 70%', 'https://world.openfoodfacts.org/product/4000539003509', '4000539003509'),
    ('Fairglobe', 'Bio Vollmilch-Schokolade', 'https://world.openfoodfacts.org/product/40896250', '40896250'),
    ('Ritter Sport', 'Kakao-Mousse', 'https://world.openfoodfacts.org/product/4000417629418', '4000417629418'),
    ('Ritter Sport', 'Kakao Klasse 61 die feine aus Nicaragua', 'https://world.openfoodfacts.org/product/4000417693211', '4000417693211'),
    ('Ritter Sport', 'Ritter Sport Honig Salz Mandel', 'https://world.openfoodfacts.org/product/4000417670410', '4000417670410'),
    ('Lindt', 'Gold Bunny', 'https://world.openfoodfacts.org/product/4000539671203', '4000539671203'),
    ('Schogetten', 'Schogetten - Edel-Alpenvollmilchschokolade', 'https://world.openfoodfacts.org/product/4000607151002', '4000607151002'),
    ('Ferrero', 'Kinder Osterhase - Harry Hase', 'https://world.openfoodfacts.org/product/4008400524023', '4008400524023'),
    ('Ritter Sport', 'Joghurt', 'https://world.openfoodfacts.org/product/4000417602718', '4000417602718'),
    ('Ritter Sport', 'Trauben Nuss', 'https://world.openfoodfacts.org/product/4000417602213', '4000417602213'),
    ('Ritter Sport', 'Knusperkeks', 'https://world.openfoodfacts.org/product/4000417621412', '4000417621412'),
    ('Milka', 'Schokolade Joghurt', 'https://world.openfoodfacts.org/product/4025700001450', '4025700001450'),
    ('Ritter Sport', 'Rum Trauben Nuss Schokolade', 'https://world.openfoodfacts.org/product/4000417601216', '4000417601216'),
    ('Aldi', 'Schokolade (Alpen-Sahne-)', 'https://world.openfoodfacts.org/product/4061458021753', '4061458021753'),
    ('Aldi', 'Erdbeer-Joghurt', 'https://world.openfoodfacts.org/product/4061458021883', '4061458021883'),
    ('Rapunzel', 'Nirwana Vegan', 'https://world.openfoodfacts.org/product/4006040488897', '4006040488897'),
    ('Ritter Sport', 'Haselnuss', 'https://world.openfoodfacts.org/product/4000417622211', '4000417622211'),
    ('Ritter Sport', 'Ritter Sport Erdbeer', 'https://world.openfoodfacts.org/product/4000417623713', '4000417623713'),
    ('Schogetten', 'Schogetten Edel-Zartbitter-Haselnuss', 'https://world.openfoodfacts.org/product/4000607730900', '4000607730900'),
    ('Ritter Sport', 'Amicelli', 'https://world.openfoodfacts.org/product/4000417601513', '4000417601513'),
    ('Ferrero', 'Kinder Weihnachtsmann', 'https://world.openfoodfacts.org/product/4008400511825', '4008400511825'),
    ('Merci', 'Finest Selection Mandel Knusper Vielfalt', 'https://world.openfoodfacts.org/product/4014400917956', '4014400917956'),
    ('Aldi', 'Rahm Mandel', 'https://world.openfoodfacts.org/product/4061458021647', '4061458021647'),
    ('Ritter Sport', 'Vegan Roasted Peanut', 'https://world.openfoodfacts.org/product/4000417106100', '4000417106100'),
    ('Ritter Sport', 'Nussklasse Ganze Mandel', 'https://world.openfoodfacts.org/product/4000417670311', '4000417670311'),
    ('Ritter Sport', 'Ritter Sport Lemon', 'https://world.openfoodfacts.org/product/4000417628510', '4000417628510')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Sweets' AND p.is_deprecated IS NOT TRUE;

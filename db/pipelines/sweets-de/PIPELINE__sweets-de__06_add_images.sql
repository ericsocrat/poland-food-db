-- PIPELINE (Sweets): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Sweets'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Ferrero', 'Ferrero Yogurette 40084060 Gefüllte Vollmilchschokolade mit Magermilchjoghurt-Erdbeer-Creme', 'https://images.openfoodfacts.org/images/products/000/004/008/4060/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 40084060', 'front_40084060'),
    ('Back Family', 'Schoko-Tröpfchen - Zartbitter', 'https://images.openfoodfacts.org/images/products/406/145/816/0971/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458160971', 'front_4061458160971'),
    ('Ferrero', 'Kinder Überraschung Maxi', 'https://images.openfoodfacts.org/images/products/400/840/023/0726/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008400230726', 'front_4008400230726'),
    ('Schogetten', 'Weiße Pistazie', 'https://images.openfoodfacts.org/images/products/400/060/785/0011/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607850011', 'front_4000607850011'),
    ('Schogetten', 'Weiße Schokolade', 'https://images.openfoodfacts.org/images/products/400/060/716/7706/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607167706', 'front_4000607167706'),
    ('RUF', 'Schoko Tröpfchen', 'https://images.openfoodfacts.org/images/products/400/280/902/4306/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002809024306', 'front_4002809024306'),
    ('Ritter Sport', 'Kakao-Klasse Die Kräftige 74%', 'https://images.openfoodfacts.org/images/products/400/041/769/3310/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417693310', 'front_4000417693310'),
    ('Kinder', 'Überraschung', 'https://images.openfoodfacts.org/images/products/000/004/008/4107/front_de.239.400.jpg', 'off_api', 'front', true, 'Front — EAN 40084107', 'front_40084107'),
    ('Ritter Sport', 'Weiße Nuss', 'https://images.openfoodfacts.org/images/products/400/041/767/0113/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417670113', 'front_4000417670113'),
    ('August Storck KG', 'Merci Finest Selection Große Vielfalt', 'https://images.openfoodfacts.org/images/products/401/440/093/2904/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014400932904', 'front_4014400932904'),
    ('Back Family', 'Kuvertüre Zartbitter', 'https://images.openfoodfacts.org/images/products/406/146/358/8951/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463588951', 'front_4061463588951'),
    ('Kinder', 'Kinder Überraschung', 'https://images.openfoodfacts.org/images/products/000/004/008/4909/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 40084909', 'front_40084909'),
    ('Alpia', 'Zarte Weiße Schokolade', 'https://images.openfoodfacts.org/images/products/400/174/376/0219/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001743760219', 'front_4001743760219'),
    ('Rapunzel', 'Nirwana Noir 55% Kakao mit dunkler Praliné-​Füllung', 'https://images.openfoodfacts.org/images/products/400/604/020/2844/front_en.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040202844', 'front_4006040202844'),
    ('Moser Roth', 'Edelbitter-Schokolade 85 % Cacao', 'https://images.openfoodfacts.org/images/products/406/145/802/1630/front_de.102.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021630', 'front_4061458021630'),
    ('Ritter Sport', 'Kakao Klasse die Starke - 81%', 'https://images.openfoodfacts.org/images/products/400/041/769/3815/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417693815', 'front_4000417693815'),
    ('Lidl', 'Lidl Organic Dark Chocolate', 'https://images.openfoodfacts.org/images/products/000/004/089/6243/front_en.168.400.jpg', 'off_api', 'front', true, 'Front — EAN 40896243', 'front_40896243'),
    ('Aldi', 'Edelbitter-Schokolade 70% Cacao', 'https://images.openfoodfacts.org/images/products/406/145/802/1593/front_de.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021593', 'front_4061458021593'),
    ('Ritter Sport', 'Schokolade Halbbitter', 'https://images.openfoodfacts.org/images/products/400/041/760/2015/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602015', 'front_4000417602015'),
    ('Ritter Sport', 'Marzipan', 'https://images.openfoodfacts.org/images/products/400/041/760/2510/front_en.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602510', 'front_4000417602510'),
    ('Aldi', 'Edelbitter- Schokolade', 'https://images.openfoodfacts.org/images/products/406/145/920/8078/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459208078', 'front_4061459208078'),
    ('Ritter Sport', 'Alpenmilch', 'https://images.openfoodfacts.org/images/products/400/041/760/1810/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417601810', 'front_4000417601810'),
    ('Ritter Sport', 'Ritter Sport Nugat', 'https://images.openfoodfacts.org/images/products/400/041/760/2619/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602619', 'front_4000417602619'),
    ('Lindt', 'Lindt Dubai Style Chocolade', 'https://images.openfoodfacts.org/images/products/400/053/915/0869/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000539150869', 'front_4000539150869'),
    ('Ritter Sport', 'Ritter Sport Voll-Nuss', 'https://images.openfoodfacts.org/images/products/400/041/767/0014/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417670014', 'front_4000417670014'),
    ('Schogetten', 'Schogetten originals: Edel-Zartbitter', 'https://images.openfoodfacts.org/images/products/400/060/715/1200/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607151200', 'front_4000607151200'),
    ('Choceur', 'Aldi-Gipfel', 'https://images.openfoodfacts.org/images/products/406/146/245/2772/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462452772', 'front_4061462452772'),
    ('Ritter Sport', 'Edel-Vollmilch', 'https://images.openfoodfacts.org/images/products/400/041/760/2114/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602114', 'front_4000417602114'),
    ('Müller & Müller GmbH', 'Blockschokolade', 'https://images.openfoodfacts.org/images/products/400/681/400/1796/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006814001796', 'front_4006814001796'),
    ('Sarotti', 'Mild 85%', 'https://images.openfoodfacts.org/images/products/403/038/776/0866/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4030387760866', 'front_4030387760866'),
    ('Aldi', 'Nussknacker - Vollmilchschokolade', 'https://images.openfoodfacts.org/images/products/406/145/802/1616/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021616', 'front_4061458021616'),
    ('Aldi', 'Nussknacker - Zartbitterschokolade', 'https://images.openfoodfacts.org/images/products/406/145/802/2002/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458022002', 'front_4061458022002'),
    ('Back Family', 'Schoko-Chunks - Zartbitter', 'https://images.openfoodfacts.org/images/products/406/145/816/0964/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458160964', 'front_4061458160964'),
    ('Ritter Sport', 'Pistachio', 'https://images.openfoodfacts.org/images/products/400/041/767/0915/front_en.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417670915', 'front_4000417670915'),
    ('Lindt', 'Excellence Mild 70%', 'https://images.openfoodfacts.org/images/products/400/053/900/3509/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000539003509', 'front_4000539003509'),
    ('Fairglobe', 'Bio Vollmilch-Schokolade', 'https://images.openfoodfacts.org/images/products/000/004/089/6250/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 40896250', 'front_40896250'),
    ('Ritter Sport', 'Kakao-Mousse', 'https://images.openfoodfacts.org/images/products/400/041/762/9418/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417629418', 'front_4000417629418'),
    ('Ritter Sport', 'Kakao Klasse 61 die feine aus Nicaragua', 'https://images.openfoodfacts.org/images/products/400/041/769/3211/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417693211', 'front_4000417693211'),
    ('Ritter Sport', 'Ritter Sport Honig Salz Mandel', 'https://images.openfoodfacts.org/images/products/400/041/767/0410/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417670410', 'front_4000417670410'),
    ('Lindt', 'Gold Bunny', 'https://images.openfoodfacts.org/images/products/400/053/967/1203/front_en.143.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000539671203', 'front_4000539671203'),
    ('Schogetten', 'Schogetten - Edel-Alpenvollmilchschokolade', 'https://images.openfoodfacts.org/images/products/400/060/715/1002/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607151002', 'front_4000607151002'),
    ('Ferrero', 'Kinder Osterhase - Harry Hase', 'https://images.openfoodfacts.org/images/products/400/840/052/4023/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008400524023', 'front_4008400524023'),
    ('Ritter Sport', 'Joghurt', 'https://images.openfoodfacts.org/images/products/400/041/760/2718/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602718', 'front_4000417602718'),
    ('Ritter Sport', 'Trauben Nuss', 'https://images.openfoodfacts.org/images/products/400/041/760/2213/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602213', 'front_4000417602213'),
    ('Ritter Sport', 'Knusperkeks', 'https://images.openfoodfacts.org/images/products/400/041/762/1412/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417621412', 'front_4000417621412'),
    ('Milka', 'Schokolade Joghurt', 'https://images.openfoodfacts.org/images/products/402/570/000/1450/front_en.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4025700001450', 'front_4025700001450'),
    ('Ritter Sport', 'Rum Trauben Nuss Schokolade', 'https://images.openfoodfacts.org/images/products/400/041/760/1216/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417601216', 'front_4000417601216'),
    ('Aldi', 'Schokolade (Alpen-Sahne-)', 'https://images.openfoodfacts.org/images/products/406/145/802/1753/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021753', 'front_4061458021753'),
    ('Aldi', 'Erdbeer-Joghurt', 'https://images.openfoodfacts.org/images/products/406/145/802/1883/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021883', 'front_4061458021883'),
    ('Rapunzel', 'Nirwana Vegan', 'https://images.openfoodfacts.org/images/products/400/604/048/8897/front_de.106.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040488897', 'front_4006040488897'),
    ('Ritter Sport', 'Haselnuss', 'https://images.openfoodfacts.org/images/products/400/041/762/2211/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417622211', 'front_4000417622211'),
    ('Ritter Sport', 'Ritter Sport Erdbeer', 'https://images.openfoodfacts.org/images/products/400/041/762/3713/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417623713', 'front_4000417623713'),
    ('Schogetten', 'Schogetten Edel-Zartbitter-Haselnuss', 'https://images.openfoodfacts.org/images/products/400/060/773/0900/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607730900', 'front_4000607730900'),
    ('Ritter Sport', 'Amicelli', 'https://images.openfoodfacts.org/images/products/400/041/760/1513/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417601513', 'front_4000417601513'),
    ('Ferrero', 'Kinder Weihnachtsmann', 'https://images.openfoodfacts.org/images/products/400/840/051/1825/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008400511825', 'front_4008400511825'),
    ('Merci', 'Finest Selection Mandel Knusper Vielfalt', 'https://images.openfoodfacts.org/images/products/401/440/091/7956/front_en.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014400917956', 'front_4014400917956'),
    ('Aldi', 'Rahm Mandel', 'https://images.openfoodfacts.org/images/products/406/145/802/1647/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021647', 'front_4061458021647'),
    ('Ritter Sport', 'Vegan Roasted Peanut', 'https://images.openfoodfacts.org/images/products/400/041/710/6100/front_en.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417106100', 'front_4000417106100'),
    ('Ritter Sport', 'Nussklasse Ganze Mandel', 'https://images.openfoodfacts.org/images/products/400/041/767/0311/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417670311', 'front_4000417670311'),
    ('Aldi', 'Feinherbe Schokolade', 'https://images.openfoodfacts.org/images/products/404/724/727/3459/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247273459', 'front_4047247273459'),
    ('Ritter Sport', 'Ritter Sport White Lemon', 'https://images.openfoodfacts.org/images/products/400/041/762/8510/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417628510', 'front_4000417628510'),
    ('Choceur', 'Vollmilchschokolade Alpenmilch', 'https://images.openfoodfacts.org/images/products/406/145/804/2963/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458042963', 'front_4061458042963'),
    ('Romy', 'Kokos-Schoko-Creme', 'https://images.openfoodfacts.org/images/products/402/170/090/3053/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021700903053', 'front_4021700903053'),
    ('Ritter Sport', 'Gebrannte Mandel', 'https://images.openfoodfacts.org/images/products/400/041/762/9616/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417629616', 'front_4000417629616'),
    ('Aldi', 'Zartbitterschokolade - Chili', 'https://images.openfoodfacts.org/images/products/406/145/802/1555/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021555', 'front_4061458021555'),
    ('Gepa', 'Zartbitter Mild Pur 60%', 'https://images.openfoodfacts.org/images/products/401/332/018/5629/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013320185629', 'front_4013320185629'),
    ('Ritter Sport', 'Groovy ritter', 'https://images.openfoodfacts.org/images/products/400/041/762/8411/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417628411', 'front_4000417628411'),
    ('Belbake', 'Schokochunks Zartbitter', 'https://images.openfoodfacts.org/images/products/405/648/911/7841/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489117841', 'front_4056489117841'),
    ('Gepa', 'Grand Chocolat Matcha Blanc', 'https://images.openfoodfacts.org/images/products/401/332/003/3333/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013320033333', 'front_4013320033333'),
    ('Ritter Sport', 'Weisse Lakritz', 'https://images.openfoodfacts.org/images/products/400/041/762/2310/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417622310', 'front_4000417622310'),
    ('Lidl', 'Vegane helle Cookies', 'https://images.openfoodfacts.org/images/products/405/648/934/5909/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489345909', 'front_4056489345909'),
    ('Ritter Sport', 'Pfefferminz', 'https://images.openfoodfacts.org/images/products/400/041/760/2817/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417602817', 'front_4000417602817'),
    ('Choceur', 'Feine Weisse', 'https://images.openfoodfacts.org/images/products/406/145/802/1913/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021913', 'front_4061458021913'),
    ('Ritter Sport', 'Salted Caramel Vegan', 'https://images.openfoodfacts.org/images/products/400/041/710/7107/front_en.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417107107', 'front_4000417107107'),
    ('Eszet', 'Schnitten- Zartbitter Schokolade', 'https://images.openfoodfacts.org/images/products/403/038/776/0606/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4030387760606', 'front_4030387760606'),
    ('Ritter Sport', 'Crunchy Mandel', 'https://images.openfoodfacts.org/images/products/400/041/710/3109/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417103109', 'front_4000417103109'),
    ('Alpia', 'Feine Zartbitter Schokolade', 'https://images.openfoodfacts.org/images/products/400/174/376/0196/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001743760196', 'front_4001743760196'),
    ('Belbake', 'Dark Chocolate Drops', 'https://images.openfoodfacts.org/images/products/405/648/900/5827/front_en.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489005827', 'front_4056489005827'),
    ('Choceur', 'Mandelknacker - Zartbitterschokolade', 'https://images.openfoodfacts.org/images/products/406/145/913/9860/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459139860', 'front_4061459139860'),
    ('EnerBio', 'Feine Edelbitter Schokolade 70%', 'https://images.openfoodfacts.org/images/products/406/813/408/9168/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068134089168', 'front_4068134089168'),
    ('Aldi', 'Edel-Vollmilch', 'https://images.openfoodfacts.org/images/products/406/145/802/1579/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021579', 'front_4061458021579'),
    ('Aldi', 'Zartbitter Schokolade 70%', 'https://images.openfoodfacts.org/images/products/406/145/960/5853/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459605853', 'front_4061459605853'),
    ('GEPA Grand Noir', 'GEPA Grand Noir Zarte Bitter 70% 4013320066393 Bio Bitterschokolade', 'https://images.openfoodfacts.org/images/products/401/332/006/6393/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013320066393', 'front_4013320066393'),
    ('Gepa', 'Vollmilch Schokolade, Espresso & Karamell', 'https://images.openfoodfacts.org/images/products/401/332/018/5742/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013320185742', 'front_4013320185742'),
    ('Fin Carré', 'Vegane Helle mit Haselnuss', 'https://images.openfoodfacts.org/images/products/405/648/924/2512/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489242512', 'front_4056489242512'),
    ('Aldi', 'Choco Changer Salted Caramel', 'https://images.openfoodfacts.org/images/products/406/145/960/5686/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459605686', 'front_4061459605686'),
    ('Ferrero', 'Yogurette', 'https://images.openfoodfacts.org/images/products/000/004/008/4244/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 40084244', 'front_40084244'),
    ('Zetti', 'Edel Bitter 75% Kakao', 'https://images.openfoodfacts.org/images/products/401/236/202/4507/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012362024507', 'front_4012362024507'),
    ('Schogetten', 'Schokolade Caramel Brownie', 'https://images.openfoodfacts.org/images/products/400/060/716/3609/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000607163609', 'front_4000607163609'),
    ('Dr. Oetker', 'Couverture fine gloss aigre-doux', 'https://images.openfoodfacts.org/images/products/400/052/100/7027/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000521007027', 'front_4000521007027'),
    ('Fin CARRE', 'Mandel Kracher', 'https://images.openfoodfacts.org/images/products/405/648/957/7294/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489577294', 'front_4056489577294'),
    ('Lindt', 'Excellence 50% cacao Zartbitter', 'https://images.openfoodfacts.org/images/products/400/053/911/3185/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000539113185', 'front_4000539113185'),
    ('Ritter Sport', 'Schokolade Crunchy Creamy Winter', 'https://images.openfoodfacts.org/images/products/400/041/769/4218/front_fr.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417694218', 'front_4000417694218'),
    ('Gepa', 'Grand Noir Edelbitter 85%', 'https://images.openfoodfacts.org/images/products/401/332/006/6379/front_de.132.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013320066379', 'front_4013320066379'),
    ('Rossmann', 'RAW Chocolate mit Dattelsüsse', 'https://images.openfoodfacts.org/images/products/430/561/597/2374/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4305615972374', 'front_4305615972374')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Sweets' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

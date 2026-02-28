-- PIPELINE (Sweets): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-02-25

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
    ('Ritter Sport', 'Kakao-Klasse Die Kräftige 74%', 'https://images.openfoodfacts.org/images/products/400/041/769/3310/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417693310', 'front_4000417693310'),
    ('Kinder', 'Überraschung', 'https://images.openfoodfacts.org/images/products/000/004/008/4107/front_de.239.400.jpg', 'off_api', 'front', true, 'Front — EAN 40084107', 'front_40084107'),
    ('J. D. Gross', 'Edelbitter Mild 90%', 'https://images.openfoodfacts.org/images/products/405/648/947/1264/front_en.122.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489471264', 'front_4056489471264'),
    ('Moser Roth', 'Edelbitter-Schokolade 85 % Cacao', 'https://images.openfoodfacts.org/images/products/406/145/802/1630/front_de.102.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458021630', 'front_4061458021630'),
    ('Ritter Sport', 'Kakao Klasse die Starke - 81%', 'https://images.openfoodfacts.org/images/products/400/041/769/3815/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417693815', 'front_4000417693815'),
    ('Moser Roth', 'Edelbitter 90 % Cacao', 'https://images.openfoodfacts.org/images/products/406/146/204/4809/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462044809', 'front_4061462044809'),
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
    ('Ritter Sport', 'Ritter Sport Lemon', 'https://images.openfoodfacts.org/images/products/400/041/762/8510/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000417628510', 'front_4000417628510')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Sweets' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

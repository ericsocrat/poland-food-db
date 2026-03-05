-- PIPELINE (Canned Goods): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Canned Goods'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Nixe - LIDL', 'Thunfisch Filets in Sonnenblumenöl', 'https://images.openfoodfacts.org/images/products/405/648/925/4676/front_en.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489254676', 'front_4056489254676'),
    ('Hengstenberg', 'KNAX Gewürzgurken', 'https://images.openfoodfacts.org/images/products/000/004/008/1410/front_de.149.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081410', 'front_40081410'),
    ('Aldi', 'Bio-Gewürzgurken', 'https://images.openfoodfacts.org/images/products/406/145/971/4517/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459714517', 'front_4061459714517'),
    ('Kuehne', 'Schlemmertöpfchen gew. Gurken', 'https://images.openfoodfacts.org/images/products/401/220/004/6654/front_de.128.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012200046654', 'front_4012200046654'),
    ('Wonnemeyer', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 'https://images.openfoodfacts.org/images/products/406/145/802/4501/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024501', 'front_4061458024501'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/8217/front_de.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108217', 'front_4037300108217'),
    ('Kühne', 'Gewürzgurken', 'https://images.openfoodfacts.org/images/products/000/004/080/4651/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 40804651', 'front_40804651'),
    ('Spreewaldhof', 'Spreelinge Gewürzgurken', 'https://images.openfoodfacts.org/images/products/401/271/200/1547/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012712001547', 'front_4012712001547'),
    ('Erasco', 'Linseneintopf mit Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/8293/front_de.134.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108293', 'front_4037300108293'),
    ('Erasco', 'Erasco Kartoffelsuppe m. Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/8491/front_de.130.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108491', 'front_4037300108491'),
    ('Aldi', 'Sardinen in Sonnenblumenöl - Klassik', 'https://images.openfoodfacts.org/images/products/406/145/802/0015/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458020015', 'front_4061458020015'),
    ('Nestlé', 'Ravioli Gemüse', 'https://images.openfoodfacts.org/images/products/400/550/033/0318/front_de.123.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500330318', 'front_4005500330318'),
    ('Erasco', 'Westfälische Linsen Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/8231/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108231', 'front_4037300108231'),
    ('Erasco', 'Hühner Reis-Topf', 'https://images.openfoodfacts.org/images/products/403/730/010/4356/front_de.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104356', 'front_4037300104356'),
    ('King''s Crown', 'Erbsen und Möhren sehr fein', 'https://images.openfoodfacts.org/images/products/404/724/708/6769/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247086769', 'front_4047247086769'),
    ('Erasco', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/3236/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103236', 'front_4037300103236'),
    ('Kühne', 'Gurken Sauer Honig Schlemmertöpfchen', 'https://images.openfoodfacts.org/images/products/401/220/041/7409/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012200417409', 'front_4012200417409'),
    ('Nixe', 'Thunfisch', 'https://images.openfoodfacts.org/images/products/405/648/925/4683/front_en.250.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489254683', 'front_4056489254683'),
    ('Appel', 'Zarte Filets vom Hering in Tomaten-Creme', 'https://images.openfoodfacts.org/images/products/402/050/092/2011/front_de.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 4020500922011', 'front_4020500922011'),
    ('KING''S CROWN (Aldi)', 'Tomatenmark', 'https://images.openfoodfacts.org/images/products/406/146/330/7743/front_de.115.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463307743', 'front_4061463307743'),
    ('Almare Seafood', 'Thunfisch Filets in eigenen Saft', 'https://images.openfoodfacts.org/images/products/406/146/263/0682/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462630682', 'front_4061462630682'),
    ('Aldi', 'Tomatenmark', 'https://images.openfoodfacts.org/images/products/406/146/252/9290/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462529290', 'front_4061462529290'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'https://images.openfoodfacts.org/images/products/000/004/008/1076/front_de.186.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081076', 'front_40081076'),
    ('King''s Crown', 'Tomaten gehackt', 'https://images.openfoodfacts.org/images/products/406/146/196/8052/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461968052', 'front_4061461968052'),
    ('Oro Di Parma', 'Tomaten', 'https://images.openfoodfacts.org/images/products/000/004/008/1236/front_en.243.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081236', 'front_40081236'),
    ('Hawesta', 'Heringsfilets - Tomaten-Creme', 'https://images.openfoodfacts.org/images/products/400/692/200/0407/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006922000407', 'front_4006922000407'),
    ('Aldi', 'Cornichons', 'https://images.openfoodfacts.org/images/products/406/145/800/4244/front_de.118.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458004244', 'front_4061458004244'),
    ('Erasco', 'Vegetarischer linsen-eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/4011/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104011', 'front_4037300104011'),
    ('DmBio', 'Tomatenmark', 'https://images.openfoodfacts.org/images/products/405/817/226/8717/front_de.66.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172268717', 'front_4058172268717'),
    ('Erasco', 'Erbsensuppe Hubertus', 'https://images.openfoodfacts.org/images/products/403/730/010/8248/front_de.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108248', 'front_4037300108248'),
    ('Hawesta', 'Heringsfilets - Pfeffercreme', 'https://images.openfoodfacts.org/images/products/400/692/200/1602/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006922001602', 'front_4006922001602'),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 'https://images.openfoodfacts.org/images/products/000/004/008/1922/front_de.103.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081922', 'front_40081922'),
    ('Bio Organic', 'Rote Beete', 'https://images.openfoodfacts.org/images/products/405/648/915/2736/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489152736', 'front_4056489152736'),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'https://images.openfoodfacts.org/images/products/402/050/092/2127/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4020500922127', 'front_4020500922127'),
    ('Appel', 'Zarte Filets vom Hering Tomate-Mozzarella', 'https://images.openfoodfacts.org/images/products/402/050/092/2158/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4020500922158', 'front_4020500922158'),
    ('Erasco', 'Erbseneintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/4004/front_en.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104004', 'front_4037300104004'),
    ('Aldi', 'Mais', 'https://images.openfoodfacts.org/images/products/404/724/749/5820/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247495820', 'front_4047247495820'),
    ('Hengstenberg', 'Tomaten - Passiert', 'https://images.openfoodfacts.org/images/products/000/004/008/1243/front_de.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081243', 'front_40081243'),
    ('Sweet Valley', 'Pfirsiche halbe Frucht, leicht gezuckert', 'https://images.openfoodfacts.org/images/products/406/145/800/4114/front_de.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458004114', 'front_4061458004114'),
    ('Deutsche See', 'Thunfisch im Aufguss', 'https://images.openfoodfacts.org/images/products/400/923/960/8694/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009239608694', 'front_4009239608694'),
    ('King''s Crown', 'Rote Beete in Kugeln', 'https://images.openfoodfacts.org/images/products/404/724/709/7161/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247097161', 'front_4047247097161'),
    ('Freshona', 'Sonnenmais natursüß', 'https://images.openfoodfacts.org/images/products/000/002/015/3229/front_de.356.400.jpg', 'off_api', 'front', true, 'Front — EAN 20153229', 'front_20153229'),
    ('REWE Bio', 'Tomaten in Stücken', 'https://images.openfoodfacts.org/images/products/433/725/635/3014/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256353014', 'front_4337256353014'),
    ('Erasco', 'Erasco Erbsen-Eintopf 4037300108309', 'https://images.openfoodfacts.org/images/products/403/730/010/8309/front_de.97.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108309', 'front_4037300108309'),
    ('Aldi', 'Gehackte Tomaten', 'https://images.openfoodfacts.org/images/products/406/145/911/2061/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459112061', 'front_4061459112061'),
    ('K-Classic', 'Thunfisch Filets I.E.S', 'https://images.openfoodfacts.org/images/products/406/336/737/9833/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367379833', 'front_4063367379833'),
    ('Nestlé', 'Dosen Ravioli', 'https://images.openfoodfacts.org/images/products/400/550/033/9403/front_en.225.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500339403', 'front_4005500339403'),
    ('Edeka', 'Delikatess Gewürzgurken', 'https://images.openfoodfacts.org/images/products/431/159/644/6117/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311596446117', 'front_4311596446117'),
    ('Mutti', 'Geschälte Italienische Tomaten', 'https://images.openfoodfacts.org/images/products/800/511/006/0007/front_en.147.400.jpg', 'off_api', 'front', true, 'Front — EAN 8005110060007', 'front_8005110060007'),
    ('Sweet Valley', 'ALDI SWEET VALLEY OBST Ananas in Scheiben ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/406/145/999/9075/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459999075', 'front_4061459999075'),
    ('Erasco', 'Serbische Bohnensuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/8460/front_de.73.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108460', 'front_4037300108460')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

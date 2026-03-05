-- PIPELINE (Canned Goods): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Nixe - LIDL', 'Thunfisch Filets in Sonnenblumenöl', 'https://world.openfoodfacts.org/product/4056489254676', '4056489254676'),
    ('Hengstenberg', 'KNAX Gewürzgurken', 'https://world.openfoodfacts.org/product/40081410', '40081410'),
    ('Aldi', 'Bio-Gewürzgurken', 'https://world.openfoodfacts.org/product/4061459714517', '4061459714517'),
    ('Kuehne', 'Schlemmertöpfchen gew. Gurken', 'https://world.openfoodfacts.org/product/4012200046654', '4012200046654'),
    ('Wonnemeyer', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 'https://world.openfoodfacts.org/product/4061458024501', '4061458024501'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'https://world.openfoodfacts.org/product/4037300108217', '4037300108217'),
    ('Kühne', 'Gewürzgurken', 'https://world.openfoodfacts.org/product/40804651', '40804651'),
    ('Spreewaldhof', 'Spreelinge Gewürzgurken', 'https://world.openfoodfacts.org/product/4012712001547', '4012712001547'),
    ('Erasco', 'Linseneintopf mit Würstchen', 'https://world.openfoodfacts.org/product/4037300108293', '4037300108293'),
    ('Erasco', 'Erasco Kartoffelsuppe m. Würstchen', 'https://world.openfoodfacts.org/product/4037300108491', '4037300108491'),
    ('Aldi', 'Sardinen in Sonnenblumenöl - Klassik', 'https://world.openfoodfacts.org/product/4061458020015', '4061458020015'),
    ('Nestlé', 'Ravioli Gemüse', 'https://world.openfoodfacts.org/product/4005500330318', '4005500330318'),
    ('Erasco', 'Westfälische Linsen Eintopf', 'https://world.openfoodfacts.org/product/4037300108231', '4037300108231'),
    ('Erasco', 'Hühner Reis-Topf', 'https://world.openfoodfacts.org/product/4037300104356', '4037300104356'),
    ('King''s Crown', 'Erbsen und Möhren sehr fein', 'https://world.openfoodfacts.org/product/4047247086769', '4047247086769'),
    ('Erasco', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'https://world.openfoodfacts.org/product/4037300103236', '4037300103236'),
    ('Kühne', 'Gurken Sauer Honig Schlemmertöpfchen', 'https://world.openfoodfacts.org/product/4012200417409', '4012200417409'),
    ('Nixe', 'Thunfisch', 'https://world.openfoodfacts.org/product/4056489254683', '4056489254683'),
    ('Appel', 'Zarte Filets vom Hering in Tomaten-Creme', 'https://world.openfoodfacts.org/product/4020500922011', '4020500922011'),
    ('KING''S CROWN (Aldi)', 'Tomatenmark', 'https://world.openfoodfacts.org/product/4061463307743', '4061463307743'),
    ('Almare Seafood', 'Thunfisch Filets in eigenen Saft', 'https://world.openfoodfacts.org/product/4061462630682', '4061462630682'),
    ('Aldi', 'Tomatenmark', 'https://world.openfoodfacts.org/product/4061462529290', '4061462529290'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'https://world.openfoodfacts.org/product/40081076', '40081076'),
    ('King''s Crown', 'Tomaten gehackt', 'https://world.openfoodfacts.org/product/4061461968052', '4061461968052'),
    ('Oro Di Parma', 'Tomaten', 'https://world.openfoodfacts.org/product/40081236', '40081236'),
    ('Hawesta', 'Heringsfilets - Tomaten-Creme', 'https://world.openfoodfacts.org/product/4006922000407', '4006922000407'),
    ('Aldi', 'Cornichons', 'https://world.openfoodfacts.org/product/4061458004244', '4061458004244'),
    ('Erasco', 'Vegetarischer linsen-eintopf', 'https://world.openfoodfacts.org/product/4037300104011', '4037300104011'),
    ('DmBio', 'Tomatenmark', 'https://world.openfoodfacts.org/product/4058172268717', '4058172268717'),
    ('Erasco', 'Erbsensuppe Hubertus', 'https://world.openfoodfacts.org/product/4037300108248', '4037300108248'),
    ('Hawesta', 'Heringsfilets - Pfeffercreme', 'https://world.openfoodfacts.org/product/4006922001602', '4006922001602'),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 'https://world.openfoodfacts.org/product/40081922', '40081922'),
    ('Bio Organic', 'Rote Beete', 'https://world.openfoodfacts.org/product/4056489152736', '4056489152736'),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'https://world.openfoodfacts.org/product/4020500922127', '4020500922127'),
    ('Appel', 'Zarte Filets vom Hering Tomate-Mozzarella', 'https://world.openfoodfacts.org/product/4020500922158', '4020500922158'),
    ('Erasco', 'Erbseneintopf', 'https://world.openfoodfacts.org/product/4037300104004', '4037300104004'),
    ('Aldi', 'Mais', 'https://world.openfoodfacts.org/product/4047247495820', '4047247495820'),
    ('Hengstenberg', 'Tomaten - Passiert', 'https://world.openfoodfacts.org/product/40081243', '40081243'),
    ('Sweet Valley', 'Pfirsiche halbe Frucht, leicht gezuckert', 'https://world.openfoodfacts.org/product/4061458004114', '4061458004114'),
    ('Deutsche See', 'Thunfisch im Aufguss', 'https://world.openfoodfacts.org/product/4009239608694', '4009239608694'),
    ('King''s Crown', 'Rote Beete in Kugeln', 'https://world.openfoodfacts.org/product/4047247097161', '4047247097161'),
    ('Freshona', 'Sonnenmais natursüß', 'https://world.openfoodfacts.org/product/20153229', '20153229'),
    ('REWE Bio', 'Tomaten in Stücken', 'https://world.openfoodfacts.org/product/4337256353014', '4337256353014'),
    ('Erasco', 'Erasco Erbsen-Eintopf 4037300108309', 'https://world.openfoodfacts.org/product/4037300108309', '4037300108309'),
    ('Aldi', 'Gehackte Tomaten', 'https://world.openfoodfacts.org/product/4061459112061', '4061459112061'),
    ('K-Classic', 'Thunfisch Filets I.E.S', 'https://world.openfoodfacts.org/product/4063367379833', '4063367379833'),
    ('Nestlé', 'Dosen Ravioli', 'https://world.openfoodfacts.org/product/4005500339403', '4005500339403'),
    ('Edeka', 'Delikatess Gewürzgurken', 'https://world.openfoodfacts.org/product/4311596446117', '4311596446117'),
    ('Mutti', 'Geschälte Italienische Tomaten', 'https://world.openfoodfacts.org/product/8005110060007', '8005110060007'),
    ('Sweet Valley', 'ALDI SWEET VALLEY OBST Ananas in Scheiben ohne Zuckerzusatz', 'https://world.openfoodfacts.org/product/4061459999075', '4061459999075'),
    ('Erasco', 'Serbische Bohnensuppe', 'https://world.openfoodfacts.org/product/4037300108460', '4037300108460')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE;

-- PIPELINE (Soups): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Soups'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Aldi', 'Bio-Gemüsebrühe', 'https://images.openfoodfacts.org/images/products/406/145/800/5814/front_en.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458005814', 'front_4061458005814'),
    ('Erasco', 'Hühner Nudel Topf/ Erasco', 'https://images.openfoodfacts.org/images/products/403/730/010/4370/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104370', 'front_4037300104370'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/8217/front_de.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108217', 'front_4037300108217'),
    ('Sonnen Bassermann', 'Hühner- Nudel-Topf/ So. Bas.', 'https://images.openfoodfacts.org/images/products/400/247/396/0351/front_de.100.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473960351', 'front_4002473960351'),
    ('10% Kartoffeln', 'Grüne Bohnen Eintopf Rind', 'https://images.openfoodfacts.org/images/products/400/247/396/2355/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473962355', 'front_4002473962355'),
    ('Bassermann', 'Eintopf Frühlingstopf m. Klößen', 'https://images.openfoodfacts.org/images/products/400/247/396/1358/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473961358', 'front_4002473961358'),
    ('Erasco', 'Grüne Bohnen Kartoffeltopf', 'https://images.openfoodfacts.org/images/products/403/730/010/3250/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103250', 'front_4037300103250'),
    ('Natur Werk', 'Kichererbsensuppe (mit Kokoscreme & Kreuzkümmel)', 'https://images.openfoodfacts.org/images/products/402/300/639/2210/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023006392210', 'front_4023006392210'),
    ('Lacroix', 'Gemüsefond', 'https://images.openfoodfacts.org/images/products/400/906/280/0845/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009062800845', 'front_4009062800845'),
    ('Asia Green Garden', 'Feurige Thaisuppe mit Hühnerfleisch', 'https://images.openfoodfacts.org/images/products/404/724/704/7616/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247047616', 'front_4047247047616'),
    ('Zimmermann', 'Leberknödelsuppe', 'https://images.openfoodfacts.org/images/products/400/615/369/7100/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006153697100', 'front_4006153697100'),
    ('Erasco', 'Hühner Reis-Topf', 'https://images.openfoodfacts.org/images/products/403/730/010/3328/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103328', 'front_4037300103328'),
    ('Natur Werk', 'Süßkartoffelsuppe mit Ingwer und Curry', 'https://images.openfoodfacts.org/images/products/402/300/639/2234/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023006392234', 'front_4023006392234'),
    ('Heisse Tasse', 'Knoblauch Französischer Art mit Croûtons', 'https://images.openfoodfacts.org/images/products/401/330/003/5067/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013300035067', 'front_4013300035067'),
    ('Erasco', 'Linseneintopf mit Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/8293/front_de.134.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108293', 'front_4037300108293'),
    ('Erasco', 'Erasco Kartoffelsuppe m. Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/8491/front_de.130.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108491', 'front_4037300108491'),
    ('Reis-fit', 'Kichererbsen mit Quinoa & Gemüse', 'https://images.openfoodfacts.org/images/products/400/623/764/2095/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006237642095', 'front_4006237642095'),
    ('Erasco', 'Westfälische Linsen Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/8231/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108231', 'front_4037300108231'),
    ('Erasco', 'Erasco Linsentopf mit Würstchen 4037300103236 Linsentopf mit Würstchen', 'https://images.openfoodfacts.org/images/products/403/730/010/3236/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103236', 'front_4037300103236'),
    ('Aldi', 'Pekingsuppe mit Hühnerfleisch', 'https://images.openfoodfacts.org/images/products/404/724/704/7609/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247047609', 'front_4047247047609'),
    ('Erasco', 'Lübecker Hochzeitssuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7340/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107340', 'front_4037300107340'),
    ('Erasco', 'Hühner-Nudelsuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7371/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107371', 'front_4037300107371'),
    ('Erasco', 'Dose Reistopf mit Fleischklößchen', 'https://images.openfoodfacts.org/images/products/403/730/010/4387/front_de.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104387', 'front_4037300104387'),
    ('Sonnen Bassermann', 'Erbsen-Eintopf mit Würstchen', 'https://images.openfoodfacts.org/images/products/400/247/396/6353/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473966353', 'front_4002473966353'),
    ('Erasco', 'Dosen Frischgemüsetopf mit Fleischklößchen', 'https://images.openfoodfacts.org/images/products/403/730/010/8279/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108279', 'front_4037300108279'),
    ('Speisezeit', 'Hühnernudeltopf', 'https://images.openfoodfacts.org/images/products/404/724/731/1489/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247311489', 'front_4047247311489'),
    ('Erasco', 'Hühner Nudel-Topf', 'https://images.openfoodfacts.org/images/products/403/730/010/3373/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103373', 'front_4037300103373'),
    ('Erasco', 'Kürbis Cremesuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7135/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107135', 'front_4037300107135'),
    ('Natur Werk', 'Möhrensuppe mit Ingwer und Kokosmilch', 'https://images.openfoodfacts.org/images/products/402/300/639/2135/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023006392135', 'front_4023006392135'),
    ('Ökoland', 'Linsensuppe mit Würstchenscheiben', 'https://images.openfoodfacts.org/images/products/403/182/923/2255/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4031829232255', 'front_4031829232255'),
    ('Erasco', 'Westfälischer Linsen-Eintopf mit Essig', 'https://images.openfoodfacts.org/images/products/403/730/010/3786/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103786', 'front_4037300103786'),
    ('Erasco', 'Heiße Tasse Champignon-Creme', 'https://images.openfoodfacts.org/images/products/401/330/003/4985/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013300034985', 'front_4013300034985'),
    ('Erasco', 'Leberknödelsuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7319/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107319', 'front_4037300107319'),
    ('Aldi', 'Fleisch-Bällcheneintopf mit Tomaten & Nudeln', 'https://images.openfoodfacts.org/images/products/406/145/801/0023/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458010023', 'front_4061458010023'),
    ('Geti wilba', 'Hühner Suppe', 'https://images.openfoodfacts.org/images/products/400/662/206/0046/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006622060046', 'front_4006622060046'),
    ('Rapunzel', 'Gemüsebrühe', 'https://images.openfoodfacts.org/images/products/400/604/027/1130/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040271130', 'front_4006040271130'),
    ('BioGourmet', 'BioGourmet Gemüsebrühe rein pflanzlich', 'https://images.openfoodfacts.org/images/products/403/905/740/0446/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4039057400446', 'front_4039057400446'),
    ('Sonnen Bassermann', 'Zwiebelsuppe französische Art', 'https://images.openfoodfacts.org/images/products/400/247/381/4456/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473814456', 'front_4002473814456'),
    ('Ökoland', 'Linsensuppe mit Würstchen', 'https://images.openfoodfacts.org/images/products/403/182/923/2200/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4031829232200', 'front_4031829232200'),
    ('Erasco', 'Vegetarischer Linseneintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/4011/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104011', 'front_4037300104011'),
    ('Erasco', 'Erbsensuppe Hubertus', 'https://images.openfoodfacts.org/images/products/403/730/010/8248/front_de.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108248', 'front_4037300108248'),
    ('Erasco', 'Vegetarischer Erbsen-Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/4004/front_en.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104004', 'front_4037300104004'),
    ('Bio', 'Veganer Erbseneintopf', 'https://images.openfoodfacts.org/images/products/406/146/258/0376/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462580376', 'front_4061462580376'),
    ('Indonesia', 'Bihun Suppe', 'https://images.openfoodfacts.org/images/products/400/800/200/0123/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008002000123', 'front_4008002000123'),
    ('Kania', 'Tomaten Suppe - toskanische Art', 'https://images.openfoodfacts.org/images/products/405/648/919/9083/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489199083', 'front_4056489199083'),
    ('Meica', 'Volle Kelle', 'https://images.openfoodfacts.org/images/products/400/050/324/3405/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000503243405', 'front_4000503243405'),
    ('Lacroix', 'Gulaschsuppe', 'https://images.openfoodfacts.org/images/products/400/906/245/2006/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009062452006', 'front_4009062452006'),
    ('Nur Nur Natur', 'Bio-Kartoffelsuppe', 'https://images.openfoodfacts.org/images/products/406/146/187/9259/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461879259', 'front_4061461879259'),
    ('Dm Bio', 'Dm Bio Linseneintopf', 'https://images.openfoodfacts.org/images/products/406/644/789/2444/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447892444', 'front_4066447892444'),
    ('Aldi', 'Gulasch-Suppe', 'https://images.openfoodfacts.org/images/products/406/145/800/9812/front_de.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009812', 'front_4061458009812'),
    ('DmBio', 'Tocană de mazăre ECO', 'https://images.openfoodfacts.org/images/products/405/817/282/4470/front_ro.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172824470', 'front_4058172824470'),
    ('Erasco', 'Kartoffel-Cremesuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7357/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107357', 'front_4037300107357'),
    ('Erasco', 'Ungarische Gulaschsuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7517/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107517', 'front_4037300107517'),
    ('Erasco', 'Pfifferling Rahmsuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7661/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107661', 'front_4037300107661'),
    ('Buss Fertiggerichte', 'Thai Suppe', 'https://images.openfoodfacts.org/images/products/406/145/800/9867/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009867', 'front_4061458009867'),
    ('Dreistern', 'Gulaschsuppe', 'https://images.openfoodfacts.org/images/products/400/627/602/9666/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006276029666', 'front_4006276029666'),
    ('Speisezeit', 'Bihun-Suppe', 'https://images.openfoodfacts.org/images/products/406/145/818/3147/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458183147', 'front_4061458183147'),
    ('Le Gusto', 'Waldpilzsuppe', 'https://images.openfoodfacts.org/images/products/406/146/357/9201/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463579201', 'front_4061463579201'),
    ('Naba Feinkost', 'Rote Beete Cremesuppe mit Birne', 'https://images.openfoodfacts.org/images/products/401/318/202/0472/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013182020472', 'front_4013182020472'),
    ('Nur Nur Natur', 'Bio-Brokkolisuppe', 'https://images.openfoodfacts.org/images/products/406/146/187/9297/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461879297', 'front_4061461879297'),
    ('Ener BIO', 'Čočková polévka', 'https://images.openfoodfacts.org/images/products/406/813/404/6383/front_cs.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068134046383', 'front_4068134046383'),
    ('Erasco', 'Heisse Tasse - Tomaten-Creme', 'https://images.openfoodfacts.org/images/products/401/330/003/4749/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013300034749', 'front_4013300034749'),
    ('Aldi', 'Tomaten-Rahmsuppe', 'https://images.openfoodfacts.org/images/products/406/145/800/9829/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009829', 'front_4061458009829'),
    ('Nabio', 'Erbsensuppe mit Basilikum', 'https://images.openfoodfacts.org/images/products/401/318/202/0403/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013182020403', 'front_4013182020403'),
    ('Buss', 'Ochsenschwanz-Suppe', 'https://images.openfoodfacts.org/images/products/404/724/704/7562/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247047562', 'front_4047247047562'),
    ('Erasco', 'Erasco Erbsen-Eintopf 4037300108309', 'https://images.openfoodfacts.org/images/products/403/730/010/8309/front_de.97.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108309', 'front_4037300108309'),
    ('Little Lunch', 'Kürbissuppe von Little Lunch', 'https://images.openfoodfacts.org/images/products/426/061/472/0411/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260614720411', 'front_4260614720411'),
    ('Larco', 'Hühnerbrühe konzentriert mit Fleisch', 'https://images.openfoodfacts.org/images/products/871/023/609/1049/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 8710236091049', 'front_8710236091049'),
    ('DmBio', 'Linseneintopf', 'https://images.openfoodfacts.org/images/products/406/779/606/8351/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796068351', 'front_4067796068351'),
    ('Erasco', 'Serbische Bohnensuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/8460/front_de.73.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300108460', 'front_4037300108460'),
    ('Knorr', 'Bratensoße', 'https://images.openfoodfacts.org/images/products/871/120/041/4352/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711200414352', 'front_8711200414352'),
    ('Maggi', '5 Minuten Terrine - Hühner-Nudeltopf', 'https://images.openfoodfacts.org/images/products/761/303/768/3561/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037683561', 'front_7613037683561'),
    ('Erasco', 'Tomatencreme suppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7326/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107326', 'front_4037300107326'),
    ('Netto', 'Hühner Nudeltopf', 'https://images.openfoodfacts.org/images/products/431/626/804/6336/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268046336', 'front_4316268046336'),
    ('Frosta', 'Yummy Tummy Soup', 'https://images.openfoodfacts.org/images/products/400/836/600/0296/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366000296', 'front_4008366000296'),
    ('Erasco', 'Erbsen-Eintopf', 'https://images.openfoodfacts.org/images/products/403/730/010/3243/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300103243', 'front_4037300103243'),
    ('Little Lunch', 'Little Lunch Bio Little Marokko 4280000878991 Bio-Eintopf mit Gemüse und Gewürzen marokkanischer Art', 'https://images.openfoodfacts.org/images/products/428/000/087/8991/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4280000878991', 'front_4280000878991'),
    ('Reichenhof', 'Vegetarischer Linseneintopf', 'https://images.openfoodfacts.org/images/products/401/318/202/8058/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013182028058', 'front_4013182028058'),
    ('Sonnen Bassermann', 'Eintopf Linseneintopf', 'https://images.openfoodfacts.org/images/products/400/247/396/7350/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473967350', 'front_4002473967350'),
    ('Erasco', 'Graupen-Topf', 'https://images.openfoodfacts.org/images/products/403/730/010/4431/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104431', 'front_4037300104431'),
    ('Maggi', 'Tütensuppe', 'https://images.openfoodfacts.org/images/products/761/303/605/3600/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036053600', 'front_7613036053600'),
    ('La Finesse', 'Minestrone', 'https://images.openfoodfacts.org/images/products/406/145/800/9881/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009881', 'front_4061458009881'),
    ('Seitenbacher', 'Klare Suppe', 'https://images.openfoodfacts.org/images/products/400/839/100/4214/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008391004214', 'front_4008391004214'),
    ('Reichenhof', 'Vegetarische Gulaschsuppe', 'https://images.openfoodfacts.org/images/products/401/318/202/8591/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013182028591', 'front_4013182028591'),
    ('Erasco', 'Ochsenschwanzsuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7555/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107555', 'front_4037300107555'),
    ('Metzger Meyer', 'Erbseneintopf', 'https://images.openfoodfacts.org/images/products/440/010/801/2015/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400108012015', 'front_4400108012015'),
    ('Nur Nur Natur', 'BioKarottenIngwerSuppe', 'https://images.openfoodfacts.org/images/products/406/146/187/9273/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461879273', 'front_4061461879273'),
    ('SonnenBassermann', 'Gulaschsuppe', 'https://images.openfoodfacts.org/images/products/400/858/510/3211/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008585103211', 'front_4008585103211'),
    ('Asia Green Garden', 'Asia Fond', 'https://images.openfoodfacts.org/images/products/406/146/211/4779/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462114779', 'front_4061462114779'),
    ('Aldi', 'Konserve Erbseneintopf', 'https://images.openfoodfacts.org/images/products/406/145/801/0030/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458010030', 'front_4061458010030'),
    ('Maggi', 'Grießklößchen Suppe', 'https://images.openfoodfacts.org/images/products/761/303/515/1697/front_en.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613035151697', 'front_7613035151697'),
    ('Erasco', 'Spargel Cremesuppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7647/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107647', 'front_4037300107647'),
    ('Edeka', 'Hühner Nudeltopf', 'https://images.openfoodfacts.org/images/products/431/150/146/3383/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501463383', 'front_4311501463383'),
    ('Sonnen Bassermann', 'Tomatencremesuppe', 'https://images.openfoodfacts.org/images/products/400/247/385/9457/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002473859457', 'front_4002473859457'),
    ('Followfood', 'Gemüsesuppe mit Kichererbsen', 'https://images.openfoodfacts.org/images/products/426/065/555/1241/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260655551241', 'front_4260655551241'),
    ('EWU', 'Soljanka', 'https://images.openfoodfacts.org/images/products/401/551/879/9007/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015518799007', 'front_4015518799007'),
    ('Erasco', 'Feurige Thai-Suppe', 'https://images.openfoodfacts.org/images/products/403/730/010/7586/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300107586', 'front_4037300107586'),
    ('Speisezeit', 'Festtagssuppe', 'https://images.openfoodfacts.org/images/products/406/145/800/9874/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009874', 'front_4061458009874'),
    ('Natur-Werk', 'Rote Linsensuppe', 'https://images.openfoodfacts.org/images/products/402/300/639/2142/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023006392142', 'front_4023006392142')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Soups' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

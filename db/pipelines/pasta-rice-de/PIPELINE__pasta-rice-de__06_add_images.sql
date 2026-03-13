-- PIPELINE (Pasta & Rice): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Pasta & Rice'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'https://images.openfoodfacts.org/images/products/407/560/005/5039/front_de.180.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600055039', 'front_4075600055039'),
    ('FRoSTA', 'Tortellini Käse-Sahne (vegetarisch)', 'https://images.openfoodfacts.org/images/products/400/836/600/9961/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009961', 'front_4008366009961'),
    ('Aldi', 'Bio-Penne aus grünen Erbsen', 'https://images.openfoodfacts.org/images/products/406/145/810/2711/front_de.104.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458102711', 'front_4061458102711'),
    ('DmBio', 'Gemüse Tortellini', 'https://images.openfoodfacts.org/images/products/406/779/600/2508/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796002508', 'front_4067796002508'),
    ('Henglein', 'Frischer Blätterteig', 'https://images.openfoodfacts.org/images/products/400/116/313/5734/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163135734', 'front_4001163135734'),
    ('Aldi', 'Frische Mezzelune - Kürbis, Salbei und Mascarpone', 'https://images.openfoodfacts.org/images/products/406/145/815/1214/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458151214', 'front_4061458151214'),
    ('Landfreude', 'Schwäbische Eierspätzle', 'https://images.openfoodfacts.org/images/products/406/145/824/0031/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458240031', 'front_4061458240031'),
    ('Bürger', 'Maultaschen original schwäbisch', 'https://images.openfoodfacts.org/images/products/407/560/005/5145/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600055145', 'front_4075600055145'),
    ('Landfreude', 'Spätzle', 'https://images.openfoodfacts.org/images/products/406/145/801/8784/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458018784', 'front_4061458018784'),
    ('Landfreude', 'Spätzle / Nudeln', 'https://images.openfoodfacts.org/images/products/406/145/806/8499/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458068499', 'front_4061458068499'),
    ('Aldi', 'Schwäbische Maultaschen traditionelle Art', 'https://images.openfoodfacts.org/images/products/406/145/801/8340/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458018340', 'front_4061458018340'),
    ('Dorfmühle', 'Frischeier schwäbische Spätzle', 'https://images.openfoodfacts.org/images/products/400/039/825/4159/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000398254159', 'front_4000398254159'),
    ('Henglein', 'Frische Spätzle vegan', 'https://images.openfoodfacts.org/images/products/400/116/311/0922/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163110922', 'front_4001163110922'),
    ('Aldi', 'Frische Ravioloni - Karamellisierte Zwiebeln und Ziegenkäse', 'https://images.openfoodfacts.org/images/products/406/145/815/1221/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458151221', 'front_4061458151221'),
    ('Bio', 'Schwäbische Maultaschen', 'https://images.openfoodfacts.org/images/products/406/146/203/7887/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462037887', 'front_4061462037887'),
    ('Nestlé', 'Ravioli Gemüse', 'https://images.openfoodfacts.org/images/products/400/550/033/0318/front_de.123.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500330318', 'front_4005500330318'),
    ('Henglein', 'Spätzle', 'https://images.openfoodfacts.org/images/products/400/116/300/0506/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163000506', 'front_4001163000506'),
    ('Frosta', 'Tagliatelle Rahm Hähnchen', 'https://images.openfoodfacts.org/images/products/400/836/601/7317/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366017317', 'front_4008366017317'),
    ('Chef select', 'Spätzle-Pfanne mit Hähnchen und Gemüse', 'https://images.openfoodfacts.org/images/products/405/648/949/7714/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489497714', 'front_4056489497714'),
    ('Frosta', 'Veggie Geschnetzeltes mit Spätzle', 'https://images.openfoodfacts.org/images/products/400/836/600/2580/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366002580', 'front_4008366002580'),
    ('Egle', 'Wiener Würste', 'https://images.openfoodfacts.org/images/products/400/840/162/0052/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008401620052', 'front_4008401620052'),
    ('Bürger', 'Eierspätzle', 'https://images.openfoodfacts.org/images/products/407/560/011/3470/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600113470', 'front_4075600113470'),
    ('Henglein', 'Schupfnudeln', 'https://images.openfoodfacts.org/images/products/400/116/300/0599/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163000599', 'front_4001163000599'),
    ('Dm', 'Fussili rote Linsen', 'https://images.openfoodfacts.org/images/products/406/779/609/6347/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796096347', 'front_4067796096347'),
    ('Combino', 'Nudeln Dinkel Penne', 'https://images.openfoodfacts.org/images/products/405/648/929/1060/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489291060', 'front_4056489291060'),
    ('Combino', 'Fussili', 'https://images.openfoodfacts.org/images/products/401/315/960/4575/front_de.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013159604575', 'front_4013159604575'),
    ('Gut Bio', 'Bio-Penne Vollkorn', 'https://images.openfoodfacts.org/images/products/406/145/803/6672/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458036672', 'front_4061458036672'),
    ('Aldi', 'Spaghettini', 'https://images.openfoodfacts.org/images/products/406/145/803/6702/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458036702', 'front_4061458036702'),
    ('Aldi', 'Bio-Strozzapreti aus roten Linsen', 'https://images.openfoodfacts.org/images/products/406/145/810/2728/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458102728', 'front_4061458102728'),
    ('Cometino', 'Nudeln Spaghetti', 'https://images.openfoodfacts.org/images/products/401/315/960/4599/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013159604599', 'front_4013159604599'),
    ('Vemondo', 'Vegan tortelloni with meat alternative filling', 'https://images.openfoodfacts.org/images/products/405/648/948/3489/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489483489', 'front_4056489483489'),
    ('Aldi', 'Wok-Nudeln - Klassik Chinanudel', 'https://images.openfoodfacts.org/images/products/406/146/399/0884/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463990884', 'front_4061463990884'),
    ('Aldi', 'Vollkorn Farfalle', 'https://images.openfoodfacts.org/images/products/406/644/712/2688/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447122688', 'front_4066447122688'),
    ('Combino', 'Glutenfrei Fusili', 'https://images.openfoodfacts.org/images/products/405/648/913/3049/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489133049', 'front_4056489133049'),
    ('Asia Green Garden', 'Udon Nudeln - Japanisch', 'https://images.openfoodfacts.org/images/products/406/145/961/8587/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459618587', 'front_4061459618587'),
    ('What''s Cooking?', 'Bami Goreng', 'https://images.openfoodfacts.org/images/products/405/648/912/7284/front_en.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489127284', 'front_4056489127284'),
    ('Vitasia', 'Konjac Noodles', 'https://images.openfoodfacts.org/images/products/405/648/937/6194/front_en.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489376194', 'front_4056489376194'),
    ('Nur Nur Natur', 'Spaghetti - Dinkel', 'https://images.openfoodfacts.org/images/products/406/145/927/0303/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459270303', 'front_4061459270303'),
    ('Chef Select', 'Feine Schlupfnudeln', 'https://images.openfoodfacts.org/images/products/405/648/948/4202/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489484202', 'front_4056489484202'),
    ('Aldi', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/406/145/800/3841/front_de.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458003841', 'front_4061458003841'),
    ('Aldi', 'Bio-Fusilli', 'https://images.openfoodfacts.org/images/products/406/145/803/6689/front_de.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458036689', 'front_4061458036689'),
    ('DmBio', 'Pasta Fusilli Rote Linsen Nudeln', 'https://images.openfoodfacts.org/images/products/405/817/251/6030/front_en.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172516030', 'front_4058172516030'),
    ('Baresa', 'Tortelloni Ricotta et épinards', 'https://images.openfoodfacts.org/images/products/405/648/900/9191/front_en.138.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489009191', 'front_4056489009191'),
    ('Combino', 'Rote Linsen Rollini', 'https://images.openfoodfacts.org/images/products/405/648/929/0681/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489290681', 'front_4056489290681'),
    ('Asia Green Garden', 'Udon-Nudeln mit Erdnusssauce', 'https://images.openfoodfacts.org/images/products/406/146/186/7669/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461867669', 'front_4061461867669'),
    ('Bio', 'Farfalle Vollkorn', 'https://images.openfoodfacts.org/images/products/406/146/368/9177/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463689177', 'front_4061463689177'),
    ('Aldi', 'Schupfnudeln', 'https://images.openfoodfacts.org/images/products/406/145/801/8777/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458018777', 'front_4061458018777'),
    ('Henglein', 'Kartoffel-Gnocchi', 'https://images.openfoodfacts.org/images/products/400/116/313/4218/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163134218', 'front_4001163134218'),
    ('Aldi', 'Tortelloni Spinat-Ricotta', 'https://images.openfoodfacts.org/images/products/406/145/805/7868/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458057868', 'front_4061458057868'),
    ('DmBio', 'Dinkel Vollkorn Locken Nudeln', 'https://images.openfoodfacts.org/images/products/405/817/238/8651/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172388651', 'front_4058172388651'),
    ('Aldi', 'Tortelloni - Prosciutto-Mortadella', 'https://images.openfoodfacts.org/images/products/406/145/805/7851/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458057851', 'front_4061458057851'),
    ('DmBio', 'Gnocchi', 'https://images.openfoodfacts.org/images/products/405/817/284/8742/front_en.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172848742', 'front_4058172848742'),
    ('Combino', 'Penne Rigate', 'https://images.openfoodfacts.org/images/products/401/315/960/4551/front_en.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013159604551', 'front_4013159604551'),
    ('Chef select', 'Frische Tortelloni Ricotta & Spinat', 'https://images.openfoodfacts.org/images/products/405/648/930/5590/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489305590', 'front_4056489305590'),
    ('Asia Green Garden', 'Soba Nudeln - Japanisch', 'https://images.openfoodfacts.org/images/products/406/145/961/8600/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459618600', 'front_4061459618600'),
    ('Aldi', 'Kritharaki', 'https://images.openfoodfacts.org/images/products/406/145/804/9009/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458049009', 'front_4061458049009'),
    ('FRoSTA', 'Pappardelle Crème Spinaci', 'https://images.openfoodfacts.org/images/products/400/836/600/8858/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366008858', 'front_4008366008858'),
    ('Cucina', 'Gnocchi - Kartoffel', 'https://images.openfoodfacts.org/images/products/406/146/264/8359/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462648359', 'front_4061462648359'),
    ('Aldi', 'Fusilli', 'https://images.openfoodfacts.org/images/products/406/145/800/3834/front_de.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458003834', 'front_4061458003834'),
    ('K Bio', 'Bio Fusilli, Vollkorn', 'https://images.openfoodfacts.org/images/products/406/336/714/7999/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367147999', 'front_4063367147999'),
    ('Aldi', 'Bio-Fusilli aus Kichererbsen', 'https://images.openfoodfacts.org/images/products/406/145/810/2704/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458102704', 'front_4061458102704'),
    ('Combino', 'Dinkel Nudeln', 'https://images.openfoodfacts.org/images/products/405/648/929/1053/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489291053', 'front_4056489291053'),
    ('Bamboo Garden', 'Glasnudeln Breit', 'https://images.openfoodfacts.org/images/products/402/390/054/5385/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023900545385', 'front_4023900545385'),
    ('Dm Bio', 'Spaghetti 100% Hartweizen', 'https://images.openfoodfacts.org/images/products/406/779/606/4834/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796064834', 'front_4067796064834'),
    ('Bürger', 'Kartoffel-Gnocchi', 'https://images.openfoodfacts.org/images/products/407/560/013/5984/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600135984', 'front_4075600135984'),
    ('Combino', 'Lasagne', 'https://images.openfoodfacts.org/images/products/405/648/970/7523/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489707523', 'front_4056489707523'),
    ('Bio+', 'Nudeln Dinkellocken Vollkorn Biobio', 'https://images.openfoodfacts.org/images/products/406/146/381/2124/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463812124', 'front_4061463812124'),
    ('Steinhaus', 'Tomaten - Mozzarella - Tortelli', 'https://images.openfoodfacts.org/images/products/400/933/790/2083/front_fr.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009337902083', 'front_4009337902083'),
    ('Riesa Nudeln', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/401/342/391/0104/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013423910104', 'front_4013423910104'),
    ('Bamboo Garden', 'Glasnudeln', 'https://images.openfoodfacts.org/images/products/402/390/054/5361/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023900545361', 'front_4023900545361'),
    ('DmBio', 'Fusilli Kichererbsen Nudeln', 'https://images.openfoodfacts.org/images/products/405/817/251/6016/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172516016', 'front_4058172516016'),
    ('Lorenz', 'Erdnusslocken', 'https://images.openfoodfacts.org/images/products/401/807/700/6159/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077006159', 'front_4018077006159'),
    ('3 Glocken', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/400/296/600/4074/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002966004074', 'front_4002966004074'),
    ('Lien Ying', 'Noodles Uncooked', 'https://images.openfoodfacts.org/images/products/401/320/088/0088/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013200880088', 'front_4013200880088'),
    ('Lien Ying', 'Reis-bandnudeln', 'https://images.openfoodfacts.org/images/products/401/320/088/0019/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013200880019', 'front_4013200880019'),
    ('Bamboo Garden', 'Mie-Nudeln', 'https://images.openfoodfacts.org/images/products/402/390/054/5101/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023900545101', 'front_4023900545101'),
    ('Mirácoli', 'MIRÁCOLI Klassik Spaghetti 3 Portionen', 'https://images.openfoodfacts.org/images/products/400/235/901/8633/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002359018633', 'front_4002359018633'),
    ('Landfreunde', 'Bandnudeln', 'https://images.openfoodfacts.org/images/products/406/145/930/1854/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459301854', 'front_4061459301854'),
    ('Rapunzel', 'Spirelli', 'https://images.openfoodfacts.org/images/products/400/604/015/0510/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006040150510', 'front_4006040150510'),
    ('Spielberger Mühle', 'Wholegrain Speltpasta', 'https://images.openfoodfacts.org/images/products/402/238/101/4106/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4022381014106', 'front_4022381014106'),
    ('Gut & Günstig', 'Spätzle Pfanne', 'https://images.openfoodfacts.org/images/products/431/150/164/1477/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501641477', 'front_4311501641477'),
    ('REWE Beste Wahl', 'Rindfleisch Tortelloni HERZHAFT & WÜRZIG', 'https://images.openfoodfacts.org/images/products/433/725/667/2887/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256672887', 'front_4337256672887'),
    ('Lidl', 'Tagliatelle Wildlachs', 'https://images.openfoodfacts.org/images/products/405/648/963/9220/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489639220', 'front_4056489639220'),
    ('Alnatura', 'Tortellini Gemüse semi frisch', 'https://images.openfoodfacts.org/images/products/410/442/025/0192/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420250192', 'front_4104420250192'),
    ('Mylos', 'Mylos Kritharaki 4260122510405 Griechische Teigwaren aus 100% Hartweizengrieß', 'https://images.openfoodfacts.org/images/products/426/012/251/0405/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260122510405', 'front_4260122510405'),
    ('Barilla', 'Fusilli 98', 'https://images.openfoodfacts.org/images/products/807/680/208/5981/front_en.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076802085981', 'front_8076802085981'),
    ('Barilla', 'Pasta Girandole 500g Barilla', 'https://images.openfoodfacts.org/images/products/807/680/951/2268/front_de.268.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809512268', 'front_8076809512268'),
    ('Barilla', 'Lasagne', 'https://images.openfoodfacts.org/images/products/807/680/952/3738/front_en.361.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809523738', 'front_8076809523738'),
    ('Combino', 'Spaghetti blé complet Bio', 'https://images.openfoodfacts.org/images/products/000/002/099/5744/front_fr.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 20995744', 'front_20995744'),
    ('Lidl', 'Bio vollkorn penne', 'https://images.openfoodfacts.org/images/products/000/002/099/5751/front_en.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 20995751', 'front_20995751'),
    ('Barilla', 'Capellini (Spagetti) Nr. 1', 'https://images.openfoodfacts.org/images/products/807/680/019/5019/front_en.2385.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076800195019', 'front_8076800195019'),
    ('Barilla', 'Fusilli Integrale', 'https://images.openfoodfacts.org/images/products/807/680/952/9457/front_en.166.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076809529457', 'front_8076809529457'),
    ('Iglo', 'Tagliatelle Pilz-Pfanne', 'https://images.openfoodfacts.org/images/products/425/024/120/6778/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241206778', 'front_4250241206778'),
    ('Gut & Günstig', 'Spaghetti Nudeln', 'https://images.openfoodfacts.org/images/products/431/159/641/0644/front_de.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311596410644', 'front_4311596410644'),
    ('Just Taste', 'Edamame Spaghetti', 'https://images.openfoodfacts.org/images/products/426/065/148/0019/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260651480019', 'front_4260651480019'),
    ('REWE Bio', 'Penne Vollkorn', 'https://images.openfoodfacts.org/images/products/433/725/656/1563/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256561563', 'front_4337256561563'),
    ('Rewe', 'Gnocci', 'https://images.openfoodfacts.org/images/products/433/725/629/9572/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256299572', 'front_4337256299572'),
    ('REWE Beste Wahl', 'Gnocchi', 'https://images.openfoodfacts.org/images/products/433/725/667/5017/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256675017', 'front_4337256675017'),
    ('Giovanni Rana', 'Ravioli Ricotta und Spinat', 'https://images.openfoodfacts.org/images/products/800/166/572/7471/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 8001665727471', 'front_8001665727471'),
    ('REWE Beste Wahl', 'Spinat ricotta Tortellini', 'https://images.openfoodfacts.org/images/products/433/725/667/2092/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256672092', 'front_4337256672092')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Pasta & Rice' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

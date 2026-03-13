-- PIPELINE (Ready Meals): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Ready Meals'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Bürger', 'Vegane Maultaschen mit feinem Gemüse', 'https://images.openfoodfacts.org/images/products/407/560/005/8177/front_de.95.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600058177', 'front_4075600058177'),
    ('Frosta', 'Bratkartoffel Hähnchen Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/600/1484/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001484', 'front_4008366001484'),
    ('Rügenwalder Mühle', 'Fleischsalat (vegan) - Rügenwalder Mühle', 'https://images.openfoodfacts.org/images/products/400/040/500/2704/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405002704', 'front_4000405002704'),
    ('Bürger', 'Gemüse-Maultaschen', 'https://images.openfoodfacts.org/images/products/407/560/005/8634/front_de.109.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600058634', 'front_4075600058634'),
    ('FRoSTA', 'Hühnerfrikassee', 'https://images.openfoodfacts.org/images/products/400/836/600/8582/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366008582', 'front_4008366008582'),
    ('FRoSTA', 'Rahmgeschnetzeltes mit Hähnchen und Spätzle', 'https://images.openfoodfacts.org/images/products/400/836/601/0967/front_en.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010967', 'front_4008366010967'),
    ('Kuehne', 'Schlemmertöpfchen gew. Gurken', 'https://images.openfoodfacts.org/images/products/401/220/004/6654/front_de.128.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012200046654', 'front_4012200046654'),
    ('Golden Seafood', 'Fischstäbchen', 'https://images.openfoodfacts.org/images/products/406/145/801/7367/front_de.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458017367', 'front_4061458017367'),
    ('Frosta', 'Spätzle Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/600/2757/front_en.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366002757', 'front_4008366002757'),
    ('Frosta', 'Hähnchen Curry', 'https://images.openfoodfacts.org/images/products/400/836/600/1347/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001347', 'front_4008366001347'),
    ('Frosta', 'Rotes Curry mit Hähnchen und Reis', 'https://images.openfoodfacts.org/images/products/400/836/601/7331/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366017331', 'front_4008366017331'),
    ('Kühlmann', 'Klarer Weißkrautsalat', 'https://images.openfoodfacts.org/images/products/406/145/821/9655/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458219655', 'front_4061458219655'),
    ('Bürger', 'Freilandhähnchen-Maultaschen', 'https://images.openfoodfacts.org/images/products/407/560/011/1834/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600111834', 'front_4075600111834'),
    ('Bunte Küche', 'Pasta mit Hähnchen in fruchtiger Tomatensoße', 'https://images.openfoodfacts.org/images/products/406/146/293/6333/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462936333', 'front_4061462936333'),
    ('Daylicious', 'Salatcup - Hähnchen mit Senf-Dressing', 'https://images.openfoodfacts.org/images/products/406/145/911/9190/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459119190', 'front_4061459119190'),
    ('Original Wagner', 'Flammkuchen Elsässer Art', 'https://images.openfoodfacts.org/images/products/400/923/300/3686/front_de.108.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003686', 'front_4009233003686'),
    ('Dr. Oetker', 'Die Ofenfrische Vier Käse', 'https://images.openfoodfacts.org/images/products/400/172/401/1118/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011118', 'front_4001724011118'),
    ('Dilek', 'Gefüllte Weinblätter mit Reis', 'https://images.openfoodfacts.org/images/products/403/657/790/5093/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036577905093', 'front_4036577905093'),
    ('Aldi', 'Hähnchen Mediterran', 'https://images.openfoodfacts.org/images/products/406/145/804/2130/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458042130', 'front_4061458042130'),
    ('Frosta', 'Wildlachs in Kräuterrahm', 'https://images.openfoodfacts.org/images/products/400/836/601/5535/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015535', 'front_4008366015535'),
    ('FRoSTA', 'Paprika Sahne Hähnchen mit Bandnudeln', 'https://images.openfoodfacts.org/images/products/400/836/601/0981/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010981', 'front_4008366010981'),
    ('Reis-fit', 'Linsen mit Reis & Gemüse - Fach 14', 'https://images.openfoodfacts.org/images/products/400/623/764/2101/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006237642101', 'front_4006237642101'),
    ('FRoSTA', 'Thai Style Hähnchen mit Bandnudeln', 'https://images.openfoodfacts.org/images/products/400/836/601/3852/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366013852', 'front_4008366013852'),
    ('Bauck Hof', 'Grünkern Burger', 'https://images.openfoodfacts.org/images/products/401/563/700/4945/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015637004945', 'front_4015637004945'),
    ('Bürger', 'Bio Gemüse Maultaschen', 'https://images.openfoodfacts.org/images/products/407/560/012/5114/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600125114', 'front_4075600125114'),
    ('FRoSTA', 'Gemüsebowl Cremiges Linsencurry mit Kürbis & Spinat', 'https://images.openfoodfacts.org/images/products/400/836/688/3400/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883400', 'front_4008366883400'),
    ('FRoSTA', 'Hackbällchen Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/600/3686/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366003686', 'front_4008366003686'),
    ('Pfanni', 'Kartoffelknödel halb & halb', 'https://images.openfoodfacts.org/images/products/400/040/013/0570/front_de.112.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000400130570', 'front_4000400130570'),
    ('Erasco', 'Hühner Reis-Topf', 'https://images.openfoodfacts.org/images/products/403/730/010/4356/front_de.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4037300104356', 'front_4037300104356'),
    ('FRoSTA', 'Reis Hähnchen Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/601/0042/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010042', 'front_4008366010042'),
    ('Kühne', 'Grünkohl', 'https://images.openfoodfacts.org/images/products/000/004/080/4033/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 40804033', 'front_40804033'),
    ('Frosta', 'Bami Goreng', 'https://images.openfoodfacts.org/images/products/400/836/600/1309/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001309', 'front_4008366001309'),
    ('Frosta', 'Butter Chicken', 'https://images.openfoodfacts.org/images/products/400/836/600/3587/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366003587', 'front_4008366003587'),
    ('Original Wagner', 'Pizza Die Backfrische Mozzarella', 'https://images.openfoodfacts.org/images/products/400/923/300/6847/front_de.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233006847', 'front_4009233006847'),
    ('Frosta', 'Nice Rice - Korean Style', 'https://images.openfoodfacts.org/images/products/400/836/688/3301/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883301', 'front_4008366883301'),
    ('Dr. Oetker Ristorante', 'Ristorante PIZZA TONNO', 'https://images.openfoodfacts.org/images/products/400/172/403/8993/front_en.98.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038993', 'front_4001724038993'),
    ('FRoSTA', 'Paella', 'https://images.openfoodfacts.org/images/products/400/836/601/5337/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015337', 'front_4008366015337'),
    ('Bauch Hof', 'Falafel', 'https://images.openfoodfacts.org/images/products/401/563/782/2952/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015637822952', 'front_4015637822952'),
    ('Rügenwalder Mühle', 'Veganer Schinkenspicker Salat', 'https://images.openfoodfacts.org/images/products/400/040/500/2711/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405002711', 'front_4000405002711'),
    ('Dr. Oetker', 'Suprema Pizza Calabrese & ''Nduja', 'https://images.openfoodfacts.org/images/products/400/172/404/9906/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724049906', 'front_4001724049906'),
    ('Original Wagner', 'Steinofen-Pizza Mozzarella Vegetarisch', 'https://images.openfoodfacts.org/images/products/400/923/300/3952/front_de.128.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003952', 'front_4009233003952'),
    ('Dr. Oetker', 'Die Ofenfrische Margherita', 'https://images.openfoodfacts.org/images/products/400/172/401/5420/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724015420', 'front_4001724015420'),
    ('Frosta', 'Fisch Schlemmerfilet Mediterraner Art', 'https://images.openfoodfacts.org/images/products/400/836/600/9787/front_de.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009787', 'front_4008366009787'),
    ('Frosta', 'Fettuccine Wildlachs', 'https://images.openfoodfacts.org/images/products/400/836/601/5511/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015511', 'front_4008366015511'),
    ('Dahlhoff Feinkost', 'Kartoffelsalat - Tegernseer Art', 'https://images.openfoodfacts.org/images/products/400/482/012/4072/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004820124072', 'front_4004820124072'),
    ('Bio', 'Veganer Linseneintopf', 'https://images.openfoodfacts.org/images/products/406/146/258/0406/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462580406', 'front_4061462580406'),
    ('Dr. Oetker', 'Pizza Tradizionale Margherita', 'https://images.openfoodfacts.org/images/products/400/172/403/8597/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038597', 'front_4001724038597'),
    ('Original Wagner', 'Steinofen-Pizza - Diavolo', 'https://images.openfoodfacts.org/images/products/400/923/300/3655/front_de.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003655', 'front_4009233003655'),
    ('Dr. Oetker', 'Die Ofenfrische Speciale', 'https://images.openfoodfacts.org/images/products/400/172/401/1057/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011057', 'front_4001724011057'),
    ('Dr. Oetker', 'Pizza Salame Ristorante', 'https://images.openfoodfacts.org/images/products/400/172/403/8900/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038900', 'front_4001724038900'),
    ('Vemondo', 'Vegan pizza Verdura', 'https://images.openfoodfacts.org/images/products/405/648/945/1044/front_cs.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489451044', 'front_4056489451044'),
    ('Dm Bio', 'Kichererbseneintopf mit Kokosmilch', 'https://images.openfoodfacts.org/images/products/406/779/609/7184/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796097184', 'front_4067796097184'),
    ('Dr. Oetker', 'Die Ofenfrische Salami', 'https://images.openfoodfacts.org/images/products/400/172/401/1170/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011170', 'front_4001724011170'),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 'https://images.openfoodfacts.org/images/products/000/004/008/1908/front_de.154.400.jpg', 'off_api', 'front', true, 'Front — EAN 40081908', 'front_40081908'),
    ('Frosta', 'Fisch Schlemmerfilet Brokkoli Mandel', 'https://images.openfoodfacts.org/images/products/400/836/600/9763/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009763', 'front_4008366009763'),
    ('Omnimax Lebensmittel', 'Chili con Carne', 'https://images.openfoodfacts.org/images/products/406/145/800/9966/front_de.75.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009966', 'front_4061458009966'),
    ('Cucina Nobile', 'Tortelloni - Spinat-Ricotta', 'https://images.openfoodfacts.org/images/products/406/145/801/4878/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014878', 'front_4061458014878'),
    ('Dr. Oetker', 'La Mia Grande Rucola', 'https://images.openfoodfacts.org/images/products/400/172/404/0538/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724040538', 'front_4001724040538'),
    ('Bürger', 'Vegane Maultaschen 2.0', 'https://images.openfoodfacts.org/images/products/407/560/011/2541/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600112541', 'front_4075600112541'),
    ('Dr. Oetker', 'Ristorante Pizza Funghi', 'https://images.openfoodfacts.org/images/products/400/172/403/8931/front_de.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038931', 'front_4001724038931'),
    ('GiaPizza', 'Bio-Dinkel-Steinofenpizza - Spinat', 'https://images.openfoodfacts.org/images/products/406/146/321/3211/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463213211', 'front_4061463213211'),
    ('Nestlé', 'Pizza Speciale', 'https://images.openfoodfacts.org/images/products/400/923/300/3587/front_de.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003587', 'front_4009233003587'),
    ('Dr. Oetker', 'La Mia Grande Pizza Margherita', 'https://images.openfoodfacts.org/images/products/400/172/402/7195/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724027195', 'front_4001724027195'),
    ('Lidl', 'Vegane Kartoffel-Schupfnudeln', 'https://images.openfoodfacts.org/images/products/405/648/938/7688/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489387688', 'front_4056489387688'),
    ('Popp', 'Kartoffelsalat Gurke, Zwiebel & Ei', 'https://images.openfoodfacts.org/images/products/404/580/070/0442/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045800700442', 'front_4045800700442'),
    ('Bon-ri', 'Express Reis Parboiled Mexikanische Art', 'https://images.openfoodfacts.org/images/products/406/146/154/3921/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461543921', 'front_4061461543921'),
    ('Frosta', 'Nom Nom Noodles', 'https://images.openfoodfacts.org/images/products/400/836/600/0500/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366000500', 'front_4008366000500'),
    ('Condeli', 'Lasagne Bolognese', 'https://images.openfoodfacts.org/images/products/406/145/801/7213/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458017213', 'front_4061458017213'),
    ('Dr. Oetker', 'Ristorante Pizza Pasta', 'https://images.openfoodfacts.org/images/products/400/172/403/9389/front_en.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724039389', 'front_4001724039389'),
    ('Nordsee', 'Fischfrikadellen', 'https://images.openfoodfacts.org/images/products/403/080/007/8943/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4030800078943', 'front_4030800078943'),
    ('Asia Green Garden', 'Samosas', 'https://images.openfoodfacts.org/images/products/406/145/997/7660/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459977660', 'front_4061459977660'),
    ('Nestlé', 'Steinofen-Pizza Thunfisch', 'https://images.openfoodfacts.org/images/products/400/923/300/3921/front_de.82.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003921', 'front_4009233003921'),
    ('Vemondo', 'Pumpkin & quinoa', 'https://images.openfoodfacts.org/images/products/405/648/945/6483/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489456483', 'front_4056489456483'),
    ('Feinkost Popp', 'Krautsalat griechischer Art', 'https://images.openfoodfacts.org/images/products/404/580/046/0216/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045800460216', 'front_4045800460216'),
    ('Bürger', 'Rindfleisch-Maultaschen', 'https://images.openfoodfacts.org/images/products/407/560/005/7118/front_de.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600057118', 'front_4075600057118'),
    ('GOOD Choice', 'Rosmarinkartoffeln // 2 kg Kart.frisch oben / 2,5 kg frisch Keller', 'https://images.openfoodfacts.org/images/products/406/145/804/9382/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458049382', 'front_4061458049382'),
    ('Steinhaus', 'Steinpilz-Champignon-Totelli', 'https://images.openfoodfacts.org/images/products/400/933/790/2106/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009337902106', 'front_4009337902106'),
    ('Omnimax Lebensmittel', 'Chili sin Carne', 'https://images.openfoodfacts.org/images/products/406/145/800/9973/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458009973', 'front_4061458009973'),
    ('Dr. Oetker', 'Ristorante Pizza Margherita Pomodori', 'https://images.openfoodfacts.org/images/products/400/172/403/9655/front_de.73.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724039655', 'front_4001724039655'),
    ('Dr. Oetker', 'Pizza Tradizionale Speciale', 'https://images.openfoodfacts.org/images/products/400/172/403/8443/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038443', 'front_4001724038443'),
    ('Speisezeit', 'Red Thai Curry', 'https://images.openfoodfacts.org/images/products/406/145/967/4446/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459674446', 'front_4061459674446'),
    ('FRoSTA', 'Tagliatelle Wildlachs', 'https://images.openfoodfacts.org/images/products/400/836/601/5498/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015498', 'front_4008366015498'),
    ('FRoSTA', 'Veganes Bami Goreng', 'https://images.openfoodfacts.org/images/products/400/836/601/7195/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366017195', 'front_4008366017195'),
    ('FRoSTA', 'Bandnudeln Pilz', 'https://images.openfoodfacts.org/images/products/400/836/601/6273/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366016273', 'front_4008366016273'),
    ('Gustavo Gusto', 'Tiefkühler Pizza groß', 'https://images.openfoodfacts.org/images/products/426/041/415/0449/front_de.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260414150449', 'front_4260414150449'),
    ('Gustavo Gusto', 'Vier Käse für ein Halleluja - Pizza Quattro Formaggi', 'https://images.openfoodfacts.org/images/products/426/041/415/0531/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260414150531', 'front_4260414150531'),
    ('Dr. Oetker', 'Ristorante Pizza Vegetale', 'https://images.openfoodfacts.org/images/products/400/172/403/9143/front_de.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724039143', 'front_4001724039143'),
    ('Bürger', 'BIO Maultaschen', 'https://images.openfoodfacts.org/images/products/407/560/015/1328/front_en.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4075600151328', 'front_4075600151328'),
    ('Maggi', 'Ravioli in Tomatensauce', 'https://images.openfoodfacts.org/images/products/400/550/033/9403/front_en.225.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500339403', 'front_4005500339403'),
    ('Feinkost Popp', 'Feiner Coleslaw-Salat', 'https://images.openfoodfacts.org/images/products/404/580/047/5197/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045800475197', 'front_4045800475197'),
    ('Gustavo Gusto', 'Gustavo Gusto Pizza Salame 4260414150470 Steinofenpizza nach italienischer Art mit Tomatensoße, laktosefreiem, schnittfestem Mozzarella und Rindersalami, teilweise vorgebacken und tiefgekühlt', 'https://images.openfoodfacts.org/images/products/426/041/415/0470/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260414150470', 'front_4260414150470'),
    ('Alnatura', 'Kartoffel Püree', 'https://images.openfoodfacts.org/images/products/410/442/001/6408/front_en.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420016408', 'front_4104420016408'),
    ('Eridanous', 'Bohnen weiß eingelegt in Tomatensoße', 'https://images.openfoodfacts.org/images/products/000/002/002/6394/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 20026394', 'front_20026394'),
    ('Dr. Oetker', 'Die Ofenfrische Thunfisch', 'https://images.openfoodfacts.org/images/products/400/172/403/6739/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724036739', 'front_4001724036739'),
    ('Speise Zeit', 'Linseneintopf', 'https://images.openfoodfacts.org/images/products/406/146/197/6842/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461976842', 'front_4061461976842'),
    ('REWE to go', 'Hähnchen Salat', 'https://images.openfoodfacts.org/images/products/433/725/676/3196/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256763196', 'front_4337256763196'),
    ('Iglo', '8 Lachs-Stäbchen', 'https://images.openfoodfacts.org/images/products/425/024/120/4958/front_en.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241204958', 'front_4250241204958'),
    ('Ocean Sea', 'Fischstäbchen', 'https://images.openfoodfacts.org/images/products/000/002/015/5087/front_de.174.400.jpg', 'off_api', 'front', true, 'Front — EAN 20155087', 'front_20155087'),
    ('Frosta', 'Mexican Style Chicken', 'https://images.openfoodfacts.org/images/products/400/836/600/3334/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366003334', 'front_4008366003334'),
    ('Original Wagner', 'Rustipani dunkles Ofenbrot geräucherter Käse', 'https://images.openfoodfacts.org/images/products/761/303/485/4896/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613034854896', 'front_7613034854896')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Ready Meals' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

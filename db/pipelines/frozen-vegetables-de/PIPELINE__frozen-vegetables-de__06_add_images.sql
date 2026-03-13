-- PIPELINE (Frozen Vegetables): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Frozen Vegetables'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('FRoSTA', 'Gemüse Pfanne alla Toscana', 'https://images.openfoodfacts.org/images/products/400/836/600/6915/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366006915', 'front_4008366006915'),
    ('Freshona', 'Bio Gemüse Pfanne Französische Art', 'https://images.openfoodfacts.org/images/products/405/648/928/9265/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489289265', 'front_4056489289265'),
    ('All Seasons', 'China Gemüse', 'https://images.openfoodfacts.org/images/products/406/146/382/6985/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463826985', 'front_4061463826985'),
    ('Freshona', 'Gemüsepfanne Asiatische Art', 'https://images.openfoodfacts.org/images/products/405/648/944/7801/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489447801', 'front_4056489447801'),
    ('Bio', 'Gemüsepfanne französische Art', 'https://images.openfoodfacts.org/images/products/406/146/382/9771/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463829771', 'front_4061463829771'),
    ('All Seasons', 'Pfannengemüse - Asiatische Art', 'https://images.openfoodfacts.org/images/products/406/145/803/2513/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032513', 'front_4061458032513'),
    ('Gut Bio', 'Bio-Gemüsepfanne - Französische Art', 'https://images.openfoodfacts.org/images/products/406/145/801/1402/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011402', 'front_4061458011402'),
    ('Frosta', 'Gemüse-Bowl - Oriental Style', 'https://images.openfoodfacts.org/images/products/400/836/688/3387/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883387', 'front_4008366883387'),
    ('Freshona', 'Kaisergemüse', 'https://images.openfoodfacts.org/images/products/405/648/912/3262/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123262', 'front_4056489123262'),
    ('K-Bio', 'Pfannengemüse Asiatische Art', 'https://images.openfoodfacts.org/images/products/406/336/711/3116/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367113116', 'front_4063367113116'),
    ('Vitasia', 'Wok Gemüse Thai', 'https://images.openfoodfacts.org/images/products/405/648/949/9237/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489499237', 'front_4056489499237'),
    ('All Seasons', 'Pfannengemüse - Italienische Art', 'https://images.openfoodfacts.org/images/products/406/145/803/2568/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032568', 'front_4061458032568'),
    ('Aldi', 'Pfannengemüse - Feinschmecker Art', 'https://images.openfoodfacts.org/images/products/406/145/803/2544/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032544', 'front_4061458032544'),
    ('All Seasons', 'Buttergemüse XXL', 'https://images.openfoodfacts.org/images/products/406/145/982/0898/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459820898', 'front_4061459820898'),
    ('Vitasia', 'Wok gemüse', 'https://images.openfoodfacts.org/images/products/405/648/949/9244/front_it.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489499244', 'front_4056489499244'),
    ('FRoSTA', 'Gemüse Mix Thai', 'https://images.openfoodfacts.org/images/products/400/836/601/2879/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366012879', 'front_4008366012879'),
    ('Aldi', 'Pfannengemüse Kalifornische Art', 'https://images.openfoodfacts.org/images/products/406/145/803/2537/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032537', 'front_4061458032537'),
    ('Freshona', 'Kaisergemüse erntefrisch tiefgefroren', 'https://images.openfoodfacts.org/images/products/405/648/912/3279/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123279', 'front_4056489123279'),
    ('Freshona', 'Gemüsepfanne Sommergarten', 'https://images.openfoodfacts.org/images/products/405/648/923/0991/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489230991', 'front_4056489230991'),
    ('FRoSTA', 'Suppengrün', 'https://images.openfoodfacts.org/images/products/400/836/601/4712/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366014712', 'front_4008366014712'),
    ('Frosta', 'Gemüse Mix Asiatische Küche', 'https://images.openfoodfacts.org/images/products/400/836/600/9435/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009435', 'front_4008366009435'),
    ('Frosta', 'Pasta mit Gemüse mediterraner Art', 'https://images.openfoodfacts.org/images/products/400/836/601/3449/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366013449', 'front_4008366013449'),
    ('Aldi', 'Gemüsepfanne', 'https://images.openfoodfacts.org/images/products/406/145/801/1389/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011389', 'front_4061458011389'),
    ('Aldi Süd', 'Bio-Gemüsepfanne - Mediterrane Art', 'https://images.openfoodfacts.org/images/products/406/145/801/1426/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011426', 'front_4061458011426'),
    ('K Classic', 'Pfanngemüse Asiatiache Art', 'https://images.openfoodfacts.org/images/products/406/336/711/2997/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367112997', 'front_4063367112997'),
    ('Freshona', 'Bio-Gemüsepfanne Asiatische Art', 'https://images.openfoodfacts.org/images/products/405/648/900/7463/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489007463', 'front_4056489007463'),
    ('All Seasons', 'Bunte Gemüsemischung, tiefgefroren', 'https://images.openfoodfacts.org/images/products/406/145/802/4730/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024730', 'front_4061458024730'),
    ('Kaufland', 'Pfanngemüse', 'https://images.openfoodfacts.org/images/products/406/336/711/3031/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367113031', 'front_4063367113031'),
    ('Gartenkrone', 'Kaisergemüse', 'https://images.openfoodfacts.org/images/products/406/145/804/0372/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458040372', 'front_4061458040372'),
    ('K-Classic', 'Pfannengemüse Italienische Art', 'https://images.openfoodfacts.org/images/products/406/336/711/3055/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367113055', 'front_4063367113055'),
    ('All seasons', 'Bunte Gemüsemischung', 'https://images.openfoodfacts.org/images/products/406/146/163/4360/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461634360', 'front_4061461634360'),
    ('All Seasons', 'Gemüse Rahm-Kaisergemüse', 'https://images.openfoodfacts.org/images/products/406/145/814/5671/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458145671', 'front_4061458145671'),
    ('K-Classic', 'Gemüse Rustikale Art', 'https://images.openfoodfacts.org/images/products/406/336/711/3093/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367113093', 'front_4063367113093'),
    ('Gut Bio', 'Bio-Kaisergemüse', 'https://images.openfoodfacts.org/images/products/406/145/801/1273/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011273', 'front_4061458011273'),
    ('Genuss pur', 'Pfannengemüse Italienische Art', 'https://images.openfoodfacts.org/images/products/402/701/648/0950/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4027016480950', 'front_4027016480950'),
    ('Frosta', 'Frosta Gemüse Pfanne Curry Kokos', 'https://images.openfoodfacts.org/images/products/400/836/600/7196/front_en.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366007196', 'front_4008366007196'),
    ('Frosta', 'Gemüsepfanne a la Provence', 'https://images.openfoodfacts.org/images/products/400/836/600/6953/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366006953', 'front_4008366006953'),
    ('FRoSTA', 'Gemüse Pfanne Style Asia Curry', 'https://images.openfoodfacts.org/images/products/400/836/600/9336/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009336', 'front_4008366009336'),
    ('Freshona', 'Gemüsepfanne Bio Mediterrane Art', 'https://images.openfoodfacts.org/images/products/405/648/928/9241/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489289241', 'front_4056489289241'),
    ('EDEKA FRoSTA', 'Frosta Gemüsemix Asiatische Küche', 'https://images.openfoodfacts.org/images/products/400/836/600/2559/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366002559', 'front_4008366002559'),
    ('FRoSTA', 'Gemüsepfanne Wok Mix', 'https://images.openfoodfacts.org/images/products/400/836/601/6396/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366016396', 'front_4008366016396'),
    ('All Seasons', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/406/146/288/0957/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462880957', 'front_4061462880957'),
    ('FRoSTA', 'Gemüse Mix italienische Küche', 'https://images.openfoodfacts.org/images/products/400/836/600/9473/front_de.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009473', 'front_4008366009473'),
    ('FRoSTA', 'Gemüsepfanne Sommergarten', 'https://images.openfoodfacts.org/images/products/400/836/600/7011/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366007011', 'front_4008366007011'),
    ('Fertiggerichte', 'Gemüsepfanne al Italiana', 'https://images.openfoodfacts.org/images/products/400/836/600/9886/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009886', 'front_4008366009886'),
    ('Frosta', 'Gemüse-Bowl - Asian Style', 'https://images.openfoodfacts.org/images/products/400/836/688/3363/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883363', 'front_4008366883363'),
    ('Frosta', 'Frosta Lieblingsgemüsemix ungewürzt', 'https://images.openfoodfacts.org/images/products/400/836/601/7355/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366017355', 'front_4008366017355'),
    ('Bio', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/406/146/283/7173/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462837173', 'front_4061462837173'),
    ('Aldi', 'Kaisergemüse', 'https://images.openfoodfacts.org/images/products/406/146/163/4308/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461634308', 'front_4061461634308'),
    ('Bio', 'Gemüsepfanne mediterrane Art', 'https://images.openfoodfacts.org/images/products/406/146/382/8866/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463828866', 'front_4061463828866'),
    ('Aldi', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/406/145/803/1806/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458031806', 'front_4061458031806'),
    ('Gut bio', 'Bio-Buttergemüse', 'https://images.openfoodfacts.org/images/products/406/145/810/4227/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458104227', 'front_4061458104227'),
    ('Aldi', 'TK Gemüse - Brokkoli', 'https://images.openfoodfacts.org/images/products/406/146/163/4742/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461634742', 'front_4061461634742'),
    ('Kaufland', 'Kaisergemüse', 'https://images.openfoodfacts.org/images/products/406/336/711/0788/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367110788', 'front_4063367110788'),
    ('Frosta', 'Gemüse Pfanne mit Falafeln & bunten Karotten', 'https://images.openfoodfacts.org/images/products/400/836/601/5153/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015153', 'front_4008366015153'),
    ('Aldi', 'Pfannengemüse - Rustikale Art', 'https://images.openfoodfacts.org/images/products/406/145/803/2520/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032520', 'front_4061458032520'),
    ('FRoSTA', 'Gemüsepfanne mit gegrillter Zuchini & Kichererbsen', 'https://images.openfoodfacts.org/images/products/400/836/601/5214/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015214', 'front_4008366015214'),
    ('Frosta', 'Gemüsepfanne mit Kichererbsen & Cranberries', 'https://images.openfoodfacts.org/images/products/400/836/601/3241/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366013241', 'front_4008366013241'),
    ('Aldi', 'Bio-Suppengemüse', 'https://images.openfoodfacts.org/images/products/406/145/801/1327/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011327', 'front_4061458011327'),
    ('Culinea', 'Kürbis Quinoa Bowl', 'https://images.openfoodfacts.org/images/products/405/648/958/2731/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489582731', 'front_4056489582731'),
    ('Frenzel', 'Gemüse auf Reis', 'https://images.openfoodfacts.org/images/products/401/707/941/1251/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4017079411251', 'front_4017079411251'),
    ('FRoSTA', 'Gemüsepfanne Thai', 'https://images.openfoodfacts.org/images/products/400/836/600/6939/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366006939', 'front_4008366006939'),
    ('All Seasons', 'Gemüse Blumenkohl-Röschen', 'https://images.openfoodfacts.org/images/products/406/145/802/4778/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024778', 'front_4061458024778'),
    ('Greenyard Frozen Langemark', 'Buckwheat & broccoli', 'https://images.openfoodfacts.org/images/products/405/648/945/6476/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489456476', 'front_4056489456476'),
    ('All Seasons', 'Rahm-Spinat', 'https://images.openfoodfacts.org/images/products/406/145/801/1228/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011228', 'front_4061458011228'),
    ('Freshona', 'Melange de légumes à l asiatique', 'https://images.openfoodfacts.org/images/products/405/648/928/9258/front_fr.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489289258', 'front_4056489289258'),
    ('Freshona', 'Erbsen', 'https://images.openfoodfacts.org/images/products/405/648/912/3422/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123422', 'front_4056489123422'),
    ('Freshona', 'Sommer Gemüse', 'https://images.openfoodfacts.org/images/products/405/648/912/3828/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123828', 'front_4056489123828'),
    ('K Classic', 'Rosmarinkartoffeln', 'https://images.openfoodfacts.org/images/products/406/336/738/9894/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367389894', 'front_4063367389894'),
    ('Freshona', 'Vegetable with fine butter herb sauce', 'https://images.openfoodfacts.org/images/products/405/648/912/2876/front_en.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489122876', 'front_4056489122876'),
    ('Freshona', 'TK - Erbsen', 'https://images.openfoodfacts.org/images/products/405/648/912/3439/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123439', 'front_4056489123439'),
    ('Frosta', 'Gemüsepfanne Mexicana', 'https://images.openfoodfacts.org/images/products/400/836/600/3303/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366003303', 'front_4008366003303'),
    ('Aldi', 'Brokkoli', 'https://images.openfoodfacts.org/images/products/406/145/801/1365/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011365', 'front_4061458011365'),
    ('Lidl', 'Sojabohnen', 'https://images.openfoodfacts.org/images/products/405/648/912/3644/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123644', 'front_4056489123644'),
    ('Aldi', 'Junge Erbsen', 'https://images.openfoodfacts.org/images/products/406/145/801/1297/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011297', 'front_4061458011297'),
    ('REWE Bio', 'Gemüsepfanne nach französischer Art', 'https://images.openfoodfacts.org/images/products/433/725/684/6813/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256846813', 'front_4337256846813'),
    ('REWE Beste Wahl', 'Gemüsepfanne Italienische Art', 'https://images.openfoodfacts.org/images/products/433/725/666/5247/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256665247', 'front_4337256665247'),
    ('Edeka', 'Asia Style Gemüsepfanne', 'https://images.openfoodfacts.org/images/products/431/150/173/9280/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501739280', 'front_4311501739280'),
    ('Iglo', 'Gemüse-Ideen Italienisch', 'https://images.openfoodfacts.org/images/products/425/024/120/1353/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241201353', 'front_4250241201353'),
    ('Genuss Welt', 'Pfannen Gemüse Mexikanische Art', 'https://images.openfoodfacts.org/images/products/431/626/865/9116/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268659116', 'front_4316268659116'),
    ('Freshona', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/000/002/004/6958/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 20046958', 'front_20046958'),
    ('Edeka', 'TK-Eigen EDEKA GEMÜSE Junger Spinat 450g 1.49€ 1kg 3.32€', 'https://images.openfoodfacts.org/images/products/431/150/142/8184/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501428184', 'front_4311501428184'),
    ('Iglo', 'Veggie Love - Gemüse Curry', 'https://images.openfoodfacts.org/images/products/425/024/120/8796/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241208796', 'front_4250241208796'),
    ('Edeka', 'Pfannengemüse Italienische Art', 'https://images.openfoodfacts.org/images/products/431/150/173/9341/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501739341', 'front_4311501739341'),
    ('REWE Bio', 'TK Buttergemüse', 'https://images.openfoodfacts.org/images/products/433/725/614/9310/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256149310', 'front_4337256149310'),
    ('BioBio', 'Pfannengemüse mediterrane Art', 'https://images.openfoodfacts.org/images/products/431/626/864/3221/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268643221', 'front_4316268643221'),
    ('REWE Beste Wahl', 'Wok Mix ungewürzt', 'https://images.openfoodfacts.org/images/products/433/725/669/3585/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256693585', 'front_4337256693585'),
    ('Gut & Günstig', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/431/150/149/8804/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501498804', 'front_4311501498804'),
    ('Edeka Bio', 'Bio Buttergemüse', 'https://images.openfoodfacts.org/images/products/431/150/173/3516/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501733516', 'front_4311501733516'),
    ('Edeka', 'Butter Gemüse', 'https://images.openfoodfacts.org/images/products/431/150/149/8446/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501498446', 'front_4311501498446'),
    ('REWE Bio', 'Kaisergemüse', 'https://images.openfoodfacts.org/images/products/433/725/619/3016/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256193016', 'front_4337256193016'),
    ('BioBio', 'Pfannengemüse Französische Art', 'https://images.openfoodfacts.org/images/products/431/626/864/3214/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268643214', 'front_4316268643214'),
    ('Freshona', 'Mixed vegetable italian style', 'https://images.openfoodfacts.org/images/products/405/648/944/7856/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489447856', 'front_4056489447856'),
    ('REWE Beste Wahl', 'Gemüsepfanne Asiatische Art in einer Sauce mit Kokosmilch 4388860395167', 'https://images.openfoodfacts.org/images/products/438/886/039/5167/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4388860395167', 'front_4388860395167'),
    ('Iglo', 'Iglo Brokkoli Buchweizen 4250241207768 Gemüsemischung mit schwarzen Bohnen, Buchweizen und schwarzem Reis', 'https://images.openfoodfacts.org/images/products/425/024/120/7768/front_de.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241207768', 'front_4250241207768'),
    ('Freshona', '1 Beutel Gemüsepfanne Asiatische Art', 'https://images.openfoodfacts.org/images/products/000/002/006/8189/front_en.125.400.jpg', 'off_api', 'front', true, 'Front — EAN 20068189', 'front_20068189'),
    ('Iglo', 'Rahm-Gemüse Blumenkohl', 'https://images.openfoodfacts.org/images/products/425/024/120/1193/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4250241201193', 'front_4250241201193'),
    ('Beste Ernte', 'Gemüse', 'https://images.openfoodfacts.org/images/products/431/626/852/7965/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268527965', 'front_4316268527965'),
    ('K Classic', 'Buttergemüse', 'https://images.openfoodfacts.org/images/products/433/718/557/1541/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337185571541', 'front_4337185571541'),
    ('Freshona', 'Festtagsgemüse', 'https://images.openfoodfacts.org/images/products/000/002/048/6099/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 20486099', 'front_20486099')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Frozen Vegetables' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

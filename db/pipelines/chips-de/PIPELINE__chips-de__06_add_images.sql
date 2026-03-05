-- PIPELINE (Chips): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Chips'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Funny Frisch', 'Pom-Bär Ketchup Style', 'https://images.openfoodfacts.org/images/products/400/052/210/5227/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000522105227', 'front_4000522105227'),
    ('Lay''s', 'Aus dem Ofen Geröstete Paprika', 'https://images.openfoodfacts.org/images/products/406/213/900/5536/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005536', 'front_4062139005536'),
    ('Bio-Zentrale', 'Gemüsechips – Pastinake, Rote Beete, Süßkartoffel, lila Süßkartoffel, Meersalz', 'https://images.openfoodfacts.org/images/products/400/500/910/1730/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005009101730', 'front_4005009101730'),
    ('Lorenz', 'Naturals Mediterranes Gemüse', 'https://images.openfoodfacts.org/images/products/401/807/781/2750/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077812750', 'front_4018077812750'),
    ('K-Classic', 'Knuspermäuse Salz', 'https://images.openfoodfacts.org/images/products/406/336/714/9092/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367149092', 'front_4063367149092'),
    ('Pom-Bär', 'Pom-Bär Crizzlies - Paprika-Style', 'https://images.openfoodfacts.org/images/products/400/052/210/8426/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000522108426', 'front_4000522108426'),
    ('DmBio', 'Gemüsechips mit Meersalz', 'https://images.openfoodfacts.org/images/products/406/644/788/4906/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447884906', 'front_4066447884906'),
    ('Lay''s', 'Kräuterbutterchips', 'https://images.openfoodfacts.org/images/products/406/213/900/5963/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005963', 'front_4062139005963'),
    ('Fanny frisch', 'Pombär Sour Cream', 'https://images.openfoodfacts.org/images/products/400/052/210/5234/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000522105234', 'front_4000522105234'),
    ('DmBio', 'Gemüse Chips mit Meersalz', 'https://images.openfoodfacts.org/images/products/406/779/608/3460/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796083460', 'front_4067796083460'),
    ('Snack Food Poco Loco', 'Tortilla-Chips - Käse', 'https://images.openfoodfacts.org/images/products/406/145/805/8544/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458058544', 'front_4061458058544'),
    ('Pom-Bär', 'Pom-Bär Crizzlies - Original', 'https://images.openfoodfacts.org/images/products/400/052/210/8433/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000522108433', 'front_4000522108433'),
    ('Lorenz', 'Crunchips Paprika', 'https://images.openfoodfacts.org/images/products/401/807/700/4377/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004377', 'front_4018077004377'),
    ('Funny-frisch', 'Chipsfrisch Oriental', 'https://images.openfoodfacts.org/images/products/400/358/610/0399/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586100399', 'front_4003586100399'),
    ('Funny-frisch', 'Chipsfrisch Sour Cream', 'https://images.openfoodfacts.org/images/products/400/358/610/1723/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586101723', 'front_4003586101723'),
    ('Funny Frisch', 'Chipsfrisch ungarisch', 'https://images.openfoodfacts.org/images/products/400/358/610/1310/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586101310', 'front_4003586101310'),
    ('Funny-frisch', 'Ofenchips paprika', 'https://images.openfoodfacts.org/images/products/400/358/610/2072/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586102072', 'front_4003586102072'),
    ('Lay''s', 'Lays Salted Chips', 'https://images.openfoodfacts.org/images/products/406/213/900/5864/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005864', 'front_4062139005864'),
    ('Funny-frisch', 'Linsen Chips Sour Creme Style', 'https://images.openfoodfacts.org/images/products/400/358/610/4038/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586104038', 'front_4003586104038'),
    ('Lay''s', 'Sour Cream & Onion', 'https://images.openfoodfacts.org/images/products/406/213/900/5888/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005888', 'front_4062139005888'),
    ('Lorenz', 'Naturals - Rosmarin', 'https://images.openfoodfacts.org/images/products/401/807/771/4016/front_en.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077714016', 'front_4018077714016'),
    ('Chio', 'Tortillas Nacho Cheese', 'https://images.openfoodfacts.org/images/products/400/124/210/5917/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242105917', 'front_4001242105917'),
    ('Lorenz', 'Crunchips Western Style', 'https://images.openfoodfacts.org/images/products/401/807/700/4117/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004117', 'front_4018077004117'),
    ('Chio', 'Tortillas - Wild Paprika', 'https://images.openfoodfacts.org/images/products/400/124/210/5931/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242105931', 'front_4001242105931'),
    ('Lay''s', 'Chips "Subway Terriyaki"', 'https://images.openfoodfacts.org/images/products/406/213/900/3136/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139003136', 'front_4062139003136'),
    ('Funny-frisch', 'Salziges, Riffels Naturell', 'https://images.openfoodfacts.org/images/products/400/358/600/0347/front_en.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586000347', 'front_4003586000347'),
    ('LORENZ Crunchips', 'Crunchips Salted Gesalzene Kartoffel-Chips', 'https://images.openfoodfacts.org/images/products/401/807/700/4285/front_de.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004285', 'front_4018077004285'),
    ('Lorenz', 'Erdnusslocken Jumbos', 'https://images.openfoodfacts.org/images/products/401/807/700/6258/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077006258', 'front_4018077006258'),
    ('Funny-frisch', 'Chipsfrisch Chili Cheese Fries Style', 'https://images.openfoodfacts.org/images/products/400/358/610/7350/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586107350', 'front_4003586107350'),
    ('Chio', 'Tortillas Salted', 'https://images.openfoodfacts.org/images/products/400/124/210/5924/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242105924', 'front_4001242105924'),
    ('Doritos', 'Sweet-Chili-Peppergeschmack', 'https://images.openfoodfacts.org/images/products/406/213/900/6052/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139006052', 'front_4062139006052'),
    ('Aldi', 'Tortilla-Chips - Paprika', 'https://images.openfoodfacts.org/images/products/406/145/915/8236/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459158236', 'front_4061459158236'),
    ('Funny-frisch', 'Frit-Sticks ungarisch', 'https://images.openfoodfacts.org/images/products/400/358/610/5196/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586105196', 'front_4003586105196'),
    ('Lorenz', 'Naturals Chips "fein gesalzen"', 'https://images.openfoodfacts.org/images/products/401/807/771/4351/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077714351', 'front_4018077714351'),
    ('Funny-frisch', 'Linsenchips Oriental', 'https://images.openfoodfacts.org/images/products/400/358/610/4137/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586104137', 'front_4003586104137'),
    ('Chio', 'Tortillas Hot Chili', 'https://images.openfoodfacts.org/images/products/400/124/210/5900/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242105900', 'front_4001242105900'),
    ('Lorenz', 'Naturals - Meersalz und Pfeffer', 'https://images.openfoodfacts.org/images/products/401/807/771/4313/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077714313', 'front_4018077714313'),
    ('Funny-frisch', 'Kessel Chips sweet chili', 'https://images.openfoodfacts.org/images/products/400/358/600/2914/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586002914', 'front_4003586002914'),
    ('Sun Snacks', 'Erdnussflips Classic', 'https://images.openfoodfacts.org/images/products/406/145/805/9015/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458059015', 'front_4061458059015'),
    ('Lorenz', 'Crunchips Cheese & Onion 150g', 'https://images.openfoodfacts.org/images/products/401/807/700/4469/front_en.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004469', 'front_4018077004469'),
    ('DmBio', 'Tortilla Chips', 'https://images.openfoodfacts.org/images/products/406/644/722/5662/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447225662', 'front_4066447225662'),
    ('Snack Day', 'Chips Paprika', 'https://images.openfoodfacts.org/images/products/405/648/923/6559/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489236559', 'front_4056489236559'),
    ('Aldi', 'Chips SALZ', 'https://images.openfoodfacts.org/images/products/406/145/802/4631/front_de.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024631', 'front_4061458024631'),
    ('Sun Snacks', 'Light-Chips - Classic', 'https://images.openfoodfacts.org/images/products/406/145/806/1445/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458061445', 'front_4061458061445'),
    ('Snäcky Knabbergebäck', 'Light-Chips - Paprika-Style', 'https://images.openfoodfacts.org/images/products/406/145/806/1452/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458061452', 'front_4061458061452'),
    ('Lorenz', 'Crunchips Hot Paprika', 'https://images.openfoodfacts.org/images/products/401/807/700/4193/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004193', 'front_4018077004193'),
    ('Sun Snacks', 'Kessel-Chips Sweet-Chili-Geschmack', 'https://images.openfoodfacts.org/images/products/406/145/805/8995/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458058995', 'front_4061458058995'),
    ('Lorenz', 'Pommels Original', 'https://images.openfoodfacts.org/images/products/401/807/761/9458/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077619458', 'front_4018077619458'),
    ('Funny-frisch', 'Linsen Chips Sweet Chili', 'https://images.openfoodfacts.org/images/products/400/358/610/4007/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586104007', 'front_4003586104007'),
    ('Doritos', 'Nacho Cheese', 'https://images.openfoodfacts.org/images/products/406/213/902/6159/front_en.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139026159', 'front_4062139026159'),
    ('Aldi', 'Linsen-Chips - Paprika-Style', 'https://images.openfoodfacts.org/images/products/404/724/703/7235/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247037235', 'front_4047247037235'),
    ('Aldi', 'Linsen-Chips - Sour Cream Style', 'https://images.openfoodfacts.org/images/products/404/724/703/7242/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247037242', 'front_4047247037242'),
    ('Funny-frisch', 'Zwiebli-Ringe', 'https://images.openfoodfacts.org/images/products/400/358/600/6042/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586006042', 'front_4003586006042'),
    ('K-Classic', 'Kartoffelchips Paprika', 'https://images.openfoodfacts.org/images/products/401/474/061/1125/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014740611125', 'front_4014740611125'),
    ('Bio zentrale', 'Tortilla Chips Mais & Paprika', 'https://images.openfoodfacts.org/images/products/400/500/910/0566/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005009100566', 'front_4005009100566'),
    ('Funny-frisch', 'Chipsfrisch Zaziki Style', 'https://images.openfoodfacts.org/images/products/400/358/610/8630/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586108630', 'front_4003586108630'),
    ('Aldi', 'Stapelchips - Original', 'https://images.openfoodfacts.org/images/products/406/145/806/1551/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458061551', 'front_4061458061551'),
    ('Asia Green Garden', 'Krabbenchips - Classic', 'https://images.openfoodfacts.org/images/products/406/145/810/4012/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458104012', 'front_4061458104012'),
    ('Sun Snacks', 'Kartoffelringe Paprikageschmack', 'https://images.openfoodfacts.org/images/products/406/145/823/9981/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458239981', 'front_4061458239981'),
    ('Lidl', 'Salz Chips', 'https://images.openfoodfacts.org/images/products/405/648/909/6092/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489096092', 'front_4056489096092'),
    ('Snack Day', 'Sour Cream & Onion Flavour', 'https://images.openfoodfacts.org/images/products/405/648/923/8799/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489238799', 'front_4056489238799'),
    ('Ültje', 'Linsen Crackets Paprika', 'https://images.openfoodfacts.org/images/products/400/498/088/5004/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980885004', 'front_4004980885004'),
    ('Snack Day', 'Snack Day Paprika Stapelchips', 'https://images.openfoodfacts.org/images/products/405/648/923/8775/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489238775', 'front_4056489238775'),
    ('Chio', 'Tortillias Nacho Cheese', 'https://images.openfoodfacts.org/images/products/400/124/210/5955/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242105955', 'front_4001242105955'),
    ('K-Classic', 'Geriffelte Paprika Chips', 'https://images.openfoodfacts.org/images/products/401/474/061/1132/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014740611132', 'front_4014740611132'),
    ('Ültje', 'Fusion - Peanuts Paprika Flamed Style', 'https://images.openfoodfacts.org/images/products/400/498/040/9507/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980409507', 'front_4004980409507'),
    ('Halloween', 'Gespenster - Ketchupgeschmack', 'https://images.openfoodfacts.org/images/products/406/145/803/6306/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458036306', 'front_4061458036306'),
    ('Sun Snacks', 'Chips Paprika Style', 'https://images.openfoodfacts.org/images/products/406/146/101/0355/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461010355', 'front_4061461010355'),
    ('Funny Frisch', 'Ofen Chips Sour Cream', 'https://images.openfoodfacts.org/images/products/400/358/610/2089/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586102089', 'front_4003586102089'),
    ('Chio', 'Red Paprika Chips', 'https://images.openfoodfacts.org/images/products/400/124/210/8536/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242108536', 'front_4001242108536'),
    ('Doritos', 'Doritos Nacho Cheese', 'https://images.openfoodfacts.org/images/products/406/213/900/6038/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139006038', 'front_4062139006038'),
    ('Snack Food Poco Loco', 'ALDI SUN SNACKS Tortilla Chips Salz 300g 1.59€ 1kg 5.30€', 'https://images.openfoodfacts.org/images/products/406/145/805/8537/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458058537', 'front_4061458058537'),
    ('Clancy''s', 'Nacho Cheese Tortilla Chips', 'https://images.openfoodfacts.org/images/products/406/146/483/8192/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464838192', 'front_4061464838192'),
    ('Sun Snacks', 'Sun Snacks Party Snack Paprika', 'https://images.openfoodfacts.org/images/products/406/826/208/3588/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068262083588', 'front_4068262083588'),
    ('Funny-frisch', 'Linsen Chips Paprika Style', 'https://images.openfoodfacts.org/images/products/400/358/610/4120/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586104120', 'front_4003586104120'),
    ('Lay''s', 'Chips Red Paprika Lays', 'https://images.openfoodfacts.org/images/products/406/213/900/7677/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139007677', 'front_4062139007677'),
    ('Funny Frisch', 'Chipsfrisch XXL Ungarisch', 'https://images.openfoodfacts.org/images/products/400/358/610/1358/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586101358', 'front_4003586101358'),
    ('Rewe', 'Kartoffel Chips mit Trüffel Geschmack', 'https://images.openfoodfacts.org/images/products/433/725/654/3675/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256543675', 'front_4337256543675'),
    ('Lay''s', 'Salt & Vinegar', 'https://images.openfoodfacts.org/images/products/406/213/900/5949/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005949', 'front_4062139005949'),
    ('Funny-frisch', 'Chipsfrisch Peperoni', 'https://images.openfoodfacts.org/images/products/400/358/610/0306/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586100306', 'front_4003586100306'),
    ('Doritos', 'Doritos - Whopper-Geschmack', 'https://images.openfoodfacts.org/images/products/406/213/902/6760/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139026760', 'front_4062139026760'),
    ('Funnyfrisch', 'Ofen Chips Smoky BBQ Style', 'https://images.openfoodfacts.org/images/products/400/358/610/2317/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586102317', 'front_4003586102317'),
    ('Lay''s', 'Chili und Lime Chips', 'https://images.openfoodfacts.org/images/products/406/213/902/6333/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139026333', 'front_4062139026333'),
    ('Funny-frisch', 'Chipsfrisch Chakalaka', 'https://images.openfoodfacts.org/images/products/400/358/610/1082/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586101082', 'front_4003586101082'),
    ('Doritos', 'Doritos Paprikageschmack', 'https://images.openfoodfacts.org/images/products/406/213/900/5826/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139005826', 'front_4062139005826'),
    ('Lorenz', 'Snack-Hits', 'https://images.openfoodfacts.org/images/products/401/807/701/0316/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077010316', 'front_4018077010316'),
    ('Funny Frisch', 'Jumpys', 'https://images.openfoodfacts.org/images/products/400/358/610/2676/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586102676', 'front_4003586102676'),
    ('Funny-frisch', 'Popchips Potato - Red Paprika', 'https://images.openfoodfacts.org/images/products/400/358/610/5165/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586105165', 'front_4003586105165'),
    ('Lorenz', 'Rohscheiben mit Steinsalz', 'https://images.openfoodfacts.org/images/products/401/807/768/0588/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077680588', 'front_4018077680588'),
    ('Lay''s', 'Iconic Restauraunt Flavours', 'https://images.openfoodfacts.org/images/products/406/213/900/3150/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139003150', 'front_4062139003150'),
    ('Lorenz', 'CrunChips Sour Cream', 'https://images.openfoodfacts.org/images/products/401/807/700/6883/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077006883', 'front_4018077006883'),
    ('Lorenz', 'Naturals Balsamico', 'https://images.openfoodfacts.org/images/products/401/807/771/4054/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077714054', 'front_4018077714054'),
    ('EDEKA funnyfrisch', 'EDEKA funnyfrisch Chipsfrisch Salt & Vinegar Style 150g 0.99€ 1kg 6.60€', 'https://images.openfoodfacts.org/images/products/400/358/610/8456/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003586108456', 'front_4003586108456'),
    ('Lay''s', 'Pizza Hut Chips Margherita', 'https://images.openfoodfacts.org/images/products/406/213/900/6762/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139006762', 'front_4062139006762')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Chips' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

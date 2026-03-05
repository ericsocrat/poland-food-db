-- PIPELINE (Chips): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Chips'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000522105227', '4062139005536', '4005009101730', '4018077812750', '4063367149092', '4000522108426', '4066447884906', '4062139005963', '4000522105234', '4067796083460', '4061458058544', '4000522108433', '4018077004377', '4003586100399', '4003586101723', '4003586101310', '4003586102072', '4062139005864', '4003586104038', '4062139005888', '4018077714016', '4001242105917', '4018077004117', '4001242105931', '4062139003136', '4003586000347', '4018077004285', '4018077006258', '4003586107350', '4001242105924', '4062139006052', '4061459158236', '4003586105196', '4018077714351', '4003586104137', '4001242105900', '4018077714313', '4003586002914', '4061458059015', '4018077004469', '4066447225662', '4056489236559', '4061458024631', '4061458061445', '4061458061452', '4018077004193', '4061458058995', '4018077619458', '4003586104007', '4062139026159', '4047247037235', '4047247037242', '4003586006042', '4014740611125', '4005009100566', '4003586108630', '4061458061551', '4061458104012', '4061458239981', '4056489096092', '4056489238799', '4004980885004', '4047247544696', '4056489238775', '4001242105955', '4014740611132', '4004980409507', '4061458036306', '4061461010355', '4003586102089', '4001242108536', '4062139006038', '4061458058537', '4061464838192', '4068262083588', '4003586104120', '4062139007677', '4003586101358', '4337256543675', '4062139005949', '4003586100306', '4062139026760', '4003586102317', '4062139026333', '4003586101082', '4062139005826', '4018077010316', '4003586102676', '4003586105165', '4018077680588', '4062139003150', '4018077006883', '4018077714054', '4003586108456', '4062139006762')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Funny Frisch', 'Grocery', 'Chips', 'Pom-Bär Ketchup Style', 'not-applicable', 'Netto', 'none', '4000522105227'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Aus dem Ofen Geröstete Paprika', 'not-applicable', null, 'none', '4062139005536'),
  ('DE', 'Bio-Zentrale', 'Grocery', 'Chips', 'Gemüsechips – Pastinake, Rote Beete, Süßkartoffel, lila Süßkartoffel, Meersalz', 'not-applicable', null, 'none', '4005009101730'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Naturals Mediterranes Gemüse', 'not-applicable', null, 'none', '4018077812750'),
  ('DE', 'K-Classic', 'Grocery', 'Chips', 'Knuspermäuse Salz', 'not-applicable', 'Kaufland', 'none', '4063367149092'),
  ('DE', 'Pom-Bär', 'Grocery', 'Chips', 'Pom-Bär Crizzlies - Paprika-Style', 'not-applicable', 'Aldi', 'none', '4000522108426'),
  ('DE', 'DmBio', 'Grocery', 'Chips', 'Gemüsechips mit Meersalz', 'not-applicable', null, 'none', '4066447884906'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Kräuterbutterchips', 'not-applicable', null, 'none', '4062139005963'),
  ('DE', 'Fanny frisch', 'Grocery', 'Chips', 'Pombär Sour Cream', 'not-applicable', null, 'none', '4000522105234'),
  ('DE', 'DmBio', 'Grocery', 'Chips', 'Gemüse Chips mit Meersalz', 'fried', null, 'none', '4067796083460'),
  ('DE', 'Snack Food Poco Loco', 'Grocery', 'Chips', 'Tortilla-Chips - Käse', 'not-applicable', null, 'none', '4061458058544'),
  ('DE', 'Pom-Bär', 'Grocery', 'Chips', 'Pom-Bär Crizzlies - Original', 'not-applicable', null, 'none', '4000522108433'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Paprika', 'not-applicable', null, 'none', '4018077004377'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Oriental', 'not-applicable', null, 'none', '4003586100399'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Sour Cream', 'not-applicable', 'Kaufland', 'none', '4003586101723'),
  ('DE', 'Funny Frisch', 'Grocery', 'Chips', 'Chipsfrisch ungarisch', 'not-applicable', null, 'none', '4003586101310'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Ofenchips paprika', 'not-applicable', null, 'none', '4003586102072'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Lays Salted Chips', 'not-applicable', null, 'none', '4062139005864'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Linsen Chips Sour Creme Style', 'not-applicable', 'Rossmann', 'none', '4003586104038'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Sour Cream & Onion', 'not-applicable', 'Netto', 'none', '4062139005888'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Naturals - Rosmarin', 'not-applicable', 'Kaufland', 'none', '4018077714016'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Tortillas Nacho Cheese', 'not-applicable', null, 'none', '4001242105917'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Western Style', 'not-applicable', 'Netto', 'none', '4018077004117'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Tortillas - Wild Paprika', 'not-applicable', null, 'none', '4001242105931'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Chips "Subway Terriyaki"', 'not-applicable', null, 'none', '4062139003136'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Salziges, Riffels Naturell', 'not-applicable', null, 'none', '4003586000347'),
  ('DE', 'LORENZ Crunchips', 'Grocery', 'Chips', 'Crunchips Salted Gesalzene Kartoffel-Chips', 'not-applicable', null, 'none', '4018077004285'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Erdnusslocken Jumbos', 'not-applicable', null, 'none', '4018077006258'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Chili Cheese Fries Style', 'not-applicable', null, 'none', '4003586107350'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Tortillas Salted', 'not-applicable', null, 'none', '4001242105924'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Sweet-Chili-Peppergeschmack', 'not-applicable', 'Aldi', 'none', '4062139006052'),
  ('DE', 'Aldi', 'Grocery', 'Chips', 'Tortilla-Chips - Paprika', 'not-applicable', 'Aldi', 'none', '4061459158236'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Frit-Sticks ungarisch', 'not-applicable', 'Penny', 'none', '4003586105196'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Naturals Chips "fein gesalzen"', 'not-applicable', null, 'none', '4018077714351'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Linsenchips Oriental', 'not-applicable', null, 'none', '4003586104137'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Tortillas Hot Chili', 'not-applicable', null, 'none', '4001242105900'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Naturals - Meersalz und Pfeffer', 'not-applicable', null, 'none', '4018077714313'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Kessel Chips sweet chili', 'not-applicable', 'Lidl', 'none', '4003586002914'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Erdnussflips Classic', 'not-applicable', 'Aldi', 'none', '4061458059015'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Cheese & Onion 150g', 'not-applicable', null, 'none', '4018077004469'),
  ('DE', 'DmBio', 'Grocery', 'Chips', 'Tortilla Chips', 'not-applicable', null, 'none', '4066447225662'),
  ('DE', 'Snack Day', 'Grocery', 'Chips', 'Chips Paprika', 'not-applicable', 'Lidl', 'none', '4056489236559'),
  ('DE', 'Aldi', 'Grocery', 'Chips', 'Chips SALZ', 'not-applicable', 'Aldi', 'none', '4061458024631'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Light-Chips - Classic', 'not-applicable', 'Aldi', 'none', '4061458061445'),
  ('DE', 'Snäcky Knabbergebäck', 'Grocery', 'Chips', 'Light-Chips - Paprika-Style', 'not-applicable', 'Aldi', 'none', '4061458061452'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Crunchips Hot Paprika', 'not-applicable', 'Kaufland', 'none', '4018077004193'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Kessel-Chips Sweet-Chili-Geschmack', 'not-applicable', 'Aldi', 'none', '4061458058995'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Pommels Original', 'not-applicable', null, 'none', '4018077619458'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Linsen Chips Sweet Chili', 'not-applicable', 'Kaufland', 'none', '4003586104007'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Nacho Cheese', 'not-applicable', 'Lidl', 'none', '4062139026159'),
  ('DE', 'Aldi', 'Grocery', 'Chips', 'Linsen-Chips - Paprika-Style', 'not-applicable', 'Aldi', 'none', '4047247037235'),
  ('DE', 'Aldi', 'Grocery', 'Chips', 'Linsen-Chips - Sour Cream Style', 'not-applicable', 'Aldi', 'none', '4047247037242'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Zwiebli-Ringe', 'not-applicable', null, 'none', '4003586006042'),
  ('DE', 'K-Classic', 'Grocery', 'Chips', 'Kartoffelchips Paprika', 'not-applicable', 'Kaufland', 'none', '4014740611125'),
  ('DE', 'Bio zentrale', 'Grocery', 'Chips', 'Tortilla Chips Mais & Paprika', 'not-applicable', null, 'none', '4005009100566'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Zaziki Style', 'not-applicable', null, 'none', '4003586108630'),
  ('DE', 'Aldi', 'Grocery', 'Chips', 'Stapelchips - Original', 'not-applicable', 'Aldi', 'none', '4061458061551'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Chips', 'Krabbenchips - Classic', 'not-applicable', 'Aldi', 'none', '4061458104012'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Kartoffelringe Paprikageschmack', 'not-applicable', 'Aldi', 'none', '4061458239981'),
  ('DE', 'Lidl', 'Grocery', 'Chips', 'Salz Chips', 'not-applicable', 'Lidl', 'none', '4056489096092'),
  ('DE', 'Snack Day', 'Grocery', 'Chips', 'Sour Cream & Onion Flavour', 'not-applicable', 'Lidl', 'none', '4056489238799'),
  ('DE', 'Ültje', 'Grocery', 'Chips', 'Linsen Crackets Paprika', 'not-applicable', null, 'none', '4004980885004'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Hurricorn', 'not-applicable', 'Aldi', 'none', '4047247544696'),
  ('DE', 'Snack Day', 'Grocery', 'Chips', 'Snack Day Paprika Stapelchips', 'not-applicable', 'Lidl', 'none', '4056489238775'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Tortillias Nacho Cheese', 'not-applicable', 'Lidl', 'none', '4001242105955'),
  ('DE', 'K-Classic', 'Grocery', 'Chips', 'Geriffelte Paprika Chips', 'not-applicable', 'Kaufland', 'none', '4014740611132'),
  ('DE', 'Ültje', 'Grocery', 'Chips', 'Fusion - Peanuts Paprika Flamed Style', 'not-applicable', 'Netto', 'none', '4004980409507'),
  ('DE', 'Halloween', 'Grocery', 'Chips', 'Gespenster - Ketchupgeschmack', 'not-applicable', 'Aldi', 'none', '4061458036306'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Chips Paprika Style', 'not-applicable', null, 'none', '4061461010355'),
  ('DE', 'Funny Frisch', 'Grocery', 'Chips', 'Ofen Chips Sour Cream', 'not-applicable', null, 'none', '4003586102089'),
  ('DE', 'Chio', 'Grocery', 'Chips', 'Red Paprika Chips', 'not-applicable', null, 'none', '4001242108536'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Doritos Nacho Cheese', 'not-applicable', null, 'none', '4062139006038'),
  ('DE', 'Snack Food Poco Loco', 'Grocery', 'Chips', 'ALDI SUN SNACKS Tortilla Chips Salz 300g 1.59€ 1kg 5.30€', 'not-applicable', null, 'none', '4061458058537'),
  ('DE', 'Clancy''s', 'Grocery', 'Chips', 'Nacho Cheese Tortilla Chips', 'not-applicable', null, 'none', '4061464838192'),
  ('DE', 'Sun Snacks', 'Grocery', 'Chips', 'Sun Snacks Party Snack Paprika', 'not-applicable', null, 'none', '4068262083588'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Linsen Chips Paprika Style', 'not-applicable', null, 'none', '4003586104120'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Chips Red Paprika Lays', 'not-applicable', null, 'none', '4062139007677'),
  ('DE', 'Funny Frisch', 'Grocery', 'Chips', 'Chipsfrisch XXL Ungarisch', 'not-applicable', null, 'none', '4003586101358'),
  ('DE', 'Rewe', 'Grocery', 'Chips', 'Kartoffel Chips mit Trüffel Geschmack', 'not-applicable', null, 'none', '4337256543675'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Salt & Vinegar', 'not-applicable', null, 'none', '4062139005949'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Peperoni', 'not-applicable', null, 'none', '4003586100306'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Doritos - Whopper-Geschmack', 'not-applicable', null, 'none', '4062139026760'),
  ('DE', 'Funnyfrisch', 'Grocery', 'Chips', 'Ofen Chips Smoky BBQ Style', 'not-applicable', null, 'none', '4003586102317'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Chili und Lime Chips', 'not-applicable', null, 'none', '4062139026333'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Chipsfrisch Chakalaka', 'not-applicable', null, 'none', '4003586101082'),
  ('DE', 'Doritos', 'Grocery', 'Chips', 'Doritos Paprikageschmack', 'not-applicable', null, 'none', '4062139005826'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Snack-Hits', 'not-applicable', null, 'none', '4018077010316'),
  ('DE', 'Funny Frisch', 'Grocery', 'Chips', 'Jumpys', 'not-applicable', null, 'none', '4003586102676'),
  ('DE', 'Funny-frisch', 'Grocery', 'Chips', 'Popchips Potato - Red Paprika', 'not-applicable', null, 'none', '4003586105165'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Rohscheiben mit Steinsalz', 'not-applicable', null, 'none', '4018077680588'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Iconic Restauraunt Flavours', 'not-applicable', null, 'none', '4062139003150'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'CrunChips Sour Cream', 'not-applicable', null, 'none', '4018077006883'),
  ('DE', 'Lorenz', 'Grocery', 'Chips', 'Naturals Balsamico', 'not-applicable', null, 'none', '4018077714054'),
  ('DE', 'EDEKA funnyfrisch', 'Grocery', 'Chips', 'EDEKA funnyfrisch Chipsfrisch Salt & Vinegar Style 150g 0.99€ 1kg 6.60€', 'not-applicable', null, 'none', '4003586108456'),
  ('DE', 'Lay''s', 'Grocery', 'Chips', 'Pizza Hut Chips Margherita', 'not-applicable', null, 'none', '4062139006762')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'DE' and category = 'Chips'
  and is_deprecated is not true
  and product_name not in ('Pom-Bär Ketchup Style', 'Aus dem Ofen Geröstete Paprika', 'Gemüsechips – Pastinake, Rote Beete, Süßkartoffel, lila Süßkartoffel, Meersalz', 'Naturals Mediterranes Gemüse', 'Knuspermäuse Salz', 'Pom-Bär Crizzlies - Paprika-Style', 'Gemüsechips mit Meersalz', 'Kräuterbutterchips', 'Pombär Sour Cream', 'Gemüse Chips mit Meersalz', 'Tortilla-Chips - Käse', 'Pom-Bär Crizzlies - Original', 'Crunchips Paprika', 'Chipsfrisch Oriental', 'Chipsfrisch Sour Cream', 'Chipsfrisch ungarisch', 'Ofenchips paprika', 'Lays Salted Chips', 'Linsen Chips Sour Creme Style', 'Sour Cream & Onion', 'Naturals - Rosmarin', 'Tortillas Nacho Cheese', 'Crunchips Western Style', 'Tortillas - Wild Paprika', 'Chips "Subway Terriyaki"', 'Salziges, Riffels Naturell', 'Crunchips Salted Gesalzene Kartoffel-Chips', 'Erdnusslocken Jumbos', 'Chipsfrisch Chili Cheese Fries Style', 'Tortillas Salted', 'Sweet-Chili-Peppergeschmack', 'Tortilla-Chips - Paprika', 'Frit-Sticks ungarisch', 'Naturals Chips "fein gesalzen"', 'Linsenchips Oriental', 'Tortillas Hot Chili', 'Naturals - Meersalz und Pfeffer', 'Kessel Chips sweet chili', 'Erdnussflips Classic', 'Crunchips Cheese & Onion 150g', 'Tortilla Chips', 'Chips Paprika', 'Chips SALZ', 'Light-Chips - Classic', 'Light-Chips - Paprika-Style', 'Crunchips Hot Paprika', 'Kessel-Chips Sweet-Chili-Geschmack', 'Pommels Original', 'Linsen Chips Sweet Chili', 'Nacho Cheese', 'Linsen-Chips - Paprika-Style', 'Linsen-Chips - Sour Cream Style', 'Zwiebli-Ringe', 'Kartoffelchips Paprika', 'Tortilla Chips Mais & Paprika', 'Chipsfrisch Zaziki Style', 'Stapelchips - Original', 'Krabbenchips - Classic', 'Kartoffelringe Paprikageschmack', 'Salz Chips', 'Sour Cream & Onion Flavour', 'Linsen Crackets Paprika', 'Hurricorn', 'Snack Day Paprika Stapelchips', 'Tortillias Nacho Cheese', 'Geriffelte Paprika Chips', 'Fusion - Peanuts Paprika Flamed Style', 'Gespenster - Ketchupgeschmack', 'Chips Paprika Style', 'Ofen Chips Sour Cream', 'Red Paprika Chips', 'Doritos Nacho Cheese', 'ALDI SUN SNACKS Tortilla Chips Salz 300g 1.59€ 1kg 5.30€', 'Nacho Cheese Tortilla Chips', 'Sun Snacks Party Snack Paprika', 'Linsen Chips Paprika Style', 'Chips Red Paprika Lays', 'Chipsfrisch XXL Ungarisch', 'Kartoffel Chips mit Trüffel Geschmack', 'Salt & Vinegar', 'Chipsfrisch Peperoni', 'Doritos - Whopper-Geschmack', 'Ofen Chips Smoky BBQ Style', 'Chili und Lime Chips', 'Chipsfrisch Chakalaka', 'Doritos Paprikageschmack', 'Snack-Hits', 'Jumpys', 'Popchips Potato - Red Paprika', 'Rohscheiben mit Steinsalz', 'Iconic Restauraunt Flavours', 'CrunChips Sour Cream', 'Naturals Balsamico', 'EDEKA funnyfrisch Chipsfrisch Salt & Vinegar Style 150g 0.99€ 1kg 6.60€', 'Pizza Hut Chips Margherita');

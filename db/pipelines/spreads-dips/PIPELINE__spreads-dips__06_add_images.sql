-- PIPELINE (Spreads & Dips): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Spreads & Dips'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Wawrzyniec', 'Hummus z pestkami dyni i słonecznika', 'https://images.openfoodfacts.org/images/products/590/001/201/0828/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900012010828', 'front_5900012010828'),
    ('Sensation', 'Ajvar łagodny', 'https://images.openfoodfacts.org/images/products/590/578/435/1414/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784351414', 'front_5905784351414'),
    ('Nasza spiżarnia', 'Ajvar łagodny', 'https://images.openfoodfacts.org/images/products/590/437/864/3287/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378643287', 'front_5904378643287'),
    ('Auchan', 'Hummus z solą morską', 'https://images.openfoodfacts.org/images/products/590/421/514/9460/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215149460', 'front_5904215149460'),
    ('Mlekpol', 'Dip śmietankowy z czosnkiem i ziołami', 'https://images.openfoodfacts.org/images/products/590/082/002/1832/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820021832', 'front_5900820021832'),
    ('Niewieścin', 'Pasztetowa Podwędzana', 'https://images.openfoodfacts.org/images/products/590/722/267/3294/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907222673294', 'front_5907222673294'),
    ('Go Vege', 'Hummus klasyczny', 'https://images.openfoodfacts.org/images/products/590/419/490/6641/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906641', 'front_5904194906641'),
    ('Go Vege', 'Hummus paprykowy', 'https://images.openfoodfacts.org/images/products/590/419/490/6658/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906658', 'front_5904194906658'),
    ('Go Vege', 'Hummus z ciecierzycy spicy salsa', 'https://images.openfoodfacts.org/images/products/590/419/490/6696/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906696', 'front_5904194906696'),
    ('Go Vege', 'Hummus pomidorowy', 'https://images.openfoodfacts.org/images/products/590/419/490/6665/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906665', 'front_5904194906665'),
    ('Go Vege', 'Hummus z ciecierzycy z burakiem', 'https://images.openfoodfacts.org/images/products/590/419/490/6672/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194906672', 'front_5904194906672'),
    ('I&lt;3vege', 'Hummus z papryką na ostro', 'https://images.openfoodfacts.org/images/products/590/061/703/9514/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617039514', 'front_5900617039514'),
    ('Go Vege', 'Hummus', 'https://images.openfoodfacts.org/images/products/590/751/780/5522/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907517805522', 'front_5907517805522'),
    ('Go Vege', 'Hummus z burakiem', 'https://images.openfoodfacts.org/images/products/590/751/780/8240/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907517808240', 'front_5907517808240'),
    ('Vital Fresh', 'Hummus pomidorowy', 'https://images.openfoodfacts.org/images/products/590/751/780/1968/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907517801968', 'front_5907517801968'),
    ('Lisner', 'Hummus z wędzonym pstrągiem', 'https://images.openfoodfacts.org/images/products/590/034/400/2324/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344002324', 'front_5900344002324'),
    ('Lavica Food', 'Hummus dynia & imbir', 'https://images.openfoodfacts.org/images/products/590/324/079/3884/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240793884', 'front_5903240793884'),
    ('Pilos', 'Masło Klarowane', 'https://images.openfoodfacts.org/images/products/590/547/700/3743/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905477003743', 'front_5905477003743'),
    ('SmaczneGo!', 'Hummus klasyczny z preclami', 'https://images.openfoodfacts.org/images/products/590/751/780/5478/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907517805478', 'front_5907517805478'),
    ('I-love-vege', 'Hummus z suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/590/061/703/5714/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617035714', 'front_5900617035714'),
    ('Dega', 'Hummus', 'https://images.openfoodfacts.org/images/products/590/762/326/8136/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907623268136', 'front_5907623268136'),
    ('Lovege', 'Hummus Klasyczny', 'https://images.openfoodfacts.org/images/products/590/061/703/0078/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617030078', 'front_5900617030078'),
    ('Perla', 'Pomidor hummus', 'https://images.openfoodfacts.org/images/products/590/419/490/1271/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194901271', 'front_5904194901271'),
    ('Perla', 'Hummus Trio', 'https://images.openfoodfacts.org/images/products/590/419/490/0854/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194900854', 'front_5904194900854'),
    ('I love vege', 'Sante Hummus With Dried Tomatoes 180 G', 'https://images.openfoodfacts.org/images/products/590/061/703/0115/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617030115', 'front_5900617030115'),
    ('Helcom', 'Dip in mexicana style', 'https://images.openfoodfacts.org/images/products/590/216/672/8161/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902166728161', 'front_5902166728161'),
    ('Zdrowidło', 'Hummus kremowy z ciecierzycy klasyczny', 'https://images.openfoodfacts.org/images/products/590/456/955/0615/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904569550615', 'front_5904569550615'),
    ('NaturAvena', 'Ekologiczny hummus oliwkowy', 'https://images.openfoodfacts.org/images/products/590/242/505/0286/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902425050286', 'front_5902425050286'),
    ('NaturAvena', 'Ekologiczny hummus paprykowy', 'https://images.openfoodfacts.org/images/products/590/242/505/0293/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902425050293', 'front_5902425050293'),
    ('Sensation', 'Vegetal Hummus - paprykowy', 'https://images.openfoodfacts.org/images/products/590/578/430/5363/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784305363', 'front_5905784305363'),
    ('Casa Del Sur', 'Salsa dip cheese', 'https://images.openfoodfacts.org/images/products/590/175/270/4602/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752704602', 'front_5901752704602'),
    ('Perla', 'SmaczneGo! - hummus klasyczny z preclami', 'https://images.openfoodfacts.org/images/products/590/751/780/5447/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907517805447', 'front_5907517805447'),
    ('Perla', 'Hummus', 'https://images.openfoodfacts.org/images/products/590/419/490/2025/front_da.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194902025', 'front_5904194902025'),
    ('Metro chef', 'Hummus tradycyjny', 'https://images.openfoodfacts.org/images/products/590/224/124/3930/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902241243930', 'front_5902241243930'),
    ('Lavica food', 'Hummus klasyczny', 'https://images.openfoodfacts.org/images/products/590/324/079/3433/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240793433', 'front_5903240793433'),
    ('Lavica food', 'Hummus proteinowy klasyczny', 'https://images.openfoodfacts.org/images/products/590/539/858/5755/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905398585755', 'front_5905398585755'),
    ('Sokołów', 'Pasztet basi', 'https://images.openfoodfacts.org/images/products/590/056/225/0439/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562250439', 'front_5900562250439'),
    ('Profi', 'Pasztet Dworski Z Dzikiem', 'https://images.openfoodfacts.org/images/products/590/169/601/1644/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696011644', 'front_5901696011644'),
    ('Sokołów', 'Pasztet dzidunia', 'https://images.openfoodfacts.org/images/products/590/056/226/6935/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562266935', 'front_5900562266935'),
    ('Gzella', 'Pasztet z borowikami', 'https://images.openfoodfacts.org/images/products/590/189/174/4026/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901891744026', 'front_5901891744026'),
    ('Vemondo', 'Hummus z pastą sezamowa i pesto bazyliowym', 'https://images.openfoodfacts.org/images/products/433/561/912/7524/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335619127524', 'front_4335619127524'),
    ('Chef Select', 'Guacamole Z Kawałkami Awokado', 'https://images.openfoodfacts.org/images/products/405/648/985/1400/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489851400', 'front_4056489851400'),
    ('Unknown', 'Ekologiczny Hummus Naturalny', 'https://images.openfoodfacts.org/images/products/590/236/740/9982/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902367409982', 'front_5902367409982'),
    ('Lisner', 'Hummus clasic', 'https://images.openfoodfacts.org/images/products/590/034/400/2201/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344002201', 'front_5900344002201'),
    ('Primavika', 'Humus naturalny', 'https://images.openfoodfacts.org/images/products/590/067/230/0932/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900672300932', 'front_5900672300932'),
    ('Lavica Food', 'Hummus z suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/590/324/079/3044/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903240793044', 'front_5903240793044'),
    ('Sobkowiak', 'Pasztet pieczony z żurawiną', 'https://images.openfoodfacts.org/images/products/153/230/200/5449/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 1532302005449', 'front_1532302005449'),
    ('Tzatziki', 'Taziki', 'https://images.openfoodfacts.org/images/products/590/113/501/0177/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901135010177', 'front_5901135010177'),
    ('Vemondo', 'Hummus klasyczny', 'https://images.openfoodfacts.org/images/products/405/648/930/6344/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489306344', 'front_4056489306344'),
    ('Chef select', 'Hummus classic', 'https://images.openfoodfacts.org/images/products/000/002/090/1882/front_pl.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 20901882', 'front_20901882'),
    ('Taverna-Bio', 'Classic Hummus', 'https://images.openfoodfacts.org/images/products/871/917/205/0608/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8719172050608', 'front_8719172050608'),
    ('Vital', 'Guacamole', 'https://images.openfoodfacts.org/images/products/843/600/852/0950/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8436008520950', 'front_8436008520950'),
    ('K-take it veggie', 'K-take it veggie Hummus Classic', 'https://images.openfoodfacts.org/images/products/406/336/720/1967/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367201967', 'front_4063367201967'),
    ('Chef Select', 'Hummus z sosem pomidorowym', 'https://images.openfoodfacts.org/images/products/405/648/933/9052/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489339052', 'front_4056489339052'),
    ('Vitasia', 'Hummus sweet chili', 'https://images.openfoodfacts.org/images/products/405/648/955/0587/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489550587', 'front_4056489550587'),
    ('Athos', 'Tzatziki', 'https://images.openfoodfacts.org/images/products/520/227/700/0515/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5202277000515', 'front_5202277000515'),
    ('Chef select', 'Bio Hummus paprykowy', 'https://images.openfoodfacts.org/images/products/405/648/930/6351/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489306351', 'front_4056489306351'),
    ('Chef select', 'Guacamole Classic with tomato and spices', 'https://images.openfoodfacts.org/images/products/405/648/996/2991/front_de.103.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489962991', 'front_4056489962991'),
    ('Chef select', 'Bio Hummus pomidorowy', 'https://images.openfoodfacts.org/images/products/405/648/930/6368/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489306368', 'front_4056489306368'),
    ('Vemondo', 'Hummus Paprykowy', 'https://images.openfoodfacts.org/images/products/000/002/090/1929/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 20901929', 'front_20901929'),
    ('Vital Fresh', 'Guacamole', 'https://images.openfoodfacts.org/images/products/843/600/852/1414/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 8436008521414', 'front_8436008521414'),
    ('Lidl', 'Hummus mit falafel & mango mousse', 'https://images.openfoodfacts.org/images/products/405/648/945/9538/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489459538', 'front_4056489459538'),
    ('Doyal', 'Humus', 'https://images.openfoodfacts.org/images/products/431/673/403/2351/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316734032351', 'front_4316734032351'),
    ('Nature''s Promise', 'Hummus klasik', 'https://images.openfoodfacts.org/images/products/859/042/104/4872/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8590421044872', 'front_8590421044872'),
    ('La campagna', 'Hummus', 'https://images.openfoodfacts.org/images/products/571/287/367/4534/front_da.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5712873674534', 'front_5712873674534'),
    ('Taverna', 'Hummus coriander & lemon', 'https://images.openfoodfacts.org/images/products/858/800/434/8585/front_cs.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8588004348585', 'front_8588004348585'),
    ('Pikok', 'Pasztet z indyka', 'https://images.openfoodfacts.org/images/products/405/648/950/8274/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489508274', 'front_4056489508274'),
    ('Unknown', 'Mild salsa dip', 'https://images.openfoodfacts.org/images/products/570/820/900/1518/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5708209001518', 'front_5708209001518'),
    ('Taverna', 'Hummus Oriental', 'https://images.openfoodfacts.org/images/products/858/800/434/8387/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8588004348387', 'front_8588004348387'),
    ('Unknown', 'Dip nacho', 'https://images.openfoodfacts.org/images/products/570/820/900/1570/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5708209001570', 'front_5708209001570'),
    ('Hellas feinkost', 'Tzatziki', 'https://images.openfoodfacts.org/images/products/900/297/452/9915/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 9002974529915', 'front_9002974529915')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spreads & Dips' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

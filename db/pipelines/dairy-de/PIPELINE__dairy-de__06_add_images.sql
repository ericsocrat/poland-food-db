-- PIPELINE (Dairy): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Dairy'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Milsani', 'Frischkäse natur', 'https://images.openfoodfacts.org/images/products/406/145/804/7685/front_de.108.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047685', 'front_4061458047685'),
    ('Gervais', 'Hüttenkäse Original', 'https://images.openfoodfacts.org/images/products/400/267/115/7751/front_de.95.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002671157751', 'front_4002671157751'),
    ('Milsani', 'Körniger Frischkäse, Halbfettstufe', 'https://images.openfoodfacts.org/images/products/406/145/804/7692/front_de.114.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047692', 'front_4061458047692'),
    ('Almette', 'Almette Kräuter', 'https://images.openfoodfacts.org/images/products/400/246/808/4017/front_de.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002468084017', 'front_4002468084017'),
    ('Bergader', 'Bergbauern mild nussig Käse', 'https://images.openfoodfacts.org/images/products/400/640/204/6192/front_de.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006402046192', 'front_4006402046192'),
    ('DOVGAN Family', 'Körniger Frischkäse 33 % Fett', 'https://images.openfoodfacts.org/images/products/403/254/901/8105/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4032549018105', 'front_4032549018105'),
    ('BMI Biobauern', 'Bio-Landkäse mild-nussig', 'https://images.openfoodfacts.org/images/products/404/090/011/7251/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4040900117251', 'front_4040900117251'),
    ('Dr. Oetker', 'High Protein Pudding Grieß', 'https://images.openfoodfacts.org/images/products/402/360/001/3511/front_en.82.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600013511', 'front_4023600013511'),
    ('Milsan', 'Grießpudding High-Protein - Zimt', 'https://images.openfoodfacts.org/images/products/406/145/828/0334/front_en.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458280334', 'front_4061458280334'),
    ('Milram', 'Frühlingsquark Original', 'https://images.openfoodfacts.org/images/products/000/004/046/6002/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 40466002', 'front_40466002'),
    ('DMK', 'Müritzer original', 'https://images.openfoodfacts.org/images/products/403/630/000/5311/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300005311', 'front_4036300005311'),
    ('Milsani', 'Körniger Frischkäse mit fettarmem Joghurt - leicht', 'https://images.openfoodfacts.org/images/products/406/145/804/7708/front_en.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047708', 'front_4061458047708'),
    ('AF Deutschland', 'Hirtenkäse', 'https://images.openfoodfacts.org/images/products/406/145/816/3903/front_en.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458163903', 'front_4061458163903'),
    ('Grünländer', 'Grünländer Mild & Nussig', 'https://images.openfoodfacts.org/images/products/400/246/821/0454/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002468210454', 'front_4002468210454'),
    ('Grünländer', 'Grünländer Leicht', 'https://images.openfoodfacts.org/images/products/400/246/821/0478/front_de.73.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002468210478', 'front_4002468210478'),
    ('Gazi', 'Grill- und Pfannenkäse', 'https://images.openfoodfacts.org/images/products/400/256/601/0703/front_de.461.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002566010703', 'front_4002566010703'),
    ('Bio', 'ALDI GUT BIO Milch Frische Bio-Milch 1.5 % Fett Aus der Kühlung 1l 1.15€ Fettarme Milch', 'https://images.openfoodfacts.org/images/products/406/145/919/3312/front_en.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459193312', 'front_4061459193312'),
    ('Milsani', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'https://images.openfoodfacts.org/images/products/406/145/822/9838/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458229838', 'front_4061458229838'),
    ('Miree', 'Frischkäse Französische Kräuter', 'https://images.openfoodfacts.org/images/products/000/004/019/3083/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 40193083', 'front_40193083'),
    ('Milram', 'Müritzer herzhaft', 'https://images.openfoodfacts.org/images/products/403/630/000/5090/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300005090', 'front_4036300005090'),
    ('Milbona', 'Frischkäse becher', 'https://images.openfoodfacts.org/images/products/405/648/908/9797/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489089797', 'front_4056489089797'),
    ('Gut Bio', 'ALDI BIO Frische Bio-Vollmilch 3,8 % Fett; kontrolliert ökologische Erzeugung Aus der Kühlung 1.35€ 1-L-Packung Liter 1.35€', 'https://images.openfoodfacts.org/images/products/406/146/204/5509/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462045509', 'front_4061462045509'),
    ('Exquisa', 'Körniger Frischkäse', 'https://images.openfoodfacts.org/images/products/401/930/009/7005/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019300097005', 'front_4019300097005'),
    ('Milbona', 'Käse Aufschnitt Leicht', 'https://images.openfoodfacts.org/images/products/405/648/909/1578/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489091578', 'front_4056489091578'),
    ('Milram', 'Frühlingsquark Leicht', 'https://images.openfoodfacts.org/images/products/000/004/046/6057/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 40466057', 'front_40466057'),
    ('Aldi', 'Bio-Bergbauernkäse nussig', 'https://images.openfoodfacts.org/images/products/406/145/970/0275/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459700275', 'front_4061459700275'),
    ('Milsani', 'Kräuterquark', 'https://images.openfoodfacts.org/images/products/406/145/801/4793/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014793', 'front_4061458014793'),
    ('Milram', 'Sylter Käse, Milram', 'https://images.openfoodfacts.org/images/products/403/630/000/5298/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300005298', 'front_4036300005298'),
    ('Aldi', 'Grießpudding High-Protein - Pur/Classic', 'https://images.openfoodfacts.org/images/products/406/145/827/8928/front_de.98.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458278928', 'front_4061458278928'),
    ('Aldi', 'Fraîcho - Kräuter der Provence', 'https://images.openfoodfacts.org/images/products/404/724/719/7830/front_en.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247197830', 'front_4047247197830'),
    ('Milsani', 'Joghurt nach türkischer Art, 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/824/4299/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458244299', 'front_4061458244299'),
    ('Hofburger', 'Butterkäse in Scheiben', 'https://images.openfoodfacts.org/images/products/406/145/804/6947/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458046947', 'front_4061458046947'),
    ('Milbona', 'Bio Hirtenkäse', 'https://images.openfoodfacts.org/images/products/405/648/989/3547/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489893547', 'front_4056489893547'),
    ('Exquisa', 'Exquisa Balance Frischkäse', 'https://images.openfoodfacts.org/images/products/401/930/000/5307/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4019300005307', 'front_4019300005307'),
    ('Milram', 'Körniger Frischkäse', 'https://images.openfoodfacts.org/images/products/403/630/000/2648/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300002648', 'front_4036300002648'),
    ('Aldi', 'ALDI LYTTOS Weißkäse in Salzlake', 'https://images.openfoodfacts.org/images/products/406/145/804/4387/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458044387', 'front_4061458044387'),
    ('Baackes & Heimes', 'Ziegenkäse in Scheiben - Natur', 'https://images.openfoodfacts.org/images/products/406/145/804/7111/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047111', 'front_4061458047111'),
    ('Weihenstephan', 'H-Milch 3,5%', 'https://images.openfoodfacts.org/images/products/400/845/202/7602/front_en.166.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452027602', 'front_4008452027602'),
    ('Milbona', 'Skyr', 'https://images.openfoodfacts.org/images/products/405/648/901/2788/front_en.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489012788', 'front_4056489012788'),
    ('Arla', 'Skyr Natur', 'https://images.openfoodfacts.org/images/products/401/624/103/0603/front_de.108.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016241030603', 'front_4016241030603'),
    ('Milsani', 'H-Vollmilch 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/406/146/284/2986/front_de.75.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462842986', 'front_4061462842986'),
    ('Elinas', 'Joghurt Griechischer Art', 'https://images.openfoodfacts.org/images/products/400/349/032/3600/front_de.124.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490323600', 'front_4003490323600'),
    ('Alpenhain', 'Obazda klassisch', 'https://images.openfoodfacts.org/images/products/400/375/100/2848/front_de.85.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003751002848', 'front_4003751002848'),
    ('Ehrmann', 'High Protein Chocolate Pudding', 'https://images.openfoodfacts.org/images/products/400/297/124/3703/front_de.192.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971243703', 'front_4002971243703'),
    ('Bio', 'Frische Bio-Vollmilch 3,8 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/919/3695/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459193695', 'front_4061459193695'),
    ('Milsani', 'Haltbare Fettarme Milch', 'https://images.openfoodfacts.org/images/products/406/146/284/2764/front_de.153.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462842764', 'front_4061462842764'),
    ('Arla', 'Skyr Bourbon Vanille', 'https://images.openfoodfacts.org/images/products/401/624/103/0917/front_de.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016241030917', 'front_4016241030917'),
    ('Milbona', 'High Protein Chocolate Flavour Pudding', 'https://images.openfoodfacts.org/images/products/405/648/921/6162/front_en.329.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489216162', 'front_4056489216162'),
    ('Milsani', 'Joghurt mild 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/802/8820/front_de.111.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028820', 'front_4061458028820'),
    ('Schwarzwaldmilch', 'Protein Milch', 'https://images.openfoodfacts.org/images/products/404/670/000/1806/front_en.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4046700001806', 'front_4046700001806'),
    ('Bresso', 'Bresso', 'https://images.openfoodfacts.org/images/products/404/535/700/4383/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045357004383', 'front_4045357004383'),
    ('Milsani', 'Milch', 'https://images.openfoodfacts.org/images/products/406/146/286/4803/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462864803', 'front_4061462864803'),
    ('Bergader', 'Bavaria Blu', 'https://images.openfoodfacts.org/images/products/400/640/202/0413/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006402020413', 'front_4006402020413'),
    ('Aldi', 'Milch, haltbar, 1,5 %, Bio', 'https://images.openfoodfacts.org/images/products/405/648/901/3105/front_de.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489013105', 'front_4056489013105'),
    ('Aldi', 'A/Joghurt mild 3,5% Fett', 'https://images.openfoodfacts.org/images/products/406/145/802/8813/front_de.96.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028813', 'front_4061458028813'),
    ('Patros', 'Patros Natur', 'https://images.openfoodfacts.org/images/products/400/267/115/1353/front_de.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002671151353', 'front_4002671151353'),
    ('Ehrmann', 'High-Protein-Pudding - Vanilla', 'https://images.openfoodfacts.org/images/products/400/297/124/3802/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971243802', 'front_4002971243802'),
    ('Patros', 'Feta (Schaf- & Ziegenmilch)', 'https://images.openfoodfacts.org/images/products/400/246/813/4361/front_de.85.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002468134361', 'front_4002468134361'),
    ('Milsani', 'Frische Vollmilch 3,5%', 'https://images.openfoodfacts.org/images/products/406/146/286/5015/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462865015', 'front_4061462865015'),
    ('Milram', 'Benjamin', 'https://images.openfoodfacts.org/images/products/403/630/000/5304/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300005304', 'front_4036300005304'),
    ('Milbona', 'Bio Fettarmer Joghurt mild', 'https://images.openfoodfacts.org/images/products/405/648/901/4003/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489014003', 'front_4056489014003'),
    ('Bauer', 'Kirsche', 'https://images.openfoodfacts.org/images/products/400/233/411/3032/front_de.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002334113032', 'front_4002334113032'),
    ('Milbona', 'Skyr Vanilla', 'https://images.openfoodfacts.org/images/products/405/648/911/8190/front_en.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118190', 'front_4056489118190'),
    ('Weihenstephan', 'Joghurt Natur 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/400/845/201/1007/front_de.173.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452011007', 'front_4008452011007'),
    ('Cucina Nobile', 'Mozzarella', 'https://images.openfoodfacts.org/images/products/406/145/801/8531/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458018531', 'front_4061458018531'),
    ('Bio', 'Bio-Feta', 'https://images.openfoodfacts.org/images/products/406/145/800/5548/front_de.99.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458005548', 'front_4061458005548'),
    ('Ein gutes Stück Bayern', 'Haltbare Bio Vollmilch', 'https://images.openfoodfacts.org/images/products/405/648/937/9850/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489379850', 'front_4056489379850'),
    ('Lyttos', 'Griechischer Joghurt', 'https://images.openfoodfacts.org/images/products/406/145/824/4404/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458244404', 'front_4061458244404'),
    ('AF Deutschland', 'Fettarme Milch (laktosefrei; 1,5% Fett)', 'https://images.openfoodfacts.org/images/products/406/146/284/3723/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462843723', 'front_4061462843723'),
    ('Lyttos', 'ALDI LYTTOS YOGRI nach griechischer Art 1kg 2.19€', 'https://images.openfoodfacts.org/images/products/406/145/901/5072/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459015072', 'front_4061459015072'),
    ('Müller', 'Joghurt mit der Ecke - Schoko Balls', 'https://images.openfoodfacts.org/images/products/000/004/025/5729/front_de.99.400.jpg', 'off_api', 'front', true, 'Front — EAN 40255729', 'front_40255729'),
    ('Milbona', 'Bio Organic Cremiger Joghurt Mild (3,8% Fett)', 'https://images.openfoodfacts.org/images/products/405/648/901/8483/front_de.66.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489018483', 'front_4056489018483'),
    ('Milsani', 'Gouda jung in Scheiben', 'https://images.openfoodfacts.org/images/products/406/146/231/4568/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462314568', 'front_4061462314568'),
    ('Milbona', 'Bio Speisequark Magerstufe', 'https://images.openfoodfacts.org/images/products/405/648/901/3082/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489013082', 'front_4056489013082'),
    ('Hofburger', 'Gouda in Scheiben', 'https://images.openfoodfacts.org/images/products/406/146/380/8660/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463808660', 'front_4061463808660'),
    ('Milbona', 'Skyr Erdbeere', 'https://images.openfoodfacts.org/images/products/405/648/911/8206/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118206', 'front_4056489118206'),
    ('Milbona', 'Bio Vollmilch', 'https://images.openfoodfacts.org/images/products/405/648/932/1354/front_en.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489321354', 'front_4056489321354'),
    ('Ehrmann', 'Chocolate & Topping with Protein', 'https://images.openfoodfacts.org/images/products/400/297/124/7503/front_en.119.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971247503', 'front_4002971247503'),
    ('Goldsteig', 'Emmentaler in Scheiben', 'https://images.openfoodfacts.org/images/products/406/145/804/6367/front_de.102.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458046367', 'front_4061458046367'),
    ('Milbona', 'Joghurt 1,5%', 'https://images.openfoodfacts.org/images/products/405/648/915/0497/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489150497', 'front_4056489150497'),
    ('Milsani', 'Speisequark Magerstufe 0,3 % Fett', 'https://images.openfoodfacts.org/images/products/406/146/254/2046/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462542046', 'front_4061462542046'),
    ('Aldi', 'Joghurt mild 3,5% / 0x 500 gr / 3x 150 gr (Gebinde= 4x je 150 gr)', 'https://images.openfoodfacts.org/images/products/406/145/802/8806/front_de.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028806', 'front_4061458028806'),
    ('Elinas', 'Joghurt, Natur', 'https://images.openfoodfacts.org/images/products/400/349/003/2076/front_en.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490032076', 'front_4003490032076'),
    ('Ehrmann', 'High Protein Chocolate Mousse', 'https://images.openfoodfacts.org/images/products/400/297/128/3808/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971283808', 'front_4002971283808'),
    ('DMK', 'Haltbare Schlagsahne', 'https://images.openfoodfacts.org/images/products/406/145/803/2452/front_de.135.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032452', 'front_4061458032452'),
    ('Ehrmann', 'Grand Dessert - Vanille', 'https://images.openfoodfacts.org/images/products/400/297/125/3108/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971253108', 'front_4002971253108'),
    ('Karwendel', 'Miree - Paprika-Chili', 'https://images.openfoodfacts.org/images/products/000/004/019/3052/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 40193052', 'front_40193052'),
    ('Der grüne Altenburger', 'Ziegencreme', 'https://images.openfoodfacts.org/images/products/404/208/900/1246/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4042089001246', 'front_4042089001246'),
    ('Aldi', 'Bio-Magerquark', 'https://images.openfoodfacts.org/images/products/406/145/801/4151/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014151', 'front_4061458014151'),
    ('Weihenstephan', 'Sahne zum Kochen (Weihenstephan)', 'https://images.openfoodfacts.org/images/products/400/845/202/3413/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452023413', 'front_4008452023413'),
    ('Milbona', 'Skyr Blueberry', 'https://images.openfoodfacts.org/images/products/405/648/911/8213/front_en.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118213', 'front_4056489118213'),
    ('Milbona', 'Kefir', 'https://images.openfoodfacts.org/images/products/405/648/910/9570/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489109570', 'front_4056489109570'),
    ('Zott', 'Monte MAXI', 'https://images.openfoodfacts.org/images/products/401/450/003/6830/front_en.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014500036830', 'front_4014500036830'),
    ('Milsani', 'Crème fraîche, 30 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/803/8584/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458038584', 'front_4061458038584'),
    ('Milsani', 'High-Protein-Pudding - Schoko', 'https://images.openfoodfacts.org/images/products/404/724/703/1080/front_en.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247031080', 'front_4047247031080')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Dairy' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

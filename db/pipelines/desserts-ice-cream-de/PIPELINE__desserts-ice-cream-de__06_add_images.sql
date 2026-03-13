-- PIPELINE (Desserts & Ice Cream): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Desserts & Ice Cream'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Gervais', 'Hüttenkäse Original', 'https://images.openfoodfacts.org/images/products/400/267/115/7751/front_de.95.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002671157751', 'front_4002671157751'),
    ('Milsani', 'Körniger Frischkäse, Halbfettstufe', 'https://images.openfoodfacts.org/images/products/406/145/804/7692/front_de.139.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047692', 'front_4061458047692'),
    ('Dr. Oetker', 'High Protein Pudding Grieß', 'https://images.openfoodfacts.org/images/products/402/360/001/3511/front_en.82.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600013511', 'front_4023600013511'),
    ('Milsani', 'Grießpudding High-Protein - Zimt', 'https://images.openfoodfacts.org/images/products/406/145/828/0334/front_en.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458280334', 'front_4061458280334'),
    ('Milsani', 'Körniger Frischkäse mit fettarmem Joghurt - leicht', 'https://images.openfoodfacts.org/images/products/406/145/804/7708/front_en.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458047708', 'front_4061458047708'),
    ('Milsani', 'ALDI MILSANI Skyr Nach isländischer Art mit viel Eiweiß und wenig Fett Aus der Kühlung 1.49€ 500g Becher 1kg 2.98€', 'https://images.openfoodfacts.org/images/products/406/145/822/9838/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458229838', 'front_4061458229838'),
    ('Milsani', 'Kräuterquark', 'https://images.openfoodfacts.org/images/products/406/145/801/4793/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014793', 'front_4061458014793'),
    ('Milsani', 'Grießpudding High-Protein - Pur/Classic', 'https://images.openfoodfacts.org/images/products/406/145/827/8928/front_de.98.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458278928', 'front_4061458278928'),
    ('Milsani', 'Joghurt nach türkischer Art, 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/824/4299/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458244299', 'front_4061458244299'),
    ('Der Grosse Bauer', 'Der große Bauer Himbeere Joghurt mild', 'https://images.openfoodfacts.org/images/products/400/233/411/3018/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002334113018', 'front_4002334113018'),
    ('Bauer', 'Der große Bauer Heidelbeer-Cassis', 'https://images.openfoodfacts.org/images/products/400/233/411/3025/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002334113025', 'front_4002334113025'),
    ('Lidl', 'Kräuterquark', 'https://images.openfoodfacts.org/images/products/405/648/912/4313/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489124313', 'front_4056489124313'),
    ('Milram', 'Frühlings Quark 7 Kräuter', 'https://images.openfoodfacts.org/images/products/000/004/046/6071/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 40466071', 'front_40466071'),
    ('Müller', 'Müller Joghurt mit der Ecke - Schoko-Flakes', 'https://images.openfoodfacts.org/images/products/000/004/025/5774/front_de.83.400.jpg', 'off_api', 'front', true, 'Front — EAN 40255774', 'front_40255774'),
    ('Milram', 'Frühlingsquark Family-Pack', 'https://images.openfoodfacts.org/images/products/000/004/046/6033/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 40466033', 'front_40466033'),
    ('Milram', 'Körniger Frischkäse', 'https://images.openfoodfacts.org/images/products/403/630/000/2648/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4036300002648', 'front_4036300002648'),
    ('Dr. Oetker', 'Götterspeise Waldmeister-Geschmack', 'https://images.openfoodfacts.org/images/products/402/360/001/4235/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600014235', 'front_4023600014235'),
    ('Aldi', 'Mandeljoghurt Natur ungesüßt', 'https://images.openfoodfacts.org/images/products/406/146/395/8310/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463958310', 'front_4061463958310'),
    ('Landliebe', 'Grießpudding Zimt', 'https://images.openfoodfacts.org/images/products/406/751/700/1315/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067517001315', 'front_4067517001315'),
    ('Milbona', 'Skyr', 'https://images.openfoodfacts.org/images/products/405/648/901/2788/front_en.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489012788', 'front_4056489012788'),
    ('Arla', 'Skyr Natur', 'https://images.openfoodfacts.org/images/products/401/624/103/0603/front_de.134.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016241030603', 'front_4016241030603'),
    ('Elinas', 'Joghurt Griechischer Art', 'https://images.openfoodfacts.org/images/products/400/349/032/3600/front_de.124.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490323600', 'front_4003490323600'),
    ('Ehrmann', 'High Protein Chocolate Pudding', 'https://images.openfoodfacts.org/images/products/400/297/124/3703/front_de.192.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971243703', 'front_4002971243703'),
    ('Arla', 'Skyr Bourbon Vanille', 'https://images.openfoodfacts.org/images/products/401/624/103/0917/front_de.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 4016241030917', 'front_4016241030917'),
    ('Milbona', 'High Protein Chocolate Flavour Pudding', 'https://images.openfoodfacts.org/images/products/405/648/921/6162/front_en.329.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489216162', 'front_4056489216162'),
    ('Milsani', 'Joghurt mild 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/406/145/802/8820/front_de.111.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028820', 'front_4061458028820'),
    ('Aldi', 'A/Joghurt mild 3,5% Fett', 'https://images.openfoodfacts.org/images/products/406/145/802/8813/front_de.96.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028813', 'front_4061458028813'),
    ('Ehrmann', 'High-Protein-Pudding - Vanilla', 'https://images.openfoodfacts.org/images/products/400/297/124/3802/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971243802', 'front_4002971243802'),
    ('Milbona', 'Bio Fettarmer Joghurt mild', 'https://images.openfoodfacts.org/images/products/405/648/901/4003/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489014003', 'front_4056489014003'),
    ('Bauer', 'Kirsche', 'https://images.openfoodfacts.org/images/products/400/233/411/3032/front_de.63.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002334113032', 'front_4002334113032'),
    ('Milbona', 'Skyr Vanilla', 'https://images.openfoodfacts.org/images/products/405/648/911/8190/front_en.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118190', 'front_4056489118190'),
    ('Weihenstephan', 'Joghurt Natur 3,5 % Fett', 'https://images.openfoodfacts.org/images/products/400/845/201/1007/front_de.173.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452011007', 'front_4008452011007'),
    ('Lyttos', 'Griechischer Joghurt', 'https://images.openfoodfacts.org/images/products/406/145/824/4404/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458244404', 'front_4061458244404'),
    ('Lyttos', 'ALDI LYTTOS YOGRI nach griechischer Art 1kg 2.19€', 'https://images.openfoodfacts.org/images/products/406/145/901/5072/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459015072', 'front_4061459015072'),
    ('Müller', 'Joghurt mit der Ecke - Schoko Balls', 'https://images.openfoodfacts.org/images/products/000/004/025/5729/front_de.99.400.jpg', 'off_api', 'front', true, 'Front — EAN 40255729', 'front_40255729'),
    ('Dr. Oetker', 'High Protein Pudding Schoko', 'https://images.openfoodfacts.org/images/products/402/360/001/3474/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600013474', 'front_4023600013474'),
    ('Milbona', 'Bio Organic Cremiger Joghurt Mild (3,8% Fett)', 'https://images.openfoodfacts.org/images/products/405/648/901/8483/front_de.66.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489018483', 'front_4056489018483'),
    ('Milbona', 'Bio Speisequark Magerstufe', 'https://images.openfoodfacts.org/images/products/405/648/901/3082/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489013082', 'front_4056489013082'),
    ('Milbona', 'Skyr Erdbeere', 'https://images.openfoodfacts.org/images/products/405/648/911/8206/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118206', 'front_4056489118206'),
    ('Ehrmann', 'Chocolate & Topping with Protein', 'https://images.openfoodfacts.org/images/products/400/297/124/7503/front_en.119.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971247503', 'front_4002971247503'),
    ('Milbona', 'Joghurt 1,5%', 'https://images.openfoodfacts.org/images/products/405/648/915/0497/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489150497', 'front_4056489150497'),
    ('Milbona', 'Haselnuss Pudding', 'https://images.openfoodfacts.org/images/products/405/648/947/2261/front_en.163.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489472261', 'front_4056489472261'),
    ('Milsani', 'Joghurt mild 3,5% / 0x 500 gr / 3x 150 gr (Gebinde= 4x je 150 gr)', 'https://images.openfoodfacts.org/images/products/406/145/802/8806/front_de.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028806', 'front_4061458028806'),
    ('Elinas', 'Joghurt, Natur', 'https://images.openfoodfacts.org/images/products/400/349/003/2076/front_en.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490032076', 'front_4003490032076'),
    ('Ehrmann', 'High Protein Chocolate Mousse', 'https://images.openfoodfacts.org/images/products/400/297/128/3808/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971283808', 'front_4002971283808'),
    ('Ehrmann', 'Grand Dessert - Vanille', 'https://images.openfoodfacts.org/images/products/400/297/125/3108/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971253108', 'front_4002971253108'),
    ('Aldi', 'Speisequark Magerstufe', 'https://images.openfoodfacts.org/images/products/406/145/801/4151/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014151', 'front_4061458014151'),
    ('Milbona', 'Skyr Blueberry', 'https://images.openfoodfacts.org/images/products/405/648/911/8213/front_en.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489118213', 'front_4056489118213'),
    ('Milbona', 'Kefir', 'https://images.openfoodfacts.org/images/products/405/648/910/9570/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489109570', 'front_4056489109570'),
    ('Zott', 'Monte MAXI', 'https://images.openfoodfacts.org/images/products/401/450/003/6830/front_en.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014500036830', 'front_4014500036830'),
    ('Milsani', 'High-Protein-Pudding - Schoko', 'https://images.openfoodfacts.org/images/products/404/724/703/1080/front_en.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247031080', 'front_4047247031080'),
    ('My Vay', 'Sojaghurt', 'https://images.openfoodfacts.org/images/products/406/146/271/4443/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462714443', 'front_4061462714443'),
    ('Molkerei Gropper', 'High-Protein-Pudding - Schoko', 'https://images.openfoodfacts.org/images/products/400/098/035/7411/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000980357411', 'front_4000980357411'),
    ('Dr. Oetker', 'High Protein Pudding Bourbon-Vanille', 'https://images.openfoodfacts.org/images/products/402/360/001/3498/front_en.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600013498', 'front_4023600013498'),
    ('Almighurt', 'Joghurt mild, Stracciatella', 'https://images.openfoodfacts.org/images/products/400/297/184/0704/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971840704', 'front_4002971840704'),
    ('DMK', 'Speisequark Magerstufe', 'https://images.openfoodfacts.org/images/products/405/648/912/8212/front_en.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489128212', 'front_4056489128212'),
    ('Exquisa', 'Quark queso natural', 'https://images.openfoodfacts.org/images/products/000/004/019/3502/front_fr.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 40193502', 'front_40193502'),
    ('Ehrmann', 'Grand Dessert - Double Choc', 'https://images.openfoodfacts.org/images/products/400/297/125/3207/front_en.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971253207', 'front_4002971253207'),
    ('Ehrmann', 'High Protein Heidelbeere Joghurt-Erzeugnis', 'https://images.openfoodfacts.org/images/products/400/297/145/3201/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971453201', 'front_4002971453201'),
    ('Ehrmann', 'Almighurt - Kirsche', 'https://images.openfoodfacts.org/images/products/400/297/101/0206/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971010206', 'front_4002971010206'),
    ('Actimel', 'Danone Actimel® CLASSIC 8X100G', 'https://images.openfoodfacts.org/images/products/400/970/007/4720/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009700074720', 'front_4009700074720'),
    ('Ehrmann', 'Almighurt - Ananas', 'https://images.openfoodfacts.org/images/products/400/297/101/1906/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971011906', 'front_4002971011906'),
    ('Milsani', 'High-Protein-Mousse Vanillegeschmack', 'https://images.openfoodfacts.org/images/products/406/146/391/5016/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463915016', 'front_4061463915016'),
    ('Ehrmann', 'High-Protein-Pudding - Caramel Style', 'https://images.openfoodfacts.org/images/products/400/297/124/3901/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971243901', 'front_4002971243901'),
    ('Vemondo', 'Coconut Classic', 'https://images.openfoodfacts.org/images/products/405/648/941/2175/front_en.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489412175', 'front_4056489412175'),
    ('Lyttos', 'Yogri - Joghurterzeugnis nach griechischer Art', 'https://images.openfoodfacts.org/images/products/406/145/804/0839/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458040839', 'front_4061458040839'),
    ('Danone', 'Fruchtzwerge', 'https://images.openfoodfacts.org/images/products/400/970/003/5783/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009700035783', 'front_4009700035783'),
    ('Elinas', 'Joghurt nach griechischer Art - Honig', 'https://images.openfoodfacts.org/images/products/400/349/032/3617/front_de.100.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490323617', 'front_4003490323617'),
    ('Aldi', 'Speisequark 20% - Bio', 'https://images.openfoodfacts.org/images/products/406/145/801/4175/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014175', 'front_4061458014175'),
    ('Milbona', 'Bio fruchtjoghurt', 'https://images.openfoodfacts.org/images/products/405/648/901/4119/front_fr.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489014119', 'front_4056489014119'),
    ('Milchfrisch', 'High-Protein-Mousse - Schokolade', 'https://images.openfoodfacts.org/images/products/406/146/391/5030/front_en.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463915030', 'front_4061463915030'),
    ('Zott', 'Sahne-Joghurt mild Amarena-Kirsche', 'https://images.openfoodfacts.org/images/products/401/450/005/9570/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014500059570', 'front_4014500059570'),
    ('Weideglück', 'Bio Joghurt Mild', 'https://images.openfoodfacts.org/images/products/402/890/000/4351/front_en.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4028900004351', 'front_4028900004351'),
    ('Müller', 'Milchreis Schoko', 'https://images.openfoodfacts.org/images/products/000/004/025/5651/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 40255651', 'front_40255651'),
    ('Milbona', 'High Protein Joghurterzeugnis - Heidelbeere', 'https://images.openfoodfacts.org/images/products/405/648/925/8346/front_en.203.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489258346', 'front_4056489258346'),
    ('Dr. Oetker', 'Paula Pudding Vanille', 'https://images.openfoodfacts.org/images/products/402/360/001/5539/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600015539', 'front_4023600015539'),
    ('Landliebe', 'Joghurt mild 3,8%', 'https://images.openfoodfacts.org/images/products/406/751/700/1629/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067517001629', 'front_4067517001629'),
    ('Landliebe', 'Schokolade Sahne Pudding', 'https://images.openfoodfacts.org/images/products/406/751/700/1759/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067517001759', 'front_4067517001759'),
    ('Dogan', 'Ayran', 'https://images.openfoodfacts.org/images/products/403/254/903/9834/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4032549039834', 'front_4032549039834'),
    ('Weihenstephan', 'Joghurt mild 0,1% Fett', 'https://images.openfoodfacts.org/images/products/400/845/201/1960/front_en.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452011960', 'front_4008452011960'),
    ('Schwarzwaldmilch', 'BIO Joghurt', 'https://images.openfoodfacts.org/images/products/404/670/000/6184/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4046700006184', 'front_4046700006184'),
    ('Milsani', 'Sour Creme - cremig mild', 'https://images.openfoodfacts.org/images/products/406/145/801/4823/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458014823', 'front_4061458014823'),
    ('Seraphos', 'Joghurt Mild nach Griechischer ART', 'https://images.openfoodfacts.org/images/products/400/233/411/0802/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002334110802', 'front_4002334110802'),
    ('Ehrmann', 'Almighurt - Pfirsich-Maracuja', 'https://images.openfoodfacts.org/images/products/400/297/101/1401/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971011401', 'front_4002971011401'),
    ('Ehrmann', 'High Protein Mango', 'https://images.openfoodfacts.org/images/products/400/297/145/5205/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971455205', 'front_4002971455205'),
    ('Kaufland', 'Veganer cocogurt', 'https://images.openfoodfacts.org/images/products/406/336/724/7743/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367247743', 'front_4063367247743'),
    ('Aldi', 'Apfelmus', 'https://images.openfoodfacts.org/images/products/406/870/639/3075/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706393075', 'front_4068706393075'),
    ('Lidl', 'High protein vanilla pudding', 'https://images.openfoodfacts.org/images/products/405/648/921/6155/front_en.290.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489216155', 'front_4056489216155'),
    ('Gut & günstig', 'Joghurt Griechischer Art (pur)', 'https://images.openfoodfacts.org/images/products/405/648/902/5207/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489025207', 'front_4056489025207'),
    ('Zott', 'Zott Sahne Joghurt mild Erdbeere 4014500059617 Sahnejoghurt mild mit Erdbeeren. 10% Fett im Milchantei', 'https://images.openfoodfacts.org/images/products/401/450/005/9617/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014500059617', 'front_4014500059617'),
    ('Ehrmann', 'Almighurt - Himbeere', 'https://images.openfoodfacts.org/images/products/400/297/101/0404/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971010404', 'front_4002971010404'),
    ('Elinas', 'Joghurt nach griechischer Art Kirsche', 'https://images.openfoodfacts.org/images/products/400/349/032/3709/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003490323709', 'front_4003490323709'),
    ('Ehrmann', 'Almighurt - Zitrone', 'https://images.openfoodfacts.org/images/products/400/297/101/3801/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971013801', 'front_4002971013801'),
    ('Milbona', 'Joghurt Mild Vanille', 'https://images.openfoodfacts.org/images/products/405/648/901/4102/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489014102', 'front_4056489014102'),
    ('Milsani', 'Joghurt 3,5 %', 'https://images.openfoodfacts.org/images/products/406/146/348/0910/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463480910', 'front_4061463480910'),
    ('DMK', 'Speisequark', 'https://images.openfoodfacts.org/images/products/405/648/912/8151/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489128151', 'front_4056489128151'),
    ('Weideglück', 'Joghurt 3,5% Fett', 'https://images.openfoodfacts.org/images/products/402/890/000/4641/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4028900004641', 'front_4028900004641'),
    ('Milsani', 'Joghurt laktosefrei', 'https://images.openfoodfacts.org/images/products/406/145/802/0251/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458020251', 'front_4061458020251'),
    ('Weihenstephan', 'Rahmjoghurt Stracciatella', 'https://images.openfoodfacts.org/images/products/400/845/203/5539/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452035539', 'front_4008452035539')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Desserts & Ice Cream' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

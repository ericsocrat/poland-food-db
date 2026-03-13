-- PIPELINE (Coffee & Tea): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Coffee & Tea'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Nestlé', 'Caro Landkaffee extra kräftig', 'https://images.openfoodfacts.org/images/products/400/550/008/6062/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500086062', 'front_4005500086062'),
    ('Grana', 'Feiner Landkaffee Aus Vollem Korn Geröstet, Kaffee', 'https://images.openfoodfacts.org/images/products/400/904/110/1017/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009041101017', 'front_4009041101017'),
    ('Amaroy', 'Entkoffeiniert Premium Löslicher Kaffee', 'https://images.openfoodfacts.org/images/products/406/145/800/2875/front_es.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458002875', 'front_4061458002875'),
    ('Dallmayr', 'Kaffee - GOLD - löslicher Kaffee', 'https://images.openfoodfacts.org/images/products/400/816/703/7002/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008167037002', 'front_4008167037002'),
    ('Tchibo', 'Feine Milde Natur-mild lösl. Kaffee', 'https://images.openfoodfacts.org/images/products/404/623/476/7414/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4046234767414', 'front_4046234767414'),
    ('Jacobs', 'Krönung Classic ganze Bohnen', 'https://images.openfoodfacts.org/images/products/400/050/805/9087/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000508059087', 'front_4000508059087'),
    ('Nestlé', 'Nescafé Classic', 'https://images.openfoodfacts.org/images/products/400/550/000/5827/front_en.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500005827', 'front_4005500005827'),
    ('Lemonaid Beverages GmbH', 'Café Intención eclógico', 'https://images.openfoodfacts.org/images/products/400/658/102/0686/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006581020686', 'front_4006581020686'),
    ('Krüger', 'Cappuccino Schoko', 'https://images.openfoodfacts.org/images/products/405/270/006/8398/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4052700068398', 'front_4052700068398'),
    ('Tchibo', 'Barista Caffè Crema Bohnen', 'https://images.openfoodfacts.org/images/products/404/623/481/5948/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4046234815948', 'front_4046234815948'),
    ('Hearts', 'Cappuccino mit feiner Kakaonote', 'https://images.openfoodfacts.org/images/products/402/115/504/3809/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021155043809', 'front_4021155043809'),
    ('Aldi', 'Cappuccino Schoko', 'https://images.openfoodfacts.org/images/products/404/724/738/2144/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247382144', 'front_4047247382144'),
    ('Aldi', 'Family cappuccino', 'https://images.openfoodfacts.org/images/products/406/145/800/2899/front_fr.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458002899', 'front_4061458002899'),
    ('Ehrmann', 'Protein Caffe Latte', 'https://images.openfoodfacts.org/images/products/400/297/160/5501/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002971605501', 'front_4002971605501'),
    ('DmBio', 'Kaffee Klassik Gemahlen', 'https://images.openfoodfacts.org/images/products/405/817/248/7255/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172487255', 'front_4058172487255'),
    ('DmBio', 'Espresso gemahlen', 'https://images.openfoodfacts.org/images/products/405/817/248/7316/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172487316', 'front_4058172487316'),
    ('J.J. Darboven GmbH & Co KG', 'Café intención ecológico', 'https://images.openfoodfacts.org/images/products/400/658/109/2607/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006581092607', 'front_4006581092607'),
    ('Krüger', 'Cappuccino Stracciatella', 'https://images.openfoodfacts.org/images/products/405/270/007/3453/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4052700073453', 'front_4052700073453'),
    ('Ja!', 'Typ Cappuccino - weniger süß im Geschmack', 'https://images.openfoodfacts.org/images/products/433/725/638/2304/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256382304', 'front_4337256382304'),
    ('Dallmayr', 'Crema d''Oro Kaffee', 'https://images.openfoodfacts.org/images/products/400/816/715/2729/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008167152729', 'front_4008167152729'),
    ('Nestlé', 'Eiskaffee', 'https://images.openfoodfacts.org/images/products/400/550/027/4995/front_en.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500274995', 'front_4005500274995'),
    ('Dallmayr', 'Dallmayr Kaffee Prodomo Naturmild', 'https://images.openfoodfacts.org/images/products/400/816/710/3905/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008167103905', 'front_4008167103905'),
    ('Milbona', 'Latte macchiato lactose free', 'https://images.openfoodfacts.org/images/products/405/648/989/3882/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489893882', 'front_4056489893882'),
    ('Cafèt', 'Latte Macchiato weniger süß', 'https://images.openfoodfacts.org/images/products/000/004/241/3660/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 42413660', 'front_42413660'),
    ('Rewe', 'Extra löslicher Kaffee', 'https://images.openfoodfacts.org/images/products/438/884/001/8321/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4388840018321', 'front_4388840018321'),
    ('Dr. Oetker', 'High Protein Coffee Drink - Latte Macchiato Style', 'https://images.openfoodfacts.org/images/products/402/360/001/6482/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4023600016482', 'front_4023600016482'),
    ('Gut & Günstig', 'Latte Macchiato - weniger süß', 'https://images.openfoodfacts.org/images/products/431/150/169/7733/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501697733', 'front_4311501697733'),
    ('Edeka', 'Getränkepulver Typ Cappuccino (weniger süß)', 'https://images.openfoodfacts.org/images/products/431/150/148/2223/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501482223', 'front_4311501482223'),
    ('K Classic to go', 'Latte Espresso', 'https://images.openfoodfacts.org/images/products/406/336/748/0638/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367480638', 'front_4063367480638'),
    ('Senseo', 'Senseo Kaffeepads Caffè Pads', 'https://images.openfoodfacts.org/images/products/404/704/600/6098/front_fr.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047046006098', 'front_4047046006098'),
    ('Melitta', 'Kaffee Harmonie entkoffeiniert', 'https://images.openfoodfacts.org/images/products/400/272/000/0496/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002720000496', 'front_4002720000496'),
    ('Lidl Milbona', 'Latte Macchiato', 'https://images.openfoodfacts.org/images/products/405/648/988/4057/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489884057', 'front_4056489884057'),
    ('Naturata', 'Getreidekaffee Instant', 'https://images.openfoodfacts.org/images/products/402/429/744/0154/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4024297440154', 'front_4024297440154'),
    ('Dallmayr', 'Kaffee', 'https://images.openfoodfacts.org/images/products/400/816/710/2113/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008167102113', 'front_4008167102113'),
    ('Bellarom', 'Kaffeebohnen', 'https://images.openfoodfacts.org/images/products/405/648/957/6792/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489576792', 'front_4056489576792'),
    ('Weihenstephan', 'Rahmjoghurt Eiskaffee', 'https://images.openfoodfacts.org/images/products/400/845/204/3947/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452043947', 'front_4008452043947'),
    ('Nestlé', 'Nescafé Cappuccino - weniger süß', 'https://images.openfoodfacts.org/images/products/761/303/256/9556/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613032569556', 'front_7613032569556'),
    ('Cafèt', 'Löslicher Kaffee, kräftig', 'https://images.openfoodfacts.org/images/products/431/626/859/5322/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268595322', 'front_4316268595322'),
    ('Krüger', 'Cappuccino Fein & Cremig', 'https://images.openfoodfacts.org/images/products/405/270/008/5715/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4052700085715', 'front_4052700085715'),
    ('Moreno', 'Cappuccino Classico', 'https://images.openfoodfacts.org/images/products/404/724/738/2113/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247382113', 'front_4047247382113'),
    ('Coffee Pads', 'Senseo Pads Cappuccino Choco', 'https://images.openfoodfacts.org/images/products/404/704/600/5008/front_fr.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047046005008', 'front_4047046005008'),
    ('Krüger', 'Latte Macchiato', 'https://images.openfoodfacts.org/images/products/405/270/007/2159/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4052700072159', 'front_4052700072159'),
    ('Melitta', 'Barista Classic Crema', 'https://images.openfoodfacts.org/images/products/400/272/000/1219/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002720001219', 'front_4002720001219'),
    ('Eduscho', 'Café Crema (Kaffee)', 'https://images.openfoodfacts.org/images/products/406/144/522/6840/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061445226840', 'front_4061445226840'),
    ('Nescafé', 'Löslicher Kaffee entkof.- Fach 21', 'https://images.openfoodfacts.org/images/products/761/303/630/3910/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036303910', 'front_7613036303910'),
    ('Nescafé', 'Typ Cappuccino Weniger Süss', 'https://images.openfoodfacts.org/images/products/844/529/060/3708/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 8445290603708', 'front_8445290603708'),
    ('Cafèt', 'Typ Cappuccino weniger süß', 'https://images.openfoodfacts.org/images/products/431/626/866/8958/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268668958', 'front_4316268668958'),
    ('Alnatura', 'Kaffee löslich', 'https://images.openfoodfacts.org/images/products/410/442/022/4810/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420224810', 'front_4104420224810'),
    ('Jacobs', 'Krönung', 'https://images.openfoodfacts.org/images/products/871/100/050/9388/front_fr.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000509388', 'front_8711000509388'),
    ('Jacobs', 'Kaffee - Löslich', 'https://images.openfoodfacts.org/images/products/871/100/043/3270/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000433270', 'front_8711000433270'),
    ('Jacobs', 'Jacobs Kaffee-kapseln Lungo 6 Classico 20 Stück', 'https://images.openfoodfacts.org/images/products/871/100/037/1237/front_fr.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000371237', 'front_8711000371237'),
    ('Nestlé', 'Nescafé Cappuccino Weniger Süß', 'https://images.openfoodfacts.org/images/products/501/154/646/0437/front_fr.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5011546460437', 'front_5011546460437'),
    ('Unknown', 'Kaffee Classico Cappucino', 'https://images.openfoodfacts.org/images/products/406/145/800/3018/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458003018', 'front_4061458003018'),
    ('Cafèt', 'Latte Espresso', 'https://images.openfoodfacts.org/images/products/000/004/241/3677/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 42413677', 'front_42413677'),
    ('Bellarom', 'Family Cappuccino Chocolate', 'https://images.openfoodfacts.org/images/products/000/002/008/4035/front_fr.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 20084035', 'front_20084035'),
    ('Illy', 'Illy Classico 100% Arabica, 250g', 'https://images.openfoodfacts.org/images/products/800/375/390/0438/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8003753900438', 'front_8003753900438'),
    ('Jacobs', 'Classic 3in1', 'https://images.openfoodfacts.org/images/products/871/100/050/6325/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000506325', 'front_8711000506325'),
    ('Fairglobe', 'Café bio fairglobe', 'https://images.openfoodfacts.org/images/products/000/002/014/9499/front_fr.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 20149499', 'front_20149499'),
    ('Cafèt', 'Latte Cappuccino', 'https://images.openfoodfacts.org/images/products/000/004/241/3684/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 42413684', 'front_42413684'),
    ('Cafèt', 'Typ Cappuccino Classico', 'https://images.openfoodfacts.org/images/products/431/626/859/5407/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268595407', 'front_4316268595407'),
    ('Bellarom', 'Cappuccino Caramel', 'https://images.openfoodfacts.org/images/products/000/002/044/1463/front_de.767.400.jpg', 'off_api', 'front', true, 'Front — EAN 20441463', 'front_20441463'),
    ('Cafet', 'Family Cappucino Schoko', 'https://images.openfoodfacts.org/images/products/431/626/859/5360/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268595360', 'front_4316268595360'),
    ('Edeka', 'Cappuccino', 'https://images.openfoodfacts.org/images/products/431/150/148/2162/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501482162', 'front_4311501482162'),
    ('Lavazza', 'Café Bio-Organic', 'https://images.openfoodfacts.org/images/products/800/007/000/9745/front_fr.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 8000070009745', 'front_8000070009745'),
    ('Emmi', 'Caffè Latte', 'https://images.openfoodfacts.org/images/products/761/090/023/7654/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900237654', 'front_7610900237654'),
    ('Ja!', 'Cappuccino Family mit feiner Kakaonote', 'https://images.openfoodfacts.org/images/products/433/725/600/3896/front_xx.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256003896', 'front_4337256003896'),
    ('Gut & Günstig', 'Latte espresso', 'https://images.openfoodfacts.org/images/products/431/150/179/7471/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501797471', 'front_4311501797471'),
    ('Edeka Bio', 'Edeka Bio Espresso', 'https://images.openfoodfacts.org/images/products/431/150/138/7894/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501387894', 'front_4311501387894'),
    ('Emmi', 'Caffè Latte High Protein', 'https://images.openfoodfacts.org/images/products/761/090/023/9139/front_en.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900239139', 'front_7610900239139'),
    ('Gut & Günstig', 'Cold Latte Espresso', 'https://images.openfoodfacts.org/images/products/431/150/169/7856/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501697856', 'front_4311501697856'),
    ('Edeka Bio', 'Caffe Crema Kaffeepads', 'https://images.openfoodfacts.org/images/products/431/150/111/9365/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501119365', 'front_4311501119365'),
    ('Milbona', 'Cappucino', 'https://images.openfoodfacts.org/images/products/000/002/003/6850/front_en.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 20036850', 'front_20036850'),
    ('Edeka', 'Family Cappuccino Schoko', 'https://images.openfoodfacts.org/images/products/431/150/166/4698/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501664698', 'front_4311501664698'),
    ('Nescafe', 'Nescafé Classic Mild Instantkaffee', 'https://images.openfoodfacts.org/images/products/761/303/151/4793/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613031514793', 'front_7613031514793'),
    ('Cafet', 'Typ Cappuccino Vanille', 'https://images.openfoodfacts.org/images/products/431/626/859/5421/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268595421', 'front_4316268595421'),
    ('Tassimo', 'Tassimo Morning Café Strong XL', 'https://images.openfoodfacts.org/images/products/871/100/039/0757/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000390757', 'front_8711000390757'),
    ('Emmi', 'Caffè Latte Double Zero Macchiato', 'https://images.openfoodfacts.org/images/products/761/090/025/1759/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900251759', 'front_7610900251759'),
    ('Penny', 'Caffé Latte Espresso', 'https://images.openfoodfacts.org/images/products/000/002/070/5817/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 20705817', 'front_20705817'),
    ('K to go', 'Latte Macchiato', 'https://images.openfoodfacts.org/images/products/433/718/529/8066/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337185298066', 'front_4337185298066'),
    ('Jacobs', 'Kaffeesticks Espresso', 'https://images.openfoodfacts.org/images/products/871/100/050/6448/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000506448', 'front_8711000506448'),
    ('Nescafé', 'Nescafé Gold - Original', 'https://images.openfoodfacts.org/images/products/761/303/631/0116/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036310116', 'front_7613036310116'),
    ('Emmi', 'Caffè Latte Cappuccino', 'https://images.openfoodfacts.org/images/products/761/090/013/8906/front_en.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900138906', 'front_7610900138906'),
    ('Jacobs', 'Classic 3:1', 'https://images.openfoodfacts.org/images/products/871/100/049/6312/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000496312', 'front_8711000496312'),
    ('Nescafe', 'Nescafé 3 en 1 classique', 'https://images.openfoodfacts.org/images/products/761/303/690/0072/front_fr.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036900072', 'front_7613036900072'),
    ('Emmi', 'Emmi Caffè Latte Balance', 'https://images.openfoodfacts.org/images/products/761/090/020/5165/front_en.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900205165', 'front_7610900205165'),
    ('Tassimo', 'Jacobs Latte Macchiato Classico', 'https://images.openfoodfacts.org/images/products/871/100/050/4895/front_fr.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000504895', 'front_8711000504895'),
    ('Nestlé', 'Nescafé Gold Bio', 'https://images.openfoodfacts.org/images/products/761/303/691/4321/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036914321', 'front_7613036914321'),
    ('Penny Ready', 'Café Latte Espresso', 'https://images.openfoodfacts.org/images/products/000/002/071/5212/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 20715212', 'front_20715212'),
    ('Jacobs', 'Kaffee Espresso Kaffee', 'https://images.openfoodfacts.org/images/products/871/100/089/1735/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000891735', 'front_8711000891735'),
    ('Nescafé', 'Dolce Gusto Latte Macchiato Caramel', 'https://images.openfoodfacts.org/images/products/761/303/778/8884/front_lt.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037788884', 'front_7613037788884'),
    ('Jacobs', '3 in 1 Coffee With Caramel', 'https://images.openfoodfacts.org/images/products/871/100/049/6343/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000496343', 'front_8711000496343'),
    ('Jacobs Douwe Egberts Norge As', 'Caffè in grani classico', 'https://images.openfoodfacts.org/images/products/800/375/390/0520/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 8003753900520', 'front_8003753900520'),
    ('Illy', 'Tostato classico caffè macinato ideale per moka', 'https://images.openfoodfacts.org/images/products/800/375/391/5050/front_it.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 8003753915050', 'front_8003753915050'),
    ('Dolce Gusto', 'Latte Macchiato', 'https://images.openfoodfacts.org/images/products/761/303/749/1173/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613037491173', 'front_7613037491173'),
    ('Senseo', 'Kaffeepads Classic, XXL', 'https://images.openfoodfacts.org/images/products/871/100/084/9941/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000849941', 'front_8711000849941'),
    ('Emmi', 'Caffè Latte Expresso', 'https://images.openfoodfacts.org/images/products/761/090/013/8890/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 7610900138890', 'front_7610900138890'),
    ('Jacobs', 'Tassimo Jacobs Latte Macchiato Caramel', 'https://images.openfoodfacts.org/images/products/871/100/050/4802/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000504802', 'front_8711000504802'),
    ('Nescafé Dolce Gusto', 'Nescafe Dolce Gusto Chococino 16cap', 'https://images.openfoodfacts.org/images/products/761/303/569/0660/front_fr.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613035690660', 'front_7613035690660'),
    ('Jacobs', 'Cappuccino von Jacobs', 'https://images.openfoodfacts.org/images/products/871/100/052/5159/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 8711000525159', 'front_8711000525159'),
    ('Nescafe', '2 in 1', 'https://images.openfoodfacts.org/images/products/761/303/696/0298/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036960298', 'front_7613036960298')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Coffee & Tea' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

-- PIPELINE (Drinks): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Drinks'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('My Vay', 'Bio-Haferdrink ungesüßt', 'https://images.openfoodfacts.org/images/products/406/146/481/1218/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061464811218', 'front_4061464811218'),
    ('Rio d''Oro', 'Apfel-Direktsaft Naturtrüb', 'https://images.openfoodfacts.org/images/products/406/145/806/1117/front_de.186.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458061117', 'front_4061458061117'),
    ('Valensina', 'Frühstücksorange ohne Fruchtfleisch 1 Liter', 'https://images.openfoodfacts.org/images/products/400/949/102/2016/front_de.85.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009491022016', 'front_4009491022016'),
    ('Bionade', 'Bionade Naturtrübe Orange', 'https://images.openfoodfacts.org/images/products/401/447/228/0101/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014472280101', 'front_4014472280101'),
    ('A. Dohrn & A. Timm', 'Bio Apfelsaft Naturtrüb', 'https://images.openfoodfacts.org/images/products/405/648/902/7201/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489027201', 'front_4056489027201'),
    ('Valensina', 'Mildes-Frühstück Multi-Vitamin', 'https://images.openfoodfacts.org/images/products/400/949/102/2023/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009491022023', 'front_4009491022023'),
    ('EDEKA Gerolsteiner', 'Gerolsteiner Wasser Medium Kiste Medium mit wenig Kohlensäure (türkis) 12x1l 0.50€ ( Angebot ) 5.99€ + Pfand 3.30€', 'https://images.openfoodfacts.org/images/products/400/151/300/0620/front_de.66.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001513000620', 'front_4001513000620'),
    ('Rotbäckchen', 'Rotbäckchen Immunstark', 'https://images.openfoodfacts.org/images/products/400/419/100/8445/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004191008445', 'front_4004191008445'),
    ('Club Mate', 'Club-Mate Original', 'https://images.openfoodfacts.org/images/products/402/976/400/1807/front_en.227.400.jpg', 'off_api', 'front', true, 'Front — EAN 4029764001807', 'front_4029764001807'),
    ('Paulaner', 'Paulaner Spezi', 'https://images.openfoodfacts.org/images/products/406/660/060/3405/front_de.143.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600603405', 'front_4066600603405'),
    ('Lidl', 'Milch Mandel ohne Zucker', 'https://images.openfoodfacts.org/images/products/405/648/968/7641/front_en.106.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489687641', 'front_4056489687641'),
    ('Vemondo', 'Barista Oat Drink', 'https://images.openfoodfacts.org/images/products/405/648/998/9363/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489989363', 'front_4056489989363'),
    ('Gerolsteiner', 'Gerolsteiner Medium 1,5 Liter', 'https://images.openfoodfacts.org/images/products/400/151/300/7704/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001513007704', 'front_4001513007704'),
    ('Aldi', 'Bio-Haferdrink Natur', 'https://images.openfoodfacts.org/images/products/406/145/913/3271/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459133271', 'front_4061459133271'),
    ('Lidl', 'No Milk Hafer 3,5% Fett', 'https://images.openfoodfacts.org/images/products/405/648/970/8995/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489708995', 'front_4056489708995'),
    ('Gut & Günstig', 'Mineralwasser', 'https://images.openfoodfacts.org/images/products/000/004/055/4006/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 40554006', 'front_40554006'),
    ('Vemondo', 'No Milk Hafer 1,8% Fett', 'https://images.openfoodfacts.org/images/products/405/648/970/8988/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489708988', 'front_4056489708988'),
    ('Berief', 'BiO HAFER NATUR', 'https://images.openfoodfacts.org/images/products/400/479/001/7565/front_en.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004790017565', 'front_4004790017565'),
    ('Paulaner', 'Spezi Zero', 'https://images.openfoodfacts.org/images/products/406/660/020/4404/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600204404', 'front_4066600204404'),
    ('Vemondo', 'Bio Hafer', 'https://images.openfoodfacts.org/images/products/405/648/999/7511/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489997511', 'front_4056489997511'),
    ('Berief', 'Bio Hafer ohne Zucker', 'https://images.openfoodfacts.org/images/products/400/479/003/7358/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004790037358', 'front_4004790037358'),
    ('DmBio', 'Sojadrink natur', 'https://images.openfoodfacts.org/images/products/406/779/600/2089/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796002089', 'front_4067796002089'),
    ('Vemondo', 'High Protein Sojadrink', 'https://images.openfoodfacts.org/images/products/405/648/968/9720/front_en.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489689720', 'front_4056489689720'),
    ('Drinks & More GmbH & Co. KG', 'Knabe Malz', 'https://images.openfoodfacts.org/images/products/400/828/795/9192/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008287959192', 'front_4008287959192'),
    ('Rio d''Oro', 'Trauben-Direktsaft', 'https://images.openfoodfacts.org/images/products/406/145/802/8998/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458028998', 'front_4061458028998'),
    ('Berief', 'Bio Barista Hafer Natur', 'https://images.openfoodfacts.org/images/products/400/479/002/3764/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004790023764', 'front_4004790023764'),
    ('Vemondo', 'Boisson au cacao et à l''avoine', 'https://images.openfoodfacts.org/images/products/405/648/968/7610/front_en.97.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489687610', 'front_4056489687610'),
    ('DmBio', 'Mandel Drink', 'https://images.openfoodfacts.org/images/products/406/779/600/2065/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796002065', 'front_4067796002065'),
    ('Bionade', 'Bionade Holunder', 'https://images.openfoodfacts.org/images/products/401/447/200/2512/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014472002512', 'front_4014472002512'),
    ('Weihenstephan', 'Weihenstephan Milch 3.5%', 'https://images.openfoodfacts.org/images/products/400/845/201/0017/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008452010017', 'front_4008452010017'),
    ('Nestlé', 'Nescafé Classic', 'https://images.openfoodfacts.org/images/products/400/550/000/5827/front_en.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005500005827', 'front_4005500005827'),
    ('Berentzen', 'Mio Mio Mate Original', 'https://images.openfoodfacts.org/images/products/400/284/603/4504/front_de.85.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002846034504', 'front_4002846034504'),
    ('Pilsner Alkoholfrei', 'Jever Fun', 'https://images.openfoodfacts.org/images/products/400/894/819/1015/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008948191015', 'front_4008948191015'),
    ('PepsiCo', 'Rockstar Blueberry Pomegranate Acai Flavour', 'https://images.openfoodfacts.org/images/products/406/080/016/0683/front_de.101.400.jpg', 'off_api', 'front', true, 'Front — EAN 4060800160683', 'front_4060800160683'),
    ('Hohes C', 'Plus Sonnenvitamin D', 'https://images.openfoodfacts.org/images/products/404/851/774/6161/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517746161', 'front_4048517746161'),
    ('Berief', 'Bio Mandel ohne Zucker', 'https://images.openfoodfacts.org/images/products/400/479/003/5866/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004790035866', 'front_4004790035866'),
    ('Topsport', 'Isolight - Grapefruit-Citrus', 'https://images.openfoodfacts.org/images/products/406/145/989/0617/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459890617', 'front_4061459890617'),
    ('Rockstar', 'Peach', 'https://images.openfoodfacts.org/images/products/406/213/902/6210/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139026210', 'front_4062139026210'),
    ('Granini', 'Die Limo Limette-Zitrone', 'https://images.openfoodfacts.org/images/products/404/514/529/5108/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045145295108', 'front_4045145295108'),
    ('Take it veggie', 'Veganer Hafer Drink', 'https://images.openfoodfacts.org/images/products/406/336/741/0345/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367410345', 'front_4063367410345'),
    ('Paulaner', 'Spezi', 'https://images.openfoodfacts.org/images/products/406/660/030/0458/front_pt.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600300458', 'front_4066600300458'),
    ('Alpro', 'Geröstete Mandel Ohne Zucker', 'https://images.openfoodfacts.org/images/products/541/118/811/2709/front_en.927.400.jpg', 'off_api', 'front', true, 'Front — EAN 5411188112709', 'front_5411188112709'),
    ('Vemondo', 'Bio Hafer ohne Zucker', 'https://images.openfoodfacts.org/images/products/405/648/998/3477/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489983477', 'front_4056489983477'),
    ('Pepsi', 'Pepsi Zero Zucker', 'https://images.openfoodfacts.org/images/products/406/213/902/5299/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139025299', 'front_4062139025299'),
    ('Jever', 'Jever fun 4008948194016 Pilsener alkoholfrei', 'https://images.openfoodfacts.org/images/products/400/894/819/4016/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008948194016', 'front_4008948194016'),
    ('Valensia', 'Orange ohne Fruchtfleisch', 'https://images.openfoodfacts.org/images/products/400/949/102/1354/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009491021354', 'front_4009491021354'),
    ('DmBio', 'Oat Drink - Sugarfree', 'https://images.openfoodfacts.org/images/products/406/779/600/0207/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796000207', 'front_4067796000207'),
    ('Red Bull', 'Kokos Blaubeere (Weiß)', 'https://images.openfoodfacts.org/images/products/000/009/043/3627/front_de.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 90433627', 'front_90433627'),
    ('Vemondo', 'High protein soy with chocolate taste', 'https://images.openfoodfacts.org/images/products/405/648/974/9455/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489749455', 'front_4056489749455'),
    ('Naturalis', 'Getränke - Mineralwasser - Classic', 'https://images.openfoodfacts.org/images/products/000/004/228/7995/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 42287995', 'front_42287995'),
    ('Vly', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 'https://images.openfoodfacts.org/images/products/428/000/193/9042/front_de.84.400.jpg', 'off_api', 'front', true, 'Front — EAN 4280001939042', 'front_4280001939042'),
    ('Teekanne', 'Teebeutel Italienische Limone', 'https://images.openfoodfacts.org/images/products/400/930/001/4492/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009300014492', 'front_4009300014492'),
    ('Hohes C', 'Saft Plus Eisen', 'https://images.openfoodfacts.org/images/products/404/851/774/6086/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517746086', 'front_4048517746086'),
    ('Pepsi', 'Pepsi', 'https://images.openfoodfacts.org/images/products/406/213/902/5251/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139025251', 'front_4062139025251'),
    ('Quellbrunn', 'Mineralwasser Naturell', 'https://images.openfoodfacts.org/images/products/406/145/825/2690/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458252690', 'front_4061458252690'),
    ('Granini', 'Multivitaminsaft', 'https://images.openfoodfacts.org/images/products/404/851/774/2040/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517742040', 'front_4048517742040'),
    ('Schwip schwap', 'Schwip Schwap Zero', 'https://images.openfoodfacts.org/images/products/406/213/902/5473/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139025473', 'front_4062139025473'),
    ('Adelholzener', 'Wasser naturell', 'https://images.openfoodfacts.org/images/products/400/590/600/3724/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005906003724', 'front_4005906003724'),
    ('Capri Sun GmbH', 'Capri-Sonne - Multivitamin', 'https://images.openfoodfacts.org/images/products/400/017/703/2695/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000177032695', 'front_4000177032695'),
    ('Alpro', 'Alpro Sojadrink, Ungesüßt 1L', 'https://images.openfoodfacts.org/images/products/541/118/811/5496/front_en.163.400.jpg', 'off_api', 'front', true, 'Front — EAN 5411188115496', 'front_5411188115496'),
    ('Edeka', 'Direktsaft Apfel, naturtrüb, EDEKA', 'https://images.openfoodfacts.org/images/products/431/150/133/9190/front_de.74.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501339190', 'front_4311501339190'),
    ('EDEKA Bio', 'Mandeldrink ungesüßt', 'https://images.openfoodfacts.org/images/products/431/150/172/0745/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501720745', 'front_4311501720745'),
    ('DmBio', 'Haferdrink Natur', 'https://images.openfoodfacts.org/images/products/406/779/600/2003/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796002003', 'front_4067796002003'),
    ('Lieblings', 'Apfel-Direktsaft, naturtrüb, Lieblings', 'https://images.openfoodfacts.org/images/products/431/626/860/9784/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268609784', 'front_4316268609784'),
    ('Adelholzener', 'Mineralwasser Sanft', 'https://images.openfoodfacts.org/images/products/400/590/600/3717/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005906003717', 'front_4005906003717'),
    ('Mio Mio', 'Mio Mio Mate Ginger', 'https://images.openfoodfacts.org/images/products/400/284/603/4603/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002846034603', 'front_4002846034603'),
    ('Vemondo', 'Bio-Haferfrink ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/405/648/998/9356/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489989356', 'front_4056489989356'),
    ('Quellbrunn', 'Sprudel / Mineralwasser', 'https://images.openfoodfacts.org/images/products/406/145/825/2676/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458252676', 'front_4061458252676'),
    ('Hohes C', 'Plus Imun', 'https://images.openfoodfacts.org/images/products/404/851/774/6482/front_en.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517746482', 'front_4048517746482'),
    ('Lipton', 'Ice tea Pfirsich Zero Zucker', 'https://images.openfoodfacts.org/images/products/406/213/900/9978/front_en.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062139009978', 'front_4062139009978'),
    ('Hohes C', 'Multivitamin', 'https://images.openfoodfacts.org/images/products/404/851/770/1832/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517701832', 'front_4048517701832'),
    ('Hohes C', 'Supershot Immun', 'https://images.openfoodfacts.org/images/products/404/851/768/9802/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4048517689802', 'front_4048517689802'),
    ('Gerolsteiner', 'Mineralwasser Naturell', 'https://images.openfoodfacts.org/images/products/400/151/300/4161/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001513004161', 'front_4001513004161'),
    ('K-take it veggie', 'K-take it veggie Bio Mandeldrink ungesüßt', 'https://images.openfoodfacts.org/images/products/433/718/583/2819/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337185832819', 'front_4337185832819'),
    ('Albi', 'Orangensaft', 'https://images.openfoodfacts.org/images/products/400/324/090/0006/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003240900006', 'front_4003240900006'),
    ('Natumi', 'Hafer Natural', 'https://images.openfoodfacts.org/images/products/403/837/502/4396/front_de.126.400.jpg', 'off_api', 'front', true, 'Front — EAN 4038375024396', 'front_4038375024396'),
    ('Adelholzener', 'Active O2 Apfel Kiwi', 'https://images.openfoodfacts.org/images/products/400/590/627/4650/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005906274650', 'front_4005906274650'),
    ('Quellbrunn', 'Naturell Mierbachquelle ohne Kohlensäure', 'https://images.openfoodfacts.org/images/products/000/004/214/2195/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 42142195', 'front_42142195'),
    ('Müller', 'Müllermilch - Bananen-Geschmack', 'https://images.openfoodfacts.org/images/products/000/004/244/8860/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 42448860', 'front_42448860'),
    ('Pfanner', 'Der Grüne', 'https://images.openfoodfacts.org/images/products/900/690/001/4858/front_de.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 9006900014858', 'front_9006900014858'),
    ('BioBio', 'Mandeldrink ungesüßt', 'https://images.openfoodfacts.org/images/products/431/626/870/5660/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268705660', 'front_4316268705660'),
    ('Volvic', 'Wasser Volvic naturelle', 'https://images.openfoodfacts.org/images/products/305/764/018/6158/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 3057640186158', 'front_3057640186158'),
    ('Coca-Cola', 'Coca-Cola Original', 'https://images.openfoodfacts.org/images/products/500/011/254/6415/front_de.137.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000112546415', 'front_5000112546415'),
    ('Oatly', 'Haferdrink Barista', 'https://images.openfoodfacts.org/images/products/739/437/661/6501/front_en.190.400.jpg', 'off_api', 'front', true, 'Front — EAN 7394376616501', 'front_7394376616501'),
    ('Coca-Cola', 'Coca-Cola 1 Liter', 'https://images.openfoodfacts.org/images/products/544/900/001/7888/front_de.147.400.jpg', 'off_api', 'front', true, 'Front — EAN 5449000017888', 'front_5449000017888'),
    ('Red Bull', 'Red Bull Energydrink Classic', 'https://images.openfoodfacts.org/images/products/000/009/016/2565/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 90162565', 'front_90162565'),
    ('Monster Energy', 'Monster Energy Ultra', 'https://images.openfoodfacts.org/images/products/506/033/750/0401/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 5060337500401', 'front_5060337500401'),
    ('Coca-Cola', 'Coca-Cola Zero', 'https://images.openfoodfacts.org/images/products/500/011/257/6009/front_de.108.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000112576009', 'front_5000112576009'),
    ('Alpro', 'Alpro Not Milk', 'https://images.openfoodfacts.org/images/products/541/118/813/4985/front_en.131.400.jpg', 'off_api', 'front', true, 'Front — EAN 5411188134985', 'front_5411188134985'),
    ('Saskia', 'Mineralwasser still 6 x 1,5 L', 'https://images.openfoodfacts.org/images/products/000/004/214/3819/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 42143819', 'front_42143819'),
    ('Cola', 'Coca-Cola Zero', 'https://images.openfoodfacts.org/images/products/544/900/013/4264/front_en.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 5449000134264', 'front_5449000134264'),
    ('Coca-Cola', 'Cola Zero', 'https://images.openfoodfacts.org/images/products/500/011/260/4450/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000112604450', 'front_5000112604450'),
    ('Coca Cola', 'Coca Cola', 'https://images.openfoodfacts.org/images/products/500/011/260/2029/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5000112602029', 'front_5000112602029'),
    ('Saskia', 'Mineralwasser still', 'https://images.openfoodfacts.org/images/products/000/004/237/6101/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 42376101', 'front_42376101'),
    ('Fritz-kola', 'Fritz-kola Original', 'https://images.openfoodfacts.org/images/products/426/010/722/0015/front_en.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260107220015', 'front_4260107220015')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Drinks' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

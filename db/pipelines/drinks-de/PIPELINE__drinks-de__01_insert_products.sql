-- PIPELINE (Drinks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Drinks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061464811218', '4061458061117', '4009491022016', '4014472280101', '4056489027201', '4009491022023', '4001513000620', '4004191008445', '4029764001807', '4066600603405', '4056489687641', '4056489989363', '4001513007704', '4061459133271', '4056489708995', '40554006', '4056489708988', '4004790017565', '4066600204404', '4056489997511', '4004790037358', '4067796002089', '4056489689720', '4008287959192', '4061458028998', '4004790023764', '4056489687610', '4067796002065', '4014472002512', '4008452010017', '4005500005827', '4002846034504', '4008948191015', '4060800160683', '4048517746161', '4004790035866', '4061459890617', '4062139026210', '4045145295108', '4063367410345', '4066600300458', '5411188112709', '4056489983477', '4062139025299', '4008948194016', '4009491021354', '4067796000207', '90433627', '4056489749455', '42287995', '4280001939042', '4009300014492', '4048517746086', '4062139025251', '4061458252690', '4048517742040', '4062139025473', '4005906003724', '4000177032695', '5411188115496', '4311501339190', '4311501720745', '4067796002003', '4316268609784', '4005906003717', '4002846034603', '4056489989356', '4061458252676', '4048517746482', '4062139009978', '4048517701832', '4048517689802', '4001513004161', '4337185832819', '4003240900006', '4038375024396', '4005906274650', '42142195', '42448860', '9006900014858', '4316268705660', '3057640186158', '5000112546415', '7394376616501', '5449000017888', '90162565', '5060337500401', '5000112576009', '5411188134985', '42143819', '5449000134264', '5000112604450', '5000112602029', '42376101', '4260107220015')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'My Vay', 'Grocery', 'Drinks', 'Bio-Haferdrink ungesüßt', 'not-applicable', 'Aldi', 'none', '4061464811218'),
  ('DE', 'Rio d''Oro', 'Grocery', 'Drinks', 'Apfel-Direktsaft Naturtrüb', 'not-applicable', 'Aldi', 'none', '4061458061117'),
  ('DE', 'Valensina', 'Grocery', 'Drinks', 'Frühstücksorange ohne Fruchtfleisch 1 Liter', 'not-applicable', 'Lidl', 'none', '4009491022016'),
  ('DE', 'Bionade', 'Grocery', 'Drinks', 'Bionade Naturtrübe Orange', 'not-applicable', null, 'none', '4014472280101'),
  ('DE', 'A. Dohrn & A. Timm', 'Grocery', 'Drinks', 'Bio Apfelsaft Naturtrüb', 'not-applicable', 'Lidl', 'none', '4056489027201'),
  ('DE', 'Valensina', 'Grocery', 'Drinks', 'Mildes-Frühstück Multi-Vitamin', 'not-applicable', null, 'none', '4009491022023'),
  ('DE', 'EDEKA Gerolsteiner', 'Grocery', 'Drinks', 'Gerolsteiner Wasser Medium Kiste Medium mit wenig Kohlensäure (türkis) 12x1l 0.50€ ( Angebot ) 5.99€ + Pfand 3.30€', 'not-applicable', null, 'none', '4001513000620'),
  ('DE', 'Rotbäckchen', 'Grocery', 'Drinks', 'Rotbäckchen Immunstark', 'not-applicable', null, 'none', '4004191008445'),
  ('DE', 'Club Mate', 'Grocery', 'Drinks', 'Club-Mate Original', 'not-applicable', 'Carrefour', 'none', '4029764001807'),
  ('DE', 'Paulaner', 'Grocery', 'Drinks', 'Paulaner Spezi', 'not-applicable', 'Kaufland', 'none', '4066600603405'),
  ('DE', 'Lidl', 'Grocery', 'Drinks', 'Milch Mandel ohne Zucker', 'not-applicable', 'Lidl', 'none', '4056489687641'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Barista Oat Drink', 'not-applicable', 'Lidl', 'none', '4056489989363'),
  ('DE', 'Gerolsteiner', 'Grocery', 'Drinks', 'Gerolsteiner Medium 1,5 Liter', 'not-applicable', 'Lidl', 'none', '4001513007704'),
  ('DE', 'Aldi', 'Grocery', 'Drinks', 'Bio-Haferdrink Natur', 'not-applicable', 'Aldi', 'none', '4061459133271'),
  ('DE', 'Lidl', 'Grocery', 'Drinks', 'No Milk Hafer 3,5% Fett', 'not-applicable', 'Lidl', 'none', '4056489708995'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Drinks', 'Mineralwasser', 'not-applicable', null, 'none', '40554006'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'No Milk Hafer 1,8% Fett', 'not-applicable', 'Lidl', 'none', '4056489708988'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'BiO HAFER NATUR', 'not-applicable', null, 'none', '4004790017565'),
  ('DE', 'Paulaner', 'Grocery', 'Drinks', 'Spezi Zero', 'not-applicable', null, 'none', '4066600204404'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Bio Hafer', 'not-applicable', 'Lidl', 'none', '4056489997511'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'Bio Hafer ohne Zucker', 'not-applicable', null, 'none', '4004790037358'),
  ('DE', 'DmBio', 'Grocery', 'Drinks', 'Sojadrink natur', 'not-applicable', null, 'none', '4067796002089'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'High Protein Sojadrink', 'not-applicable', 'Lidl', 'none', '4056489689720'),
  ('DE', 'Drinks & More GmbH & Co. KG', 'Grocery', 'Drinks', 'Knabe Malz', 'not-applicable', null, 'none', '4008287959192'),
  ('DE', 'Rio d''Oro', 'Grocery', 'Drinks', 'Trauben-Direktsaft', 'not-applicable', 'Aldi', 'none', '4061458028998'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'Bio Barista Hafer Natur', 'not-applicable', null, 'none', '4004790023764'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Boisson au cacao et à l''avoine', 'not-applicable', 'Lidl', 'none', '4056489687610'),
  ('DE', 'DmBio', 'Grocery', 'Drinks', 'Mandel Drink', 'not-applicable', null, 'none', '4067796002065'),
  ('DE', 'Bionade', 'Grocery', 'Drinks', 'Bionade Holunder', 'not-applicable', 'Kaufland', 'none', '4014472002512'),
  ('DE', 'Weihenstephan', 'Grocery', 'Drinks', 'Weihenstephan Milch 3.5%', 'not-applicable', 'Lidl', 'none', '4008452010017'),
  ('DE', 'Nestlé', 'Grocery', 'Drinks', 'Nescafé Classic', 'not-applicable', 'Lidl', 'none', '4005500005827'),
  ('DE', 'Berentzen', 'Grocery', 'Drinks', 'Mio Mio Mate Original', 'not-applicable', 'Kaufland', 'none', '4002846034504'),
  ('DE', 'Pilsner Alkoholfrei', 'Grocery', 'Drinks', 'Jever Fun', 'not-applicable', null, 'none', '4008948191015'),
  ('DE', 'PepsiCo', 'Grocery', 'Drinks', 'Rockstar Blueberry Pomegranate Acai Flavour', 'not-applicable', 'Penny', 'none', '4060800160683'),
  ('DE', 'Hohes C', 'Grocery', 'Drinks', 'Plus Sonnenvitamin D', 'not-applicable', null, 'none', '4048517746161'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'Bio Mandel ohne Zucker', 'not-applicable', null, 'none', '4004790035866'),
  ('DE', 'Topsport', 'Grocery', 'Drinks', 'Isolight - Grapefruit-Citrus', 'not-applicable', 'Aldi', 'none', '4061459890617'),
  ('DE', 'Rockstar', 'Grocery', 'Drinks', 'Peach', 'not-applicable', 'Penny', 'none', '4062139026210'),
  ('DE', 'Granini', 'Grocery', 'Drinks', 'Die Limo Limette-Zitrone', 'not-applicable', 'Lidl', 'none', '4045145295108'),
  ('DE', 'Take it veggie', 'Grocery', 'Drinks', 'Veganer Hafer Drink', 'not-applicable', 'Kaufland', 'none', '4063367410345'),
  ('DE', 'Paulaner', 'Grocery', 'Drinks', 'Spezi', 'not-applicable', 'Lidl', 'none', '4066600300458'),
  ('DE', 'Alpro', 'Grocery', 'Drinks', 'Geröstete Mandel Ohne Zucker', 'not-applicable', 'Carrefour', 'none', '5411188112709'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Bio Hafer ohne Zucker', 'not-applicable', null, 'none', '4056489983477'),
  ('DE', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi Zero Zucker', 'not-applicable', null, 'none', '4062139025299'),
  ('DE', 'Jever', 'Grocery', 'Drinks', 'Jever fun 4008948194016 Pilsener alkoholfrei', 'not-applicable', null, 'none', '4008948194016'),
  ('DE', 'Valensia', 'Grocery', 'Drinks', 'Orange ohne Fruchtfleisch', 'not-applicable', null, 'none', '4009491021354'),
  ('DE', 'DmBio', 'Grocery', 'Drinks', 'Oat Drink - Sugarfree', 'not-applicable', null, 'none', '4067796000207'),
  ('DE', 'Red Bull', 'Grocery', 'Drinks', 'Kokos Blaubeere (Weiß)', 'not-applicable', 'Lidl', 'none', '90433627'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'High protein soy with chocolate taste', 'not-applicable', null, 'none', '4056489749455'),
  ('DE', 'Naturalis', 'Grocery', 'Drinks', 'Getränke - Mineralwasser - Classic', 'not-applicable', 'Netto', 'none', '42287995'),
  ('DE', 'Vly', 'Grocery', 'Drinks', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 'not-applicable', null, 'none', '4280001939042'),
  ('DE', 'Teekanne', 'Grocery', 'Drinks', 'Teebeutel Italienische Limone', 'not-applicable', null, 'none', '4009300014492'),
  ('DE', 'Hohes C', 'Grocery', 'Drinks', 'Saft Plus Eisen', 'not-applicable', null, 'none', '4048517746086'),
  ('DE', 'Pepsi', 'Grocery', 'Drinks', 'Pepsi', 'not-applicable', null, 'none', '4062139025251'),
  ('DE', 'Quellbrunn', 'Grocery', 'Drinks', 'Mineralwasser Naturell', 'not-applicable', null, 'none', '4061458252690'),
  ('DE', 'Granini', 'Grocery', 'Drinks', 'Multivitaminsaft', 'not-applicable', null, 'none', '4048517742040'),
  ('DE', 'Schwip schwap', 'Grocery', 'Drinks', 'Schwip Schwap Zero', 'not-applicable', null, 'none', '4062139025473'),
  ('DE', 'Adelholzener', 'Grocery', 'Drinks', 'Wasser naturell', 'not-applicable', null, 'none', '4005906003724'),
  ('DE', 'Capri Sun GmbH', 'Grocery', 'Drinks', 'Capri-Sonne - Multivitamin', 'not-applicable', null, 'none', '4000177032695'),
  ('DE', 'Alpro', 'Grocery', 'Drinks', 'Alpro Sojadrink, Ungesüßt 1L', 'not-applicable', 'Kaufland', 'none', '5411188115496'),
  ('DE', 'Edeka', 'Grocery', 'Drinks', 'Direktsaft Apfel, naturtrüb, EDEKA', 'not-applicable', null, 'none', '4311501339190'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Drinks', 'Mandeldrink ungesüßt', 'not-applicable', null, 'none', '4311501720745'),
  ('DE', 'DmBio', 'Grocery', 'Drinks', 'Haferdrink Natur', 'not-applicable', null, 'none', '4067796002003'),
  ('DE', 'Lieblings', 'Grocery', 'Drinks', 'Apfel-Direktsaft, naturtrüb, Lieblings', 'not-applicable', 'Netto', 'none', '4316268609784'),
  ('DE', 'Adelholzener', 'Grocery', 'Drinks', 'Mineralwasser Sanft', 'not-applicable', null, 'none', '4005906003717'),
  ('DE', 'Mio Mio', 'Grocery', 'Drinks', 'Mio Mio Mate Ginger', 'not-applicable', 'Dealz', 'none', '4002846034603'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Bio-Haferfrink ohne Zuckerzusatz', 'not-applicable', null, 'none', '4056489989356'),
  ('DE', 'Quellbrunn', 'Grocery', 'Drinks', 'Sprudel / Mineralwasser', 'not-applicable', null, 'none', '4061458252676'),
  ('DE', 'Hohes C', 'Grocery', 'Drinks', 'Plus Imun', 'not-applicable', null, 'none', '4048517746482'),
  ('DE', 'Lipton', 'Grocery', 'Drinks', 'Ice tea Pfirsich Zero Zucker', 'not-applicable', null, 'none', '4062139009978'),
  ('DE', 'Hohes C', 'Grocery', 'Drinks', 'Multivitamin', 'not-applicable', null, 'none', '4048517701832'),
  ('DE', 'Hohes C', 'Grocery', 'Drinks', 'Supershot Immun', 'not-applicable', null, 'none', '4048517689802'),
  ('DE', 'Gerolsteiner', 'Grocery', 'Drinks', 'Mineralwasser Naturell', 'not-applicable', null, 'none', '4001513004161'),
  ('DE', 'K-take it veggie', 'Grocery', 'Drinks', 'K-take it veggie Bio Mandeldrink ungesüßt', 'not-applicable', 'Kaufland', 'none', '4337185832819'),
  ('DE', 'Albi', 'Grocery', 'Drinks', 'Orangensaft', 'not-applicable', null, 'none', '4003240900006'),
  ('DE', 'Natumi', 'Grocery', 'Drinks', 'Hafer Natural', 'not-applicable', null, 'none', '4038375024396'),
  ('DE', 'Adelholzener', 'Grocery', 'Drinks', 'Active O2 Apfel Kiwi', 'not-applicable', null, 'none', '4005906274650'),
  ('DE', 'Quellbrunn', 'Grocery', 'Drinks', 'Naturell Mierbachquelle ohne Kohlensäure', 'not-applicable', null, 'none', '42142195'),
  ('DE', 'Müller', 'Grocery', 'Drinks', 'Müllermilch - Bananen-Geschmack', 'not-applicable', null, 'none', '42448860'),
  ('DE', 'Pfanner', 'Grocery', 'Drinks', 'Der Grüne', 'not-applicable', null, 'none', '9006900014858'),
  ('DE', 'BioBio', 'Grocery', 'Drinks', 'Mandeldrink ungesüßt', 'not-applicable', null, 'none', '4316268705660'),
  ('DE', 'Volvic', 'Grocery', 'Drinks', 'Wasser Volvic naturelle', 'not-applicable', 'Lidl', 'none', '3057640186158'),
  ('DE', 'Coca-Cola', 'Grocery', 'Drinks', 'Coca-Cola Original', 'not-applicable', 'Lidl', 'none', '5000112546415'),
  ('DE', 'Oatly', 'Grocery', 'Drinks', 'Haferdrink Barista', 'not-applicable', 'Kaufland', 'none', '7394376616501'),
  ('DE', 'Coca-Cola', 'Grocery', 'Drinks', 'Coca-Cola 1 Liter', 'not-applicable', null, 'none', '5449000017888'),
  ('DE', 'Red Bull', 'Grocery', 'Drinks', 'Red Bull Energydrink Classic', 'not-applicable', 'Lidl', 'none', '90162565'),
  ('DE', 'Monster Energy', 'Grocery', 'Drinks', 'Monster Energy Ultra', 'not-applicable', 'Lidl', 'none', '5060337500401'),
  ('DE', 'Coca-Cola', 'Grocery', 'Drinks', 'Coca-Cola Zero', 'not-applicable', 'Lidl', 'none', '5000112576009'),
  ('DE', 'Alpro', 'Grocery', 'Drinks', 'Alpro Not Milk', 'not-applicable', null, 'none', '5411188134985'),
  ('DE', 'Saskia', 'Grocery', 'Drinks', 'Mineralwasser still 6 x 1,5 L', 'not-applicable', 'Lidl', 'none', '42143819'),
  ('DE', 'Cola', 'Grocery', 'Drinks', 'Coca-Cola Zero', 'not-applicable', 'Kaufland', 'none', '5449000134264'),
  ('DE', 'Coca-Cola', 'Grocery', 'Drinks', 'Cola Zero', 'not-applicable', 'Netto', 'none', '5000112604450'),
  ('DE', 'Coca Cola', 'Grocery', 'Drinks', 'Coca Cola', 'not-applicable', 'Penny', 'none', '5000112602029'),
  ('DE', 'Saskia', 'Grocery', 'Drinks', 'Mineralwasser still', 'not-applicable', 'Lidl', 'none', '42376101'),
  ('DE', 'Fritz-kola', 'Grocery', 'Drinks', 'Fritz-kola Original', 'not-applicable', null, 'none', '4260107220015')
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
where country = 'DE' and category = 'Drinks'
  and is_deprecated is not true
  and product_name not in ('Bio-Haferdrink ungesüßt', 'Apfel-Direktsaft Naturtrüb', 'Frühstücksorange ohne Fruchtfleisch 1 Liter', 'Bionade Naturtrübe Orange', 'Bio Apfelsaft Naturtrüb', 'Mildes-Frühstück Multi-Vitamin', 'Gerolsteiner Wasser Medium Kiste Medium mit wenig Kohlensäure (türkis) 12x1l 0.50€ ( Angebot ) 5.99€ + Pfand 3.30€', 'Rotbäckchen Immunstark', 'Club-Mate Original', 'Paulaner Spezi', 'Milch Mandel ohne Zucker', 'Barista Oat Drink', 'Gerolsteiner Medium 1,5 Liter', 'Bio-Haferdrink Natur', 'No Milk Hafer 3,5% Fett', 'Mineralwasser', 'No Milk Hafer 1,8% Fett', 'BiO HAFER NATUR', 'Spezi Zero', 'Bio Hafer', 'Bio Hafer ohne Zucker', 'Sojadrink natur', 'High Protein Sojadrink', 'Knabe Malz', 'Trauben-Direktsaft', 'Bio Barista Hafer Natur', 'Boisson au cacao et à l''avoine', 'Mandel Drink', 'Bionade Holunder', 'Weihenstephan Milch 3.5%', 'Nescafé Classic', 'Mio Mio Mate Original', 'Jever Fun', 'Rockstar Blueberry Pomegranate Acai Flavour', 'Plus Sonnenvitamin D', 'Bio Mandel ohne Zucker', 'Isolight - Grapefruit-Citrus', 'Peach', 'Die Limo Limette-Zitrone', 'Veganer Hafer Drink', 'Spezi', 'Geröstete Mandel Ohne Zucker', 'Bio Hafer ohne Zucker', 'Pepsi Zero Zucker', 'Jever fun 4008948194016 Pilsener alkoholfrei', 'Orange ohne Fruchtfleisch', 'Oat Drink - Sugarfree', 'Kokos Blaubeere (Weiß)', 'High protein soy with chocolate taste', 'Getränke - Mineralwasser - Classic', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 'Teebeutel Italienische Limone', 'Saft Plus Eisen', 'Pepsi', 'Mineralwasser Naturell', 'Multivitaminsaft', 'Schwip Schwap Zero', 'Wasser naturell', 'Capri-Sonne - Multivitamin', 'Alpro Sojadrink, Ungesüßt 1L', 'Direktsaft Apfel, naturtrüb, EDEKA', 'Mandeldrink ungesüßt', 'Haferdrink Natur', 'Apfel-Direktsaft, naturtrüb, Lieblings', 'Mineralwasser Sanft', 'Mio Mio Mate Ginger', 'Bio-Haferfrink ohne Zuckerzusatz', 'Sprudel / Mineralwasser', 'Plus Imun', 'Ice tea Pfirsich Zero Zucker', 'Multivitamin', 'Supershot Immun', 'Mineralwasser Naturell', 'K-take it veggie Bio Mandeldrink ungesüßt', 'Orangensaft', 'Hafer Natural', 'Active O2 Apfel Kiwi', 'Naturell Mierbachquelle ohne Kohlensäure', 'Müllermilch - Bananen-Geschmack', 'Der Grüne', 'Mandeldrink ungesüßt', 'Wasser Volvic naturelle', 'Coca-Cola Original', 'Haferdrink Barista', 'Coca-Cola 1 Liter', 'Red Bull Energydrink Classic', 'Monster Energy Ultra', 'Coca-Cola Zero', 'Alpro Not Milk', 'Mineralwasser still 6 x 1,5 L', 'Coca-Cola Zero', 'Cola Zero', 'Coca Cola', 'Mineralwasser still', 'Fritz-kola Original');

-- PIPELINE (Drinks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-25

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Drinks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061464811218', '4061458061117', '4029764001807', '4066600603405', '4056489687641', '4056489989363', '4001513007704', '4061459133271', '4056489708995', '40554006', '4061458004121', '4056489708988', '4004790017565', '4066600204404', '4056489997511', '4004790037358', '4067796002089', '4001743754539', '4052700022932', '4056489689720', '4008287959192', '4061458028998', '5411188112709', '4056489983477', '4062139025299', '4008948194016', '4009491021354', '4067796000207', '90433627', '4056489749455', '42287995', '4280001939042', '4009300014492', '4048517746086', '4062139025251', '4061458252690', '4048517742040', '4062139025473', '42142195', '42448860', '3057640186158', '5000112546415', '7394376616501', '5449000017888', '90162565', '5060337500401', '5000112576009', '5411188134985', '42143819', '5449000134264', '5000112604450')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'My Vay', 'Grocery', 'Drinks', 'Bio-Haferdrink ungesüßt', 'not-applicable', 'Aldi', 'none', '4061464811218'),
  ('DE', 'Rio d''Oro', 'Grocery', 'Drinks', 'Apfel-Direktsaft Naturtrüb', 'not-applicable', 'Aldi', 'none', '4061458061117'),
  ('DE', 'Club Mate', 'Grocery', 'Drinks', 'Club-Mate Original', 'not-applicable', 'Carrefour', 'none', '4029764001807'),
  ('DE', 'Paulaner', 'Grocery', 'Drinks', 'Paulaner Spezi', 'not-applicable', 'Kaufland', 'none', '4066600603405'),
  ('DE', 'Lidl', 'Grocery', 'Drinks', 'Milch Mandel ohne Zucker', 'not-applicable', 'Lidl', 'none', '4056489687641'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Barista Oat Drink', 'not-applicable', 'Lidl', 'none', '4056489989363'),
  ('DE', 'Gerolsteiner', 'Grocery', 'Drinks', 'Gerolsteiner Medium 1,5 Liter', 'not-applicable', 'Lidl', 'none', '4001513007704'),
  ('DE', 'Aldi', 'Grocery', 'Drinks', 'Bio-Haferdrink Natur', 'not-applicable', 'Aldi', 'none', '4061459133271'),
  ('DE', 'Lidl', 'Grocery', 'Drinks', 'No Milk Hafer 3,5% Fett', 'not-applicable', 'Lidl', 'none', '4056489708995'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Drinks', 'Mineralwasser', 'not-applicable', null, 'none', '40554006'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Drinks', 'Kokosnussmilch Klassik', 'not-applicable', 'Aldi', 'none', '4061458004121'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'No Milk Hafer 1,8% Fett', 'not-applicable', 'Lidl', 'none', '4056489708988'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'BiO HAFER NATUR', 'not-applicable', null, 'none', '4004790017565'),
  ('DE', 'Paulaner', 'Grocery', 'Drinks', 'Spezi Zero', 'not-applicable', null, 'none', '4066600204404'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'Bio Hafer', 'not-applicable', 'Lidl', 'none', '4056489997511'),
  ('DE', 'Berief', 'Grocery', 'Drinks', 'Bio Hafer ohne Zucker', 'not-applicable', null, 'none', '4004790037358'),
  ('DE', 'DmBio', 'Grocery', 'Drinks', 'Sojadrink natur', 'not-applicable', null, 'none', '4067796002089'),
  ('DE', 'Bensdorp', 'Grocery', 'Drinks', 'Bensdorp Kakao', 'not-applicable', 'Lidl', 'none', '4001743754539'),
  ('DE', 'Choco', 'Grocery', 'Drinks', 'Kakao Choco', 'not-applicable', null, 'none', '4052700022932'),
  ('DE', 'Vemondo', 'Grocery', 'Drinks', 'High Protein Sojadrink', 'not-applicable', 'Lidl', 'none', '4056489689720'),
  ('DE', 'Drinks & More GmbH & Co. KG', 'Grocery', 'Drinks', 'Knabe Malz', 'not-applicable', null, 'none', '4008287959192'),
  ('DE', 'Rio d''Oro', 'Grocery', 'Drinks', 'Trauben-Direktsaft', 'not-applicable', 'Aldi', 'none', '4061458028998'),
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
  ('DE', 'Quellbrunn', 'Grocery', 'Drinks', 'Naturell Mierbachquelle ohne Kohlensäure', 'not-applicable', null, 'none', '42142195'),
  ('DE', 'Müller', 'Grocery', 'Drinks', 'Müllermilch - Bananen-Geschmack', 'not-applicable', null, 'none', '42448860'),
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
  ('DE', 'Coca-Cola', 'Grocery', 'Drinks', 'Cola Zero', 'not-applicable', 'Netto', 'none', '5000112604450')
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
  and product_name not in ('Bio-Haferdrink ungesüßt', 'Apfel-Direktsaft Naturtrüb', 'Club-Mate Original', 'Paulaner Spezi', 'Milch Mandel ohne Zucker', 'Barista Oat Drink', 'Gerolsteiner Medium 1,5 Liter', 'Bio-Haferdrink Natur', 'No Milk Hafer 3,5% Fett', 'Mineralwasser', 'Kokosnussmilch Klassik', 'No Milk Hafer 1,8% Fett', 'BiO HAFER NATUR', 'Spezi Zero', 'Bio Hafer', 'Bio Hafer ohne Zucker', 'Sojadrink natur', 'Bensdorp Kakao', 'Kakao Choco', 'High Protein Sojadrink', 'Knabe Malz', 'Trauben-Direktsaft', 'Geröstete Mandel Ohne Zucker', 'Bio Hafer ohne Zucker', 'Pepsi Zero Zucker', 'Jever fun 4008948194016 Pilsener alkoholfrei', 'Orange ohne Fruchtfleisch', 'Oat Drink - Sugarfree', 'Kokos Blaubeere (Weiß)', 'High protein soy with chocolate taste', 'Getränke - Mineralwasser - Classic', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 'Teebeutel Italienische Limone', 'Saft Plus Eisen', 'Pepsi', 'Mineralwasser Naturell', 'Multivitaminsaft', 'Schwip Schwap Zero', 'Naturell Mierbachquelle ohne Kohlensäure', 'Müllermilch - Bananen-Geschmack', 'Wasser Volvic naturelle', 'Coca-Cola Original', 'Haferdrink Barista', 'Coca-Cola 1 Liter', 'Red Bull Energydrink Classic', 'Monster Energy Ultra', 'Coca-Cola Zero', 'Alpro Not Milk', 'Mineralwasser still 6 x 1,5 L', 'Coca-Cola Zero', 'Cola Zero');

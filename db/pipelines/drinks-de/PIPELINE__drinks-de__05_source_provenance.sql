-- PIPELINE (Drinks): source provenance
-- Generated: 2026-02-25

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('My Vay', 'Bio-Haferdrink ungesüßt', 'https://world.openfoodfacts.org/product/4061464811218', '4061464811218'),
    ('Rio d''Oro', 'Apfel-Direktsaft Naturtrüb', 'https://world.openfoodfacts.org/product/4061458061117', '4061458061117'),
    ('Club Mate', 'Club-Mate Original', 'https://world.openfoodfacts.org/product/4029764001807', '4029764001807'),
    ('Paulaner', 'Paulaner Spezi', 'https://world.openfoodfacts.org/product/4066600603405', '4066600603405'),
    ('Lidl', 'Milch Mandel ohne Zucker', 'https://world.openfoodfacts.org/product/4056489687641', '4056489687641'),
    ('Vemondo', 'Barista Oat Drink', 'https://world.openfoodfacts.org/product/4056489989363', '4056489989363'),
    ('Gerolsteiner', 'Gerolsteiner Medium 1,5 Liter', 'https://world.openfoodfacts.org/product/4001513007704', '4001513007704'),
    ('Aldi', 'Bio-Haferdrink Natur', 'https://world.openfoodfacts.org/product/4061459133271', '4061459133271'),
    ('Lidl', 'No Milk Hafer 3,5% Fett', 'https://world.openfoodfacts.org/product/4056489708995', '4056489708995'),
    ('Gut & Günstig', 'Mineralwasser', 'https://world.openfoodfacts.org/product/40554006', '40554006'),
    ('Asia Green Garden', 'Kokosnussmilch Klassik', 'https://world.openfoodfacts.org/product/4061458004121', '4061458004121'),
    ('Vemondo', 'No Milk Hafer 1,8% Fett', 'https://world.openfoodfacts.org/product/4056489708988', '4056489708988'),
    ('Berief', 'BiO HAFER NATUR', 'https://world.openfoodfacts.org/product/4004790017565', '4004790017565'),
    ('Paulaner', 'Spezi Zero', 'https://world.openfoodfacts.org/product/4066600204404', '4066600204404'),
    ('Vemondo', 'Bio Hafer', 'https://world.openfoodfacts.org/product/4056489997511', '4056489997511'),
    ('Berief', 'Bio Hafer ohne Zucker', 'https://world.openfoodfacts.org/product/4004790037358', '4004790037358'),
    ('DmBio', 'Sojadrink natur', 'https://world.openfoodfacts.org/product/4067796002089', '4067796002089'),
    ('Bensdorp', 'Bensdorp Kakao', 'https://world.openfoodfacts.org/product/4001743754539', '4001743754539'),
    ('Choco', 'Kakao Choco', 'https://world.openfoodfacts.org/product/4052700022932', '4052700022932'),
    ('Vemondo', 'High Protein Sojadrink', 'https://world.openfoodfacts.org/product/4056489689720', '4056489689720'),
    ('Drinks & More GmbH & Co. KG', 'Knabe Malz', 'https://world.openfoodfacts.org/product/4008287959192', '4008287959192'),
    ('Rio d''Oro', 'Trauben-Direktsaft', 'https://world.openfoodfacts.org/product/4061458028998', '4061458028998'),
    ('Alpro', 'Geröstete Mandel Ohne Zucker', 'https://world.openfoodfacts.org/product/5411188112709', '5411188112709'),
    ('Vemondo', 'Bio Hafer ohne Zucker', 'https://world.openfoodfacts.org/product/4056489983477', '4056489983477'),
    ('Pepsi', 'Pepsi Zero Zucker', 'https://world.openfoodfacts.org/product/4062139025299', '4062139025299'),
    ('Jever', 'Jever fun 4008948194016 Pilsener alkoholfrei', 'https://world.openfoodfacts.org/product/4008948194016', '4008948194016'),
    ('Valensia', 'Orange ohne Fruchtfleisch', 'https://world.openfoodfacts.org/product/4009491021354', '4009491021354'),
    ('DmBio', 'Oat Drink - Sugarfree', 'https://world.openfoodfacts.org/product/4067796000207', '4067796000207'),
    ('Red Bull', 'Kokos Blaubeere (Weiß)', 'https://world.openfoodfacts.org/product/90433627', '90433627'),
    ('VEMondo', 'High protein soy with chocolate taste', 'https://world.openfoodfacts.org/product/4056489749455', '4056489749455'),
    ('Naturalis', 'Getränke - Mineralwasser - Classic', 'https://world.openfoodfacts.org/product/42287995', '42287995'),
    ('Vly', 'Erbsenproteindrink Ungesüsst aus Erbsenprotein', 'https://world.openfoodfacts.org/product/4280001939042', '4280001939042'),
    ('Teekanne', 'Teebeutel Italienische Limone', 'https://world.openfoodfacts.org/product/4009300014492', '4009300014492'),
    ('Hohes C', 'Saft Plus Eisen', 'https://world.openfoodfacts.org/product/4048517746086', '4048517746086'),
    ('Pepsi', 'Pepsi', 'https://world.openfoodfacts.org/product/4062139025251', '4062139025251'),
    ('Quellbrunn', 'Mineralwasser Naturell', 'https://world.openfoodfacts.org/product/4061458252690', '4061458252690'),
    ('Granini', 'Multivitaminsaft', 'https://world.openfoodfacts.org/product/4048517742040', '4048517742040'),
    ('Schwip schwap', 'Schwip Schwap Zero', 'https://world.openfoodfacts.org/product/4062139025473', '4062139025473'),
    ('Quellbrunn', 'Naturell Mierbachquelle ohne Kohlensäure', 'https://world.openfoodfacts.org/product/42142195', '42142195'),
    ('Müller', 'Müllermilch - Bananen-Geschmack', 'https://world.openfoodfacts.org/product/42448860', '42448860'),
    ('Volvic', 'Wasser Volvic naturelle', 'https://world.openfoodfacts.org/product/3057640186158', '3057640186158'),
    ('Coca-Cola', 'Coca-Cola Original', 'https://world.openfoodfacts.org/product/5000112546415', '5000112546415'),
    ('Oatly', 'Haferdrink Barista', 'https://world.openfoodfacts.org/product/7394376616501', '7394376616501'),
    ('Coca-Cola', 'Coca-Cola 1 Liter', 'https://world.openfoodfacts.org/product/5449000017888', '5449000017888'),
    ('Red Bull', 'Red Bull Energydrink Classic', 'https://world.openfoodfacts.org/product/90162565', '90162565'),
    ('Monster Energy', 'Monster Energy Ultra', 'https://world.openfoodfacts.org/product/5060337500401', '5060337500401'),
    ('Coca-Cola', 'Coca-Cola Zero', 'https://world.openfoodfacts.org/product/5000112576009', '5000112576009'),
    ('Alpro', 'Alpro Not Milk', 'https://world.openfoodfacts.org/product/5411188134985', '5411188134985'),
    ('Saskia', 'Mineralwasser still 6 x 1,5 L', 'https://world.openfoodfacts.org/product/42143819', '42143819'),
    ('Cola', 'Coca-Cola Zero', 'https://world.openfoodfacts.org/product/5449000134264', '5449000134264'),
    ('Coca-Cola', 'Cola Zero', 'https://world.openfoodfacts.org/product/5000112604450', '5000112604450')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Drinks' AND p.is_deprecated IS NOT TRUE;

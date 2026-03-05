-- PIPELINE (Condiments): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Hela', 'Gewürzketchup Curry', 'https://world.openfoodfacts.org/product/4027400148008', '4027400148008'),
    ('Aldi', 'Curry-Gewürzketchup - delikat', 'https://world.openfoodfacts.org/product/4061458084185', '4061458084185'),
    ('Werder', 'Gewürz Ketchup', 'https://world.openfoodfacts.org/product/4400139000241', '4400139000241'),
    ('Delikato', 'Curry-Gewürzketchup - scharf', 'https://world.openfoodfacts.org/product/4061458084192', '4061458084192'),
    ('American', 'Würzsauce 2 in 1 - Ketchup & Senf', 'https://world.openfoodfacts.org/product/4061458032070', '4061458032070'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'https://world.openfoodfacts.org/product/4027400070361', '4027400070361'),
    ('Hela', 'Gewürz Ketchup Curry', 'https://world.openfoodfacts.org/product/4027400148343', '4027400148343'),
    ('Hela', 'Gewürz Ketchup Curry Delikat 30%', 'https://world.openfoodfacts.org/product/4027400148244', '4027400148244'),
    ('Hela', 'Soße Curry Ketchup', 'https://world.openfoodfacts.org/product/4027400148596', '4027400148596'),
    ('Develey', 'VW Ketchup Gewürz', 'https://world.openfoodfacts.org/product/4006824998819', '4006824998819'),
    ('Hela', 'Gewürz Ketchup Curry Leicht Scharf', 'https://world.openfoodfacts.org/product/4027400148398', '4027400148398'),
    ('Hela', 'Gewürzketchup Tomate', 'https://world.openfoodfacts.org/product/4027400148121', '4027400148121'),
    ('Hela', 'Hela Schaschlik Gewürz- Ketchup', 'https://world.openfoodfacts.org/product/4027400148091', '4027400148091'),
    ('Hela', 'Gewürz Ketchup Curry Extra Scharf', 'https://world.openfoodfacts.org/product/4027400148060', '4027400148060'),
    ('Delikato', 'Tomatenketchup', 'https://world.openfoodfacts.org/product/4061463721204', '4061463721204'),
    ('Kania', 'Ketchup', 'https://world.openfoodfacts.org/product/4056489139393', '4056489139393'),
    ('DmBio', 'Jemný kečup', 'https://world.openfoodfacts.org/product/4058172287459', '4058172287459'),
    ('Kania', 'Tomato Ketchup', 'https://world.openfoodfacts.org/product/4056489617181', '4056489617181'),
    ('Werder', 'Tomatenketchup von Werder', 'https://world.openfoodfacts.org/product/4400139000067', '4400139000067'),
    ('Jütro', 'Tomaten Ketchup', 'https://world.openfoodfacts.org/product/4056489604471', '4056489604471'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Klassik', 'https://world.openfoodfacts.org/product/4061459416329', '4061459416329'),
    ('Delikato', 'Tomatenketchup Light', 'https://world.openfoodfacts.org/product/4061462342639', '4061462342639'),
    ('Kania', 'Kečup', 'https://world.openfoodfacts.org/product/4056489640585', '4056489640585'),
    ('La Vialla', 'Premium Tomatenketchup', 'https://world.openfoodfacts.org/product/4400139000647', '4400139000647'),
    ('Werder', 'Barbecue Sauce', 'https://world.openfoodfacts.org/product/4400139006540', '4400139006540'),
    ('Bio Zentrale', 'Tomaten Ketchup', 'https://world.openfoodfacts.org/product/4005009101303', '4005009101303'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Curry', 'https://world.openfoodfacts.org/product/4061459416176', '4061459416176'),
    ('Gourmet Finest Cuisine', 'Steakhouse-Ketchup mit Fleur de Sel', 'https://world.openfoodfacts.org/product/4061463502391', '4061463502391'),
    ('Hela', 'Curry Ketchup', 'https://world.openfoodfacts.org/product/4027400168105', '4027400168105'),
    ('Dennree', 'Gewürz Ketchup', 'https://world.openfoodfacts.org/product/4021851557242', '4021851557242'),
    ('Develey', 'Ketchup - Tomaten Ketchup', 'https://world.openfoodfacts.org/product/4006824003551', '4006824003551'),
    ('Werder', 'Tomatenketchup ohne Zuckerzusatz', 'https://world.openfoodfacts.org/product/4400139006045', '4400139006045'),
    ('Bautz''ner', 'Ketchup', 'https://world.openfoodfacts.org/product/4012860004582', '4012860004582'),
    ('Hela', 'Tomaten-Ketchup', 'https://world.openfoodfacts.org/product/4027400102116', '4027400102116'),
    ('Werder', 'Tomaten Ketchup', 'https://world.openfoodfacts.org/product/4400139000838', '4400139000838'),
    ('K-Bio', 'Tomatenketchup', 'https://world.openfoodfacts.org/product/4063367537813', '4063367537813'),
    ('Delikato', 'Tomatenketchup Hot Chili', 'https://world.openfoodfacts.org/product/4061462342448', '4061462342448'),
    ('Byodo', 'Kinder ketchup', 'https://world.openfoodfacts.org/product/4018462157701', '4018462157701'),
    ('K-Classic', 'Tomatenketchup', 'https://world.openfoodfacts.org/product/4063367508011', '4063367508011'),
    ('Curry36', 'Tomatenketchup', 'https://world.openfoodfacts.org/product/4400139018536', '4400139018536'),
    ('Tomatenketchup', 'Tomatenketchup Original Bio', 'https://world.openfoodfacts.org/product/4027400102055', '4027400102055'),
    ('Born', 'Tomatenketchup', 'https://world.openfoodfacts.org/product/4400191061563', '4400191061563'),
    ('Kaufland Classic', 'Ketchup', 'https://world.openfoodfacts.org/product/4002442820815', '4002442820815'),
    ('Born', 'Tomaten Ketchup', 'https://world.openfoodfacts.org/product/4400191050017', '4400191050017'),
    ('Bio-Zentrale', 'Biokids Tomatenketchup', 'https://world.openfoodfacts.org/product/4005009106759', '4005009106759'),
    ('Hela', 'Ketchup', 'https://world.openfoodfacts.org/product/4027400172805', '4027400172805'),
    ('Zwergenwiese', 'Tomatensauce', 'https://world.openfoodfacts.org/product/4019736003748', '4019736003748'),
    ('Develey', 'Ketchup develey', 'https://world.openfoodfacts.org/product/4006824002639', '4006824002639'),
    ('K-Classic', 'Curry Gewürz Ketchup scharf', 'https://world.openfoodfacts.org/product/4337185752339', '4337185752339'),
    ('Werder', 'Kinder Bio Ketchup', 'https://world.openfoodfacts.org/product/4400139018178', '4400139018178'),
    ('Dennree', 'Ketchup', 'https://world.openfoodfacts.org/product/4021851556603', '4021851556603')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Condiments' AND p.is_deprecated IS NOT TRUE;

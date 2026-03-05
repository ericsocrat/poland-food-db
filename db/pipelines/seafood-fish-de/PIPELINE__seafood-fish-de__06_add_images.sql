-- PIPELINE (Seafood & Fish): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Seafood & Fish'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Aldi', 'ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 'https://images.openfoodfacts.org/images/products/406/145/802/7458/front_de.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458027458', 'front_4061458027458'),
    ('Aldi Archiv', 'Räucherlachs Bio', 'https://images.openfoodfacts.org/images/products/406/146/135/6569/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461356569', 'front_4061461356569'),
    ('ArcticFish', 'Pures Grün Räucherlachs', 'https://images.openfoodfacts.org/images/products/405/729/525/0227/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4057295250227', 'front_4057295250227'),
    ('Lidl', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 'https://images.openfoodfacts.org/images/products/405/648/945/2676/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489452676', 'front_4056489452676'),
    ('Golden Seafood', 'Fischstäbchen', 'https://images.openfoodfacts.org/images/products/406/145/801/7367/front_de.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458017367', 'front_4061458017367'),
    ('Almare', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 'https://images.openfoodfacts.org/images/products/406/145/801/6599/front_de.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458016599', 'front_4061458016599'),
    ('Almare', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 'https://images.openfoodfacts.org/images/products/406/145/811/0754/front_de.80.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458110754', 'front_4061458110754'),
    ('Krone', 'Räucherlachs', 'https://images.openfoodfacts.org/images/products/400/645/100/0312/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006451000312', 'front_4006451000312'),
    ('Appel', 'Bratheringe in würzigem Aufguss', 'https://images.openfoodfacts.org/images/products/402/050/092/0819/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4020500920819', 'front_4020500920819'),
    ('Aldi', 'Bio-Räucherlachs', 'https://images.openfoodfacts.org/images/products/406/145/801/1235/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011235', 'front_4061458011235'),
    ('Almare Seafood', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 'https://images.openfoodfacts.org/images/products/406/146/274/6543/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462746543', 'front_4061462746543'),
    ('Aldi', 'Thunfischfilets in Sonnenblumenöl', 'https://images.openfoodfacts.org/images/products/406/146/263/3591/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462633591', 'front_4061462633591'),
    ('Golden Seafood', 'Riesengarnelenschwänze - Provencale', 'https://images.openfoodfacts.org/images/products/406/145/803/4838/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458034838', 'front_4061458034838'),
    ('Aldi', 'Knusper-Filets - Käse-Kräuter', 'https://images.openfoodfacts.org/images/products/406/145/804/9474/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458049474', 'front_4061458049474'),
    ('Krone Fisch', 'Lachs aus verantwortungsvoller Fischzucht', 'https://images.openfoodfacts.org/images/products/400/645/100/0596/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006451000596', 'front_4006451000596'),
    ('Aldi', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 'https://images.openfoodfacts.org/images/products/406/146/273/9293/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462739293', 'front_4061462739293'),
    ('Almare', 'Stremellachs - Pfeffer', 'https://images.openfoodfacts.org/images/products/406/145/802/7489/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458027489', 'front_4061458027489'),
    ('Almare Seafood', 'Lachs', 'https://images.openfoodfacts.org/images/products/404/724/768/7317/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247687317', 'front_4047247687317'),
    ('Almare', 'Matjes Blister', 'https://images.openfoodfacts.org/images/products/404/724/742/3748/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247423748', 'front_4047247423748'),
    ('Almare', 'Stremellachs - Natur', 'https://images.openfoodfacts.org/images/products/406/145/802/7533/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458027533', 'front_4061458027533'),
    ('Ocean sea', 'King Prawns - White Tiger Garnelen', 'https://images.openfoodfacts.org/images/products/405/648/923/7846/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489237846', 'front_4056489237846'),
    ('Frosta', 'Backofen Fisch (Knusprig Kross)', 'https://images.openfoodfacts.org/images/products/400/836/601/1940/front_en.58.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366011940', 'front_4008366011940'),
    ('Nordsee', 'Fischfrikadellen', 'https://images.openfoodfacts.org/images/products/403/080/007/8943/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4030800078943', 'front_4030800078943'),
    ('Almare Seafood', 'Lachsforelle', 'https://images.openfoodfacts.org/images/products/406/145/801/7107/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458017107', 'front_4061458017107'),
    ('Lidl', 'Bio Stremel Lachs', 'https://images.openfoodfacts.org/images/products/405/648/955/4967/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489554967', 'front_4056489554967'),
    ('Almare', 'Marinierte Garnelen - Tomate-Chili', 'https://images.openfoodfacts.org/images/products/406/145/802/5188/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458025188', 'front_4061458025188'),
    ('Almare', 'Matjesfilets mit Honig-Senf-Sauce', 'https://images.openfoodfacts.org/images/products/406/145/804/3083/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458043083', 'front_4061458043083'),
    ('Lidl', 'Smoke Salmon Slices', 'https://images.openfoodfacts.org/images/products/405/648/914/4083/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489144083', 'front_4056489144083'),
    ('Deutsche See GmbH', 'Lachsfilet', 'https://images.openfoodfacts.org/images/products/400/923/951/2298/front_en.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009239512298', 'front_4009239512298'),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'https://images.openfoodfacts.org/images/products/402/190/000/8817/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021900008817', 'front_4021900008817'),
    ('Select & Go', 'Sushi Box', 'https://images.openfoodfacts.org/images/products/405/648/963/8353/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489638353', 'front_4056489638353'),
    ('Almare', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 'https://images.openfoodfacts.org/images/products/406/146/269/8781/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462698781', 'front_4061462698781'),
    ('Golden Seafood', 'White-Tiger-Garnelen', 'https://images.openfoodfacts.org/images/products/406/146/175/8158/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461758158', 'front_4061461758158'),
    ('Nordsee', 'Backfisch in knuspriger Panade mit Remoulade', 'https://images.openfoodfacts.org/images/products/402/190/001/0698/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021900010698', 'front_4021900010698'),
    ('Krone', 'Bio-Lachs', 'https://images.openfoodfacts.org/images/products/406/487/200/0250/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4064872000250', 'front_4064872000250'),
    ('Edeka', 'Räucherlachs', 'https://images.openfoodfacts.org/images/products/431/150/171/5307/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501715307', 'front_4311501715307'),
    ('Golden Seafood', 'Wildlachsfilet', 'https://images.openfoodfacts.org/images/products/408/850/064/9598/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4088500649598', 'front_4088500649598'),
    ('Fischerstolz', 'Frisches Lachsforellen-Filet mit Haut', 'https://images.openfoodfacts.org/images/products/405/648/963/9992/front_en.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489639992', 'front_4056489639992'),
    ('REWE Bio', 'Räucherlachs', 'https://images.openfoodfacts.org/images/products/433/725/678/2623/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256782623', 'front_4337256782623'),
    ('Natürlich für uns', 'Bio Räucherlachs', 'https://images.openfoodfacts.org/images/products/000/002/044/2484/front_en.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 20442484', 'front_20442484'),
    ('Golden Seafood', 'Lachsfilet-Portion mit Haut aus Norwegen', 'https://images.openfoodfacts.org/images/products/406/145/802/4105/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024105', 'front_4061458024105'),
    ('Golden Seafood', 'Lachsfilet', 'https://images.openfoodfacts.org/images/products/406/145/803/2551/front_en.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458032551', 'front_4061458032551'),
    ('Almare Seafood', 'Matjesfilets mit Sauce nach Sylter Art', 'https://images.openfoodfacts.org/images/products/406/145/804/3090/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458043090', 'front_4061458043090'),
    ('Krone', 'Kodiak Wildlachs', 'https://images.openfoodfacts.org/images/products/400/645/100/0152/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006451000152', 'front_4006451000152'),
    ('Nadler', 'Alaska Seelachs Mus', 'https://images.openfoodfacts.org/images/products/402/190/000/6561/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4021900006561', 'front_4021900006561'),
    ('Fischerstolz', 'Bio Lachsfiletportionen', 'https://images.openfoodfacts.org/images/products/405/648/991/9339/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489919339', 'front_4056489919339'),
    ('Almare', 'Shrimps- Salat', 'https://images.openfoodfacts.org/images/products/406/145/802/6918/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458026918', 'front_4061458026918'),
    ('Almare Seafood', 'Lachsfilet in Cranberry-Chili-Sauce', 'https://images.openfoodfacts.org/images/products/406/145/815/6165/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458156165', 'front_4061458156165'),
    ('Sea Gold', 'Fischstäbchen', 'https://images.openfoodfacts.org/images/products/431/626/864/3160/front_en.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4316268643160', 'front_4316268643160'),
    ('Fischersolz', 'Norwegische Lachsfiletportionen', 'https://images.openfoodfacts.org/images/products/405/648/967/2074/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489672074', 'front_4056489672074')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

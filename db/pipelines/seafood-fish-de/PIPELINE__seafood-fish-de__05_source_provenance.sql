-- PIPELINE (Seafood & Fish): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Aldi', 'ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 'https://world.openfoodfacts.org/product/4061458027458', '4061458027458'),
    ('Aldi Archiv', 'Räucherlachs Bio', 'https://world.openfoodfacts.org/product/4061461356569', '4061461356569'),
    ('ArcticFish', 'Pures Grün Räucherlachs', 'https://world.openfoodfacts.org/product/4057295250227', '4057295250227'),
    ('Lidl', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 'https://world.openfoodfacts.org/product/4056489452676', '4056489452676'),
    ('Golden Seafood', 'Fischstäbchen', 'https://world.openfoodfacts.org/product/4061458017367', '4061458017367'),
    ('Almare', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 'https://world.openfoodfacts.org/product/4061458016599', '4061458016599'),
    ('Almare', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 'https://world.openfoodfacts.org/product/4061458110754', '4061458110754'),
    ('Krone', 'Räucherlachs', 'https://world.openfoodfacts.org/product/4006451000312', '4006451000312'),
    ('Appel', 'Bratheringe in würzigem Aufguss', 'https://world.openfoodfacts.org/product/4020500920819', '4020500920819'),
    ('Aldi', 'Bio-Räucherlachs', 'https://world.openfoodfacts.org/product/4061458011235', '4061458011235'),
    ('Almare Seafood', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 'https://world.openfoodfacts.org/product/4061462746543', '4061462746543'),
    ('Aldi', 'Thunfischfilets in Sonnenblumenöl', 'https://world.openfoodfacts.org/product/4061462633591', '4061462633591'),
    ('Golden Seafood', 'Riesengarnelenschwänze - Provencale', 'https://world.openfoodfacts.org/product/4061458034838', '4061458034838'),
    ('Aldi', 'Knusper-Filets - Käse-Kräuter', 'https://world.openfoodfacts.org/product/4061458049474', '4061458049474'),
    ('Krone Fisch', 'Lachs aus verantwortungsvoller Fischzucht', 'https://world.openfoodfacts.org/product/4006451000596', '4006451000596'),
    ('Aldi', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 'https://world.openfoodfacts.org/product/4061462739293', '4061462739293'),
    ('Almare', 'Stremellachs - Pfeffer', 'https://world.openfoodfacts.org/product/4061458027489', '4061458027489'),
    ('Almare Seafood', 'Lachs', 'https://world.openfoodfacts.org/product/4047247687317', '4047247687317'),
    ('Almare', 'Matjes Blister', 'https://world.openfoodfacts.org/product/4047247423748', '4047247423748'),
    ('Almare', 'Stremellachs - Natur', 'https://world.openfoodfacts.org/product/4061458027533', '4061458027533'),
    ('Ocean sea', 'King Prawns - White Tiger Garnelen', 'https://world.openfoodfacts.org/product/4056489237846', '4056489237846'),
    ('Frosta', 'Backofen Fisch (Knusprig Kross)', 'https://world.openfoodfacts.org/product/4008366011940', '4008366011940'),
    ('Nordsee', 'Fischfrikadellen', 'https://world.openfoodfacts.org/product/4030800078943', '4030800078943'),
    ('Almare Seafood', 'Lachsforelle', 'https://world.openfoodfacts.org/product/4061458017107', '4061458017107'),
    ('Lidl', 'Bio Stremel Lachs', 'https://world.openfoodfacts.org/product/4056489554967', '4056489554967'),
    ('Almare', 'Marinierte Garnelen - Tomate-Chili', 'https://world.openfoodfacts.org/product/4061458025188', '4061458025188'),
    ('Almare', 'Matjesfilets mit Honig-Senf-Sauce', 'https://world.openfoodfacts.org/product/4061458043083', '4061458043083'),
    ('Lidl', 'Smoke Salmon Slices', 'https://world.openfoodfacts.org/product/4056489144083', '4056489144083'),
    ('Deutsche See GmbH', 'Lachsfilet', 'https://world.openfoodfacts.org/product/4009239512298', '4009239512298'),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'https://world.openfoodfacts.org/product/4021900008817', '4021900008817'),
    ('Select & Go', 'Sushi Box', 'https://world.openfoodfacts.org/product/4056489638353', '4056489638353'),
    ('Almare', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 'https://world.openfoodfacts.org/product/4061462698781', '4061462698781'),
    ('Golden Seafood', 'White-Tiger-Garnelen', 'https://world.openfoodfacts.org/product/4061461758158', '4061461758158'),
    ('Nordsee', 'Backfisch in knuspriger Panade mit Remoulade', 'https://world.openfoodfacts.org/product/4021900010698', '4021900010698'),
    ('Krone', 'Bio-Lachs', 'https://world.openfoodfacts.org/product/4064872000250', '4064872000250'),
    ('Edeka', 'Räucherlachs', 'https://world.openfoodfacts.org/product/4311501715307', '4311501715307'),
    ('Golden Seafood', 'Wildlachsfilet', 'https://world.openfoodfacts.org/product/4088500649598', '4088500649598'),
    ('Fischerstolz', 'Frisches Lachsforellen-Filet mit Haut', 'https://world.openfoodfacts.org/product/4056489639992', '4056489639992'),
    ('REWE Bio', 'Räucherlachs', 'https://world.openfoodfacts.org/product/4337256782623', '4337256782623'),
    ('Natürlich für uns', 'Bio Räucherlachs', 'https://world.openfoodfacts.org/product/20442484', '20442484'),
    ('Golden Seafood', 'Lachsfilet-Portion mit Haut aus Norwegen', 'https://world.openfoodfacts.org/product/4061458024105', '4061458024105'),
    ('Golden Seafood', 'Lachsfilet', 'https://world.openfoodfacts.org/product/4061458032551', '4061458032551'),
    ('Almare Seafood', 'Matjesfilets mit Sauce nach Sylter Art', 'https://world.openfoodfacts.org/product/4061458043090', '4061458043090'),
    ('Krone', 'Kodiak Wildlachs', 'https://world.openfoodfacts.org/product/4006451000152', '4006451000152'),
    ('Ja!', 'Regenbogenforelle Geräuchert', 'https://world.openfoodfacts.org/product/4337256843973', '4337256843973'),
    ('Nadler', 'Alaska Seelachs Mus', 'https://world.openfoodfacts.org/product/4021900006561', '4021900006561'),
    ('Fischerstolz', 'Bio Lachsfiletportionen', 'https://world.openfoodfacts.org/product/4056489919339', '4056489919339'),
    ('Almare', 'Shrimps- Salat', 'https://world.openfoodfacts.org/product/4061458026918', '4061458026918'),
    ('Almare Seafood', 'Lachsfilet in Cranberry-Chili-Sauce', 'https://world.openfoodfacts.org/product/4061458156165', '4061458156165'),
    ('Sea Gold', 'Fischstäbchen', 'https://world.openfoodfacts.org/product/4316268643160', '4316268643160'),
    ('Fischersolz', 'Norwegische Lachsfiletportionen', 'https://world.openfoodfacts.org/product/4056489672074', '4056489672074')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE;

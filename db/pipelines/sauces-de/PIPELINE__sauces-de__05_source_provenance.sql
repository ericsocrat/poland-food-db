-- PIPELINE (Sauces): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('DmBio', 'Tomatensoße Klassik', 'https://world.openfoodfacts.org/product/4058172943591', '4058172943591'),
    ('Hengstenberg', 'Tomaten stückig mit Kräutern', 'https://world.openfoodfacts.org/product/4008100168473', '4008100168473'),
    ('Bautz''ner', 'Fix Tomatensoße', 'https://world.openfoodfacts.org/product/4012860003424', '4012860003424'),
    ('DmBio', 'Tomatensoße Arrabbiata', 'https://world.openfoodfacts.org/product/4058172814327', '4058172814327'),
    ('InnFood Organic', 'Bio-Tomatensauce - Gemüse und Parmesan', 'https://world.openfoodfacts.org/product/4061463583413', '4061463583413'),
    ('DmBio', 'Tomatensauce Kräuter', 'https://world.openfoodfacts.org/product/4067796061901', '4067796061901'),
    ('Aldi', 'Passierte Tomaten', 'https://world.openfoodfacts.org/product/4061461461508', '4061461461508'),
    ('DmBio', 'Tomatensauce - Ricotta Pecorino', 'https://world.openfoodfacts.org/product/4066447265330', '4066447265330'),
    ('King''s Crown', 'Passata', 'https://world.openfoodfacts.org/product/4061463660800', '4061463660800'),
    ('Oro Di Parma', 'Pizzasauce Oregano', 'https://world.openfoodfacts.org/product/4008100168220', '4008100168220'),
    ('InnFood Organic', 'Bio-Tomatensauce - Basilikum', 'https://world.openfoodfacts.org/product/4061463583062', '4061463583062'),
    ('DmBio', 'Tomatensauce - gegrillte Paprika', 'https://world.openfoodfacts.org/product/4066447265316', '4066447265316'),
    ('InnFood Organic', 'Bio-Tomatensauce - Arrabiata', 'https://world.openfoodfacts.org/product/4061463583390', '4061463583390'),
    ('Clama', 'Tomate Frito', 'https://world.openfoodfacts.org/product/4061462018237', '4061462018237'),
    ('Cucina', 'Pasta-Sauce Arrabbiata', 'https://world.openfoodfacts.org/product/4061461024680', '4061461024680'),
    ('Mars', 'Pastasauce Miracoli Klassiker', 'https://world.openfoodfacts.org/product/4002359006029', '4002359006029'),
    ('Alnatura', 'Passata', 'https://world.openfoodfacts.org/product/40045122', '40045122'),
    ('Oro', 'Pastasauce Classico', 'https://world.openfoodfacts.org/product/4008100168466', '4008100168466'),
    ('Cucina', 'Pasta-Sauce - Napoletana', 'https://world.openfoodfacts.org/product/4061459566789', '4061459566789'),
    ('REWE Bio', 'Tomatensauce Kräuter', 'https://world.openfoodfacts.org/product/4337256377331', '4337256377331'),
    ('Allos', 'Olivers Olive Tomate', 'https://world.openfoodfacts.org/product/4016249132354', '4016249132354'),
    ('Barilla', 'Toscana Kräuter', 'https://world.openfoodfacts.org/product/8076809523561', '8076809523561'),
    ('Kaufland Bio', 'Tomatensauce Classic', 'https://world.openfoodfacts.org/product/4063367433108', '4063367433108'),
    ('Knorr', 'Tomaten passiert', 'https://world.openfoodfacts.org/product/4038700117373', '4038700117373'),
    ('Alnatura', 'Tomatensauce Kräuter', 'https://world.openfoodfacts.org/product/4104420213517', '4104420213517'),
    ('Nestlé', 'Tomaten Sauce', 'https://world.openfoodfacts.org/product/4005500331407', '4005500331407'),
    ('REWE Beste Wahl', 'Stückige Tomaten', 'https://world.openfoodfacts.org/product/4337256376709', '4337256376709'),
    ('Rewe', 'Kräuter Knoblauch Saucenbasis', 'https://world.openfoodfacts.org/product/4337256785396', '4337256785396'),
    ('Alnatura', 'Tomatensauce Gegrilltes Gemüse 350M', 'https://world.openfoodfacts.org/product/4104420213555', '4104420213555'),
    ('Ppura', 'Kinder Tomatensoße', 'https://world.openfoodfacts.org/product/7640143674138', '7640143674138'),
    ('Ppura', 'Kinder Tomatensoße mit verstecktem Gemüse', 'https://world.openfoodfacts.org/product/7640143674145', '7640143674145'),
    ('Barilla', 'Basilico 400g eu', 'https://world.openfoodfacts.org/product/8076809513722', '8076809513722'),
    ('Baresa', 'Tomatenmark', 'https://world.openfoodfacts.org/product/20004125', '20004125'),
    ('Baresa', 'Passierte Tomate', 'https://world.openfoodfacts.org/product/20884260', '20884260'),
    ('Gut & Günstig', 'Passierte Tomaten', 'https://world.openfoodfacts.org/product/4311596440429', '4311596440429'),
    ('Mutti', 'Triplo concentrato di pomodoro', 'https://world.openfoodfacts.org/product/8005110140013', '8005110140013'),
    ('Barilla', 'Arrabbiata', 'https://world.openfoodfacts.org/product/8076809513388', '8076809513388'),
    ('EDEKA Bio', 'Passata, passierte Tomaten - Bio', 'https://world.openfoodfacts.org/product/4311501650578', '4311501650578'),
    ('Ppura', 'Vegane Bolognese', 'https://world.openfoodfacts.org/product/7640143674114', '7640143674114'),
    ('Barilla', 'Napoletana', 'https://world.openfoodfacts.org/product/8076809513692', '8076809513692'),
    ('Barilla', 'Ricotta', 'https://world.openfoodfacts.org/product/8076809521543', '8076809521543'),
    ('Combino', 'Bolognese', 'https://world.openfoodfacts.org/product/20003937', '20003937'),
    ('Baresa', 'Passierte Tomaten', 'https://world.openfoodfacts.org/product/20164034', '20164034'),
    ('Ja!', 'Tomatensauce mit Basilikum', 'https://world.openfoodfacts.org/product/4337256946070', '4337256946070'),
    ('Mutti', 'Pizzasauce Aromatica', 'https://world.openfoodfacts.org/product/8005110551215', '8005110551215'),
    ('Combino', 'Arrabbiata', 'https://world.openfoodfacts.org/product/20300623', '20300623'),
    ('REWE Bio', 'Passata Tomaten', 'https://world.openfoodfacts.org/product/4337256343107', '4337256343107'),
    ('Barilla', 'Verdure mediterranee 400g eu cross', 'https://world.openfoodfacts.org/product/8076809583749', '8076809583749'),
    ('REWE Bio', 'Tomatensauce Ricotta', 'https://world.openfoodfacts.org/product/4337256380669', '4337256380669'),
    ('Alnatura', 'Tomatensauce Toscana', 'https://world.openfoodfacts.org/product/4104420031081', '4104420031081'),
    ('Rewe', 'Tomate Ricotta mit Basilikum', 'https://world.openfoodfacts.org/product/4337256794176', '4337256794176')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Sauces' AND p.is_deprecated IS NOT TRUE;

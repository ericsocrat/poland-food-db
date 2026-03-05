-- PIPELINE (Snacks): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Top', 'Popcorn o smaku maślanym', 'https://world.openfoodfacts.org/product/5905617000854', '5905617000854'),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 'https://world.openfoodfacts.org/product/5900259115393', '5900259115393'),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 'https://world.openfoodfacts.org/product/5902180470336', '5902180470336'),
    ('Kupiec', 'Wafle ryżowe naturalne', 'https://world.openfoodfacts.org/product/5902172001524', '5902172001524'),
    ('Zdrowidło', 'Chipsy Loopea''s O Smaku Śmietanki Z Cebulką', 'https://world.openfoodfacts.org/product/5904569550394', '5904569550394'),
    ('Lubella', 'Paluszki z solą', 'https://world.openfoodfacts.org/product/5900049041017', '5900049041017'),
    ('Pano', 'Wafle mini, zbożowe', 'https://world.openfoodfacts.org/product/5902973790894', '5902973790894'),
    ('Bakalland', 'Ba! żurawina', 'https://world.openfoodfacts.org/product/5900749610988', '5900749610988'),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 'https://world.openfoodfacts.org/product/5900449006890', '5900449006890'),
    ('Lajkonik', 'Paluszki o smaku waniliowym.', 'https://world.openfoodfacts.org/product/5900320003260', '5900320003260'),
    ('Delicje', 'Szampariskie pomaranczowe', 'https://world.openfoodfacts.org/product/5906747308582', '5906747308582'),
    ('Vitanella', 'Superballs Kokos i kakao', 'https://world.openfoodfacts.org/product/5903548013110', '5903548013110'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'https://world.openfoodfacts.org/product/5900617013064', '5900617013064'),
    ('Lajkonik', 'Dobry chrup', 'https://world.openfoodfacts.org/product/5900320011036', '5900320011036'),
    ('Lajkonik', 'Salted cracker', 'https://world.openfoodfacts.org/product/5900320001136', '5900320001136'),
    ('Go On Nutrition', 'Protein 33% Caramel', 'https://world.openfoodfacts.org/product/5900617035905', '5900617035905'),
    ('Lajkonik', 'Krakersy mini', 'https://world.openfoodfacts.org/product/5900320008463', '5900320008463'),
    ('Bakalland', 'Barre chocolat ba', 'https://world.openfoodfacts.org/product/5900749610926', '5900749610926'),
    ('Go On', 'Go On Energy', 'https://world.openfoodfacts.org/product/5900617047304', '5900617047304'),
    ('Lajkonik', 'Prezel', 'https://world.openfoodfacts.org/product/5900320001334', '5900320001334'),
    ('Lorenz', 'Chrupki Curly', 'https://world.openfoodfacts.org/product/5905187001237', '5905187001237'),
    ('Beskidzkie', 'Beskidzkie paluchy z sezamem', 'https://world.openfoodfacts.org/product/5907029001658', '5907029001658'),
    ('Purella superfoods', 'Purella ciasteczko', 'https://world.openfoodfacts.org/product/5905186302410', '5905186302410'),
    ('Unknown', 'Vitanella raw', 'https://world.openfoodfacts.org/product/5905186302106', '5905186302106'),
    ('Meltié Chocolatier', 'Dark Chocolate 64% Cocoa', 'https://world.openfoodfacts.org/product/5904358563994', '5904358563994'),
    ('Lajkonik', 'Junior Safari', 'https://world.openfoodfacts.org/product/5900320003420', '5900320003420'),
    ('Lorenz', 'Monster munch', 'https://world.openfoodfacts.org/product/5905187001213', '5905187001213'),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 'https://world.openfoodfacts.org/product/5907029010797', '5907029010797'),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 'https://world.openfoodfacts.org/product/5900320003536', '5900320003536'),
    ('TOP', 'Paluszki solone', 'https://world.openfoodfacts.org/product/5900928004676', '5900928004676'),
    ('Be raw', 'Energy Raspberry', 'https://world.openfoodfacts.org/product/5903246562552', '5903246562552'),
    ('Top', 'Paluszki i precelki solone', 'https://world.openfoodfacts.org/product/5904607004810', '5904607004810'),
    ('San', 'San bieszczadzkie suchary', 'https://world.openfoodfacts.org/product/5906747309893', '5906747309893'),
    ('Tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'https://world.openfoodfacts.org/product/4056489814092', '4056489814092'),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 'https://world.openfoodfacts.org/product/8595229924432', '8595229924432'),
    ('Lajkonik', 'Krakersy mini ser i cebula', 'https://world.openfoodfacts.org/product/5900320008470', '5900320008470'),
    ('Delicje', 'Delicje malinowe', 'https://world.openfoodfacts.org/product/5906747308490', '5906747308490'),
    ('Go On', 'Vitamin Coconut & Milk Chocolate', 'https://world.openfoodfacts.org/product/5900617047281', '5900617047281'),
    ('Góralki', 'Góralki mleczne', 'https://world.openfoodfacts.org/product/8584004042089', '8584004042089'),
    ('Unknown', 'Popcorn solony', 'https://world.openfoodfacts.org/product/5900749115049', '5900749115049'),
    ('7 Days', 'Croissant with Cocoa Filling', 'https://world.openfoodfacts.org/product/5201360521210', '5201360521210'),
    ('Snack Day', 'Popcorn', 'https://world.openfoodfacts.org/product/4056489827498', '4056489827498'),
    ('Lorenz', 'Monster Munch Crispy Potato-Snack Original', 'https://world.openfoodfacts.org/product/4018077632006', '4018077632006'),
    ('Zott', 'Monte Snack', 'https://world.openfoodfacts.org/product/4014500513485', '4014500513485'),
    ('Emco', 'Vitanella Bars', 'https://world.openfoodfacts.org/product/8595229926573', '8595229926573'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'https://world.openfoodfacts.org/product/3800205871255', '3800205871255'),
    ('7days', '7days', 'https://world.openfoodfacts.org/product/5201360677351', '5201360677351'),
    ('Tastino', 'Wafle Kukurydziane', 'https://world.openfoodfacts.org/product/4056489784050', '4056489784050'),
    ('Eti', 'Dare with MILK CHOCOLATE', 'https://world.openfoodfacts.org/product/8690526026220', '8690526026220'),
    ('Belle France', 'Brioche Tressée', 'https://world.openfoodfacts.org/product/3258561400242', '3258561400242'),
    ('Happy Creations', 'Cracker Mix Classic', 'https://world.openfoodfacts.org/product/8719979201470', '8719979201470')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE;

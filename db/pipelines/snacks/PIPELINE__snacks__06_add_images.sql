-- PIPELINE (Snacks): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Snacks'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Top', 'Popcorn o smaku maślanym', 'https://images.openfoodfacts.org/images/products/590/561/700/0854/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905617000854', 'front_5905617000854'),
    ('Lay''s', 'Oven Baked Krakersy wielozbożowe', 'https://images.openfoodfacts.org/images/products/590/025/911/5393/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900259115393', 'front_5900259115393'),
    ('Sonko', 'Wafle ryżowe w czekoladzie mlecznej', 'https://images.openfoodfacts.org/images/products/590/218/047/0336/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902180470336', 'front_5902180470336'),
    ('Kupiec', 'Wafle ryżowe naturalne', 'https://images.openfoodfacts.org/images/products/590/217/200/1524/front_pl.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902172001524', 'front_5902172001524'),
    ('Zdrowidło', 'Chipsy Loopea''s O Smaku Śmietanki Z Cebulką', 'https://images.openfoodfacts.org/images/products/590/456/955/0394/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904569550394', 'front_5904569550394'),
    ('Lubella', 'Paluszki z solą', 'https://images.openfoodfacts.org/images/products/590/004/904/1017/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049041017', 'front_5900049041017'),
    ('Pano', 'Wafle mini, zbożowe', 'https://images.openfoodfacts.org/images/products/590/297/379/0894/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902973790894', 'front_5902973790894'),
    ('Bakalland', 'Ba! żurawina', 'https://images.openfoodfacts.org/images/products/590/074/961/0988/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900749610988', 'front_5900749610988'),
    ('Vital Fresh', 'Surówka Colesław z białej kapusty', 'https://images.openfoodfacts.org/images/products/590/044/900/6890/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900449006890', 'front_5900449006890'),
    ('Lajkonik', 'Paluszki o smaku waniliowym.', 'https://images.openfoodfacts.org/images/products/590/032/000/3260/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320003260', 'front_5900320003260'),
    ('Delicje', 'Szampariskie pomaranczowe', 'https://images.openfoodfacts.org/images/products/590/674/730/8582/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906747308582', 'front_5906747308582'),
    ('Vitanella', 'Superballs Kokos i kakao', 'https://images.openfoodfacts.org/images/products/590/354/801/3110/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903548013110', 'front_5903548013110'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'https://images.openfoodfacts.org/images/products/590/061/701/3064/front_pl.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617013064', 'front_5900617013064'),
    ('Lajkonik', 'Dobry chrup', 'https://images.openfoodfacts.org/images/products/590/032/001/1036/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320011036', 'front_5900320011036'),
    ('Lajkonik', 'Salted cracker', 'https://images.openfoodfacts.org/images/products/590/032/000/1136/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320001136', 'front_5900320001136'),
    ('Go On Nutrition', 'Protein 33% Caramel', 'https://images.openfoodfacts.org/images/products/590/061/703/5905/front_en.75.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617035905', 'front_5900617035905'),
    ('Lajkonik', 'Krakersy mini', 'https://images.openfoodfacts.org/images/products/590/032/000/8463/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320008463', 'front_5900320008463'),
    ('Bakalland', 'Barre chocolat ba', 'https://images.openfoodfacts.org/images/products/590/074/961/0926/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900749610926', 'front_5900749610926'),
    ('Go On', 'Go On Energy', 'https://images.openfoodfacts.org/images/products/590/061/704/7304/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617047304', 'front_5900617047304'),
    ('Lajkonik', 'Prezel', 'https://images.openfoodfacts.org/images/products/590/032/000/1334/front_en.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320001334', 'front_5900320001334'),
    ('Lorenz', 'Chrupki Curly', 'https://images.openfoodfacts.org/images/products/590/518/700/1237/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905187001237', 'front_5905187001237'),
    ('Beskidzkie', 'Beskidzkie paluchy z sezamem', 'https://images.openfoodfacts.org/images/products/590/702/900/1658/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907029001658', 'front_5907029001658'),
    ('Purella superfoods', 'Purella ciasteczko', 'https://images.openfoodfacts.org/images/products/590/518/630/2410/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905186302410', 'front_5905186302410'),
    ('Unknown', 'Vitanella raw', 'https://images.openfoodfacts.org/images/products/590/518/630/2106/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905186302106', 'front_5905186302106'),
    ('Meltié Chocolatier', 'Dark Chocolate 64% Cocoa', 'https://images.openfoodfacts.org/images/products/590/435/856/3994/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904358563994', 'front_5904358563994'),
    ('Lajkonik', 'Junior Safari', 'https://images.openfoodfacts.org/images/products/590/032/000/3420/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320003420', 'front_5900320003420'),
    ('Lorenz', 'Monster munch', 'https://images.openfoodfacts.org/images/products/590/518/700/1213/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905187001213', 'front_5905187001213'),
    ('Aksam', 'Beskidzkie paluszki o smaku sera i cebulki', 'https://images.openfoodfacts.org/images/products/590/702/901/0797/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907029010797', 'front_5907029010797'),
    ('Lajkonik', 'Drobne pieczywo o smaku waniliowym', 'https://images.openfoodfacts.org/images/products/590/032/000/3536/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320003536', 'front_5900320003536'),
    ('TOP', 'Paluszki solone', 'https://images.openfoodfacts.org/images/products/590/092/800/4676/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900928004676', 'front_5900928004676'),
    ('Be raw', 'Energy Raspberry', 'https://images.openfoodfacts.org/images/products/590/324/656/2552/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903246562552', 'front_5903246562552'),
    ('Top', 'Paluszki i precelki solone', 'https://images.openfoodfacts.org/images/products/590/460/700/4810/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904607004810', 'front_5904607004810'),
    ('San', 'San bieszczadzkie suchary', 'https://images.openfoodfacts.org/images/products/590/674/730/9893/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906747309893', 'front_5906747309893'),
    ('Tastino', 'Małe Wafle Kukurydziane O Smaku Pizzy', 'https://images.openfoodfacts.org/images/products/405/648/981/4092/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489814092', 'front_4056489814092'),
    ('Go Active', 'Baton wysokobiałkowy z pistacjami', 'https://images.openfoodfacts.org/images/products/859/522/992/4432/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 8595229924432', 'front_8595229924432'),
    ('Lajkonik', 'Krakersy mini ser i cebula', 'https://images.openfoodfacts.org/images/products/590/032/000/8470/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900320008470', 'front_5900320008470'),
    ('Delicje', 'Delicje malinowe', 'https://images.openfoodfacts.org/images/products/590/674/730/8490/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906747308490', 'front_5906747308490'),
    ('Go On', 'Vitamin Coconut & Milk Chocolate', 'https://images.openfoodfacts.org/images/products/590/061/704/7281/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900617047281', 'front_5900617047281'),
    ('Góralki', 'Góralki mleczne', 'https://images.openfoodfacts.org/images/products/858/400/404/2089/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 8584004042089', 'front_8584004042089'),
    ('Unknown', 'Popcorn solony', 'https://images.openfoodfacts.org/images/products/590/074/911/5049/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900749115049', 'front_5900749115049'),
    ('7 Days', 'Croissant with Cocoa Filling', 'https://images.openfoodfacts.org/images/products/520/136/052/1210/front_en.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 5201360521210', 'front_5201360521210'),
    ('Snack Day', 'Popcorn', 'https://images.openfoodfacts.org/images/products/405/648/982/7498/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489827498', 'front_4056489827498'),
    ('Lorenz', 'Monster Munch Crispy Potato-Snack Original', 'https://images.openfoodfacts.org/images/products/401/807/763/2006/front_en.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077632006', 'front_4018077632006'),
    ('Zott', 'Monte Snack', 'https://images.openfoodfacts.org/images/products/401/450/051/3485/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014500513485', 'front_4014500513485'),
    ('Emco', 'Vitanella Bars', 'https://images.openfoodfacts.org/images/products/859/522/992/6573/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8595229926573', 'front_8595229926573'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'https://images.openfoodfacts.org/images/products/380/020/587/1255/front_en.111.400.jpg', 'off_api', 'front', true, 'Front — EAN 3800205871255', 'front_3800205871255'),
    ('7days', '7days', 'https://images.openfoodfacts.org/images/products/520/136/067/7351/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5201360677351', 'front_5201360677351'),
    ('Tastino', 'Wafle Kukurydziane', 'https://images.openfoodfacts.org/images/products/405/648/978/4050/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489784050', 'front_4056489784050'),
    ('Eti', 'Dare with MILK CHOCOLATE', 'https://images.openfoodfacts.org/images/products/869/052/602/6220/front_ro.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 8690526026220', 'front_8690526026220'),
    ('Belle France', 'Brioche Tressée', 'https://images.openfoodfacts.org/images/products/325/856/140/0242/front_fr.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 3258561400242', 'front_3258561400242'),
    ('Happy Creations', 'Cracker Mix Classic', 'https://images.openfoodfacts.org/images/products/871/997/920/1470/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 8719979201470', 'front_8719979201470')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

-- PIPELINE (Plant-Based & Alternatives): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-12

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Plant-Based & Alternatives'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'https://images.openfoodfacts.org/images/products/400/040/500/4593/front_de.133.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405004593', 'front_4000405004593'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'https://images.openfoodfacts.org/images/products/400/040/500/5026/front_de.102.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405005026', 'front_4000405005026'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'https://images.openfoodfacts.org/images/products/400/040/500/5033/front_de.79.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405005033', 'front_4000405005033'),
    ('Mühlenbauer', 'Vegane Bratwürste', 'https://images.openfoodfacts.org/images/products/400/040/500/1523/front_en.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405001523', 'front_4000405001523'),
    ('Eberswalder', 'Vegetarios Würstchen', 'https://images.openfoodfacts.org/images/products/401/237/162/0103/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012371620103', 'front_4012371620103'),
    ('Vemondo', 'Bio Tofu geräuchert', 'https://images.openfoodfacts.org/images/products/405/648/961/6221/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489616221', 'front_4056489616221'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Crispies', 'https://images.openfoodfacts.org/images/products/400/040/500/1868/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405001868', 'front_4000405001868'),
    ('Gut Bio', 'Griechische Bio-Oliven, grün', 'https://images.openfoodfacts.org/images/products/406/145/918/8745/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459188745', 'front_4061459188745'),
    ('Jerg', 'Vegane Genießerscheiben würzig', 'https://images.openfoodfacts.org/images/products/405/648/946/7939/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489467939', 'front_4056489467939'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Bratwurst', 'https://images.openfoodfacts.org/images/products/400/040/500/1752/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405001752', 'front_4000405001752'),
    ('Rügenwalder Mühle', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 'https://images.openfoodfacts.org/images/products/400/040/500/3251/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405003251', 'front_4000405003251'),
    ('My Vay', 'Bio-Tofu Geräuchert', 'https://images.openfoodfacts.org/images/products/406/146/293/8825/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462938825', 'front_4061462938825'),
    ('DmBio', 'Tomaten Stücke', 'https://images.openfoodfacts.org/images/products/406/644/761/0048/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447610048', 'front_4066447610048'),
    ('Taifun', 'Räuchertofu Mandel-Sesam', 'https://images.openfoodfacts.org/images/products/401/235/911/3108/front_de.146.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012359113108', 'front_4012359113108'),
    ('Henglein', 'Gnocchi Kartoffel-Klößchen', 'https://images.openfoodfacts.org/images/products/400/116/315/4858/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001163154858', 'front_4001163154858'),
    ('DmBio', 'Maiswaffeln', 'https://images.openfoodfacts.org/images/products/406/644/758/4035/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447584035', 'front_4066447584035'),
    ('Vemondo', 'Tofu Natur', 'https://images.openfoodfacts.org/images/products/405/648/961/6214/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489616214', 'front_4056489616214'),
    ('Rügenwalder Mühle', 'Veganer Schinken Spicker Bunter Pfeffer', 'https://images.openfoodfacts.org/images/products/400/040/500/4999/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405004999', 'front_4000405004999'),
    ('DmBio', 'Mais Waffeln gesalzen', 'https://images.openfoodfacts.org/images/products/406/644/756/2682/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447562682', 'front_4066447562682'),
    ('Rügenwalder Mühle', 'Vegan Curry aufschnitt', 'https://images.openfoodfacts.org/images/products/400/040/500/1745/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000405001745', 'front_4000405001745'),
    ('Gut Bio', 'Bio-Linsenwaffeln - Meersalz', 'https://images.openfoodfacts.org/images/products/406/146/380/3764/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463803764', 'front_4061463803764'),
    ('Kühne', 'Rotkohl', 'https://images.openfoodfacts.org/images/products/000/004/080/4002/front_de.208.400.jpg', 'off_api', 'front', true, 'Front — EAN 40804002', 'front_40804002'),
    ('Harry', 'Steinofenbrot, Harry 1688', 'https://images.openfoodfacts.org/images/products/407/180/000/0855/front_de.87.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000855', 'front_4071800000855'),
    ('Better Plant', 'Vegane Creme', 'https://images.openfoodfacts.org/images/products/405/648/967/1411/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489671411', 'front_4056489671411'),
    ('REWE Bio +vegan', 'Räucher-Tofu', 'https://images.openfoodfacts.org/images/products/433/725/625/0122/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256250122', 'front_4337256250122'),
    ('Rewe', 'Falafel bällchen', 'https://images.openfoodfacts.org/images/products/433/725/685/7086/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256857086', 'front_4337256857086'),
    ('Taifun', 'Tofu fumé', 'https://images.openfoodfacts.org/images/products/401/235/911/1104/front_en.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012359111104', 'front_4012359111104'),
    ('Rewe Beste Wahl', 'Milde Genießer Scheiben', 'https://images.openfoodfacts.org/images/products/000/002/176/3847/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 21763847', 'front_21763847'),
    ('Simply V', 'Würzig verfeinert mit Mandelöl', 'https://images.openfoodfacts.org/images/products/426/044/496/2982/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260444962982', 'front_4260444962982'),
    ('Plant Republic', 'Räucher-Tofu', 'https://images.openfoodfacts.org/images/products/433/725/624/2585/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256242585', 'front_4337256242585'),
    ('K-take it veggie', 'Bio Tofu geräuchert', 'https://images.openfoodfacts.org/images/products/433/589/675/0200/front_en.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4335896750200', 'front_4335896750200'),
    ('No-Name', 'Bananen süß & samtig', 'https://images.openfoodfacts.org/images/products/425/129/111/3221/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4251291113221', 'front_4251291113221'),
    ('Taifun', 'Filets de tofu à la japonaise', 'https://images.openfoodfacts.org/images/products/401/235/914/4003/front_fr.99.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012359144003', 'front_4012359144003'),
    ('EDEKA Bio', 'My Veggie Tofu geräuchert', 'https://images.openfoodfacts.org/images/products/431/150/170/4288/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501704288', 'front_4311501704288'),
    ('Taifun', 'Tofu natur', 'https://images.openfoodfacts.org/images/products/401/235/911/0107/front_en.84.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012359110107', 'front_4012359110107'),
    ('Like Meat', 'Like Grilled Chicken', 'https://images.openfoodfacts.org/images/products/426/038/066/5039/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260380665039', 'front_4260380665039'),
    ('Like Meat', 'Like Chicken', 'https://images.openfoodfacts.org/images/products/426/038/066/5015/front_de.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260380665015', 'front_4260380665015'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 'https://images.openfoodfacts.org/images/products/000/002/031/9335/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 20319335', 'front_20319335'),
    ('Freshona', 'Cornichons Gurken', 'https://images.openfoodfacts.org/images/products/000/002/000/4361/front_en.155.400.jpg', 'off_api', 'front', true, 'Front — EAN 20004361', 'front_20004361'),
    ('Rewe Bio', 'Tofu Natur', 'https://images.openfoodfacts.org/images/products/433/725/624/4794/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256244794', 'front_4337256244794'),
    ('Baresa', 'Tomaten passiert', 'https://images.openfoodfacts.org/images/products/000/002/016/3402/front_en.352.400.jpg', 'off_api', 'front', true, 'Front — EAN 20163402', 'front_20163402'),
    ('Garden Gourmet', 'Sensational Burger aus Sojaprotein', 'https://images.openfoodfacts.org/images/products/761/303/691/5076/front_de.138.400.jpg', 'off_api', 'front', true, 'Front — EAN 7613036915076', 'front_7613036915076'),
    ('Sondey', 'Mais Waffeln mit Meersalz Bio', 'https://images.openfoodfacts.org/images/products/000/002/088/4697/front_en.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 20884697', 'front_20884697'),
    ('Greenforce', 'Pflanzliche Mini-Frika', 'https://images.openfoodfacts.org/images/products/426/032/221/1348/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260322211348', 'front_4260322211348'),
    ('Ja', 'Tomaten passiert', 'https://images.openfoodfacts.org/images/products/433/725/673/3359/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256733359', 'front_4337256733359'),
    ('REWE Bio', 'Sojasahne', 'https://images.openfoodfacts.org/images/products/433/725/626/6383/front_de.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256266383', 'front_4337256266383'),
    ('Simply V', 'Gerieben Pizza', 'https://images.openfoodfacts.org/images/products/426/044/496/2807/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260444962807', 'front_4260444962807'),
    ('Ja!', 'Cherry-Roma Tomaten Klasse 1', 'https://images.openfoodfacts.org/images/products/843/655/713/8934/front_en.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 8436557138934', 'front_8436557138934'),
    ('EDEKA Bio', 'My Veggie Tofu Natur', 'https://images.openfoodfacts.org/images/products/431/150/145/1076/front_de.82.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501451076', 'front_4311501451076'),
    ('REWE Bio', 'Linsenwaffeln', 'https://images.openfoodfacts.org/images/products/433/725/666/9160/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256669160', 'front_4337256669160'),
    ('Nestlé', 'Vegane Filet-Streifen', 'https://images.openfoodfacts.org/images/products/729/010/935/9021/front_de.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 7290109359021', 'front_7290109359021'),
    ('Greenforce', 'Pflanzliche Cevapcici', 'https://images.openfoodfacts.org/images/products/426/032/221/1362/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260322211362', 'front_4260322211362'),
    ('EnerBiO', 'Veggie Hack', 'https://images.openfoodfacts.org/images/products/430/561/578/3208/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4305615783208', 'front_4305615783208'),
    ('Edeka Bio', 'Tomatenmark 2-fach konzentriert', 'https://images.openfoodfacts.org/images/products/431/150/144/6232/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501446232', 'front_4311501446232'),
    ('Rewe', 'Tofu Natur', 'https://images.openfoodfacts.org/images/products/433/725/625/3222/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4337256253222', 'front_4337256253222'),
    ('Like Meat', 'Like Beef Strips', 'https://images.openfoodfacts.org/images/products/426/038/066/5930/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4260380665930', 'front_4260380665930'),
    ('Rama', 'Kochcreme', 'https://images.openfoodfacts.org/images/products/871/920/020/7172/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 8719200207172', 'front_8719200207172'),
    ('Edeka', 'My Veggie Tofu Classic', 'https://images.openfoodfacts.org/images/products/431/150/101/2246/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4311501012246', 'front_4311501012246'),
    ('Alnatura', 'Linsen Waffeln', 'https://images.openfoodfacts.org/images/products/410/442/020/8254/front_en.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4104420208254', 'front_4104420208254')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

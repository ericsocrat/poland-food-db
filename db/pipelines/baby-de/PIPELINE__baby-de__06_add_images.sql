-- PIPELINE (Baby): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Baby'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Hipp', 'Reine Bio-Karotten mild-süßlich', 'https://images.openfoodfacts.org/images/products/406/230/002/0719/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300020719', 'front_4062300020719'),
    ('Hipp', 'Früchte Riegel Joghurt-Kirsch in Banane', 'https://images.openfoodfacts.org/images/products/406/230/036/2215/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300362215', 'front_4062300362215'),
    ('Mamia Bio', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'https://images.openfoodfacts.org/images/products/406/145/975/1420/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459751420', 'front_4061459751420'),
    ('Hipp', 'Gemüse Allerlei', 'https://images.openfoodfacts.org/images/products/406/230/002/0313/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300020313', 'front_4062300020313'),
    ('DmBio', 'Kürbis pur', 'https://images.openfoodfacts.org/images/products/406/779/601/7090/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796017090', 'front_4067796017090'),
    ('Bebivita', 'Mini-Makkaroni mit buntem Rahmgemüse', 'https://images.openfoodfacts.org/images/products/401/885/201/4959/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852014959', 'front_4018852014959'),
    ('Hipp', 'Reiner Butternut Kürbis', 'https://images.openfoodfacts.org/images/products/406/230/038/1971/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300381971', 'front_4062300381971'),
    ('Hipp', 'Menü Karotten, Kartoffeln, Wildlachs', 'https://images.openfoodfacts.org/images/products/406/230/025/5142/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300255142', 'front_4062300255142'),
    ('Hipp', 'Gemüse Kürbis Nach Dem 4. Monat', 'https://images.openfoodfacts.org/images/products/406/230/025/7597/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300257597', 'front_4062300257597'),
    ('Puttkammer', 'Schinkenröllchen in Aspik', 'https://images.openfoodfacts.org/images/products/400/417/610/0539/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004176100539', 'front_4004176100539'),
    ('Hipp', 'Mango-Bananen-Grieß', 'https://images.openfoodfacts.org/images/products/406/230/040/6476/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300406476', 'front_4062300406476'),
    ('Hipp', 'Spinatgemüse in Kartoffeln', 'https://images.openfoodfacts.org/images/products/406/230/035/0403/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300350403', 'front_4062300350403'),
    ('Bebivita', 'Abendbrei Grieß-Vanille', 'https://images.openfoodfacts.org/images/products/401/885/203/5855/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852035855', 'front_4018852035855'),
    ('Hipp', 'Grießbrei', 'https://images.openfoodfacts.org/images/products/406/230/012/3175/front_fr.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300123175', 'front_4062300123175'),
    ('Hipp', 'Schinkennudeln mit Gemüse (ab 8. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/026/6179/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300266179', 'front_4062300266179'),
    ('Hipp', 'Gemüse Lasagne', 'https://images.openfoodfacts.org/images/products/406/230/026/5967/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300265967', 'front_4062300265967'),
    ('Bebivita', 'Gemüse-Spätzle-Pfanne', 'https://images.openfoodfacts.org/images/products/401/885/203/0577/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852030577', 'front_4018852030577'),
    ('DmBio', 'Pastinaken mit Kartoffeln und Rind im Gläschen', 'https://images.openfoodfacts.org/images/products/406/779/608/1381/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796081381', 'front_4067796081381'),
    ('Hipp', 'Kartoffel-Gemüse mit Bio-Rind (ab 8. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/026/5998/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300265998', 'front_4062300265998'),
    ('Hipp', 'Gemüsereis mit Erbsen und zartem Geschnetzelten', 'https://images.openfoodfacts.org/images/products/406/230/016/6738/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300166738', 'front_4062300166738'),
    ('Hipp', 'Erdbeere in Apfel-Joghurt-Müsli', 'https://images.openfoodfacts.org/images/products/406/230/026/2652/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300262652', 'front_4062300262652'),
    ('Hipp', 'Gartengemüse Mit Pute Und Rosmarin', 'https://images.openfoodfacts.org/images/products/406/230/026/5608/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300265608', 'front_4062300265608'),
    ('Hipp', 'Tomaten Und Kartoffeln Mit Bio-hühnchen', 'https://images.openfoodfacts.org/images/products/406/230/026/6025/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300266025', 'front_4062300266025'),
    ('Hipp', 'Hipp Gemüseallerlei Mit Bio Rind,250G', 'https://images.openfoodfacts.org/images/products/406/230/026/1303/front_fr.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300261303', 'front_4062300261303'),
    ('Hipp', 'Frühstücks Porridge Banane Blaubeeren Haferbrei', 'https://images.openfoodfacts.org/images/products/406/230/034/9445/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300349445', 'front_4062300349445'),
    ('Hipp', 'Hippis Pfirsich Banane Mango Joghurt', 'https://images.openfoodfacts.org/images/products/406/230/043/2123/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300432123', 'front_4062300432123'),
    ('DmBio', 'Hirse Getreidebrei', 'https://images.openfoodfacts.org/images/products/406/644/739/8649/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447398649', 'front_4066447398649'),
    ('Hipp', 'Pfirsich in Apfel (ab 5. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/029/7104/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300297104', 'front_4062300297104'),
    ('Hipp', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/029/0136/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300290136', 'front_4062300290136'),
    ('Unknown', 'Apfel Bananen müesli', 'https://images.openfoodfacts.org/images/products/406/230/040/6490/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300406490', 'front_4062300406490'),
    ('DmBio', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'https://images.openfoodfacts.org/images/products/405/817/243/7892/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172437892', 'front_4058172437892'),
    ('Hipp', 'Birne-Apfel mit Dinkel, Frucht & urgetreide', 'https://images.openfoodfacts.org/images/products/406/230/026/9842/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300269842', 'front_4062300269842'),
    ('Bebivita', 'Anfangsmilch', 'https://images.openfoodfacts.org/images/products/401/885/202/6655/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852026655', 'front_4018852026655'),
    ('Hipp Bio', 'Himbeer Reiswaffeln', 'https://images.openfoodfacts.org/images/products/406/230/037/6182/front_en.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300376182', 'front_4062300376182'),
    ('Hipp', 'Bio Combiotik Pre', 'https://images.openfoodfacts.org/images/products/406/230/039/8894/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300398894', 'front_4062300398894'),
    ('Dr. Oetker', 'Banane & Pfirsich in Apfel (ab 5. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/029/7081/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300297081', 'front_4062300297081'),
    ('Hipp', 'Urkorn Dinos', 'https://images.openfoodfacts.org/images/products/406/230/042/9710/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300429710', 'front_4062300429710'),
    ('Bebivita', 'Reis mit Karotten und Pute', 'https://images.openfoodfacts.org/images/products/401/885/203/5343/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852035343', 'front_4018852035343'),
    ('Hipp', 'Hipp', 'https://images.openfoodfacts.org/images/products/406/230/037/5260/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300375260', 'front_4062300375260'),
    ('Hipp', 'Hippis Apfel-Birne-Banane', 'https://images.openfoodfacts.org/images/products/406/230/027/8530/front_fr.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300278530', 'front_4062300278530'),
    ('Milupa', 'MILUPA MILUPINO KINDERMILCH 1 Liter', 'https://images.openfoodfacts.org/images/products/400/897/609/1271/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008976091271', 'front_4008976091271'),
    ('Hipp', 'Apfel Banane in Babykeks', 'https://images.openfoodfacts.org/images/products/406/230/026/9811/front_fr.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300269811', 'front_4062300269811'),
    ('Hipp', 'Pfirsich Aprikose mit Quarkcreme (ab 10. Monat)', 'https://images.openfoodfacts.org/images/products/406/230/037/9503/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300379503', 'front_4062300379503'),
    ('Hipp', 'Hipp Guten Morgen', 'https://images.openfoodfacts.org/images/products/406/230/037/9657/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300379657', 'front_4062300379657'),
    ('DmBio', 'Babyobst', 'https://images.openfoodfacts.org/images/products/405/817/243/8011/front_it.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058172438011', 'front_4058172438011'),
    ('Kölln', 'Schmelzflocken 5 korn 6. Monat', 'https://images.openfoodfacts.org/images/products/400/054/000/2560/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000540002560', 'front_4000540002560'),
    ('Hipp', 'Heidelbeer reiswaffeln', 'https://images.openfoodfacts.org/images/products/406/230/037/6205/front_hr.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300376205', 'front_4062300376205'),
    ('Hipp', 'BIO Getreidebrei 5-Korn', 'https://images.openfoodfacts.org/images/products/406/230/034/4877/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300344877', 'front_4062300344877'),
    ('Hipp', 'Hipp Apfel-banane & Babykeks Ohne Zuckerzusatz', 'https://images.openfoodfacts.org/images/products/406/230/028/9406/front_en.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300289406', 'front_4062300289406'),
    ('Hipp', 'Hipp, Karotten Mit Reis Und Wildlachs', 'https://images.openfoodfacts.org/images/products/406/230/020/8254/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4062300208254', 'front_4062300208254'),
    ('Bebivita', 'Pfirsich mit Maracuja in Apfel', 'https://images.openfoodfacts.org/images/products/401/885/202/9083/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018852029083', 'front_4018852029083')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

-- PIPELINE (Frozen & Prepared): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Frozen & Prepared'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Frosta', 'Bratkartoffel Hähnchen Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/600/1484/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001484', 'front_4008366001484'),
    ('Frosta', 'Fischstäbchen ( Frosta)', 'https://images.openfoodfacts.org/images/products/400/836/601/0387/front_en.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010387', 'front_4008366010387'),
    ('Frosta', 'Hühnerfrikassee', 'https://images.openfoodfacts.org/images/products/400/836/600/8582/front_de.69.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366008582', 'front_4008366008582'),
    ('Frosta', 'Tortellini Käse-Sahne (vegetarisch)', 'https://images.openfoodfacts.org/images/products/400/836/600/9961/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009961', 'front_4008366009961'),
    ('Frosta', 'Gemüse Pfanne alla Toscana', 'https://images.openfoodfacts.org/images/products/400/836/600/6915/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366006915', 'front_4008366006915'),
    ('Frosta', 'Hähnchen Curry', 'https://images.openfoodfacts.org/images/products/400/836/600/1347/front_de.53.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001347', 'front_4008366001347'),
    ('Speisezeit', 'Süßkartoffel-Pommes', 'https://images.openfoodfacts.org/images/products/406/145/812/8407/front_de.46.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458128407', 'front_4061458128407'),
    ('Original Wagner', 'Piccolinis Drei-Käse Pizza', 'https://images.openfoodfacts.org/images/products/400/923/301/4347/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233014347', 'front_4009233014347'),
    ('Dr. Oetker', 'Die Ofenfrische Vier Käse', 'https://images.openfoodfacts.org/images/products/400/172/401/1118/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011118', 'front_4001724011118'),
    ('Frosta', 'Wildlachs in Kräuterrahm', 'https://images.openfoodfacts.org/images/products/400/836/601/5535/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015535', 'front_4008366015535'),
    ('Frosta', 'Paprika Sahne Hähnchen mit Bandnudeln', 'https://images.openfoodfacts.org/images/products/400/836/601/0981/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010981', 'front_4008366010981'),
    ('Frosta', 'Gemüsepfanne a la Provence', 'https://images.openfoodfacts.org/images/products/400/836/600/6953/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366006953', 'front_4008366006953'),
    ('Frosta', 'Gemüse Pfanne Style Asia Curry', 'https://images.openfoodfacts.org/images/products/400/836/600/9336/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009336', 'front_4008366009336'),
    ('Frosta', 'Reis Hähnchen Pfanne', 'https://images.openfoodfacts.org/images/products/400/836/601/0042/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366010042', 'front_4008366010042'),
    ('Golden Seafood', 'Riesengarnelenschwänze - Natur', 'https://images.openfoodfacts.org/images/products/406/145/803/4807/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458034807', 'front_4061458034807'),
    ('Freshona', 'Gemüsepfanne Bio Mediterrane Art', 'https://images.openfoodfacts.org/images/products/405/648/928/9241/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489289241', 'front_4056489289241'),
    ('Frost', 'Pfannenfisch Müllerin Art', 'https://images.openfoodfacts.org/images/products/400/836/601/1964/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366011964', 'front_4008366011964'),
    ('Frosta', 'Gemüse-Bowl - Pikanter Bulgur mit schwarzen Bohnen', 'https://images.openfoodfacts.org/images/products/400/836/688/3448/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883448', 'front_4008366883448'),
    ('Frosta', 'Bami Goreng', 'https://images.openfoodfacts.org/images/products/400/836/600/1309/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366001309', 'front_4008366001309'),
    ('Frosta', 'Butter Chicken', 'https://images.openfoodfacts.org/images/products/400/836/600/3587/front_en.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366003587', 'front_4008366003587'),
    ('Original Wagner', 'Pizza Die Backfrische Mozzarella', 'https://images.openfoodfacts.org/images/products/400/923/300/6847/front_de.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233006847', 'front_4009233006847'),
    ('Frosta', 'Nice Rice - Korean Style', 'https://images.openfoodfacts.org/images/products/400/836/688/3301/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366883301', 'front_4008366883301'),
    ('Dr. Oetker', 'Ristorante PIZZA TONNO', 'https://images.openfoodfacts.org/images/products/400/172/403/8993/front_en.98.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038993', 'front_4001724038993'),
    ('Frosta', 'Paella', 'https://images.openfoodfacts.org/images/products/400/836/601/5337/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015337', 'front_4008366015337'),
    ('Dr. Oetker', 'Suprema Pizza Calabrese & ''Nduja', 'https://images.openfoodfacts.org/images/products/400/172/404/9906/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724049906', 'front_4001724049906'),
    ('Original Wagner', 'Steinofen-Pizza Mozzarella Vegetarisch', 'https://images.openfoodfacts.org/images/products/400/923/300/3952/front_de.128.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003952', 'front_4009233003952'),
    ('Dr. Oetker', 'Die Ofenfrische Margherita', 'https://images.openfoodfacts.org/images/products/400/172/401/5420/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724015420', 'front_4001724015420'),
    ('Greenyard Frozen Langemark', 'Buckwheat & broccoli', 'https://images.openfoodfacts.org/images/products/405/648/945/6476/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489456476', 'front_4056489456476'),
    ('Frosta', 'Fisch Schlemmerfilet Mediterraner Art', 'https://images.openfoodfacts.org/images/products/400/836/600/9787/front_de.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009787', 'front_4008366009787'),
    ('Frosta', 'Fettuccine Wildlachs', 'https://images.openfoodfacts.org/images/products/400/836/601/5511/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366015511', 'front_4008366015511'),
    ('Dr. Oetker', 'Pizza Tradizionale Margherita', 'https://images.openfoodfacts.org/images/products/400/172/403/8597/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038597', 'front_4001724038597'),
    ('Original Wagner', 'Steinofen-Pizza - Diavolo', 'https://images.openfoodfacts.org/images/products/400/923/300/3655/front_de.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003655', 'front_4009233003655'),
    ('Dr. Oetker', 'Die Ofenfrische Speciale', 'https://images.openfoodfacts.org/images/products/400/172/401/1057/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011057', 'front_4001724011057'),
    ('Dr. Oetker', 'Pizza Salame Ristorante', 'https://images.openfoodfacts.org/images/products/400/172/403/8900/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038900', 'front_4001724038900'),
    ('Vemondo', 'Vegan pizza Verdura', 'https://images.openfoodfacts.org/images/products/405/648/945/1044/front_cs.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489451044', 'front_4056489451044'),
    ('Dr. Oetker', 'Die Ofenfrische Salami', 'https://images.openfoodfacts.org/images/products/400/172/401/1170/front_de.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724011170', 'front_4001724011170'),
    ('Frosta', 'Fisch Schlemmerfilet Brokkoli Mandel', 'https://images.openfoodfacts.org/images/products/400/836/600/9763/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366009763', 'front_4008366009763'),
    ('Dr. Oetker', 'La Mia Grande Rucola', 'https://images.openfoodfacts.org/images/products/400/172/404/0538/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724040538', 'front_4001724040538'),
    ('GiaPizza', 'Bio-Dinkel-Steinofenpizza - Spinat', 'https://images.openfoodfacts.org/images/products/406/146/321/3211/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463213211', 'front_4061463213211'),
    ('Nestlé', 'Pizza Speciale', 'https://images.openfoodfacts.org/images/products/400/923/300/3587/front_de.81.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003587', 'front_4009233003587'),
    ('Dr. Oetker', 'La Mia Grande Pizza Margherita', 'https://images.openfoodfacts.org/images/products/400/172/402/7195/front_de.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724027195', 'front_4001724027195'),
    ('Speise Zeit', 'Wellenschnitt Pommes', 'https://images.openfoodfacts.org/images/products/406/145/804/2192/front_en.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458042192', 'front_4061458042192'),
    ('Frosta', 'Nom Nom Noodles', 'https://images.openfoodfacts.org/images/products/400/836/600/0500/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008366000500', 'front_4008366000500'),
    ('Dr. Oetker', 'Pizza Traditionale Verdure Grigliate', 'https://images.openfoodfacts.org/images/products/400/172/403/8658/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724038658', 'front_4001724038658'),
    ('Dr. Oetker', 'Ristorante Pizza Pasta', 'https://images.openfoodfacts.org/images/products/400/172/403/9389/front_en.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001724039389', 'front_4001724039389'),
    ('Nur Nur Natur', 'Bio-Eiscreme - Vanille', 'https://images.openfoodfacts.org/images/products/406/146/282/6344/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462826344', 'front_4061462826344'),
    ('Nestlé', 'Steinofen-Pizza Thunfisch', 'https://images.openfoodfacts.org/images/products/400/923/300/3921/front_de.82.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009233003921', 'front_4009233003921'),
    ('Aldi', 'Pommes Frites', 'https://images.openfoodfacts.org/images/products/406/145/804/1942/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458041942', 'front_4061458041942'),
    ('All Seasons', 'Rahm-Spinat', 'https://images.openfoodfacts.org/images/products/406/145/801/1228/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458011228', 'front_4061458011228'),
    ('Vemondo', 'Pumpkin & quinoa', 'https://images.openfoodfacts.org/images/products/405/648/945/6483/front_en.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489456483', 'front_4056489456483')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Frozen & Prepared' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

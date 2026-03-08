-- PIPELINE (Spreads & Dips): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-08

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Spreads & Dips'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Aldi', 'Vegane Bio-Streichcreme - Kräuter-Tomate', 'https://images.openfoodfacts.org/images/products/406/146/193/7348/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461937348', 'front_4061461937348'),
    ('Noa', 'Noa Brotaufstrich Hummus Kräuter', 'https://images.openfoodfacts.org/images/products/405/809/430/0021/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058094300021', 'front_4058094300021'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 'https://images.openfoodfacts.org/images/products/406/145/939/7161/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459397161', 'front_4061459397161'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 'https://images.openfoodfacts.org/images/products/406/145/939/7048/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459397048', 'front_4061459397048'),
    ('Unknown', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 'https://images.openfoodfacts.org/images/products/406/145/967/3012/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459673012', 'front_4061459673012'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 'https://images.openfoodfacts.org/images/products/406/145/939/7116/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459397116', 'front_4061459397116'),
    ('Menken Salades & Sauzen', 'Hummus - Kürbis', 'https://images.openfoodfacts.org/images/products/406/145/802/4082/front_de.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024082', 'front_4061458024082'),
    ('Milram', 'Fein-würzige Sour Cream', 'https://images.openfoodfacts.org/images/products/000/004/046/6156/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 40466156', 'front_40466156'),
    ('BLM', 'Bruschetta-Creme mit Paprika und Ricottakäse', 'https://images.openfoodfacts.org/images/products/406/146/259/1938/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462591938', 'front_4061462591938'),
    ('Sun Snacks', 'Salsa Dip Käse', 'https://images.openfoodfacts.org/images/products/406/146/392/9853/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463929853', 'front_4061463929853'),
    ('Kühlmann', 'Kichererbsenpüree', 'https://images.openfoodfacts.org/images/products/405/100/904/1989/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4051009041989', 'front_4051009041989'),
    ('W', 'Bio Hummus - Kichererbsenpüree mit Sesam und rotem Pesto', 'https://images.openfoodfacts.org/images/products/406/146/264/2463/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462642463', 'front_4061462642463'),
    ('Schätze des Orients', 'Hummus Natur', 'https://images.openfoodfacts.org/images/products/406/145/802/4068/front_de.101.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024068', 'front_4061458024068'),
    ('NOA', 'Hummus , Natur', 'https://images.openfoodfacts.org/images/products/405/809/430/0014/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058094300014', 'front_4058094300014'),
    ('Heinrich Kuhmann GmbH', 'Hummus - Pikant', 'https://images.openfoodfacts.org/images/products/406/145/802/4037/front_de.116.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458024037', 'front_4061458024037'),
    ('K Bio (Kaufland)', 'Bio Hummus Classic', 'https://images.openfoodfacts.org/images/products/406/336/740/5440/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367405440', 'front_4063367405440'),
    ('Noa', 'Hummus Paprika-Chili', 'https://images.openfoodfacts.org/images/products/405/809/430/0083/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058094300083', 'front_4058094300083'),
    ('My Vay', 'Bio Streichcreme', 'https://images.openfoodfacts.org/images/products/406/146/193/7430/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461937430', 'front_4061461937430'),
    ('DmBio', 'Hummus Natur', 'https://images.openfoodfacts.org/images/products/406/779/601/0831/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796010831', 'front_4067796010831'),
    ('Chef Select', 'Bio Hummus Natur', 'https://images.openfoodfacts.org/images/products/405/648/955/0600/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489550600', 'front_4056489550600'),
    ('Kaufland', 'Veganer Hummus Classic', 'https://images.openfoodfacts.org/images/products/406/336/717/0713/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367170713', 'front_4063367170713'),
    ('Deluxe', 'Hummus und Guacamole', 'https://images.openfoodfacts.org/images/products/405/648/945/9545/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489459545', 'front_4056489459545'),
    ('Noa', 'Brotaufstrich Kichererbse Tomate-Basilikum', 'https://images.openfoodfacts.org/images/products/405/809/431/0105/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058094310105', 'front_4058094310105'),
    ('Aldi', 'Vegane Bio-Streichcreme - Aubergine', 'https://images.openfoodfacts.org/images/products/406/146/193/7362/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461937362', 'front_4061461937362'),
    ('Chef select', 'Bio organic humus', 'https://images.openfoodfacts.org/images/products/405/648/955/0617/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489550617', 'front_4056489550617'),
    ('Feinkost Popp', 'Hummus Klassisch', 'https://images.openfoodfacts.org/images/products/404/580/071/9635/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045800719635', 'front_4045800719635'),
    ('Milbona', 'Zaziki', 'https://images.openfoodfacts.org/images/products/405/648/966/5588/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489665588', 'front_4056489665588'),
    ('Aldi', 'Bio-Hummus - Natur', 'https://images.openfoodfacts.org/images/products/406/146/182/5140/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461825140', 'front_4061461825140'),
    ('Aldi', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 'https://images.openfoodfacts.org/images/products/406/146/193/7409/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461937409', 'front_4061461937409'),
    ('Chef Select', 'Guacamole scharf', 'https://images.openfoodfacts.org/images/products/405/648/996/3004/front_de.51.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489963004', 'front_4056489963004'),
    ('Nur Nur Natur', 'Bio Humus Paprika Kurkuma Chili', 'https://images.openfoodfacts.org/images/products/406/146/155/9175/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461559175', 'front_4061461559175'),
    ('Nur Nur Natur', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 'https://images.openfoodfacts.org/images/products/406/146/156/8948/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461568948', 'front_4061461568948'),
    ('Nabio', 'Gegrillte Paprika Cashew', 'https://images.openfoodfacts.org/images/products/401/318/202/4098/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013182024098', 'front_4013182024098'),
    ('Chef Select', 'Guacamole Avocado-Dip mild', 'https://images.openfoodfacts.org/images/products/405/648/924/2079/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489242079', 'front_4056489242079'),
    ('Wonnemeyer', 'Antipasticreme - Feta', 'https://images.openfoodfacts.org/images/products/406/145/802/3238/front_de.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458023238', 'front_4061458023238'),
    ('Nur Nur Natur', 'Bio-Hummus - Tomate', 'https://images.openfoodfacts.org/images/products/406/146/182/5225/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461825225', 'front_4061461825225'),
    ('Popp', 'Brotaufstrich Bruschetta', 'https://images.openfoodfacts.org/images/products/404/580/050/5269/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4045800505269', 'front_4045800505269'),
    ('Kaufland', 'Guacamole', 'https://images.openfoodfacts.org/images/products/406/336/714/6978/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367146978', 'front_4063367146978'),
    ('Chef select', 'Hummus Nature', 'https://images.openfoodfacts.org/images/products/405/648/945/6544/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489456544', 'front_4056489456544'),
    ('Kühlmann', 'Hummus Trio', 'https://images.openfoodfacts.org/images/products/405/100/902/6733/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4051009026733', 'front_4051009026733'),
    ('Aldi', 'Bio-Hummus - Rote Beete', 'https://images.openfoodfacts.org/images/products/406/146/182/5263/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461825263', 'front_4061461825263'),
    ('Chef Select', 'Hummus bruschetta', 'https://images.openfoodfacts.org/images/products/405/648/945/9514/front_cs.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489459514', 'front_4056489459514'),
    ('Aldi', 'Bio-Hummus - Paprika', 'https://images.openfoodfacts.org/images/products/406/146/182/5249/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461825249', 'front_4061461825249'),
    ('Grossmann', 'Knoblauch-Dip', 'https://images.openfoodfacts.org/images/products/400/649/516/2700/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006495162700', 'front_4006495162700'),
    ('Kaufland', 'Hummus mit Topping Grünes Pesto', 'https://images.openfoodfacts.org/images/products/405/100/903/5636/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4051009035636', 'front_4051009035636'),
    ('Wonnemeyer', 'Antipasticreme - Dattel-Curry', 'https://images.openfoodfacts.org/images/products/404/724/762/2004/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247622004', 'front_4047247622004'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 'https://images.openfoodfacts.org/images/products/406/145/939/7062/front_de.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459397062', 'front_4061459397062'),
    ('Chef Select', 'Kirschpaprika Antipasti-Creme', 'https://images.openfoodfacts.org/images/products/405/648/900/8170/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489008170', 'front_4056489008170'),
    ('Noa', 'Hummus Dattel Curry', 'https://images.openfoodfacts.org/images/products/405/809/430/0113/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4058094300113', 'front_4058094300113'),
    ('Chio', 'Hot Cheese Dip!', 'https://images.openfoodfacts.org/images/products/400/124/210/8239/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242108239', 'front_4001242108239'),
    ('Chio', 'Chip dip', 'https://images.openfoodfacts.org/images/products/400/124/210/8222/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001242108222', 'front_4001242108222')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spreads & Dips' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

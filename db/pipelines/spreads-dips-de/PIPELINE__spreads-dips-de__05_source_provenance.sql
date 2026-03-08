-- PIPELINE (Spreads & Dips): source provenance
-- Generated: 2026-03-08

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Aldi', 'Vegane Bio-Streichcreme - Kräuter-Tomate', 'https://world.openfoodfacts.org/product/4061461937348', '4061461937348'),
    ('Noa', 'Noa Brotaufstrich Hummus Kräuter', 'https://world.openfoodfacts.org/product/4058094300021', '4058094300021'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 'https://world.openfoodfacts.org/product/4061459397161', '4061459397161'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 'https://world.openfoodfacts.org/product/4061459397048', '4061459397048'),
    ('Unknown', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 'https://world.openfoodfacts.org/product/4061459673012', '4061459673012'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 'https://world.openfoodfacts.org/product/4061459397116', '4061459397116'),
    ('Menken Salades & Sauzen', 'Hummus - Kürbis', 'https://world.openfoodfacts.org/product/4061458024082', '4061458024082'),
    ('Milram', 'Fein-würzige Sour Cream', 'https://world.openfoodfacts.org/product/40466156', '40466156'),
    ('BLM', 'Bruschetta-Creme mit Paprika und Ricottakäse', 'https://world.openfoodfacts.org/product/4061462591938', '4061462591938'),
    ('Sun Snacks', 'Salsa Dip Käse', 'https://world.openfoodfacts.org/product/4061463929853', '4061463929853'),
    ('Kühlmann', 'Kichererbsenpüree', 'https://world.openfoodfacts.org/product/4051009041989', '4051009041989'),
    ('W', 'Bio Hummus - Kichererbsenpüree mit Sesam und rotem Pesto', 'https://world.openfoodfacts.org/product/4061462642463', '4061462642463'),
    ('Schätze des Orients', 'Hummus Natur', 'https://world.openfoodfacts.org/product/4061458024068', '4061458024068'),
    ('NOA', 'Hummus , Natur', 'https://world.openfoodfacts.org/product/4058094300014', '4058094300014'),
    ('Heinrich Kuhmann GmbH', 'Hummus - Pikant', 'https://world.openfoodfacts.org/product/4061458024037', '4061458024037'),
    ('K Bio (Kaufland)', 'Bio Hummus Classic', 'https://world.openfoodfacts.org/product/4063367405440', '4063367405440'),
    ('Noa', 'Hummus Paprika-Chili', 'https://world.openfoodfacts.org/product/4058094300083', '4058094300083'),
    ('My Vay', 'Bio Streichcreme', 'https://world.openfoodfacts.org/product/4061461937430', '4061461937430'),
    ('DmBio', 'Hummus Natur', 'https://world.openfoodfacts.org/product/4067796010831', '4067796010831'),
    ('Chef Select', 'Bio Hummus Natur', 'https://world.openfoodfacts.org/product/4056489550600', '4056489550600'),
    ('Kaufland', 'Veganer Hummus Classic', 'https://world.openfoodfacts.org/product/4063367170713', '4063367170713'),
    ('Deluxe', 'Hummus und Guacamole', 'https://world.openfoodfacts.org/product/4056489459545', '4056489459545'),
    ('Noa', 'Brotaufstrich Kichererbse Tomate-Basilikum', 'https://world.openfoodfacts.org/product/4058094310105', '4058094310105'),
    ('Aldi', 'Vegane Bio-Streichcreme - Aubergine', 'https://world.openfoodfacts.org/product/4061461937362', '4061461937362'),
    ('Chef select', 'Bio organic humus', 'https://world.openfoodfacts.org/product/4056489550617', '4056489550617'),
    ('Feinkost Popp', 'Hummus Klassisch', 'https://world.openfoodfacts.org/product/4045800719635', '4045800719635'),
    ('Milbona', 'Zaziki', 'https://world.openfoodfacts.org/product/4056489665588', '4056489665588'),
    ('Aldi', 'Bio-Hummus - Natur', 'https://world.openfoodfacts.org/product/4061461825140', '4061461825140'),
    ('Aldi', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 'https://world.openfoodfacts.org/product/4061461937409', '4061461937409'),
    ('Chef Select', 'Guacamole scharf', 'https://world.openfoodfacts.org/product/4056489963004', '4056489963004'),
    ('Nur Nur Natur', 'Bio Humus Paprika Kurkuma Chili', 'https://world.openfoodfacts.org/product/4061461559175', '4061461559175'),
    ('Nur Nur Natur', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 'https://world.openfoodfacts.org/product/4061461568948', '4061461568948'),
    ('Nabio', 'Gegrillte Paprika Cashew', 'https://world.openfoodfacts.org/product/4013182024098', '4013182024098'),
    ('Chef Select', 'Guacamole Avocado-Dip mild', 'https://world.openfoodfacts.org/product/4056489242079', '4056489242079'),
    ('Wonnemeyer', 'Antipasticreme - Feta', 'https://world.openfoodfacts.org/product/4061458023238', '4061458023238'),
    ('Nur Nur Natur', 'Bio-Hummus - Tomate', 'https://world.openfoodfacts.org/product/4061461825225', '4061461825225'),
    ('Popp', 'Brotaufstrich Bruschetta', 'https://world.openfoodfacts.org/product/4045800505269', '4045800505269'),
    ('Kaufland', 'Guacamole', 'https://world.openfoodfacts.org/product/4063367146978', '4063367146978'),
    ('Chef select', 'Hummus Nature', 'https://world.openfoodfacts.org/product/4056489456544', '4056489456544'),
    ('Kühlmann', 'Hummus Trio', 'https://world.openfoodfacts.org/product/4051009026733', '4051009026733'),
    ('Aldi', 'Bio-Hummus - Rote Beete', 'https://world.openfoodfacts.org/product/4061461825263', '4061461825263'),
    ('Chef Select', 'Hummus bruschetta', 'https://world.openfoodfacts.org/product/4056489459514', '4056489459514'),
    ('Aldi', 'Bio-Hummus - Paprika', 'https://world.openfoodfacts.org/product/4061461825249', '4061461825249'),
    ('Grossmann', 'Knoblauch-Dip', 'https://world.openfoodfacts.org/product/4006495162700', '4006495162700'),
    ('Kaufland', 'Hummus mit Topping Grünes Pesto', 'https://world.openfoodfacts.org/product/4051009035636', '4051009035636'),
    ('Wonnemeyer', 'Antipasticreme - Dattel-Curry', 'https://world.openfoodfacts.org/product/4047247622004', '4047247622004'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 'https://world.openfoodfacts.org/product/4061459397062', '4061459397062'),
    ('Chef Select', 'Kirschpaprika Antipasti-Creme', 'https://world.openfoodfacts.org/product/4056489008170', '4056489008170'),
    ('Noa', 'Hummus Dattel Curry', 'https://world.openfoodfacts.org/product/4058094300113', '4058094300113'),
    ('Chio', 'Hot Cheese Dip!', 'https://world.openfoodfacts.org/product/4001242108239', '4001242108239'),
    ('Chio', 'Chip dip', 'https://world.openfoodfacts.org/product/4001242108222', '4001242108222')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Spreads & Dips' AND p.is_deprecated IS NOT TRUE;

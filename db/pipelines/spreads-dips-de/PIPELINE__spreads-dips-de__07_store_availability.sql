-- PIPELINE (Spreads & Dips): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-08

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Aldi', 'Vegane Bio-Streichcreme - Kräuter-Tomate', 'Aldi'),
    ('Noa', 'Noa Brotaufstrich Hummus Kräuter', 'REWE'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Grüne Oliven, Aprikosen & Mandeln', 'Aldi'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Tomaten, Walnüsse & Basilikum', 'Aldi'),
    ('Unknown', 'Hummus Kürbis Kürbis Kichererbsenpüree mit Kürbis und Sesam', 'Aldi'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Rote Linsen, Tomaten & Kürbis', 'Aldi'),
    ('Menken Salades & Sauzen', 'Hummus - Kürbis', 'Aldi'),
    ('Schätze des Orients', 'Hummus Natur', 'Aldi'),
    ('NOA', 'Hummus , Natur', 'Kaufland'),
    ('NOA', 'Hummus , Natur', 'Real'),
    ('Heinrich Kuhmann GmbH', 'Hummus - Pikant', 'Aldi'),
    ('K Bio (Kaufland)', 'Bio Hummus Classic', 'Kaufland'),
    ('Noa', 'Hummus Paprika-Chili', 'Lidl'),
    ('Noa', 'Hummus Paprika-Chili', 'Edeka'),
    ('Noa', 'Hummus Paprika-Chili', 'REWE'),
    ('Noa', 'Hummus Paprika-Chili', 'Netto'),
    ('Noa', 'Hummus Paprika-Chili', 'Kaufland'),
    ('My Vay', 'Bio Streichcreme', 'Aldi'),
    ('DmBio', 'Hummus Natur', 'dm'),
    ('Chef Select', 'Bio Hummus Natur', 'Lidl'),
    ('Kaufland', 'Veganer Hummus Classic', 'Kaufland'),
    ('Deluxe', 'Hummus und Guacamole', 'Lidl'),
    ('Noa', 'Brotaufstrich Kichererbse Tomate-Basilikum', 'REWE'),
    ('Aldi', 'Vegane Bio-Streichcreme - Aubergine', 'Aldi'),
    ('Chef select', 'Bio organic humus', 'Lidl'),
    ('Milbona', 'Zaziki', 'Lidl'),
    ('Aldi', 'Bio-Hummus - Natur', 'Aldi'),
    ('Aldi', 'Vegane Bio-Streichcreme - Rote Bete-Meerrettich', 'Aldi'),
    ('Chef Select', 'Guacamole scharf', 'Lidl'),
    ('Nur Nur Natur', 'Bio Humus Paprika Kurkuma Chili', 'Aldi'),
    ('Nur Nur Natur', 'Bio-Hummus - Rote Bete, Meerrettich, Hibiskus', 'Aldi'),
    ('Nabio', 'Gegrillte Paprika Cashew', 'REWE'),
    ('Chef Select', 'Guacamole Avocado-Dip mild', 'Lidl'),
    ('Wonnemeyer', 'Antipasticreme - Feta', 'Aldi'),
    ('Nur Nur Natur', 'Bio-Hummus - Tomate', 'Aldi'),
    ('Popp', 'Brotaufstrich Bruschetta', 'REWE'),
    ('Kaufland', 'Guacamole', 'Kaufland'),
    ('Chef select', 'Hummus Nature', 'Lidl'),
    ('Kühlmann', 'Hummus Trio', 'Edeka'),
    ('Aldi', 'Bio-Hummus - Rote Beete', 'Aldi'),
    ('Chef Select', 'Hummus bruschetta', 'Lidl'),
    ('Aldi', 'Bio-Hummus - Paprika', 'Aldi'),
    ('Grossmann', 'Knoblauch-Dip', 'REWE'),
    ('Wonnemeyer', 'Antipasticreme - Dattel-Curry', 'Aldi'),
    ('Lyttos', 'Griechischer Pitabrot-Dip - Paprika, Feta & Tomaten', 'Aldi'),
    ('Chef Select', 'Kirschpaprika Antipasti-Creme', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spreads & Dips' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

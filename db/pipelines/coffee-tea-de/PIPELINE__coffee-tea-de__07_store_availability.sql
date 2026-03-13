-- PIPELINE (Coffee & Tea): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-13

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Nestlé', 'Caro Landkaffee extra kräftig', 'REWE'),
    ('Grana', 'Feiner Landkaffee Aus Vollem Korn Geröstet, Kaffee', 'Kaufland'),
    ('Amaroy', 'Entkoffeiniert Premium Löslicher Kaffee', 'Aldi'),
    ('Nestlé', 'Nescafé Classic', 'Lidl'),
    ('Lemonaid Beverages GmbH', 'Café Intención eclógico', 'Edeka'),
    ('Krüger', 'Cappuccino Schoko', 'Edeka'),
    ('Tchibo', 'Barista Caffè Crema Bohnen', 'REWE'),
    ('Hearts', 'Cappuccino mit feiner Kakaonote', 'Lidl'),
    ('Aldi', 'Cappuccino Schoko', 'Aldi'),
    ('Aldi', 'Family cappuccino', 'Aldi'),
    ('Ehrmann', 'Protein Caffe Latte', 'Lidl'),
    ('DmBio', 'Kaffee Klassik Gemahlen', 'dm'),
    ('DmBio', 'Espresso gemahlen', 'dm'),
    ('J.J. Darboven GmbH & Co KG', 'Café intención ecológico', 'Kaufland'),
    ('Krüger', 'Cappuccino Stracciatella', 'Edeka'),
    ('Krüger', 'Cappuccino Stracciatella', 'REWE'),
    ('Ja!', 'Typ Cappuccino - weniger süß im Geschmack', 'REWE'),
    ('Cafèt', 'Latte Macchiato weniger süß', 'Netto'),
    ('Rewe', 'Extra löslicher Kaffee', 'REWE'),
    ('Gut & Günstig', 'Latte Macchiato - weniger süß', 'Edeka'),
    ('Edeka', 'Getränkepulver Typ Cappuccino (weniger süß)', 'Edeka'),
    ('Nestlé', 'Nescafé Cappuccino - weniger süß', 'REWE'),
    ('Cafèt', 'Löslicher Kaffee, kräftig', 'Netto'),
    ('Cafèt', 'Latte Espresso', 'Netto'),
    ('Bellarom', 'Family Cappuccino Chocolate', 'Lidl'),
    ('Illy', 'Illy Classico 100% Arabica, 250g', 'Kaufland'),
    ('Jacobs', 'Classic 3in1', 'Lidl'),
    ('Fairglobe', 'Café bio fairglobe', 'Lidl'),
    ('Cafèt', 'Latte Cappuccino', 'Netto'),
    ('Cafèt', 'Typ Cappuccino Classico', 'Netto'),
    ('Bellarom', 'Cappuccino Caramel', 'Lidl'),
    ('Cafet', 'Family Cappucino Schoko', 'Netto'),
    ('Edeka', 'Cappuccino', 'Edeka'),
    ('Lavazza', 'Café Bio-Organic', 'Edeka'),
    ('Emmi', 'Caffè Latte', 'Edeka'),
    ('Emmi', 'Caffè Latte', 'Netto'),
    ('Ja!', 'Cappuccino Family mit feiner Kakaonote', 'REWE'),
    ('Gut & Günstig', 'Latte espresso', 'Edeka'),
    ('Edeka Bio', 'Edeka Bio Espresso', 'Edeka'),
    ('Emmi', 'Caffè Latte High Protein', 'Aldi'),
    ('Gut & Günstig', 'Cold Latte Espresso', 'Edeka'),
    ('Edeka Bio', 'Caffe Crema Kaffeepads', 'Edeka'),
    ('Milbona', 'Cappucino', 'Lidl'),
    ('Edeka', 'Family Cappuccino Schoko', 'Edeka'),
    ('Nescafe', 'Nescafé Classic Mild Instantkaffee', 'Kaufland'),
    ('Cafet', 'Typ Cappuccino Vanille', 'Netto'),
    ('Tassimo', 'Tassimo Morning Café Strong XL', 'REWE'),
    ('Emmi', 'Caffè Latte Double Zero Macchiato', 'Netto'),
    ('Penny', 'Caffé Latte Espresso', 'Penny'),
    ('K to go', 'Latte Macchiato', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Coffee & Tea' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

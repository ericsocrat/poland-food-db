-- PIPELINE (Sauces): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-04

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('DmBio', 'Tomatensoße Klassik', 'dm'),
    ('Hengstenberg', 'Tomaten stückig mit Kräutern', 'REWE'),
    ('Bautz''ner', 'Fix Tomatensoße', 'Lidl'),
    ('DmBio', 'Tomatensoße Arrabbiata', 'dm'),
    ('InnFood Organic', 'Bio-Tomatensauce - Gemüse und Parmesan', 'Aldi'),
    ('Aldi', 'Passierte Tomaten', 'Aldi'),
    ('DmBio', 'Tomatensauce - Ricotta Pecorino', 'dm'),
    ('King''s Crown', 'Passata', 'Aldi'),
    ('Oro Di Parma', 'Pizzasauce Oregano', 'REWE'),
    ('InnFood Organic', 'Bio-Tomatensauce - Basilikum', 'Aldi'),
    ('DmBio', 'Tomatensauce - gegrillte Paprika', 'dm'),
    ('InnFood Organic', 'Bio-Tomatensauce - Arrabiata', 'Aldi'),
    ('Clama', 'Tomate Frito', 'Aldi'),
    ('Cucina', 'Pasta-Sauce Arrabbiata', 'Aldi'),
    ('Mars', 'Pastasauce Miracoli Klassiker', 'REWE'),
    ('Alnatura', 'Passata', 'Edeka'),
    ('Oro', 'Pastasauce Classico', 'Kaufland'),
    ('Cucina', 'Pasta-Sauce - Napoletana', 'Aldi'),
    ('REWE Bio', 'Tomatensauce Kräuter', 'REWE'),
    ('Barilla', 'Toscana Kräuter', 'Lidl'),
    ('Barilla', 'Toscana Kräuter', 'REWE'),
    ('REWE Beste Wahl', 'Stückige Tomaten', 'REWE'),
    ('Rewe', 'Kräuter Knoblauch Saucenbasis', 'REWE'),
    ('Barilla', 'Basilico 400g eu', 'Aldi'),
    ('Barilla', 'Basilico 400g eu', 'Lidl'),
    ('Baresa', 'Tomatenmark', 'Lidl'),
    ('Baresa', 'Passierte Tomate', 'Lidl'),
    ('Gut & Günstig', 'Passierte Tomaten', 'Edeka'),
    ('Mutti', 'Triplo concentrato di pomodoro', 'REWE'),
    ('Mutti', 'Triplo concentrato di pomodoro', 'Tegut'),
    ('Barilla', 'Arrabbiata', 'Lidl'),
    ('EDEKA Bio', 'Passata, passierte Tomaten - Bio', 'Edeka'),
    ('Ppura', 'Vegane Bolognese', 'REWE'),
    ('Barilla', 'Napoletana', 'Lidl'),
    ('Barilla', 'Ricotta', 'Edeka'),
    ('Combino', 'Bolognese', 'Lidl'),
    ('Baresa', 'Passierte Tomaten', 'Lidl'),
    ('Ja!', 'Tomatensauce mit Basilikum', 'REWE'),
    ('Mutti', 'Pizzasauce Aromatica', 'REWE'),
    ('Combino', 'Arrabbiata', 'Lidl'),
    ('REWE Bio', 'Passata Tomaten', 'REWE'),
    ('Barilla', 'Verdure mediterranee 400g eu cross', 'REWE'),
    ('REWE Bio', 'Tomatensauce Ricotta', 'REWE'),
    ('Alnatura', 'Tomatensauce Toscana', 'Edeka'),
    ('Rewe', 'Tomate Ricotta mit Basilikum', 'REWE')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Sauces' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

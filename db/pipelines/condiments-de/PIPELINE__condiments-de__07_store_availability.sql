-- PIPELINE (Condiments): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-12

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Hela', 'Gewürz Ketchup Curry', 'REWE'),
    ('Hela', 'Gewürz Ketchup Curry', 'Kaufland'),
    ('Aldi', 'Curry-Gewürzketchup - delikat', 'Aldi'),
    ('Werder', 'Gewürz Ketchup', 'Netto'),
    ('Delikato', 'Curry-Gewürzketchup - scharf', 'Aldi'),
    ('American', 'Würzsauce 2 in 1 - Ketchup & Senf', 'Aldi'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'REWE'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'Netto'),
    ('Gourmet Finest Cuisine', 'Trüffel-Ketchup mit Meersalz', 'Aldi'),
    ('Hela', 'Curry Gewürz Ketchup, Scharf', 'Aldi'),
    ('Jütro', 'Newmoji Tomatenketchup für Kinder', 'Aldi'),
    ('Jütro', 'Newmoji Tomatenketchup für Kinder', 'Kaufland'),
    ('Delikato', 'Tomatenketchup', 'Aldi'),
    ('Kania', 'Ketchup', 'Lidl'),
    ('DmBio', 'Jemný kečup', 'dm'),
    ('Kania', 'Tomato Ketchup', 'Lidl'),
    ('Werder', 'Tomatenketchup von Werder', 'Aldi'),
    ('Werder', 'Tomatenketchup von Werder', 'Edeka'),
    ('Werder', 'Tomatenketchup von Werder', 'Netto'),
    ('Werder', 'Tomatenketchup von Werder', 'Kaufland'),
    ('Jütro', 'Tomaten Ketchup', 'Lidl'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Klassik', 'Aldi'),
    ('Delikato', 'Tomatenketchup Light', 'Aldi'),
    ('Kania', 'Kečup', 'Lidl'),
    ('La Vialla', 'Premium Tomatenketchup', 'Kaufland'),
    ('Werder', 'Barbecue Sauce', 'Netto'),
    ('Nur Nur Natur', 'Bio-Tomatenketchup - Curry', 'Aldi'),
    ('Gourmet Finest Cuisine', 'Steakhouse-Ketchup mit Fleur de Sel', 'Aldi'),
    ('Hela', 'Curry Ketchup', 'Aldi'),
    ('Werder', 'Gelber Ketchup', 'Kaufland'),
    ('Werder', 'Bierketchup', 'Edeka'),
    ('HELA Gewürz Ketchup', 'Gehackte Tomaten mit Basilikum', 'Kaufland'),
    ('DmBio', 'Tomaten ketchup', 'dm'),
    ('Kaufland', 'Hot tomaten ketchup', 'Kaufland'),
    ('Werder Feinkost', 'Kinder Tomaten Ketchup', 'Edeka'),
    ('Werder Feinkost', 'Tomaten Ketchup', 'REWE'),
    ('Delikato', 'Tomatenketchup - Hot Chili', 'Aldi'),
    ('Curry36', 'Tomaten Ketchup Curry 36', 'REWE'),
    ('Hela', 'Kruidenketchup', 'REWE'),
    ('Hela', 'Kruidenketchup', 'Netto'),
    ('Baumann''s', 'Bayerisch Ketchup', 'REWE'),
    ('Le Gusto', 'Ketchup', 'Aldi'),
    ('K-Classic', 'Curry Gewürz Ketchup scharf', 'Kaufland'),
    ('Gut und Günstig', 'Curry Gewürz Ketchup', 'Edeka'),
    ('Ja!', 'Ja! Curry Gewürzketchup', 'REWE'),
    ('Netto', 'Curry Gewürz Ketchup', 'Netto'),
    ('Kaufland', 'Curry Gewürz-Ketchup', 'Kaufland'),
    ('Rich', 'Hot Curry Gewürz Ketchup', 'Netto'),
    ('Delikato', 'Curry gewürz ketchup', 'Aldi'),
    ('Sunred', 'Curry Gewürz Ketchup', 'Norma'),
    ('Ja!', 'Ja Gewürzketchup', 'REWE'),
    ('Gut & Günstig', 'Gut & Günstig Curry Gewürz Ketchup', 'Edeka'),
    ('Heinz', 'Tomato Ketchup', 'Aldi'),
    ('Heinz', 'Tomato Ketchup', 'Lidl'),
    ('Heinz', 'Tomato Ketchup', 'Edeka'),
    ('Heinz', 'Tomato Ketchup', 'REWE'),
    ('Heinz', 'Zero Tomaten Ketchup', 'Aldi'),
    ('Heinz', 'Zero Tomaten Ketchup', 'REWE'),
    ('Rewe Bio', 'Ketchup', 'REWE'),
    ('Alnatura', 'Tomaten Ketchup', 'Tegut')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Condiments' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

-- PIPELINE (Condiments): store availability
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
    ('Hela', 'Gewürzketchup Curry', 'REWE'),
    ('Hela', 'Gewürzketchup Curry', 'Kaufland'),
    ('Aldi', 'Curry-Gewürzketchup - delikat', 'Aldi'),
    ('Werder', 'Gewürz Ketchup', 'Netto'),
    ('Delikato', 'Curry-Gewürzketchup - scharf', 'Aldi'),
    ('American', 'Würzsauce 2 in 1 - Ketchup & Senf', 'Aldi'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'REWE'),
    ('HELA Gewürz Ketchup', 'Gewürz Ketchup Curry Scharf', 'Netto'),
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
    ('K-Classic', 'Curry Gewürz Ketchup scharf', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Condiments' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

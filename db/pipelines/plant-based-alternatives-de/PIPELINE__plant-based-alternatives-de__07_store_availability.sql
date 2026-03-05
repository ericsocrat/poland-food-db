-- PIPELINE (Plant-Based & Alternatives): store availability
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
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'Edeka'),
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'REWE'),
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'Kaufland'),
    ('Rügenwalder Mühle', 'Veganer Schinken-Spicker Grillgemüse', 'Tegut'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Aldi'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Lidl'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Edeka'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'REWE'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Netto'),
    ('Rügenwalder Mühle', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Kaufland'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'Aldi'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'Lidl'),
    ('Bürger', 'Maultaschen traditionell schwäbisch', 'REWE'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'Edeka'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'REWE'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'Penny'),
    ('Rügenwalder Mühle', 'Vegane Mühlen Nuggets Klassisch', 'Kaufland'),
    ('DmBio', 'Maiswaffeln', 'dm'),
    ('REWE Bio +vegan', 'Räucher-Tofu', 'REWE'),
    ('Rewe', 'Falafel bällchen', 'REWE'),
    ('Like Meat', 'Like Grilled Chicken', 'REWE'),
    ('Like Meat', 'Like Chicken', 'Edeka'),
    ('Like Meat', 'Like Chicken', 'REWE'),
    ('Baresa', 'Tomatenmark 2-Fach Konzentriert', 'Lidl'),
    ('Freshona', 'Cornichons Gurken', 'Lidl'),
    ('Freshona', 'Cornichons Gurken', 'Norma'),
    ('REWE Bio', 'Tofu Natur', 'REWE'),
    ('Baresa', 'Tomaten passiert', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Plant-Based & Alternatives' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

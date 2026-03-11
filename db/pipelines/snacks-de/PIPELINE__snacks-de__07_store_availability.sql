-- PIPELINE (Snacks): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-11

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Pom-Bär', 'POM-BÄR Original', 'Edeka'),
    ('Pom-Bär', 'POM-BÄR Original', 'Netto'),
    ('Huober', 'Original schwäbische Knusper Brezel', 'Edeka'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'Edeka'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'REWE'),
    ('Schwartauer Corny', 'Haferkraft Cranberry Kürbiskern', 'Netto'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'Lidl'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'Edeka'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'REWE'),
    ('Lorenz', 'Lorenz Saltletts Sticks', 'Netto'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 'Edeka'),
    ('Corny', 'Haferkraft Zero - Kakao 4er-Pack', 'REWE'),
    ('Lorenz', 'Clubs Cracker', 'Aldi'),
    ('Lorenz', 'Clubs Cracker', 'Lidl'),
    ('Lorenz', 'Clubs Cracker', 'Edeka'),
    ('Lorenz', 'Clubs Cracker', 'REWE'),
    ('Lorenz', 'Clubs Cracker', 'Kaufland'),
    ('Seeberger', 'Nuts''n Berries', 'Edeka'),
    ('Corny', 'Nussvoll Nuss &Traube', 'REWE'),
    ('Corny', 'Milch Classic', 'REWE'),
    ('Tuc', 'Tuc Original', 'REWE'),
    ('Pågen', 'Gifflar Cannelle', 'Aldi'),
    ('Alnatura', 'Linsenwaffeln', 'Edeka'),
    ('Alesto', 'Cruspies Paprika', 'Lidl'),
    ('Snack Day', 'Erdnuss Flips', 'Lidl'),
    ('KoRo', 'Vegan Protein Bar Chocolate Brownie', 'REWE'),
    ('KoRo', 'Protein Bar Deluxe', 'dm'),
    ('REWE Bio', 'Dattel-Erdnuss Riegel (3er)', 'REWE')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

-- PIPELINE (Baby): store availability
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
    ('Hipp', 'Früchte Riegel Joghurt-Kirsch in Banane', 'Edeka'),
    ('Mamia Bio', 'Bio-Fruchtpüree - Apfel-Birne-Aprikose', 'Aldi'),
    ('DmBio', 'Kürbis pur', 'dm'),
    ('Bebivita', 'Mini-Makkaroni mit buntem Rahmgemüse', 'REWE'),
    ('Hipp', 'Reiner Butternut Kürbis', 'dm'),
    ('Hipp', 'Menü Karotten, Kartoffeln, Wildlachs', 'dm'),
    ('Hipp', 'Gemüse Kürbis Nach Dem 4. Monat', 'dm'),
    ('Hipp', 'Hippis Pfirsich Banane Mango Joghurt', 'Edeka'),
    ('Hipp', 'Hippis Pfirsich Banane Mango Joghurt', 'REWE'),
    ('DmBio', 'Hirse Getreidebrei', 'dm'),
    ('Hipp', 'Pfirsich in Apfel (ab 5. Monat)', 'dm'),
    ('Hipp', 'Williams Christ-Birnen mit Apfel (ab 5. Monat)', 'dm'),
    ('DmBio', 'Apfel mit Banane & Hirse (ab 6. Monat)', 'dm'),
    ('Bebivita', 'Anfangsmilch', 'Lidl'),
    ('Bebivita', 'Anfangsmilch', 'Penny'),
    ('Bebivita', 'Anfangsmilch', 'dm')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

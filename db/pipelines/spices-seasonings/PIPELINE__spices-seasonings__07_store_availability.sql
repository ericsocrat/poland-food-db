-- PIPELINE (Spices & Seasonings): store availability
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
    ('Kucharek', 'Przyprawa do potraw z obniżoną zawartością soli', 'Kaufland'),
    ('Kamis', 'Przyprawa do gyrosa', 'Biedronka'),
    ('Culineo', 'Cebulka zapiekana', 'Biedronka'),
    ('El Tequito', 'Jalapeños', 'Lidl'),
    ('Lidl', 'Ground chili peppers in olive oil', 'Lidl'),
    ('Kania', 'Gewürzzubereitung „Perfekt für Bratkartoffeln „', 'Lidl'),
    ('Eridanous', 'Gyros', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spices & Seasonings' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

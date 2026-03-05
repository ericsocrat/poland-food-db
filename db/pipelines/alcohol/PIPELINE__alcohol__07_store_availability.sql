-- PIPELINE (Alcohol): store availability
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
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'Biedronka'),
    ('Seth & Riley''s Garage Euphoriq', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'Dino'),
    ('Kompania Piwowarska', 'Kozel cerny', 'Auchan'),
    ('Browar Fortuna', 'Piwo Pilzner, dolnej fermentacji', 'Kaufland'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'Kaufland'),
    ('Velkopopovicky Kozel', 'Polnische Bier (Dose)', 'Netto'),
    ('Tyskie', 'Bier &quot;Tyskie Gronie&quot;', 'Kaufland'),
    ('Christkindl', 'Christkindl Glühwein', 'Lidl'),
    ('Ikea', 'Glühwein', 'Ikea'),
    ('Just 0.', 'Just 0 White alcoholfree', 'Dealz'),
    ('Just 0.', 'Just 0. Red', 'Dealz')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

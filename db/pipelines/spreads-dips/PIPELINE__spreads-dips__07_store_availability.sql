-- PIPELINE (Spreads & Dips): store availability
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
    ('Wawrzyniec', 'Hummus z pestkami dyni i słonecznika', 'Rossmann'),
    ('Sensation', 'Ajvar łagodny', 'Carrefour'),
    ('Auchan', 'Hummus z solą morską', 'Auchan'),
    ('Go Vege', 'Hummus klasyczny', 'Biedronka'),
    ('Go Vege', 'Hummus paprykowy', 'Biedronka'),
    ('Go Vege', 'Hummus z ciecierzycy spicy salsa', 'Biedronka'),
    ('Go Vege', 'Hummus pomidorowy', 'Biedronka'),
    ('Go Vege', 'Hummus z ciecierzycy z burakiem', 'Biedronka'),
    ('Go Vege', 'Hummus', 'Biedronka'),
    ('Go Vege', 'Hummus z burakiem', 'Biedronka'),
    ('Vital Fresh', 'Hummus pomidorowy', 'Biedronka'),
    ('Lavica Food', 'Hummus dynia & imbir', 'Kaufland'),
    ('Perla', 'Pomidor hummus', 'Aldi'),
    ('Vemondo', 'Hummus klasyczny', 'Lidl'),
    ('Chef select', 'Hummus classic', 'Lidl'),
    ('K-take it veggie', 'K-take it veggie Hummus Tomato', 'Kaufland'),
    ('K-take it veggie', 'K-take it veggie Hummus Red Pepper 200g', 'Kaufland'),
    ('Taverna-Bio', 'Classic Hummus', 'Auchan'),
    ('Vital', 'Guacamole', 'Biedronka'),
    ('K-take it veggie', 'K-take it veggie Hummus Classic', 'Kaufland'),
    ('Chef Select', 'Hummus z sosem pomidorowym', 'Lidl'),
    ('Vitasia', 'Hummus sweet chili', 'Lidl'),
    ('Athos', 'Tzatziki', 'Kaufland')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Spreads & Dips' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

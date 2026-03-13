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
    ('Herbapol', 'Herbaciany ogród - Prosto z lasu.', 'Dino'),
    ('Herbapol', 'Herbaciany ogród, malina z żurawiną', 'Biedronka'),
    ('Cafe d''or', 'Kawa rozpuszczalna gold liofilizowana robusta/arabica', 'Biedronka'),
    ('Unilever', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'Biedronka'),
    ('Remsey', 'Herbata czarna aromatyzowana Earl Grey Strong w torebkach do zaparzania', 'Biedronka'),
    ('Lipton', 'Yellow Label', 'Biedronka'),
    ('Sir Adalbert''s tea', 'Herbata czarna earl grey liściasta', 'Kaufland'),
    ('Nestlé', 'Nescafe', 'Carrefour'),
    ('Carrefour', 'Intenso', 'Carrefour'),
    ('Carrefour', 'Classico', 'Carrefour'),
    ('Carrefour', 'Dolce', 'Carrefour'),
    ('Carrefour', 'Cappuccino', 'Carrefour'),
    ('Carrefour', 'Latte Macchiato', 'Carrefour'),
    ('Carrefour', 'Cappuccino Vanilata', 'Carrefour'),
    ('Carrefour', 'CAPPUCCINO Decaffeinato', 'Carrefour'),
    ('Carrefour', 'CAPPUCCINO Chocolate', 'Carrefour'),
    ('L''Or Barista', 'L''or Barista Double Ristretto Intensity 11', 'Carrefour'),
    ('Carrefour', 'Lungo Généreux et Fruité', 'Carrefour'),
    ('Carrefour', 'Pérou', 'Carrefour'),
    ('Carrefour BIO', 'AMÉRIQUE LATINE GRAINS Pur Arabica', 'Carrefour'),
    ('Carrefour BIO', 'Amérique Latine', 'Carrefour'),
    ('Carrefour', 'Espresso nocciolita', 'Carrefour'),
    ('Carrefour', 'Espresso Colombie', 'Carrefour'),
    ('Carrefour', 'Lungo Voluptuo', 'Carrefour'),
    ('Carrefour', 'Café Grande 100% Arabica', 'Carrefour'),
    ('Carrefour', 'Cappuccino ORIGINAL', 'Carrefour'),
    ('Carrefour', 'Caffe latte', 'Carrefour'),
    ('Carrefour', 'Espresso decaffeinato', 'Carrefour'),
    ('Carrefour', 'Espresso', 'Carrefour'),
    ('Tian Ku Shan', 'Matcha Tea powder', 'Netto'),
    ('Lipton', 'Herbata czarna z naturalnym aromatem', 'Biedronka'),
    ('Lipton', 'Pokrzywa z mango', 'Auchan'),
    ('Lipton', 'Yellow Label granulowana', 'Biedronka'),
    ('Lipton', 'Yellow Label granulowana', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Coffee & Tea' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

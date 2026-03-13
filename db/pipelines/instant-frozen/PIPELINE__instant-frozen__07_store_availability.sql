-- PIPELINE (Instant & Frozen): store availability
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
    ('Vifon', 'Hot Beef pikantne w stylu syczuańskim', 'Biedronka'),
    ('Goong', 'Zupa błyskawiczna o smaku kurczaka STRONG', 'Aldi'),
    ('Asia Style', 'VeggieMeal hot and sour CHINESE STYLE', 'Biedronka'),
    ('Asia Style', 'VeggieMeal hot and sour SICHUAN STYLE', 'Biedronka'),
    ('Vifon', 'Korean Hot Beef', 'Carrefour'),
    ('Nongshim', 'Bowl Noodles Hot & Spicy', 'Biedronka'),
    ('Nongshim', 'Kimchi Bowl Noodles', 'Netto'),
    ('Nongshim', 'Super Spicy Red Shin', 'Lidl'),
    ('Indomie', 'Noodles Chicken Flavour', 'Carrefour'),
    ('NongshimSamyang', 'Ramen kimchi', 'Carrefour'),
    ('Mama', 'Oriental Kitchen Instant Noodles Carbonara Bacon Flavour', 'Carrefour'),
    ('มาม่า', 'Mala Beef Instant Noodle', 'Carrefour'),
    ('Mama', 'Mama salted egg', 'Carrefour')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Instant & Frozen' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

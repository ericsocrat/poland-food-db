-- PIPELINE (Baby): store availability
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
    ('Diamant', 'Cukier Biały', 'Kaufland'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Biedronka'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Lidl'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Kaufland'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Carrefour'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Aldi'),
    ('Owolovo', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Selgros'),
    ('GutBio', 'Puré de Frutas Manzana y Plátano', 'Aldi')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Baby' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

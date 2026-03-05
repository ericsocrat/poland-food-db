-- PIPELINE (Snacks): store availability
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
    ('Top', 'Popcorn o smaku maślanym', 'Biedronka'),
    ('Lajkonik', 'Paluszki o smaku waniliowym.', 'Biedronka'),
    ('Delicje', 'Szampariskie pomaranczowe', 'Carrefour'),
    ('Vitanella', 'Superballs Kokos i kakao', 'Biedronka'),
    ('Go On', 'Sante Baton Proteinowy Go On Kakaowy', 'Lidl'),
    ('Unknown', 'Vitanella raw', 'Biedronka'),
    ('7 Days', 'Croissant with Cocoa Filling', 'Kaufland'),
    ('Snack Day', 'Popcorn', 'Lidl'),
    ('Lorenz', 'Monster Munch Crispy Potato-Snack Original', 'Biedronka'),
    ('Zott', 'Monte Snack', 'Biedronka'),
    ('Emco', 'Vitanella Bars', 'Biedronka'),
    ('Maretti', 'Bruschette Chips Pizza Flavour', 'Penny')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Snacks' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

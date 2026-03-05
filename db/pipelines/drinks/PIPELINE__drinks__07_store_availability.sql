-- PIPELINE (Drinks): store availability
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
    ('Hortex', 'Sok jabłkowy', 'Dino'),
    ('Riviva', 'Sok 100% pomarańcza z witaminą C', 'Biedronka'),
    ('Bracia Sadownicy', 'Sok 100% tłoczony tłoczone jabłko z marchewką', 'Biedronka'),
    ('Polaris', 'Napój gazowany Vital Red', 'Biedronka'),
    ('Polaris', 'Napój gazowany Vital Green', 'Biedronka'),
    ('Riviva', '100% Coconut Water', 'Biedronka'),
    ('Pepsico', 'Pepsi', 'Netto'),
    ('Pepsi', 'Pepsi Zero', 'Lidl'),
    ('Riviva', 'Sok 100% multiwitamina', 'Biedronka'),
    ('Riviva', 'Sok 100% multiwitamina', 'Kaufland'),
    ('Pepsi', 'Pepsi Max 0.5', 'Żabka'),
    ('Tymbark', 'Multifruit mango flavoured still drink', 'Auchan'),
    ('Fortuna', 'Sok 100% pomidor', 'Auchan'),
    ('Unknown', 'Cola original zero', 'Biedronka'),
    ('Frugo', 'Ultra black', 'Dino'),
    ('Riviva', 'Jus d''orange 100%', 'Biedronka'),
    ('Unilever', '(3, 58eur / 100g) Schwarzer Tee Von Lipton - 25 Beutel', 'Biedronka'),
    ('Vemondo', 'Owsiane smoothie owoce lata', 'Lidl'),
    ('Cola', 'Cola original intense zero', 'Biedronka'),
    ('Frugo', 'Frugo ultragreen', 'Dino'),
    ('Tymbark', 'Sok pomidorowy pikantny', 'Auchan'),
    ('Riviva', 'Sok 100% pomidorowo-warzywny', 'Biedronka'),
    ('Inka', 'Mleko owsiane', 'Dino'),
    ('Tymbark', 'Tymbark 100% jablko', 'Dino'),
    ('Tymbark', 'Tymbark 100% jablko', 'Carrefour'),
    ('Grana', 'Owsiane', 'Lidl'),
    ('Heineken', 'Heineken 0.0%', 'Żabka'),
    ('WK Dzik', 'Dzik Energy Zero calorie', 'Biedronka'),
    ('Lidl', 'Sok 100% tłoczony z miąższem Pomarańcza Grejpfrut Pitaja', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Drinks' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

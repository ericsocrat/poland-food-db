-- PIPELINE (Chips): store availability
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
    ('Top', 'Top Prażynki Solone', 'Biedronka'),
    ('TOP', 'Tortilla Salted Chips', 'Biedronka'),
    ('Classic''', 'Chipsy Ziemniaczane O Smaku Zielonej Cebulki', 'Carrefour'),
    ('Sonko', 'Chipsy Z Ciecierzycy', 'Kaufland'),
    ('Granex', 'Bio Kwiatki Kukurydziane Chrupki', 'Biedronka'),
    ('Star', 'Star chrupki o smaku zielona cebulka', 'Netto'),
    ('Go VEGE', 'Tortilla Chips Szpinakowe', 'Biedronka'),
    ('Top', 'Tortilla Chipsy Kukurydziane Solone', 'Biedronka'),
    ('Lorenz', 'Crunchips Wow Jalapeno & Cheese', 'Biedronka'),
    ('Top', 'Top chips faliste', 'Biedronka'),
    ('Cheetos', 'Cheetos Chrupki cebulowe', 'Auchan'),
    ('Granex', 'Bio Krokodylki Kukurydziane Chrupki', 'Biedronka'),
    ('Carrefour', 'Chipsy ziemniaczane solone', 'Carrefour'),
    ('Crunchips', 'X-Cut Chakalaka Smak Afryki', 'Biedronka'),
    ('Carrefour', 'Chipsy ziemniaczane o smaku paprykowym', 'Carrefour'),
    ('Auchan', 'Czipsy cebulowe', 'Auchan'),
    ('Przysnacki', 'Snack festival - grilled chicken style', 'Aldi'),
    ('Auchan', 'Chipsy ziemniaczane faliste o smaku fromage', 'Auchan'),
    ('Moggi', 'Chrupki kukurydziane o smaku cebulki ze śmietanką', 'Stokrotka'),
    ('Snack Day', 'Chipsy z soczewicy pomidor bazylia', 'Lidl'),
    ('Carrefour', 'Tortilla nachos', 'Carrefour'),
    ('Snack day', 'Tortilla Chips salted', 'Lidl'),
    ('Old El Paso', 'Tortilla Chips', 'Carrefour'),
    ('Snack Day', 'Tapioca and prawn crackers classic', 'Lidl'),
    ('Carrefour', 'Toetilla Chips Nature', 'Carrefour'),
    ('Kaufland', 'Tortilla chips', 'Kaufland'),
    ('Salati Preziosi', 'Limopepe', 'Żabka'),
    ('Auchan', 'Tortillas chips saveur chili', 'Auchan'),
    ('El Tequito', 'Tortilla Rolls', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Chips' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

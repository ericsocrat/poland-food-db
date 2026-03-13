-- PIPELINE (Pasta & Rice): store availability
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
    ('Lubella', 'Makaron Lubella Pióra nr 17', 'Dino'),
    ('Nasze Smaki', 'Kluski śląskie', 'Biedronka'),
    ('Pastani', 'Makaron pełnoziarnisty świderki', 'Biedronka'),
    ('Pastani', 'Makaron Świderki', 'Biedronka'),
    ('Dobrusia', 'Makaron świderki', 'Biedronka'),
    ('Goliard', 'Makaron szlachecki jajeczny. Wstażki - Gniazda', 'Biedronka'),
    ('Maxpol', 'Penne rurka skośna', 'Dino'),
    ('Auchan', 'Makaron świderki', 'Auchan'),
    ('Novelle', 'Diabetic makaron świderki', 'Aldi'),
    ('Pastani', 'Makaron Cavatappi', 'Biedronka'),
    ('House of Asia', 'Makaron udon pszenny', 'Lidl'),
    ('House of Asia', 'Makaron udon pszenny', 'Auchan'),
    ('De Care', 'Ramen Noodles', 'Kaufland'),
    ('Auchan', 'Kluski leniwe', 'Auchan'),
    ('Makarony Polskie', 'Pastani Penne', 'Biedronka'),
    ('Novelle', 'Makaron z soczewicy czerwonej', 'Kaufland'),
    ('Novelle', 'Makaron z zielonego groszku', 'Kaufland'),
    ('Auchan', 'Makaron spaghetti', 'Auchan'),
    ('Asia Style', 'Spaghetti Konjac', 'Biedronka'),
    ('Sorenti', 'Makaron spaghetti nr 79', 'Dino'),
    ('Jeronimo Martons', 'Makaron szlachecki', 'Biedronka'),
    ('Makarony Polskie SA', 'Makaron falbanki', 'Auchan'),
    ('Auchan', 'Makaron jajeczny krajanka', 'Auchan'),
    ('Makarony Polskie', 'Spaghetti', 'Kaufland'),
    ('Makarony Polskie', 'Swiderki spirals noodle pasta', 'Kaufland'),
    ('Tiradell', 'Makaron świderki', 'Lidl'),
    ('Carrefour', 'Espirales cocción rápida', 'Carrefour'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'Carrefour'),
    ('Barilla', 'Penne Rigate N°73', 'Auchan'),
    ('Barilla', 'Penne Rigate N°73', 'Penny'),
    ('Tiradell', 'Makaron 5-jajeczny, krajanka', 'Lidl'),
    ('Chef select', 'Tortellini viande', 'Lidl'),
    ('Tiradell', 'Makaron gryczany rurki', 'Lidl'),
    ('Combino', 'Sardinen in Sonnenblumenöl mit Chili', 'Lidl'),
    ('Podravka', 'Makaron z pszenicy twardej durum', 'Auchan'),
    ('Melissa', 'Pasta Kids', 'Biedronka'),
    ('Combino', 'Spaghetti', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Pasta & Rice' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

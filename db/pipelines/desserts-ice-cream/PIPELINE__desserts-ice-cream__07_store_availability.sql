-- PIPELINE (Desserts & Ice Cream): store availability
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
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'Biedronka'),
    ('Piątnica', 'Skyr z mango i marakują', 'Kaufland'),
    ('Piatnica', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'Kaufland'),
    ('OwoLovo', 'OwoLowo Jabłkowo', 'Biedronka'),
    ('Tutti', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'Biedronka'),
    ('Jovi', 'Napój jogurtowy Duet Banan-Truskawka', 'Biedronka'),
    ('Zott', 'Jogurt jabłko i gruszka', 'Biedronka'),
    ('Amelia', 'Waniliowy 3 składniki', 'Lidl'),
    ('Vital Fresh', 'Mus Jabłko Banan Marakuja', 'Biedronka'),
    ('Fruvita', 'Mixo Jabłko-Gruszka', 'Biedronka'),
    ('Bakoma', 'Maxi Meal o smaku słonego karmelu', 'Dino'),
    ('Maluta', 'Maluta Jogurt Bałkański', 'Auchan'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Kaufland'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Auchan'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Carrefour'),
    ('Piątnica', 'Skyr Wanilia', 'Kaufland'),
    ('Piątnica', 'Skyr Wanilia', 'Auchan'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'Auchan'),
    ('Piątnica', 'Icelandic type yoghurt natural', 'Kaufland'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'Lidl'),
    ('Mlekovita', 'Jogurt Grecki naturalny', 'Kaufland'),
    ('Zott', 'Jogurt naturalny', 'Auchan'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 'Lidl'),
    ('Piątnica', 'Skyr Naturalny', 'Lidl'),
    ('Piątnica', 'Skyr Naturalny', 'Kaufland'),
    ('Fruvita', 'Jogurt jagodowy', 'Biedronka'),
    ('Fruvita', 'Skyr Pitny Wanilia', 'Biedronka'),
    ('Pilos', 'Serek Wiejski Lekki', 'Lidl'),
    ('Président', 'Twarog sernikowy', 'Kaufland'),
    ('Jovi', 'Duet jogurt pitny Truskawka-Kiwi', 'Lidl'),
    ('Piątnica', 'Serek wiejski z jagodami', 'Biedronka'),
    ('Bakoma', 'Bakoma Ave Vege czekolada', 'Biedronka'),
    ('Vemondo', 'Kokos naturalny', 'Lidl'),
    ('Delikate', 'Serek Wiejski', 'Biedronka'),
    ('Tutti', 'Serek homogenizowany brzoskwiniowy Tutti', 'Biedronka'),
    ('Président', 'Serek waniliowy', 'Biedronka'),
    ('Piatnica', 'Serek homogenizowany brzoskwiniowy', 'Kaufland'),
    ('Bakoma', 'Jogurt Bio naturalny', 'Biedronka'),
    ('Rolmlecz', 'Serek truskawkowy', 'Auchan'),
    ('Go Active', 'Serek proteinowy ze skyrem', 'Biedronka'),
    ('Łowicz', 'Sernik z brzoskwiniami', 'Żabka'),
    ('Danone', 'Fantasia ar ķiršiem', 'Auchan'),
    ('Danone', 'Actimel o smaku wieloowocowym', 'Biedronka'),
    ('Go Active', 'Protein Jogurt Truskawkowy', 'Biedronka'),
    ('Fruvita', 'Skyr blueberry', 'Biedronka'),
    ('Jogobella', 'Jogurt brzoskwiniowy', 'Biedronka'),
    ('Bakoma', 'Jogurt Bio z Truskawkami', 'Biedronka'),
    ('Fruvita', 'Skyr naturalny', 'Biedronka')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Desserts & Ice Cream' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

-- PIPELINE (Soups): store availability
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
    ('Krakus', 'Zupa Żurek', 'Auchan'),
    ('Krakus', 'Zupa Żurek', 'Carrefour'),
    ('Auchan', 'Fasolka po bretońsku z kiełbasą i boczkiem.', 'Auchan'),
    ('Łowicz', 'Kociołek węgierski', 'Biedronka'),
    ('Łowicz', 'Kociołek węgierski', 'Auchan'),
    ('Profi', 'Krupnik z mięsem wieprzowym', 'Auchan'),
    ('Krakus', 'Barszcz biały koncentrat', 'Biedronka'),
    ('Profi', 'Zupa pomidorowa z mięsem wieprzowym', 'Auchan'),
    ('Lewiatan', 'Fasolka po bretońsku', 'Lewiatan'),
    ('Biedronka', 'Zupa kapuśniak z pomidorami', 'Biedronka'),
    ('Biedronka', 'Zupa kapuśniak', 'Biedronka'),
    ('Nestlé', 'Barszcz czerwony', 'Carrefour'),
    ('Jemy Jemy', 'Zupa krem z pomidorow', 'Lidl'),
    ('Biedronka', 'Zupa krem z dyni', 'Biedronka'),
    ('Biedronka', 'Zupa Fasolowa z Pomidorami i Szpinakiem', 'Biedronka'),
    ('Jemy Jemy', 'Zupa krem z zielonego groszku', 'Lidl'),
    ('Biedronka', 'Zupa pomidorowa', 'Biedronka'),
    ('Biedronka', 'Zupa grochowa', 'Biedronka'),
    ('Biedronka', 'Zupa koperkowa', 'Biedronka'),
    ('Urbanek', 'Cucumber soup with dill', 'Auchan'),
    ('Słoik konesera', 'Klopsy w sosie pomidorowym', 'Auchan'),
    ('Auchan', 'Pulpety w sosie pomidorowym', 'Auchan'),
    ('Yabra', 'Zupa gulaszowa', 'Auchan'),
    ('Pan Pomidor', 'Zupa szczawiowa z ziemniakami', 'Kaufland'),
    ('Biedronka', 'Zupa Minestrone', 'Biedronka'),
    ('Culineo', 'Bulion warzywny', 'Biedronka'),
    ('Chef select', 'Zupa krem z pomidorów z bazylią', 'Lidl'),
    ('Chef Select', 'Żurek z białą kiełbasą i boczkiem', 'Lidl'),
    ('Samyang', 'Buldak HOT Chicken Flavour Ramen Cheese Flavour', 'Biedronka'),
    ('Italiamo', 'Paradizniki suseni lidl', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Soups' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

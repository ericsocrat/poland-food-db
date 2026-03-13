-- PIPELINE (Frozen Vegetables): store availability
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
    ('Hortex', 'Warzywa na patelnię', 'Kaufland'),
    ('Mroźna Kraina', 'Warzywa na patelnię z ziemniakami', 'Biedronka'),
    ('Morźna Kraina', 'Włoszczyzna w słupkach', 'Biedronka'),
    ('Hortex', 'Warzywa na patelnię z przyprawą włoską', 'Kaufland'),
    ('Mroźna Kraina', 'Szpinak w liściach, porcjowany', 'Biedronka'),
    ('Mroźna Kraina', 'Warzywa na patelnię letnie', 'Biedronka'),
    ('Hortex', 'Warzywa na patelnię ze szpinakiem', 'Auchan'),
    ('Mroźna Kraina', 'Brokuły różyczki', 'Biedronka'),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po hiszpańsku&quot;', 'Biedronka'),
    ('Hortex', 'Warzywa Na Patelnię Z Koperkiem', 'Żabka'),
    ('Mroźna Kraina', 'Fasola szparagowa cięta Mroźna Kraina', 'Biedronka'),
    ('Mroźna Kraina', 'Jagody leśne', 'Biedronka'),
    ('Mroźna Kraina', 'Borówka', 'Biedronka'),
    ('Mroźna Kraina', 'Mieszanka wiosenna', 'Biedronka'),
    ('Hortex', 'Warzywa na patelnie', 'Auchan'),
    ('Hortex', 'Bukiet warzyw kwiatowy', 'Auchan'),
    ('Mroźna kraina', 'Szpinak rozdrobniony porcjowany', 'Biedronka'),
    ('Mroźna Kraina', 'Warzywa na patelnie z ziemniakami', 'Biedronka'),
    ('Mroźna Kraina', 'Warzywa na patelnie &quot;po indyjsku&quot;', 'Biedronka'),
    ('Mroźna kraina', 'Warzywa na patelnie', 'Biedronka'),
    ('Mroźna Kraina', 'Groszek zielony', 'Biedronka'),
    ('Mroźna Kraina', 'Marchew mini', 'Biedronka'),
    ('Mroźna Kraina', 'Brzoskwinia', 'Biedronka'),
    ('Freshona', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'Lidl'),
    ('Freshona', 'Mix zeleniny na čínský způsob', 'Lidl'),
    ('Harvest Best', 'Wok mix', 'Netto'),
    ('Bonduelle', 'Epinards Feuilles Préservées 750g', 'Carrefour'),
    ('Carrefour', 'Haricots Verts Très Fins', 'Carrefour'),
    ('Carrefour', 'CHOUX-FLEURS En fleurette', 'Carrefour'),
    ('Tesco', 'Mix mražené zeleniny', 'Tesco'),
    ('Freshona', 'Berry Mix with Sour Cherries', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Frozen Vegetables' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'PL' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

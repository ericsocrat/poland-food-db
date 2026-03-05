-- PIPELINE (Meat): store availability
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
    ('Herta', 'Hähnchenbrust', 'REWE'),
    ('Frosta', 'Hähnchen Paella', 'Edeka'),
    ('Frosta', 'Hähnchen Paella', 'REWE'),
    ('Frosta', 'Hähnchen Paella', 'Kaufland'),
    ('Frosta', 'Hähnchen Paella', 'Real'),
    ('Gut Drei Eichen', 'Herzhafte Edelsalami, geräuchert', 'Aldi'),
    ('Güldenhof', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 'Aldi'),
    ('Allfein Feinkost', 'Hähnchen-Knusper-Dinos', 'Aldi'),
    ('Güldenhof', 'Mini-Wiener - Geflügel', 'Aldi'),
    ('Güldenhof', 'Geflügel-Paprikalyoner', 'Aldi'),
    ('Adler Schwarzwald', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 'Aldi'),
    ('Bio', 'Bio-Salami - geräuchert mit grünem Pfeffer', 'Aldi'),
    ('Güldenhof', 'Geflügel-Mortadella', 'Aldi'),
    ('Böklunder', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 'Aldi'),
    ('Dulano', 'Geflügel Wiener', 'Lidl'),
    ('Familie Wein', 'Schwarzwälder Schinken', 'Netto'),
    ('Zimmermann', 'Weißwurst', 'REWE'),
    ('Rügenwalder Mühle', 'Mühlen Frikadellen 100% Geflügel', 'REWE'),
    ('Rügenwalder Mühle', 'Mühlen Frikadellen 100% Geflügel', 'Kaufland'),
    ('Gut Drei Eichen', 'Katenschinken-Würfel', 'Aldi'),
    ('Bernard Matthews Oldenburg', 'Hähnchen Filetstreifen', 'REWE'),
    ('Gut Drei Eichen', 'Münchner Weißwurst', 'Aldi'),
    ('Herta', 'Schinken', 'Lidl'),
    ('Herta', 'Schinken', 'REWE'),
    ('Gut Drei Eichen', 'Schinken-Lyoner', 'Aldi'),
    ('Herta', 'Schinken gegart ofengegrillt', 'REWE'),
    ('Nestlé', 'Saftschinken', 'REWE'),
    ('Ponnath Die Meistermetzger', 'Delikatess Prosciutto Cotto', 'REWE'),
    ('Bio', 'Bio-Salami - luftgetrocknet', 'Aldi'),
    ('Abraham', 'Jamón Serrano Schinken', 'Aldi'),
    ('Zimbo', 'Schinken Zwiebelmettwurst fettreduziert', 'REWE'),
    ('K-Classic', 'Kochhinterschinken', 'Kaufland'),
    ('Herta', 'Schinken Belem Pfeffer', 'Lidl'),
    ('Steinhaus', 'Bergische Salami', 'REWE'),
    ('Meica', 'Curryking fix & fertig', 'Edeka'),
    ('Meica', 'Curryking fix & fertig', 'REWE')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Meat' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

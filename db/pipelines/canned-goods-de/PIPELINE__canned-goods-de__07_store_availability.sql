-- PIPELINE (Canned Goods): store availability
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
    ('Nixe - LIDL', 'Thunfisch Filets in Sonnenblumenöl', 'Lidl'),
    ('Hengstenberg', 'KNAX Gewürzgurken', 'REWE'),
    ('Aldi', 'Bio-Gewürzgurken', 'Aldi'),
    ('Wonnemeyer', 'Mediterrane Antipasti - Kirschpaprika mit Frischkäsecreme Senf-Honig', 'Aldi'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'Lidl'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'REWE'),
    ('Nixe', 'Thunfisch', 'Lidl'),
    ('Appel', 'Zarte Filets vom Hering in Tomaten-Creme', 'Netto'),
    ('KING''S CROWN (Aldi)', 'Tomatenmark', 'Aldi'),
    ('Almare Seafood', 'Thunfisch Filets in eigenen Saft', 'Aldi'),
    ('Aldi', 'Tomatenmark', 'Aldi'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'Aldi'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'Edeka'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'REWE'),
    ('Oro Di Parma', 'Famila Oro di Parma Tomatenmark mit Knoblauch 200g 1.29€ 1kg 6.45', 'Netto'),
    ('King''s Crown', 'Tomaten gehackt', 'Aldi'),
    ('Oro Di Parma', 'Tomaten', 'Edeka'),
    ('Oro Di Parma', 'Tomaten', 'Kaufland'),
    ('Hawesta', 'Heringsfilets - Tomaten-Creme', 'Edeka'),
    ('Hawesta', 'Heringsfilets - Tomaten-Creme', 'REWE'),
    ('Aldi', 'Cornichons', 'Aldi'),
    ('Erasco', 'Vegetarischer linsen-eintopf', 'Lidl'),
    ('Erasco', 'Vegetarischer linsen-eintopf', 'REWE'),
    ('DmBio', 'Tomatenmark', 'dm'),
    ('Erasco', 'Erbsensuppe Hubertus', 'Lidl'),
    ('Hawesta', 'Heringsfilets - Pfeffercreme', 'Edeka'),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 'Edeka'),
    ('Hengstenberg', 'Mildes Weinsauerkraut', 'REWE'),
    ('Bio Organic', 'Rote Beete', 'Lidl'),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'Edeka'),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'REWE'),
    ('Appel', 'Zarte Filets vom Hering in Eier-Senf-Creme', 'Kaufland'),
    ('Appel', 'Zarte Filets vom Hering Tomate-Mozzarella', 'Edeka'),
    ('Appel', 'Zarte Filets vom Hering Tomate-Mozzarella', 'REWE'),
    ('Erasco', 'Erbseneintopf', 'Edeka'),
    ('Erasco', 'Erbseneintopf', 'REWE'),
    ('Aldi', 'Mais', 'Aldi'),
    ('Hengstenberg', 'Tomaten - Passiert', 'Kaufland'),
    ('Sweet Valley', 'Pfirsiche halbe Frucht, leicht gezuckert', 'Aldi'),
    ('Deutsche See', 'Thunfisch im Aufguss', 'REWE'),
    ('King''s Crown', 'Rote Beete in Kugeln', 'Aldi'),
    ('Freshona', 'Sonnenmais natursüß', 'Lidl'),
    ('REWE Bio', 'Tomaten in Stücken', 'REWE'),
    ('Edeka', 'Delikatess Gewürzgurken', 'Edeka'),
    ('Mutti', 'Geschälte Italienische Tomaten', 'Edeka')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

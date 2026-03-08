-- PIPELINE (Oils & Vinegars): store availability
-- Source: Open Food Facts API store field
-- Generated: 2026-03-08

INSERT INTO product_store_availability (product_id, store_id, verified_at, source)
SELECT
  p.product_id,
  sr.store_id,
  NOW(),
  'pipeline'
FROM (
  VALUES
    ('Bellasan', 'Natives Olivenöl Extra', 'Aldi'),
    ('Primadonna', 'Natives Olivenöl Extra', 'Lidl'),
    ('DmBio', 'Natives Olivenöl extra', 'dm'),
    ('Lyttos', 'Olivenöl', 'Aldi'),
    ('DmBio', 'Bratolivenöl', 'dm'),
    ('Camaletti', 'Camaletti Olivenöl', 'Penny'),
    ('Gut Bio', 'Natives Olivenöl Extra', 'Aldi'),
    ('Lyttos', 'Griechisches natives Olivenöl extra', 'Aldi'),
    ('Primadonna', 'Brat Olivenöl', 'Lidl'),
    ('Primadonna', 'Olivenöl (nativ, extra)', 'Lidl'),
    ('Aldi', 'Griechisches natives Olivenöl Extra', 'Aldi'),
    ('Bellasan', 'Oliven Öl', 'Aldi'),
    ('K-Classic', 'Natives Olivenöl extra', 'Kaufland'),
    ('Lidl', 'Natives Olivenöl extra aus Griechenland', 'Lidl'),
    ('DmBio', 'Natives Olivenöl extra naturtrüb', 'dm'),
    ('Cucina Nobile', 'Natives Olivenöl', 'Aldi'),
    ('Aldi Bellasan', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 'Aldi'),
    ('Bellasan', 'Olivenöl', 'Aldi'),
    ('Aldi', 'Natives Olivenöl Extra', 'Aldi'),
    ('Bertolli', 'Natives Olivenöl Originale', 'Edeka'),
    ('Bertolli', 'Natives Olivenöl Originale', 'REWE'),
    ('Rewe', 'Natives Olivenöl Extra', 'REWE'),
    ('Edeka Bio', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 'Edeka'),
    ('Alnatura', 'Olivenöl', 'Edeka'),
    ('Gut & Günstig', 'Olivenöl Extra Natives', 'Edeka'),
    ('D.O.P. Terra Di Bari Castel Del Monte', 'Italienisches natives Olivenöl extra', 'REWE'),
    ('Bertolli', 'Olivenöl Natives Extra Gentile SANFT', 'Edeka'),
    ('BioBio', 'Natives Bio-Olivenöl Extra', 'Netto'),
    ('Rewe beste Wahl', 'Olivenöl ideal für warme Speisen', 'REWE'),
    ('Ja!', 'Natives Olivenöl Extra', 'REWE'),
    ('La Espaniola', 'Natives Ölivenöl extra', 'Kaufland'),
    ('Las Cuarenta', 'Spanisches Natives Olivenöl extra', 'Netto'),
    ('Natur Gut', 'Natives Olivenöl Extra', 'Penny'),
    ('Bio', 'Bio natives Olivenöl', 'Kaufland'),
    ('Primadonna', 'Bio natives Olivenöl extra', 'Lidl'),
    ('Vegola', 'Natives Olivenöl extra', 'Netto'),
    ('Fiore', 'Natives Olivenöl Extra', 'REWE'),
    ('REWE Feine Welt', 'Natives Olivenöl Extra Lesvos g.g.A.', 'REWE'),
    ('Edeka', 'Griechisches Natives Olivenöl Extra', 'Edeka')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Oils & Vinegars' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

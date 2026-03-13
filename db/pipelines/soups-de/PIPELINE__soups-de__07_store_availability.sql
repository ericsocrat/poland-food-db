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
    ('Aldi', 'Bio-Gemüsebrühe', 'Aldi'),
    ('Erasco', 'Hühner Nudel Topf/ Erasco', 'Lidl'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'Lidl'),
    ('Erasco', 'Grüne-Bohnen-Eintopf', 'REWE'),
    ('Sonnen Bassermann', 'Hühner- Nudel-Topf/ So. Bas.', 'Edeka'),
    ('Sonnen Bassermann', 'Hühner- Nudel-Topf/ So. Bas.', 'REWE'),
    ('Sonnen Bassermann', 'Hühner- Nudel-Topf/ So. Bas.', 'Penny'),
    ('Sonnen Bassermann', 'Hühner- Nudel-Topf/ So. Bas.', 'Netto'),
    ('10% Kartoffeln', 'Grüne Bohnen Eintopf Rind', 'Lidl'),
    ('Bassermann', 'Eintopf Frühlingstopf m. Klößen', 'Kaufland'),
    ('Erasco', 'Grüne Bohnen Kartoffeltopf', 'Edeka'),
    ('Natur Werk', 'Kichererbsensuppe (mit Kokoscreme & Kreuzkümmel)', 'Netto'),
    ('Asia Green Garden', 'Feurige Thaisuppe mit Hühnerfleisch', 'Aldi'),
    ('Zimmermann', 'Leberknödelsuppe', 'Edeka'),
    ('Zimmermann', 'Leberknödelsuppe', 'REWE'),
    ('Erasco', 'Hühner Reis-Topf', 'Edeka'),
    ('Natur Werk', 'Süßkartoffelsuppe mit Ingwer und Curry', 'REWE'),
    ('Erasco', 'Vegetarischer Linseneintopf', 'Lidl'),
    ('Erasco', 'Vegetarischer Linseneintopf', 'REWE'),
    ('Erasco', 'Erbsensuppe Hubertus', 'Lidl'),
    ('Erasco', 'Vegetarischer Erbsen-Eintopf', 'Edeka'),
    ('Erasco', 'Vegetarischer Erbsen-Eintopf', 'REWE'),
    ('Bio', 'Veganer Erbseneintopf', 'Aldi'),
    ('Indonesia', 'Bihun Suppe', 'Edeka'),
    ('Kania', 'Tomaten Suppe - toskanische Art', 'Lidl'),
    ('Meica', 'Volle Kelle', 'Edeka'),
    ('Lacroix', 'Gulaschsuppe', 'REWE'),
    ('Nur Nur Natur', 'Bio-Kartoffelsuppe', 'Aldi'),
    ('Dm Bio', 'Dm Bio Linseneintopf', 'dm'),
    ('Aldi', 'Gulasch-Suppe', 'Aldi'),
    ('DmBio', 'Tocană de mazăre ECO', 'dm'),
    ('Erasco', 'Kartoffel-Cremesuppe', 'Edeka'),
    ('Erasco', 'Ungarische Gulaschsuppe', 'REWE'),
    ('Erasco', 'Pfifferling Rahmsuppe', 'REWE'),
    ('Buss Fertiggerichte', 'Thai Suppe', 'Aldi'),
    ('Dreistern', 'Gulaschsuppe', 'Netto'),
    ('Speisezeit', 'Bihun-Suppe', 'Aldi'),
    ('Le Gusto', 'Waldpilzsuppe', 'Aldi'),
    ('Naba Feinkost', 'Rote Beete Cremesuppe mit Birne', 'Tegut'),
    ('Nur Nur Natur', 'Bio-Brokkolisuppe', 'Aldi'),
    ('Ener BIO', 'Čočková polévka', 'Rossmann'),
    ('Aldi', 'Tomaten-Rahmsuppe', 'Aldi'),
    ('Nabio', 'Erbsensuppe mit Basilikum', 'Tegut'),
    ('Buss', 'Ochsenschwanz-Suppe', 'Aldi'),
    ('Little Lunch', 'Kürbissuppe von Little Lunch', 'REWE'),
    ('Larco', 'Hühnerbrühe konzentriert mit Fleisch', 'REWE'),
    ('Larco', 'Hühnerbrühe konzentriert mit Fleisch', 'Netto'),
    ('Knorr', 'Bratensoße', 'Lidl'),
    ('Maggi', '5 Minuten Terrine - Hühner-Nudeltopf', 'REWE'),
    ('Maggi', '5 Minuten Terrine - Hühner-Nudeltopf', 'Penny'),
    ('Netto', 'Hühner Nudeltopf', 'Netto'),
    ('Little Lunch', 'Little Lunch Bio Little Marokko 4280000878991 Bio-Eintopf mit Gemüse und Gewürzen marokkanischer Art', 'REWE'),
    ('Little Lunch', 'Little Lunch Bio Little Marokko 4280000878991 Bio-Eintopf mit Gemüse und Gewürzen marokkanischer Art', 'Rossmann'),
    ('Maggi', 'Tütensuppe', 'Edeka'),
    ('Maggi', 'Tütensuppe', 'REWE'),
    ('Maggi', 'Tütensuppe', 'Kaufland'),
    ('Maggi', 'Grießklößchen Suppe', 'Edeka'),
    ('Edeka', 'Hühner Nudeltopf', 'Edeka'),
    ('Followfood', 'Gemüsesuppe mit Kichererbsen', 'Tegut')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Soups' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

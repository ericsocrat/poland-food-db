-- PIPELINE (Seafood & Fish): store availability
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
    ('Aldi', 'ALDI ALMARE FISCH Räucherlachs XXL In hauchdünnen Scheiben Aus der Kühlung 3.49€ 220-g-Packung 1kg 15.86€', 'Aldi'),
    ('Aldi Archiv', 'Räucherlachs Bio', 'Aldi'),
    ('ArcticFish', 'Pures Grün Räucherlachs', 'Lidl'),
    ('Lidl', 'Bio-Räucherlachs, trockengesalzen, in Scheiben geschnitten', 'Lidl'),
    ('Golden Seafood', 'Fischstäbchen', 'Aldi'),
    ('Almare', 'Regenbogenforellenfilets über Eichenholzrauch heiß geräuchert', 'Aldi'),
    ('Almare', 'Norwegischer Räucherlachs in Scheiben - Mini-Pack', 'Aldi'),
    ('Krone', 'Räucherlachs', 'Edeka'),
    ('Krone', 'Räucherlachs', 'REWE'),
    ('Appel', 'Bratheringe in würzigem Aufguss', 'Aldi'),
    ('Appel', 'Bratheringe in würzigem Aufguss', 'Edeka'),
    ('Appel', 'Bratheringe in würzigem Aufguss', 'REWE'),
    ('Aldi', 'Bio-Räucherlachs', 'Aldi'),
    ('Almare Seafood', 'White Tiger Garnelen geschält, gekocht, entdarmt XXL', 'Aldi'),
    ('Aldi', 'Thunfischfilets in Sonnenblumenöl', 'Aldi'),
    ('Golden Seafood', 'Riesengarnelenschwänze - Provencale', 'Aldi'),
    ('Krone Fisch', 'Lachs aus verantwortungsvoller Fischzucht', 'REWE'),
    ('Krone Fisch', 'Lachs aus verantwortungsvoller Fischzucht', 'Kaufland'),
    ('Aldi', 'ALDI ALMARE FISCH Heringsfilets Geteilt in Tomaten-Sauce MSC-zertifiziert Dauertiefpreis 0.99€ 200-g-Dose 1kg 4.95€ 4061462739293', 'Aldi'),
    ('Almare', 'Stremellachs - Pfeffer', 'Aldi'),
    ('Almare Seafood', 'Lachs', 'Aldi'),
    ('Almare', 'Matjes Blister', 'Aldi'),
    ('Almare', 'Stremellachs - Natur', 'Aldi'),
    ('Ocean sea', 'King Prawns - White Tiger Garnelen', 'Lidl'),
    ('Frosta', 'Backofen Fisch (Knusprig Kross)', 'Kaufland'),
    ('Nordsee', 'Fischfrikadellen', 'Lidl'),
    ('Almare Seafood', 'Lachsforelle', 'Aldi'),
    ('Lidl', 'Bio Stremel Lachs', 'Lidl'),
    ('Almare', 'Marinierte Garnelen - Tomate-Chili', 'Aldi'),
    ('Almare', 'Matjesfilets mit Honig-Senf-Sauce', 'Aldi'),
    ('Lidl', 'Smoke Salmon Slices', 'Lidl'),
    ('Deutsche See GmbH', 'Lachsfilet', 'REWE'),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'Aldi'),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'Lidl'),
    ('Homann Feinkost', 'Sahne-Heringsfilets mit Zwiebel, Gurke & Apfel', 'Kaufland'),
    ('Select & Go', 'Sushi Box', 'Lidl'),
    ('Almare', 'Heringsfilets geteilt in Tomatensauce - fettreduziert', 'Aldi'),
    ('Golden Seafood', 'White-Tiger-Garnelen', 'Aldi'),
    ('Edeka', 'Räucherlachs', 'Edeka'),
    ('REWE Bio', 'Räucherlachs', 'REWE'),
    ('Natürlich für uns', 'Bio Räucherlachs', 'Lidl'),
    ('Ja!', 'Regenbogenforelle Geräuchert', 'REWE'),
    ('Sea Gold', 'Fischstäbchen', 'Netto')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Seafood & Fish' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

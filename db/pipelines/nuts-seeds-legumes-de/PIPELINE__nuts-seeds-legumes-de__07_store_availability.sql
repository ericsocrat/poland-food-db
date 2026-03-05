-- PIPELINE (Nuts, Seeds & Legumes): store availability
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
    ('Ültje', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'Aldi'),
    ('Ültje', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'Edeka'),
    ('Ültje', 'Erdnüsse', 'Norma'),
    ('Ültje', 'EXTRA ROAST Erdnüsse gesalzen', 'Edeka'),
    ('Farmer', 'Cashewkerne - geröstet & gesalzen', 'Aldi'),
    ('Maryland', 'Snack Nüsse pur', 'REWE'),
    ('Maryland', 'Snack Nüsse pur', 'Penny'),
    ('Maryland', 'Snack Nüsse pur', 'Netto'),
    ('K-Classic', 'Erdnüsse geröstet & gesalzen', 'Kaufland'),
    ('Ültje', 'Ofen Erdnüsse gesalzen', 'Kaufland'),
    ('Alesto', 'Erdnusskerne geröstet', 'Lidl'),
    ('Aldi', 'Pistazien - geröstet & gesalzen', 'Aldi'),
    ('Maryland', 'Nuss-Kern-Mischung geröstet & gesalzen', 'Penny'),
    ('Maryland', 'Nuss-Kern-Mischung geröstet & gesalzen', 'Netto'),
    ('Alesto', 'XXL Erdnüsse', 'Lidl'),
    ('Eurofood', 'Macadamia geröstet & gesalzen', 'Aldi'),
    ('Aldi', 'Erdnüsse in der Schale, geröstet', 'Aldi'),
    ('Seeberger', 'Cashew Kerne Nüsse', 'dm'),
    ('August Töpfer', 'Nuss-Mix, geröstet & gesalzen', 'Aldi'),
    ('Maryland', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'Edeka'),
    ('Maryland', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'Penny'),
    ('Farmer', 'Cashewkerne - pikant gewürzt', 'Aldi'),
    ('XOX', 'Erdnüsse geröstet ohne Salz', 'Netto'),
    ('Farmer', 'Pistazien - geröstet & ungesalzen', 'Aldi'),
    ('K-Classic', 'Erdnüsse geröstet', 'Kaufland'),
    ('Maryland', 'Snack Nüsse Honig & Salz', 'Edeka'),
    ('Maryland', 'Snack Nüsse Honig & Salz', 'Netto'),
    ('Lorenz', 'NicNacs', 'Edeka'),
    ('Lorenz', 'NicNacs', 'REWE'),
    ('Farmer Naturals', 'Walnusskerne naturbelassen', 'Aldi'),
    ('Seeberger', 'Nusskernmischung', 'Kaufland'),
    ('Fazer naturals', 'Feinste Nuss-Variation, naturbelassen', 'Aldi'),
    ('Alesto', 'Mix Proteína Frutos Secos Y Soja', 'Lidl'),
    ('Farmer Naturals', 'Cashewkerne naturbelassen', 'Aldi'),
    ('Farmer Naturals', 'Premium-Nussmix - Fein mit Pekannusskernen', 'Aldi'),
    ('Alesto Selection', 'Pecan Nuts natural', 'Lidl'),
    ('Trader Joe''s', 'Walnusskerne naturbelassen', 'Aldi'),
    ('Farmer Naturals', 'Simply Roasted - Cashewkerne', 'Aldi'),
    ('Trader Joe''s', 'Cashewkerne, naturbelassen', 'Aldi'),
    ('Farmer', 'Trail-Mix Kerne', 'Aldi'),
    ('DmBio', 'Mandeln ganze Kerne', 'dm'),
    ('Farmer Naturals', 'Simply Roasted - Nussmischung', 'Aldi'),
    ('Trader joes', 'Pistachio mix', 'Aldi'),
    ('Seeberger', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 'Edeka'),
    ('Alesto', 'Cashew Nuts XXL', 'Lidl'),
    ('Alesto', 'Mandeln Honig & Salz', 'Lidl'),
    ('Alesto', 'Noisettes grillées', 'Lidl')
) AS d(brand, product_name, store_name)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Nuts, Seeds & Legumes' AND p.is_deprecated IS NOT TRUE
JOIN store_ref sr ON sr.country = 'DE' AND sr.store_name = d.store_name AND sr.is_active = true
ON CONFLICT (product_id, store_id) DO NOTHING;

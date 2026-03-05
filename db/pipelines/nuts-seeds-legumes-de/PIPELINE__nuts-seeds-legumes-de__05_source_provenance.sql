-- PIPELINE (Nuts, Seeds & Legumes): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Ültje', 'Erdnüsse geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4004980401907', '4004980401907'),
    ('Ültje', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'https://world.openfoodfacts.org/product/4004980404007', '4004980404007'),
    ('Ültje', 'Erdnüsse', 'https://world.openfoodfacts.org/product/4004980400504', '4004980400504'),
    ('Ültje', 'EXTRA ROAST Erdnüsse gesalzen', 'https://world.openfoodfacts.org/product/4004980512801', '4004980512801'),
    ('Farmer', 'Cashewkerne - geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4061458056618', '4061458056618'),
    ('Maryland', 'Snack Nüsse pur', 'https://world.openfoodfacts.org/product/4008088919821', '4008088919821'),
    ('K-Classic', 'Erdnüsse geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4063367419102', '4063367419102'),
    ('Ültje', 'Ofen Erdnüsse gesalzen', 'https://world.openfoodfacts.org/product/4004980513006', '4004980513006'),
    ('Alesto', 'Erdnusskerne geröstet', 'https://world.openfoodfacts.org/product/4056489150374', '4056489150374'),
    ('Aldi', 'Pistazien - geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4088500665956', '4088500665956'),
    ('Maryland', 'Nuss-Kern-Mischung geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4008088184038', '4008088184038'),
    ('Alesto', 'XXL Erdnüsse', 'https://world.openfoodfacts.org/product/4056489105169', '4056489105169'),
    ('Eurofood', 'Macadamia geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4061458056557', '4061458056557'),
    ('Aldi', 'Erdnüsse in der Schale, geröstet', 'https://world.openfoodfacts.org/product/4061461698263', '4061461698263'),
    ('Seeberger', 'Cashew Kerne Nüsse', 'https://world.openfoodfacts.org/product/4008258107010', '4008258107010'),
    ('August Töpfer', 'Nuss-Mix, geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4061458056595', '4061458056595'),
    ('Maryland', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'https://world.openfoodfacts.org/product/4008088920018', '4008088920018'),
    ('Farmer', 'Cashewkerne - pikant gewürzt', 'https://world.openfoodfacts.org/product/4061458056656', '4061458056656'),
    ('XOX', 'Erdnüsse geröstet ohne Salz', 'https://world.openfoodfacts.org/product/4031446850108', '4031446850108'),
    ('Farmer', 'Pistazien - geröstet & ungesalzen', 'https://world.openfoodfacts.org/product/4088500665963', '4088500665963'),
    ('K-Classic', 'Erdnüsse geröstet', 'https://world.openfoodfacts.org/product/4063367143144', '4063367143144'),
    ('Maryland', 'Snack Nüsse Honig & Salz', 'https://world.openfoodfacts.org/product/4008088184458', '4008088184458'),
    ('Ültje', 'Erdnüsse pikant gewürzt', 'https://world.openfoodfacts.org/product/4004980514003', '4004980514003'),
    ('Farmer', 'Erdnusskerne - geröstet und gesalzen', 'https://world.openfoodfacts.org/product/4061461229917', '4061461229917'),
    ('Trader Joe''s', 'Erdnüsse geröstet und gesalzen', 'https://world.openfoodfacts.org/product/4047247192583', '4047247192583'),
    ('Ültje', 'Kessel Nüsse Paprika', 'https://world.openfoodfacts.org/product/4004980516809', '4004980516809'),
    ('Farmer', 'Erdnüsse', 'https://world.openfoodfacts.org/product/4088500658026', '4088500658026'),
    ('Ültje', 'Erdnüsse, geröstet & gesalzen', 'https://world.openfoodfacts.org/product/4004980501607', '4004980501607'),
    ('K Classic', 'Erdnüsse pikant', 'https://world.openfoodfacts.org/product/4063367353499', '4063367353499'),
    ('Alesto', 'Spanische Mandeln blanchiert und geröstet', 'https://world.openfoodfacts.org/product/4056489694403', '4056489694403'),
    ('Ültje', 'Erdnüsse ungesalzen', 'https://world.openfoodfacts.org/product/4004980507500', '4004980507500'),
    ('Ültje', 'Mandeln & Erdnüsse Honig und Salz', 'https://world.openfoodfacts.org/product/4004980530508', '4004980530508'),
    ('Lorenz', 'NicNacs', 'https://world.openfoodfacts.org/product/4018077004896', '4018077004896'),
    ('Farmer Naturals', 'Walnusskerne naturbelassen', 'https://world.openfoodfacts.org/product/4061461689087', '4061461689087'),
    ('Seeberger', 'Nusskernmischung', 'https://world.openfoodfacts.org/product/4008258150092', '4008258150092'),
    ('Fazer naturals', 'Feinste Nuss-Variation, naturbelassen', 'https://world.openfoodfacts.org/product/4061462369551', '4061462369551'),
    ('Alesto', 'Mix Proteína Frutos Secos Y Soja', 'https://world.openfoodfacts.org/product/4056489357117', '4056489357117'),
    ('Farmer Naturals', 'Cashewkerne naturbelassen', 'https://world.openfoodfacts.org/product/4061458057813', '4061458057813'),
    ('Farmer Naturals', 'Premium-Nussmix - Fein mit Pekannusskernen', 'https://world.openfoodfacts.org/product/4061458140102', '4061458140102'),
    ('Alesto Selection', 'Pecan Nuts natural', 'https://world.openfoodfacts.org/product/4056489682677', '4056489682677'),
    ('Trader Joe''s', 'Walnusskerne naturbelassen', 'https://world.openfoodfacts.org/product/4047247192637', '4047247192637'),
    ('Farmer Naturals', 'Simply Roasted - Cashewkerne', 'https://world.openfoodfacts.org/product/4061462602375', '4061462602375'),
    ('Trader Joe''s', 'Cashewkerne, naturbelassen', 'https://world.openfoodfacts.org/product/4047247192743', '4047247192743'),
    ('Farmer', 'Trail-Mix Kerne', 'https://world.openfoodfacts.org/product/4061462713910', '4061462713910'),
    ('DmBio', 'Mandeln ganze Kerne', 'https://world.openfoodfacts.org/product/4066447615821', '4066447615821'),
    ('Farmer Naturals', 'Simply Roasted - Nussmischung', 'https://world.openfoodfacts.org/product/4061462602399', '4061462602399'),
    ('Trader joes', 'Pistachio mix', 'https://world.openfoodfacts.org/product/4047247971287', '4047247971287'),
    ('Seeberger', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 'https://world.openfoodfacts.org/product/4008258130018', '4008258130018'),
    ('Alesto', 'Cashew Nuts XXL', 'https://world.openfoodfacts.org/product/40893532', '40893532'),
    ('Alesto', 'Mandeln Honig & Salz', 'https://world.openfoodfacts.org/product/4056489018995', '4056489018995'),
    ('Alesto', 'Noisettes grillées', 'https://world.openfoodfacts.org/product/4056489033042', '4056489033042')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Nuts, Seeds & Legumes' AND p.is_deprecated IS NOT TRUE;

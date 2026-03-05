-- PIPELINE (Nuts, Seeds & Legumes): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Nuts, Seeds & Legumes'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Ültje', 'Erdnüsse geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/400/498/040/1907/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980401907', 'front_4004980401907'),
    ('Ültje', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'https://images.openfoodfacts.org/images/products/400/498/040/4007/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980404007', 'front_4004980404007'),
    ('Ültje', 'Erdnüsse', 'https://images.openfoodfacts.org/images/products/400/498/040/0504/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980400504', 'front_4004980400504'),
    ('Ültje', 'EXTRA ROAST Erdnüsse gesalzen', 'https://images.openfoodfacts.org/images/products/400/498/051/2801/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980512801', 'front_4004980512801'),
    ('Farmer', 'Cashewkerne - geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/406/145/805/6618/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458056618', 'front_4061458056618'),
    ('Maryland', 'Snack Nüsse pur', 'https://images.openfoodfacts.org/images/products/400/808/891/9821/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008088919821', 'front_4008088919821'),
    ('K-Classic', 'Erdnüsse geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/406/336/741/9102/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367419102', 'front_4063367419102'),
    ('Ültje', 'Ofen Erdnüsse gesalzen', 'https://images.openfoodfacts.org/images/products/400/498/051/3006/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980513006', 'front_4004980513006'),
    ('Alesto', 'Erdnusskerne geröstet', 'https://images.openfoodfacts.org/images/products/405/648/915/0374/front_de.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489150374', 'front_4056489150374'),
    ('Aldi', 'Pistazien - geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/408/850/066/5956/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4088500665956', 'front_4088500665956'),
    ('Maryland', 'Nuss-Kern-Mischung geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/400/808/818/4038/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008088184038', 'front_4008088184038'),
    ('Alesto', 'XXL Erdnüsse', 'https://images.openfoodfacts.org/images/products/405/648/910/5169/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489105169', 'front_4056489105169'),
    ('Eurofood', 'Macadamia geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/406/145/805/6557/front_de.45.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458056557', 'front_4061458056557'),
    ('Aldi', 'Erdnüsse in der Schale, geröstet', 'https://images.openfoodfacts.org/images/products/406/146/169/8263/front_de.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461698263', 'front_4061461698263'),
    ('Seeberger', 'Cashew Kerne Nüsse', 'https://images.openfoodfacts.org/images/products/400/825/810/7010/front_de.124.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008258107010', 'front_4008258107010'),
    ('August Töpfer', 'Nuss-Mix, geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/406/145/805/6595/front_de.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458056595', 'front_4061458056595'),
    ('Maryland', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'https://images.openfoodfacts.org/images/products/400/808/892/0018/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008088920018', 'front_4008088920018'),
    ('Farmer', 'Cashewkerne - pikant gewürzt', 'https://images.openfoodfacts.org/images/products/406/145/805/6656/front_de.37.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458056656', 'front_4061458056656'),
    ('XOX', 'Erdnüsse geröstet ohne Salz', 'https://images.openfoodfacts.org/images/products/403/144/685/0108/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4031446850108', 'front_4031446850108'),
    ('Farmer', 'Pistazien - geröstet & ungesalzen', 'https://images.openfoodfacts.org/images/products/408/850/066/5963/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4088500665963', 'front_4088500665963'),
    ('K-Classic', 'Erdnüsse geröstet', 'https://images.openfoodfacts.org/images/products/406/336/714/3144/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367143144', 'front_4063367143144'),
    ('Maryland', 'Snack Nüsse Honig & Salz', 'https://images.openfoodfacts.org/images/products/400/808/818/4458/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008088184458', 'front_4008088184458'),
    ('Ültje', 'Erdnüsse pikant gewürzt', 'https://images.openfoodfacts.org/images/products/400/498/051/4003/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980514003', 'front_4004980514003'),
    ('Farmer', 'Erdnusskerne - geröstet und gesalzen', 'https://images.openfoodfacts.org/images/products/406/146/122/9917/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461229917', 'front_4061461229917'),
    ('Trader Joe''s', 'Erdnüsse geröstet und gesalzen', 'https://images.openfoodfacts.org/images/products/404/724/719/2583/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247192583', 'front_4047247192583'),
    ('Ültje', 'Kessel Nüsse Paprika', 'https://images.openfoodfacts.org/images/products/400/498/051/6809/front_en.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980516809', 'front_4004980516809'),
    ('Farmer', 'Erdnüsse', 'https://images.openfoodfacts.org/images/products/408/850/065/8026/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4088500658026', 'front_4088500658026'),
    ('Ültje', 'Erdnüsse, geröstet & gesalzen', 'https://images.openfoodfacts.org/images/products/400/498/050/1607/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980501607', 'front_4004980501607'),
    ('K Classic', 'Erdnüsse pikant', 'https://images.openfoodfacts.org/images/products/406/336/735/3499/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4063367353499', 'front_4063367353499'),
    ('Alesto', 'Spanische Mandeln blanchiert und geröstet', 'https://images.openfoodfacts.org/images/products/405/648/969/4403/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489694403', 'front_4056489694403'),
    ('Ültje', 'Erdnüsse ungesalzen', 'https://images.openfoodfacts.org/images/products/400/498/050/7500/front_de.41.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980507500', 'front_4004980507500'),
    ('Ültje', 'Mandeln & Erdnüsse Honig und Salz', 'https://images.openfoodfacts.org/images/products/400/498/053/0508/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004980530508', 'front_4004980530508'),
    ('Lorenz', 'NicNacs', 'https://images.openfoodfacts.org/images/products/401/807/700/4896/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4018077004896', 'front_4018077004896'),
    ('Farmer Naturals', 'Walnusskerne naturbelassen', 'https://images.openfoodfacts.org/images/products/406/146/168/9087/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461689087', 'front_4061461689087'),
    ('Seeberger', 'Nusskernmischung', 'https://images.openfoodfacts.org/images/products/400/825/815/0092/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008258150092', 'front_4008258150092'),
    ('Fazer naturals', 'Feinste Nuss-Variation, naturbelassen', 'https://images.openfoodfacts.org/images/products/406/146/236/9551/front_de.94.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462369551', 'front_4061462369551'),
    ('Alesto', 'Mix Proteína Frutos Secos Y Soja', 'https://images.openfoodfacts.org/images/products/405/648/935/7117/front_en.86.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489357117', 'front_4056489357117'),
    ('Farmer Naturals', 'Cashewkerne naturbelassen', 'https://images.openfoodfacts.org/images/products/406/145/805/7813/front_de.89.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458057813', 'front_4061458057813'),
    ('Farmer Naturals', 'Premium-Nussmix - Fein mit Pekannusskernen', 'https://images.openfoodfacts.org/images/products/406/145/814/0102/front_de.71.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458140102', 'front_4061458140102'),
    ('Alesto Selection', 'Pecan Nuts natural', 'https://images.openfoodfacts.org/images/products/405/648/968/2677/front_en.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489682677', 'front_4056489682677'),
    ('Trader Joe''s', 'Walnusskerne naturbelassen', 'https://images.openfoodfacts.org/images/products/404/724/719/2637/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247192637', 'front_4047247192637'),
    ('Farmer Naturals', 'Simply Roasted - Cashewkerne', 'https://images.openfoodfacts.org/images/products/406/146/260/2375/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462602375', 'front_4061462602375'),
    ('Trader Joe''s', 'Cashewkerne, naturbelassen', 'https://images.openfoodfacts.org/images/products/404/724/719/2743/front_de.55.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247192743', 'front_4047247192743'),
    ('Farmer', 'Trail-Mix Kerne', 'https://images.openfoodfacts.org/images/products/406/146/271/3910/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462713910', 'front_4061462713910'),
    ('DmBio', 'Mandeln ganze Kerne', 'https://images.openfoodfacts.org/images/products/406/644/761/5821/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447615821', 'front_4066447615821'),
    ('Farmer Naturals', 'Simply Roasted - Nussmischung', 'https://images.openfoodfacts.org/images/products/406/146/260/2399/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462602399', 'front_4061462602399'),
    ('Trader joes', 'Pistachio mix', 'https://images.openfoodfacts.org/images/products/404/724/797/1287/front_en.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 4047247971287', 'front_4047247971287'),
    ('Seeberger', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 'https://images.openfoodfacts.org/images/products/400/825/813/0018/front_de.155.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008258130018', 'front_4008258130018'),
    ('Alesto', 'Cashew Nuts XXL', 'https://images.openfoodfacts.org/images/products/000/004/089/3532/front_en.168.400.jpg', 'off_api', 'front', true, 'Front — EAN 40893532', 'front_40893532'),
    ('Alesto', 'Mandeln Honig & Salz', 'https://images.openfoodfacts.org/images/products/405/648/901/8995/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489018995', 'front_4056489018995'),
    ('Alesto', 'Noisettes grillées', 'https://images.openfoodfacts.org/images/products/405/648/903/3042/front_en.125.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489033042', 'front_4056489033042')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Nuts, Seeds & Legumes' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

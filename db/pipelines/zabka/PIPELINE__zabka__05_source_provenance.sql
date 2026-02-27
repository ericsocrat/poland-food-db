-- PIPELINE (Żabka): source provenance
-- Generated: 2026-02-28

-- 1. Update source info on products with EAN barcodes
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Żabka',         'Meksykaner',                            'https://world.openfoodfacts.org/product/2050000645372', '2050000645372'),
    ('Żabka',         'Kurczaker',                             'https://world.openfoodfacts.org/product/2050000554995', '2050000554995'),
    ('Żabka',         'Wołowiner Ser Kozi',                    'https://world.openfoodfacts.org/product/5908308910043', '5908308910043'),
    ('Żabka',         'Burger Kibica',                         'https://world.openfoodfacts.org/product/5908308910791', '5908308910791'),
    ('Żabka',         'Falafel Rollo',                         'https://world.openfoodfacts.org/product/5903738866274', '5903738866274'),
    ('Żabka',         'Kajzerka Kebab',                        'https://world.openfoodfacts.org/product/5903111184766', '5903111184766'),
    ('Żabka',         'Panini z serem cheddar',                'https://world.openfoodfacts.org/product/5908308908729', '5908308908729'),
    ('Żabka',         'Panini z kurczakiem',                   'https://world.openfoodfacts.org/product/2040100470387', '2040100470387'),
    ('Żabka',         'Kulki owsiane z czekoladą',             'https://world.openfoodfacts.org/product/5903548012045', '5903548012045'),
    ('Tomcio Paluch', 'Szynka & Jajko',                        'https://world.openfoodfacts.org/product/8586020103553', '8586020103553'),
    ('Tomcio Paluch', 'Pieczony bekon, sałata, jajko',         'https://world.openfoodfacts.org/product/8586020104505', '8586020104505'),
    ('Tomcio Paluch', 'Bajgiel z salami',                      'https://world.openfoodfacts.org/product/5903111184339', '5903111184339'),
    ('Szamamm',       'Naleśniki z jabłkami i cynamonem',       'https://world.openfoodfacts.org/product/5901398082379', '5901398082379'),
    ('Szamamm',       'Placki ziemniaczane',                   'https://world.openfoodfacts.org/product/04998358',      '04998358'),
    ('Szamamm',       'Penne z kurczakiem',                    'https://world.openfoodfacts.org/product/5908308902093', '5908308902093'),
    ('Szamamm',       'Kotlet de Volaille',                    'https://world.openfoodfacts.org/product/06638993',      '06638993'),
    ('Żabka',         'Wegger',                                'https://world.openfoodfacts.org/product/2050000557415', '2050000557415'),
    ('Żabka',         'Bao Burger',                            'https://world.openfoodfacts.org/product/5908308911019', '5908308911019'),
    ('Żabka',         'Wieprzowiner',                          'https://world.openfoodfacts.org/product/5908308911637', '5908308911637'),
    ('Tomcio Paluch', 'Kanapka Cezar',                         'https://world.openfoodfacts.org/product/8586020100064', '8586020100064'),
    ('Tomcio Paluch', 'Kebab z kurczaka',                      'https://world.openfoodfacts.org/product/8586015136382', '8586015136382'),
    ('Tomcio Paluch', 'BBQ Strips',                            'https://world.openfoodfacts.org/product/8586015136399', '8586015136399'),
    ('Tomcio Paluch', 'Pasta jajeczna, por, jajko gotowane',   'https://world.openfoodfacts.org/product/8586020103768', '8586020103768'),
    ('Tomcio Paluch', 'High 24g protein',                      'https://world.openfoodfacts.org/product/8586020105540', '8586020105540'),
    ('Szamamm',       'Pierogi ruskie ze smażoną cebulką',     'https://world.openfoodfacts.org/product/00719063',      '00719063'),
    ('Szamamm',       'Gnocchi z kurczakiem',                  'https://world.openfoodfacts.org/product/5908308911309', '5908308911309'),
    ('Szamamm',       'Panierowane skrzydełka z kurczaka',     'https://world.openfoodfacts.org/product/5900757067941', '5900757067941'),
    ('Szamamm',       'Kotlet Drobiowy',                       'https://world.openfoodfacts.org/api/v2/search',        NULL)
) AS d(brand, product_name, source_url, source_ean)
WHERE p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.is_deprecated = FALSE;

-- PIPELINE (Alcohol): source provenance
-- Generated: 2026-03-04

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Franziskaner', 'Franziskaner Premium Weissbier Naturtrüb', 'https://world.openfoodfacts.org/product/4072700001126', '4072700001126'),
    ('Hauser Weinimport', 'Glühwein rot', 'https://world.openfoodfacts.org/product/4061458002622', '4061458002622'),
    ('Köstritzer', 'Köstritzer Schwarzbier', 'https://world.openfoodfacts.org/product/4014964111555', '4014964111555'),
    ('Hasseröder', 'Hasseröder Premium Pils', 'https://world.openfoodfacts.org/product/4014558326839', '4014558326839'),
    ('Spaten', 'Münchner Hell', 'https://world.openfoodfacts.org/product/4072700005315', '4072700005315'),
    ('Paulaner München', 'Weißbier-Zitrone Alkoholfrei', 'https://world.openfoodfacts.org/product/4066600242024', '4066600242024'),
    ('Mönchshof', 'Mönchshof Kellerbier', 'https://world.openfoodfacts.org/product/4082100009097', '4082100009097'),
    ('Erdinger', 'Weißbier', 'https://world.openfoodfacts.org/product/4002103000013', '4002103000013'),
    ('Lübzer', 'Lübzer Pils', 'https://world.openfoodfacts.org/product/40678337', '40678337'),
    ('Paulaner', 'Paulaner Original Münchner Hell', 'https://world.openfoodfacts.org/product/4066600251101', '4066600251101'),
    ('Paulaner', 'Münchner Hell', 'https://world.openfoodfacts.org/product/4066600301110', '4066600301110'),
    ('Mönchshof', 'Mönchshof Original Naturtrüb''s Alkoholfrei 4082100003552 Alkoholfreies Schankbier', 'https://world.openfoodfacts.org/product/4082100003552', '4082100003552'),
    ('Wernesgrüner', 'Wernesgrüner Pils', 'https://world.openfoodfacts.org/product/4015444000017', '4015444000017'),
    ('Köstritzer', 'Köstritzer Edel Pils', 'https://world.openfoodfacts.org/product/4014964111340', '4014964111340'),
    ('Neumarkter Lammsbräu', 'Neumarkter Lammsbräu Glutenfrei', 'https://world.openfoodfacts.org/product/4012852001698', '4012852001698'),
    ('Bayreuther Brauhaus', 'Bayreuther', 'https://world.openfoodfacts.org/product/40173894', '40173894'),
    ('Pülleken', 'Veltins', 'https://world.openfoodfacts.org/product/4005249061702', '4005249061702'),
    ('Veltins', 'Bier - Veltins Pilsener', 'https://world.openfoodfacts.org/product/4005249000565', '4005249000565'),
    ('Rotkäppchen', 'Sekt halbtrocken', 'https://world.openfoodfacts.org/product/4400066903530', '4400066903530'),
    ('Berliner', 'Berliner Pilsner', 'https://world.openfoodfacts.org/product/4004160005338', '4004160005338'),
    ('Jever', 'Jever Pilsener', 'https://world.openfoodfacts.org/product/4008948027000', '4008948027000'),
    ('0 Original', '5,0 Original Pils', 'https://world.openfoodfacts.org/product/4014086093364', '4014086093364'),
    ('Mönchshof', 'Natur Radler', 'https://world.openfoodfacts.org/product/4082100005044', '4082100005044'),
    ('Störtebeker', 'Atlantik Ale', 'https://world.openfoodfacts.org/product/4014807204840', '4014807204840'),
    ('Nordbrand Nordhausen', 'Pfefferminz', 'https://world.openfoodfacts.org/product/4400065403109', '4400065403109'),
    ('Warsteiner', 'Radler alkoholfrei', 'https://world.openfoodfacts.org/product/4000856007129', '4000856007129'),
    ('Warsteiner', 'Pilsener', 'https://world.openfoodfacts.org/product/4000856003688', '4000856003688'),
    ('Mumm', 'Sekt, Jahrgang Dry, alkoholfrei', 'https://world.openfoodfacts.org/product/4011900670015', '4011900670015'),
    ('Mönchshof', 'Natur Radler 0,0%', 'https://world.openfoodfacts.org/product/4082100006508', '4082100006508'),
    ('Krombacher', 'Krombacher Pils', 'https://world.openfoodfacts.org/product/4008287056020', '4008287056020'),
    ('Herzoglich Bayerisches Brauhaus Tegernsee', 'Tegernseer Hell', 'https://world.openfoodfacts.org/product/4022396000026', '4022396000026'),
    ('Oettinger', 'Pils', 'https://world.openfoodfacts.org/product/4014086010361', '4014086010361'),
    ('Radeberger', 'Pilsner Alkoholfrei', 'https://world.openfoodfacts.org/product/4053400208527', '4053400208527'),
    ('Rothaus', 'Tannenzäpfle', 'https://world.openfoodfacts.org/product/41051825', '41051825'),
    ('Gesamt', 'Hefeweissbier hell', 'https://world.openfoodfacts.org/product/4066600641964', '4066600641964'),
    ('Unknown', 'Wodka Gorbatschow', 'https://world.openfoodfacts.org/product/4003310013759', '4003310013759'),
    ('Doppio Passo', 'Doppio Passo Rotwein alkoholfrei', 'https://world.openfoodfacts.org/product/4002859125800', '4002859125800'),
    ('Schloss Wachenheim', 'Light Live Red 0,0%', 'https://world.openfoodfacts.org/product/4001744024532', '4001744024532'),
    ('Paulaner', 'Natur-Radler', 'https://world.openfoodfacts.org/product/4066600201199', '4066600201199'),
    ('Franziskaner', 'Premium Weissbier Dunkel', 'https://world.openfoodfacts.org/product/4072700001188', '4072700001188'),
    ('Mönchshof', 'Radler Blutorange', 'https://world.openfoodfacts.org/product/4082100006102', '4082100006102'),
    ('Unknown', 'Benediktiner Hell', 'https://world.openfoodfacts.org/product/4052197003599', '4052197003599'),
    ('Christkindl', 'Christkindl Glühwein', 'https://world.openfoodfacts.org/product/4304493261709', '4304493261709'),
    ('Schöfferhofer', 'Weizen-Mix Grapefruit', 'https://world.openfoodfacts.org/product/4053400271729', '4053400271729'),
    ('Krombacher', 'Weizen Alkoholfrei', 'https://world.openfoodfacts.org/product/4008287064025', '4008287064025'),
    ('Allgäuer Brauhaus', 'Büble Bier Edelbräu', 'https://world.openfoodfacts.org/product/4103210001297', '4103210001297'),
    ('Gösser', 'Natur Radler', 'https://world.openfoodfacts.org/product/9028800638644', '9028800638644'),
    ('Budweiser', 'Budvar', 'https://world.openfoodfacts.org/product/8594403110111', '8594403110111'),
    ('Unknown', 'Pilsner Urquell', 'https://world.openfoodfacts.org/product/8594404110110', '8594404110110'),
    ('Carlsberg', 'Apple Cider', 'https://world.openfoodfacts.org/product/42400868', '42400868'),
    ('Cerveceria Modelio', 'Corona Extra', 'https://world.openfoodfacts.org/product/75033927', '75033927')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'DE' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE;

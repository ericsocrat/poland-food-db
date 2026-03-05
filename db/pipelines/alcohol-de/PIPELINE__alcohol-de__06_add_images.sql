-- PIPELINE (Alcohol): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Alcohol'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Franziskaner', 'Franziskaner Premium Weissbier Naturtrüb', 'https://images.openfoodfacts.org/images/products/407/270/000/1126/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4072700001126', 'front_4072700001126'),
    ('Hauser Weinimport', 'Glühwein rot', 'https://images.openfoodfacts.org/images/products/406/145/800/2622/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458002622', 'front_4061458002622'),
    ('Köstritzer', 'Köstritzer Schwarzbier', 'https://images.openfoodfacts.org/images/products/401/496/411/1555/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014964111555', 'front_4014964111555'),
    ('Hasseröder', 'Hasseröder Premium Pils', 'https://images.openfoodfacts.org/images/products/401/455/832/6839/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014558326839', 'front_4014558326839'),
    ('Spaten', 'Münchner Hell', 'https://images.openfoodfacts.org/images/products/407/270/000/5315/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4072700005315', 'front_4072700005315'),
    ('Paulaner München', 'Weißbier-Zitrone Alkoholfrei', 'https://images.openfoodfacts.org/images/products/406/660/024/2024/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600242024', 'front_4066600242024'),
    ('Mönchshof', 'Mönchshof Kellerbier', 'https://images.openfoodfacts.org/images/products/408/210/000/9097/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4082100009097', 'front_4082100009097'),
    ('Erdinger', 'Weißbier', 'https://images.openfoodfacts.org/images/products/400/210/300/0013/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002103000013', 'front_4002103000013'),
    ('Lübzer', 'Lübzer Pils', 'https://images.openfoodfacts.org/images/products/000/004/067/8337/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 40678337', 'front_40678337'),
    ('Paulaner', 'Paulaner Original Münchner Hell', 'https://images.openfoodfacts.org/images/products/406/660/025/1101/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600251101', 'front_4066600251101'),
    ('Paulaner', 'Münchner Hell', 'https://images.openfoodfacts.org/images/products/406/660/030/1110/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600301110', 'front_4066600301110'),
    ('Mönchshof', 'Mönchshof Original Naturtrüb''s Alkoholfrei 4082100003552 Alkoholfreies Schankbier', 'https://images.openfoodfacts.org/images/products/408/210/000/3552/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4082100003552', 'front_4082100003552'),
    ('Wernesgrüner', 'Wernesgrüner Pils', 'https://images.openfoodfacts.org/images/products/401/544/400/0017/front_de.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015444000017', 'front_4015444000017'),
    ('Köstritzer', 'Köstritzer Edel Pils', 'https://images.openfoodfacts.org/images/products/401/496/411/1340/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014964111340', 'front_4014964111340'),
    ('Neumarkter Lammsbräu', 'Neumarkter Lammsbräu Glutenfrei', 'https://images.openfoodfacts.org/images/products/401/285/200/1698/front_de.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 4012852001698', 'front_4012852001698'),
    ('Bayreuther Brauhaus', 'Bayreuther', 'https://images.openfoodfacts.org/images/products/000/004/017/3894/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 40173894', 'front_40173894'),
    ('Pülleken', 'Veltins', 'https://images.openfoodfacts.org/images/products/400/524/906/1702/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005249061702', 'front_4005249061702'),
    ('Veltins', 'Bier - Veltins Pilsener', 'https://images.openfoodfacts.org/images/products/400/524/900/0565/front_de.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 4005249000565', 'front_4005249000565'),
    ('Rotkäppchen', 'Sekt halbtrocken', 'https://images.openfoodfacts.org/images/products/440/006/690/3530/front_de.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400066903530', 'front_4400066903530'),
    ('Berliner', 'Berliner Pilsner', 'https://images.openfoodfacts.org/images/products/400/416/000/5338/front_fr.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4004160005338', 'front_4004160005338'),
    ('Jever', 'Jever Pilsener', 'https://images.openfoodfacts.org/images/products/400/894/802/7000/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008948027000', 'front_4008948027000'),
    ('0 Original', '5,0 Original Pils', 'https://images.openfoodfacts.org/images/products/401/408/609/3364/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014086093364', 'front_4014086093364'),
    ('Mönchshof', 'Natur Radler', 'https://images.openfoodfacts.org/images/products/408/210/000/5044/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4082100005044', 'front_4082100005044'),
    ('Störtebeker', 'Atlantik Ale', 'https://images.openfoodfacts.org/images/products/401/480/720/4840/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014807204840', 'front_4014807204840'),
    ('Nordbrand Nordhausen', 'Pfefferminz', 'https://images.openfoodfacts.org/images/products/440/006/540/3109/front_de.43.400.jpg', 'off_api', 'front', true, 'Front — EAN 4400065403109', 'front_4400065403109'),
    ('Warsteiner', 'Radler alkoholfrei', 'https://images.openfoodfacts.org/images/products/400/085/600/7129/front_de.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000856007129', 'front_4000856007129'),
    ('Warsteiner', 'Pilsener', 'https://images.openfoodfacts.org/images/products/400/085/600/3688/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000856003688', 'front_4000856003688'),
    ('Mumm', 'Sekt, Jahrgang Dry, alkoholfrei', 'https://images.openfoodfacts.org/images/products/401/190/067/0015/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4011900670015', 'front_4011900670015'),
    ('Mönchshof', 'Natur Radler 0,0%', 'https://images.openfoodfacts.org/images/products/408/210/000/6508/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4082100006508', 'front_4082100006508'),
    ('Krombacher', 'Krombacher Pils', 'https://images.openfoodfacts.org/images/products/400/828/705/6020/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008287056020', 'front_4008287056020'),
    ('Herzoglich Bayerisches Brauhaus Tegernsee', 'Tegernseer Hell', 'https://images.openfoodfacts.org/images/products/402/239/600/0026/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4022396000026', 'front_4022396000026'),
    ('Oettinger', 'Pils', 'https://images.openfoodfacts.org/images/products/401/408/601/0361/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4014086010361', 'front_4014086010361'),
    ('Radeberger', 'Pilsner Alkoholfrei', 'https://images.openfoodfacts.org/images/products/405/340/020/8527/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4053400208527', 'front_4053400208527'),
    ('Rothaus', 'Tannenzäpfle', 'https://images.openfoodfacts.org/images/products/000/004/105/1825/front_de.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 41051825', 'front_41051825'),
    ('Gesamt', 'Hefeweissbier hell', 'https://images.openfoodfacts.org/images/products/406/660/064/1964/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600641964', 'front_4066600641964'),
    ('Unknown', 'Wodka Gorbatschow', 'https://images.openfoodfacts.org/images/products/400/331/001/3759/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4003310013759', 'front_4003310013759'),
    ('Doppio Passo', 'Doppio Passo Rotwein alkoholfrei', 'https://images.openfoodfacts.org/images/products/400/285/912/5800/front_de.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4002859125800', 'front_4002859125800'),
    ('Schloss Wachenheim', 'Light Live Red 0,0%', 'https://images.openfoodfacts.org/images/products/400/174/402/4532/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4001744024532', 'front_4001744024532'),
    ('Paulaner', 'Natur-Radler', 'https://images.openfoodfacts.org/images/products/406/660/020/1199/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066600201199', 'front_4066600201199'),
    ('Franziskaner', 'Premium Weissbier Dunkel', 'https://images.openfoodfacts.org/images/products/407/270/000/1188/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4072700001188', 'front_4072700001188'),
    ('Mönchshof', 'Radler Blutorange', 'https://images.openfoodfacts.org/images/products/408/210/000/6102/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4082100006102', 'front_4082100006102'),
    ('Unknown', 'Benediktiner Hell', 'https://images.openfoodfacts.org/images/products/405/219/700/3599/front_de.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 4052197003599', 'front_4052197003599'),
    ('Christkindl', 'Christkindl Glühwein', 'https://images.openfoodfacts.org/images/products/430/449/326/1709/front_en.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 4304493261709', 'front_4304493261709'),
    ('Schöfferhofer', 'Weizen-Mix Grapefruit', 'https://images.openfoodfacts.org/images/products/405/340/027/1729/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4053400271729', 'front_4053400271729'),
    ('Krombacher', 'Weizen Alkoholfrei', 'https://images.openfoodfacts.org/images/products/400/828/706/4025/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008287064025', 'front_4008287064025'),
    ('Allgäuer Brauhaus', 'Büble Bier Edelbräu', 'https://images.openfoodfacts.org/images/products/410/321/000/1297/front_de.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4103210001297', 'front_4103210001297'),
    ('Gösser', 'Natur Radler', 'https://images.openfoodfacts.org/images/products/902/880/063/8644/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 9028800638644', 'front_9028800638644'),
    ('Budweiser', 'Budvar', 'https://images.openfoodfacts.org/images/products/859/440/311/0111/front_en.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 8594403110111', 'front_8594403110111'),
    ('Unknown', 'Pilsner Urquell', 'https://images.openfoodfacts.org/images/products/859/440/411/0110/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 8594404110110', 'front_8594404110110'),
    ('Carlsberg', 'Apple Cider', 'https://images.openfoodfacts.org/images/products/000/004/240/0868/front_de.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 42400868', 'front_42400868'),
    ('Cerveceria Modelio', 'Corona Extra', 'https://images.openfoodfacts.org/images/products/000/007/503/3927/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 75033927', 'front_75033927')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Alcohol' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

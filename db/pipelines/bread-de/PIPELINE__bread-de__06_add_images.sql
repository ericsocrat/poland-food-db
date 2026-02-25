-- PIPELINE (Bread): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-02-25

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'DE' AND p.category = 'Bread'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Gräfschafter', 'Eiweißreiches Weizenvollkornbrot', 'https://images.openfoodfacts.org/images/products/405/648/920/6026/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489206026', 'front_4056489206026'),
    ('Harry', 'Körner Balance Sandwich', 'https://images.openfoodfacts.org/images/products/407/180/003/8810/front_de.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038810', 'front_4071800038810'),
    ('Golden Toast', 'Sandwich Körner-Harmonie', 'https://images.openfoodfacts.org/images/products/400/924/900/1843/front_de.65.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249001843', 'front_4009249001843'),
    ('Lieken Urkorn', 'Fitnessbrot mit 5 % Ölsaaten', 'https://images.openfoodfacts.org/images/products/400/924/900/2277/front_de.104.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249002277', 'front_4009249002277'),
    ('Harry', 'Eiweißbrot', 'https://images.openfoodfacts.org/images/products/407/180/005/8269/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800058269', 'front_4071800058269'),
    ('Harry', 'Harry Dinkel Krüstchen 4071800057637', 'https://images.openfoodfacts.org/images/products/407/180/005/7637/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800057637', 'front_4071800057637'),
    ('Aldi', 'Das Pure - Bio-Haferbrot mit 29% Ölsaaten', 'https://images.openfoodfacts.org/images/products/406/146/107/7563/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461077563', 'front_4061461077563'),
    ('Conditorei Coppenrath & Wiese', 'Weizenbrötchen', 'https://images.openfoodfacts.org/images/products/400/857/700/6315/front_en.173.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008577006315', 'front_4008577006315'),
    ('Lieken', 'Roggenbäcker', 'https://images.openfoodfacts.org/images/products/400/924/900/2550/front_fr.56.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249002550', 'front_4009249002550'),
    ('Goldähren', 'Französisches Steinofen-Baguette', 'https://images.openfoodfacts.org/images/products/406/145/804/6046/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458046046', 'front_4061458046046'),
    ('Goldähren', 'Laugen-Brioche vorgeschnitten, 6 Stück', 'https://images.openfoodfacts.org/images/products/406/145/969/8992/front_de.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459698992', 'front_4061459698992'),
    ('Mestemacher', 'Westfälischen Pumpernickel', 'https://images.openfoodfacts.org/images/products/400/044/600/1018/front_de.78.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446001018', 'front_4000446001018'),
    ('Goldähren', 'Toast-Brötchen Protein', 'https://images.openfoodfacts.org/images/products/406/145/822/7650/front_de.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458227650', 'front_4061458227650'),
    ('GutBio', 'Das Pure - Haferbrot mit 27% Ölsaaten', 'https://images.openfoodfacts.org/images/products/406/145/817/6323/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458176323', 'front_4061458176323'),
    ('Coppenrath & Wiese', 'Dinkelbrötchen', 'https://images.openfoodfacts.org/images/products/400/857/700/6186/front_de.185.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008577006186', 'front_4008577006186'),
    ('Aldi', 'Bio-Landbrötchen - Kernig', 'https://images.openfoodfacts.org/images/products/406/870/647/1902/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706471902', 'front_4068706471902'),
    ('Sinnack', 'Brot Protein Brötchen', 'https://images.openfoodfacts.org/images/products/400/909/701/0691/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009097010691', 'front_4009097010691'),
    ('Harry', 'Körner Balance Toastbrötchen', 'https://images.openfoodfacts.org/images/products/407/180/003/8568/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038568', 'front_4071800038568'),
    ('Gut bio', 'Finnkorn Toastbrötchen', 'https://images.openfoodfacts.org/images/products/406/146/296/8624/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462968624', 'front_4061462968624'),
    ('Grafschafter', 'Pure Kornkraft Haferbrot', 'https://images.openfoodfacts.org/images/products/405/648/918/3631/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489183631', 'front_4056489183631'),
    ('Goldähren', 'Vollkorn-Sandwich', 'https://images.openfoodfacts.org/images/products/406/145/802/2040/front_de.171.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458022040', 'front_4061458022040'),
    ('Golden Toast', 'Vollkorn-Toast', 'https://images.openfoodfacts.org/images/products/400/924/901/9923/front_de.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249019923', 'front_4009249019923'),
    ('Harry', 'Harry Brot Vital + Fit', 'https://images.openfoodfacts.org/images/products/407/180/000/1012/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800001012', 'front_4071800001012'),
    ('Goldähren', 'Vollkorntoast', 'https://images.openfoodfacts.org/images/products/406/145/804/5759/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458045759', 'front_4061458045759'),
    ('Goldähren', 'Eiweiss Brot', 'https://images.openfoodfacts.org/images/products/406/145/805/5734/front_en.146.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458055734', 'front_4061458055734'),
    ('Meierbaer & Albro', 'Das Pure - Bio-Haferbrot', 'https://images.openfoodfacts.org/images/products/406/146/208/4256/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462084256', 'front_4061462084256'),
    ('Goldähren', 'Mehrkorn Wraps', 'https://images.openfoodfacts.org/images/products/406/145/804/5797/front_en.151.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458045797', 'front_4061458045797'),
    ('Goldähren', 'Protein-Wraps', 'https://images.openfoodfacts.org/images/products/406/145/823/6928/front_de.77.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458236928', 'front_4061458236928'),
    ('Nur Nur Natur', 'Bio-Roggenvollkornbrot', 'https://images.openfoodfacts.org/images/products/406/145/942/5697/front_de.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459425697', 'front_4061459425697'),
    ('DmBio', 'Das Pure Hafer - und Saatenbrot', 'https://images.openfoodfacts.org/images/products/406/779/616/2462/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4067796162462', 'front_4067796162462'),
    ('Goldähren', 'American Sandwich - Weizen', 'https://images.openfoodfacts.org/images/products/406/145/802/2033/front_de.94.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458022033', 'front_4061458022033'),
    ('Harry', 'Vollkorn Toast', 'https://images.openfoodfacts.org/images/products/407/180/000/0633/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000633', 'front_4071800000633'),
    ('Brandt', 'Brandt Markenzwieback', 'https://images.openfoodfacts.org/images/products/401/375/201/9004/front_de.112.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013752019004', 'front_4013752019004'),
    ('Harry', 'Unser Mildes (Weizenmischbrot)', 'https://images.openfoodfacts.org/images/products/407/180/000/0879/front_en.70.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000879', 'front_4071800000879'),
    ('Lieken', 'Bauernmild Brot', 'https://images.openfoodfacts.org/images/products/400/924/900/1171/front_de.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249001171', 'front_4009249001171'),
    ('Lieken Urkorn', 'Vollkornsaftiges fein', 'https://images.openfoodfacts.org/images/products/400/617/000/1676/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4006170001676', 'front_4006170001676'),
    ('Goldähren', 'Mehrkornschnitten', 'https://images.openfoodfacts.org/images/products/406/145/816/9066/front_de.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458169066', 'front_4061458169066'),
    ('Mestemacher', 'Dinkel Wraps', 'https://images.openfoodfacts.org/images/products/400/044/601/5497/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446015497', 'front_4000446015497'),
    ('Harry', 'Toastbrot', 'https://images.openfoodfacts.org/images/products/407/180/003/8803/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038803', 'front_4071800038803'),
    ('Harry', 'Vollkorn Urtyp', 'https://images.openfoodfacts.org/images/products/407/180/003/4508/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800034508', 'front_4071800034508'),
    ('Golden Toast', 'Vollkorn Toast', 'https://images.openfoodfacts.org/images/products/400/924/902/2565/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249022565', 'front_4009249022565'),
    ('Harry', 'Harry 1688 Korn an Korn', 'https://images.openfoodfacts.org/images/products/407/180/000/0824/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000824', 'front_4071800000824'),
    ('Golden Toast', 'Buttertoast', 'https://images.openfoodfacts.org/images/products/400/924/901/9916/front_de.88.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249019916', 'front_4009249019916'),
    ('Brandt', 'Der Markenzwieback', 'https://images.openfoodfacts.org/images/products/401/375/201/9547/front_de.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013752019547', 'front_4013752019547'),
    ('Gutes aus der Bäckerei', 'Weissbrot', 'https://images.openfoodfacts.org/images/products/407/180/000/1081/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800001081', 'front_4071800001081'),
    ('Harry', 'Mischbrot Anno 1688 Klassisch, Harry', 'https://images.openfoodfacts.org/images/products/407/180/005/2618/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800052618', 'front_4071800052618'),
    ('Goldähren', 'Dreisaatbrot - Roggenvollkornbrot', 'https://images.openfoodfacts.org/images/products/406/145/805/4263/front_de.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458054263', 'front_4061458054263'),
    ('Golden Toast', 'Dinkel-Harmonie Sandwich', 'https://images.openfoodfacts.org/images/products/400/924/903/8184/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249038184', 'front_4009249038184'),
    ('Filinchen', 'Das Knusperbrot Original', 'https://images.openfoodfacts.org/images/products/401/542/711/1112/front_de.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 4015427111112', 'front_4015427111112'),
    ('Goldähren', 'Saaten-Sandwich', 'https://images.openfoodfacts.org/images/products/406/145/804/5827/front_de.77.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458045827', 'front_4061458045827'),
    ('Cucina', 'Pinsa', 'https://images.openfoodfacts.org/images/products/406/145/971/2001/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459712001', 'front_4061459712001')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Bread' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

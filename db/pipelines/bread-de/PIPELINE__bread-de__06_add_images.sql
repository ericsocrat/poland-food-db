-- PIPELINE (Bread): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

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
    ('Goldähren', 'Proteinbrötchen zum Fertigbacken', 'https://images.openfoodfacts.org/images/products/406/146/306/0327/front_de.40.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061463060327', 'front_4061463060327'),
    ('Grafschafter', 'Mehrkorn-Toastbrötchen', 'https://images.openfoodfacts.org/images/products/405/648/910/0522/front_de.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489100522', 'front_4056489100522'),
    ('Conditorei Coppenrath & Wiese', 'Baguette-Brötchen', 'https://images.openfoodfacts.org/images/products/400/857/700/6391/front_de.110.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008577006391', 'front_4008577006391'),
    ('Cucina', 'Grissotti - Olivenöl und Meersalz', 'https://images.openfoodfacts.org/images/products/406/146/101/0911/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461010911', 'front_4061461010911'),
    ('K-Classic', 'Toastbrötchen Mehrkorn', 'https://images.openfoodfacts.org/images/products/406/844/500/0029/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068445000029', 'front_4068445000029'),
    ('Golden Toast', 'Körnerharmonie-Toast', 'https://images.openfoodfacts.org/images/products/400/924/901/9954/front_de.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249019954', 'front_4009249019954'),
    ('Mestemacher', 'High Protein Eiweißbrot', 'https://images.openfoodfacts.org/images/products/400/044/601/1376/front_de.137.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446011376', 'front_4000446011376'),
    ('EDEKA Harry', 'EDEKA Harry Harry XXL Burger Brötchen 4 Stück 300g 1.79€ 1kg 5.97€', 'https://images.openfoodfacts.org/images/products/407/180/003/8612/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038612', 'front_4071800038612'),
    ('Golden Toast', 'Körner Toasties (2x 3 Stück, 300 g; pro 3 Stück aufgeführt)', 'https://images.openfoodfacts.org/images/products/400/924/904/0071/front_de.33.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249040071', 'front_4009249040071'),
    ('GutBio', 'Das Pure - Haferbrot mit 27% Ölsaaten', 'https://images.openfoodfacts.org/images/products/406/145/817/6323/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458176323', 'front_4061458176323'),
    ('Coppenrath & Wiese', 'Dinkelbrötchen', 'https://images.openfoodfacts.org/images/products/400/857/700/6186/front_de.185.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008577006186', 'front_4008577006186'),
    ('Aldi', 'Bio-Landbrötchen - Kernig', 'https://images.openfoodfacts.org/images/products/406/870/647/1902/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706471902', 'front_4068706471902'),
    ('Sinnack', 'Brot Protein Brötchen', 'https://images.openfoodfacts.org/images/products/400/909/701/0691/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009097010691', 'front_4009097010691'),
    ('Harry', 'Körner Balance Toastbrötchen', 'https://images.openfoodfacts.org/images/products/407/180/003/8568/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038568', 'front_4071800038568'),
    ('Gut Bio', 'Finnkorn Toastbrötchen', 'https://images.openfoodfacts.org/images/products/406/146/296/8624/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462968624', 'front_4061462968624'),
    ('Harry', 'Dinkel Toastbrötchen 4071800048611', 'https://images.openfoodfacts.org/images/products/407/180/004/8611/front_de.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800048611', 'front_4071800048611'),
    ('Mestemacher', 'Mestemacher High Protein Toastbrötchen 4000446016791 Eiweiß Toastbrötchen', 'https://images.openfoodfacts.org/images/products/400/044/601/6791/front_en.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446016791', 'front_4000446016791'),
    ('Bio', 'Bio-Landbrötchen - Weizen', 'https://images.openfoodfacts.org/images/products/406/870/647/1896/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706471896', 'front_4068706471896'),
    ('Leimer', 'Semmelbrösel', 'https://images.openfoodfacts.org/images/products/400/018/601/0400/front_de.77.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000186010400', 'front_4000186010400'),
    ('Mestemacher', 'Eiweißbrot mit Karotten', 'https://images.openfoodfacts.org/images/products/400/044/601/1420/front_de.91.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446011420', 'front_4000446011420'),
    ('Mestemacher', '1 stück Wraps Tortilla', 'https://images.openfoodfacts.org/images/products/400/044/601/6630/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 4000446016630', 'front_4000446016630'),
    ('Harry', 'Körner Balance toast', 'https://images.openfoodfacts.org/images/products/407/180/003/8780/front_de.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800038780', 'front_4071800038780'),
    ('Bäcker', 'Roggenbrötchen', 'https://images.openfoodfacts.org/images/products/400/857/700/6278/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 4008577006278', 'front_4008577006278'),
    ('Goldähren', 'Toast Brötchen Mehrkorn', 'https://images.openfoodfacts.org/images/products/406/145/823/9240/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458239240', 'front_4061458239240'),
    ('DmBio', 'Eiweißbrot', 'https://images.openfoodfacts.org/images/products/406/644/737/0072/front_de.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 4066447370072', 'front_4066447370072'),
    ('Grafschafter', 'Pure Kornkraft Haferbrot', 'https://images.openfoodfacts.org/images/products/405/648/918/3631/front_de.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489183631', 'front_4056489183631'),
    ('Goldähren', 'Vollkorn-Sandwich', 'https://images.openfoodfacts.org/images/products/406/145/802/2040/front_de.171.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458022040', 'front_4061458022040'),
    ('Golden Toast', 'Vollkorn-Toast', 'https://images.openfoodfacts.org/images/products/400/924/901/9923/front_de.121.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249019923', 'front_4009249019923'),
    ('Harry', 'Harry Brot Vital + Fit', 'https://images.openfoodfacts.org/images/products/407/180/000/1012/front_de.92.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800001012', 'front_4071800001012'),
    ('Goldähren', 'Vollkorntoast', 'https://images.openfoodfacts.org/images/products/406/145/804/5759/front_de.64.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458045759', 'front_4061458045759'),
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
    ('Cucina', 'Pinsa', 'https://images.openfoodfacts.org/images/products/406/145/971/2001/front_de.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459712001', 'front_4061459712001'),
    ('Nur Nur Natur', 'Das Pure Bio', 'https://images.openfoodfacts.org/images/products/406/146/208/4454/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061462084454', 'front_4061462084454'),
    ('Harry', '1688 Mehrkorn', 'https://images.openfoodfacts.org/images/products/407/180/000/0992/front_fr.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000992', 'front_4071800000992'),
    ('Goldähren', 'Wraps - Weizen', 'https://images.openfoodfacts.org/images/products/406/145/804/5780/front_de.95.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458045780', 'front_4061458045780'),
    ('Harry', 'Vital & pur', 'https://images.openfoodfacts.org/images/products/407/180/005/3462/front_de.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800053462', 'front_4071800053462'),
    ('Harry', 'Vollkorn mit Sonnenblumenkernen', 'https://images.openfoodfacts.org/images/products/407/180/000/3696/front_de.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800003696', 'front_4071800003696'),
    ('Golden Toast', 'Vollkorn-Harmonie Sandwich', 'https://images.openfoodfacts.org/images/products/400/924/900/2420/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249002420', 'front_4009249002420'),
    ('Harry', 'Roggenvollkornbrot Sonnenkern', 'https://images.openfoodfacts.org/images/products/407/180/000/0909/front_de.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000909', 'front_4071800000909'),
    ('Goldähren', 'Bauernschnitten', 'https://images.openfoodfacts.org/images/products/406/145/805/5901/front_de.54.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061458055901', 'front_4061458055901'),
    ('Harry', 'Voll:Korn - Katen - Harry 1688', 'https://images.openfoodfacts.org/images/products/407/180/000/0763/front_de.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800000763', 'front_4071800000763'),
    ('Grafschafter', 'Bauernmildes Weizenmischbrot', 'https://images.openfoodfacts.org/images/products/405/648/923/5750/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489235750', 'front_4056489235750'),
    ('Harry', 'Eiweiss Sandwich', 'https://images.openfoodfacts.org/images/products/407/180/005/8801/front_de.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800058801', 'front_4071800058801'),
    ('Aldi', 'Volles Korn dunkel - Roggenvollkornbrot', 'https://images.openfoodfacts.org/images/products/406/870/637/4456/front_de.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 4068706374456', 'front_4068706374456'),
    ('Grafschafter', 'American Style Sandwich Weizen', 'https://images.openfoodfacts.org/images/products/405/648/912/4184/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489124184', 'front_4056489124184'),
    ('Grafschafter', 'Pfundsschnitten Roggenmischbrot', 'https://images.openfoodfacts.org/images/products/405/648/912/3941/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123941', 'front_4056489123941'),
    ('Goldähren', 'Das Rustikale - Dinkel', 'https://images.openfoodfacts.org/images/products/406/146/190/1301/front_de.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461901301', 'front_4061461901301'),
    ('Brandt', 'Mini-Zwieback', 'https://images.openfoodfacts.org/images/products/401/375/204/0541/front_de.48.400.jpg', 'off_api', 'front', true, 'Front — EAN 4013752040541', 'front_4013752040541'),
    ('Kronenbrot', 'Rustikales Dinkel', 'https://images.openfoodfacts.org/images/products/407/180/006/0064/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800060064', 'front_4071800060064'),
    ('Grafschafter', 'Balance Brot', 'https://images.openfoodfacts.org/images/products/405/648/912/3972/front_de.68.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489123972', 'front_4056489123972'),
    ('Goldähren', 'Dinkel-Sandwich', 'https://images.openfoodfacts.org/images/products/406/145/930/1335/front_de.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061459301335', 'front_4061459301335'),
    ('Golden Toast', 'American Sandwich', 'https://images.openfoodfacts.org/images/products/400/924/900/2437/front_de.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 4009249002437', 'front_4009249002437'),
    ('Harry', 'Krustenbrot', 'https://images.openfoodfacts.org/images/products/407/180/000/4372/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800004372', 'front_4071800004372'),
    ('Grafschafter', 'American Style Sandwich Vollkorn', 'https://images.openfoodfacts.org/images/products/405/648/912/4191/front_de.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489124191', 'front_4056489124191'),
    ('Harry', 'Weltmeister Mehrkornbrot', 'https://images.openfoodfacts.org/images/products/407/180/003/4874/front_de.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 4071800034874', 'front_4071800034874'),
    ('Cucina', 'Grissotti - Sesam', 'https://images.openfoodfacts.org/images/products/406/146/101/0935/front_de.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4061461010935', 'front_4061461010935'),
    ('Grafschafter', 'Laugen-Brezeln', 'https://images.openfoodfacts.org/images/products/405/648/942/3867/front_en.72.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489423867', 'front_4056489423867'),
    ('Backländer GmbH', 'Mehrkorn-Schnitten', 'https://images.openfoodfacts.org/images/products/405/648/909/6320/front_de.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489096320', 'front_4056489096320')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'DE' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Bread' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

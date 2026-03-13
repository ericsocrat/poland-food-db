-- PIPELINE (Desserts & Ice Cream): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Desserts & Ice Cream'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'https://images.openfoodfacts.org/images/products/590/240/970/3887/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703887', 'front_5902409703887'),
    ('Piątnica', 'Skyr z mango i marakują', 'https://images.openfoodfacts.org/images/products/590/053/100/4704/front_pl.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004704', 'front_5900531004704'),
    ('Piatnica', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'https://images.openfoodfacts.org/images/products/590/193/910/3402/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103402', 'front_5901939103402'),
    ('OwoLovo', 'OwoLowo Jabłkowo', 'https://images.openfoodfacts.org/images/products/590/195/861/2343/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901958612343', 'front_5901958612343'),
    ('Tutti', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'https://images.openfoodfacts.org/images/products/590/311/194/3240/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903111943240', 'front_5903111943240'),
    ('Jovi', 'Napój jogurtowy Duet Banan-Truskawka', 'https://images.openfoodfacts.org/images/products/590/376/700/7488/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767007488', 'front_5903767007488'),
    ('Piątnica', 'Serek Wiejski Z Malinami I Żurawiną', 'https://images.openfoodfacts.org/images/products/590/053/100/0980/front_en.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531000980', 'front_5900531000980'),
    ('Zott', 'Jogurt jabłko i gruszka', 'https://images.openfoodfacts.org/images/products/590/604/006/3430/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063430', 'front_5906040063430'),
    ('Amelia', 'Waniliowy 3 składniki', 'https://images.openfoodfacts.org/images/products/590/053/101/1146/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011146', 'front_5900531011146'),
    ('Vital Fresh', 'Mus Jabłko Banan Marakuja', 'https://images.openfoodfacts.org/images/products/590/195/861/6365/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901958616365', 'front_5901958616365'),
    ('Fruvita', 'Mixo Jabłko-Gruszka', 'https://images.openfoodfacts.org/images/products/590/376/700/3787/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003787', 'front_5903767003787'),
    ('Łaciaty', 'Łaciaty SEREK WIEJSKI', 'https://images.openfoodfacts.org/images/products/590/082/001/2779/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820012779', 'front_5900820012779'),
    ('Bakoma', 'Maxi Meal o smaku słonego karmelu', 'https://images.openfoodfacts.org/images/products/590/019/703/1809/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197031809', 'front_5900197031809'),
    ('Maluta', 'Maluta Jogurt Bałkański', 'https://images.openfoodfacts.org/images/products/590/446/710/9243/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904467109243', 'front_5904467109243'),
    ('Piątnica', 'Koktajl spożywczy', 'https://images.openfoodfacts.org/images/products/590/193/900/6048/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939006048', 'front_5901939006048'),
    ('Bakoma', 'Jogurt naturalny gęsty', 'https://images.openfoodfacts.org/images/products/590/019/702/8298/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197028298', 'front_5900197028298'),
    ('Bakoma', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'https://images.openfoodfacts.org/images/products/590/019/700/2595/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197002595', 'front_5900197002595'),
    ('Fantasia', 'Fantasia z płatkami w czekoladzie', 'https://images.openfoodfacts.org/images/products/590/064/304/7385/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643047385', 'front_5900643047385'),
    ('Fruvita (Bakoma)', 'Jogurt Wiśniowy', 'https://images.openfoodfacts.org/images/products/590/019/702/7901/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197027901', 'front_5900197027901'),
    ('Piątnica', 'Koktail Białkowy malina & granat', 'https://images.openfoodfacts.org/images/products/590/193/900/6017/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939006017', 'front_5901939006017'),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', 'https://images.openfoodfacts.org/images/products/590/019/702/3842/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197023842', 'front_5900197023842'),
    ('Tutti', 'Serek Tutti Prosty Skład', 'https://images.openfoodfacts.org/images/products/590/240/970/3047/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703047', 'front_5902409703047'),
    ('Ovolove', 'Mus Jabłko Rabarbar', 'https://images.openfoodfacts.org/images/products/590/195/861/4781/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901958614781', 'front_5901958614781'),
    ('Bakoma', 'Bakoma Ave Vege (Czekolada z Wiśniami)', 'https://images.openfoodfacts.org/images/products/590/019/702/8045/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197028045', 'front_5900197028045'),
    ('Fruvita', 'Jogurt wysokobiałkowy low carb waniliowy', 'https://images.openfoodfacts.org/images/products/590/053/100/3370/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531003370', 'front_5900531003370'),
    ('Pilos Pure', 'Jogurt - truskawka, jabłko, banan, owies', 'https://images.openfoodfacts.org/images/products/590/016/853/1000/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900168531000', 'front_5900168531000'),
    ('7zbóż men', 'Jogurt z jagodą, czarną porzeczką i ziarnami zbóż', 'https://images.openfoodfacts.org/images/products/590/019/702/6034/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197026034', 'front_5900197026034'),
    ('Bakoma', '7 zbóż MEN jogurt z brzoskwinią, gruszką i ziarnami zbóż', 'https://images.openfoodfacts.org/images/products/590/019/702/6010/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197026010', 'front_5900197026010'),
    ('Danone', 'Yopro jogurt o smaku banan-krem z orzeszków ziemnych z magnezem i witaminą b9', 'https://images.openfoodfacts.org/images/products/590/064/305/1061/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643051061', 'front_5900643051061'),
    ('Łaciaty', 'Łaciaty jogurt pitny równowaga i regeneracja z magnezem i biotyną', 'https://images.openfoodfacts.org/images/products/590/082/002/7322/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820027322', 'front_5900820027322'),
    ('Jogobella', 'Jogurt wiśniowy', 'https://images.openfoodfacts.org/images/products/590/604/006/3621/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063621', 'front_5906040063621'),
    ('Fruvita', 'Jogurt o smaku pieczonego jabłka', 'https://images.openfoodfacts.org/images/products/590/376/700/3404/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003404', 'front_5903767003404'),
    ('Bakoma', 'Skyr Malina-truskawka Wysoka Zawartość Białka', 'https://images.openfoodfacts.org/images/products/590/019/703/1465/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197031465', 'front_5900197031465'),
    ('Dessella', 'Deser mleczny czekoladowy z bitą śmietana o smaku czekoladowym', 'https://images.openfoodfacts.org/images/products/590/215/059/3706/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902150593706', 'front_5902150593706'),
    ('Piątnica', 'Skyr czekoladowy z wiśnią', 'https://images.openfoodfacts.org/images/products/590/053/100/4827/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004827', 'front_5900531004827'),
    ('Danone', 'Ale pitny malina Borówka', 'https://images.openfoodfacts.org/images/products/590/064/305/0408/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643050408', 'front_5900643050408'),
    ('Rolmlecz', 'Serek poznański naturalny', 'https://images.openfoodfacts.org/images/products/590/163/000/1588/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901630001588', 'front_5901630001588'),
    ('Wieluń', 'Mój Ulubiony', 'https://images.openfoodfacts.org/images/products/590/490/300/0653/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904903000653', 'front_5904903000653'),
    ('Fruvita pure', 'Jogurt + owoce borówka banan', 'https://images.openfoodfacts.org/images/products/590/376/700/1325/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767001325', 'front_5903767001325'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'https://images.openfoodfacts.org/images/products/590/193/910/3068/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103068', 'front_5901939103068'),
    ('Piątnica', 'Skyr Wanilia', 'https://images.openfoodfacts.org/images/products/590/193/910/3075/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103075', 'front_5901939103075'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'https://images.openfoodfacts.org/images/products/590/193/910/3099/front_en.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103099', 'front_5901939103099'),
    ('Piątnica', 'Icelandic type yoghurt natural', 'https://images.openfoodfacts.org/images/products/590/053/100/4735/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004735', 'front_5900531004735'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'https://images.openfoodfacts.org/images/products/590/053/100/4537/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004537', 'front_5900531004537'),
    ('Mlekovita', 'Jogurt Grecki naturalny', 'https://images.openfoodfacts.org/images/products/590/051/235/0080/front_pl.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512350080', 'front_5900512350080'),
    ('Zott', 'Jogurt naturalny', 'https://images.openfoodfacts.org/images/products/590/604/006/3515/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063515', 'front_5906040063515'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 'https://images.openfoodfacts.org/images/products/590/053/101/1023/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011023', 'front_5900531011023'),
    ('Piątnica', 'Skyr Naturalny', 'https://images.openfoodfacts.org/images/products/590/053/100/4544/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004544', 'front_5900531004544'),
    ('Fruvita', 'Jogurt jagodowy', 'https://images.openfoodfacts.org/images/products/590/376/700/3459/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003459', 'front_5903767003459'),
    ('Fruvita', 'Skyr Pitny Wanilia', 'https://images.openfoodfacts.org/images/products/590/376/700/3176/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003176', 'front_5903767003176'),
    ('Pilos', 'Serek Wiejski Lekki', 'https://images.openfoodfacts.org/images/products/590/082/002/2280/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820022280', 'front_5900820022280'),
    ('Président', 'Twarog sernikowy', 'https://images.openfoodfacts.org/images/products/590/827/568/8587/front_pl.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908275688587', 'front_5908275688587'),
    ('Jovi', 'Duet jogurt pitny Truskawka-Kiwi', 'https://images.openfoodfacts.org/images/products/590/376/700/0687/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767000687', 'front_5903767000687'),
    ('Piątnica', 'Serek wiejski z jagodami', 'https://images.openfoodfacts.org/images/products/590/053/100/0973/front_en.52.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531000973', 'front_5900531000973'),
    ('Bakoma', 'Bakoma Ave Vege czekolada', 'https://images.openfoodfacts.org/images/products/590/019/702/4412/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197024412', 'front_5900197024412'),
    ('Vemondo', 'Kokos naturalny', 'https://images.openfoodfacts.org/images/products/590/110/400/5302/front_cs.42.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901104005302', 'front_5901104005302'),
    ('Delikate', 'Serek Wiejski', 'https://images.openfoodfacts.org/images/products/590/051/298/7378/front_en.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512987378', 'front_5900512987378'),
    ('Tutti', 'Serek homogenizowany brzoskwiniowy Tutti', 'https://images.openfoodfacts.org/images/products/590/240/970/3269/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703269', 'front_5902409703269'),
    ('Président', 'Serek waniliowy', 'https://images.openfoodfacts.org/images/products/590/827/568/8891/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908275688891', 'front_5908275688891'),
    ('Piatnica', 'Serek homogenizowany brzoskwiniowy', 'https://images.openfoodfacts.org/images/products/590/053/101/1207/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011207', 'front_5900531011207'),
    ('Bakoma', 'Jogurt Bio naturalny', 'https://images.openfoodfacts.org/images/products/590/019/702/2548/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197022548', 'front_5900197022548'),
    ('Rolmlecz', 'Serek truskawkowy', 'https://images.openfoodfacts.org/images/products/590/163/000/0574/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901630000574', 'front_5901630000574'),
    ('Go Active', 'Serek proteinowy ze skyrem', 'https://images.openfoodfacts.org/images/products/590/240/970/3726/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703726', 'front_5902409703726'),
    ('Łowicz', 'Sernik z brzoskwiniami', 'https://images.openfoodfacts.org/images/products/590/039/775/4003/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397754003', 'front_5900397754003'),
    ('Danone', 'Fantasia ar ķiršiem', 'https://images.openfoodfacts.org/images/products/590/064/304/7347/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643047347', 'front_5900643047347'),
    ('Danone', 'Actimel o smaku wieloowocowym', 'https://images.openfoodfacts.org/images/products/000/005/904/6677/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 59046677', 'front_59046677'),
    ('Activia', 'Activia pitna owoce leśne', 'https://images.openfoodfacts.org/images/products/590/064/304/7101/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643047101', 'front_5900643047101'),
    ('Go Active', 'Protein Jogurt Truskawkowy', 'https://images.openfoodfacts.org/images/products/590/376/700/6528/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767006528', 'front_5903767006528'),
    ('Fruvita', 'Skyr blueberry', 'https://images.openfoodfacts.org/images/products/590/240/970/4174/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409704174', 'front_5902409704174'),
    ('Fruivita', 'Skyr Słony Karmel', 'https://images.openfoodfacts.org/images/products/590/240/970/4150/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409704150', 'front_5902409704150'),
    ('Mlekowita', 'Jogurt Polski truskawka z kawałkami owoców', 'https://images.openfoodfacts.org/images/products/590/051/235/0097/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512350097', 'front_5900512350097'),
    ('Jogobella', 'Jogurt brzoskwiniowy', 'https://images.openfoodfacts.org/images/products/590/604/006/3591/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063591', 'front_5906040063591'),
    ('Bakoma', 'Jogurt Bio z Truskawkami', 'https://images.openfoodfacts.org/images/products/590/019/702/2388/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197022388', 'front_5900197022388'),
    ('Unknown', 'Fruvita z granolą i truskawkami', 'https://images.openfoodfacts.org/images/products/590/240/970/2484/front_fr.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409702484', 'front_5902409702484'),
    ('Fruvita', 'Jogurt Grecki', 'https://images.openfoodfacts.org/images/products/590/051/290/1091/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512901091', 'front_5900512901091'),
    ('Rolmlecz', 'Serek Homo Wanil 200G Rolmlecz', 'https://images.openfoodfacts.org/images/products/590/163/000/0208/front_pl.38.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901630000208', 'front_5901630000208'),
    ('Piątnica', 'Serek homogenizowany stracciatella', 'https://images.openfoodfacts.org/images/products/590/053/101/1047/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011047', 'front_5900531011047'),
    ('Fruvita', 'Jogurt naturalny kremowy', 'https://images.openfoodfacts.org/images/products/590/376/700/6160/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767006160', 'front_5903767006160'),
    ('Piątnica', 'Skyr jogurt pitny Naturalny', 'https://images.openfoodfacts.org/images/products/590/193/910/3105/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103105', 'front_5901939103105'),
    ('Zott Primo', 'Jogurt Naturalny', 'https://images.openfoodfacts.org/images/products/590/604/006/3089/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063089', 'front_5906040063089'),
    ('Piątnica', 'Serek homogenizowany waniliowy', 'https://images.openfoodfacts.org/images/products/590/053/101/1016/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011016', 'front_5900531011016'),
    ('Danone', 'YoPRO (Smak Truskawka Malina)', 'https://images.openfoodfacts.org/images/products/590/064/305/1108/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643051108', 'front_5900643051108'),
    ('Piątnica', 'Skyr - jogurt typu islandzkiego z truskawkami', 'https://images.openfoodfacts.org/images/products/590/053/100/4506/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004506', 'front_5900531004506'),
    ('Piątnica', 'Skyr Joghurt', 'https://images.openfoodfacts.org/images/products/590/053/100/4513/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004513', 'front_5900531004513'),
    ('Activia', 'Jogurt z probiotykami truskawka kiwi', 'https://images.openfoodfacts.org/images/products/590/064/304/7699/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643047699', 'front_5900643047699'),
    ('Piątnica', 'Skyr jogurt pitny', 'https://images.openfoodfacts.org/images/products/590/193/910/3235/front_pl.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103235', 'front_5901939103235'),
    ('Danone', 'Activia', 'https://images.openfoodfacts.org/images/products/590/064/305/0217/front_en.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643050217', 'front_5900643050217'),
    ('YoPRO', 'Jogurt pitny proteinowy o smaku mango', 'https://images.openfoodfacts.org/images/products/590/064/305/2341/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643052341', 'front_5900643052341'),
    ('Fruvita', 'Skyr naturalny', 'https://images.openfoodfacts.org/images/products/590/240/970/4389/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409704389', 'front_5902409704389'),
    ('Piątnica', 'Skyr Wanilia & Stracciatella', 'https://images.openfoodfacts.org/images/products/590/193/910/3334/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103334', 'front_5901939103334'),
    ('Piątnica', 'Jogurt naturalny', 'https://images.openfoodfacts.org/images/products/590/053/100/3738/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531003738', 'front_5900531003738'),
    ('Delikate', 'Serek Wiejski Lekki', 'https://images.openfoodfacts.org/images/products/590/082/002/1931/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820021931', 'front_5900820021931'),
    ('Bakoma', 'Bakoma jogurt naturalny typ grecki', 'https://images.openfoodfacts.org/images/products/590/019/701/2723/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197012723', 'front_5900197012723'),
    ('Tolonis', 'Jogurt typu greckiego', 'https://images.openfoodfacts.org/images/products/590/012/004/4142/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120044142', 'front_5900120044142'),
    ('Pilos', 'Skyr', 'https://images.openfoodfacts.org/images/products/590/053/100/4667/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004667', 'front_5900531004667'),
    ('Piątnica', 'Coconut homogenized cheese', 'https://images.openfoodfacts.org/images/products/590/053/101/1061/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011061', 'front_5900531011061'),
    ('Fruvira', 'Skyr Naturalny Pitny', 'https://images.openfoodfacts.org/images/products/590/376/700/3183/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003183', 'front_5903767003183'),
    ('Unknown', 'Fruvita low carb jogurt o smaku truskawkowym', 'https://images.openfoodfacts.org/images/products/590/053/100/3387/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531003387', 'front_5900531003387'),
    ('Owolovo', 'Brzoskwiniowo', 'https://images.openfoodfacts.org/images/products/590/195/861/2374/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901958612374', 'front_5901958612374')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Desserts & Ice Cream' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

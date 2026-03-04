-- PIPELINE (Dairy): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Dairy'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Mlekpol', 'Mleko łaciate 3.2%', 'https://images.openfoodfacts.org/images/products/590/082/000/0011/front_en.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820000011', 'front_5900820000011'),
    ('Piątnica', 'Twój Smak Serek śmietankowy', 'https://images.openfoodfacts.org/images/products/590/053/100/0508/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531000508', 'front_5900531000508'),
    ('Piątnica', 'Twaróg Wiejski Półtłusty', 'https://images.openfoodfacts.org/images/products/590/053/100/4018/front_en.93.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004018', 'front_5900531004018'),
    ('Fruvita', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'https://images.openfoodfacts.org/images/products/590/240/970/3887/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703887', 'front_5902409703887'),
    ('Piątnica', 'Skyr z mango i marakują', 'https://images.openfoodfacts.org/images/products/590/053/100/4704/front_pl.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004704', 'front_5900531004704'),
    ('Piatnica', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'https://images.openfoodfacts.org/images/products/590/193/910/3402/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103402', 'front_5901939103402'),
    ('Delikate', 'Serek Wiejski Wysokobiałkowy', 'https://images.openfoodfacts.org/images/products/590/249/500/2055/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902495002055', 'front_5902495002055'),
    ('Mleczna Dolina', 'Mleko Świeże 2,0%', 'https://images.openfoodfacts.org/images/products/590/082/000/9854/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820009854', 'front_5900820009854'),
    ('Tolonis', 'Ser sałatkowo-kanapkowy półtłusty', 'https://images.openfoodfacts.org/images/products/590/051/270/0090/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512700090', 'front_5900512700090'),
    ('Piątnica', 'Twaróg wiejski', 'https://images.openfoodfacts.org/images/products/590/053/100/4049/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004049', 'front_5900531004049'),
    ('Almette', 'Serek twarogowy z ziołami', 'https://images.openfoodfacts.org/images/products/590/289/914/3873/front_en.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899143873', 'front_5902899143873'),
    ('Delikate', 'Twaróg Klinek (Chudy)', 'https://images.openfoodfacts.org/images/products/590/082/002/1962/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820021962', 'front_5900820021962'),
    ('Biedronka', 'Kefir naturalny 1,5 % tłuszczu', 'https://images.openfoodfacts.org/images/products/590/012/000/5136/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120005136', 'front_5900120005136'),
    ('Tutti', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'https://images.openfoodfacts.org/images/products/590/311/194/3240/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903111943240', 'front_5903111943240'),
    ('Mlekpol', 'Królewski z Kolna - ser w plastrach', 'https://images.openfoodfacts.org/images/products/590/082/000/5528/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820005528', 'front_5900820005528'),
    ('Euroser', 'Holenderski ser kozi półtwardy ser podpuszczkowy z mleka koziego, w plastrach.', 'https://images.openfoodfacts.org/images/products/590/762/747/1532/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907627471532', 'front_5907627471532'),
    ('Pilos', 'Mleko spożywcze 3,2%', 'https://images.openfoodfacts.org/images/products/590/051/298/8016/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512988016', 'front_5900512988016'),
    ('Piatnica', 'Twaróg Półtłusty', 'https://images.openfoodfacts.org/images/products/590/053/110/5036/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531105036', 'front_5900531105036'),
    ('Delikate', 'Capreggio serek typu włoskiego', 'https://images.openfoodfacts.org/images/products/590/780/928/6084/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907809286084', 'front_5907809286084'),
    ('Wieluń', 'Twarożek &quot;Mój ulubiony&quot;', 'https://images.openfoodfacts.org/images/products/590/490/300/0677/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904903000677', 'front_5904903000677'),
    ('Łaciaty', 'Serek śmietankowy z cebulą i szczypiorkiem', 'https://images.openfoodfacts.org/images/products/590/082/001/1512/front_en.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820011512', 'front_5900820011512'),
    ('Jovi', 'Napój jogurtowy Duet Banan-Truskawka', 'https://images.openfoodfacts.org/images/products/590/376/700/7488/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767007488', 'front_5903767007488'),
    ('Łaciate', 'Łaciate mleko', 'https://images.openfoodfacts.org/images/products/590/082/000/0554/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820000554', 'front_5900820000554'),
    ('Delikate', 'Twaróg klinek chudy', 'https://images.openfoodfacts.org/images/products/590/051/250/1680/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512501680', 'front_5900512501680'),
    ('Delikate', 'Twaróg chudy', 'https://images.openfoodfacts.org/images/products/590/012/007/2251/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120072251', 'front_5900120072251'),
    ('Piątnica', 'Śmietana 18%', 'https://images.openfoodfacts.org/images/products/590/053/100/1130/front_en.30.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531001130', 'front_5900531001130'),
    ('Piątnica', 'Mleko wieskie świeże 2%', 'https://images.openfoodfacts.org/images/products/590/193/900/0770/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939000770', 'front_5901939000770'),
    ('Mlekovita', 'Mleko Polskie SPOŻYWCZE', 'https://images.openfoodfacts.org/images/products/590/051/285/0023/front_pl.36.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512850023', 'front_5900512850023'),
    ('Mlekpol', 'Świeże mleko', 'https://images.openfoodfacts.org/images/products/590/082/001/2229/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820012229', 'front_5900820012229'),
    ('Sierpc', 'Ser królewski', 'https://images.openfoodfacts.org/images/products/590/175/300/0628/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901753000628', 'front_5901753000628'),
    ('Almette', 'Serek Almette z ziołami', 'https://images.openfoodfacts.org/images/products/590/289/910/1651/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899101651', 'front_5902899101651'),
    ('Mlekpol', 'Maślanka Mrągowska', 'https://images.openfoodfacts.org/images/products/590/082/000/1506/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820001506', 'front_5900820001506'),
    ('Gustobello', 'Grana Padano Wiórki', 'https://images.openfoodfacts.org/images/products/590/718/035/2682/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180352682', 'front_5907180352682'),
    ('Zott', 'Primo śmietanka 30%', 'https://images.openfoodfacts.org/images/products/590/604/006/3225/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063225', 'front_5906040063225'),
    ('Piątnica', 'Koktajl spożywczy', 'https://images.openfoodfacts.org/images/products/590/193/900/6048/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939006048', 'front_5901939006048'),
    ('Bakoma', 'Jogurt naturalny gęsty', 'https://images.openfoodfacts.org/images/products/590/019/702/8298/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197028298', 'front_5900197028298'),
    ('Almette', 'Almette śmietankowy bez laktozy', 'https://images.openfoodfacts.org/images/products/590/289/914/3835/front_en.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899143835', 'front_5902899143835'),
    ('Piątnica', 'Twarożek Domowy grani naturalny', 'https://images.openfoodfacts.org/images/products/590/053/100/0300/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531000300', 'front_5900531000300'),
    ('Bakoma', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'https://images.openfoodfacts.org/images/products/590/019/700/2595/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197002595', 'front_5900197002595'),
    ('Fantasia', 'Fantasia z płatkami w czekoladzie', 'https://images.openfoodfacts.org/images/products/590/064/304/7385/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900643047385', 'front_5900643047385'),
    ('Piątnica', 'Śmietanka 30%', 'https://images.openfoodfacts.org/images/products/590/053/100/1079/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531001079', 'front_5900531001079'),
    ('Włoszczowa', 'Ser Włoszczowski typu szwajcarskiego', 'https://images.openfoodfacts.org/images/products/590/100/500/7269/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901005007269', 'front_5901005007269'),
    ('Fruvita (Bakoma)', 'Jogurt Wiśniowy', 'https://images.openfoodfacts.org/images/products/590/019/702/7901/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197027901', 'front_5900197027901'),
    ('Piątnica', 'Koktail Białkowy malina & granat', 'https://images.openfoodfacts.org/images/products/590/193/900/6017/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939006017', 'front_5901939006017'),
    ('Łaciate', 'Łaciate Uht Milk 2.0% Fat 0.5 L', 'https://images.openfoodfacts.org/images/products/590/082/000/0158/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820000158', 'front_5900820000158'),
    ('Bakoma', 'Jogurt kremowy z malinami i granolą', 'https://images.openfoodfacts.org/images/products/590/019/702/3842/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900197023842', 'front_5900197023842'),
    ('Sierpc', 'Ser Królewski Light', 'https://images.openfoodfacts.org/images/products/590/175/300/0642/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901753000642', 'front_5901753000642'),
    ('SM Gostyń', 'Kajmak masa krówkowa gostyńska', 'https://images.openfoodfacts.org/images/products/590/069/103/1329/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900691031329', 'front_5900691031329'),
    ('Delikate', 'Twarożek grani klasyczny', 'https://images.openfoodfacts.org/images/products/590/082/002/1955/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820021955', 'front_5900820021955'),
    ('Tutti', 'Serek Tutti Prosty Skład', 'https://images.openfoodfacts.org/images/products/590/240/970/3047/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902409703047', 'front_5902409703047'),
    ('Hochland', 'Ser kremowy ze śmietanką', 'https://images.openfoodfacts.org/images/products/590/289/914/1701/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899141701', 'front_5902899141701'),
    ('Mlekovita', 'Ser Cheddar wiórki', 'https://images.openfoodfacts.org/images/products/590/051/298/3677/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512983677', 'front_5900512983677'),
    ('Pilos', 'Serek śmietankowy ze szczypiorkiem', 'https://images.openfoodfacts.org/images/products/590/012/007/2879/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120072879', 'front_5900120072879'),
    ('Gostyńskie', 'Mleko zagęszczone słodzone', 'https://images.openfoodfacts.org/images/products/590/069/103/1114/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900691031114', 'front_5900691031114'),
    ('Delikate', 'Serek śmietanowy klasyczny', 'https://images.openfoodfacts.org/images/products/590/053/100/9655/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531009655', 'front_5900531009655'),
    ('Mleczna Dolina', 'Śmietanka UHT', 'https://images.openfoodfacts.org/images/products/590/012/002/2553/front_pl.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120022553', 'front_5900120022553'),
    ('Pilos', 'Serek śmietankowy', 'https://images.openfoodfacts.org/images/products/590/012/007/2817/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120072817', 'front_5900120072817'),
    ('Fruvita', 'Jogurt wysokobiałkowy low carb waniliowy', 'https://images.openfoodfacts.org/images/products/590/053/100/3370/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531003370', 'front_5900531003370'),
    ('Krasnystaw', 'Kefir', 'https://images.openfoodfacts.org/images/products/590/205/700/1748/front_en.57.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902057001748', 'front_5902057001748'),
    ('Piątnica', 'Soured cream 18%', 'https://images.openfoodfacts.org/images/products/590/053/100/1031/front_en.49.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531001031', 'front_5900531001031'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'https://images.openfoodfacts.org/images/products/590/193/910/3068/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103068', 'front_5901939103068'),
    ('Piątnica', 'Skyr Wanilia', 'https://images.openfoodfacts.org/images/products/590/193/910/3075/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103075', 'front_5901939103075'),
    ('Piątnica', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'https://images.openfoodfacts.org/images/products/590/193/910/3099/front_en.60.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901939103099', 'front_5901939103099'),
    ('Piątnica', 'Icelandic type yoghurt natural', 'https://images.openfoodfacts.org/images/products/590/053/100/4735/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004735', 'front_5900531004735'),
    ('Piątnica', 'Skyr jogurt typu islandzkiego waniliowy', 'https://images.openfoodfacts.org/images/products/590/053/100/4537/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004537', 'front_5900531004537'),
    ('Mlekovita', 'Mleko WYPASIONE 3,2%', 'https://images.openfoodfacts.org/images/products/590/051/232/0359/front_en.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512320359', 'front_5900512320359'),
    ('Fruvita', 'Jogurt Naturalny Kremowy', 'https://images.openfoodfacts.org/images/products/590/376/700/2971/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767002971', 'front_5903767002971'),
    ('Mlekovita', 'Jogurt Grecki naturalny', 'https://images.openfoodfacts.org/images/products/590/051/235/0080/front_pl.47.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512350080', 'front_5900512350080'),
    ('Zott', 'Jogurt naturalny', 'https://images.openfoodfacts.org/images/products/590/604/006/3515/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906040063515', 'front_5906040063515'),
    ('Almette', 'Puszysty Serek Jogurtowy', 'https://images.openfoodfacts.org/images/products/590/289/911/7225/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899117225', 'front_5902899117225'),
    ('Piątnica', 'Serek homogenizowany truskawkowy', 'https://images.openfoodfacts.org/images/products/590/053/101/1023/front_en.31.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531011023', 'front_5900531011023'),
    ('Mleczna Dolina', 'Milk Lactose free 3.2% UHT', 'https://images.openfoodfacts.org/images/products/590/012/001/0970/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120010970', 'front_5900120010970'),
    ('Piątnica', 'Skyr Naturalny', 'https://images.openfoodfacts.org/images/products/590/053/100/4544/front_en.39.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900531004544', 'front_5900531004544'),
    ('Robico', 'Kefir Robcio', 'https://images.openfoodfacts.org/images/products/590/831/238/0078/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908312380078', 'front_5908312380078'),
    ('Mleczna Dolina', 'Mleko UHT 3,2%', 'https://images.openfoodfacts.org/images/products/590/051/232/0625/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512320625', 'front_5900512320625'),
    ('Mlekovita', 'Mleko 2%', 'https://images.openfoodfacts.org/images/products/590/051/232/0335/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512320335', 'front_5900512320335'),
    ('Mlekovita', '.', 'https://images.openfoodfacts.org/images/products/590/051/230/0320/front_bg.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512300320', 'front_5900512300320'),
    ('OSM Łowicz', 'Mleko UHT 3,2', 'https://images.openfoodfacts.org/images/products/590/012/001/1199/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120011199', 'front_5900120011199'),
    ('Mleczna Dolina', 'Mleko 1,5% bez laktozy', 'https://images.openfoodfacts.org/images/products/590/012/001/0277/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120010277', 'front_5900120010277'),
    ('Flavita', 'Lactose Free Milk', 'https://images.openfoodfacts.org/images/products/590/051/298/1178/front_en.44.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512981178', 'front_5900512981178'),
    ('Unknown', 'Roslinne Nie Mleko', 'https://images.openfoodfacts.org/images/products/590/000/142/1611/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900001421611', 'front_5900001421611'),
    ('Spółdzielnia Mleczarska Ryki', 'Ser Rycki Edam kl.I', 'https://images.openfoodfacts.org/images/products/590/220/800/0811/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902208000811', 'front_5902208000811'),
    ('Mlekovita', 'Ser Rycerski z dziurami dojrzewajacy', 'https://images.openfoodfacts.org/images/products/590/051/298/4513/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512984513', 'front_5900512984513'),
    ('Światowid', 'Ser topiony tostowy', 'https://images.openfoodfacts.org/images/products/590/471/601/3277/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904716013277', 'front_5904716013277'),
    ('Mlekpol', 'Ser Gouda w plastrach', 'https://images.openfoodfacts.org/images/products/590/082/000/5504/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820005504', 'front_5900820005504'),
    ('Fruvita', 'Jogurt jagodowy', 'https://images.openfoodfacts.org/images/products/590/376/700/3459/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003459', 'front_5903767003459'),
    ('Delikate', 'Delikate Serek Smetankowy', 'https://images.openfoodfacts.org/images/products/590/012/007/2480/front_de.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900120072480', 'front_5900120072480'),
    ('Światowid', 'Gouda', 'https://images.openfoodfacts.org/images/products/590/051/211/0394/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512110394', 'front_5900512110394'),
    ('Fruvita', 'Skyr Pitny Wanilia', 'https://images.openfoodfacts.org/images/products/590/376/700/3176/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903767003176', 'front_5903767003176'),
    ('Go Active', 'Kefir Proteinowy', 'https://images.openfoodfacts.org/images/products/590/205/700/5623/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902057005623', 'front_5902057005623'),
    ('Favita', 'Favita', 'https://images.openfoodfacts.org/images/products/590/051/270/0014/front_en.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900512700014', 'front_5900512700014'),
    ('Almette', 'Almette z chrzanem', 'https://images.openfoodfacts.org/images/products/590/289/910/4652/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902899104652', 'front_5902899104652'),
    ('Pilos', 'Serek Wiejski Lekki', 'https://images.openfoodfacts.org/images/products/590/082/002/2280/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900820022280', 'front_5900820022280'),
    ('Président', 'Twarog sernikowy', 'https://images.openfoodfacts.org/images/products/590/827/568/8587/front_pl.50.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908275688587', 'front_5908275688587'),
    ('Mleczna dolina', 'Śmietana', 'https://images.openfoodfacts.org/images/products/590/718/031/5847/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907180315847', 'front_5907180315847')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Dairy' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

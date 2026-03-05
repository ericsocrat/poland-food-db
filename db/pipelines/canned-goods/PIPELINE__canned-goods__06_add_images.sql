-- PIPELINE (Canned Goods): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Canned Goods'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Nasza Spiżarnia', 'Kukurydza słodka', 'https://images.openfoodfacts.org/images/products/590/171/300/8756/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713008756', 'front_5901713008756'),
    ('Marinero', 'Tuńczyk jednolity w oliwie z oliwek', 'https://images.openfoodfacts.org/images/products/590/389/563/7786/front_en.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895637786', 'front_5903895637786'),
    ('Marineo', 'Filety śledziowe w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/503/9047/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895039047', 'front_5903895039047'),
    ('Marinero', 'Łosoś Kawałki w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/563/1913/front_en.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895631913', 'front_5903895631913'),
    ('Graal', 'Tuńczyk kawałki w oleju roślinnym.', 'https://images.openfoodfacts.org/images/products/590/389/502/0014/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895020014', 'front_5903895020014'),
    ('Mariners', 'Paprykarz szczeciński z łososiem', 'https://images.openfoodfacts.org/images/products/590/389/508/0933/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895080933', 'front_5903895080933'),
    ('Marinero', 'Chili filety śledziowe', 'https://images.openfoodfacts.org/images/products/590/349/603/9354/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903496039354', 'front_5903496039354'),
    ('Nasza Spiżarnia', 'Ogórki konserwowe', 'https://images.openfoodfacts.org/images/products/590/171/300/2181/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713002181', 'front_5901713002181'),
    ('Dawtona', 'Kukurydza słodka', 'https://images.openfoodfacts.org/images/products/590/171/300/1795/front_pl.28.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713001795', 'front_5901713001795'),
    ('Marinero', 'Płaty śledziowe smażone w zalewie octowej', 'https://images.openfoodfacts.org/images/products/590/235/302/0962/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902353020962', 'front_5902353020962'),
    ('Go Active', 'Proteinowa sałatka z łososiem pikantna', 'https://images.openfoodfacts.org/images/products/590/233/533/2694/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902335332694', 'front_5902335332694'),
    ('Graal', 'Sałatka z makrelą pikantna', 'https://images.openfoodfacts.org/images/products/590/389/501/1234/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895011234', 'front_5903895011234'),
    ('Lisner', 'Śledź atlantycki opiekamy', 'https://images.openfoodfacts.org/images/products/590/034/460/0520/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344600520', 'front_5900344600520'),
    ('Carrefour Classic', 'Pomidory całe', 'https://images.openfoodfacts.org/images/products/590/578/433/9283/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784339283', 'front_5905784339283'),
    ('Krakus', 'Ćwikła z chrzanem', 'https://images.openfoodfacts.org/images/products/590/039/773/8508/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397738508', 'front_5900397738508'),
    ('Auchan', 'Kukurydza super słodka', 'https://images.openfoodfacts.org/images/products/590/421/514/1327/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215141327', 'front_5904215141327'),
    ('Nasza spiżarnia', 'Mieszanka owoców w lekkim syropie', 'https://images.openfoodfacts.org/images/products/590/564/305/4999/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905643054999', 'front_5905643054999'),
    ('Provitus', 'Ogórki konserwowe hot chili', 'https://images.openfoodfacts.org/images/products/590/058/000/0726/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900580000726', 'front_5900580000726'),
    ('Mega ryba', 'Śledź w sosie pomidorowym.', 'https://images.openfoodfacts.org/images/products/590/389/508/0025/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895080025', 'front_5903895080025'),
    ('Łosoś Ustka', 'Śledź w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/106/900/1012/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901069001012', 'front_5901069001012'),
    ('Biedronka', 'Ogórki ćwiartki', 'https://images.openfoodfacts.org/images/products/590/090/700/5847/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907005847', 'front_5900907005847'),
    ('Graal', 'Filety że śledzia w oleju', 'https://images.openfoodfacts.org/images/products/590/389/501/0220/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010220', 'front_5903895010220'),
    ('Auchan', 'Kiszone ogórki', 'https://images.openfoodfacts.org/images/products/590/421/513/6378/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215136378', 'front_5904215136378'),
    ('King Oscar', 'Filety z makreli w sosie pomidorowym z papryką.', 'https://images.openfoodfacts.org/images/products/590/148/912/4087/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901489124087', 'front_5901489124087'),
    ('Helcom', 'Tuńczyk kawałki w sosie własnym.', 'https://images.openfoodfacts.org/images/products/590/781/010/2199/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907810102199', 'front_5907810102199'),
    ('EvraFish', 'Śledzie w sosie pomidorowym.', 'https://images.openfoodfacts.org/images/products/590/824/163/6413/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908241636413', 'front_5908241636413'),
    ('Graal', 'Tuńczyk kawałki w bulionie warzywnym.', 'https://images.openfoodfacts.org/images/products/590/389/563/0831/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895630831', 'front_5903895630831'),
    ('Graal S.A.', 'Śledź w oleju po gdańsku', 'https://images.openfoodfacts.org/images/products/590/313/788/7276/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903137887276', 'front_5903137887276'),
    ('Nasza spiżarnia', 'Ogórki kiszone', 'https://images.openfoodfacts.org/images/products/590/419/400/3753/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904194003753', 'front_5904194003753'),
    ('Nasza Spiżarnia', 'Pomidory całe', 'https://images.openfoodfacts.org/images/products/590/171/300/2327/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713002327', 'front_5901713002327'),
    ('Lisner', 'Tuńczyk w sosie własnym', 'https://images.openfoodfacts.org/images/products/590/034/420/1109/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344201109', 'front_5900344201109'),
    ('Graal', 'Tuńczyk kawałki w sosie własnym.', 'https://images.openfoodfacts.org/images/products/590/389/502/0021/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895020021', 'front_5903895020021'),
    ('Amerigo', 'Śledź w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/503/9023/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895039023', 'front_5903895039023'),
    ('Nasza Spiżarnia', 'Mieszanka warzywna z kukuyrdzą', 'https://images.openfoodfacts.org/images/products/590/090/700/5922/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900907005922', 'front_5900907005922'),
    ('Dawtona', 'Pomidory skrojone z ziołami', 'https://images.openfoodfacts.org/images/products/590/171/300/0248/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713000248', 'front_5901713000248'),
    ('Pudliszki', 'Fasolka po Bretońsku', 'https://images.openfoodfacts.org/images/products/590/078/300/4057/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783004057', 'front_5900783004057'),
    ('Lisner', 'Tuńczyk kawałki w oleju roślinnym', 'https://images.openfoodfacts.org/images/products/590/034/420/1406/front_en.24.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344201406', 'front_5900344201406'),
    ('Neptun', 'Tuńczyk W Wodzie', 'https://images.openfoodfacts.org/images/products/590/389/563/9049/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895639049', 'front_5903895639049'),
    ('Pudliszki', 'Pomidore krojone bez skórki w sosie pomidorowym.', 'https://images.openfoodfacts.org/images/products/590/078/300/2152/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783002152', 'front_5900783002152'),
    ('Asia Flavours', 'Jackfruit kawałki', 'https://images.openfoodfacts.org/images/products/590/437/864/5427/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645427', 'front_5904378645427'),
    ('Nasza Spiżarnia', 'Ćwikła z chrzanem', 'https://images.openfoodfacts.org/images/products/590/671/620/5744/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906716205744', 'front_5906716205744'),
    ('Graal', 'Śledź w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/501/0114/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010114', 'front_5903895010114'),
    ('Smak', 'Konserwowe ogóreczki klasyczne', 'https://images.openfoodfacts.org/images/products/590/187/100/2863/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901871002863', 'front_5901871002863'),
    ('MK', 'Szproty wędzone w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/269/318/0234/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902693180234', 'front_5902693180234'),
    ('Helcom Premium', 'Brzoskwinie połówki', 'https://images.openfoodfacts.org/images/products/590/216/674/1351/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902166741351', 'front_5902166741351'),
    ('Kuchnia STAROPOLSKA', 'Bigos z kiełbasą', 'https://images.openfoodfacts.org/images/products/590/389/563/1067/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895631067', 'front_5903895631067'),
    ('Łosoś', 'Paprykarz szczeciński', 'https://images.openfoodfacts.org/images/products/590/106/900/5300/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901069005300', 'front_5901069005300'),
    ('Graal', 'Winter szprot podwędzany w oleju', 'https://images.openfoodfacts.org/images/products/590/389/501/0190/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895010190', 'front_5903895010190'),
    ('Provitus', 'Ogórki konserwowe kozackie', 'https://images.openfoodfacts.org/images/products/590/058/000/1815/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900580001815', 'front_5900580001815'),
    ('Łowicz', 'Pomidory krojone bez skórki', 'https://images.openfoodfacts.org/images/products/590/039/773/5286/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397735286', 'front_5900397735286'),
    ('Ole!', 'Cebulka marynowana złota', 'https://images.openfoodfacts.org/images/products/590/066/400/5869/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900664005869', 'front_5900664005869'),
    ('Łosoś Ustka', 'Śledź po gdańsku w oleju', 'https://images.openfoodfacts.org/images/products/590/106/900/0916/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901069000916', 'front_5901069000916'),
    ('Unknown', 'Brzoskwinie połówki w lekkim syropie', 'https://images.openfoodfacts.org/images/products/590/494/760/9058/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904947609058', 'front_5904947609058'),
    ('Królewska', 'Sardynka w sosie własnym z dodatkiem oleju', 'https://images.openfoodfacts.org/images/products/590/202/085/0250/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902020850250', 'front_5902020850250'),
    ('Lisner', 'Śledź atlantycki w sosie grzybowym', 'https://images.openfoodfacts.org/images/products/590/034/440/3350/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344403350', 'front_5900344403350'),
    ('Jamar', 'Mieszanka warzywna meksykańska', 'https://images.openfoodfacts.org/images/products/590/671/620/1531/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906716201531', 'front_5906716201531'),
    ('Krakus', 'Ogórki Korniszony', 'https://images.openfoodfacts.org/images/products/590/039/773/4586/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900397734586', 'front_5900397734586'),
    ('Kuchnia Polska', 'Ogórki kiszone', 'https://images.openfoodfacts.org/images/products/590/516/200/0033/front_en.25.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905162000033', 'front_5905162000033'),
    ('Magaw', 'Ogórki kiszone', 'https://images.openfoodfacts.org/images/products/590/642/800/0118/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906428000118', 'front_5906428000118'),
    ('Dominik', 'Kapusta kiszona z marchewką', 'https://images.openfoodfacts.org/images/products/590/746/490/6747/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907464906747', 'front_5907464906747'),
    ('Primavika', 'Gołąbki wegetariańskie z kaszą jaglaną', 'https://images.openfoodfacts.org/images/products/590/067/230/2288/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900672302288', 'front_5900672302288'),
    ('Stoczek', 'Fasolka po bretońsku z dodatkiem kiełbasy', 'https://images.openfoodfacts.org/images/products/590/100/200/2991/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901002002991', 'front_5901002002991'),
    ('Dobry wybór', 'Tuńczyk kawałki w zalewie z olejem roślinnym.', 'https://images.openfoodfacts.org/images/products/590/823/594/6894/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908235946894', 'front_5908235946894'),
    ('Super Fish', 'Tuńczyk kawałki w oleju roślinnym', 'https://images.openfoodfacts.org/images/products/590/033/500/8502/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900335008502', 'front_5900335008502'),
    ('Tradycyjny smak', 'Buraczki wiórki', 'https://images.openfoodfacts.org/images/products/590/152/900/3938/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901529003938', 'front_5901529003938'),
    ('Pudliszki', 'Pomidory całe', 'https://images.openfoodfacts.org/images/products/590/078/300/2145/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900783002145', 'front_5900783002145'),
    ('Victus', 'Ogórki Kiszone', 'https://images.openfoodfacts.org/images/products/590/338/607/0948/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903386070948', 'front_5903386070948'),
    ('Kier', 'Szparagi białe', 'https://images.openfoodfacts.org/images/products/590/261/900/1032/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902619001032', 'front_5902619001032'),
    ('Lisner', 'Śledź atlantycki filety a''la Matjas korzenne', 'https://images.openfoodfacts.org/images/products/590/034/401/6260/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344016260', 'front_5900344016260'),
    ('Nasza Spiżarnia', 'Pomidory Krojone', 'https://images.openfoodfacts.org/images/products/590/171/300/2198/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713002198', 'front_5901713002198'),
    ('Dega', 'Fish spread with rice', 'https://images.openfoodfacts.org/images/products/590/196/004/8161/front_en.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901960048161', 'front_5901960048161'),
    ('Dawtona', 'Kukurydza gold', 'https://images.openfoodfacts.org/images/products/590/171/300/1658/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901713001658', 'front_5901713001658'),
    ('Kwidzyn', 'Canned Corn', 'https://images.openfoodfacts.org/images/products/590/158/110/0064/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901581100064', 'front_5901581100064'),
    ('Graal', 'Makrela w sosie pomidorowym', 'https://images.openfoodfacts.org/images/products/590/389/563/0541/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895630541', 'front_5903895630541'),
    ('Auchan', 'Tuńczyk w kawałkach w sosie własnym', 'https://images.openfoodfacts.org/images/products/590/421/516/9321/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215169321', 'front_5904215169321'),
    ('Nasza spiżarnia', 'Brzoskwinie w syropie', 'https://images.openfoodfacts.org/images/products/590/437/864/5649/front_pl.8.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645649', 'front_5904378645649'),
    ('Nasza Spiżarnia', 'Korniszony z chili', 'https://images.openfoodfacts.org/images/products/590/437/864/0064/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378640064', 'front_5904378640064'),
    ('Mega ryba', 'Filety z makreli w sosie pomidorowym.', 'https://images.openfoodfacts.org/images/products/590/389/508/0056/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895080056', 'front_5903895080056'),
    ('Unknown', 'Buraczki zasmażane z cebulą', 'https://images.openfoodfacts.org/images/products/590/671/620/9117/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906716209117', 'front_5906716209117'),
    ('Łosoś ustka', 'Paprykarz szczeciński', 'https://images.openfoodfacts.org/images/products/590/106/900/0336/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901069000336', 'front_5901069000336'),
    ('GustoBello', 'Carciofi', 'https://images.openfoodfacts.org/images/products/590/437/864/5199/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645199', 'front_5904378645199'),
    ('Carrefour', 'Korniszony delitatesowe z przyprawami', 'https://images.openfoodfacts.org/images/products/590/578/434/4737/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784344737', 'front_5905784344737'),
    ('ZPH "Wojna"', 'Marchewka z groszkiem', 'https://images.openfoodfacts.org/images/products/590/152/905/4787/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901529054787', 'front_5901529054787'),
    ('Graal', 'Filety z makreli w sosie pomidorowym z suszonymi pomidorami.', 'https://images.openfoodfacts.org/images/products/590/389/563/5119/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895635119', 'front_5903895635119'),
    ('Łosoś Ustka', 'Tinned Tomato Mackerel', 'https://images.openfoodfacts.org/images/products/590/106/900/0817/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901069000817', 'front_5901069000817'),
    ('Greek Trade', 'Brzoskwinie w syropie', 'https://images.openfoodfacts.org/images/products/590/421/513/2905/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215132905', 'front_5904215132905'),
    ('EvraFish', 'Szprot w oleju roslinnym', 'https://images.openfoodfacts.org/images/products/590/824/163/6246/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908241636246', 'front_5908241636246'),
    ('Provitus', 'Kapusta kwaszona duszona', 'https://images.openfoodfacts.org/images/products/590/058/000/4861/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900580004861', 'front_5900580004861'),
    ('Biedronka', 'Maliny w lekkim syropie', 'https://images.openfoodfacts.org/images/products/590/564/305/4975/front_fr.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905643054975', 'front_5905643054975'),
    ('Farma-świętokrzyska', 'Bio kapusta z grochem', 'https://images.openfoodfacts.org/images/products/590/253/754/0538/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902537540538', 'front_5902537540538'),
    ('Elios', 'Papryczki pikantne nadziewane serem', 'https://images.openfoodfacts.org/images/products/590/437/864/5045/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645045', 'front_5904378645045'),
    ('Nautica', 'Makrélafilé bőrrel paradicsomos szószban', 'https://images.openfoodfacts.org/images/products/000/002/009/6410/front_hu.62.400.jpg', 'off_api', 'front', true, 'Front — EAN 20096410', 'front_20096410'),
    ('Nasza Spiżarnia', 'Korniszony Delikatesowe', 'https://images.openfoodfacts.org/images/products/590/437/864/5588/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904378645588', 'front_5904378645588')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Canned Goods' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

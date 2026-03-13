-- PIPELINE (Pasta & Rice): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-13

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Pasta & Rice'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Lubella', 'Makaron Lubella Pióra nr 17', 'https://images.openfoodfacts.org/images/products/590/004/900/6375/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049006375', 'front_5900049006375'),
    ('Nasze Smaki', 'Kluski śląskie', 'https://images.openfoodfacts.org/images/products/590/139/807/7115/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901398077115', 'front_5901398077115'),
    ('Pastani', 'Makaron pełnoziarnisty świderki', 'https://images.openfoodfacts.org/images/products/590/004/900/5521/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049005521', 'front_5900049005521'),
    ('Pastani', 'Makaron Świderki', 'https://images.openfoodfacts.org/images/products/590/035/403/6906/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354036906', 'front_5900354036906'),
    ('Dobrusia', 'Makaron świderki', 'https://images.openfoodfacts.org/images/products/590/004/900/1714/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049001714', 'front_5900049001714'),
    ('Goliard', 'Makaron szlachecki jajeczny. Wstażki - Gniazda', 'https://images.openfoodfacts.org/images/products/590/025/200/0603/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900252000603', 'front_5900252000603'),
    ('Maxpol', 'Penne rurka skośna', 'https://images.openfoodfacts.org/images/products/590/821/700/1436/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908217001436', 'front_5908217001436'),
    ('Auchan', 'Makaron świderki', 'https://images.openfoodfacts.org/images/products/590/421/511/5540/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215115540', 'front_5904215115540'),
    ('Lubella', 'Świderki', 'https://images.openfoodfacts.org/images/products/590/004/982/3026/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049823026', 'front_5900049823026'),
    ('Pastani', 'Makarom pełnoziarnisty pióra', 'https://images.openfoodfacts.org/images/products/590/307/700/0834/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903077000834', 'front_5903077000834'),
    ('Lubella', 'Nitki Cięte - filini', 'https://images.openfoodfacts.org/images/products/590/004/982/3033/front_pl.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049823033', 'front_5900049823033'),
    ('House Of Asia', 'Makaron ryżowy', 'https://images.openfoodfacts.org/images/products/590/435/855/1793/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904358551793', 'front_5904358551793'),
    ('Pastani', 'Spaghetti Pełnoziarnisty', 'https://images.openfoodfacts.org/images/products/590/035/403/8474/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354038474', 'front_5900354038474'),
    ('Novelle', 'Diabetic makaron świderki', 'https://images.openfoodfacts.org/images/products/590/035/403/9822/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354039822', 'front_5900354039822'),
    ('Lubella', 'Makaron Lubella świderki nr 19', 'https://images.openfoodfacts.org/images/products/590/004/900/3022/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049003022', 'front_5900049003022'),
    ('Lubella', 'Łazanki', 'https://images.openfoodfacts.org/images/products/590/004/982/3040/front_en.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049823040', 'front_5900049823040'),
    ('Makarony premium', 'Makaron pełnoziarnisty', 'https://images.openfoodfacts.org/images/products/590/694/000/3703/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940003703', 'front_5906940003703'),
    ('Taverna fell ancora', 'Ravioli z ricottą i suszonymi pomidorami', 'https://images.openfoodfacts.org/images/products/590/014/301/0346/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900143010346', 'front_5900143010346'),
    ('Unknown', 'Makaron ryżowy', 'https://images.openfoodfacts.org/images/products/590/175/270/0406/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752700406', 'front_5901752700406'),
    ('Czaniecki', 'Makaron 5-jajeczny w kształcie ryżu', 'https://images.openfoodfacts.org/images/products/590/184/100/0097/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901841000097', 'front_5901841000097'),
    ('Vitaliana', 'Ekologiczny makaron pełnoziarnisty świderki', 'https://images.openfoodfacts.org/images/products/590/675/025/1592/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906750251592', 'front_5906750251592'),
    ('Food House', 'Wegańskie spaghetti z sosem bolognese', 'https://images.openfoodfacts.org/images/products/590/188/556/7198/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901885567198', 'front_5901885567198'),
    ('Auchan', 'Makaron pełnoziarnisty świdry z pszenicy durum', 'https://images.openfoodfacts.org/images/products/590/421/515/5652/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215155652', 'front_5904215155652'),
    ('Torebka plastikowa', 'NUDLE ser w ziołach', 'https://images.openfoodfacts.org/images/products/590/539/200/0049/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905392000049', 'front_5905392000049'),
    ('MaxPol', 'Makaron rosołowy', 'https://images.openfoodfacts.org/images/products/590/821/700/1177/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908217001177', 'front_5908217001177'),
    ('TaoTao', 'Makaron ryżowy wstążki', 'https://images.openfoodfacts.org/images/products/590/188/218/8815/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901882188815', 'front_5901882188815'),
    ('Makarony Babuni', 'Makaron fusilli-świderek z kurkumą', 'https://images.openfoodfacts.org/images/products/590/407/240/0537/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904072400537', 'front_5904072400537'),
    ('Sulma', 'Makaron Nadarzyński', 'https://images.openfoodfacts.org/images/products/590/136/700/1172/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901367001172', 'front_5901367001172'),
    ('Sulma', 'Makaron Nadarzyński rurka', 'https://images.openfoodfacts.org/images/products/590/136/700/1240/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901367001240', 'front_5901367001240'),
    ('Bezgluten', 'Makaron z mąka gryczaną - Penne', 'https://images.openfoodfacts.org/images/products/590/672/057/2580/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906720572580', 'front_5906720572580'),
    ('Malma', 'Makaron Malma pióra nr. 14', 'https://images.openfoodfacts.org/images/products/590/004/901/1829/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049011829', 'front_5900049011829'),
    ('Pastani', 'Makaron Cavatappi', 'https://images.openfoodfacts.org/images/products/590/035/403/7934/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354037934', 'front_5900354037934'),
    ('House of Asia', 'Makaron udon pszenny', 'https://images.openfoodfacts.org/images/products/590/289/882/7101/front_pl.21.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902898827101', 'front_5902898827101'),
    ('Pastani', 'Makaron pełnoziarnisty gotowany', 'https://images.openfoodfacts.org/images/products/590/004/981/2730/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049812730', 'front_5900049812730'),
    ('De Care', 'Ramen Noodles', 'https://images.openfoodfacts.org/images/products/590/289/882/7095/front_en.18.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902898827095', 'front_5902898827095'),
    ('Auchan', 'Kluski leniwe', 'https://images.openfoodfacts.org/images/products/590/421/514/9415/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215149415', 'front_5904215149415'),
    ('Makarony Polskie', 'Pastani Penne', 'https://images.openfoodfacts.org/images/products/590/035/403/6920/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354036920', 'front_5900354036920'),
    ('Novelle', 'Makaron z soczewicy czerwonej', 'https://images.openfoodfacts.org/images/products/590/694/000/1945/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940001945', 'front_5906940001945'),
    ('Novelle', 'Makaron z zielonego groszku', 'https://images.openfoodfacts.org/images/products/590/694/000/1969/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940001969', 'front_5906940001969'),
    ('Auchan', 'Makaron spaghetti', 'https://images.openfoodfacts.org/images/products/590/421/512/3729/front_en.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215123729', 'front_5904215123729'),
    ('Sorenti', 'Makaron spaghetti nr 79', 'https://images.openfoodfacts.org/images/products/590/035/403/8221/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900354038221', 'front_5900354038221'),
    ('Jeronimo Martons', 'Makaron szlachecki', 'https://images.openfoodfacts.org/images/products/590/025/200/0467/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900252000467', 'front_5900252000467'),
    ('Makarony Polskie SA', 'Makaron falbanki', 'https://images.openfoodfacts.org/images/products/590/421/511/0064/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215110064', 'front_5904215110064'),
    ('Auchan', 'Makaron jajeczny krajanka', 'https://images.openfoodfacts.org/images/products/590/421/513/3896/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215133896', 'front_5904215133896'),
    ('Makarony Polskie', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/590/694/000/3000/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940003000', 'front_5906940003000'),
    ('Makarony Polskie', 'Swiderki spirals noodle pasta', 'https://images.openfoodfacts.org/images/products/590/694/000/3062/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940003062', 'front_5906940003062'),
    ('Czarniecki', 'Nitka walcowana. 5-jajeczny makaron', 'https://images.openfoodfacts.org/images/products/590/202/057/2022/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902020572022', 'front_5902020572022'),
    ('Lubella', 'Makaron Lasagne', 'https://images.openfoodfacts.org/images/products/590/004/900/1523/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049001523', 'front_5900049001523'),
    ('GustoBello', 'Makaron z semoliny z pszenicy durum z dodatkiem sepii', 'https://images.openfoodfacts.org/images/products/590/754/413/1892/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907544131892', 'front_5907544131892'),
    ('Lubella', 'Jajeczna 5 jaj nitki', 'https://images.openfoodfacts.org/images/products/590/004/981/6585/front_pl.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049816585', 'front_5900049816585'),
    ('Lubella', 'Kokardki Farfalle', 'https://images.openfoodfacts.org/images/products/590/004/900/1516/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049001516', 'front_5900049001516'),
    ('Pastani', 'Makaron muszelki', 'https://images.openfoodfacts.org/images/products/590/307/700/0292/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903077000292', 'front_5903077000292'),
    ('Asia Flavours', 'Massa de arroz integral', 'https://images.openfoodfacts.org/images/products/590/161/993/3602/front_pt.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901619933602', 'front_5901619933602'),
    ('Lubella', 'Kolanka ozdobne', 'https://images.openfoodfacts.org/images/products/590/004/982/3125/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049823125', 'front_5900049823125'),
    ('Lubella', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/590/004/981/8923/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049818923', 'front_5900049818923'),
    ('Lubella', '5-jajeczny makaron', 'https://images.openfoodfacts.org/images/products/590/004/981/6561/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049816561', 'front_5900049816561'),
    ('Makarony Polskie', 'Makaron szlachecki', 'https://images.openfoodfacts.org/images/products/590/307/700/4931/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903077004931', 'front_5903077004931'),
    ('Lubella', 'Makaron spaghetti', 'https://images.openfoodfacts.org/images/products/590/004/900/3107/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049003107', 'front_5900049003107'),
    ('Makarony kopcza', 'Makaron ze szpinakiem', 'https://images.openfoodfacts.org/images/products/590/474/100/1508/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904741001508', 'front_5904741001508'),
    ('Lubella', 'Makaron muszelki nr 26', 'https://images.openfoodfacts.org/images/products/590/004/900/3329/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049003329', 'front_5900049003329'),
    ('House Of Asia', 'Makaron pszenny Mie', 'https://images.openfoodfacts.org/images/products/590/175/270/2820/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752702820', 'front_5901752702820'),
    ('Makarony Polskie', 'Makaron Staropolski', 'https://images.openfoodfacts.org/images/products/590/694/000/7039/front_en.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906940007039', 'front_5906940007039'),
    ('Lubella', 'Gniazda nitki', 'https://images.openfoodfacts.org/images/products/590/004/900/3497/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049003497', 'front_5900049003497'),
    ('Tiradell', 'Makaron świderki', 'https://images.openfoodfacts.org/images/products/000/002/023/4010/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20234010', 'front_20234010'),
    ('Sulma', 'Smaki z ogrodu', 'https://images.openfoodfacts.org/images/products/590/136/700/0311/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901367000311', 'front_5901367000311'),
    ('Mlexer', 'Makaron rurki', 'https://images.openfoodfacts.org/images/products/590/553/050/0158/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905530500158', 'front_5905530500158'),
    ('Asia Flavours', 'Makaron vermicelli', 'https://images.openfoodfacts.org/images/products/590/180/158/1079/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901801581079', 'front_5901801581079'),
    ('Firma Produkcyjno-Handlowa &quot;GZ Kowalczyk&quot;', 'Makaron Szlachecki 5-jajeczny. Krajanka', 'https://images.openfoodfacts.org/images/products/590/496/006/6517/front_pl.5.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904960066517', 'front_5904960066517'),
    ('Asia style', 'Makaron soba', 'https://images.openfoodfacts.org/images/products/590/161/999/0674/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901619990674', 'front_5901619990674'),
    ('Unknown', 'Makaron Ramen', 'https://images.openfoodfacts.org/images/products/590/161/997/3677/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901619973677', 'front_5901619973677'),
    ('Asia Style', 'Makaron Chow Mein', 'https://images.openfoodfacts.org/images/products/590/161/993/9192/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901619939192', 'front_5901619939192'),
    ('Asia Style', 'Makaron wonton', 'https://images.openfoodfacts.org/images/products/590/511/800/2807/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905118002807', 'front_5905118002807'),
    ('Carrefour', 'Fusilli - whole wheat pasta', 'https://images.openfoodfacts.org/images/products/590/578/435/6129/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905784356129', 'front_5905784356129'),
    ('Makłowicz i synowie', 'Makaron z semoliny z pszenicy durum', 'https://images.openfoodfacts.org/images/products/590/564/403/0169/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905644030169', 'front_5905644030169'),
    ('Unifood Smaki Świata', 'Makaron pad thai', 'https://images.openfoodfacts.org/images/products/590/823/506/0743/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908235060743', 'front_5908235060743'),
    ('Lubella', 'Spaghetti express', 'https://images.openfoodfacts.org/images/products/590/004/982/3064/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049823064', 'front_5900049823064'),
    ('As-Babuni', 'Makaron Lasagne', 'https://images.openfoodfacts.org/images/products/590/529/900/0623/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5905299000623', 'front_5905299000623'),
    ('Carrefour', 'Espirales cocción rápida', 'https://images.openfoodfacts.org/images/products/356/007/101/5152/front_es.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 3560071015152', 'front_3560071015152'),
    ('Unknown', 'Pastani Makaron', 'https://images.openfoodfacts.org/images/products/590/307/700/0841/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903077000841', 'front_5903077000841'),
    ('Hipp', 'Spaghetti z pomidorami i mozzarellą', 'https://images.openfoodfacts.org/images/products/906/230/013/0833/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 9062300130833', 'front_9062300130833'),
    ('Lubella', 'Wholegrain Pasta', 'https://images.openfoodfacts.org/images/products/590/004/901/1546/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900049011546', 'front_5900049011546'),
    ('NiroBio', 'Bio Makaron Orkiszowy spirelli', 'https://images.openfoodfacts.org/images/products/590/825/995/4028/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908259954028', 'front_5908259954028'),
    ('Rana', 'Tortellini z ricottą i szpinakiem', 'https://images.openfoodfacts.org/images/products/800/166/572/5941/front_pl.11.400.jpg', 'off_api', 'front', true, 'Front — EAN 8001665725941', 'front_8001665725941'),
    ('Vitasia', 'Linguine z matchą', 'https://images.openfoodfacts.org/images/products/405/648/988/1445/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489881445', 'front_4056489881445'),
    ('Barilla', 'Pâtes spaghetti n°5 1kg', 'https://images.openfoodfacts.org/images/products/807/680/010/5056/front_fr.1292.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076800105056', 'front_8076800105056'),
    ('Barilla', 'Penne Rigate N°73', 'https://images.openfoodfacts.org/images/products/807/680/208/5738/front_en.3506.400.jpg', 'off_api', 'front', true, 'Front — EAN 8076802085738', 'front_8076802085738'),
    ('Tiradell', 'Makaron 5-jajeczny, krajanka', 'https://images.openfoodfacts.org/images/products/000/002/063/9792/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20639792', 'front_20639792'),
    ('Chef select', 'Tortellini viande', 'https://images.openfoodfacts.org/images/products/000/002/035/1939/front_en.302.400.jpg', 'off_api', 'front', true, 'Front — EAN 20351939', 'front_20351939'),
    ('Combino', 'Makaron Wstążka Przepiórcza', 'https://images.openfoodfacts.org/images/products/405/648/918/5550/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 4056489185550', 'front_4056489185550'),
    ('Tiradell', 'Makaron gryczany rurki', 'https://images.openfoodfacts.org/images/products/000/002/098/1129/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 20981129', 'front_20981129'),
    ('Combino', 'Sardinen in Sonnenblumenöl mit Chili', 'https://images.openfoodfacts.org/images/products/000/002/014/3084/front_en.76.400.jpg', 'off_api', 'front', true, 'Front — EAN 20143084', 'front_20143084'),
    ('Podravka', 'Makaron z pszenicy twardej durum', 'https://images.openfoodfacts.org/images/products/385/602/022/3083/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 3856020223083', 'front_3856020223083'),
    ('Melissa', 'Pasta Kids', 'https://images.openfoodfacts.org/images/products/520/119/320/4021/front_en.32.400.jpg', 'off_api', 'front', true, 'Front — EAN 5201193204021', 'front_5201193204021'),
    ('Combino', 'Spaghetti', 'https://images.openfoodfacts.org/images/products/000/002/006/3757/front_hr.67.400.jpg', 'off_api', 'front', true, 'Front — EAN 20063757', 'front_20063757')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Pasta & Rice' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

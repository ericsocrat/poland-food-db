-- PIPELINE (Meat): add product images
-- Source: Open Food Facts API image URLs
-- Generated: 2026-03-04

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = 'PL' AND p.category = 'Meat'
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
    ('Krakus', 'Parówki z piersi kurczaka', 'https://images.openfoodfacts.org/images/products/590/056/701/9727/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567019727', 'front_5900567019727'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 'https://images.openfoodfacts.org/images/products/590/823/052/6602/front_en.12.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908230526602', 'front_5908230526602'),
    ('Kraina Wędlin', 'Szynka Zawędzana', 'https://images.openfoodfacts.org/images/products/590/056/246/0111/front_pl.17.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562460111', 'front_5900562460111'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 'https://images.openfoodfacts.org/images/products/590/019/600/4026/front_pl.23.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900196004026', 'front_5900196004026'),
    ('Biedra', 'Polędwica Wiejska Sadecka', 'https://images.openfoodfacts.org/images/products/590/619/037/2697/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906190372697', 'front_5906190372697'),
    ('Kraina Wędlin', 'Parówki z szynki', 'https://images.openfoodfacts.org/images/products/590/056/221/8439/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562218439', 'front_5900562218439'),
    ('Morliny', 'Szynka konserwowa z galaretką', 'https://images.openfoodfacts.org/images/products/590/024/402/5621/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244025621', 'front_5900244025621'),
    ('Kraina Wedlin', 'Polędwica drobiowa', 'https://images.openfoodfacts.org/images/products/590/033/160/2155/front_pl.27.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900331602155', 'front_5900331602155'),
    ('Kraina Wędlin', 'Szynka Wędzona', 'https://images.openfoodfacts.org/images/products/590/056/243/5614/front_en.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562435614', 'front_5900562435614'),
    ('Kraina Wędlin', 'Salami ostródzkie', 'https://images.openfoodfacts.org/images/products/590/056/701/0823/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567010823', 'front_5900567010823'),
    ('Kraina Wędlin', 'Kiełbasa żywiecka z szynki', 'https://images.openfoodfacts.org/images/products/590/056/701/8706/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567018706', 'front_5900567018706'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 'https://images.openfoodfacts.org/images/products/590/822/681/4874/front_pl.9.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908226814874', 'front_5908226814874'),
    ('Lisner', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'https://images.openfoodfacts.org/images/products/590/034/400/1761/front_pl.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900344001761', 'front_5900344001761'),
    ('Kraina Mięs', 'Mięso mielone z łopatki wieprzowej i wołowiny', 'https://images.openfoodfacts.org/images/products/590/328/220/2719/front_pl.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903282202719', 'front_5903282202719'),
    ('Masarnia Strzała', 'Kiełbasa ze wsi', 'https://images.openfoodfacts.org/images/products/590/311/191/6336/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903111916336', 'front_5903111916336'),
    ('Kraina Mięs', 'Indyk w sosie maślano-koperkowym', 'https://images.openfoodfacts.org/images/products/590/280/818/1750/front_en.16.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902808181750', 'front_5902808181750'),
    ('Auchan', 'Boczek surowy wędzony', 'https://images.openfoodfacts.org/images/products/590/421/515/1678/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215151678', 'front_5904215151678'),
    ('Auchan', 'Boczek dojrzewający wędzony', 'https://images.openfoodfacts.org/images/products/590/421/515/1647/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215151647', 'front_5904215151647'),
    ('Yeemy', 'Chicken wings / skrzydełka panierowane', 'https://images.openfoodfacts.org/images/products/590/075/706/7859/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900757067859', 'front_5900757067859'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 'https://images.openfoodfacts.org/images/products/590/024/401/0030/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244010030', 'front_5900244010030'),
    ('Kraina Wędlin', 'Kiełbasa Żywiecka z indyka', 'https://images.openfoodfacts.org/images/products/590/056/701/2001/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567012001', 'front_5900567012001'),
    ('Dania Express', 'Polędwiczki z kurczaka panierowane', 'https://images.openfoodfacts.org/images/products/590/075/706/2090/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900757062090', 'front_5900757062090'),
    ('Stoczek', 'Kiełbasa z weka', 'https://images.openfoodfacts.org/images/products/590/100/200/6524/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901002006524', 'front_5901002006524'),
    ('Nasze Smaki', 'Mięsiwo w sosie własnym', 'https://images.openfoodfacts.org/images/products/590/750/101/9911/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501019911', 'front_5907501019911'),
    ('Goodvalley', 'Wędzony Schab 100% polskiego mięsa', 'https://images.openfoodfacts.org/images/products/590/822/681/5017/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908226815017', 'front_5908226815017'),
    ('Biedronka', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'https://images.openfoodfacts.org/images/products/590/187/490/5079/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901874905079', 'front_5901874905079'),
    ('Drosed', 'Pasztet Belgijski z dodatkiem wątróbki z kurcząt', 'https://images.openfoodfacts.org/images/products/590/120/400/4151/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901204004151', 'front_5901204004151'),
    ('Olewnik', 'Żywiecka kiełbasa sucha z szynki.', 'https://images.openfoodfacts.org/images/products/590/624/577/9693/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906245779693', 'front_5906245779693'),
    ('Kraina Mięs', 'Tatar wołowy', 'https://images.openfoodfacts.org/images/products/590/056/250/9209/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562509209', 'front_5900562509209'),
    ('Kraina Wędlin', 'Kiełbaski białe z szynki', 'https://images.openfoodfacts.org/images/products/590/056/247/2312/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562472312', 'front_5900562472312'),
    ('Sokołów', 'Metka łososiowa', 'https://images.openfoodfacts.org/images/products/590/056/246/9701/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562469701', 'front_5900562469701'),
    ('Provincja', 'Pasztet z dzika z wątróbką drobiową', 'https://images.openfoodfacts.org/images/products/590/769/369/8086/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907693698086', 'front_5907693698086'),
    ('Könecke', 'Salami z papryką', 'https://images.openfoodfacts.org/images/products/590/427/790/2164/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904277902164', 'front_5904277902164'),
    ('Masarnia Strzała', 'Wołowina w sosie własnym', 'https://images.openfoodfacts.org/images/products/590/311/191/6411/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903111916411', 'front_5903111916411'),
    ('Animex Foods', 'Kiełbasa żywiecka z szynki.', 'https://images.openfoodfacts.org/images/products/590/050/501/8706/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900505018706', 'front_5900505018706'),
    ('Auchan', 'Kiełbasa żywiecka', 'https://images.openfoodfacts.org/images/products/590/421/512/8427/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5904215128427', 'front_5904215128427'),
    ('Smaczne Wędliny', 'Polędwica Drobiowa', 'https://images.openfoodfacts.org/images/products/590/056/248/3813/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562483813', 'front_5900562483813'),
    ('Konspol', 'Polędwiczki panierowane z kurczaka', 'https://images.openfoodfacts.org/images/products/590/750/431/1852/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907504311852', 'front_5907504311852'),
    ('Biedronka', 'Pasztet z królikiem', 'https://images.openfoodfacts.org/images/products/590/056/220/4531/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562204531', 'front_5900562204531'),
    ('Delikatesowy', 'Pasztet z papryką', 'https://images.openfoodfacts.org/images/products/590/676/400/4498/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906764004498', 'front_5906764004498'),
    ('Sokołów', 'Parówki wieprzowe', 'https://images.openfoodfacts.org/images/products/590/671/280/7331/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906712807331', 'front_5906712807331'),
    ('Kraina Mięs', 'Mięso mielone z karkówki', 'https://images.openfoodfacts.org/images/products/590/268/617/0716/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902686170716', 'front_5902686170716'),
    ('Yeemy', 'Pikantne skrzydełka panierowane z kurczaka', 'https://images.openfoodfacts.org/images/products/590/075/706/0768/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900757060768', 'front_5900757060768'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 'https://images.openfoodfacts.org/images/products/590/624/578/0330/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906245780330', 'front_5906245780330'),
    ('Morliny', 'Boczek wędzony', 'https://images.openfoodfacts.org/images/products/590/265/989/6735/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902659896735', 'front_5902659896735'),
    ('Kraina Wędlin', 'Boczek wędzony surowy', 'https://images.openfoodfacts.org/images/products/590/056/236/8318/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562368318', 'front_5900562368318'),
    ('Sokołów', 'Tatar wołowy', 'https://images.openfoodfacts.org/images/products/590/056/254/5900/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562545900', 'front_5900562545900'),
    ('Sokołów', 'Boczek surowy wędzony', 'https://images.openfoodfacts.org/images/products/590/056/236/2316/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562362316', 'front_5900562362316'),
    ('Kraina Mięs', 'Mięso Mielone Z Kurczaka Świeże', 'https://images.openfoodfacts.org/images/products/590/037/809/1608/front_pl.7.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900378091608', 'front_5900378091608'),
    ('Dolina Dobra', 'Śląska kiełbasa', 'https://images.openfoodfacts.org/images/products/590/822/681/5697/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908226815697', 'front_5908226815697'),
    ('Szubryt', 'Gulasz Wołowy', 'https://images.openfoodfacts.org/images/products/590/619/037/5674/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906190375674', 'front_5906190375674'),
    ('Marlej Sp. z o.o.', 'Pierś z kurczaka', 'https://images.openfoodfacts.org/images/products/590/659/860/3195/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906598603195', 'front_5906598603195'),
    ('Sokołów', 'Salami z cebulą', 'https://images.openfoodfacts.org/images/products/590/231/001/5147/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902310015147', 'front_5902310015147'),
    ('Drobimex', 'Pierś pieczona z pomidorami i ziołami', 'https://images.openfoodfacts.org/images/products/590/019/600/7133/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900196007133', 'front_5900196007133'),
    ('Unknown', 'Danie express Panierowane skrzydełka z kurczaka', 'https://images.openfoodfacts.org/images/products/590/075/706/3134/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900757063134', 'front_5900757063134'),
    ('Sokołów', 'Stówki z mięsa z piersi kurczaka', 'https://images.openfoodfacts.org/images/products/590/056/226/8830/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562268830', 'front_5900562268830'),
    ('Drobimex', 'Polędwica z kurcząt', 'https://images.openfoodfacts.org/images/products/590/019/600/4040/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900196004040', 'front_5900196004040'),
    ('Graal', 'Kiełbasa biała', 'https://images.openfoodfacts.org/images/products/590/389/562/9569/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5903895629569', 'front_5903895629569'),
    ('Sokołów', 'Boczek surowy wędzony w kostce', 'https://images.openfoodfacts.org/images/products/590/056/247/1216/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562471216', 'front_5900562471216'),
    ('Goodvalley', 'Winerki 100% mięsa', 'https://images.openfoodfacts.org/images/products/590/822/681/3495/front_pl.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908226813495', 'front_5908226813495'),
    ('Dolina Dobra', 'Kiełbaski 100% mięsa', 'https://images.openfoodfacts.org/images/products/590/822/681/4898/front_pl.13.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908226814898', 'front_5908226814898'),
    ('Pamapol', 'Kiełbasa lekko czosnkowa', 'https://images.openfoodfacts.org/images/products/590/750/101/3292/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907501013292', 'front_5907501013292'),
    ('Sokołów', 'Salceson Hetmański', 'https://images.openfoodfacts.org/images/products/590/056/246/8711/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562468711', 'front_5900562468711'),
    ('Indykpol', 'Parówki z gęsiną', 'https://images.openfoodfacts.org/images/products/590/186/901/3987/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901869013987', 'front_5901869013987'),
    ('Krakus', 'Kiełbasa myśliwska', 'https://images.openfoodfacts.org/images/products/590/216/064/2654/front_pl.10.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902160642654', 'front_5902160642654'),
    ('Smak Mak', 'Wołowinka w galaretce', 'https://images.openfoodfacts.org/images/products/590/048/834/0429/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900488340429', 'front_5900488340429'),
    ('Duda', 'Gulasz z jelenia w sosie myśliwskim', 'https://images.openfoodfacts.org/images/products/590/033/118/1049/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900331181049', 'front_5900331181049'),
    ('Cedrob', 'Ćwiartka z kurczaka w marynacie z łagodnej papryki', 'https://images.openfoodfacts.org/images/products/590/033/160/4517/front_pl.6.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900331604517', 'front_5900331604517'),
    ('K-Stoisko Mięsne', 'Burger wołowy', 'https://images.openfoodfacts.org/images/products/590/752/406/1843/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5907524061843', 'front_5907524061843'),
    ('Sokołów', 'Szynka Biała', 'https://images.openfoodfacts.org/images/products/590/056/290/2994/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562902994', 'front_5900562902994'),
    ('Morliny', 'Pork Loin Morliński', 'https://images.openfoodfacts.org/images/products/590/265/989/9583/front_en.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902659899583', 'front_5902659899583'),
    ('Sokołów', 'Sokoliki drobiowo-cielece', 'https://images.openfoodfacts.org/images/products/590/671/280/8277/front_en.59.400.jpg', 'off_api', 'front', true, 'Front — EAN 5906712808277', 'front_5906712808277'),
    ('Morliny', 'Berlinki classic', 'https://images.openfoodfacts.org/images/products/590/056/700/9681/front_en.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567009681', 'front_5900567009681'),
    ('Krakus', 'Szynka eksportowa', 'https://images.openfoodfacts.org/images/products/590/056/701/5613/front_en.20.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567015613', 'front_5900567015613'),
    ('Profi', 'Pasztet z pomidorami', 'https://images.openfoodfacts.org/images/products/590/169/600/0051/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696000051', 'front_5901696000051'),
    ('Tarczyński', 'Kabanosy wieprzowe', 'https://images.openfoodfacts.org/images/products/590/823/052/1485/front_en.35.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908230521485', 'front_5908230521485'),
    ('Profi', 'Chicken Pâté', 'https://images.openfoodfacts.org/images/products/590/169/600/0013/front_en.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696000013', 'front_5901696000013'),
    ('Animex Foods', 'Berlinki Kurczak', 'https://images.openfoodfacts.org/images/products/590/166/400/3749/front_en.61.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901664003749', 'front_5901664003749'),
    ('Morliny', 'Boczek', 'https://images.openfoodfacts.org/images/products/590/024/400/1199/front_pl.34.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244001199', 'front_5900244001199'),
    ('Podlaski', 'Pasztet drobiowy', 'https://images.openfoodfacts.org/images/products/590/120/400/0733/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901204000733', 'front_5901204000733'),
    ('Drosed', 'Podlaski pasztet drobiowy', 'https://images.openfoodfacts.org/images/products/590/120/400/0788/front_pl.26.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901204000788', 'front_5901204000788'),
    ('Berlinki', 'Z Serem', 'https://images.openfoodfacts.org/images/products/590/056/700/1517/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900567001517', 'front_5900567001517'),
    ('Profi', 'Wielkopolski Pasztet z drobiem i pieczarkami', 'https://images.openfoodfacts.org/images/products/590/169/600/0068/front_pl.22.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901696000068', 'front_5901696000068'),
    ('Drosed', 'Pasztet drobiowy z pomidorami', 'https://images.openfoodfacts.org/images/products/590/120/400/2553/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901204002553', 'front_5901204002553'),
    ('Animex Foods', 'Mielonka luksusowa', 'https://images.openfoodfacts.org/images/products/590/024/401/0047/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244010047', 'front_5900244010047'),
    ('Tarczyński', 'Krakowska sucha z szynki', 'https://images.openfoodfacts.org/images/products/590/823/053/1521/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5908230531521', 'front_5908230531521'),
    ('Kraina wędlin', 'Mielonka Tyrolska', 'https://images.openfoodfacts.org/images/products/590/056/248/5114/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562485114', 'front_5900562485114'),
    ('Animex Foods', 'Konserwa turystyczna', 'https://images.openfoodfacts.org/images/products/590/216/077/3303/front_pl.19.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902160773303', 'front_5902160773303'),
    ('Sokołów', 'Tatar Premium', 'https://images.openfoodfacts.org/images/products/590/056/254/8000/front_en.3.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562548000', 'front_5900562548000'),
    ('Kraina wędlin', 'Szynka z fileta kurczaka', 'https://images.openfoodfacts.org/images/products/590/265/989/4540/front_pl.4.400.jpg', 'off_api', 'front', true, 'Front — EAN 5902659894540', 'front_5902659894540'),
    ('Sokołów', 'Szynka Basiuni', 'https://images.openfoodfacts.org/images/products/590/056/210/1793/front_pl.29.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900562101793', 'front_5900562101793'),
    ('Animex Foods', 'Golonkowa', 'https://images.openfoodfacts.org/images/products/590/024/401/0023/front_pl.15.400.jpg', 'off_api', 'front', true, 'Front — EAN 5900244010023', 'front_5900244010023'),
    ('Bell', 'Salami Delikatesowe', 'https://images.openfoodfacts.org/images/products/590/175/257/0252/front_en.14.400.jpg', 'off_api', 'front', true, 'Front — EAN 5901752570252', 'front_5901752570252')
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = 'PL' AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = 'Meat' AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;

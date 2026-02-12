-- PIPELINE (Meat): source provenance
-- Generated: 2026-02-11

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
    ('Sokołów', 'Sokoliki parówki drobiowo-cielęce', 'https://world.openfoodfacts.org/product/5906712808277', '5906712808277'),
    ('Tarczyński', 'Naturalne Parówki 100% z szynki', 'https://world.openfoodfacts.org/product/5908230526602', '5908230526602'),
    ('Kraina Wędlin', 'Parówki z szynki', 'https://world.openfoodfacts.org/product/5900562218439', '5900562218439'),
    ('Dolina Dobra', 'Soczysta Szynka 100% Mięsa', 'https://world.openfoodfacts.org/product/5908226814874', '5908226814874'),
    ('Morliny', 'Szynka konserwowa z galaretką', 'https://world.openfoodfacts.org/product/5900244025621', '5900244025621'),
    ('Drobimex', 'Szynka delikatesowa z kurcząt', 'https://world.openfoodfacts.org/product/5900196004026', '5900196004026'),
    ('Biedra', 'Polędwica Wiejska Sadecka', 'https://world.openfoodfacts.org/product/5906190372697', '5906190372697'),
    ('Krakus', 'Parówki z piersi kurczaka', 'https://world.openfoodfacts.org/product/5900567019727', '5900567019727'),
    ('Krakus', 'Gulasz angielski 95 % mięsa', 'https://world.openfoodfacts.org/product/5900244010030', '5900244010030'),
    ('Kraina Wędlin', 'Szynka Zawędzana', 'https://world.openfoodfacts.org/product/5900562460111', '5900562460111'),
    ('Dania Express', 'Polędwiczki z kurczaka panierowane', 'https://world.openfoodfacts.org/product/5900757062090', '5900757062090'),
    ('Kraina Wedlin', 'Polędwica drobiowa', 'https://world.openfoodfacts.org/product/5900331602155', '5900331602155'),
    ('Kraina Wędlin', 'Kiełbasa Żywiecka z indyka', 'https://world.openfoodfacts.org/product/5900567012001', '5900567012001'),
    ('Kraina Wędlin', 'Szynka Wędzona', 'https://world.openfoodfacts.org/product/5900562435614', '5900562435614'),
    ('Kraina Wędlin', 'Kiełbasa Myśliwska', 'https://world.openfoodfacts.org/product/5906245779020', '5906245779020'),
    ('Lisner', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'https://world.openfoodfacts.org/product/5900344001761', '5900344001761'),
    ('Masarnia Strzała', 'Wołowina w sosie własnym', 'https://world.openfoodfacts.org/product/5903111916411', '5903111916411'),
    ('Goodvalley', 'Wędzony Schab 100% polskiego mięsa', 'https://world.openfoodfacts.org/product/5908226815017', '5908226815017'),
    ('Yeemy', 'Pikantne skrzydełka panierowane z kurczaka', 'https://world.openfoodfacts.org/product/5900757060768', '5900757060768'),
    ('Stoczek', 'Kiełbasa z weka', 'https://world.openfoodfacts.org/product/5901002006524', '5901002006524'),
    ('Olewnik', 'Żywiecka kiełbasa sucha z szynki', 'https://world.openfoodfacts.org/product/5906245779693', '5906245779693'),
    ('Biedronka', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'https://world.openfoodfacts.org/product/5901874905079', '5901874905079'),
    ('Provincja', 'Pasztet z dzika z wątróbką drobiową', 'https://world.openfoodfacts.org/product/5907693698086', '5907693698086'),
    ('Duda', 'Parówki wieprzowe Mediolanki', 'https://world.openfoodfacts.org/product/5900331193400', '5900331193400'),
    ('Kraina Mięs', 'Tatar wołowy', 'https://world.openfoodfacts.org/product/5900562509209', '5900562509209'),
    ('Nasze Smaki', 'Mięsiwo w sosie własnym', 'https://world.openfoodfacts.org/product/5907501019911', '5907501019911'),
    ('Kraina Wędlin', 'Salami ostródzkie', 'https://world.openfoodfacts.org/product/5900567010823', '5900567010823'),
    ('Smaczne Wędliny', 'Schab Wędzony na wiśniowo', 'https://world.openfoodfacts.org/product/5906245780330', '5906245780330'),
    ('Kraina Mięs', 'Mięso Mielone Z Kurczaka Świeże', 'https://world.openfoodfacts.org/product/5900378091608', '5900378091608'),
    ('Morliny', 'Boczek wędzony', 'https://world.openfoodfacts.org/product/5902659896735', '5902659896735'),
    ('Sokołów', 'Salami z cebulą', 'https://world.openfoodfacts.org/product/5902310015147', '5902310015147'),
    ('Kraina Wędlin', 'Boczek wędzony surowy', 'https://world.openfoodfacts.org/product/5900562368318', '5900562368318'),
    ('Sokołów', 'Tatar wołowy', 'https://world.openfoodfacts.org/product/5900562545900', '5900562545900'),
    ('Drobimex', 'Polędwica z kurcząt', 'https://world.openfoodfacts.org/product/5900196004040', '5900196004040'),
    ('Sokołów', 'Stówki z mięsa z piersi kurczaka', 'https://world.openfoodfacts.org/product/5900562268830', '5900562268830'),
    ('Dolina Dobra', 'Kiełbaski 100% mięsa', 'https://world.openfoodfacts.org/product/5908226814898', '5908226814898'),
    ('Morliny', 'Mięsko ze smalczykiem', 'https://world.openfoodfacts.org/product/5900244012843', '5900244012843'),
    ('Drobimex', 'Pierś pieczona z pomidorami i ziołami', 'https://world.openfoodfacts.org/product/5900196007133', '5900196007133'),
    ('Sokołów', 'Boczek surowy wędzony', 'https://world.openfoodfacts.org/product/5900562362316', '5900562362316'),
    ('Morliny', 'Berlinki classic', 'https://world.openfoodfacts.org/product/5900567009681', '5900567009681'),
    ('Tarczyński', 'Kabanosy wieprzowe', 'https://world.openfoodfacts.org/product/5908230521485', '5908230521485'),
    ('Krakus', 'Szynka eksportowa', 'https://world.openfoodfacts.org/product/5900567015613', '5900567015613'),
    ('Drosed', 'Podlaski pasztet drobiowy', 'https://world.openfoodfacts.org/product/5901204000788', '5901204000788'),
    ('Morliny', 'Boczek', 'https://world.openfoodfacts.org/product/5900244001199', '5900244001199'),
    ('Berlinki', 'Z Serem', 'https://world.openfoodfacts.org/product/5900567001517', '5900567001517'),
    ('Podlaski', 'Pasztet drobiowy', 'https://world.openfoodfacts.org/product/5901204000733', '5901204000733'),
    ('Unknown', 'Polędwiczki z kurczaka panierowane łagodna', 'https://world.openfoodfacts.org/product/5907799011031', '5907799011031'),
    ('Animex Foods', 'Berlinki Kurczak', 'https://world.openfoodfacts.org/product/5901664003749', '5901664003749')
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = 'Meat' AND p.is_deprecated IS NOT TRUE;

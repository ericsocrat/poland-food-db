-- PIPELINE (Meat): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Meat'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906712808277', '5908230526602', '5900562218439', '5908226814874', '5900244025621', '5900196004026', '5906190372697', '5900567019727', '5900244010030', '5900562460111', '5900757062090', '5900331602155', '5900567012001', '5900562435614', '5906245779020', '5900344001761', '5903111916411', '5908226815017', '5900757060768', '5903282202719', '5901002006524', '5906245779693', '5901874905079', '5907693698086', '5900331193400', '5900562509209', '5907501019911', '5900567010823', '5906245780330', '5900378091608', '5902659896735', '5902310015147', '5900562368318', '5900562545900', '5900196004040', '5900562268830', '5908226814898', '5900244012843', '5900196007133', '5900562362316', '5900567009681', '5908230521485', '5900567001746', '5900567015613', '5901204000788', '5900244001199', '5900567001517', '5901204000733', '5907799011031', '5901664003749')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Sokoliki parówki drobiowo-cielęce', 'not-applicable', 'Biedronka', 'none', '5906712808277'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Naturalne Parówki 100% z szynki', 'not-applicable', 'Żabka', 'none', '5908230526602'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Parówki z szynki', 'not-applicable', 'Biedronka', 'none', '5900562218439'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Soczysta Szynka 100% Mięsa', 'not-applicable', 'Kaufland', 'none', '5908226814874'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Szynka konserwowa z galaretką', 'not-applicable', 'Biedronka', 'none', '5900244025621'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Szynka delikatesowa z kurcząt', 'not-applicable', 'Biedronka', 'none', '5900196004026'),
  ('PL', 'Biedra', 'Grocery', 'Meat', 'Polędwica Wiejska Sadecka', 'not-applicable', 'Biedronka', 'none', '5906190372697'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Parówki z piersi kurczaka', 'not-applicable', 'Żabka', 'none', '5900567019727'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Gulasz angielski 95 % mięsa', 'not-applicable', 'Biedronka', 'none', '5900244010030'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Szynka Zawędzana', 'smoked', 'Biedronka', 'none', '5900562460111'),
  ('PL', 'Dania Express', 'Grocery', 'Meat', 'Polędwiczki z kurczaka panierowane', 'not-applicable', 'Biedronka', 'none', '5900757062090'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Polędwica drobiowa', 'not-applicable', 'Biedronka', 'none', '5900331602155'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Kiełbasa Żywiecka z indyka', 'not-applicable', 'Biedronka', 'none', '5900567012001'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Szynka Wędzona', 'smoked', 'Biedronka', 'none', '5900562435614'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Kiełbasa Myśliwska', 'not-applicable', 'Biedronka', 'none', '5906245779020'),
  ('PL', 'Lisner', 'Grocery', 'Meat', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'roasted', 'Dino', 'none', '5900344001761'),
  ('PL', 'Masarnia Strzała', 'Grocery', 'Meat', 'Wołowina w sosie własnym', 'not-applicable', 'Auchan', 'none', '5903111916411'),
  ('PL', 'Goodvalley', 'Grocery', 'Meat', 'Wędzony Schab 100% polskiego mięsa', 'smoked', 'Selgros', 'none', '5908226815017'),
  ('PL', 'Yeemy', 'Grocery', 'Meat', 'Pikantne skrzydełka panierowane z kurczaka', 'not-applicable', 'Biedronka', 'none', '5900757060768'),
  ('PL', 'Stoczek', 'Grocery', 'Meat', 'Kiełbasa z weka', 'not-applicable', 'Auchan', 'none', '5901002006524'),
  ('PL', 'Olewnik', 'Grocery', 'Meat', 'Żywiecka kiełbasa sucha z szynki', 'not-applicable', 'Auchan', 'none', '5906245779693'),
  ('PL', 'Biedronka', 'Grocery', 'Meat', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'not-applicable', 'Biedronka', 'none', '5901874905079'),
  ('PL', 'Provincja', 'Grocery', 'Meat', 'Pasztet z dzika z wątróbką drobiową', 'not-applicable', 'Lewiatan', 'none', '5907693698086'),
  ('PL', 'Duda', 'Grocery', 'Meat', 'Parówki wieprzowe Mediolanki', 'not-applicable', 'Tesco', 'none', '5900331193400'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Tatar wołowy', 'not-applicable', 'Biedronka', 'none', '5900562509209'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Meat', 'Mięsiwo w sosie własnym', 'not-applicable', 'Biedronka', 'none', '5907501019911'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Salami ostródzkie', 'not-applicable', 'Biedronka', 'none', '5900567010823'),
  ('PL', 'Smaczne Wędliny', 'Grocery', 'Meat', 'Schab Wędzony na wiśniowo', 'smoked', null, 'none', '5906245780330'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Mięso Mielone Z Kurczaka Świeże', 'not-applicable', null, 'none', '5900378091608'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Boczek wędzony', 'smoked', null, 'none', '5902659896735'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Salami z cebulą', 'not-applicable', null, 'none', '5902310015147'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Boczek wędzony surowy', 'smoked', null, 'none', '5900562368318'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Tatar wołowy', 'not-applicable', null, 'none', '5900562545900'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Polędwica z kurcząt', 'not-applicable', null, 'none', '5900196004040'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Stówki z mięsa z piersi kurczaka', 'not-applicable', null, 'none', '5900562268830'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Kiełbaski 100% mięsa', 'not-applicable', null, 'none', '5908226814898'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Mięsko ze smalczykiem', 'not-applicable', null, 'none', '5900244012843'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Pierś pieczona z pomidorami i ziołami', 'roasted', null, 'none', '5900196007133'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Boczek surowy wędzony', 'smoked', null, 'none', '5900562362316'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Berlinki classic', 'not-applicable', 'Biedronka', 'none', '5900567009681'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Kabanosy wieprzowe', 'not-applicable', 'Lidl', 'none', '5908230521485'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Szynka eksportowa', 'not-applicable', 'Stokrotka', 'none', '5900567015613'),
  ('PL', 'Drosed', 'Grocery', 'Meat', 'Podlaski pasztet drobiowy', 'not-applicable', 'Auchan', 'none', '5901204000788'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Boczek', 'not-applicable', 'Biedronka', 'none', '5900244001199'),
  ('PL', 'Berlinki', 'Grocery', 'Meat', 'Z Serem', 'not-applicable', 'Auchan', 'none', '5900567001517'),
  ('PL', 'Podlaski', 'Grocery', 'Meat', 'Pasztet drobiowy', 'not-applicable', 'Auchan', 'none', '5901204000733'),
  ('PL', 'Unknown', 'Grocery', 'Meat', 'Polędwiczki z kurczaka panierowane łagodna', 'not-applicable', null, 'none', '5907799011031'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Berlinki Kurczak', 'not-applicable', 'Dino', 'none', '5901664003749')
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = 'PL' and category = 'Meat'
  and is_deprecated is not true
  and product_name not in ('Sokoliki parówki drobiowo-cielęce', 'Naturalne Parówki 100% z szynki', 'Parówki z szynki', 'Soczysta Szynka 100% Mięsa', 'Szynka konserwowa z galaretką', 'Szynka delikatesowa z kurcząt', 'Polędwica Wiejska Sadecka', 'Parówki z piersi kurczaka', 'Gulasz angielski 95 % mięsa', 'Szynka Zawędzana', 'Polędwiczki z kurczaka panierowane', 'Polędwica drobiowa', 'Kiełbasa Żywiecka z indyka', 'Szynka Wędzona', 'Kiełbasa Myśliwska', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'Wołowina w sosie własnym', 'Wędzony Schab 100% polskiego mięsa', 'Pikantne skrzydełka panierowane z kurczaka', 'mięso mielone z łopatki wieprzowej i wołowiny', 'Kiełbasa z weka', 'Żywiecka kiełbasa sucha z szynki', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'Pasztet z dzika z wątróbką drobiową', 'Parówki wieprzowe Mediolanki', 'Tatar wołowy', 'Mięsiwo w sosie własnym', 'Salami ostródzkie', 'Schab Wędzony na wiśniowo', 'Mięso Mielone Z Kurczaka Świeże', 'Boczek wędzony', 'Salami z cebulą', 'Boczek wędzony surowy', 'Tatar wołowy', 'Polędwica z kurcząt', 'Stówki z mięsa z piersi kurczaka', 'Kiełbaski 100% mięsa', 'Mięsko ze smalczykiem', 'Pierś pieczona z pomidorami i ziołami', 'Boczek surowy wędzony', 'Berlinki classic', 'Kabanosy wieprzowe', 'Berlinki Classic', 'Szynka eksportowa', 'Podlaski pasztet drobiowy', 'Boczek', 'Z Serem', 'Pasztet drobiowy', 'Polędwiczki z kurczaka panierowane łagodna', 'Berlinki Kurczak');

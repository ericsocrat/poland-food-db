-- PIPELINE (Meat): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Meat'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900567019727', '5908230526602', '5900562460111', '5900196004026', '5906190372697', '5900562218439', '5900244025621', '5900331602155', '5900562435614', '5900567010823', '5900567018706', '5908226814874', '5900344001761', '5903282202719', '5903111916336', '5902808181750', '5904215151678', '5904215151647', '5900757067859', '5900244010030', '5900567012001', '5900757062090', '5901002006524', '5907501019911', '5908226815017', '5901874905079', '5901204004151', '5906245779693', '5900562509209', '5900562472312', '5900562469701', '5907693698086', '5904277902164', '5903111916411', '5900505018706', '5904215128427', '5900562483813', '5907504311852', '5900562204531', '5906764004498', '5906712807331', '5902686170716', '5900757060768', '5906245780330', '5902659896735', '5900562368318', '5900562545900', '5900562362316', '5900378091608', '5908226815697', '5906190375674', '5906598603195', '5902310015147', '5900196007133', '5900757063134', '5900562268830', '5900196004040', '5903895629569', '5900562471216', '5908226813495', '5908226814898', '5907501013292', '5900562468711', '5901869013987', '5902160642654', '5900488340429', '5900331181049', '5900331604517', '5907524061843', '5900562902994', '5902659899583', '5900244012843', '5906712808277', '5900567009681', '5900567015613', '5901696000051', '5908230521485', '5900567001746', '5901696000013', '5901664003749', '5900244001199', '5901204000733', '5901204000788', '5900567001517', '5901696000068', '5901204002553', '5900244010047', '5908230531521', '5900562485114', '5902160773303', '5900562548000', '5902659894540', '5900562101793', '5900244010023', '5901752570252')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Parówki z piersi kurczaka', 'not-applicable', 'Żabka', 'none', '5900567019727'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Naturalne Parówki 100% z szynki', 'not-applicable', 'Żabka', 'none', '5908230526602'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Szynka Zawędzana', 'smoked', 'Biedronka', 'none', '5900562460111'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Szynka delikatesowa z kurcząt', 'not-applicable', 'Biedronka', 'none', '5900196004026'),
  ('PL', 'Biedra', 'Grocery', 'Meat', 'Polędwica Wiejska Sadecka', 'not-applicable', 'Biedronka', 'none', '5906190372697'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Parówki z szynki', 'not-applicable', 'Biedronka', 'none', '5900562218439'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Szynka konserwowa z galaretką', 'not-applicable', 'Biedronka', 'none', '5900244025621'),
  ('PL', 'Kraina Wedlin', 'Grocery', 'Meat', 'Polędwica drobiowa', 'not-applicable', 'Biedronka', 'none', '5900331602155'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Szynka Wędzona', 'smoked', 'Biedronka', 'none', '5900562435614'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Salami ostródzkie', 'not-applicable', 'Biedronka', 'none', '5900567010823'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Kiełbasa żywiecka z szynki', 'not-applicable', 'Biedronka', 'none', '5900567018706'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Soczysta Szynka 100% Mięsa', 'not-applicable', 'Kaufland', 'none', '5908226814874'),
  ('PL', 'Lisner', 'Grocery', 'Meat', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'roasted', 'Dino', 'none', '5900344001761'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Mięso mielone z łopatki wieprzowej i wołowiny', 'not-applicable', 'Biedronka', 'none', '5903282202719'),
  ('PL', 'Masarnia Strzała', 'Grocery', 'Meat', 'Kiełbasa ze wsi', 'not-applicable', 'Auchan', 'none', '5903111916336'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Indyk w sosie maślano-koperkowym', 'not-applicable', 'Biedronka', 'none', '5902808181750'),
  ('PL', 'Auchan', 'Grocery', 'Meat', 'Boczek surowy wędzony', 'smoked', 'Auchan', 'none', '5904215151678'),
  ('PL', 'Auchan', 'Grocery', 'Meat', 'Boczek dojrzewający wędzony', 'smoked', 'Auchan', 'none', '5904215151647'),
  ('PL', 'Yeemy', 'Grocery', 'Meat', 'Chicken wings / skrzydełka panierowane', 'not-applicable', 'Biedronka', 'none', '5900757067859'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Gulasz angielski 95 % mięsa', 'not-applicable', 'Biedronka', 'none', '5900244010030'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Kiełbasa Żywiecka z indyka', 'not-applicable', 'Biedronka', 'none', '5900567012001'),
  ('PL', 'Dania Express', 'Grocery', 'Meat', 'Polędwiczki z kurczaka panierowane', 'not-applicable', 'Biedronka', 'none', '5900757062090'),
  ('PL', 'Stoczek', 'Grocery', 'Meat', 'Kiełbasa z weka', 'not-applicable', 'Auchan', 'none', '5901002006524'),
  ('PL', 'Nasze Smaki', 'Grocery', 'Meat', 'Mięsiwo w sosie własnym', 'not-applicable', 'Biedronka', 'none', '5907501019911'),
  ('PL', 'Goodvalley', 'Grocery', 'Meat', 'Wędzony Schab 100% polskiego mięsa', 'smoked', 'Selgros', 'none', '5908226815017'),
  ('PL', 'Biedronka', 'Grocery', 'Meat', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'not-applicable', 'Biedronka', 'none', '5901874905079'),
  ('PL', 'Drosed', 'Grocery', 'Meat', 'Pasztet Belgijski z dodatkiem wątróbki z kurcząt', 'not-applicable', 'Auchan', 'none', '5901204004151'),
  ('PL', 'Olewnik', 'Grocery', 'Meat', 'Żywiecka kiełbasa sucha z szynki.', 'not-applicable', 'Auchan', 'none', '5906245779693'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Tatar wołowy', 'not-applicable', 'Biedronka', 'none', '5900562509209'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Kiełbaski białe z szynki', 'not-applicable', 'Biedronka', 'none', '5900562472312'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Metka łososiowa', 'not-applicable', 'Biedronka', 'none', '5900562469701'),
  ('PL', 'Provincja', 'Grocery', 'Meat', 'Pasztet z dzika z wątróbką drobiową', 'not-applicable', 'Lewiatan', 'none', '5907693698086'),
  ('PL', 'Könecke', 'Grocery', 'Meat', 'Salami z papryką', 'not-applicable', 'Auchan', 'none', '5904277902164'),
  ('PL', 'Masarnia Strzała', 'Grocery', 'Meat', 'Wołowina w sosie własnym', 'not-applicable', 'Auchan', 'none', '5903111916411'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Kiełbasa żywiecka z szynki.', 'not-applicable', 'Biedronka', 'none', '5900505018706'),
  ('PL', 'Auchan', 'Grocery', 'Meat', 'Kiełbasa żywiecka', 'not-applicable', 'Auchan', 'none', '5904215128427'),
  ('PL', 'Smaczne Wędliny', 'Grocery', 'Meat', 'Polędwica Drobiowa', 'not-applicable', 'Biedronka', 'none', '5900562483813'),
  ('PL', 'Konspol', 'Grocery', 'Meat', 'Polędwiczki panierowane z kurczaka', 'not-applicable', null, 'none', '5907504311852'),
  ('PL', 'Biedronka', 'Grocery', 'Meat', 'Pasztet z królikiem', 'not-applicable', 'Biedronka', 'none', '5900562204531'),
  ('PL', 'Delikatesowy', 'Grocery', 'Meat', 'Pasztet z papryką', 'not-applicable', 'Biedronka', 'none', '5906764004498'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Parówki wieprzowe', 'not-applicable', 'Netto', 'none', '5906712807331'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Mięso mielone z karkówki', 'not-applicable', 'Biedronka', 'none', '5902686170716'),
  ('PL', 'Yeemy', 'Grocery', 'Meat', 'Pikantne skrzydełka panierowane z kurczaka', 'not-applicable', 'Biedronka', 'none', '5900757060768'),
  ('PL', 'Smaczne Wędliny', 'Grocery', 'Meat', 'Schab Wędzony na wiśniowo', 'smoked', null, 'none', '5906245780330'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Boczek wędzony', 'smoked', null, 'none', '5902659896735'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Boczek wędzony surowy', 'smoked', null, 'none', '5900562368318'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Tatar wołowy', 'not-applicable', null, 'none', '5900562545900'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Boczek surowy wędzony', 'smoked', null, 'none', '5900562362316'),
  ('PL', 'Kraina Mięs', 'Grocery', 'Meat', 'Mięso Mielone Z Kurczaka Świeże', 'not-applicable', null, 'none', '5900378091608'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Śląska kiełbasa', 'not-applicable', null, 'none', '5908226815697'),
  ('PL', 'Szubryt', 'Grocery', 'Meat', 'Gulasz Wołowy', 'not-applicable', null, 'none', '5906190375674'),
  ('PL', 'Marlej Sp. z o.o.', 'Grocery', 'Meat', 'Pierś z kurczaka', 'not-applicable', null, 'none', '5906598603195'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Salami z cebulą', 'not-applicable', null, 'none', '5902310015147'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Pierś pieczona z pomidorami i ziołami', 'roasted', null, 'none', '5900196007133'),
  ('PL', 'Unknown', 'Grocery', 'Meat', 'Danie express Panierowane skrzydełka z kurczaka', 'not-applicable', null, 'none', '5900757063134'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Stówki z mięsa z piersi kurczaka', 'not-applicable', null, 'none', '5900562268830'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Polędwica z kurcząt', 'not-applicable', null, 'none', '5900196004040'),
  ('PL', 'Graal', 'Grocery', 'Meat', 'Kiełbasa biała', 'not-applicable', null, 'none', '5903895629569'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Boczek surowy wędzony w kostce', 'smoked', null, 'none', '5900562471216'),
  ('PL', 'Goodvalley', 'Grocery', 'Meat', 'Winerki 100% mięsa', 'not-applicable', null, 'none', '5908226813495'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Kiełbaski 100% mięsa', 'not-applicable', null, 'none', '5908226814898'),
  ('PL', 'Pamapol', 'Grocery', 'Meat', 'Kiełbasa lekko czosnkowa', 'not-applicable', null, 'none', '5907501013292'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Salceson Hetmański', 'not-applicable', null, 'none', '5900562468711'),
  ('PL', 'Indykpol', 'Grocery', 'Meat', 'Parówki z gęsiną', 'not-applicable', null, 'none', '5901869013987'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Kiełbasa myśliwska', 'not-applicable', null, 'none', '5902160642654'),
  ('PL', 'Smak Mak', 'Grocery', 'Meat', 'Wołowinka w galaretce', 'not-applicable', null, 'none', '5900488340429'),
  ('PL', 'Duda', 'Grocery', 'Meat', 'Gulasz z jelenia w sosie myśliwskim', 'not-applicable', null, 'none', '5900331181049'),
  ('PL', 'Cedrob', 'Grocery', 'Meat', 'Ćwiartka z kurczaka w marynacie z łagodnej papryki', 'not-applicable', null, 'none', '5900331604517'),
  ('PL', 'K-Stoisko Mięsne', 'Grocery', 'Meat', 'Burger wołowy', 'not-applicable', null, 'none', '5907524061843'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Szynka Biała', 'not-applicable', null, 'none', '5900562902994'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Pork Loin Morliński', 'not-applicable', null, 'none', '5902659899583'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Mięsko ze smalczykiem', 'not-applicable', null, 'none', '5900244012843'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Sokoliki drobiowo-cielece', 'not-applicable', 'Biedronka', 'none', '5906712808277'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Berlinki classic', 'not-applicable', 'Biedronka', 'none', '5900567009681'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Szynka eksportowa', 'not-applicable', 'Stokrotka', 'none', '5900567015613'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Pasztet z pomidorami', 'not-applicable', 'Auchan', 'none', '5901696000051'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Kabanosy wieprzowe', 'not-applicable', 'Lidl', 'none', '5908230521485'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Chicken Pâté', 'not-applicable', 'Auchan', 'none', '5901696000013'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Berlinki Kurczak', 'not-applicable', 'Dino', 'none', '5901664003749'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Boczek', 'not-applicable', 'Biedronka', 'none', '5900244001199'),
  ('PL', 'Podlaski', 'Grocery', 'Meat', 'Pasztet drobiowy', 'not-applicable', 'Auchan', 'none', '5901204000733'),
  ('PL', 'Drosed', 'Grocery', 'Meat', 'Podlaski pasztet drobiowy', 'not-applicable', 'Auchan', 'none', '5901204000788'),
  ('PL', 'Berlinki', 'Grocery', 'Meat', 'Z Serem', 'not-applicable', 'Auchan', 'none', '5900567001517'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Wielkopolski Pasztet z drobiem i pieczarkami', 'not-applicable', 'Auchan', 'none', '5901696000068'),
  ('PL', 'Drosed', 'Grocery', 'Meat', 'Pasztet drobiowy z pomidorami', 'not-applicable', 'Auchan', 'none', '5901204002553'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Mielonka luksusowa', 'not-applicable', 'Biedronka', 'none', '5900244010047'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Krakowska sucha z szynki', 'not-applicable', 'Lidl', 'none', '5908230531521'),
  ('PL', 'Kraina wędlin', 'Grocery', 'Meat', 'Mielonka Tyrolska', 'not-applicable', 'Biedronka', 'none', '5900562485114'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Konserwa turystyczna', 'not-applicable', 'Biedronka', 'none', '5902160773303'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Tatar Premium', 'not-applicable', 'Lidl', 'none', '5900562548000'),
  ('PL', 'Kraina wędlin', 'Grocery', 'Meat', 'Szynka z fileta kurczaka', 'not-applicable', 'Biedronka', 'none', '5902659894540'),
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Szynka Basiuni', 'not-applicable', 'Kaufland', 'none', '5900562101793'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Golonkowa', 'not-applicable', 'Tesco', 'none', '5900244010023'),
  ('PL', 'Bell', 'Grocery', 'Meat', 'Salami Delikatesowe', 'not-applicable', 'Auchan', 'none', '5901752570252')
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
  and product_name not in ('Parówki z piersi kurczaka', 'Naturalne Parówki 100% z szynki', 'Szynka Zawędzana', 'Szynka delikatesowa z kurcząt', 'Polędwica Wiejska Sadecka', 'Parówki z szynki', 'Szynka konserwowa z galaretką', 'Polędwica drobiowa', 'Szynka Wędzona', 'Salami ostródzkie', 'Kiełbasa żywiecka z szynki', 'Soczysta Szynka 100% Mięsa', 'Sałatka z pieczonym mięsem z kurczaka, kukurydzą i białą kapustą', 'Mięso mielone z łopatki wieprzowej i wołowiny', 'Kiełbasa ze wsi', 'Indyk w sosie maślano-koperkowym', 'Boczek surowy wędzony', 'Boczek dojrzewający wędzony', 'Chicken wings / skrzydełka panierowane', 'Gulasz angielski 95 % mięsa', 'Kiełbasa Żywiecka z indyka', 'Polędwiczki z kurczaka panierowane', 'Kiełbasa z weka', 'Mięsiwo w sosie własnym', 'Wędzony Schab 100% polskiego mięsa', 'Kiełbasa krakowska - konserwa wieprzowa grubo rozdrobniona, sterylizowana', 'Pasztet Belgijski z dodatkiem wątróbki z kurcząt', 'Żywiecka kiełbasa sucha z szynki.', 'Tatar wołowy', 'Kiełbaski białe z szynki', 'Metka łososiowa', 'Pasztet z dzika z wątróbką drobiową', 'Salami z papryką', 'Wołowina w sosie własnym', 'Kiełbasa żywiecka z szynki.', 'Kiełbasa żywiecka', 'Polędwica Drobiowa', 'Polędwiczki panierowane z kurczaka', 'Pasztet z królikiem', 'Pasztet z papryką', 'Parówki wieprzowe', 'Mięso mielone z karkówki', 'Pikantne skrzydełka panierowane z kurczaka', 'Schab Wędzony na wiśniowo', 'Boczek wędzony', 'Boczek wędzony surowy', 'Tatar wołowy', 'Boczek surowy wędzony', 'Mięso Mielone Z Kurczaka Świeże', 'Śląska kiełbasa', 'Gulasz Wołowy', 'Pierś z kurczaka', 'Salami z cebulą', 'Pierś pieczona z pomidorami i ziołami', 'Danie express Panierowane skrzydełka z kurczaka', 'Stówki z mięsa z piersi kurczaka', 'Polędwica z kurcząt', 'Kiełbasa biała', 'Boczek surowy wędzony w kostce', 'Winerki 100% mięsa', 'Kiełbaski 100% mięsa', 'Kiełbasa lekko czosnkowa', 'Salceson Hetmański', 'Parówki z gęsiną', 'Kiełbasa myśliwska', 'Wołowinka w galaretce', 'Gulasz z jelenia w sosie myśliwskim', 'Ćwiartka z kurczaka w marynacie z łagodnej papryki', 'Burger wołowy', 'Szynka Biała', 'Pork Loin Morliński', 'Mięsko ze smalczykiem', 'Sokoliki drobiowo-cielece', 'Berlinki classic', 'Szynka eksportowa', 'Pasztet z pomidorami', 'Kabanosy wieprzowe', 'Berlinki Classic', 'Chicken Pâté', 'Berlinki Kurczak', 'Boczek', 'Pasztet drobiowy', 'Podlaski pasztet drobiowy', 'Z Serem', 'Wielkopolski Pasztet z drobiem i pieczarkami', 'Pasztet drobiowy z pomidorami', 'Mielonka luksusowa', 'Krakowska sucha z szynki', 'Mielonka Tyrolska', 'Konserwa turystyczna', 'Tatar Premium', 'Szynka z fileta kurczaka', 'Szynka Basiuni', 'Golonkowa', 'Salami Delikatesowe');

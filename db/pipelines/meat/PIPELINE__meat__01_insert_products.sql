-- PIPELINE (Meat): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Meat'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5906712808277', '5908230526602', '5900562218439', '5908226814874', '5900244025621', '5901002006524', '5900196004026', '5906190372697', '5900567019727', '5903111916473', '5900244010030', '5900331193400', '5900562460111', '5906245780330', '5906190371676', '5900567001746', '5908230521485', '5900567009681', '5901664003749', '5901204000733', '5900567015613', '5901204000788', '5901696000013', '5900567001517', '5900244001199', '5901696000068', '5908230515804', '5901696000051')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sokołów', 'Grocery', 'Meat', 'Sokoliki parówki drobiowo-cielęce', null, 'Biedronka', 'none', '5906712808277'),
  ('PL', 'Tarczyński', 'Grocery', 'Meat', 'Naturalne Parówki 100% z szynki', null, 'Stokrotka,Żabka', 'none', '5908230526602'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Parówki z szynki', null, 'Biedronka', 'none', '5900562218439'),
  ('PL', 'Dolina Dobra', 'Grocery', 'Meat', 'Soczysta Szynka 100% Mięsa', null, 'Kaufland', 'none', '5908226814874'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Szynka konserwowa z galaretką', null, 'Biedronka,Aldi', 'none', '5900244025621'),
  ('PL', 'Stoczek', 'Grocery', 'Meat', 'Kiełbasa z weka', null, 'Auchan', 'none', '5901002006524'),
  ('PL', 'Drobimex', 'Grocery', 'Meat', 'Szynka delikatesowa z kurcząt', null, 'Biedronka,Żabka', 'none', '5900196004026'),
  ('PL', 'Biedra', 'Grocery', 'Meat', 'Polędwica Wiejska Sadecka', null, 'Biedronka', 'none', '5906190372697'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Parówki z piersi kurczaka', null, 'Żabka', 'none', '5900567019727'),
  ('PL', 'Strzała', 'Grocery', 'Meat', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', null, 'Biedronka', 'none', '5903111916473'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Gulasz angielski 95 % mięsa', null, 'Biedronka', 'none', '5900244010030'),
  ('PL', 'Duda', 'Grocery', 'Meat', 'Parówki wieprzowe Mediolanki', null, 'Tesco', 'none', '5900331193400'),
  ('PL', 'Kraina Wędlin', 'Grocery', 'Meat', 'Szynka Zawędzana', null, 'Biedronka', 'none', '5900562460111'),
  ('PL', 'Smaczne Wędliny', 'Grocery', 'Meat', 'Schab Wędzony na wiśniowo', null, null, 'none', '5906245780330'),
  ('PL', 'Szubryt', 'Grocery', 'Meat', 'Kiełbasa z czosnkiem', null, null, 'none', '5906190371676'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Berlinki Classic', null, 'Dino', 'none', '5900567001746'),
  ('PL', 'tarczyński', 'Grocery', 'Meat', 'Kabanosy wieprzowe', null, 'Lidl,Biedonka,Żabka', 'none', '5908230521485'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Berlinki classic', null, 'Biedronka', 'none', '5900567009681'),
  ('PL', 'Animex Foods', 'Grocery', 'Meat', 'Berlinki Kurczak', null, 'Dino,Penny', 'none', '5901664003749'),
  ('PL', 'Podlaski', 'Grocery', 'Meat', 'Pasztet drobiowy', null, 'Auchan', 'none', '5901204000733'),
  ('PL', 'Krakus', 'Grocery', 'Meat', 'Szynka eksportowa', null, 'Stokrotka', 'none', '5900567015613'),
  ('PL', 'Drosed', 'Grocery', 'Meat', 'Podlaski pasztet drobiowy', null, 'Auchan,Polnische Spezialitäten by Ewa und & Jarek', 'none', '5901204000788'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Chicken Pâté', null, 'Auchan', 'none', '5901696000013'),
  ('PL', 'Berlinki', 'Grocery', 'Meat', 'Z Serem', null, 'Auchan', 'none', '5900567001517'),
  ('PL', 'Morliny', 'Grocery', 'Meat', 'Boczek', null, 'Biedronka', 'none', '5900244001199'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Wielkopolski Pasztet z drobiem i pieczarkami', null, 'Auchan', 'none', '5901696000068'),
  ('PL', 'Tarczynski', 'Grocery', 'Meat', 'Krakauer Wurst (polnische Brühwurst)', null, 'Kaufland,Picnic,Tegut,Rewe', 'none', '5908230515804'),
  ('PL', 'Profi', 'Grocery', 'Meat', 'Pasztet z pomidorami', null, 'Auchan', 'none', '5901696000051')
on conflict (country, brand, product_name) do update set
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
  and product_name not in ('Sokoliki parówki drobiowo-cielęce', 'Naturalne Parówki 100% z szynki', 'Parówki z szynki', 'Soczysta Szynka 100% Mięsa', 'Szynka konserwowa z galaretką', 'Kiełbasa z weka', 'Szynka delikatesowa z kurcząt', 'Polędwica Wiejska Sadecka', 'Parówki z piersi kurczaka', 'Konserwa mięsna z dziczyzny z dodatkiem mięsa wieprzowego', 'Gulasz angielski 95 % mięsa', 'Parówki wieprzowe Mediolanki', 'Szynka Zawędzana', 'Schab Wędzony na wiśniowo', 'Kiełbasa z czosnkiem', 'Berlinki Classic', 'Kabanosy wieprzowe', 'Berlinki classic', 'Berlinki Kurczak', 'Pasztet drobiowy', 'Szynka eksportowa', 'Podlaski pasztet drobiowy', 'Chicken Pâté', 'Z Serem', 'Boczek', 'Wielkopolski Pasztet z drobiem i pieczarkami', 'Krakauer Wurst (polnische Brühwurst)', 'Pasztet z pomidorami');

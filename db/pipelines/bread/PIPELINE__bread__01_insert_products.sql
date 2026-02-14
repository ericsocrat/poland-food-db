-- PIPELINE (Bread): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Bread'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5905279941427', '5900320001303', '5900864721545', '5906395431007', '5901688800058', '5900585000028', '5904215137917', '5904215134251', '5906395431021', '5900697040172', '5906489239182', '5901688807163', '5904215138587', '5900340012815', '5900340003912', '5906827017830', '5900340009068', '5900864810003', '5902180210505', '5902620000116', '5907029010773', '5905279941120', '5900864727806', '5901486007406', '5900340007347', '5903111184322', '5907377301646', '5902180400500', '5900585000011', '5907577250027', '5905784301631', '5900340003615', '5906395431090', '5900864760346', '5907577250508', '5900320008142', '5900864789828', '5906739703012', '5900864883007', '5907577250461', '5900340011146', '5906598323055', '5901948004431', '5900928032358', '5900340009082', '5901534001745', '5905683298421', '5901549519211', '5900340003424', '5903111184230', '5905784344591', '5903111184261', '5902620000406', '5900340000294', '5905204650424', '5903111184766', '5906286063799', '5906489239373', '5904341989060', '5904276030240')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Gursz', 'Grocery', 'Bread', 'Chleb Pszenno-Żytni', 'baked', 'Biedronka', 'none', '5905279941427'),
  ('PL', 'Lajkonik', 'Grocery', 'Bread', 'Paluszki słone', 'baked', 'Auchan', 'none', '5900320001303'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Bułeczki mleczne z czekoladą', 'baked', 'Lidl', 'none', '5900864721545'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', 'baked', 'Biedronka', 'none', '5906395431007'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Hot dog pszenno-żytni', 'baked', 'Biedronka', 'none', '5901688800058'),
  ('PL', 'Mestemacher', 'Grocery', 'Bread', 'Chleb wielozbożowy żytni pełnoziarnisty', 'baked', 'Auchan', 'none', '5900585000028'),
  ('PL', 'Auchan', 'Grocery', 'Bread', 'Bułki do Hamburgerów', 'baked', 'Auchan', 'none', '5904215137917'),
  ('PL', 'Auchan', 'Grocery', 'Bread', 'Tost pełnoziarnisty', 'baked', 'Auchan', 'none', '5904215134251'),
  ('PL', 'Vital', 'Grocery', 'Bread', 'Bułki śniadaniowe', 'baked', 'Kaufland', 'none', '5906395431021'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Bułka tarta', 'baked', 'Biedronka', 'none', '5900697040172'),
  ('PL', 'Piekarnia Gwóźdź', 'Grocery', 'Bread', 'Chleb z mąką krojony - pieczywo mieszane', 'baked', 'Biedronka', 'none', '5906489239182'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Bułka do hot doga', 'baked', 'Biedronka', 'none', '5901688807163'),
  ('PL', 'Auchan', 'Grocery', 'Bread', 'Tortilla Pszenno-Żytnia', 'baked', 'Auchan', 'none', '5904215138587'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tost pełnoziarnisty', 'baked', null, 'none', '5900340012815'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tost maślany', 'baked', null, 'none', '5900340003912'),
  ('PL', 'Melvit', 'Grocery', 'Bread', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 'baked', null, 'none', '5906827017830'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb żytni', 'baked', null, 'none', '5900340009068'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Mleczne bułeczki', 'baked', null, 'none', '5900864810003'),
  ('PL', 'Sonko', 'Grocery', 'Bread', 'Lekkie żytnie', 'baked', null, 'none', '5902180210505'),
  ('PL', 'Lantmannen Unibake', 'Grocery', 'Bread', 'Bułki pszenne do hot dogów', 'baked', null, 'none', '5902620000116'),
  ('PL', 'Aksam', 'Grocery', 'Bread', 'Beskidzkie paluszki z solą', 'baked', null, 'none', '5907029010773'),
  ('PL', 'Wypieczone ze smakiem', 'Grocery', 'Bread', 'Chleb żytni z ziarnami', 'baked', null, 'none', '5905279941120'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Bułeczki śniadaniowe', 'baked', null, 'none', '5900864727806'),
  ('PL', 'Spółdzielnia piekarsko ciastkarska w Warszawie', 'Grocery', 'Bread', 'Chleb wieloziarnisty złoty łan', 'baked', null, 'none', '5901486007406'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb wieloziarnisty Złoty Łan', 'baked', null, 'none', '5900340007347'),
  ('PL', 'Z Piekarni Regionalnej', 'Grocery', 'Bread', 'Chleb zytni ze słonecznikiem', 'baked', null, 'none', '5903111184322'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Bułki do hamburgerów z sezamem', 'baked', null, 'none', '5907377301646'),
  ('PL', 'Sonko', 'Grocery', 'Bread', 'Lekkie ze słonecznikiem', 'baked', null, 'none', '5902180400500'),
  ('PL', 'Mastemacher', 'Grocery', 'Bread', 'Chleb żytni', 'baked', null, 'none', '5900585000011'),
  ('PL', 'Sendal', 'Grocery', 'Bread', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', 'baked', 'Polska Chata', 'none', '5907577250027'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Chleb tostowy maślany', 'baked', null, 'none', '5905784301631'),
  ('PL', 'Oskroba', 'Grocery', 'Bread', 'Chleb żytni razowy', 'baked', null, 'none', '5900340003615'),
  ('PL', 'Vital', 'Grocery', 'Bread', 'Bułki z ziarnami', 'baked', null, 'none', '5906395431090'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Bułki śniadaniowe', 'baked', null, 'none', '5900864760346'),
  ('PL', 'Sendal', 'Grocery', 'Bread', 'Chleb na maślance', 'baked', 'Polska Chata', 'none', '5907577250508'),
  ('PL', 'Lajkonik', 'Grocery', 'Bread', 'Bajgle z ziołami prowansalskimi', 'baked', null, 'none', '5900320008142'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Tost pełnoziarnisty', 'baked', null, 'none', '5900864789828'),
  ('PL', 'Piekarnia Wilkowo', 'Grocery', 'Bread', 'Chleb pszenno-żytni', 'baked', null, 'none', '5906739703012'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku', 'baked', null, 'none', '5900864883007'),
  ('PL', 'Sendal', 'Grocery', 'Bread', 'Chleb żytni bez drożdzy', 'baked', 'Mila', 'none', '5907577250461'),
  ('PL', 'Piekarnia Oskrobia', 'Grocery', 'Bread', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony', 'baked', null, 'none', '5900340011146'),
  ('PL', 'Mika', 'Grocery', 'Bread', 'Chleb żytni razowy', 'baked', null, 'none', '5906598323055'),
  ('PL', 'Putka', 'Grocery', 'Bread', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', 'baked', null, 'none', '5901948004431'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tortilla', 'baked', 'Biedronka', 'none', '5900928032358'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 'baked', null, 'none', '5900340009082'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Pieczywo kukurydziane chrupkie', 'baked', 'Biedronka', 'none', '5901534001745'),
  ('PL', 'Bite IT', 'Grocery', 'Bread', 'LAWASZ pszenny chleb', 'baked', 'Biedronka', 'none', '5905683298421'),
  ('PL', 'Gwóźdź', 'Grocery', 'Bread', 'Chleb wieloziarnisty', 'baked', 'Biedronka', 'none', '5901549519211'),
  ('PL', 'Oskroba', 'Grocery', 'Bread', 'Tost maślany', 'baked', null, 'none', '5900340003424'),
  ('PL', 'Z Dobrej Piekarni', 'Grocery', 'Bread', 'Chleb baltonowski', 'baked', 'Żabka', 'none', '5903111184230'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Tortilla pszenna', 'baked', 'Auchan', 'none', '5905784344591'),
  ('PL', 'Z Dobrej Piekarni', 'Grocery', 'Bread', 'Chleb wieloziarnisty', 'baked', 'Żabka', 'none', '5903111184261'),
  ('PL', 'Shulstad', 'Grocery', 'Bread', 'Classic Pszenny Hot Dog', 'baked', 'Auchan', 'none', '5902620000406'),
  ('PL', 'Oskroba', 'Grocery', 'Bread', 'Chleb żytni pełnoziarnisty pasteryzowany', 'baked', null, 'none', '5900340000294'),
  ('PL', 'Dakri', 'Grocery', 'Bread', 'Pinsa', 'baked', 'Lidl', 'none', '5905204650424'),
  ('PL', 'Żabka', 'Grocery', 'Bread', 'Kajzerka Kebab', 'baked', 'Żabka', 'none', '5903111184766'),
  ('PL', 'Asprod', 'Grocery', 'Bread', 'Chleb jakubowy żytni razowy', 'baked', null, 'none', '5906286063799'),
  ('PL', 'Biedronka piekarnia gwóźdź', 'Grocery', 'Bread', 'Chleb żytni', 'baked', null, 'none', '5906489239373'),
  ('PL', 'Piekarnia "Pod Rogalem"', 'Grocery', 'Bread', 'Chleb Baltonowski krojony', 'baked', 'Dino', 'none', '5904341989060'),
  ('PL', 'Piekarnia Jesse', 'Grocery', 'Bread', 'Chleb wieloziarnisty ciemny', 'baked', 'Dino', 'none', '5904276030240')
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
where country = 'PL' and category = 'Bread'
  and is_deprecated is not true
  and product_name not in ('Chleb Pszenno-Żytni', 'Paluszki słone', 'Bułeczki mleczne z czekoladą', 'Chleb mieszany pszenno-żytni z dodatkiem naturalnego zakwasu żytniego oraz ziaren, krojony. Złoty łan', 'Hot dog pszenno-żytni', 'Chleb wielozbożowy żytni pełnoziarnisty', 'Bułki do Hamburgerów', 'Tost pełnoziarnisty', 'Bułki śniadaniowe', 'Bułka tarta', 'Chleb z mąką krojony - pieczywo mieszane', 'Bułka do hot doga', 'Tortilla Pszenno-Żytnia', 'Tost pełnoziarnisty', 'Tost maślany', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 'Chleb żytni', 'Mleczne bułeczki', 'Lekkie żytnie', 'Bułki pszenne do hot dogów', 'Beskidzkie paluszki z solą', 'Chleb żytni z ziarnami', 'Bułeczki śniadaniowe', 'Chleb wieloziarnisty złoty łan', 'Chleb wieloziarnisty Złoty Łan', 'Chleb zytni ze słonecznikiem', 'Bułki do hamburgerów z sezamem', 'Lekkie ze słonecznikiem', 'Chleb żytni', 'Chleb firmowy, pieczywo mieszane pszenno-żytnie', 'Chleb tostowy maślany', 'Chleb żytni razowy', 'Bułki z ziarnami', 'Bułki śniadaniowe', 'Chleb na maślance', 'Bajgle z ziołami prowansalskimi', 'Tost pełnoziarnisty', 'Chleb pszenno-żytni', 'Bułeczki pszenne częściowo pieczone - do samodzielnego wypieku', 'Chleb żytni bez drożdzy', 'Chleb-pszenno-żytni z mąką pełnoziarnistą graham oraz dodatkiem zakwasu żytniego, krojony', 'Chleb żytni razowy', 'Tost z mąką pełnoziarnistą (pszenno-żytni)', 'Tortilla', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 'Pieczywo kukurydziane chrupkie', 'LAWASZ pszenny chleb', 'Chleb wieloziarnisty', 'Tost maślany', 'Chleb baltonowski', 'Tortilla pszenna', 'Chleb wieloziarnisty', 'Classic Pszenny Hot Dog', 'Chleb żytni pełnoziarnisty pasteryzowany', 'Pinsa', 'Kajzerka Kebab', 'Chleb jakubowy żytni razowy', 'Chleb żytni', 'Chleb Baltonowski krojony', 'Chleb wieloziarnisty ciemny');

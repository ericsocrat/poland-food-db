-- PIPELINE (Bread): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Bread'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Lajkonik', 'Grocery', 'Bread', 'Paluszki słone', null, 'Auchan', 'none', '5900320001303'),
  ('PL', 'Gursz', 'Grocery', 'Bread', 'Chleb Pszenno-Żytni', null, 'Biedronka', 'none', '5905279941427'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tost pełnoziarnisty', null, null, 'none', '5900340012815'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tost  maślany', null, null, 'none', '5900340003912'),
  ('PL', 'Sonko', 'Grocery', 'Bread', 'Lekkie żytnie', null, null, 'none', '5902180210505'),
  ('PL', 'Aksam', 'Grocery', 'Bread', 'Beskidzkie paluszki z solą', null, null, 'none', '5907029010773'),
  ('PL', 'Melvit', 'Grocery', 'Bread', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', null, null, 'none', '5906827017830'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb żytni', null, null, 'none', '5900340009068'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Tortilla', null, 'Biedronka', 'none', '5900928032358'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', null, null, 'none', '5900340009082'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Pieczywo kukurydziane chrupkie', null, 'Biedronka', 'none', '5901534001745'),
  ('PL', 'Dijo', 'Grocery', 'Bread', 'Fresh Wraps Grill Barbecue x4', null, 'Kaufland', 'none', '5900928007264'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'tosty pszenny', null, null, 'none', '5900340003929'),
  ('PL', 'Sonko', 'Grocery', 'Bread', 'Pieczywo Sonko Lekkie 7 Ziaren', null, null, 'none', '5902180200506'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Chleb Wiejski', null, null, 'none', '5900340001758'),
  ('PL', 'Dan Cake', 'Grocery', 'Bread', 'Toast bread', null, null, 'none', '5900864520117'),
  ('PL', 'Wasa', 'Grocery', 'Bread', 'Pieczywo z pełnoziarnistej mąki żytniej', null, 'Biedronka', 'none', '7300400122054'),
  ('PL', 'Pano', 'Grocery', 'Bread', 'Wraps lo-carb whole wheat tortilla', null, null, 'none', '5900928008902'),
  ('PL', 'Lestello', 'Grocery', 'Bread', 'Chickpea cakes', null, null, 'none', '5902609001400'),
  ('PL', 'TOP', 'Grocery', 'Bread', 'Paluszki solone', null, null, 'none', '5904607000935'),
  ('PL', 'Piekarnia w sercu Lidla', 'Grocery', 'Bread', 'Chleb Tostowy Z Mąką Pełnoziarnistą', null, null, 'none', '20319205'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Petits pains grilles', null, 'Dia,Carrefour,carrefour.fr', 'none', '3270190007425'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'biscottes braisées', null, 'Carrefour,carrefour.fr,Carrefour Market,Carrefour Express,Carrefour City', 'none', '3560070401826'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Biscottes sans sel ajouté', null, 'Carrefour,carrefour.fr', 'none', '5400101201712'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Biscottes Blé complet', null, 'Carrefour,carrefour.fr', 'none', '3560070823291'),
  ('PL', 'Chabrior', 'Grocery', 'Bread', 'Biscottes complètes x36', null, 'Intermarché, INTERMARCHE FRANCE', 'none', '3250391699995'),
  ('PL', 'Italiamo', 'Grocery', 'Bread', 'Piada sfogliata', null, 'LIDL', 'none', '20072483'),
  ('PL', 'Carrefour', 'Grocery', 'Bread', 'Biscuits Nature', null, 'Carrefour,carrefour.fr,Carefour Market', 'none', '3245412589980')
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
where country = 'PL' and category = 'Bread'
  and is_deprecated is not true
  and product_name not in ('Paluszki słone', 'Chleb Pszenno-Żytni', 'Tost pełnoziarnisty', 'Tost  maślany', 'Lekkie żytnie', 'Beskidzkie paluszki z solą', 'Pieczywo Chrupkie Zytnie CRISPY z pomidorami i bazylią', 'Chleb żytni', 'Tortilla', 'Chleb żytni z dodatkiem amarantusa i komosy ryżowej', 'Pieczywo kukurydziane chrupkie', 'Fresh Wraps Grill Barbecue x4', 'tosty pszenny', 'Pieczywo Sonko Lekkie 7 Ziaren', 'Chleb Wiejski', 'Toast bread', 'Pieczywo z pełnoziarnistej mąki żytniej', 'Wraps lo-carb whole wheat tortilla', 'Chickpea cakes', 'Paluszki solone', 'Chleb Tostowy Z Mąką Pełnoziarnistą', 'Petits pains grilles', 'biscottes braisées', 'Biscottes sans sel ajouté', 'Biscottes Blé complet', 'Biscottes complètes x36', 'Piada sfogliata', 'Biscuits Nature');

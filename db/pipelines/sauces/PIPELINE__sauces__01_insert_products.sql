-- PIPELINE (Sauces): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Sauces'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900854002913', '5906716207359', '5900397016255', '20164041', '8005110519000', '4056489447160', '80042563', '8001310811050', '8002920016606')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Fanex', 'Grocery', 'Sauces', 'Sos meksykański', null, null, 'none', '5900854002913'),
  ('PL', 'Sottile Gusto', 'Grocery', 'Sauces', 'Passata', null, 'Biedronka', 'none', '5906716207359'),
  ('PL', 'ŁOWICZ', 'Grocery', 'Sauces', 'Sos Spaghetti', null, null, 'none', '5900397016255'),
  ('PL', 'Italiamo', 'Grocery', 'Sauces', 'Sugo al pomodoro con basilico', null, 'Lidl', 'none', '20164041'),
  ('PL', 'Mutti', 'Grocery', 'Sauces', 'Sauce Tomate aux légumes grillés', null, 'carrefour.fr', 'none', '8005110519000'),
  ('PL', 'Combino', 'Grocery', 'Sauces', 'Sauce tomate bio à la napolitaine', null, 'Lidl', 'none', '4056489447160'),
  ('PL', 'Mutti', 'Grocery', 'Sauces', 'Passierte Tomaten', null, 'Magasins U,Woolworths,Coles,Billa', 'none', '80042563'),
  ('PL', 'Polli', 'Grocery', 'Sauces', 'Pesto alla calabrese poivrons et ricotta', null, null, 'none', '8001310811050'),
  ('PL', 'gustobello', 'Grocery', 'Sauces', 'Passata', null, null, 'none', '8002920016606')
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
where country = 'PL' and category = 'Sauces'
  and is_deprecated is not true
  and product_name not in ('Sos meksykański', 'Passata', 'Sos Spaghetti', 'Sugo al pomodoro con basilico', 'Sauce Tomate aux légumes grillés', 'Sauce tomate bio à la napolitaine', 'Passierte Tomaten', 'Pesto alla calabrese poivrons et ricotta', 'Passata');

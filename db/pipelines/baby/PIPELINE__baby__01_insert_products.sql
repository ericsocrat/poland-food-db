-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Baby'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Kaszka mleczna z biszkoptami i jabłkami', null, null, 'none', '4062300279773'),
  ('PL', 'dada baby food', 'Grocery', 'Baby', 'bio mus kokos', null, null, 'none', '8436550903003')
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
where country = 'PL' and category = 'Baby'
  and is_deprecated is not true
  and product_name not in ('Kaszka mleczna z biszkoptami i jabłkami', 'bio mus kokos');

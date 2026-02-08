-- PIPELINE (Breakfast & Grain-Based): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Granola - Musli Prażone (Czekoladowe)', null, null, 'none', '5907437369043'),
  ('PL', 'Bakalland', 'Grocery', 'Breakfast & Grain-Based', 'Ba! Granola Z Żurawiną', null, null, 'none', '5900749615303'),
  ('PL', 'Go on', 'Grocery', 'Breakfast & Grain-Based', 'Granola proteinowa brownie & cherry', null, null, 'none', '5900617045126'),
  ('PL', 'Bakalland', 'Grocery', 'Breakfast & Grain-Based', 'Ba! Granola 5 bakalii', null, null, 'none', '5900749614313'),
  ('PL', 'Unknown', 'Grocery', 'Breakfast & Grain-Based', 'Étcsokis granola málnával', null, null, 'none', '5902884463184'),
  ('PL', 'All nutrition', 'Grocery', 'Breakfast & Grain-Based', 'F**king delicious Granola', null, null, 'none', '5902837740393'),
  ('PL', 'Unknown', 'Grocery', 'Breakfast & Grain-Based', 'Gyümölcsös granola', null, null, 'none', '5902884463160'),
  ('PL', 'All  nutrition', 'Grocery', 'Breakfast & Grain-Based', 'F**king delicious granola fruity', null, null, 'none', '5902837740409'),
  ('PL', 'Unknown', 'Grocery', 'Breakfast & Grain-Based', 'Granola with Fruits', null, null, 'none', '5906660508199'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Winter Granola', null, null, 'none', '5902884462866'),
  ('PL', 'One Day More', 'Grocery', 'Breakfast & Grain-Based', 'Protein Granola Caramel Nuts & Chocolate', null, null, 'none', '5905108803360'),
  ('PL', 'Sante', 'Grocery', 'Breakfast & Grain-Based', 'Granola o smaku rumu', null, null, 'none', '5900617046161'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Granola Z Ciasteczkami', null, null, 'none', '5907437369319'),
  ('PL', 'Vitanella', 'Grocery', 'Breakfast & Grain-Based', 'Cherry granola', null, null, 'none', '5907437369036')
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
where country = 'PL' and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true
  and product_name not in ('Granola - Musli Prażone (Czekoladowe)', 'Ba! Granola Z Żurawiną', 'Granola proteinowa brownie & cherry', 'Ba! Granola 5 bakalii', 'Étcsokis granola málnával', 'F**king delicious Granola', 'Gyümölcsös granola', 'F**king delicious granola fruity', 'Granola with Fruits', 'Winter Granola', 'Protein Granola Caramel Nuts & Chocolate', 'Granola o smaku rumu', 'Granola Z Ciasteczkami', 'Cherry granola');

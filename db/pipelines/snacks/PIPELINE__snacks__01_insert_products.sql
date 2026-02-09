-- PIPELINE (Snacks): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Snacks'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900617015723', '5900617013064', '5900617034809', '5060088706534', '3560071504090', '5201360521210', '20154691', '20080662', '7622300784751', '3800205871255')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sante A. Kowalski sp. j.', 'Grocery', 'Snacks', 'Crunchy Cranberry & Raspberry - Santé', null, 'Kaufland', 'none', '5900617015723'),
  ('PL', 'Go On', 'Grocery', 'Snacks', 'Sante Baton Proteinowy Go On Kakaowy', null, 'Lidl', 'none', '5900617013064'),
  ('PL', 'Sante', 'Grocery', 'Snacks', 'Vitamin coconut bar', null, 'zahran market', 'none', '5900617034809'),
  ('PL', 'nakd', 'Grocery', 'Snacks', 'Blueberry Muffin Myrtilles', null, 'Tesco,metro', 'none', '5060088706534'),
  ('PL', 'Carrefour', 'Grocery', 'Snacks', 'Toast crock'' céréales complètes', null, 'Carrefour Market,Carrefour', 'none', '3560071504090'),
  ('PL', '7 DAYS', 'Grocery', 'Snacks', 'Croissant with Cocoa Filling', null, 'Kaufland', 'palm oil', '5201360521210'),
  ('PL', 'Favorina', 'Grocery', 'Snacks', 'Coeurs pain d''épices chocolat noir', null, 'Lidl', 'none', '20154691'),
  ('PL', 'Crownfield', 'Grocery', 'Snacks', 'Muesli Bars Chocolate & Banana', null, 'Lidl', 'none', '20080662'),
  ('PL', 'Milka', 'Grocery', 'Snacks', 'Cake & Chock', null, null, 'none', '7622300784751'),
  ('PL', 'Maretti', 'Grocery', 'Snacks', 'Bruschette Chips Pizza Flavour', null, 'Penny', 'none', '3800205871255')
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
where country = 'PL' and category = 'Snacks'
  and is_deprecated is not true
  and product_name not in ('Crunchy Cranberry & Raspberry - Santé', 'Sante Baton Proteinowy Go On Kakaowy', 'Vitamin coconut bar', 'Blueberry Muffin Myrtilles', 'Toast crock'' céréales complètes', 'Croissant with Cocoa Filling', 'Coeurs pain d''épices chocolat noir', 'Muesli Bars Chocolate & Banana', 'Cake & Chock', 'Bruschette Chips Pizza Flavour');

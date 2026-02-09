-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900617012197', '5900012000232', '5900617038289', '5000157072023', '5900617038265', '20000653', '3560070910366', '20173074', '8076800105056', '20487942', '4056489067740', '20199876', '4056489181293', '1103086260005', '94001129')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sante', 'Grocery', 'Plant-Based & Alternatives', 'Masło orzechowe', null, 'Kaufland', 'none', '5900617012197'),
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', null, null, 'none', '5900012000232'),
  ('PL', 'GO ON', 'Grocery', 'Plant-Based & Alternatives', 'Peanut Butter Smooth', null, 'Lidl', 'none', '5900617038289'),
  ('PL', 'HEINZ', 'Grocery', 'Plant-Based & Alternatives', '5 rodzajów fasoli w sosie pomidorowym', 'baked', 'Sainsbury''s,Kaufland,Lidl', 'none', '5000157072023'),
  ('PL', 'Go On', 'Grocery', 'Plant-Based & Alternatives', 'Peanut Butter Crunchy', null, null, 'none', '5900617038265'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Doce Extra Fresa Morango', null, 'Lidl', 'none', '20000653'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Plant-Based & Alternatives', 'Huile d''olive vierge extra', null, 'Dia,Carrefour,carrefour.fr', 'none', '3560070910366'),
  ('PL', 'Batts', 'Grocery', 'Plant-Based & Alternatives', 'Crispy Fried Onions', 'fried', 'Lidl', 'none', '20173074'),
  ('PL', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Pâtes spaghetti n°5 1kg', null, 'Magasins U,carrefour.fr', 'none', '8076800105056'),
  ('PL', 'ITALIAMO', 'Grocery', 'Plant-Based & Alternatives', 'Paradizniki suseni lidl', null, 'Lidl', 'none', '20487942'),
  ('PL', 'DONAU SOJA', 'Grocery', 'Plant-Based & Alternatives', 'Tofu smoked', null, 'Lidl', 'none', '4056489067740'),
  ('PL', 'Lidl Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Aurinkokuivattuja tomaatteja', null, 'Lidl', 'none', '20199876'),
  ('PL', 'Vitasia', 'Grocery', 'Plant-Based & Alternatives', 'Rice Noodles', null, 'Lidl', 'none', '4056489181293'),
  ('PL', 'IKEA', 'Grocery', 'Plant-Based & Alternatives', 'Lingonberry jam, organic', null, 'IKEA', 'none', '1103086260005'),
  ('PL', 'ALDI Zespri', 'Grocery', 'Plant-Based & Alternatives', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€', null, 'Colruyt,Costco,REWE', 'none', '94001129')
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
where country = 'PL' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Masło orzechowe', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'Peanut Butter Smooth', '5 rodzajów fasoli w sosie pomidorowym', 'Peanut Butter Crunchy', 'Doce Extra Fresa Morango', 'Huile d''olive vierge extra', 'Crispy Fried Onions', 'Pâtes spaghetti n°5 1kg', 'Paradizniki suseni lidl', 'Tofu smoked', 'Aurinkokuivattuja tomaatteja', 'Rice Noodles', 'Lingonberry jam, organic', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€');

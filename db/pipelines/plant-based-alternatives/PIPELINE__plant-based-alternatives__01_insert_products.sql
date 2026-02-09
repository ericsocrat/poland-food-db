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
where ean in ('5900012000232', '5000157072023', '3560070910366', '20173074', '8076800105056', '4056489067740', '4056489181293', '20422103', '3560071469641', '20411978', '4056489067566', '20229030', '4056489068204', '3560071469573', '20013578', '8717496041647', '4056489126287', '3560070328970', '94001129')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Kujawski', 'Grocery', 'Plant-Based & Alternatives', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', null, null, 'none', '5900012000232'),
  ('PL', 'HEINZ', 'Grocery', 'Plant-Based & Alternatives', '5 rodzajów fasoli w sosie pomidorowym', 'baked', 'Sainsbury''s,Kaufland,Lidl', 'none', '5000157072023'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Plant-Based & Alternatives', 'Huile d''olive vierge extra', null, 'Dia,Carrefour,carrefour.fr', 'none', '3560070910366'),
  ('PL', 'Batts', 'Grocery', 'Plant-Based & Alternatives', 'Crispy Fried Onions', 'fried', 'Lidl', 'none', '20173074'),
  ('PL', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Pâtes spaghetti n°5 1kg', null, 'Magasins U,carrefour.fr', 'none', '8076800105056'),
  ('PL', 'DONAU SOJA', 'Grocery', 'Plant-Based & Alternatives', 'Tofu smoked', null, 'Lidl', 'none', '4056489067740'),
  ('PL', 'Vitasia', 'Grocery', 'Plant-Based & Alternatives', 'Rice Noodles', null, 'Lidl', 'none', '4056489181293'),
  ('PL', 'LIDL', 'Grocery', 'Plant-Based & Alternatives', 'ground chili peppers in olive oil', null, 'Lidl', 'none', '20422103'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Plant-Based & Alternatives', 'Galettes épeautre', null, 'carrefour.fr, Carrefour', 'none', '3560071469641'),
  ('PL', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Lasagnes', null, 'Lidl, Asda', 'none', '20411978'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu naturalne', null, 'Lidl', 'none', '4056489067566'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Avocados', null, 'Lidl', 'none', '20229030'),
  ('PL', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu basil Bio', null, 'Lidl', 'none', '4056489068204'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Plant-Based & Alternatives', 'Galettes 4 Céréales', null, 'carrefour.fr, Carrefour', 'none', '3560071469573'),
  ('PL', 'Vita D''or', 'Grocery', 'Plant-Based & Alternatives', 'Rapsöl', null, 'Lidl', 'none', '20013578'),
  ('PL', 'Driscoll''s', 'Grocery', 'Plant-Based & Alternatives', 'Framboises', null, 'Cora,Lidl,Edeka,Netto MD', 'none', '8717496041647'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Kalamata olive paste', null, 'Lidl', 'none', '4056489126287'),
  ('PL', 'Carrefour', 'Grocery', 'Plant-Based & Alternatives', 'Spaghetti', null, 'Carrefour,Carrefour City, carrefour.fr', 'none', '3560070328970'),
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
  and product_name not in ('Olej rzepakowy z pierwszego tłoczenia, filtrowany', '5 rodzajów fasoli w sosie pomidorowym', 'Huile d''olive vierge extra', 'Crispy Fried Onions', 'Pâtes spaghetti n°5 1kg', 'Tofu smoked', 'Rice Noodles', 'ground chili peppers in olive oil', 'Galettes épeautre', 'Lasagnes', 'Tofu naturalne', 'Avocados', 'Tofu basil Bio', 'Galettes 4 Céréales', 'Rapsöl', 'Framboises', 'Kalamata olive paste', 'Spaghetti', 'ALDI ZESPRI SunGold Kiwi Gold 1St. 0,65€');

-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Sante', 'Grocery', 'Plant-Based & Alternatives', 'Masło orzechowe', null, 'Kaufland', 'none', '5900617012197'),
  ('PL', 'HEINZ', 'Grocery', 'Plant-Based & Alternatives', '5 rodzajów fasoli w sosie pomidorowym', 'baked', 'Sainsbury''s,Kaufland,Lidl', 'none', '5000157072023'),
  ('PL', 'Lidl', 'Grocery', 'Plant-Based & Alternatives', 'Doce Extra Fresa Morango', null, 'Lidl', 'none', '20000653'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Plant-Based & Alternatives', 'Huile d''olive vierge extra', null, 'Dia,Carrefour,carrefour.fr', 'none', '3560070910366'),
  ('PL', 'Batts', 'Grocery', 'Plant-Based & Alternatives', 'Crispy Fried Onions', 'fried', 'Lidl', 'none', '20173074'),
  ('PL', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Pâtes spaghetti n°5 1kg', null, 'Magasins U,carrefour.fr', 'none', '8076800105056'),
  ('PL', 'ITALIAMO', 'Grocery', 'Plant-Based & Alternatives', 'Paradizniki suseni lidl', null, 'Lidl', 'none', '20487942'),
  ('PL', 'DONAU SOJA', 'Grocery', 'Plant-Based & Alternatives', 'Tofu smoked', null, 'Lidl', 'none', '4056489067740'),
  ('PL', 'Lidl Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Aurinkokuivattuja tomaatteja', null, 'Lidl', 'none', '20199876')
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
where country = 'PL' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Masło orzechowe', '5 rodzajów fasoli w sosie pomidorowym', 'Doce Extra Fresa Morango', 'Huile d''olive vierge extra', 'Crispy Fried Onions', 'Pâtes spaghetti n°5 1kg', 'Paradizniki suseni lidl', 'Tofu smoked', 'Aurinkokuivattuja tomaatteja');

-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000405004593', '4000405005026', '4075600055039', '4000405005033', '4066447584035', '4337256250122', '4337256857086', '4260380665039', '4260380665015', '20319335', '20004361', '4337256244794', '20163402', '5411188124689', '7394376621680', '8076800195057')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Schinken-Spicker Grillgemüse', 'not-applicable', 'Kaufland', 'none', '4000405004593'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'not-applicable', 'Lidl', 'none', '4000405005026'),
  ('DE', 'Bürger', 'Grocery', 'Plant-Based & Alternatives', 'Maultaschen traditionell schwäbisch', 'not-applicable', 'Lidl', 'none', '4075600055039'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Mühlen Nuggets Klassisch', 'not-applicable', 'Kaufland', 'none', '4000405005033'),
  ('DE', 'DmBio', 'Grocery', 'Plant-Based & Alternatives', 'Maiswaffeln', 'not-applicable', null, 'none', '4066447584035'),
  ('DE', 'REWE Bio +vegan', 'Grocery', 'Plant-Based & Alternatives', 'Räucher-Tofu', 'smoked', null, 'none', '4337256250122'),
  ('DE', 'Rewe', 'Grocery', 'Plant-Based & Alternatives', 'Falafel bällchen', 'not-applicable', null, 'none', '4337256857086'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Grilled Chicken', 'grilled', null, 'none', '4260380665039'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Chicken', 'not-applicable', null, 'none', '4260380665015'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomatenmark 2-Fach Konzentriert', 'not-applicable', 'Lidl', 'none', '20319335'),
  ('DE', 'Freshona', 'Grocery', 'Plant-Based & Alternatives', 'Cornichons Gurken', 'not-applicable', 'Lidl', 'none', '20004361'),
  ('DE', 'REWE Bio', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', null, 'none', '4337256244794'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomaten passiert', 'not-applicable', 'Lidl', 'none', '20163402'),
  ('DE', 'Alpro', 'Grocery', 'Plant-Based & Alternatives', 'Hafer Milch', 'not-applicable', null, 'none', '5411188124689'),
  ('DE', 'Oatly!', 'Grocery', 'Plant-Based & Alternatives', 'Haferdrink Barista Bio', 'not-applicable', null, 'none', '7394376621680'),
  ('DE', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Spaghetti N°5', 'not-applicable', 'Carrefour', 'none', '8076800195057')
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
where country = 'DE' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Veganer Schinken-Spicker Grillgemüse', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Maultaschen traditionell schwäbisch', 'Vegane Mühlen Nuggets Klassisch', 'Maiswaffeln', 'Räucher-Tofu', 'Falafel bällchen', 'Like Grilled Chicken', 'Like Chicken', 'Tomatenmark 2-Fach Konzentriert', 'Cornichons Gurken', 'Tofu Natur', 'Tomaten passiert', 'Hafer Milch', 'Haferdrink Barista Bio', 'Spaghetti N°5');

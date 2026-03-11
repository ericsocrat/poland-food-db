-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000405004593', '4000405005026', '4075600055039', '4000405005033', '4000405003251', '4066447584035', '4056489616214', '4337256250122', '4337256857086', '4260380665039', '4260380665015', '20319335', '20004361', '4337256244794', '20163402', '7613036915076', '20884697', '8076802085981', '8076800195057')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Plant-Based & Alternatives by pipeline',
    ean = null
where country = 'DE'
  and category != 'Plant-Based & Alternatives'
  and identity_key in ('10ddbe09d0dd51442229592a576e794e', '30af4cc7663c7d575cd12860627b7278', '48fbeab81e8f9bb46fad3d4fb0ced51e', '5f75c37868407efdac023cfd0793f6b9', '6177ee62f9e72cecf18b17e534330653', '74f3c59a50e3095ee1a9a4d05046734b', '76a8f13b385eba38ca8b94befb1b4701', '8236ecb7d7927564b681def1e08c078f', '862a94057ffcd072eea4681b6c01cb23', 'a364b013d7e6e6818c62cb35bfb629a9', 'a8d14133c45668378038508e9acd6032', 'ae88970fbd9184a737faab303deb8fcb', 'b01a6447e70622a8ad47fcdbd328c898', 'b83d6fd129c0508f1fcc1635695ce148', 'b8795e17e3545773ade23decb63edd86', 'b8846f84379f8bdda0b7acc1ce1939f5', 'ed47fa34a5c9dffdd00b7ef3cd2f2dc5', 'f0f2a866d5c227a64cb550dcd6c304e5', 'f9f1687fb0bfb3f36fd1ce0c67dab2cf')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Schinken-Spicker Grillgemüse', 'not-applicable', 'Kaufland', 'none', '4000405004593'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'not-applicable', 'Lidl', 'none', '4000405005026'),
  ('DE', 'Bürger', 'Grocery', 'Plant-Based & Alternatives', 'Maultaschen traditionell schwäbisch', 'not-applicable', 'Lidl', 'none', '4075600055039'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Mühlen Nuggets Klassisch', 'not-applicable', 'Kaufland', 'none', '4000405005033'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 'not-applicable', null, 'none', '4000405003251'),
  ('DE', 'DmBio', 'Grocery', 'Plant-Based & Alternatives', 'Maiswaffeln', 'not-applicable', null, 'none', '4066447584035'),
  ('DE', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', 'Lidl', 'none', '4056489616214'),
  ('DE', 'REWE Bio +vegan', 'Grocery', 'Plant-Based & Alternatives', 'Räucher-Tofu', 'smoked', null, 'none', '4337256250122'),
  ('DE', 'Rewe', 'Grocery', 'Plant-Based & Alternatives', 'Falafel bällchen', 'not-applicable', null, 'none', '4337256857086'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Grilled Chicken', 'grilled', null, 'none', '4260380665039'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Chicken', 'not-applicable', null, 'none', '4260380665015'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomatenmark 2-Fach Konzentriert', 'not-applicable', 'Lidl', 'none', '20319335'),
  ('DE', 'Freshona', 'Grocery', 'Plant-Based & Alternatives', 'Cornichons Gurken', 'not-applicable', 'Lidl', 'none', '20004361'),
  ('DE', 'Rewe Bio', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', null, 'none', '4337256244794'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomaten passiert', 'not-applicable', 'Lidl', 'none', '20163402'),
  ('DE', 'Garden Gourmet', 'Grocery', 'Plant-Based & Alternatives', 'Sensational Burger aus Sojaprotein', 'not-applicable', null, 'none', '7613036915076'),
  ('DE', 'Sondey', 'Grocery', 'Plant-Based & Alternatives', 'Mais Waffeln mit Meersalz Bio', 'not-applicable', 'Lidl', 'none', '20884697'),
  ('DE', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Fusilli 98', 'not-applicable', 'Lidl', 'none', '8076802085981'),
  ('DE', 'Barilla', 'Grocery', 'Plant-Based & Alternatives', 'Spaghetti n5', 'not-applicable', 'Carrefour', 'none', '8076800195057')
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
  and product_name not in ('Veganer Schinken-Spicker Grillgemüse', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Maultaschen traditionell schwäbisch', 'Vegane Mühlen Nuggets Klassisch', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 'Maiswaffeln', 'Tofu Natur', 'Räucher-Tofu', 'Falafel bällchen', 'Like Grilled Chicken', 'Like Chicken', 'Tomatenmark 2-Fach Konzentriert', 'Cornichons Gurken', 'Tofu Natur', 'Tomaten passiert', 'Sensational Burger aus Sojaprotein', 'Mais Waffeln mit Meersalz Bio', 'Fusilli 98', 'Spaghetti n5');

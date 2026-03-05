-- PIPELINE (Breakfast & Grain-Based): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000521662103', '4000540003260', '4000540023169', '4066447524413', '4000540003222', '4000540011517', '4008391212145', '4000521010423', '4000540003130', '4000540001501', '4000521041991', '4000521040628', '4061464835504', '4000521021894', '4000521663407', '4000540003314', '4000540011364', '4008391008205', '4000521661304', '4061464833838', '4061464833845', '4066447607567', '4000521661205', '4056489255499', '4000521040680', '4061464836297', '4000540003956', '4061459595079', '4000521041977', '4000540043587', '4061458181266', '4008391041479', '4061464835580', '4000540003192', '4000540001341', '4000540053869', '4000540003468', '4000540063868', '4000540001334', '4067796057089', '4067796066760', '4061464835757', '4000521035686', '4066447607598', '4000540003246', '4000540003567', '4008391051508', '4000521027032', '4066447524772', '4015637018799', '4061464833821')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'not-applicable', null, 'none', '4000521662103'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 'not-applicable', null, 'none', '4000540003260'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Knusper Honig-Nuss Müsli', 'not-applicable', 'Lidl', 'none', '4000540023169'),
  ('DE', 'Dm', 'Grocery', 'Breakfast & Grain-Based', 'Bio Schokomüsli ohne Rosinen', 'not-applicable', null, 'none', '4066447524413'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'not-applicable', 'Lidl', 'none', '4000540003222'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Zartes Bircher Müsli', 'not-applicable', null, 'none', '4000540011517'),
  ('DE', 'Seitenbacher', 'Grocery', 'Breakfast & Grain-Based', 'Kakao-Düsis', 'not-applicable', null, 'none', '4008391212145'),
  ('DE', 'Dr. Oetker Vitalis', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Weniger süß Knusper Himbeere', 'not-applicable', null, 'none', '4000521010423'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 'not-applicable', null, 'none', '4000540003130'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Hafer Müsli Beere Apfel', 'not-applicable', null, 'none', '4000540001501'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Schoko Müsli klassisch', 'not-applicable', null, 'none', '4000521041991'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Knusper Schoko Müsli', 'not-applicable', null, 'none', '4000521040628'),
  ('DE', 'Golden Bridge', 'Grocery', 'Breakfast & Grain-Based', 'Trauben-Nuss Müsli Vollkorn', 'not-applicable', 'Aldi', 'none', '4061464835504'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Knusper Müsli PLUS Nussmischung', 'not-applicable', null, 'none', '4000521021894'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Müsli Joghurt', 'not-applicable', null, 'none', '4000521663407'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Crunchy Berry Hafer-Müsli', 'not-applicable', null, 'none', '4000540003314'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Kölln Müsli Nuss & Krokant', 'not-applicable', 'Kaufland', 'none', '4000540011364'),
  ('DE', 'Seitenbacher', 'Grocery', 'Breakfast & Grain-Based', 'Müsli 205 Für Sportliche', 'not-applicable', null, 'none', '4008391008205'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Knusper müsli Honeys', 'not-applicable', null, 'none', '4000521661304'),
  ('DE', 'Golden Bridge', 'Grocery', 'Breakfast & Grain-Based', 'Schoko-Müsli mit 30 % weniger Zucker', 'not-applicable', 'Aldi', 'none', '4061464833838'),
  ('DE', 'Golden Bridge', 'Grocery', 'Breakfast & Grain-Based', 'Früchte-Müsli', 'not-applicable', 'Aldi', 'none', '4061464833845'),
  ('DE', 'DmBio', 'Grocery', 'Breakfast & Grain-Based', 'Beeren Müsli', 'not-applicable', null, 'none', '4066447607567'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Knusper Müsli klassisch', 'not-applicable', null, 'none', '4000521661205'),
  ('DE', 'Crownfield', 'Grocery', 'Breakfast & Grain-Based', 'Schoko Müsli', 'not-applicable', 'Lidl', 'none', '4056489255499'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Knusper Schoko Müsli', 'not-applicable', null, 'none', '4000521040680'),
  ('DE', 'GUT Bio', 'Grocery', 'Breakfast & Grain-Based', 'Basis Müsli 5-Kornmix', 'not-applicable', 'Aldi', 'none', '4061464836297'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Crunchy Mango-Maracuja Hafer-Müsli', 'not-applicable', null, 'none', '4000540003956'),
  ('DE', 'Aldi', 'Grocery', 'Breakfast & Grain-Based', 'Bio-Müsli - Urkorn-Früchte', 'not-applicable', 'Aldi', 'none', '4061459595079'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Müsli Schoko weniger süss', 'not-applicable', null, 'none', '4000521041977'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 'not-applicable', null, 'none', '4000540043587'),
  ('DE', 'GUT bio', 'Grocery', 'Breakfast & Grain-Based', 'Bio Knusper-Müsli Schoko-Amaranth', 'not-applicable', 'Aldi', 'none', '4061458181266'),
  ('DE', 'Seitenbacher', 'Grocery', 'Breakfast & Grain-Based', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 'not-applicable', null, 'none', '4008391041479'),
  ('DE', 'Golden Bridge', 'Grocery', 'Breakfast & Grain-Based', 'Früchte-Müsli Vollkorn', 'not-applicable', 'Aldi', 'none', '4061464835580'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Crunchy Hazel Hafer-Müsli', 'not-applicable', null, 'none', '4000540003192'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Früchte Hafer-Müsli', 'not-applicable', null, 'none', '4000540001341'),
  ('DE', 'Kölln kölln', 'Grocery', 'Breakfast & Grain-Based', 'Schoko Müsli', 'not-applicable', null, 'none', '4000540053869'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Knusper Müsli', 'not-applicable', null, 'none', '4000540003468'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Hafer Müsli', 'not-applicable', null, 'none', '4000540063868'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Früchte Müsli ohne Zuckerzusatz', 'not-applicable', null, 'none', '4000540001334'),
  ('DE', 'DmBio', 'Grocery', 'Breakfast & Grain-Based', 'Müsli Nuss', 'not-applicable', null, 'none', '4067796057089'),
  ('DE', 'DmBio', 'Grocery', 'Breakfast & Grain-Based', 'Paleo Müsli', 'not-applicable', null, 'none', '4067796066760'),
  ('DE', 'Golden Bridge', 'Grocery', 'Breakfast & Grain-Based', 'Premium Müsli', 'not-applicable', null, 'none', '4061464835757'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Vitalis Müsli Knusper Schoko ohne Zuckerzusatz', 'not-applicable', null, 'none', '4000521035686'),
  ('DE', 'DmBio', 'Grocery', 'Breakfast & Grain-Based', 'Basismüsli ohne Rosinen', 'not-applicable', null, 'none', '4066447607598'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Knusper Schoko & Keks Müsli', 'not-applicable', null, 'none', '4000540003246'),
  ('DE', 'Kölln', 'Grocery', 'Breakfast & Grain-Based', 'Knusper Joghurt Himbeer Müsli', 'not-applicable', null, 'palm oil', '4000540003567'),
  ('DE', 'Seitenbacher', 'Grocery', 'Breakfast & Grain-Based', 'Müsli 508 Dinos Frühstück', 'not-applicable', null, 'none', '4008391051508'),
  ('DE', 'Dr. Oetker', 'Grocery', 'Breakfast & Grain-Based', 'Paula Müslispaß Schoko', 'not-applicable', null, 'none', '4000521027032'),
  ('DE', 'DmBio', 'Grocery', 'Breakfast & Grain-Based', 'Früchte müsli', 'not-applicable', null, 'none', '4066447524772'),
  ('DE', 'Bauck Mühle', 'Grocery', 'Breakfast & Grain-Based', 'Schoko+Flakes Hafer Müsli Bio', 'not-applicable', null, 'none', '4015637018799'),
  ('DE', 'Brüggen', 'Grocery', 'Breakfast & Grain-Based', 'Schoko-Müsli', 'not-applicable', null, 'none', '4061464833821')
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
where country = 'DE' and category = 'Breakfast & Grain-Based'
  and is_deprecated is not true
  and product_name not in ('Vitalis Knuspermüsli Weniger Süß Knusper pur ohne Rosinen', 'Kölln Knusper Volkorn-Müsli mit Vanille-Note 500g', 'Knusper Honig-Nuss Müsli', 'Bio Schokomüsli ohne Rosinen', 'Kellogs, Hafer-Müsli, Schoko und Keks', 'Zartes Bircher Müsli', 'Kakao-Düsis', 'Vitalis Weniger süß Knusper Himbeere', 'Crunchy Choc-Choc-Choc - Hafer-Müsli', 'Hafer Müsli Beere Apfel', 'Schoko Müsli klassisch', 'Vitalis Knusper Schoko Müsli', 'Trauben-Nuss Müsli Vollkorn', 'Vitalis Knusper Müsli PLUS Nussmischung', 'Vitalis Müsli Joghurt', 'Crunchy Berry Hafer-Müsli', 'Kölln Müsli Nuss & Krokant', 'Müsli 205 Für Sportliche', 'Vitalis Knusper müsli Honeys', 'Schoko-Müsli mit 30 % weniger Zucker', 'Früchte-Müsli', 'Beeren Müsli', 'Vitalis Knusper Müsli klassisch', 'Schoko Müsli', 'Knusper Schoko Müsli', 'Basis Müsli 5-Kornmix', 'Crunchy Mango-Maracuja Hafer-Müsli', 'Bio-Müsli - Urkorn-Früchte', 'Müsli Schoko weniger süss', 'EDEKA Müsli Kölln Müsli Knusper Schoko-Krokant 500g 2.49€ 1kg 4.98€', 'Bio Knusper-Müsli Schoko-Amaranth', 'Seitenbacher Müsli 479 Knackige Mischung Ohne Süß', 'Früchte-Müsli Vollkorn', 'Crunchy Hazel Hafer-Müsli', 'Früchte Hafer-Müsli', 'Schoko Müsli', 'Knusper Müsli', 'Hafer Müsli', 'Früchte Müsli ohne Zuckerzusatz', 'Müsli Nuss', 'Paleo Müsli', 'Premium Müsli', 'Vitalis Müsli Knusper Schoko ohne Zuckerzusatz', 'Basismüsli ohne Rosinen', 'Knusper Schoko & Keks Müsli', 'Knusper Joghurt Himbeer Müsli', 'Müsli 508 Dinos Frühstück', 'Paula Müslispaß Schoko', 'Früchte müsli', 'Schoko+Flakes Hafer Müsli Bio', 'Schoko-Müsli');

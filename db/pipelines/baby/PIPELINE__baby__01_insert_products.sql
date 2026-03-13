-- PIPELINE (Baby): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Baby'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5907069000017', '5901958612367', '5900852041129', '5901939006031', '9062300126638', '7613033629303', '7613035507142', '8591119253835', '4062300279773', '7613287666819', '9062300109365', '22009326')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Baby by pipeline',
    ean = null
where country = 'PL'
  and category != 'Baby'
  and identity_key in ('11402e2682a1fac58d1284e78699b4c8', '235592acb044f31d0687cc8c31779bfb', '27ce0e5d358dd425ce8de8c307a369ab', '41a1afe882d7b0cffa411a700a3d79af', '463169ff4e9e1192d9961f6fad97c511', '8a02752fe7df4f14e52f7150649d6df2', '943bffb097372b5be60f564765b8e85e', 'b6d44ead4c04d9187bdda7285fbdf425', 'd10ac75ada0950aca78bcb7d1509bc88', 'd1b2b6acea13c0ed396c6422232a2a6c', 'e69de1a3ed5587ca55591126565f9fb0', 'f0dfa6d8f7a1b4709a6060922052e9fd')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Diamant', 'Grocery', 'Baby', 'Cukier Biały', 'not-applicable', 'Kaufland', 'none', '5907069000017'),
  ('PL', 'Owolovo', 'Grocery', 'Baby', 'Truskawkowo Mus jabłkowo-truskawkowy', 'not-applicable', 'Biedronka', 'none', '5901958612367'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'not-applicable', null, 'none', '5900852041129'),
  ('PL', 'Piątnica', 'Grocery', 'Baby', 'Koktajl z białkiem serwatkowym', 'not-applicable', null, 'none', '5901939006031'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'not-applicable', null, 'none', '9062300126638'),
  ('PL', 'Nestle Gerber', 'Grocery', 'Baby', 'Owoce jabłka z truskawkami i jagodami', 'not-applicable', null, 'none', '7613033629303'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Leczo z mozzarellą i kluseczkami', 'not-applicable', null, 'none', '7613035507142'),
  ('PL', 'BoboVita', 'Grocery', 'Baby', 'BoboVita Jabłka z marchewka', 'not-applicable', null, 'none', '8591119253835'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Kaszka mleczna z biszkoptami i jabłkami', 'not-applicable', null, 'none', '4062300279773'),
  ('PL', 'Nestlé', 'Grocery', 'Baby', 'Nestle Sinlac', 'not-applicable', null, 'none', '7613287666819'),
  ('PL', 'Hipp', 'Grocery', 'Baby', 'Dynia z indykiem', 'not-applicable', null, 'none', '9062300109365'),
  ('PL', 'GutBio', 'Grocery', 'Baby', 'Puré de Frutas Manzana y Plátano', 'not-applicable', 'Aldi', 'none', '22009326')
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
where country = 'PL' and category = 'Baby'
  and is_deprecated is not true
  and product_name not in ('Cukier Biały', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Kaszka Mleczna 7 Zbóż Zbożowo-Jaglana Owocowa', 'Koktajl z białkiem serwatkowym', 'Ziemniaki z buraczkami, jabłkiem i wołowiną', 'Owoce jabłka z truskawkami i jagodami', 'Leczo z mozzarellą i kluseczkami', 'BoboVita Jabłka z marchewka', 'Kaszka mleczna z biszkoptami i jabłkami', 'Nestle Sinlac', 'Dynia z indykiem', 'Puré de Frutas Manzana y Plátano');

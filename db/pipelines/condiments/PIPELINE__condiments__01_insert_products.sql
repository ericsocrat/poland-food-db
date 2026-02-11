-- PIPELINE (Condiments): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Condiments'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900385012573', '5900783004996', '5900783003043', '5901044011074', '5900783008581', '5900084254700', '5900783000424', '5900385500148', '5901044022896', '5900385501756', '5901044003581', '5900385012528', '5906425121397', '5901713012692', '5901044022872', '5901044022889', '5906425121861', '5900084229395', '5901044016802', '5900242000187', '5906425111473', '5900783010287', '5900783008697', '5900783000417', '5900783003418', '5901044027549', '5900783009557', '5901248000911')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup Łagodny', 'not-applicable', 'Netto', 'none', '5900385012573'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Biedronka', 'none', '5900783004996'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny - Najsmaczniejszy', 'not-applicable', 'Auchan', 'none', '5900783003043'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup łagodny markowy', 'not-applicable', 'Auchan', 'none', '5901044011074'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup Łagodny Premium', 'not-applicable', 'Lidl', 'none', '5900783008581'),
  ('PL', 'Kamis', 'Grocery', 'Condiments', 'Ketchup włoski', 'not-applicable', 'Auchan', 'none', '5900084254700'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5900783000424'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5900385500148'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup Premium Łagodny', 'not-applicable', null, 'none', '5901044022896'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup Łagodny', 'not-applicable', null, 'none', '5900385501756'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Musztarda Stołowa', 'not-applicable', null, 'none', '5901044003581'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup hot', 'not-applicable', 'Netto', 'none', '5900385012528'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup junior', 'not-applicable', 'Biedronka', 'none', '5906425121397'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5901713012692'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup Premium', 'not-applicable', 'Biedronka', 'none', '5901044022872'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup premium Pikantny', 'not-applicable', 'Kaufland', 'none', '5901044022889'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Premium ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5906425121861'),
  ('PL', 'Kamis', 'Grocery', 'Condiments', 'Musztarda sarepska ostra', 'not-applicable', 'Tesco', 'none', '5900084229395'),
  ('PL', 'Firma Roleski', 'Grocery', 'Condiments', 'Mutarde', 'not-applicable', 'Dino', 'none', '5901044016802'),
  ('PL', 'Spolem', 'Grocery', 'Condiments', 'Spo?e Musztarda Delikatesowa 190Ml', 'not-applicable', 'Carrefour', 'none', '5900242000187'),
  ('PL', 'Unknown', 'Grocery', 'Condiments', 'Musztarda stołowa', 'not-applicable', null, 'none', '5906425111473'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Heinz Zero Sel Ajoute', 'not-applicable', null, 'none', '5900783010287'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', null, 'none', '5900783008697'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', null, 'none', '5900783000417'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup Lagodny', 'not-applicable', null, 'none', '5900783003418'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup premium sycylijski KETO do pizzy', 'not-applicable', null, 'none', '5901044027549'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', null, 'none', '5900783009557'),
  ('PL', 'Wloclawek', 'Grocery', 'Condiments', 'Wloclawek Mild Tomato Ketchup', 'not-applicable', null, 'none', '5901248000911')
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
where country = 'PL' and category = 'Condiments'
  and is_deprecated is not true
  and product_name not in ('Ketchup Łagodny', 'Ketchup łagodny', 'Ketchup łagodny - Najsmaczniejszy', 'Ketchup łagodny markowy', 'Ketchup Łagodny Premium', 'Ketchup włoski', 'Ketchup łagodny', 'Ketchup łagodny', 'Ketchup Premium Łagodny', 'Ketchup Łagodny', 'Musztarda Stołowa', 'Ketchup hot', 'Ketchup junior', 'Ketchup pikantny', 'Ketchup Premium', 'Ketchup premium Pikantny', 'Premium ketchup pikantny', 'Musztarda sarepska ostra', 'Mutarde', 'Spo?e Musztarda Delikatesowa 190Ml', 'Musztarda stołowa', 'Heinz Zero Sel Ajoute', 'ketchup pikantny', 'Ketchup pikantny', 'Ketchup Lagodny', 'Ketchup premium sycylijski KETO do pizzy', 'Ketchup pikantny', 'Wloclawek Mild Tomato Ketchup');

-- PIPELINE (Condiments): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-11

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Condiments'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900385012573', '5900783004996', '5900783003043', '5900783008581', '5901044011074', '5901307001309', '5900783008673', '5901248001444', '5901713012173', '5900084254700', '5901713012647', '5901044015652', '5906425121830', '5901529031436', '5901658000020', '5900783008680', '5900385500148', '5901044022896', '5900385501756', '5901044027532', '5901619150948', '5906734827294', '5901986081050', '5908235940083', '5900385501640', '5902501342007', '5902501339007', '5903760706135', '5901307004973', '5901044003581', '5900385012528', '5901713012692', '5906425121397', '5901044022872', '5901307006519', '5906425121243', '5901713012654', '5901248002076', '5901044022889', '5901044027556', '5900385501688', '5906425121861', '5900385500391', '5906425121434', '5900854002555', '5900854002890', '5901248001123', '5901986081111', '5900783006426', '5906425120215')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup Łagodny', 'not-applicable', 'Netto', 'none', '5900385012573'),
  ('PL', 'Heinz', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Biedronka', 'none', '5900783004996'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny - Najsmaczniejszy', 'not-applicable', 'Auchan', 'none', '5900783003043'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup Łagodny Premium', 'not-applicable', 'Lidl', 'none', '5900783008581'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup łagodny markowy', 'not-applicable', 'Auchan', 'none', '5901044011074'),
  ('PL', 'Kotliński specjał', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Dino', 'none', '5901307001309'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny Pudliszek', 'not-applicable', 'Żabka', 'none', '5900783008673'),
  ('PL', 'Agro Nova Food', 'Grocery', 'Condiments', 'Ketchup pikantny z pomidorów z Kujaw', 'not-applicable', 'Auchan', 'none', '5901248001444'),
  ('PL', 'Dawtona', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Auchan', 'none', '5901713012173'),
  ('PL', 'Kamis', 'Grocery', 'Condiments', 'Ketchup włoski', 'not-applicable', 'Auchan', 'none', '5900084254700'),
  ('PL', 'Tomatini', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Biedronka', 'none', '5901713012647'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup markowy łagodny', 'not-applicable', 'Auchan', 'none', '5901044015652'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Biedronka', 'none', '5906425121830'),
  ('PL', 'Unknown', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', 'Netto', 'none', '5901529031436'),
  ('PL', 'Pegaz', 'Grocery', 'Condiments', 'Musztarda stołowa', 'not-applicable', 'Biedronka', 'none', '5901658000020'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5900783008680'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5900385500148'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup Premium Łagodny', 'not-applicable', null, 'none', '5901044022896'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup Łagodny', 'not-applicable', null, 'none', '5900385501756'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup premium meksykański KETO', 'not-applicable', null, 'none', '5901044027532'),
  ('PL', 'Międzychód', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5901619150948'),
  ('PL', 'Na Szlaku Smaku', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5906734827294'),
  ('PL', 'Polskie przetwory', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5901986081050'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5908235940083'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup z truskawką', 'not-applicable', null, 'none', '5900385501640'),
  ('PL', 'Reypol', 'Grocery', 'Condiments', 'Ketchup Ziołowy Premium z Nasionami Konopi', 'not-applicable', null, 'none', '5902501342007'),
  ('PL', 'Reypol', 'Grocery', 'Condiments', 'Ketchup premium łagodny', 'not-applicable', null, 'none', '5902501339007'),
  ('PL', 'Lewiatan', 'Grocery', 'Condiments', 'Ketchup Łagodny', 'not-applicable', null, 'none', '5903760706135'),
  ('PL', 'Kotliński', 'Grocery', 'Condiments', 'Ketchup łagodny', 'not-applicable', null, 'none', '5901307004973'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Musztarda Stołowa', 'not-applicable', null, 'none', '5901044003581'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup hot', 'not-applicable', 'Netto', 'none', '5900385012528'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5901713012692'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup junior', 'not-applicable', 'Biedronka', 'none', '5906425121397'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup Premium', 'not-applicable', 'Biedronka', 'none', '5901044022872'),
  ('PL', 'Kotlin sp. z o. o.', 'Grocery', 'Condiments', 'Ketchup kotliński', 'not-applicable', null, 'none', '5901307006519'),
  ('PL', 'Develey', 'Grocery', 'Condiments', 'Ketchup z dodatkiem miodu, czosnku i tymianku.', 'not-applicable', 'Biedronka', 'none', '5906425121243'),
  ('PL', 'Dawtona', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5901713012654'),
  ('PL', 'Włocławek', 'Grocery', 'Condiments', 'Ketchup', 'not-applicable', 'Auchan', 'none', '5901248002076'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup premium Pikantny', 'not-applicable', 'Kaufland', 'none', '5901044022889'),
  ('PL', 'Roleski', 'Grocery', 'Condiments', 'Ketchup premium jalapeño KETO', 'not-applicable', 'Kaufland', 'none', '5901044027556'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Kotlin Ketchup Premium', 'not-applicable', 'Lidl', 'none', '5900385501688'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Premium ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5906425121861'),
  ('PL', 'Kotlin', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', 'Biedronka', 'none', '5900385500391'),
  ('PL', 'Madero', 'Grocery', 'Condiments', 'Ketchup classic', 'not-applicable', 'Biedronka', 'none', '5906425121434'),
  ('PL', 'Fenex', 'Grocery', 'Condiments', 'Ketchup nr. VII', 'not-applicable', 'Auchan', 'none', '5900854002555'),
  ('PL', 'Fenex', 'Grocery', 'Condiments', 'Ketchup nr VII', 'not-applicable', 'Auchan', 'none', '5900854002890'),
  ('PL', 'Włocławek', 'Grocery', 'Condiments', 'Ketchup pikantny', 'not-applicable', 'Auchan', 'none', '5901248001123'),
  ('PL', 'Krajowa Spółka Cukrowa', 'Grocery', 'Condiments', 'Ketchup lagoduy', 'not-applicable', 'Lewiatan', 'none', '5901986081111'),
  ('PL', 'Pudliszki', 'Grocery', 'Condiments', 'Ketchup Super Pikantny', 'not-applicable', 'Lidl', 'none', '5900783006426'),
  ('PL', 'Develey', 'Grocery', 'Condiments', 'Ketchup Pikantny', 'not-applicable', null, 'none', '5906425120215')
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
  and product_name not in ('Ketchup Łagodny', 'Ketchup łagodny', 'Ketchup łagodny - Najsmaczniejszy', 'Ketchup Łagodny Premium', 'Ketchup łagodny markowy', 'Ketchup łagodny', 'Ketchup łagodny Pudliszek', 'Ketchup pikantny z pomidorów z Kujaw', 'Ketchup łagodny', 'Ketchup włoski', 'Ketchup łagodny', 'Ketchup markowy łagodny', 'Ketchup łagodny', 'Ketchup łagodny', 'Musztarda stołowa', 'Ketchup łagodny', 'Ketchup łagodny', 'Ketchup Premium Łagodny', 'Ketchup Łagodny', 'Ketchup premium meksykański KETO', 'Ketchup łagodny', 'Ketchup łagodny', 'Ketchup łagodny', 'Ketchup łagodny', 'Ketchup z truskawką', 'Ketchup Ziołowy Premium z Nasionami Konopi', 'Ketchup premium łagodny', 'Ketchup Łagodny', 'Ketchup łagodny', 'Musztarda Stołowa', 'Ketchup hot', 'Ketchup pikantny', 'Ketchup junior', 'Ketchup Premium', 'Ketchup kotliński', 'Ketchup z dodatkiem miodu, czosnku i tymianku.', 'Ketchup pikantny', 'Ketchup', 'Ketchup premium Pikantny', 'Ketchup premium jalapeño KETO', 'Kotlin Ketchup Premium', 'Premium ketchup pikantny', 'Ketchup pikantny', 'Ketchup classic', 'Ketchup nr. VII', 'Ketchup nr VII', 'Ketchup pikantny', 'Ketchup lagoduy', 'Ketchup Super Pikantny', 'Ketchup Pikantny');

-- PIPELINE (Alcohol): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Alcohol'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900014005716', '5900014004245', '5900535013986', '5900014002562', '5900699106388', '5903538900628', '5901359074290', '5902709615323', '5901359074269', '5901359062013', '5900490000182', '5901359122021', '5900014005105', '5900535019209', '5901359144917', '5900014003569', '5906591002520', '4304493261709', '8712000900045', '4905846960050', '1704314830009', '4003301069086', '4003301069048', '4600721021566', '0085000024683')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Seth & Riley''s Garage Euphoriq', 'Grocery', 'Alcohol', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'not-applicable', 'Biedronka', 'none', '5900014005716'),
  ('PL', 'Harnaś', 'Grocery', 'Alcohol', 'Harnaś jasne pełne', 'not-applicable', null, 'none', '5900014004245'),
  ('PL', 'Van Pur S.A.', 'Grocery', 'Alcohol', 'Łomża piwo jasne bezalkoholowe', 'not-applicable', null, 'none', '5900535013986'),
  ('PL', 'Karmi', 'Grocery', 'Alcohol', 'Karmi o smaku żurawina', 'not-applicable', null, 'none', '5900014002562'),
  ('PL', 'Żywiec', 'Grocery', 'Alcohol', 'Limonż 0%', 'not-applicable', null, 'none', '5900699106388'),
  ('PL', 'Lomża', 'Grocery', 'Alcohol', 'Łomża jasne', 'not-applicable', null, 'none', '5903538900628'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Kozel cerny', 'not-applicable', 'Auchan', 'none', '5901359074290'),
  ('PL', 'Browar Fortuna', 'Grocery', 'Alcohol', 'Piwo Pilzner, dolnej fermentacji', 'not-applicable', 'Kaufland', 'none', '5902709615323'),
  ('PL', 'Velkopopovicky Kozel', 'Grocery', 'Alcohol', 'Polnische Bier (Dose)', 'not-applicable', 'Kaufland', 'none', '5901359074269'),
  ('PL', 'Tyskie', 'Grocery', 'Alcohol', 'Bier &quot;Tyskie Gronie&quot;', 'not-applicable', 'Kaufland', 'none', '5901359062013'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Premium', 'not-applicable', null, 'none', '5900490000182'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Lech free', 'not-applicable', null, 'none', '5901359122021'),
  ('PL', 'Zatecky', 'Grocery', 'Alcohol', 'Zatecky 0%', 'not-applicable', null, 'none', '5900014005105'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Radler 0,0%', 'not-applicable', null, 'none', '5900535019209'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Free Lime Mint', 'not-applicable', null, 'none', '5901359144917'),
  ('PL', 'Carlsberg', 'Grocery', 'Alcohol', 'Pilsner 0.0%', 'not-applicable', null, 'none', '5900014003569'),
  ('PL', 'Amber', 'Grocery', 'Alcohol', 'Amber IPA zero', 'not-applicable', null, 'none', '5906591002520'),
  ('PL', 'Christkindl', 'Grocery', 'Alcohol', 'Christkindl Glühwein', 'not-applicable', 'Lidl', 'none', '4304493261709'),
  ('PL', 'Heineken', 'Grocery', 'Alcohol', 'Heineken Beer', 'not-applicable', null, 'none', '8712000900045'),
  ('PL', 'Choya', 'Grocery', 'Alcohol', 'Silver', 'not-applicable', null, 'none', '4905846960050'),
  ('PL', 'Ikea', 'Grocery', 'Alcohol', 'Glühwein', 'not-applicable', 'Ikea', 'none', '1704314830009'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0 White alcoholfree', 'not-applicable', 'Dealz', 'none', '4003301069086'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0. Red', 'not-applicable', 'Dealz', 'none', '4003301069048'),
  ('PL', 'Hoegaarden', 'Grocery', 'Alcohol', 'Hoegaarden hveteøl, 4,9%', 'not-applicable', null, 'none', '4600721021566'),
  ('PL', 'Carlo Rossi', 'Grocery', 'Alcohol', 'Vin carlo rossi', 'not-applicable', null, 'none', '0085000024683')
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
where country = 'PL' and category = 'Alcohol'
  and is_deprecated is not true
  and product_name not in ('Bezalkoholowy napój piwny o smaku jagód i marakui', 'Harnaś jasne pełne', 'Łomża piwo jasne bezalkoholowe', 'Karmi o smaku żurawina', 'Limonż 0%', 'Łomża jasne', 'Kozel cerny', 'Piwo Pilzner, dolnej fermentacji', 'Polnische Bier (Dose)', 'Bier &quot;Tyskie Gronie&quot;', 'Lech Premium', 'Lech free', 'Zatecky 0%', 'Radler 0,0%', 'Lech Free Lime Mint', 'Pilsner 0.0%', 'Amber IPA zero', 'Christkindl Glühwein', 'Heineken Beer', 'Silver', 'Glühwein', 'Just 0 White alcoholfree', 'Just 0. Red', 'Hoegaarden hveteøl, 4,9%', 'Vin carlo rossi');

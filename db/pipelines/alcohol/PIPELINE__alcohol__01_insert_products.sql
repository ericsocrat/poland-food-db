-- PIPELINE (Alcohol): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-09

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Alcohol'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900014004245', '5900014002562', '5900535013986', '5901359074269', '5901359062013', '5903538900628', '5901359074290', '5900490000182', '5900535015171', '5901359122021', '5900014003569', '5901359144917', '4304493261709', '8712000900045', '1704314830009', '4600721021566')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Harnaś', 'Grocery', 'Alcohol', 'Harnaś jasne pełne', null, null, 'none', '5900014004245'),
  ('PL', 'Karmi', 'Grocery', 'Alcohol', 'Karmi o smaku żurawina', null, null, 'none', '5900014002562'),
  ('PL', 'VAN PUR S.A.', 'Grocery', 'Alcohol', 'Łomża piwo jasne bezalkoholowe', null, null, 'none', '5900535013986'),
  ('PL', 'Velkopopovicky Kozel', 'Grocery', 'Alcohol', 'Polnische Bier (Dose)', null, 'Kaufland,Netto', 'none', '5901359074269'),
  ('PL', 'Tyskie', 'Grocery', 'Alcohol', 'Bier &quot;Tyskie Gronie&quot;', null, 'Real,Kaufland,Getränke Handel,Aral', 'none', '5901359062013'),
  ('PL', 'Lomża', 'Grocery', 'Alcohol', 'Łomża jasne', null, null, 'none', '5903538900628'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Kozel cerny', null, 'Auchan', 'none', '5901359074290'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Premium', null, null, 'none', '5900490000182'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Bière sans alcool', null, 'IN''s', 'none', '5900535015171'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Lech free', null, null, 'none', '5901359122021'),
  ('PL', 'Carlsberg', 'Grocery', 'Alcohol', 'Pilsner 0.0%', null, null, 'none', '5900014003569'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Free Lime Mint', null, null, 'none', '5901359144917'),
  ('PL', 'Christkindl', 'Grocery', 'Alcohol', 'Christkindl Glühwein', null, 'Lidl', 'none', '4304493261709'),
  ('PL', 'Heineken', 'Grocery', 'Alcohol', 'Heineken Beer', null, null, 'none', '8712000900045'),
  ('PL', 'Ikea', 'Grocery', 'Alcohol', 'Glühwein', null, 'Ikea', 'none', '1704314830009'),
  ('PL', 'Hoegaarden', 'Grocery', 'Alcohol', 'Hoegaarden hveteøl, 4,9%', null, null, 'none', '4600721021566')
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
  and product_name not in ('Harnaś jasne pełne', 'Karmi o smaku żurawina', 'Łomża piwo jasne bezalkoholowe', 'Polnische Bier (Dose)', 'Bier &quot;Tyskie Gronie&quot;', 'Łomża jasne', 'Kozel cerny', 'Lech Premium', 'Bière sans alcool', 'Lech free', 'Pilsner 0.0%', 'Lech Free Lime Mint', 'Christkindl Glühwein', 'Heineken Beer', 'Glühwein', 'Hoegaarden hveteøl, 4,9%');

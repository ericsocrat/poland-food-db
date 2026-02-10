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
where ean in ('5900014005716', '5900910010906', '5907069000017', '5901958612367', '5900014004245', '5900535013986', '5900014002562', '5900699106388', '5906340630011', '5903538900628', '5901359074290', '5902709615323', '5901359062013', '5901359074269', '5901359014784', '5900490000182', '5900014005105', '5901359122021', '5900535019209', '5900535015171', '5900699106463', '5900085011180', '5908230514647', '5900014003569', '5901359144917', '5906591002520', '5901359144689', '5905718983308', '4304493261709', '8595588201182', '8712000900045', '4003301069086', '4003301069048', '4600721021566', '1704314830009', '4905846960050', '0085000024683', '3856777584161')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Seth & Riley''s Garage Euphoriq', 'Grocery', 'Alcohol', 'Bezalkoholowy napój piwny o smaku jagód i marakui', 'not-applicable', 'Biedronka', 'none', '5900014005716'),
  ('PL', 'Magnetic', 'Grocery', 'Alcohol', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'not-applicable', 'Biedronka', 'none', '5900910010906'),
  ('PL', 'Diamant', 'Grocery', 'Alcohol', 'Cukier Biały', 'not-applicable', 'Kaufland', 'none', '5907069000017'),
  ('PL', 'owolovo', 'Grocery', 'Alcohol', 'Truskawkowo Mus jabłkowo-truskawkowy', 'not-applicable', 'Biedronka', 'none', '5901958612367'),
  ('PL', 'Harnaś', 'Grocery', 'Alcohol', 'Harnaś jasne pełne', 'not-applicable', null, 'none', '5900014004245'),
  ('PL', 'VAN PUR S.A.', 'Grocery', 'Alcohol', 'Łomża piwo jasne bezalkoholowe', 'not-applicable', null, 'none', '5900535013986'),
  ('PL', 'Karmi', 'Grocery', 'Alcohol', 'Karmi o smaku żurawina', 'not-applicable', null, 'none', '5900014002562'),
  ('PL', 'Żywiec', 'Grocery', 'Alcohol', 'Limonż 0%', 'not-applicable', null, 'none', '5900699106388'),
  ('PL', 'Polski Cukier', 'Grocery', 'Alcohol', 'Cukier biały', 'not-applicable', null, 'none', '5906340630011'),
  ('PL', 'Lomża', 'Grocery', 'Alcohol', 'Łomża jasne', 'not-applicable', null, 'none', '5903538900628'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Kozel cerny', 'not-applicable', 'Auchan', 'none', '5901359074290'),
  ('PL', 'Browar Fortuna', 'Grocery', 'Alcohol', 'Piwo Pilzner, dolnej fermentacji', 'not-applicable', 'Kaufland', 'none', '5902709615323'),
  ('PL', 'Tyskie', 'Grocery', 'Alcohol', 'Bier &quot;Tyskie Gronie&quot;', 'not-applicable', 'Kaufland', 'none', '5901359062013'),
  ('PL', 'Velkopopovicky Kozel', 'Grocery', 'Alcohol', 'Polnische Bier (Dose)', 'not-applicable', 'Kaufland', 'none', '5901359074269'),
  ('PL', 'Książęce', 'Grocery', 'Alcohol', 'Książęce czerwony lager', 'not-applicable', null, 'none', '5901359014784'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Premium', 'not-applicable', null, 'none', '5900490000182'),
  ('PL', 'Zatecky', 'Grocery', 'Alcohol', 'Zatecky 0%', 'not-applicable', null, 'none', '5900014005105'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Lech free', 'not-applicable', null, 'none', '5901359122021'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Radler 0,0%', 'not-applicable', null, 'none', '5900535019209'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Bière sans alcool', 'not-applicable', null, 'none', '5900535015171'),
  ('PL', 'Warka', 'Grocery', 'Alcohol', 'Piwo Warka Radler', 'not-applicable', null, 'none', '5900699106463'),
  ('PL', 'Nestlé', 'Grocery', 'Alcohol', 'Przyprawa Maggi', 'not-applicable', null, 'none', '5900085011180'),
  ('PL', 'Gryzzale', 'Grocery', 'Alcohol', 'polutry kabanos sausages', 'not-applicable', null, 'none', '5908230514647'),
  ('PL', 'Carlsberg', 'Grocery', 'Alcohol', 'Pilsner 0.0%', 'not-applicable', null, 'none', '5900014003569'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Free Lime Mint', 'not-applicable', null, 'none', '5901359144917'),
  ('PL', 'Amber', 'Grocery', 'Alcohol', 'Amber IPA zero', 'not-applicable', null, 'none', '5906591002520'),
  ('PL', 'Unknown', 'Grocery', 'Alcohol', 'LECH FREE CITRUS SOUR', 'not-applicable', null, 'none', '5901359144689'),
  ('PL', 'Shroom', 'Grocery', 'Alcohol', 'Shroom power', 'not-applicable', null, 'none', '5905718983308'),
  ('PL', 'Christkindl', 'Grocery', 'Alcohol', 'Christkindl Glühwein', 'not-applicable', 'Lidl', 'none', '4304493261709'),
  ('PL', 'GO ACTIVE', 'Grocery', 'Alcohol', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'not-applicable', 'Biedronka', 'none', '8595588201182'),
  ('PL', 'Heineken', 'Grocery', 'Alcohol', 'Heineken Beer', 'not-applicable', null, 'none', '8712000900045'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0 White alcoholfree', 'not-applicable', 'Dealz', 'none', '4003301069086'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0. Red', 'not-applicable', 'Dealz', 'none', '4003301069048'),
  ('PL', 'Hoegaarden', 'Grocery', 'Alcohol', 'Hoegaarden hveteøl, 4,9%', 'not-applicable', null, 'none', '4600721021566'),
  ('PL', 'Ikea', 'Grocery', 'Alcohol', 'Glühwein', 'not-applicable', 'Ikea', 'none', '1704314830009'),
  ('PL', 'Choya', 'Grocery', 'Alcohol', 'Silver', 'not-applicable', null, 'none', '4905846960050'),
  ('PL', 'Carlo Rossi', 'Grocery', 'Alcohol', 'Vin carlo rossi', 'not-applicable', null, 'none', '0085000024683'),
  ('PL', 'Somersby', 'Grocery', 'Alcohol', 'Somersby Blueberry Flavoured Cider', 'not-applicable', null, 'none', '3856777584161')
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
  and product_name not in ('Bezalkoholowy napój piwny o smaku jagód i marakui', 'Kakao o obniżonej zawartości tłuszczu ekstra ciemne', 'Cukier Biały', 'Truskawkowo Mus jabłkowo-truskawkowy', 'Harnaś jasne pełne', 'Łomża piwo jasne bezalkoholowe', 'Karmi o smaku żurawina', 'Limonż 0%', 'Cukier biały', 'Łomża jasne', 'Kozel cerny', 'Piwo Pilzner, dolnej fermentacji', 'Bier &quot;Tyskie Gronie&quot;', 'Polnische Bier (Dose)', 'Książęce czerwony lager', 'Lech Premium', 'Zatecky 0%', 'Lech free', 'Radler 0,0%', 'Bière sans alcool', 'Piwo Warka Radler', 'Przyprawa Maggi', 'polutry kabanos sausages', 'Pilsner 0.0%', 'Lech Free Lime Mint', 'Amber IPA zero', 'LECH FREE CITRUS SOUR', 'Shroom power', 'Christkindl Glühwein', 'PUDDING PROTEINOWY SMAK CAFFE LATTE', 'Heineken Beer', 'Just 0 White alcoholfree', 'Just 0. Red', 'Hoegaarden hveteøl, 4,9%', 'Glühwein', 'Silver', 'Vin carlo rossi', 'Somersby Blueberry Flavoured Cider');

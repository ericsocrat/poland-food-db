-- PIPELINE (Alcohol): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Alcohol'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5900014005716', '5900014004245', '5900535013986', '5900014002562', '5900699106388', '5903538900628', '5901359074290', '5902709615323', '5901359074269', '5901359062013', '5901359014784', '5900490000182', '5901359122021', '5900014005105', '5900535019209', '5900535015171', '5900699106463', '5901359144917', '5900014003569', '5906591002520', '5901359144689', '5905718983308', '8712000900045', '4905846960050', '1704314830009', '4003301069086', '4003301069048', '4600721021566', '0085000024683', '3856777584161')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Alcohol by pipeline',
    ean = null
where country = 'PL'
  and category != 'Alcohol'
  and identity_key in ('0357059c97298e01983a1dd7a22f7e7f', '03750d0e213d57365b8e9358c4fa77c3', '0a05d73104e53bffaec8d40f518a8d82', '1405f610b920127a3580e9935c200256', '29b9bb38f5433c6eb444b6f925877fbe', '2c330363e95552a1e16a66345c405f95', '35e59ccc0e796b80b20f328149be47fd', '373e805d885f8712a5cf301f5adf7364', '59d423ea424cdff289c018e82ef4b196', '5e40df66d79e6a7a7f28c4771891024c', '66a1fb41c5f091a7ed27fc1b312ef284', '6906d7896185bc555485f64a2f004140', '72b5be5df2ab09765e2cb5985fb2d7b1', '7635cc879c4842c0a647779b11c5a126', '76ebb22e49e0b5b84af735e9048b5d50', '8abd2c2382fa040d1eab28c372cefa46', '921785706a1a969f020e17061060ddcf', '9642cc638cf372c97eb2ae4ffef0b9e3', '9c24c8e51ca8ccd1b1bf2e54f9643c3a', 'a1c9179e1d507b0f94ba8fee2f7757c6', 'a90964a91dd345130e1869aaa57b6ab2', 'ab1f4b113d2c2608da77bd390d87ea37', 'b83fb7310b930f6fab1ac1024f34e8fa', 'c36ff60fca12de9f00a569564bacee71', 'd018fd58fd5626f6c194580f0b635d91', 'd9bfc7d97741509df4e740b40c57f187', 'de53aa2753ad75253f2f2a46d62c198c', 'e09235dd558122c9f32551b5166dffbd', 'f587872e3468d1acabe55aef7e21bb74', 'f6ab285d3be7beb77c4f4223ac11d8c9')
  and is_deprecated is not true;

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
  ('PL', 'Książęce', 'Grocery', 'Alcohol', 'Książęce czerwony lager', 'not-applicable', null, 'none', '5901359014784'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Premium', 'not-applicable', null, 'none', '5900490000182'),
  ('PL', 'Kompania Piwowarska', 'Grocery', 'Alcohol', 'Lech free', 'not-applicable', null, 'none', '5901359122021'),
  ('PL', 'Zatecky', 'Grocery', 'Alcohol', 'Zatecky 0%', 'not-applicable', null, 'none', '5900014005105'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Radler 0,0%', 'not-applicable', null, 'none', '5900535019209'),
  ('PL', 'Łomża', 'Grocery', 'Alcohol', 'Bière sans alcool', 'not-applicable', null, 'none', '5900535015171'),
  ('PL', 'Warka', 'Grocery', 'Alcohol', 'Piwo Warka Radler', 'not-applicable', null, 'none', '5900699106463'),
  ('PL', 'Lech', 'Grocery', 'Alcohol', 'Lech Free Lime Mint', 'not-applicable', null, 'none', '5901359144917'),
  ('PL', 'Carlsberg', 'Grocery', 'Alcohol', 'Pilsner 0.0%', 'not-applicable', null, 'none', '5900014003569'),
  ('PL', 'Amber', 'Grocery', 'Alcohol', 'Amber IPA zero', 'not-applicable', null, 'none', '5906591002520'),
  ('PL', 'Unknown', 'Grocery', 'Alcohol', 'Lech Free Citrus Sour', 'not-applicable', null, 'none', '5901359144689'),
  ('PL', 'Shroom', 'Grocery', 'Alcohol', 'Shroom power', 'not-applicable', null, 'none', '5905718983308'),
  ('PL', 'Heineken', 'Grocery', 'Alcohol', 'Heineken Beer', 'not-applicable', null, 'none', '8712000900045'),
  ('PL', 'Choya', 'Grocery', 'Alcohol', 'Silver', 'not-applicable', null, 'none', '4905846960050'),
  ('PL', 'Ikea', 'Grocery', 'Alcohol', 'Glühwein', 'not-applicable', 'Ikea', 'none', '1704314830009'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0 White alcoholfree', 'not-applicable', 'Dealz', 'none', '4003301069086'),
  ('PL', 'Just 0.', 'Grocery', 'Alcohol', 'Just 0. Red', 'not-applicable', 'Dealz', 'none', '4003301069048'),
  ('PL', 'Hoegaarden', 'Grocery', 'Alcohol', 'Hoegaarden hveteøl, 4,9%', 'not-applicable', null, 'none', '4600721021566'),
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
  and product_name not in ('Bezalkoholowy napój piwny o smaku jagód i marakui', 'Harnaś jasne pełne', 'Łomża piwo jasne bezalkoholowe', 'Karmi o smaku żurawina', 'Limonż 0%', 'Łomża jasne', 'Kozel cerny', 'Piwo Pilzner, dolnej fermentacji', 'Polnische Bier (Dose)', 'Bier &quot;Tyskie Gronie&quot;', 'Książęce czerwony lager', 'Lech Premium', 'Lech free', 'Zatecky 0%', 'Radler 0,0%', 'Bière sans alcool', 'Piwo Warka Radler', 'Lech Free Lime Mint', 'Pilsner 0.0%', 'Amber IPA zero', 'Lech Free Citrus Sour', 'Shroom power', 'Heineken Beer', 'Silver', 'Glühwein', 'Just 0 White alcoholfree', 'Just 0. Red', 'Hoegaarden hveteøl, 4,9%', 'Vin carlo rossi', 'Somersby Blueberry Flavoured Cider');

-- PIPELINE (Alcohol): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Alcohol'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4072700001126', '4061458002622', '4014964111555', '4014558326839', '4072700005315', '4066600242024', '4082100009097', '4002103000013', '40678337', '4066600251101', '4066600301110', '4082100003552', '4015444000017', '4014964111340', '4012852001698', '40173894', '4005249061702', '4005249000565', '4400066903530', '4004160005338', '4008948027000', '4014086093364', '4082100005044', '4014807204840', '4400065403109', '4000856007129', '4000856003688', '4011900670015', '4082100006508', '4008287056020', '4022396000026', '4014086010361', '4053400208527', '41051825', '4066600641964', '4003310013759', '4002859125800', '4001744024532', '4066600201199', '4072700001188', '4082100006102', '4052197003599', '4304493261709', '4053400271729', '4008287064025', '4103210001297', '9028800638644', '8594403110111', '8594404110110', '42400868', '75033927')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Franziskaner', 'Grocery', 'Alcohol', 'Franziskaner Premium Weissbier Naturtrüb', 'not-applicable', null, 'none', '4072700001126'),
  ('DE', 'Hauser Weinimport', 'Grocery', 'Alcohol', 'Glühwein rot', 'not-applicable', 'Aldi', 'none', '4061458002622'),
  ('DE', 'Köstritzer', 'Grocery', 'Alcohol', 'Köstritzer Schwarzbier', 'not-applicable', null, 'none', '4014964111555'),
  ('DE', 'Hasseröder', 'Grocery', 'Alcohol', 'Hasseröder Premium Pils', 'not-applicable', null, 'none', '4014558326839'),
  ('DE', 'Spaten', 'Grocery', 'Alcohol', 'Münchner Hell', 'not-applicable', null, 'none', '4072700005315'),
  ('DE', 'Paulaner München', 'Grocery', 'Alcohol', 'Weißbier-Zitrone Alkoholfrei', 'not-applicable', null, 'none', '4066600242024'),
  ('DE', 'Mönchshof', 'Grocery', 'Alcohol', 'Mönchshof Kellerbier', 'not-applicable', null, 'none', '4082100009097'),
  ('DE', 'Erdinger', 'Grocery', 'Alcohol', 'Weißbier', 'not-applicable', null, 'none', '4002103000013'),
  ('DE', 'Lübzer', 'Grocery', 'Alcohol', 'Lübzer Pils', 'not-applicable', null, 'none', '40678337'),
  ('DE', 'Paulaner', 'Grocery', 'Alcohol', 'Paulaner Original Münchner Hell', 'not-applicable', null, 'none', '4066600251101'),
  ('DE', 'Paulaner', 'Grocery', 'Alcohol', 'Münchner Hell', 'not-applicable', null, 'none', '4066600301110'),
  ('DE', 'Mönchshof', 'Grocery', 'Alcohol', 'Mönchshof Original Naturtrüb''s Alkoholfrei 4082100003552 Alkoholfreies Schankbier', 'not-applicable', null, 'none', '4082100003552'),
  ('DE', 'Wernesgrüner', 'Grocery', 'Alcohol', 'Wernesgrüner Pils', 'not-applicable', null, 'none', '4015444000017'),
  ('DE', 'Köstritzer', 'Grocery', 'Alcohol', 'Köstritzer Edel Pils', 'not-applicable', null, 'none', '4014964111340'),
  ('DE', 'Neumarkter Lammsbräu', 'Grocery', 'Alcohol', 'Neumarkter Lammsbräu Glutenfrei', 'not-applicable', null, 'none', '4012852001698'),
  ('DE', 'Bayreuther Brauhaus', 'Grocery', 'Alcohol', 'Bayreuther', 'not-applicable', null, 'none', '40173894'),
  ('DE', 'Pülleken', 'Grocery', 'Alcohol', 'Veltins', 'not-applicable', 'Penny', 'none', '4005249061702'),
  ('DE', 'Veltins', 'Grocery', 'Alcohol', 'Bier - Veltins Pilsener', 'not-applicable', null, 'none', '4005249000565'),
  ('DE', 'Rotkäppchen', 'Grocery', 'Alcohol', 'Sekt halbtrocken', 'not-applicable', null, 'none', '4400066903530'),
  ('DE', 'Berliner', 'Grocery', 'Alcohol', 'Berliner Pilsner', 'not-applicable', 'Penny', 'none', '4004160005338'),
  ('DE', 'Jever', 'Grocery', 'Alcohol', 'Jever Pilsener', 'not-applicable', null, 'none', '4008948027000'),
  ('DE', '0 Original', 'Grocery', 'Alcohol', '5,0 Original Pils', 'not-applicable', null, 'none', '4014086093364'),
  ('DE', 'Mönchshof', 'Grocery', 'Alcohol', 'Natur Radler', 'not-applicable', null, 'none', '4082100005044'),
  ('DE', 'Störtebeker', 'Grocery', 'Alcohol', 'Atlantik Ale', 'not-applicable', null, 'none', '4014807204840'),
  ('DE', 'Nordbrand Nordhausen', 'Grocery', 'Alcohol', 'Pfefferminz', 'not-applicable', 'Kaufland', 'none', '4400065403109'),
  ('DE', 'Warsteiner', 'Grocery', 'Alcohol', 'Radler alkoholfrei', 'not-applicable', null, 'none', '4000856007129'),
  ('DE', 'Warsteiner', 'Grocery', 'Alcohol', 'Pilsener', 'not-applicable', 'Kaufland', 'none', '4000856003688'),
  ('DE', 'Mumm', 'Grocery', 'Alcohol', 'Sekt, Jahrgang Dry, alkoholfrei', 'not-applicable', null, 'none', '4011900670015'),
  ('DE', 'Mönchshof', 'Grocery', 'Alcohol', 'Natur Radler 0,0%', 'not-applicable', null, 'none', '4082100006508'),
  ('DE', 'Krombacher', 'Grocery', 'Alcohol', 'Krombacher Pils', 'not-applicable', null, 'none', '4008287056020'),
  ('DE', 'Herzoglich Bayerisches Brauhaus Tegernsee', 'Grocery', 'Alcohol', 'Tegernseer Hell', 'not-applicable', null, 'none', '4022396000026'),
  ('DE', 'Oettinger', 'Grocery', 'Alcohol', 'Pils', 'not-applicable', null, 'none', '4014086010361'),
  ('DE', 'Radeberger', 'Grocery', 'Alcohol', 'Pilsner Alkoholfrei', 'not-applicable', null, 'none', '4053400208527'),
  ('DE', 'Rothaus', 'Grocery', 'Alcohol', 'Tannenzäpfle', 'not-applicable', null, 'none', '41051825'),
  ('DE', 'Gesamt', 'Grocery', 'Alcohol', 'Hefeweissbier hell', 'not-applicable', null, 'none', '4066600641964'),
  ('DE', 'Unknown', 'Grocery', 'Alcohol', 'Wodka Gorbatschow', 'not-applicable', null, 'none', '4003310013759'),
  ('DE', 'Doppio Passo', 'Grocery', 'Alcohol', 'Doppio Passo Rotwein alkoholfrei', 'not-applicable', null, 'none', '4002859125800'),
  ('DE', 'Schloss Wachenheim', 'Grocery', 'Alcohol', 'Light Live Red 0,0%', 'not-applicable', null, 'none', '4001744024532'),
  ('DE', 'Paulaner', 'Grocery', 'Alcohol', 'Natur-Radler', 'not-applicable', null, 'none', '4066600201199'),
  ('DE', 'Franziskaner', 'Grocery', 'Alcohol', 'Premium Weissbier Dunkel', 'not-applicable', 'Carrefour', 'none', '4072700001188'),
  ('DE', 'Mönchshof', 'Grocery', 'Alcohol', 'Radler Blutorange', 'not-applicable', null, 'none', '4082100006102'),
  ('DE', 'Unknown', 'Grocery', 'Alcohol', 'Benediktiner Hell', 'not-applicable', null, 'none', '4052197003599'),
  ('DE', 'Christkindl', 'Grocery', 'Alcohol', 'Christkindl Glühwein', 'not-applicable', 'Lidl', 'none', '4304493261709'),
  ('DE', 'Schöfferhofer', 'Grocery', 'Alcohol', 'Weizen-Mix Grapefruit', 'not-applicable', null, 'none', '4053400271729'),
  ('DE', 'Krombacher', 'Grocery', 'Alcohol', 'Weizen Alkoholfrei', 'not-applicable', null, 'none', '4008287064025'),
  ('DE', 'Allgäuer Brauhaus', 'Grocery', 'Alcohol', 'Büble Bier Edelbräu', 'not-applicable', null, 'none', '4103210001297'),
  ('DE', 'Gösser', 'Grocery', 'Alcohol', 'Natur Radler', 'not-applicable', 'Aldi', 'none', '9028800638644'),
  ('DE', 'Budweiser', 'Grocery', 'Alcohol', 'Budvar', 'not-applicable', 'Kaufland', 'none', '8594403110111'),
  ('DE', 'Unknown', 'Grocery', 'Alcohol', 'Pilsner Urquell', 'not-applicable', 'Penny', 'none', '8594404110110'),
  ('DE', 'Carlsberg', 'Grocery', 'Alcohol', 'Apple Cider', 'not-applicable', null, 'none', '42400868'),
  ('DE', 'Cerveceria Modelio', 'Grocery', 'Alcohol', 'Corona Extra', 'not-applicable', null, 'none', '75033927')
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
where country = 'DE' and category = 'Alcohol'
  and is_deprecated is not true
  and product_name not in ('Franziskaner Premium Weissbier Naturtrüb', 'Glühwein rot', 'Köstritzer Schwarzbier', 'Hasseröder Premium Pils', 'Münchner Hell', 'Weißbier-Zitrone Alkoholfrei', 'Mönchshof Kellerbier', 'Weißbier', 'Lübzer Pils', 'Paulaner Original Münchner Hell', 'Münchner Hell', 'Mönchshof Original Naturtrüb''s Alkoholfrei 4082100003552 Alkoholfreies Schankbier', 'Wernesgrüner Pils', 'Köstritzer Edel Pils', 'Neumarkter Lammsbräu Glutenfrei', 'Bayreuther', 'Veltins', 'Bier - Veltins Pilsener', 'Sekt halbtrocken', 'Berliner Pilsner', 'Jever Pilsener', '5,0 Original Pils', 'Natur Radler', 'Atlantik Ale', 'Pfefferminz', 'Radler alkoholfrei', 'Pilsener', 'Sekt, Jahrgang Dry, alkoholfrei', 'Natur Radler 0,0%', 'Krombacher Pils', 'Tegernseer Hell', 'Pils', 'Pilsner Alkoholfrei', 'Tannenzäpfle', 'Hefeweissbier hell', 'Wodka Gorbatschow', 'Doppio Passo Rotwein alkoholfrei', 'Light Live Red 0,0%', 'Natur-Radler', 'Premium Weissbier Dunkel', 'Radler Blutorange', 'Benediktiner Hell', 'Christkindl Glühwein', 'Weizen-Mix Grapefruit', 'Weizen Alkoholfrei', 'Büble Bier Edelbräu', 'Natur Radler', 'Budvar', 'Pilsner Urquell', 'Apple Cider', 'Corona Extra');

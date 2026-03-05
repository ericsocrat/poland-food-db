-- PIPELINE (Nuts, Seeds & Legumes): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4004980401907', '4004980404007', '4004980400504', '4004980512801', '4061458056618', '4008088919821', '4063367419102', '4004980513006', '4056489150374', '4088500665956', '4008088184038', '4056489105169', '4061458056557', '4061461698263', '4008258107010', '4061458056595', '4008088920018', '4061458056656', '4031446850108', '4088500665963', '4063367143144', '4008088184458', '4004980514003', '4061461229917', '4047247192583', '4004980516809', '4088500658026', '4004980501607', '4063367353499', '4056489694403', '4004980507500', '4004980530508', '4018077004896', '4061461689087', '4008258150092', '4061462369551', '4056489357117', '4061458057813', '4061458140102', '4056489682677', '4047247192637', '4061462602375', '4047247192743', '4061462713910', '4066447615821', '4061462602399', '4047247971287', '4008258130018', '40893532', '4056489018995', '4056489033042')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse geröstet & gesalzen', 'roasted', null, 'none', '4004980401907'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'roasted', 'Aldi', 'none', '4004980404007'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse', 'roasted', null, 'none', '4004980400504'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'EXTRA ROAST Erdnüsse gesalzen', 'roasted', null, 'none', '4004980512801'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashewkerne - geröstet & gesalzen', 'not-applicable', 'Aldi', 'none', '4061458056618'),
  ('DE', 'Maryland', 'Grocery', 'Nuts, Seeds & Legumes', 'Snack Nüsse pur', 'roasted', 'Netto', 'none', '4008088919821'),
  ('DE', 'K-Classic', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse geröstet & gesalzen', 'roasted', 'Kaufland', 'none', '4063367419102'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Ofen Erdnüsse gesalzen', 'not-applicable', 'Kaufland', 'none', '4004980513006'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnusskerne geröstet', 'roasted', 'Lidl', 'none', '4056489150374'),
  ('DE', 'Aldi', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistazien - geröstet & gesalzen', 'roasted', 'Aldi', 'none', '4088500665956'),
  ('DE', 'Maryland', 'Grocery', 'Nuts, Seeds & Legumes', 'Nuss-Kern-Mischung geröstet & gesalzen', 'not-applicable', 'Netto', 'none', '4008088184038'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'XXL Erdnüsse', 'roasted', 'Lidl', 'none', '4056489105169'),
  ('DE', 'Eurofood', 'Grocery', 'Nuts, Seeds & Legumes', 'Macadamia geröstet & gesalzen', 'not-applicable', 'Aldi', 'none', '4061458056557'),
  ('DE', 'Aldi', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse in der Schale, geröstet', 'roasted', 'Aldi', 'none', '4061461698263'),
  ('DE', 'Seeberger', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashew Kerne Nüsse', 'not-applicable', 'Carrefour', 'none', '4008258107010'),
  ('DE', 'August Töpfer', 'Grocery', 'Nuts, Seeds & Legumes', 'Nuss-Mix, geröstet & gesalzen', 'not-applicable', 'Aldi', 'none', '4061458056595'),
  ('DE', 'Maryland', 'Grocery', 'Nuts, Seeds & Legumes', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'not-applicable', 'Penny', 'none', '4008088920018'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashewkerne - pikant gewürzt', 'roasted', 'Aldi', 'none', '4061458056656'),
  ('DE', 'XOX', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse geröstet ohne Salz', 'roasted', 'Netto', 'none', '4031446850108'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistazien - geröstet & ungesalzen', 'roasted', 'Aldi', 'none', '4088500665963'),
  ('DE', 'K-Classic', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse geröstet', 'roasted', 'Kaufland', 'none', '4063367143144'),
  ('DE', 'Maryland', 'Grocery', 'Nuts, Seeds & Legumes', 'Snack Nüsse Honig & Salz', 'not-applicable', 'Netto', 'none', '4008088184458'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse pikant gewürzt', 'not-applicable', null, 'none', '4004980514003'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnusskerne - geröstet und gesalzen', 'roasted', null, 'none', '4061461229917'),
  ('DE', 'Trader Joe''s', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse geröstet und gesalzen', 'roasted', null, 'none', '4047247192583'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Kessel Nüsse Paprika', 'roasted', null, 'none', '4004980516809'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse', 'not-applicable', null, 'none', '4088500658026'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse, geröstet & gesalzen', 'roasted', null, 'none', '4004980501607'),
  ('DE', 'K Classic', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse pikant', 'roasted', null, 'none', '4063367353499'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Spanische Mandeln blanchiert und geröstet', 'not-applicable', null, 'none', '4056489694403'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Erdnüsse ungesalzen', 'roasted', null, 'none', '4004980507500'),
  ('DE', 'Ültje', 'Grocery', 'Nuts, Seeds & Legumes', 'Mandeln & Erdnüsse Honig und Salz', 'not-applicable', null, 'none', '4004980530508'),
  ('DE', 'Lorenz', 'Grocery', 'Nuts, Seeds & Legumes', 'NicNacs', 'roasted', null, 'none', '4018077004896'),
  ('DE', 'Farmer Naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Walnusskerne naturbelassen', 'not-applicable', 'Aldi', 'none', '4061461689087'),
  ('DE', 'Seeberger', 'Grocery', 'Nuts, Seeds & Legumes', 'Nusskernmischung', 'not-applicable', 'Kaufland', 'none', '4008258150092'),
  ('DE', 'Fazer naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Feinste Nuss-Variation, naturbelassen', 'not-applicable', 'Aldi', 'none', '4061462369551'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Mix Proteína Frutos Secos Y Soja', 'not-applicable', 'Lidl', 'none', '4056489357117'),
  ('DE', 'Farmer Naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashewkerne naturbelassen', 'not-applicable', 'Aldi', 'none', '4061458057813'),
  ('DE', 'Farmer Naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Premium-Nussmix - Fein mit Pekannusskernen', 'not-applicable', 'Aldi', 'none', '4061458140102'),
  ('DE', 'Alesto Selection', 'Grocery', 'Nuts, Seeds & Legumes', 'Pecan Nuts natural', 'not-applicable', 'Lidl', 'none', '4056489682677'),
  ('DE', 'Trader Joe''s', 'Grocery', 'Nuts, Seeds & Legumes', 'Walnusskerne naturbelassen', 'not-applicable', 'Aldi', 'none', '4047247192637'),
  ('DE', 'Farmer Naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Simply Roasted - Cashewkerne', 'roasted', 'Aldi', 'none', '4061462602375'),
  ('DE', 'Trader Joe''s', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashewkerne, naturbelassen', 'not-applicable', 'Aldi', 'none', '4047247192743'),
  ('DE', 'Farmer', 'Grocery', 'Nuts, Seeds & Legumes', 'Trail-Mix Kerne', 'dried', 'Aldi', 'none', '4061462713910'),
  ('DE', 'DmBio', 'Grocery', 'Nuts, Seeds & Legumes', 'Mandeln ganze Kerne', 'not-applicable', null, 'none', '4066447615821'),
  ('DE', 'Farmer Naturals', 'Grocery', 'Nuts, Seeds & Legumes', 'Simply Roasted - Nussmischung', 'roasted', 'Aldi', 'none', '4061462602399'),
  ('DE', 'Trader joes', 'Grocery', 'Nuts, Seeds & Legumes', 'Pistachio mix', 'not-applicable', 'Aldi', 'none', '4047247971287'),
  ('DE', 'Seeberger', 'Grocery', 'Nuts, Seeds & Legumes', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 'not-applicable', 'Carrefour', 'none', '4008258130018'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Cashew Nuts XXL', 'not-applicable', 'Lidl', 'none', '40893532'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Mandeln Honig & Salz', 'not-applicable', 'Lidl', 'none', '4056489018995'),
  ('DE', 'Alesto', 'Grocery', 'Nuts, Seeds & Legumes', 'Noisettes grillées', 'roasted', 'Lidl', 'none', '4056489033042')
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
where country = 'DE' and category = 'Nuts, Seeds & Legumes'
  and is_deprecated is not true
  and product_name not in ('Erdnüsse geröstet & gesalzen', 'Ültje Erdnüsse geröstet & ungesalzen 180g 2,49€ 13,83€ 1kg', 'Erdnüsse', 'EXTRA ROAST Erdnüsse gesalzen', 'Cashewkerne - geröstet & gesalzen', 'Snack Nüsse pur', 'Erdnüsse geröstet & gesalzen', 'Ofen Erdnüsse gesalzen', 'Erdnusskerne geröstet', 'Pistazien - geröstet & gesalzen', 'Nuss-Kern-Mischung geröstet & gesalzen', 'XXL Erdnüsse', 'Macadamia geröstet & gesalzen', 'Erdnüsse in der Schale, geröstet', 'Cashew Kerne Nüsse', 'Nuss-Mix, geröstet & gesalzen', 'Studentenfutter Berry mit Cranberries & Walnüssen', 'Cashewkerne - pikant gewürzt', 'Erdnüsse geröstet ohne Salz', 'Pistazien - geröstet & ungesalzen', 'Erdnüsse geröstet', 'Snack Nüsse Honig & Salz', 'Erdnüsse pikant gewürzt', 'Erdnusskerne - geröstet und gesalzen', 'Erdnüsse geröstet und gesalzen', 'Kessel Nüsse Paprika', 'Erdnüsse', 'Erdnüsse, geröstet & gesalzen', 'Erdnüsse pikant', 'Spanische Mandeln blanchiert und geröstet', 'Erdnüsse ungesalzen', 'Mandeln & Erdnüsse Honig und Salz', 'NicNacs', 'Walnusskerne naturbelassen', 'Nusskernmischung', 'Feinste Nuss-Variation, naturbelassen', 'Mix Proteína Frutos Secos Y Soja', 'Cashewkerne naturbelassen', 'Premium-Nussmix - Fein mit Pekannusskernen', 'Pecan Nuts natural', 'Walnusskerne naturbelassen', 'Simply Roasted - Cashewkerne', 'Cashewkerne, naturbelassen', 'Trail-Mix Kerne', 'Mandeln ganze Kerne', 'Simply Roasted - Nussmischung', 'Pistachio mix', 'Seeberger Walnusskerne 4008258130018 Walnusskerne', 'Cashew Nuts XXL', 'Mandeln Honig & Salz', 'Noisettes grillées');

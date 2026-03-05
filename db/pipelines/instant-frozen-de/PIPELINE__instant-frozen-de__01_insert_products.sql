-- PIPELINE (Instant & Frozen): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Instant & Frozen'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4019339646052', '4056489915287', '4061462956621', '4061461867683', '4061463779526', '4019339646014', '4061458055352', '4061462213427', '4061462213441', '4068706482878', '4061459672770', '4061462213090', '4047247979535', '4061463779533', '4061461337292', '4061462213403', '4061463779632', '4061461060251', '4023900545446', '4016810470106', '8712566332137', '4019339646113', '4056489915263', '4019339646007', '4013200880910', '4061464906334', '4820179258561', '8801073116467', '8852018101154', '8801043022705', '7613037683660', '8720182777294', '7613036680028', '8720182777225', '8801073113428', '7613037683417', '5997523313272', '8801043157728', '5997523315832', '7613035897427', '8852523206184', '8720182406354', '7613031722594', '8994963003173', '7613036679978', '8852018511069', '5901384504731', '7613037683608', '8801043031011', '5997523313234', '8714100679852')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Davert', 'Grocery', 'Instant & Frozen', 'Noodle Cup - Thailändisch', 'dried', null, 'none', '4019339646052'),
  ('DE', 'Kania', 'Grocery', 'Instant & Frozen', 'Instant Nudeln Gemüse Geschmack', 'dried', 'Lidl', 'none', '4056489915287'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Instantnudeln Hühnergeschmack 5er-Pack', 'dried', 'Aldi', 'none', '4061462956621'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Udon-Nudeln mit Soja-Ingwer-Soße', 'dried', 'Aldi', 'none', '4061461867683'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Bratnudeln - Thailändische Art', 'dried', 'Aldi', 'none', '4061463779526'),
  ('DE', 'Davert', 'Grocery', 'Instant & Frozen', 'Noodle Brokkoli Käse Sauce', 'dried', null, 'none', '4019339646014'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Instant Nudeln Gemüsegeschmack', 'dried', null, 'none', '4061458055352'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Instant-Reisnudeln mit Hühnerfleischgeschmack', 'dried', null, 'none', '4061462213427'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Pho Chat Instant-Reisnudeln mit Gemüsegeschmack', 'dried', null, 'none', '4061462213441'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Udon-Nudel-Bowl mit Sauce nach Kimchi Art Gewürzt', 'dried', null, 'none', '4068706482878'),
  ('DE', 'Aldi', 'Grocery', 'Instant & Frozen', 'Green Curry Noodles / Grüne Curry Nudeln', 'dried', null, 'none', '4061459672770'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Instant-Nudeln Beef', 'dried', 'Aldi', 'none', '4061462213090'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Udon Noodle Bowl', 'dried', 'Aldi', 'none', '4047247979535'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Bratnudeln - Entengeschmack', 'dried', 'Aldi', 'none', '4061463779533'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 'dried', 'Aldi', 'none', '4061461337292'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 'dried', null, 'none', '4061462213403'),
  ('DE', 'Asia Green Garden', 'Grocery', 'Instant & Frozen', 'Bratnudeln - Chili', 'dried', 'Aldi', 'none', '4061463779632'),
  ('DE', 'Unknown', 'Grocery', 'Instant & Frozen', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 'dried', 'Aldi', 'none', '4061461060251'),
  ('DE', 'Bamboo Garden', 'Grocery', 'Instant & Frozen', 'Mie Nudeln', 'dried', null, 'none', '4023900545446'),
  ('DE', 'Nissin', 'Grocery', 'Instant & Frozen', 'Thai Roasted Chicken', 'roasted', null, 'palm oil', '4016810470106'),
  ('DE', 'Knorr', 'Grocery', 'Instant & Frozen', 'Hühnersuppe', 'dried', null, 'none', '8712566332137'),
  ('DE', 'Davert', 'Grocery', 'Instant & Frozen', 'Noodle Cup No. 11 Linsen Bolognese', 'dried', null, 'none', '4019339646113'),
  ('DE', 'Kania', 'Grocery', 'Instant & Frozen', 'Instant Nudeln Rind', 'dried', null, 'none', '4056489915263'),
  ('DE', 'Davert', 'Grocery', 'Instant & Frozen', 'Noodle Cup No. 7', 'dried', null, 'none', '4019339646007'),
  ('DE', 'Lien Ying Asian-Spirit', 'Grocery', 'Instant & Frozen', 'Eier-Mie-Nudeln', 'dried', null, 'none', '4013200880910'),
  ('DE', 'Aldi', 'Grocery', 'Instant & Frozen', 'Asia-Instant-Noodles-Cup - Curry', 'dried', null, 'none', '4061464906334'),
  ('DE', 'Reeva', 'Grocery', 'Instant & Frozen', 'Instant Nudeln gebratenes Hähnchen', 'dried', null, 'none', '4820179258561'),
  ('DE', 'Buldak', 'Grocery', 'Instant & Frozen', 'Buldak HOT Chicken Flavour Ramen', 'dried', 'Lidl', 'none', '8801073116467'),
  ('DE', 'Yum Yum', 'Grocery', 'Instant & Frozen', 'Instant Nudeln, Japanese Chicken Flavor', 'dried', null, 'none', '8852018101154'),
  ('DE', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Soon Veggie Ramyun Noodle', 'dried', 'Carrefour', 'palm oil', '8801043022705'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Saucy Noodles Teriyaki', 'dried', 'Kaufland', 'none', '7613037683660'),
  ('DE', 'Knorr', 'Grocery', 'Instant & Frozen', 'Asia Noodels Beef Taste', 'dried', 'Netto', 'none', '8720182777294'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Noodle Cup - Chicken Taste', 'dried', null, 'none', '7613036680028'),
  ('DE', 'Knorr', 'Grocery', 'Instant & Frozen', 'Asia Noodles Chicken Taste', 'dried', 'Netto', 'none', '8720182777225'),
  ('DE', 'Buldak', 'Grocery', 'Instant & Frozen', 'Buldak 2x Spicy', 'dried', 'Netto', 'palm oil', '8801073113428'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Saucy Noodles Sesame Chicken Taste', 'dried', 'Penny', 'none', '7613037683417'),
  ('DE', 'Nissin', 'Grocery', 'Instant & Frozen', 'Soba Cup Noodles', 'dried', null, 'none', '5997523313272'),
  ('DE', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Nouilles Chapaghetti Nongshim', 'dried', null, 'palm oil', '8801043157728'),
  ('DE', 'Nissin', 'Grocery', 'Instant & Frozen', 'Cup Noodles Big Soba Wok Style', 'dried', 'Kaufland', 'palm oil', '5997523315832'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Gebratene Nudeln Ente', 'dried', null, 'none', '7613035897427'),
  ('DE', 'Thai Chef', 'Grocery', 'Instant & Frozen', 'Thaisuppe, Curry Huhn', 'dried', null, 'none', '8852523206184'),
  ('DE', 'Knorr', 'Grocery', 'Instant & Frozen', 'Spaghetteria Spinaci', 'dried', 'Penny', 'none', '8720182406354'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'dried', 'Kaufland', 'none', '7613031722594'),
  ('DE', 'Indomie', 'Grocery', 'Instant & Frozen', 'Noodles', 'dried', 'Lidl', 'none', '8994963003173'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Asia Noodle Cup Duck', 'dried', null, 'none', '7613036679978'),
  ('DE', 'Yum Yum', 'Grocery', 'Instant & Frozen', 'Nouilles instantanées au goût de légumes, pack de 5', 'dried', 'Lidl', 'palm oil', '8852018511069'),
  ('DE', 'Ajinomoto', 'Grocery', 'Instant & Frozen', 'Pork Ramen', 'dried', null, 'palm oil', '5901384504731'),
  ('DE', 'Maggi', 'Grocery', 'Instant & Frozen', 'Saucy Noodles Sweet Chili', 'dried', null, 'none', '7613037683608'),
  ('DE', 'Nongshim', 'Grocery', 'Instant & Frozen', 'Shin Cup Gourmet Spicy Noodle Soup', 'dried', null, 'palm oil', '8801043031011'),
  ('DE', 'Nissin', 'Grocery', 'Instant & Frozen', 'Soba Yakitori Chicken', 'dried', null, 'none', '5997523313234'),
  ('DE', 'Knorr', 'Grocery', 'Instant & Frozen', 'Asia Noodles Currygeschmack', 'dried', 'Netto', 'none', '8714100679852')
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
where country = 'DE' and category = 'Instant & Frozen'
  and is_deprecated is not true
  and product_name not in ('Noodle Cup - Thailändisch', 'Instant Nudeln Gemüse Geschmack', 'Instantnudeln Hühnergeschmack 5er-Pack', 'Udon-Nudeln mit Soja-Ingwer-Soße', 'Bratnudeln - Thailändische Art', 'Noodle Brokkoli Käse Sauce', 'Instant Nudeln Gemüsegeschmack', 'Instant-Reisnudeln mit Hühnerfleischgeschmack', 'Pho Chat Instant-Reisnudeln mit Gemüsegeschmack', 'Udon-Nudel-Bowl mit Sauce nach Kimchi Art Gewürzt', 'Green Curry Noodles / Grüne Curry Nudeln', 'Instant-Nudeln Beef', 'Udon Noodle Bowl', 'Bratnudeln - Entengeschmack', 'Instant-Nudel-Cup 3er-Pack - Teriyaki-Geschmack – Asia Green Garden', 'Phò Bò (Reisnudel-Suppe mit Rindfleischgeschmack)', 'Bratnudeln - Chili', 'Feurige Ramen Nudeln Spicy Hot Chicken Korean Style', 'Mie Nudeln', 'Thai Roasted Chicken', 'Hühnersuppe', 'Noodle Cup No. 11 Linsen Bolognese', 'Instant Nudeln Rind', 'Noodle Cup No. 7', 'Eier-Mie-Nudeln', 'Asia-Instant-Noodles-Cup - Curry', 'Instant Nudeln gebratenes Hähnchen', 'Buldak HOT Chicken Flavour Ramen', 'Instant Nudeln, Japanese Chicken Flavor', 'Soon Veggie Ramyun Noodle', 'Saucy Noodles Teriyaki', 'Asia Noodels Beef Taste', 'Noodle Cup - Chicken Taste', 'Asia Noodles Chicken Taste', 'Buldak 2x Spicy', 'Saucy Noodles Sesame Chicken Taste', 'Soba Cup Noodles', 'Nouilles Chapaghetti Nongshim', 'Cup Noodles Big Soba Wok Style', 'Gebratene Nudeln Ente', 'Thaisuppe, Curry Huhn', 'Spaghetteria Spinaci', 'Magic Asia - Gebratene Nudeln Thai-Curry', 'Noodles', 'Asia Noodle Cup Duck', 'Nouilles instantanées au goût de légumes, pack de 5', 'Pork Ramen', 'Saucy Noodles Sweet Chili', 'Shin Cup Gourmet Spicy Noodle Soup', 'Soba Yakitori Chicken', 'Asia Noodles Currygeschmack');

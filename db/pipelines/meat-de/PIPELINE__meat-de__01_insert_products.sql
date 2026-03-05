-- PIPELINE (Meat): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Meat'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000582370597', '4008366008704', '4061458015219', '4061461786533', '4061459187557', '4061458015851', '4061458014410', '4061458016377', '4061458013024', '4061458014458', '4061458015035', '4056489205234', '4003419025790', '4006153116007', '4000405002605', '4061458016315', '4002993071100', '4061458015905', '4003171003692', '4006639070397', '4006229015579', '4061458131315', '4003171096175', '4000503148502', '4056489640158', '4006229019041', '4061458041232', '4006229710214', '4003171047146', '4000503148601', '4056489619642', '4061458010627', '4000582309290', '4003171020088', '4018703070479', '4008460266741', '4000503102306', '4003171020057', '4000582185290', '4061458015516', '4000582185498', '4000582309993', '4000930585048', '4061458012973', '4061458016568', '4063761540068', '4063367225079', '4000582185399', '4009337779333', '4000503280004', '4006229690219')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Herta', 'Grocery', 'Meat', 'Hähnchenbrust', 'not-applicable', null, 'none', '4000582370597'),
  ('DE', 'Frosta', 'Grocery', 'Meat', 'Hähnchen Paella', 'not-applicable', 'Kaufland', 'none', '4008366008704'),
  ('DE', 'Gut Drei Eichen', 'Grocery', 'Meat', 'Herzhafte Edelsalami, geräuchert', 'not-applicable', 'Aldi', 'none', '4061458015219'),
  ('DE', 'Güldenhof', 'Grocery', 'Meat', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 'not-applicable', 'Aldi', 'none', '4061461786533'),
  ('DE', 'Allfein Feinkost', 'Grocery', 'Meat', 'Hähnchen-Knusper-Dinos', 'not-applicable', 'Aldi', 'none', '4061459187557'),
  ('DE', 'Güldenhof', 'Grocery', 'Meat', 'Mini-Wiener - Geflügel', 'not-applicable', 'Aldi', 'none', '4061458015851'),
  ('DE', 'Güldenhof', 'Grocery', 'Meat', 'Geflügel-Paprikalyoner', 'not-applicable', 'Aldi', 'none', '4061458014410'),
  ('DE', 'Adler Schwarzwald', 'Grocery', 'Meat', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 'smoked', 'Aldi', 'none', '4061458016377'),
  ('DE', 'Bio', 'Grocery', 'Meat', 'Bio-Salami - geräuchert mit grünem Pfeffer', 'not-applicable', 'Aldi', 'none', '4061458013024'),
  ('DE', 'Güldenhof', 'Grocery', 'Meat', 'Geflügel-Mortadella', 'not-applicable', 'Aldi', 'none', '4061458014458'),
  ('DE', 'Böklunder', 'Grocery', 'Meat', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 'not-applicable', 'Aldi', 'none', '4061458015035'),
  ('DE', 'Dulano', 'Grocery', 'Meat', 'Geflügel Wiener', 'not-applicable', 'Lidl', 'none', '4056489205234'),
  ('DE', 'Familie Wein', 'Grocery', 'Meat', 'Schwarzwälder Schinken', 'smoked', 'Netto', 'none', '4003419025790'),
  ('DE', 'Zimmermann', 'Grocery', 'Meat', 'Weißwurst', 'not-applicable', null, 'none', '4006153116007'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Meat', 'Mühlen Frikadellen 100% Geflügel', 'not-applicable', 'Kaufland', 'none', '4000405002605'),
  ('DE', 'Gut Drei Eichen', 'Grocery', 'Meat', 'Katenschinken-Würfel', 'not-applicable', 'Aldi', 'none', '4061458016315'),
  ('DE', 'Bernard Matthews Oldenburg', 'Grocery', 'Meat', 'Hähnchen Filetstreifen', 'not-applicable', null, 'none', '4002993071100'),
  ('DE', 'Gut Drei Eichen', 'Grocery', 'Meat', 'Münchner Weißwurst', 'not-applicable', 'Aldi', 'none', '4061458015905'),
  ('DE', 'Gutfried', 'Grocery', 'Meat', 'Geflügelwurst', 'not-applicable', null, 'none', '4003171003692'),
  ('DE', 'Ferdi Fuchs', 'Grocery', 'Meat', 'Wurst Ferdi Fuchs Mini Würstschen', 'not-applicable', null, 'none', '4006639070397'),
  ('DE', 'Reinert', 'Grocery', 'Meat', 'Bärchenwurst', 'not-applicable', null, 'none', '4006229015579'),
  ('DE', 'Meine Metzgerei', 'Grocery', 'Meat', 'Puten-Hackfleisch Frisch; gewürzt; zum Braten Aus der Frischetruhe Dauertiefpreis 2.49€ 400g Packung 1kg 6.23€', 'not-applicable', null, 'none', '4061458131315'),
  ('DE', 'Gutfried', 'Grocery', 'Meat', 'Hähnchenbrust', 'not-applicable', null, 'none', '4003171096175'),
  ('DE', 'Meica', 'Grocery', 'Meat', 'Geflügelwürstchen', 'not-applicable', null, 'none', '4000503148502'),
  ('DE', 'Dulano', 'Grocery', 'Meat', 'Delikatess Hähnchenbrust', 'not-applicable', null, 'none', '4056489640158'),
  ('DE', 'Reinert', 'Grocery', 'Meat', 'Bärchen SchlaWiener', 'not-applicable', null, 'none', '4006229019041'),
  ('DE', 'Sprehe Feinkost', 'Grocery', 'Meat', 'Hähnchen-Brustfiletstreifen', 'not-applicable', null, 'none', '4061458041232'),
  ('DE', 'Reinert', 'Grocery', 'Meat', 'Bärchen-Wurst', 'not-applicable', null, 'none', '4006229710214'),
  ('DE', 'Gutfried', 'Grocery', 'Meat', 'Gutfried - Hähnchen-Salami', 'not-applicable', null, 'none', '4003171047146'),
  ('DE', 'Meica', 'Grocery', 'Meat', 'Meica Geflügel-Wiener 4000503148601 Geflügel-Wiener im Saitling', 'not-applicable', null, 'none', '4000503148601'),
  ('DE', 'Dulano', 'Grocery', 'Meat', 'Wurst - Geflügel-Leberwurst', 'not-applicable', null, 'none', '4056489619642'),
  ('DE', 'Aldi Meine Metzgerei', 'Grocery', 'Meat', 'Hähnchenbrust', 'raw', null, 'none', '4061458010627'),
  ('DE', 'Herta', 'Grocery', 'Meat', 'FARMERSCHINKEN mit Honig verfeinert und über Buchenholz geräuchert, gegart', 'not-applicable', null, 'none', '4000582309290'),
  ('DE', 'Gutfried', 'Grocery', 'Meat', 'Hähnchenbrust Kirschpaprika', 'not-applicable', null, 'none', '4003171020088'),
  ('DE', 'Kupfer', 'Grocery', 'Meat', 'Original Nürnberger Rostbratwürste', 'not-applicable', null, 'none', '4018703070479'),
  ('DE', 'Kamar', 'Grocery', 'Meat', 'Geflügelbratwurst', 'not-applicable', null, 'none', '4008460266741'),
  ('DE', 'Meica', 'Grocery', 'Meat', 'Zutat: Würstchen - Wiener Art', 'not-applicable', null, 'none', '4000503102306'),
  ('DE', 'Gutfried', 'Grocery', 'Meat', 'Hähnchenbrust, gepökelt und gebraten', 'not-applicable', null, 'none', '4003171020057'),
  ('DE', 'Herta', 'Grocery', 'Meat', 'Schinken', 'not-applicable', 'Lidl', 'none', '4000582185290'),
  ('DE', 'Gut Drei Eichen', 'Grocery', 'Meat', 'Schinken-Lyoner', 'not-applicable', 'Aldi', 'none', '4061458015516'),
  ('DE', 'Herta', 'Grocery', 'Meat', 'Schinken gegart ofengegrillt', 'not-applicable', null, 'none', '4000582185498'),
  ('DE', 'Nestlé', 'Grocery', 'Meat', 'Saftschinken', 'not-applicable', null, 'none', '4000582309993'),
  ('DE', 'Ponnath Die Meistermetzger', 'Grocery', 'Meat', 'Delikatess Prosciutto Cotto', 'not-applicable', null, 'none', '4000930585048'),
  ('DE', 'Bio', 'Grocery', 'Meat', 'Bio-Salami - luftgetrocknet', 'not-applicable', 'Aldi', 'none', '4061458012973'),
  ('DE', 'Abraham', 'Grocery', 'Meat', 'Jamón Serrano Schinken', 'dried', 'Aldi', 'none', '4061458016568'),
  ('DE', 'Zimbo', 'Grocery', 'Meat', 'Schinken Zwiebelmettwurst fettreduziert', 'not-applicable', null, 'none', '4063761540068'),
  ('DE', 'K-Classic', 'Grocery', 'Meat', 'Kochhinterschinken', 'not-applicable', 'Kaufland', 'none', '4063367225079'),
  ('DE', 'Herta', 'Grocery', 'Meat', 'Schinken Belem Pfeffer', 'not-applicable', 'Lidl', 'none', '4000582185399'),
  ('DE', 'Steinhaus', 'Grocery', 'Meat', 'Bergische Salami', 'not-applicable', null, 'none', '4009337779333'),
  ('DE', 'Meica', 'Grocery', 'Meat', 'Curryking fix & fertig', 'not-applicable', null, 'none', '4000503280004'),
  ('DE', 'Reinert', 'Grocery', 'Meat', 'Schinken Nuggets', 'not-applicable', null, 'none', '4006229690219')
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
where country = 'DE' and category = 'Meat'
  and is_deprecated is not true
  and product_name not in ('Hähnchenbrust', 'Hähnchen Paella', 'Herzhafte Edelsalami, geräuchert', 'Mini-Hähnchenbrust-Filetstücke - Klassik', 'Hähnchen-Knusper-Dinos', 'Mini-Wiener - Geflügel', 'Geflügel-Paprikalyoner', 'ALDI GUT DREI EICHEN Schwarzwälder Schinken Aus der Kühlung 2.65€ 200g Packung 1kg 13.25€', 'Bio-Salami - geräuchert mit grünem Pfeffer', 'Geflügel-Mortadella', 'ALDI Güldenhof Huhn Hähnchen-Mortadella 140g 1kg', 'Geflügel Wiener', 'Schwarzwälder Schinken', 'Weißwurst', 'Mühlen Frikadellen 100% Geflügel', 'Katenschinken-Würfel', 'Hähnchen Filetstreifen', 'Münchner Weißwurst', 'Geflügelwurst', 'Wurst Ferdi Fuchs Mini Würstschen', 'Bärchenwurst', 'Puten-Hackfleisch Frisch; gewürzt; zum Braten Aus der Frischetruhe Dauertiefpreis 2.49€ 400g Packung 1kg 6.23€', 'Hähnchenbrust', 'Geflügelwürstchen', 'Delikatess Hähnchenbrust', 'Bärchen SchlaWiener', 'Hähnchen-Brustfiletstreifen', 'Bärchen-Wurst', 'Gutfried - Hähnchen-Salami', 'Meica Geflügel-Wiener 4000503148601 Geflügel-Wiener im Saitling', 'Wurst - Geflügel-Leberwurst', 'Hähnchenbrust', 'FARMERSCHINKEN mit Honig verfeinert und über Buchenholz geräuchert, gegart', 'Hähnchenbrust Kirschpaprika', 'Original Nürnberger Rostbratwürste', 'Geflügelbratwurst', 'Zutat: Würstchen - Wiener Art', 'Hähnchenbrust, gepökelt und gebraten', 'Schinken', 'Schinken-Lyoner', 'Schinken gegart ofengegrillt', 'Saftschinken', 'Delikatess Prosciutto Cotto', 'Bio-Salami - luftgetrocknet', 'Jamón Serrano Schinken', 'Schinken Zwiebelmettwurst fettreduziert', 'Kochhinterschinken', 'Schinken Belem Pfeffer', 'Bergische Salami', 'Curryking fix & fertig', 'Schinken Nuggets');

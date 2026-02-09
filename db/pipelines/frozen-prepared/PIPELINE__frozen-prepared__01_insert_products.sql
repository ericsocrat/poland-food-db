-- PIPELINE (Frozen & Prepared): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-02-08

-- 0. DEPRECATE old products & release their EANs
update products
set is_deprecated = true, ean = null
where country = 'PL'
  and category = 'Frozen & Prepared'
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Dr. Oetker', 'Grocery', 'Frozen & Prepared', 'Pizza 4 sery, głęboko mrożona.', null, 'Tesco', 'none', '5900437007137'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Frozen & Prepared', 'Ratatouille', null, 'carrefour,carrefour.fr', 'none', '3270190174356'),
  ('PL', 'Vitasia', 'Grocery', 'Frozen & Prepared', 'soba noodles', null, 'Lidl', 'none', '20561864'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Frozen & Prepared', 'Riz Sans sucres ajoutés**', null, 'Carrefour,Carrefour Market,carrefour.fr', 'none', '3245411573669'),
  ('PL', 'Gelatelli', 'Grocery', 'Frozen & Prepared', 'Gelatelli Chocolate', null, 'LIDL', 'none', '4056489238614'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Premium Bourbon - Dairy ice cream', null, 'Lidl', 'none', '40875125'),
  ('PL', 'Gelatelli', 'Grocery', 'Frozen & Prepared', 'High Protein Salted Caramel Ice Cream', null, 'Lidl', 'none', '4056489238607'),
  ('PL', 'Bonduelle', 'Grocery', 'Frozen & Prepared', 'Epinards Feuilles Préservées 750g', null, 'Franprix, carrefour.fr', 'none', '3083680836371'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Salted caramel premium ice cream', null, 'Lidl', 'none', '20707330'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen & Prepared', 'Poisson pané', null, 'Carrefour,carrefour.fr', 'none', '3560071019228'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Frozen & Prepared', 'PIZZA Chèvre Cuite au feu de bois', null, 'Carrefour,Carrefour Bio, carrefour.fr', 'none', '3560070590728'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Walnut Bon Gelati', null, 'Lidl', 'none', '20086091'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Frozen & Prepared', 'Galettes de riz chocolat au lait', null, 'Carrefour', 'none', '3560071469740'),
  ('PL', 'Italiamo', 'Grocery', 'Frozen & Prepared', 'Pizza Prosciutto e Mozzarella', null, 'LIDL', 'none', '20490706'),
  ('PL', 'Gelatelli', 'Grocery', 'Frozen & Prepared', 'High protein cookies & cream', null, 'LIDL', 'none', '4056489238621'),
  ('PL', 'Freshona', 'Grocery', 'Frozen & Prepared', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', null, 'Lidl', 'none', '4056489359593'),
  ('PL', 'Harrys', 'Grocery', 'Frozen & Prepared', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', null, 'Carrefour', 'none', '3228857001934'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Bon Gelati Eiscreme mit Schlagsahne', null, 'Lidl', 'none', '20001407'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen & Prepared', 'Pain au Chocolat', null, 'Carrefour,carrefour.fr', 'none', '3560070343362'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen & Prepared', 'Spaghetti', null, 'Carrefour, carrefour.fr', 'none', '3560071016869'),
  ('PL', 'Magnum', 'Grocery', 'Frozen & Prepared', 'Magnum Crème Glacée en Pot Amande 440ml', null, 'Żabka,Hofer', 'none', '8714100289983'),
  ('PL', 'Gelatelli', 'Grocery', 'Frozen & Prepared', 'Creme al pistacchio', null, 'Lidl', 'none', '20219895'),
  ('PL', 'Nixe', 'Grocery', 'Frozen & Prepared', 'Weisser Thunfish Alalunga', null, 'Lidl', 'none', '20916947'),
  ('PL', 'Mars', 'Grocery', 'Frozen & Prepared', 'Snickers ice cream', null, 'Żabka', 'none', '5000159515481'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Stracciatella Premium Eis', null, 'Lidl', 'none', '20001360'),
  ('PL', 'Bon Gelati', 'Grocery', 'Frozen & Prepared', 'Glace Erdbeer Strawberry ice cream premium', null, 'Lidl', 'none', '20059903'),
  ('PL', 'Simpl', 'Grocery', 'Frozen & Prepared', 'Tranches de filets de Colin d''Alaska', null, 'Carrefour,carrefour.fr', 'none', '3560070529636'),
  ('PL', 'Carrefour', 'Grocery', 'Frozen & Prepared', 'Cônes parfum vanille', null, 'Carrefour,carrefour.fr', 'none', '3560070774265')
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
where country = 'PL' and category = 'Frozen & Prepared'
  and is_deprecated is not true
  and product_name not in ('Pizza 4 sery, głęboko mrożona.', 'Ratatouille', 'soba noodles', 'Riz Sans sucres ajoutés**', 'Gelatelli Chocolate', 'Premium Bourbon - Dairy ice cream', 'High Protein Salted Caramel Ice Cream', 'Epinards Feuilles Préservées 750g', 'Salted caramel premium ice cream', 'Poisson pané', 'PIZZA Chèvre Cuite au feu de bois', 'Walnut Bon Gelati', 'Galettes de riz chocolat au lait', 'Pizza Prosciutto e Mozzarella', 'High protein cookies & cream', 'Vegetable Mix with Bamboo Shoots and Mun Mushrooms', 'Brioche Tranchée Noix de Coco, Chocolat au Lait', 'Bon Gelati Eiscreme mit Schlagsahne', 'Pain au Chocolat', 'Spaghetti', 'Magnum Crème Glacée en Pot Amande 440ml', 'Creme al pistacchio', 'Weisser Thunfish Alalunga', 'Snickers ice cream', 'Stracciatella Premium Eis', 'Glace Erdbeer Strawberry ice cream premium', 'Tranches de filets de Colin d''Alaska', 'Cônes parfum vanille');

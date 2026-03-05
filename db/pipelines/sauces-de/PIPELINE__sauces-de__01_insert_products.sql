-- PIPELINE (Sauces): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-04

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Sauces'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4058172943591', '4008100168473', '4012860003424', '4058172814327', '4061463583413', '4067796061901', '4061461461508', '4066447265330', '4061463660800', '4008100168220', '4061463583062', '4066447265316', '4061463583390', '4061462018237', '4061461024680', '4002359006029', '40045122', '4008100168466', '4061459566789', '4337256377331', '4016249132354', '8076809523561', '4063367433108', '4038700117373', '4104420213517', '4005500331407', '4337256376709', '4337256785396', '4104420213555', '7640143674138', '7640143674145', '8076809513722', '20004125', '20884260', '4311596440429', '8005110140013', '8076809513388', '4311501650578', '7640143674114', '8076809513692', '8076809521543', '20003937', '20164034', '4337256946070', '8005110551215', '20300623', '4337256343107', '8076809583749', '4337256380669', '4104420031081', '4337256794176')
  and ean is not null;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'DmBio', 'Grocery', 'Sauces', 'Tomatensoße Klassik', 'not-applicable', null, 'none', '4058172943591'),
  ('DE', 'Hengstenberg', 'Grocery', 'Sauces', 'Tomaten stückig mit Kräutern', 'not-applicable', null, 'none', '4008100168473'),
  ('DE', 'Bautz''ner', 'Grocery', 'Sauces', 'Fix Tomatensoße', 'not-applicable', 'Lidl', 'none', '4012860003424'),
  ('DE', 'DmBio', 'Grocery', 'Sauces', 'Tomatensoße Arrabbiata', 'not-applicable', null, 'none', '4058172814327'),
  ('DE', 'InnFood Organic', 'Grocery', 'Sauces', 'Bio-Tomatensauce - Gemüse und Parmesan', 'not-applicable', 'Aldi', 'none', '4061463583413'),
  ('DE', 'DmBio', 'Grocery', 'Sauces', 'Tomatensauce Kräuter', 'not-applicable', null, 'none', '4067796061901'),
  ('DE', 'Aldi', 'Grocery', 'Sauces', 'Passierte Tomaten', 'not-applicable', 'Aldi', 'none', '4061461461508'),
  ('DE', 'DmBio', 'Grocery', 'Sauces', 'Tomatensauce - Ricotta Pecorino', 'not-applicable', null, 'none', '4066447265330'),
  ('DE', 'King''s Crown', 'Grocery', 'Sauces', 'Passata', 'not-applicable', 'Aldi', 'none', '4061463660800'),
  ('DE', 'Oro Di Parma', 'Grocery', 'Sauces', 'Pizzasauce Oregano', 'not-applicable', null, 'none', '4008100168220'),
  ('DE', 'InnFood Organic', 'Grocery', 'Sauces', 'Bio-Tomatensauce - Basilikum', 'not-applicable', 'Aldi', 'none', '4061463583062'),
  ('DE', 'DmBio', 'Grocery', 'Sauces', 'Tomatensauce - gegrillte Paprika', 'not-applicable', null, 'none', '4066447265316'),
  ('DE', 'InnFood Organic', 'Grocery', 'Sauces', 'Bio-Tomatensauce - Arrabiata', 'not-applicable', 'Aldi', 'none', '4061463583390'),
  ('DE', 'Clama', 'Grocery', 'Sauces', 'Tomate Frito', 'fried', 'Aldi', 'none', '4061462018237'),
  ('DE', 'Cucina', 'Grocery', 'Sauces', 'Pasta-Sauce Arrabbiata', 'not-applicable', 'Aldi', 'none', '4061461024680'),
  ('DE', 'Mars', 'Grocery', 'Sauces', 'Pastasauce Miracoli Klassiker', 'not-applicable', null, 'none', '4002359006029'),
  ('DE', 'Alnatura', 'Grocery', 'Sauces', 'Passata', 'not-applicable', null, 'none', '40045122'),
  ('DE', 'Oro', 'Grocery', 'Sauces', 'Pastasauce Classico', 'not-applicable', 'Kaufland', 'none', '4008100168466'),
  ('DE', 'Cucina', 'Grocery', 'Sauces', 'Pasta-Sauce - Napoletana', 'not-applicable', 'Aldi', 'none', '4061459566789'),
  ('DE', 'REWE Bio', 'Grocery', 'Sauces', 'Tomatensauce Kräuter', 'not-applicable', null, 'none', '4337256377331'),
  ('DE', 'Allos', 'Grocery', 'Sauces', 'Olivers Olive Tomate', 'not-applicable', null, 'none', '4016249132354'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Toscana Kräuter', 'not-applicable', 'Lidl', 'none', '8076809523561'),
  ('DE', 'Kaufland Bio', 'Grocery', 'Sauces', 'Tomatensauce Classic', 'not-applicable', null, 'none', '4063367433108'),
  ('DE', 'Knorr', 'Grocery', 'Sauces', 'Tomaten passiert', 'not-applicable', null, 'none', '4038700117373'),
  ('DE', 'Alnatura', 'Grocery', 'Sauces', 'Tomatensauce Kräuter', 'not-applicable', null, 'none', '4104420213517'),
  ('DE', 'Nestlé', 'Grocery', 'Sauces', 'Tomaten Sauce', 'dried', null, 'none', '4005500331407'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Sauces', 'Stückige Tomaten', 'not-applicable', null, 'none', '4337256376709'),
  ('DE', 'Rewe', 'Grocery', 'Sauces', 'Kräuter Knoblauch Saucenbasis', 'not-applicable', null, 'none', '4337256785396'),
  ('DE', 'Alnatura', 'Grocery', 'Sauces', 'Tomatensauce Gegrilltes Gemüse 350M', 'not-applicable', null, 'none', '4104420213555'),
  ('DE', 'Ppura', 'Grocery', 'Sauces', 'Kinder Tomatensoße', 'not-applicable', null, 'none', '7640143674138'),
  ('DE', 'Ppura', 'Grocery', 'Sauces', 'Kinder Tomatensoße mit verstecktem Gemüse', 'not-applicable', null, 'none', '7640143674145'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Basilico 400g eu', 'not-applicable', 'Lidl', 'none', '8076809513722'),
  ('DE', 'Baresa', 'Grocery', 'Sauces', 'Tomatenmark', 'not-applicable', 'Lidl', 'none', '20004125'),
  ('DE', 'Baresa', 'Grocery', 'Sauces', 'Passierte Tomate', 'not-applicable', 'Lidl', 'none', '20884260'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Sauces', 'Passierte Tomaten', 'not-applicable', null, 'none', '4311596440429'),
  ('DE', 'Mutti', 'Grocery', 'Sauces', 'Triplo concentrato di pomodoro', 'not-applicable', null, 'none', '8005110140013'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Arrabbiata', 'not-applicable', 'Lidl', 'none', '8076809513388'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Sauces', 'Passata, passierte Tomaten - Bio', 'not-applicable', null, 'none', '4311501650578'),
  ('DE', 'Ppura', 'Grocery', 'Sauces', 'Vegane Bolognese', 'not-applicable', null, 'none', '7640143674114'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Napoletana', 'not-applicable', 'Lidl', 'none', '8076809513692'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Ricotta', 'not-applicable', null, 'none', '8076809521543'),
  ('DE', 'Combino', 'Grocery', 'Sauces', 'Bolognese', 'not-applicable', 'Lidl', 'none', '20003937'),
  ('DE', 'Baresa', 'Grocery', 'Sauces', 'Passierte Tomaten', 'not-applicable', 'Lidl', 'none', '20164034'),
  ('DE', 'Ja!', 'Grocery', 'Sauces', 'Tomatensauce mit Basilikum', 'not-applicable', null, 'none', '4337256946070'),
  ('DE', 'Mutti', 'Grocery', 'Sauces', 'Pizzasauce Aromatica', 'not-applicable', null, 'none', '8005110551215'),
  ('DE', 'Combino', 'Grocery', 'Sauces', 'Arrabbiata', 'not-applicable', 'Lidl', 'none', '20300623'),
  ('DE', 'REWE Bio', 'Grocery', 'Sauces', 'Passata Tomaten', 'not-applicable', null, 'none', '4337256343107'),
  ('DE', 'Barilla', 'Grocery', 'Sauces', 'Verdure mediterranee 400g eu cross', 'not-applicable', null, 'none', '8076809583749'),
  ('DE', 'REWE Bio', 'Grocery', 'Sauces', 'Tomatensauce Ricotta', 'not-applicable', null, 'none', '4337256380669'),
  ('DE', 'Alnatura', 'Grocery', 'Sauces', 'Tomatensauce Toscana', 'not-applicable', null, 'none', '4104420031081'),
  ('DE', 'Rewe', 'Grocery', 'Sauces', 'Tomate Ricotta mit Basilikum', 'not-applicable', null, 'none', '4337256794176')
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
where country = 'DE' and category = 'Sauces'
  and is_deprecated is not true
  and product_name not in ('Tomatensoße Klassik', 'Tomaten stückig mit Kräutern', 'Fix Tomatensoße', 'Tomatensoße Arrabbiata', 'Bio-Tomatensauce - Gemüse und Parmesan', 'Tomatensauce Kräuter', 'Passierte Tomaten', 'Tomatensauce - Ricotta Pecorino', 'Passata', 'Pizzasauce Oregano', 'Bio-Tomatensauce - Basilikum', 'Tomatensauce - gegrillte Paprika', 'Bio-Tomatensauce - Arrabiata', 'Tomate Frito', 'Pasta-Sauce Arrabbiata', 'Pastasauce Miracoli Klassiker', 'Passata', 'Pastasauce Classico', 'Pasta-Sauce - Napoletana', 'Tomatensauce Kräuter', 'Olivers Olive Tomate', 'Toscana Kräuter', 'Tomatensauce Classic', 'Tomaten passiert', 'Tomatensauce Kräuter', 'Tomaten Sauce', 'Stückige Tomaten', 'Kräuter Knoblauch Saucenbasis', 'Tomatensauce Gegrilltes Gemüse 350M', 'Kinder Tomatensoße', 'Kinder Tomatensoße mit verstecktem Gemüse', 'Basilico 400g eu', 'Tomatenmark', 'Passierte Tomate', 'Passierte Tomaten', 'Triplo concentrato di pomodoro', 'Arrabbiata', 'Passata, passierte Tomaten - Bio', 'Vegane Bolognese', 'Napoletana', 'Ricotta', 'Bolognese', 'Passierte Tomaten', 'Tomatensauce mit Basilikum', 'Pizzasauce Aromatica', 'Arrabbiata', 'Passata Tomaten', 'Verdure mediterranee 400g eu cross', 'Tomatensauce Ricotta', 'Tomatensauce Toscana', 'Tomate Ricotta mit Basilikum');

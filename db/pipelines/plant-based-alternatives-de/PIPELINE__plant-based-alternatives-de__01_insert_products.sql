-- PIPELINE (Plant-Based & Alternatives): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000405004593', '4000405005026', '4000405005033', '4000405001523', '4012371620103', '4056489616221', '4000405001868', '4061459188745', '4056489467939', '4000405001752', '4000405003251', '4061462938825', '4066447610048', '4012359113108', '4001163154858', '4066447584035', '4056489616214', '4000405004999', '4066447562682', '4000405001745', '4061463803764', '40804002', '4071800000855', '4056489671411', '4337256250122', '4337256857086', '4012359111104', '21763847', '4260444962982', '4337256242585', '4335896750200', '4251291113221', '4012359144003', '4311501704288', '4012359110107', '4260380665039', '4260380665015', '20319335', '20004361', '4337256244794', '20163402', '7613036915076', '20884697', '4260322211348', '4337256733359', '4337256266383', '4260444962807', '8436557138934', '4311501451076', '4337256669160', '7290109359021', '4260322211362', '4305615783208', '4311501446232', '4337256253222', '4260380665930', '8719200207172', '4311501012246', '4104420208254')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Plant-Based & Alternatives by pipeline',
    ean = null
where country = 'DE'
  and category != 'Plant-Based & Alternatives'
  and identity_key in ('072a70efec60ade4ca88598074f23f03', '09b78a5e0267889d9caadde929edcc32', '0d1355d9050b8d81503610ac59ad828f', '0d81b39884e9202fc0d7339b7a9b259e', '10ddbe09d0dd51442229592a576e794e', '187ddb38bdfc0c08f3cfa232b09d2765', '192a65cc4d5716d064a1d4d2a40f8fb0', '1934c7fb1f9244031df96acc0c52b4a6', '2048788caa509915d8ccbf55abd40472', '231c34ad32ffb332ec280dbaafc1393e', '2af8ef946e4e5e560c324d9968b1a23f', '2e4e71ac37e52756e43d04ebc15cec10', '308ee4ebdd3917badfa6a48ec81f3d77', '30af4cc7663c7d575cd12860627b7278', '35c83938419421fc2824af4b6021215c', '362656b21491fbdb11f212cc6a3913e3', '429b2b0ee977052aa73131d8ae938a57', '44156e176085bd47f769693f42375ec2', '4826b9bd7b02e5b00217a905400f01e1', '48fbeab81e8f9bb46fad3d4fb0ced51e', '4a6f15ce259337ab0cd7064d1cef56ad', '4bd7f7ca23973ab9093ade0cf8916bd4', '5191ec5801c25f396447550435fab712', '52ad8ba1f4942b732ffacba9b7dd18c5', '5a3a199da4a5bf5440a9b8cf7a1f5468', '5d169e56b5e1ae13150ed680fdff4a00', '5e74ceae1f80200cad9ed4ba56bbbf59', '5f54d170a423dce4d630ede8b49872ea', '5f75c37868407efdac023cfd0793f6b9', '60ed67460324a4b9216b972f0f5ed242', '6177ee62f9e72cecf18b17e534330653', '66483c04490193645a293146cef89681', '6f87b74818e5b1aefa6b87664b6ae0f8', '71c2355595f74eee847c20c87acf8a99', '728e4364a1d03cf91c5fec7ba196504a', '7c87d3cd32c59a47600a4f99f29ca70d', '80973aa8037e51cf78c75496b135eb59', '8236ecb7d7927564b681def1e08c078f', '862a94057ffcd072eea4681b6c01cb23', '96b58efc528a89dc7ea25e25d01228ba', '9c274e04e23a00f5ff9fbcf41f913539', '9fe030f1e8d8605bb8bb348812cc0afa', 'a1959ca9b2821500ee4c34b7e1f89670', 'a364b013d7e6e6818c62cb35bfb629a9', 'a6543d859385ffc60555706d739fb1f2', 'a7ac593d23d7793d7d9fe1aeb93ba51c', 'a8d14133c45668378038508e9acd6032', 'ae88970fbd9184a737faab303deb8fcb', 'b01a6447e70622a8ad47fcdbd328c898', 'b83d6fd129c0508f1fcc1635695ce148', 'b8846f84379f8bdda0b7acc1ce1939f5', 'c45e407e08da3745701cc0aa42abf476', 'd578656201ac673512e5537dc915c3fd', 'da17c67784e77f542374a75ff8e0fe76', 'dde7237c76b8a71f179c02168ef425a6', 'ed128309920a5af2b016cf54a1cf7ce6', 'ed47fa34a5c9dffdd00b7ef3cd2f2dc5', 'f0f2a866d5c227a64cb550dcd6c304e5', 'f9f1687fb0bfb3f36fd1ce0c67dab2cf')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Schinken-Spicker Grillgemüse', 'not-applicable', 'Kaufland', 'none', '4000405004593'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'not-applicable', 'Lidl', 'none', '4000405005026'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Mühlen Nuggets Klassisch', 'not-applicable', 'Kaufland', 'none', '4000405005033'),
  ('DE', 'Mühlenbauer', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Bratwürste', 'not-applicable', 'Kaufland', 'none', '4000405001523'),
  ('DE', 'Eberswalder', 'Grocery', 'Plant-Based & Alternatives', 'Vegetarios Würstchen', 'not-applicable', null, 'none', '4012371620103'),
  ('DE', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Bio Tofu geräuchert', 'not-applicable', 'Lidl', 'none', '4056489616221'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Mühlen Crispies', 'not-applicable', null, 'none', '4000405001868'),
  ('DE', 'Gut Bio', 'Grocery', 'Plant-Based & Alternatives', 'Griechische Bio-Oliven, grün', 'not-applicable', 'Aldi', 'none', '4061459188745'),
  ('DE', 'Jerg', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Genießerscheiben würzig', 'not-applicable', 'Lidl', 'none', '4056489467939'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Mühlen Bratwurst', 'not-applicable', null, 'none', '4000405001752'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 'not-applicable', null, 'none', '4000405003251'),
  ('DE', 'My Vay', 'Grocery', 'Plant-Based & Alternatives', 'Bio-Tofu Geräuchert', 'smoked', null, 'none', '4061462938825'),
  ('DE', 'DmBio', 'Grocery', 'Plant-Based & Alternatives', 'Tomaten Stücke', 'not-applicable', null, 'none', '4066447610048'),
  ('DE', 'Taifun', 'Grocery', 'Plant-Based & Alternatives', 'Räuchertofu Mandel-Sesam', 'not-applicable', null, 'none', '4012359113108'),
  ('DE', 'Henglein', 'Grocery', 'Plant-Based & Alternatives', 'Gnocchi Kartoffel-Klößchen', 'not-applicable', null, 'none', '4001163154858'),
  ('DE', 'DmBio', 'Grocery', 'Plant-Based & Alternatives', 'Maiswaffeln', 'not-applicable', null, 'none', '4066447584035'),
  ('DE', 'Vemondo', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', 'Lidl', 'none', '4056489616214'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Veganer Schinken Spicker Bunter Pfeffer', 'not-applicable', null, 'none', '4000405004999'),
  ('DE', 'DmBio', 'Grocery', 'Plant-Based & Alternatives', 'Mais Waffeln gesalzen', 'not-applicable', null, 'none', '4066447562682'),
  ('DE', 'Rügenwalder Mühle', 'Grocery', 'Plant-Based & Alternatives', 'Vegan Curry aufschnitt', 'not-applicable', null, 'none', '4000405001745'),
  ('DE', 'Gut Bio', 'Grocery', 'Plant-Based & Alternatives', 'Bio-Linsenwaffeln - Meersalz', 'not-applicable', 'Aldi', 'none', '4061463803764'),
  ('DE', 'Kühne', 'Grocery', 'Plant-Based & Alternatives', 'Rotkohl', 'not-applicable', 'Lidl', 'none', '40804002'),
  ('DE', 'Harry', 'Grocery', 'Plant-Based & Alternatives', 'Steinofenbrot, Harry 1688', 'not-applicable', null, 'none', '4071800000855'),
  ('DE', 'Better Plant', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Creme', 'not-applicable', 'Lidl', 'none', '4056489671411'),
  ('DE', 'REWE Bio +vegan', 'Grocery', 'Plant-Based & Alternatives', 'Räucher-Tofu', 'smoked', null, 'none', '4337256250122'),
  ('DE', 'Rewe', 'Grocery', 'Plant-Based & Alternatives', 'Falafel bällchen', 'not-applicable', null, 'none', '4337256857086'),
  ('DE', 'Taifun', 'Grocery', 'Plant-Based & Alternatives', 'Tofu fumé', 'smoked', null, 'none', '4012359111104'),
  ('DE', 'Rewe Beste Wahl', 'Grocery', 'Plant-Based & Alternatives', 'Milde Genießer Scheiben', 'not-applicable', null, 'none', '21763847'),
  ('DE', 'Simply V', 'Grocery', 'Plant-Based & Alternatives', 'Würzig verfeinert mit Mandelöl', 'not-applicable', null, 'none', '4260444962982'),
  ('DE', 'Plant Republic', 'Grocery', 'Plant-Based & Alternatives', 'Räucher-Tofu', 'smoked', null, 'none', '4337256242585'),
  ('DE', 'K-take it veggie', 'Grocery', 'Plant-Based & Alternatives', 'Bio Tofu geräuchert', 'smoked', 'Kaufland', 'none', '4335896750200'),
  ('DE', 'No-Name', 'Grocery', 'Plant-Based & Alternatives', 'Bananen süß & samtig', 'not-applicable', 'Penny', 'none', '4251291113221'),
  ('DE', 'Taifun', 'Grocery', 'Plant-Based & Alternatives', 'Filets de tofu à la japonaise', 'not-applicable', null, 'none', '4012359144003'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Plant-Based & Alternatives', 'My Veggie Tofu geräuchert', 'not-applicable', null, 'none', '4311501704288'),
  ('DE', 'Taifun', 'Grocery', 'Plant-Based & Alternatives', 'Tofu natur', 'not-applicable', null, 'none', '4012359110107'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Grilled Chicken', 'grilled', null, 'none', '4260380665039'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Chicken', 'not-applicable', null, 'none', '4260380665015'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomatenmark 2-Fach Konzentriert', 'not-applicable', 'Lidl', 'none', '20319335'),
  ('DE', 'Freshona', 'Grocery', 'Plant-Based & Alternatives', 'Cornichons Gurken', 'not-applicable', 'Lidl', 'none', '20004361'),
  ('DE', 'Rewe Bio', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', null, 'none', '4337256244794'),
  ('DE', 'Baresa', 'Grocery', 'Plant-Based & Alternatives', 'Tomaten passiert', 'not-applicable', 'Lidl', 'none', '20163402'),
  ('DE', 'Garden Gourmet', 'Grocery', 'Plant-Based & Alternatives', 'Sensational Burger aus Sojaprotein', 'not-applicable', null, 'none', '7613036915076'),
  ('DE', 'Sondey', 'Grocery', 'Plant-Based & Alternatives', 'Mais Waffeln mit Meersalz Bio', 'not-applicable', 'Lidl', 'none', '20884697'),
  ('DE', 'Greenforce', 'Grocery', 'Plant-Based & Alternatives', 'Pflanzliche Mini-Frika', 'not-applicable', 'Lidl', 'none', '4260322211348'),
  ('DE', 'Ja', 'Grocery', 'Plant-Based & Alternatives', 'Tomaten passiert', 'not-applicable', null, 'none', '4337256733359'),
  ('DE', 'REWE Bio', 'Grocery', 'Plant-Based & Alternatives', 'Sojasahne', 'not-applicable', null, 'none', '4337256266383'),
  ('DE', 'Simply V', 'Grocery', 'Plant-Based & Alternatives', 'Gerieben Pizza', 'not-applicable', null, 'none', '4260444962807'),
  ('DE', 'Ja!', 'Grocery', 'Plant-Based & Alternatives', 'Cherry-Roma Tomaten Klasse 1', 'not-applicable', null, 'none', '8436557138934'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Plant-Based & Alternatives', 'My Veggie Tofu Natur', 'not-applicable', null, 'none', '4311501451076'),
  ('DE', 'REWE Bio', 'Grocery', 'Plant-Based & Alternatives', 'Linsenwaffeln', 'not-applicable', null, 'none', '4337256669160'),
  ('DE', 'Nestlé', 'Grocery', 'Plant-Based & Alternatives', 'Vegane Filet-Streifen', 'not-applicable', null, 'none', '7290109359021'),
  ('DE', 'Greenforce', 'Grocery', 'Plant-Based & Alternatives', 'Pflanzliche Cevapcici', 'not-applicable', 'Netto', 'none', '4260322211362'),
  ('DE', 'EnerBiO', 'Grocery', 'Plant-Based & Alternatives', 'Veggie Hack', 'not-applicable', 'Rossmann', 'none', '4305615783208'),
  ('DE', 'Edeka Bio', 'Grocery', 'Plant-Based & Alternatives', 'Tomatenmark 2-fach konzentriert', 'not-applicable', null, 'none', '4311501446232'),
  ('DE', 'Rewe', 'Grocery', 'Plant-Based & Alternatives', 'Tofu Natur', 'not-applicable', null, 'none', '4337256253222'),
  ('DE', 'Like Meat', 'Grocery', 'Plant-Based & Alternatives', 'Like Beef Strips', 'not-applicable', null, 'none', '4260380665930'),
  ('DE', 'Rama', 'Grocery', 'Plant-Based & Alternatives', 'Kochcreme', 'not-applicable', null, 'none', '8719200207172'),
  ('DE', 'Edeka', 'Grocery', 'Plant-Based & Alternatives', 'My Veggie Tofu Classic', 'not-applicable', null, 'none', '4311501012246'),
  ('DE', 'Alnatura', 'Grocery', 'Plant-Based & Alternatives', 'Linsen Waffeln', 'not-applicable', null, 'none', '4104420208254')
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
where country = 'DE' and category = 'Plant-Based & Alternatives'
  and is_deprecated is not true
  and product_name not in ('Veganer Schinken-Spicker Grillgemüse', 'Veganes Mühlen Cordon Bleu auf Basis von Soja', 'Vegane Mühlen Nuggets Klassisch', 'Vegane Bratwürste', 'Vegetarios Würstchen', 'Bio Tofu geräuchert', 'Vegane Mühlen Crispies', 'Griechische Bio-Oliven, grün', 'Vegane Genießerscheiben würzig', 'Vegane Mühlen Bratwurst', 'Veganer Hauchgenuss Mediterrane Kräuter-Typ Salami', 'Bio-Tofu Geräuchert', 'Tomaten Stücke', 'Räuchertofu Mandel-Sesam', 'Gnocchi Kartoffel-Klößchen', 'Maiswaffeln', 'Tofu Natur', 'Veganer Schinken Spicker Bunter Pfeffer', 'Mais Waffeln gesalzen', 'Vegan Curry aufschnitt', 'Bio-Linsenwaffeln - Meersalz', 'Rotkohl', 'Steinofenbrot, Harry 1688', 'Vegane Creme', 'Räucher-Tofu', 'Falafel bällchen', 'Tofu fumé', 'Milde Genießer Scheiben', 'Würzig verfeinert mit Mandelöl', 'Räucher-Tofu', 'Bio Tofu geräuchert', 'Bananen süß & samtig', 'Filets de tofu à la japonaise', 'My Veggie Tofu geräuchert', 'Tofu natur', 'Like Grilled Chicken', 'Like Chicken', 'Tomatenmark 2-Fach Konzentriert', 'Cornichons Gurken', 'Tofu Natur', 'Tomaten passiert', 'Sensational Burger aus Sojaprotein', 'Mais Waffeln mit Meersalz Bio', 'Pflanzliche Mini-Frika', 'Tomaten passiert', 'Sojasahne', 'Gerieben Pizza', 'Cherry-Roma Tomaten Klasse 1', 'My Veggie Tofu Natur', 'Linsenwaffeln', 'Vegane Filet-Streifen', 'Pflanzliche Cevapcici', 'Veggie Hack', 'Tomatenmark 2-fach konzentriert', 'Tofu Natur', 'Like Beef Strips', 'Kochcreme', 'My Veggie Tofu Classic', 'Linsen Waffeln');

-- PIPELINE (Oils & Vinegars): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-08

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Oils & Vinegars'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4061462150685', '4056489017479', '4067796070255', '4061462626883', '4066447258936', '4028856014978', '4061458029650', '4069365106273', '4056489017493', '4056489957652', '4061458063074', '4047247949293', '4028856015272', '4056489412472', '4058172777400', '4061458063470', '4047247949286', '4099200023526', '4061459138856', '4056489166856', '4006040002062', '4068134060273', '4056489798552', '4063367000614', '4006040196518', '4006040205548', '4006040112327', '4005009103048', '4056489639817', '4021851585139', '4006040205111', '8002470031944', '4337256414371', '4311501635773', '4104420248823', '4311596421626', '4337256021654', '8002470031937', '4316268576161', '4311501311943', '4337256079792', '4337256625784', '8410660101153', '4316268510738', '21596278', '8002802103288', '4335619110694', '4316268393478', '8008460004332', '4337256876872', '4311501490884')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Oils & Vinegars by pipeline',
    ean = null
where country = 'DE'
  and category != 'Oils & Vinegars'
  and identity_key in ('02db529a31a8588afcd0f39af2d07773', '02ecc09af0ddf85bc9f35967fa86adc7', '07706810b3f31245ccb711e816ff7fe1', '0a17e63aaaa56c1b160b89261c9857db', '0edf681169e3f57c90d6cf5e09e9a4f3', '11b5f7dddedb89ccc52ac4d0e63a8548', '15db5343ed005f4645cdca82396be692', '18ac0321bc4cb47212f6e565ece90286', '23698db11dd155ccb7df6882c9d1b764', '257511595cfe00a7d5f48373d633f532', '2a1960bcd003f48a1055b05e5a27f8e8', '2c97126dcb3fab479dd3fd1fbcbdfac6', '343e06d9e33d1a4fc40ff296b400e714', '36a4ffb00c48c72e14176b4a9842cf03', '3ebb2ef7b53ab4111f96ab51f293af21', '43eeb59aa1999a00e66b2c89cdff4ce6', '44022517b8bcc2e28679e7dbf7c981b4', '443507371e1e518e148fa657fddd51f4', '4621eb4a7da5851492c903e86d97c192', '4d7548eee762d998322eefaa3ddf0762', '569a6a49995eb6e5a8e94c322ccd96be', '5a0b466b4c7681c8d1fdf50909f671ac', '5d00394b2e1ea8d10774ed74b48aca84', '606786b716d3ef3c025fd70ad93596aa', '7c501ab1d647be07ffd51ec4c76da979', '82d188285e1c8ea424a9efc21330f28a', '90d7f8a81b870f4421eefd9b5dcd41b4', '9d412218a7c2f407f4b4dae2ad419a00', '9d9d30435c3b91777ffe31742b0dedc4', 'a5cf5b5cb5297d640bfda2e66f8bae20', 'a8756d1050d13f3f2280738065e2021f', 'aee180c959e9253d262c751661e62821', 'b0d2546f897b38a453dbe5d0a69a85af', 'b41131193bc78b047111464e58d04964', 'b4790bcebed8e415674cbcdd71effe41', 'b68ff8ae43a93f133f8287ff77053d00', 'bc6b4b6e2c32d81a03e95d5aa3710bb6', 'c32e8bc018709006a47e95204c310181', 'c479a62b43a6b3256ad141cf150fe8a2', 'c75447452484a74e896d4889e84de853', 'c7e1a8f517719b4aebc5103e0236dc18', 'de58419f08cea91d0be350a5e05f3fa3', 'e0918890b45840008c8a4502606f47d8', 'e37ff6a099e021ea86641d019637d1e3', 'e557cfe94186f4bb78db416437ea8b7b', 'e7c31ff80ff62c5c1f1dc03b4d9ee273', 'e9d3daf22a974eab9e2adb65f895b59b', 'f572ac7a9db435e009c833b644baf290', 'f7ede849cde51bf20af8044032b89540', 'fdd0f876c6443700cd8fa81b49059df9', 'ff15a80bfe2ee5498168a04efddb708c')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Bellasan', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', 'Aldi', 'none', '4061462150685'),
  ('DE', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', 'Lidl', 'none', '4056489017479'),
  ('DE', 'DmBio', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra', 'not-applicable', null, 'none', '4067796070255'),
  ('DE', 'Lyttos', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', 'Aldi', 'none', '4061462626883'),
  ('DE', 'DmBio', 'Grocery', 'Oils & Vinegars', 'Bratolivenöl', 'not-applicable', null, 'none', '4066447258936'),
  ('DE', 'Camaletti', 'Grocery', 'Oils & Vinegars', 'Camaletti Olivenöl', 'not-applicable', 'Penny', 'none', '4028856014978'),
  ('DE', 'Gut Bio', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', 'Aldi', 'none', '4061458029650'),
  ('DE', 'Lyttos', 'Grocery', 'Oils & Vinegars', 'Griechisches natives Olivenöl extra', 'not-applicable', 'Aldi', 'none', '4069365106273'),
  ('DE', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Brat Olivenöl', 'not-applicable', 'Lidl', 'none', '4056489017493'),
  ('DE', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Olivenöl (nativ, extra)', 'not-applicable', 'Lidl', 'none', '4056489957652'),
  ('DE', 'Aldi', 'Grocery', 'Oils & Vinegars', 'Griechisches natives Olivenöl Extra', 'not-applicable', 'Aldi', 'none', '4061458063074'),
  ('DE', 'Bellasan', 'Grocery', 'Oils & Vinegars', 'Oliven Öl', 'not-applicable', 'Aldi', 'none', '4047247949293'),
  ('DE', 'K-Classic', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra', 'not-applicable', 'Kaufland', 'none', '4028856015272'),
  ('DE', 'Lidl', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra aus Griechenland', 'not-applicable', 'Lidl', 'none', '4056489412472'),
  ('DE', 'DmBio', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra naturtrüb', 'not-applicable', null, 'none', '4058172777400'),
  ('DE', 'Cucina Nobile', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl', 'not-applicable', 'Aldi', 'none', '4061458063470'),
  ('DE', 'Aldi Bellasan', 'Grocery', 'Oils & Vinegars', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 'not-applicable', 'Aldi', 'none', '4047247949286'),
  ('DE', 'Bellasan', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', 'Aldi', 'none', '4099200023526'),
  ('DE', 'Aldi', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', 'Aldi', 'none', '4061459138856'),
  ('DE', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', null, 'none', '4056489166856'),
  ('DE', 'Rapunzel', 'Grocery', 'Oils & Vinegars', 'Ö-Kreta Olivenöl nativ extra-10,48€/29.6.22', 'not-applicable', null, 'none', '4006040002062'),
  ('DE', 'Ener Bio', 'Grocery', 'Oils & Vinegars', 'Griechisches natives Olivenöl e', 'not-applicable', null, 'none', '4068134060273'),
  ('DE', 'Deluxe', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', null, 'none', '4056489798552'),
  ('DE', 'K Favorites', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', null, 'none', '4063367000614'),
  ('DE', 'Rapunzel', 'Grocery', 'Oils & Vinegars', 'Olivenöl fruchtig', 'not-applicable', null, 'none', '4006040196518'),
  ('DE', 'Rapunzel', 'Grocery', 'Oils & Vinegars', 'Olivenöl nativ extra mild', 'not-applicable', null, 'none', '4006040205548'),
  ('DE', 'Rapunzel', 'Grocery', 'Oils & Vinegars', 'Ölivenöl Finca la Torre', 'not-applicable', null, 'none', '4006040112327'),
  ('DE', 'Biozentrsle', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', null, 'none', '4005009103048'),
  ('DE', 'Deluxe', 'Grocery', 'Oils & Vinegars', 'Öl - Olivenöl Extra G.G.A. Chania Kritis', 'not-applicable', null, 'none', '4056489639817'),
  ('DE', 'Dennree', 'Grocery', 'Oils & Vinegars', 'Olivenöl nativ extra', 'not-applicable', null, 'none', '4021851585139'),
  ('DE', 'Rapunzel', 'Grocery', 'Oils & Vinegars', 'Rapunzel Olivenöl Fruchtig, Nativ Extra, 0,5 LTR Flasche', 'not-applicable', null, 'none', '4006040205111'),
  ('DE', 'Bertolli', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Originale', 'not-applicable', null, 'none', '8002470031944'),
  ('DE', 'Rewe', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', null, 'none', '4337256414371'),
  ('DE', 'Edeka Bio', 'Grocery', 'Oils & Vinegars', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 'not-applicable', null, 'none', '4311501635773'),
  ('DE', 'Alnatura', 'Grocery', 'Oils & Vinegars', 'Olivenöl', 'not-applicable', null, 'none', '4104420248823'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Oils & Vinegars', 'Olivenöl Extra Natives', 'not-applicable', null, 'none', '4311596421626'),
  ('DE', 'D.O.P. Terra Di Bari Castel Del Monte', 'Grocery', 'Oils & Vinegars', 'Italienisches natives Olivenöl extra', 'not-applicable', null, 'none', '4337256021654'),
  ('DE', 'Bertolli', 'Grocery', 'Oils & Vinegars', 'Olivenöl Natives Extra Gentile SANFT', 'not-applicable', null, 'none', '8002470031937'),
  ('DE', 'BioBio', 'Grocery', 'Oils & Vinegars', 'Natives Bio-Olivenöl Extra', 'not-applicable', 'Netto', 'none', '4316268576161'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra', 'not-applicable', null, 'none', '4311501311943'),
  ('DE', 'Rewe beste Wahl', 'Grocery', 'Oils & Vinegars', 'Olivenöl ideal für warme Speisen', 'not-applicable', null, 'none', '4337256079792'),
  ('DE', 'Ja!', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', null, 'none', '4337256625784'),
  ('DE', 'La Espaniola', 'Grocery', 'Oils & Vinegars', 'Natives Ölivenöl extra', 'not-applicable', 'Kaufland', 'none', '8410660101153'),
  ('DE', 'Las Cuarenta', 'Grocery', 'Oils & Vinegars', 'Spanisches Natives Olivenöl extra', 'not-applicable', 'Netto', 'none', '4316268510738'),
  ('DE', 'Natur Gut', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', 'Penny', 'none', '21596278'),
  ('DE', 'Bio', 'Grocery', 'Oils & Vinegars', 'Bio natives Olivenöl', 'not-applicable', 'Kaufland', 'none', '8002802103288'),
  ('DE', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Bio natives Olivenöl extra', 'not-applicable', 'Lidl', 'none', '4335619110694'),
  ('DE', 'Vegola', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl extra', 'not-applicable', 'Netto', 'none', '4316268393478'),
  ('DE', 'Fiore', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra', 'not-applicable', null, 'none', '8008460004332'),
  ('DE', 'REWE Feine Welt', 'Grocery', 'Oils & Vinegars', 'Natives Olivenöl Extra Lesvos g.g.A.', 'not-applicable', null, 'none', '4337256876872'),
  ('DE', 'Edeka', 'Grocery', 'Oils & Vinegars', 'Griechisches Natives Olivenöl Extra', 'not-applicable', null, 'none', '4311501490884')
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
where country = 'DE' and category = 'Oils & Vinegars'
  and is_deprecated is not true
  and product_name not in ('Natives Olivenöl Extra', 'Natives Olivenöl Extra', 'Natives Olivenöl extra', 'Olivenöl', 'Bratolivenöl', 'Camaletti Olivenöl', 'Natives Olivenöl Extra', 'Griechisches natives Olivenöl extra', 'Brat Olivenöl', 'Olivenöl (nativ, extra)', 'Griechisches natives Olivenöl Extra', 'Oliven Öl', 'Natives Olivenöl extra', 'Natives Olivenöl extra aus Griechenland', 'Natives Olivenöl extra naturtrüb', 'Natives Olivenöl', 'ALDI BELLASAN Natives Olivenöl extra für kalte Zubereitungen wie Salate und Vinaigretten geeignet, in PET-Flasche 1l 8.99€', 'Olivenöl', 'Natives Olivenöl Extra', 'Olivenöl', 'Ö-Kreta Olivenöl nativ extra-10,48€/29.6.22', 'Griechisches natives Olivenöl e', 'Olivenöl', 'Natives Olivenöl Extra', 'Olivenöl fruchtig', 'Olivenöl nativ extra mild', 'Ölivenöl Finca la Torre', 'Olivenöl', 'Öl - Olivenöl Extra G.G.A. Chania Kritis', 'Olivenöl nativ extra', 'Rapunzel Olivenöl Fruchtig, Nativ Extra, 0,5 LTR Flasche', 'Natives Olivenöl Originale', 'Natives Olivenöl Extra', 'EDEKA Bio Natives Olivenöl extra 750ml 6.65€ 1l 9.27€', 'Olivenöl', 'Olivenöl Extra Natives', 'Italienisches natives Olivenöl extra', 'Olivenöl Natives Extra Gentile SANFT', 'Natives Bio-Olivenöl Extra', 'Natives Olivenöl extra', 'Olivenöl ideal für warme Speisen', 'Natives Olivenöl Extra', 'Natives Ölivenöl extra', 'Spanisches Natives Olivenöl extra', 'Natives Olivenöl Extra', 'Bio natives Olivenöl', 'Bio natives Olivenöl extra', 'Natives Olivenöl extra', 'Natives Olivenöl Extra', 'Natives Olivenöl Extra Lesvos g.g.A.', 'Griechisches Natives Olivenöl Extra');

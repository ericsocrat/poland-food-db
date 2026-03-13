-- PIPELINE (Desserts & Ice Cream): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Desserts & Ice Cream'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5902409703887', '5900531004704', '5901939103402', '5901958612343', '5903111943240', '5903767007488', '5900531000980', '5906040063430', '5900531011146', '5901958616365', '5903767003787', '5900820012779', '5900197031809', '5904467109243', '5901939006048', '5900197028298', '5900197002595', '5900643047385', '5900197027901', '5901939006017', '5900197023842', '5902409703047', '5901958614781', '5900197028045', '5900531003370', '5900168531000', '5900197026034', '5900197026010', '5900643051061', '5900820027322', '5902166748695', '5906040063621', '5903767003404', '5900197031465', '5902150593706', '5900531004827', '5900643050408', '5901630001588', '5904903000653', '5903767001325', '5901939103068', '5901939103075', '5901939103099', '5900531004735', '5900531004537', '5900512350080', '5906040063515', '5900531011023', '5900531004544', '5903767003459', '5903767003176', '5900820022280', '5908275688587', '5903767000687', '5900531000973', '5900197024412', '5901104005302', '5900512987378', '5902409703269', '5908275688891', '5900531011207', '5900197022548', '5901630000574', '5902409703726', '5900397754003', '5900643047347', '59046677', '5900643047101', '5903767006528', '5902409704174', '5902409704150', '5900512350097', '5906040063591', '5900197022388', '5902409702484', '5900512901091', '5901630000208', '5900531011047', '5903767006160', '5901939103105', '5906040063089', '5900531011016', '5900643051108', '5900531004506', '5900531004513', '5900643047699', '5901939103235', '5900643050217', '5900643052341', '5902409704389', '5901939103334', '5900531003738', '5900820021931', '5900197012723', '5900120044142', '5900531004667', '5900531011061', '5903767003183', '5900531003387', '5901958612374')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Desserts & Ice Cream by pipeline',
    ean = null
where country = 'PL'
  and category != 'Desserts & Ice Cream'
  and identity_key in ('0189fa952a722b317421fd0c8a87e01b', '01977c01d69caf8778d41affabcc5cb9', '01b62d8b2a7783476b56b356e5a6cf65', '01cfd588633bab03be370c242a31c168', '070f1528d2015315d7b881d7d2433dcc', '0903ea23972a7a661ca0445c09de2463', '0af06e01745c1113a6717d65583aceb0', '0fac8fa7e4b6de7b137f3a0a94c62ec6', '11149ba186315cda67b43db97051e404', '11203d1cb9fe4e91c8c6d8998818ed90', '162d0b9c10ce7c906e4e1aea6b5e7311', '170da3e1d3d38e27b3bc314cbf109c6d', '184959dce5bab2b93f5094767ecdaf74', '18b706e6ac98ea646dc08f6704e50683', '18baffd9557cdd4b36a2abe640ea45ad', '1959da53cb342b25a22a9d2efa5ccfca', '19fae46aeaf29c4a45fe7084a6dfe37f', '1af423f41d2ce7d92b42ff2eec08e99b', '1c57fbdcd9b8fce5ba270680b3686a76', '1cb777c7aa006f5d13581fc31842ff98', '1ce12479dc38200abc3b3007e964ca68', '1ddee28a79bc0da7f1dc6d81c1a500e6', '241a46f02dc4e05918292eb3147663ed', '26869d71b0fd3d83ac84c92a296785d5', '29aa0a1c13d356a7288c490bce11e40a', '2b2c3184363fca6ccd2935019122ae8c', '2ce23453c89e9a023e99fdf1e87ff695', '34f674cdc135d144c528d6d8bf0bc098', '35010bb67bd2fb837c9363f828fe1f1f', '355fcc0ecf8590c05f563b94da1bc114', '392b74c11f915ed3e60efe0489f0cb22', '3acbfc87e0cc28fa4dfd27fe1efa9127', '3b8d816f38a2285e601bac2eeddc38a0', '3c4c01b7c99286d37b3b2e9043ca9d3e', '3d4516cc39e24ad37ad63701e5399ef2', '3da36933e3c763cf3015e6d0dd4866d5', '3e5b1fdcf51b905800126aa5242f2b0d', '4800e7748f06b864c1af2ef5a386d2aa', '491d67dc8c26a2ae68533bbb5e06e0c4', '4b9bb109105ad7f725ceb433fa29d06b', '4cfa7f002039d0f9075260bdf4cd8953', '4d78de32c8c3c6c5c838baa980ef2468', '5204895150608ee88b0f024d6ee119f0', '57fb38aaa285e156d48d432de3d63706', '5898070f79d67dd6b7effeb852dc5185', '5c613dace71b00bfb8b0e1a983815084', '5cc388ba3822286e4f98eafe9460b990', '6256774ffb2e6f8045d834819aa8b271', '63af18498eeffeef0bed4d98a842c190', '64633b5d36523c7c01fbc56df48753dc', '6f08b16172e95a51ae74eb242613a694', '731aec3972c42dfde7224d1ba7b9b9c3', '754d1281a94b866cfa418aa5fe8258d1', '781629ce73e5c324f7eb8156300453a5', '79313525ecc40640d8ee2c693761e992', '85bf9491175dba21b182ebd9229e1a66', '868fa71d028069597c90a1b6ebbb7a15', '8691716a3329f7f25b3997bcfb027997', '8753eff19e0f571ee5e639780de90a5e', '87882cdfe7cb4323155fe311ca1b5210', '883bdc13f2ecd604723fd7eb8c83c324', '8b179a48699f5a5ab444c6b625c8cd25', '8cfbd7ac261503b1cb9f989e58f8a5a5', '8e27d8d034d4d939bf5c7e90eb51fa0e', '91c6f7a7a82b3acf5d4784a1c9a04f0b', '9265405d54970cf3106775860db32e1e', '95d7be2062ce20e1a3c18c56d0ea5146', '9b8c13ec6fbbd1b5c1eb48f29070b52c', 'a7e70eed7120d493f43d971079ebd7e1', 'a9a297c1fd470525057870caf3d16bd5', 'aa030c08684c712a57c3afd3b81d89ae', 'abf9fb50283b2e23466fd15cfd23a830', 'aec22a71c205f056f768d653d46044b4', 'b71f28382ac3ce1e3b687ddce4154cdb', 'b9b4ce9e8457fe09d70fb97d55244d21', 'beb1ef81803629edaef83547edc3c80a', 'c36b7a238b36e7b753ef26b01fb0ef9d', 'c703035874c9de705ed206b5aee80e4f', 'c8cc91ff2d9df2b3a0889be50a7479c3', 'd095465c88f4b57cb3dd3c56d48c7c42', 'd17b685ccb8dff8aabfe1011c8fe2e02', 'd49b87fd214c941e7d702392064bf59f', 'd60e46f68e700cc76feb99d5a4e69f53', 'd71c7d23b1a126d7b3a4d3036c07de18', 'dc18a8ecaa66e17d02df70a86825c228', 'ddcd88b6e25ea77d00ef65579877189a', 'de37cb269852bdc731819ff98651143f', 'e07cb6f72eb20fac4cc37c4a73cbe990', 'e0916975769bc0ad4266c1ef697b340e', 'e0d22fdb41ed8d608ef4d12d332e4180', 'e352700f50bfa45354e4e379619794cb', 'e7cc339bf8dae3a626b9d0bc6b8d445c', 'e7dc9d49582bed3cfe1b52d0427c8010', 'e8e9391383e73585b4dc315c9eb2f493', 'ecd400de424373d0a994370627e306df', 'f04f3691c624ca2975fd7233bf441b7a', 'f54c6b3298fa0538c676e31a8bf7059c', 'f95522de5483c72ded210860b004d5ef', 'f96b63642fd0234d9984f80284aeec0d', 'ff7616b856e7648069b27ddf8ce072a1')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'fermented', 'Biedronka', 'none', '5902409703887'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr z mango i marakują', 'fermented', 'Kaufland', 'none', '5900531004704'),
  ('PL', 'Piatnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'fermented', 'Kaufland', 'none', '5901939103402'),
  ('PL', 'OwoLovo', 'Grocery', 'Desserts & Ice Cream', 'OwoLowo Jabłkowo', 'not-applicable', 'Biedronka', 'none', '5901958612343'),
  ('PL', 'Tutti', 'Grocery', 'Desserts & Ice Cream', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'not-applicable', 'Biedronka', 'none', '5903111943240'),
  ('PL', 'Jovi', 'Grocery', 'Desserts & Ice Cream', 'Napój jogurtowy Duet Banan-Truskawka', 'fermented', 'Biedronka', 'none', '5903767007488'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Serek Wiejski Z Malinami I Żurawiną', 'fermented', null, 'none', '5900531000980'),
  ('PL', 'Zott', 'Grocery', 'Desserts & Ice Cream', 'Jogurt jabłko i gruszka', 'fermented', 'Biedronka', 'none', '5906040063430'),
  ('PL', 'Amelia', 'Grocery', 'Desserts & Ice Cream', 'Waniliowy 3 składniki', 'not-applicable', 'Lidl', 'none', '5900531011146'),
  ('PL', 'Vital Fresh', 'Grocery', 'Desserts & Ice Cream', 'Mus Jabłko Banan Marakuja', 'not-applicable', 'Biedronka', 'none', '5901958616365'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Mixo Jabłko-Gruszka', 'fermented', 'Biedronka', 'none', '5903767003787'),
  ('PL', 'Łaciaty', 'Grocery', 'Desserts & Ice Cream', 'Łaciaty SEREK WIEJSKI', 'fermented', null, 'none', '5900820012779'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Maxi Meal o smaku słonego karmelu', 'not-applicable', 'Dino', 'none', '5900197031809'),
  ('PL', 'Maluta', 'Grocery', 'Desserts & Ice Cream', 'Maluta Jogurt Bałkański', 'fermented', 'Auchan', 'none', '5904467109243'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Koktajl spożywczy', 'fermented', null, 'none', '5901939006048'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Jogurt naturalny gęsty', 'fermented', null, 'none', '5900197028298'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'fermented', null, 'none', '5900197002595'),
  ('PL', 'Fantasia', 'Grocery', 'Desserts & Ice Cream', 'Fantasia z płatkami w czekoladzie', 'fermented', null, 'none', '5900643047385'),
  ('PL', 'Fruvita (Bakoma)', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Wiśniowy', 'fermented', null, 'none', '5900197027901'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Koktail Białkowy malina & granat', 'fermented', null, 'none', '5901939006017'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Jogurt kremowy z malinami i granolą', 'fermented', null, 'none', '5900197023842'),
  ('PL', 'Tutti', 'Grocery', 'Desserts & Ice Cream', 'Serek Tutti Prosty Skład', 'fermented', null, 'none', '5902409703047'),
  ('PL', 'Ovolove', 'Grocery', 'Desserts & Ice Cream', 'Mus Jabłko Rabarbar', 'not-applicable', null, 'none', '5901958614781'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Bakoma Ave Vege (Czekolada z Wiśniami)', 'not-applicable', null, 'none', '5900197028045'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt wysokobiałkowy low carb waniliowy', 'fermented', null, 'none', '5900531003370'),
  ('PL', 'Pilos Pure', 'Grocery', 'Desserts & Ice Cream', 'Jogurt - truskawka, jabłko, banan, owies', 'fermented', null, 'none', '5900168531000'),
  ('PL', '7zbóż men', 'Grocery', 'Desserts & Ice Cream', 'Jogurt z jagodą, czarną porzeczką i ziarnami zbóż', 'fermented', null, 'none', '5900197026034'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', '7 zbóż MEN jogurt z brzoskwinią, gruszką i ziarnami zbóż', 'fermented', null, 'none', '5900197026010'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Yopro jogurt o smaku banan-krem z orzeszków ziemnych z magnezem i witaminą b9', 'fermented', null, 'none', '5900643051061'),
  ('PL', 'Łaciaty', 'Grocery', 'Desserts & Ice Cream', 'Łaciaty jogurt pitny równowaga i regeneracja z magnezem i biotyną', 'fermented', null, 'none', '5900820027322'),
  ('PL', 'Helcom', 'Grocery', 'Desserts & Ice Cream', 'Mix owoców w lekkim syropie', 'not-applicable', null, 'none', '5902166748695'),
  ('PL', 'Jogobella', 'Grocery', 'Desserts & Ice Cream', 'Jogurt wiśniowy', 'fermented', null, 'none', '5906040063621'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt o smaku pieczonego jabłka', 'roasted', null, 'none', '5903767003404'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Skyr Malina-truskawka Wysoka Zawartość Białka', 'fermented', null, 'none', '5900197031465'),
  ('PL', 'Dessella', 'Grocery', 'Desserts & Ice Cream', 'Deser mleczny czekoladowy z bitą śmietana o smaku czekoladowym', 'not-applicable', null, 'none', '5902150593706'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr czekoladowy z wiśnią', 'not-applicable', null, 'none', '5900531004827'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Ale pitny malina Borówka', 'fermented', null, 'none', '5900643050408'),
  ('PL', 'Rolmlecz', 'Grocery', 'Desserts & Ice Cream', 'Serek poznański naturalny', 'fermented', null, 'none', '5901630001588'),
  ('PL', 'Wieluń', 'Grocery', 'Desserts & Ice Cream', 'Mój Ulubiony', 'fermented', null, 'none', '5904903000653'),
  ('PL', 'Fruvita pure', 'Grocery', 'Desserts & Ice Cream', 'Jogurt + owoce borówka banan', 'fermented', null, 'none', '5903767001325'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'fermented', 'Kaufland', 'none', '5901939103068'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr Wanilia', 'fermented', 'Kaufland', 'none', '5901939103075'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'fermented', 'Auchan', 'none', '5901939103099'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Icelandic type yoghurt natural', 'fermented', 'Kaufland', 'none', '5900531004735'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt typu islandzkiego waniliowy', 'fermented', 'Lidl', 'none', '5900531004537'),
  ('PL', 'Mlekovita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Grecki naturalny', 'fermented', 'Kaufland', 'none', '5900512350080'),
  ('PL', 'Zott', 'Grocery', 'Desserts & Ice Cream', 'Jogurt naturalny', 'fermented', 'Auchan', 'none', '5906040063515'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Serek homogenizowany truskawkowy', 'fermented', 'Lidl', 'none', '5900531011023'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr Naturalny', 'fermented', 'Lidl', 'none', '5900531004544'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt jagodowy', 'fermented', 'Biedronka', 'none', '5903767003459'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Skyr Pitny Wanilia', 'fermented', 'Biedronka', 'none', '5903767003176'),
  ('PL', 'Pilos', 'Grocery', 'Desserts & Ice Cream', 'Serek Wiejski Lekki', 'fermented', 'Lidl', 'none', '5900820022280'),
  ('PL', 'Président', 'Grocery', 'Desserts & Ice Cream', 'Twarog sernikowy', 'fermented', 'Kaufland', 'none', '5908275688587'),
  ('PL', 'Jovi', 'Grocery', 'Desserts & Ice Cream', 'Duet jogurt pitny Truskawka-Kiwi', 'fermented', 'Lidl', 'none', '5903767000687'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Serek wiejski z jagodami', 'fermented', 'Biedronka', 'none', '5900531000973'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Bakoma Ave Vege czekolada', 'not-applicable', 'Biedronka', 'none', '5900197024412'),
  ('PL', 'Vemondo', 'Grocery', 'Desserts & Ice Cream', 'Kokos naturalny', 'fermented', 'Lidl', 'none', '5901104005302'),
  ('PL', 'Delikate', 'Grocery', 'Desserts & Ice Cream', 'Serek Wiejski', 'fermented', 'Biedronka', 'none', '5900512987378'),
  ('PL', 'Tutti', 'Grocery', 'Desserts & Ice Cream', 'Serek homogenizowany brzoskwiniowy Tutti', 'fermented', 'Biedronka', 'none', '5902409703269'),
  ('PL', 'Président', 'Grocery', 'Desserts & Ice Cream', 'Serek waniliowy', 'fermented', 'Biedronka', 'none', '5908275688891'),
  ('PL', 'Piatnica', 'Grocery', 'Desserts & Ice Cream', 'Serek homogenizowany brzoskwiniowy', 'fermented', 'Kaufland', 'none', '5900531011207'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Bio naturalny', 'fermented', 'Biedronka', 'none', '5900197022548'),
  ('PL', 'Rolmlecz', 'Grocery', 'Desserts & Ice Cream', 'Serek truskawkowy', 'fermented', 'Auchan', 'none', '5901630000574'),
  ('PL', 'Go Active', 'Grocery', 'Desserts & Ice Cream', 'Serek proteinowy ze skyrem', 'fermented', 'Biedronka', 'none', '5902409703726'),
  ('PL', 'Łowicz', 'Grocery', 'Desserts & Ice Cream', 'Sernik z brzoskwiniami', 'not-applicable', 'Żabka', 'none', '5900397754003'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Fantasia ar ķiršiem', 'fermented', 'Auchan', 'none', '5900643047347'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Actimel o smaku wieloowocowym', 'fermented', 'Biedronka', 'none', '59046677'),
  ('PL', 'Activia', 'Grocery', 'Desserts & Ice Cream', 'Activia pitna owoce leśne', 'fermented', null, 'none', '5900643047101'),
  ('PL', 'Go Active', 'Grocery', 'Desserts & Ice Cream', 'Protein Jogurt Truskawkowy', 'fermented', 'Biedronka', 'none', '5903767006528'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Skyr blueberry', 'fermented', 'Biedronka', 'none', '5902409704174'),
  ('PL', 'Fruivita', 'Grocery', 'Desserts & Ice Cream', 'Skyr Słony Karmel', 'fermented', null, 'none', '5902409704150'),
  ('PL', 'Mlekowita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Polski truskawka z kawałkami owoców', 'fermented', null, 'none', '5900512350097'),
  ('PL', 'Jogobella', 'Grocery', 'Desserts & Ice Cream', 'Jogurt brzoskwiniowy', 'fermented', 'Biedronka', 'none', '5906040063591'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Bio z Truskawkami', 'fermented', 'Biedronka', 'none', '5900197022388'),
  ('PL', 'Unknown', 'Grocery', 'Desserts & Ice Cream', 'Fruvita z granolą i truskawkami', 'fermented', null, 'none', '5902409702484'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Grecki', 'fermented', null, 'none', '5900512901091'),
  ('PL', 'Rolmlecz', 'Grocery', 'Desserts & Ice Cream', 'Serek Homo Wanil 200G Rolmlecz', 'fermented', null, 'none', '5901630000208'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Serek homogenizowany stracciatella', 'fermented', null, 'none', '5900531011047'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Jogurt naturalny kremowy', 'fermented', null, 'none', '5903767006160'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt pitny Naturalny', 'fermented', null, 'none', '5901939103105'),
  ('PL', 'Zott Primo', 'Grocery', 'Desserts & Ice Cream', 'Jogurt Naturalny', 'fermented', null, 'none', '5906040063089'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Serek homogenizowany waniliowy', 'fermented', null, 'none', '5900531011016'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'YoPRO (Smak Truskawka Malina)', 'fermented', null, 'none', '5900643051108'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr - jogurt typu islandzkiego z truskawkami', 'fermented', null, 'none', '5900531004506'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr Joghurt', 'fermented', null, 'none', '5900531004513'),
  ('PL', 'Activia', 'Grocery', 'Desserts & Ice Cream', 'Jogurt z probiotykami truskawka kiwi', 'fermented', null, 'none', '5900643047699'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr jogurt pitny', 'fermented', null, 'none', '5901939103235'),
  ('PL', 'Danone', 'Grocery', 'Desserts & Ice Cream', 'Activia', 'fermented', null, 'none', '5900643050217'),
  ('PL', 'YoPRO', 'Grocery', 'Desserts & Ice Cream', 'Jogurt pitny proteinowy o smaku mango', 'fermented', null, 'none', '5900643052341'),
  ('PL', 'Fruvita', 'Grocery', 'Desserts & Ice Cream', 'Skyr naturalny', 'fermented', 'Biedronka', 'none', '5902409704389'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Skyr Wanilia & Stracciatella', 'fermented', null, 'none', '5901939103334'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Jogurt naturalny', 'fermented', null, 'none', '5900531003738'),
  ('PL', 'Delikate', 'Grocery', 'Desserts & Ice Cream', 'Serek Wiejski Lekki', 'fermented', null, 'none', '5900820021931'),
  ('PL', 'Bakoma', 'Grocery', 'Desserts & Ice Cream', 'Bakoma jogurt naturalny typ grecki', 'fermented', null, 'none', '5900197012723'),
  ('PL', 'Tolonis', 'Grocery', 'Desserts & Ice Cream', 'Jogurt typu greckiego', 'fermented', null, 'none', '5900120044142'),
  ('PL', 'Pilos', 'Grocery', 'Desserts & Ice Cream', 'Skyr', 'fermented', null, 'none', '5900531004667'),
  ('PL', 'Piątnica', 'Grocery', 'Desserts & Ice Cream', 'Coconut homogenized cheese', 'fermented', null, 'none', '5900531011061'),
  ('PL', 'Fruvira', 'Grocery', 'Desserts & Ice Cream', 'Skyr Naturalny Pitny', 'fermented', null, 'none', '5903767003183'),
  ('PL', 'Unknown', 'Grocery', 'Desserts & Ice Cream', 'Fruvita low carb jogurt o smaku truskawkowym', 'fermented', null, 'none', '5900531003387'),
  ('PL', 'Owolovo', 'Grocery', 'Desserts & Ice Cream', 'Brzoskwiniowo', 'not-applicable', null, 'none', '5901958612374')
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
where country = 'PL' and category = 'Desserts & Ice Cream'
  and is_deprecated is not true
  and product_name not in ('Jogurt typu islandzkiego SKYR Naturalny 0% tłuszczu', 'Skyr z mango i marakują', 'Skyr jogurt pitny typu islandzkiego Wiśnia', 'OwoLowo Jabłkowo', 'Tutti - serek o smaku waniliowym z pokruszoną laską wanilii', 'Napój jogurtowy Duet Banan-Truskawka', 'Serek Wiejski Z Malinami I Żurawiną', 'Jogurt jabłko i gruszka', 'Waniliowy 3 składniki', 'Mus Jabłko Banan Marakuja', 'Mixo Jabłko-Gruszka', 'Łaciaty SEREK WIEJSKI', 'Maxi Meal o smaku słonego karmelu', 'Maluta Jogurt Bałkański', 'Koktajl spożywczy', 'Jogurt naturalny gęsty', 'Bakoma 30 MILIARDOW jogurt Naturalny Gęsty RZADKI', 'Fantasia z płatkami w czekoladzie', 'Jogurt Wiśniowy', 'Koktail Białkowy malina & granat', 'Jogurt kremowy z malinami i granolą', 'Serek Tutti Prosty Skład', 'Mus Jabłko Rabarbar', 'Bakoma Ave Vege (Czekolada z Wiśniami)', 'Jogurt wysokobiałkowy low carb waniliowy', 'Jogurt - truskawka, jabłko, banan, owies', 'Jogurt z jagodą, czarną porzeczką i ziarnami zbóż', '7 zbóż MEN jogurt z brzoskwinią, gruszką i ziarnami zbóż', 'Yopro jogurt o smaku banan-krem z orzeszków ziemnych z magnezem i witaminą b9', 'Łaciaty jogurt pitny równowaga i regeneracja z magnezem i biotyną', 'Mix owoców w lekkim syropie', 'Jogurt wiśniowy', 'Jogurt o smaku pieczonego jabłka', 'Skyr Malina-truskawka Wysoka Zawartość Białka', 'Deser mleczny czekoladowy z bitą śmietana o smaku czekoladowym', 'Skyr czekoladowy z wiśnią', 'Ale pitny malina Borówka', 'Serek poznański naturalny', 'Mój Ulubiony', 'Jogurt + owoce borówka banan', 'Skyr jogurt pitny typu islandzkiego mango & marakuja', 'Skyr Wanilia', 'Skyr jogurt pitny typu islandzkiego Jagoda', 'Icelandic type yoghurt natural', 'Skyr jogurt typu islandzkiego waniliowy', 'Jogurt Grecki naturalny', 'Jogurt naturalny', 'Serek homogenizowany truskawkowy', 'Skyr Naturalny', 'Jogurt jagodowy', 'Skyr Pitny Wanilia', 'Serek Wiejski Lekki', 'Twarog sernikowy', 'Duet jogurt pitny Truskawka-Kiwi', 'Serek wiejski z jagodami', 'Bakoma Ave Vege czekolada', 'Kokos naturalny', 'Serek Wiejski', 'Serek homogenizowany brzoskwiniowy Tutti', 'Serek waniliowy', 'Serek homogenizowany brzoskwiniowy', 'Jogurt Bio naturalny', 'Serek truskawkowy', 'Serek proteinowy ze skyrem', 'Sernik z brzoskwiniami', 'Fantasia ar ķiršiem', 'Actimel o smaku wieloowocowym', 'Activia pitna owoce leśne', 'Protein Jogurt Truskawkowy', 'Skyr blueberry', 'Skyr Słony Karmel', 'Jogurt Polski truskawka z kawałkami owoców', 'Jogurt brzoskwiniowy', 'Jogurt Bio z Truskawkami', 'Fruvita z granolą i truskawkami', 'Jogurt Grecki', 'Serek Homo Wanil 200G Rolmlecz', 'Serek homogenizowany stracciatella', 'Jogurt naturalny kremowy', 'Skyr jogurt pitny Naturalny', 'Jogurt Naturalny', 'Serek homogenizowany waniliowy', 'YoPRO (Smak Truskawka Malina)', 'Skyr - jogurt typu islandzkiego z truskawkami', 'Skyr Joghurt', 'Jogurt z probiotykami truskawka kiwi', 'Skyr jogurt pitny', 'Activia', 'Jogurt pitny proteinowy o smaku mango', 'Skyr naturalny', 'Skyr Wanilia & Stracciatella', 'Jogurt naturalny', 'Serek Wiejski Lekki', 'Bakoma jogurt naturalny typ grecki', 'Jogurt typu greckiego', 'Skyr', 'Coconut homogenized cheese', 'Skyr Naturalny Pitny', 'Fruvita low carb jogurt o smaku truskawkowym', 'Brzoskwiniowo');

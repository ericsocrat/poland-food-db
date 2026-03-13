-- PIPELINE (Cereals): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Cereals'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4000540000108', '4000540011050', '4018077006203', '4063367446207', '4018077006340', '4005528123367', '4008713713213', '4067796181463', '4000540000306', '4021700900021', '4061464911895', '4000540000641', '4056489665519', '4000540005028', '4000540011081', '4061459674101', '4066447607543', '4000540005059', '4067796181487', '4058172307348', '4061458088725', '4061464177512', '4000540000405', '4000540002409', '4000540010732', '4063367101885', '4000540025217', '4061464177536', '4000540002508', '4068134046536', '4067796181500', '40897677', '4000540000658', '4061463845337', '4000540091069', '4061464912014', '4311501043646', '4337256379519', '4067796001839', '4066447663075', '4061458198424', '4033500101577', '4056489917700', '4000540043013', '4008391212596', '4337256818506', '4067796081428', '4000540003048', '4036300157638', '4061464912243', '4061461399276', '4000540000726', '4000540015157', '4061461053703', '4019339291016', '4015637825427', '4063367107511', '4015637825410', '4061464173538', '4104420115743', '25814200', '4337256415965', '7613033212949', '20003166', '4260582961519', '3387390339499', '4311501720073', '4337256783132', '4337256739689', '4337256436649', '20283360', '4311501492246', '7613287433633', '5059319023670', '4337256782531', '3387390321067', '4337256095891', '4337256850032', '4104420018709', '4311501492277', '20159917', '4337256427722', '4260582961502', '4104420018747', '5010029227062', '4311596412006', '20101268', '7613031570126', '4311501688762', '20621377', '20937041', '4337256479639', '4337256538596', '8445290728791', '4337256412872', '7613287476678', '4316268586849', '20003180', '4104420237155', '5906827022278', '4337256486057', '3387390320190', '4305615907840', '5059319030760', '4104420254756', '5010029000023', '4104420238244', '4311501095355', '4104420139640', '20713812', '4311501018989', '5059319030791', '4104420021921', '5738001092490', '4104420257146', '4104420257108', '4104420136540', '4316268594431', '5900020043481', '8008698007709', '9004617066580', '4260335837351')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Cereals by pipeline',
    ean = null
where country = 'DE'
  and category != 'Cereals'
  and identity_key in ('008ec7cf3ff8b6de932d8fc0feda2d34', '0489bbed9cab763a44138453c5ab4823', '096cb2be95436257b0511c0413c39c98', '0f0da1a27be2d43afe5517cf7bda2a99', '1037efaac3a62d7f3b8bce1b95e45fe8', '143fbb3d8996bfddaa936c8d4aca7c7c', '16d860a378ad9fd61d341fc32628a427', '17db3ee119f93f55060bcbb8d918671e', '1846b9128ca2bd3beef2872370ca1e37', '1bbdda82f4aa2be75f89e38abbbb5b81', '1bc8f17ef75548027c96a9ad4f8508e1', '1d976418852c5a06407b7a3e170613f6', '1e042e977612de82320d0f746cab076d', '1e0c3f1bbdbceca377d1334c01b19c15', '1ffac3e8fc393258ece176847e7562b9', '22bd5aa8e20d3b8af1f4102fd8ab7a63', '22da790b29b0f60f8860e01ca05c53db', '23315ea4af1932d82f64eca410936204', '2571cf69b78af816f623193e6fce1fc8', '262d5f6695cf79e183ba8e51f9723d8f', '296cbba9daeb870e9309a802891e0f6b', '29b562f7826b182068719ac900131043', '29e3a2042a1ea6b79db57f855dccc731', '2b470833d6e7411f20fb3c3223e1cc1a', '2b8377625daa1ff9366871cc97d2e486', '2def761fcc1ba7e07854cf783af6ce6b', '2e8e81f7fabcf5149b6fa74b36ab7c00', '30eeabcbb2569ff84f1a0b37e163eb9d', '32ff1308ea20215ee7bb2d82889f0c4a', '34ffe300bd2858241ae1086e3bce9822', '37ce9d12ae7d4627d7c00699b57e9e03', '3c3248336e31df1d649c22883f82ca74', '3dfcf2fb8a366cf27addd1ab6ce4e86b', '3fe14f569562499a31ffee6180697ba4', '43b9d8a36675db082f5fe69f2f441aa6', '474fef30c23866d5ecf657f1b59fb4d0', '4828d3813b465d4f037583d4fe475cfd', '4c3eb15182e86c2016e11e10f443fbfd', '4ceb3d11724c991e767dbba177ebfb09', '4d0dc5e6850ffd5d09a6aea86c6ad3d1', '4d8639b76d4e14d8d5ed1022aab09304', '4dbf881506955e017630537f8fe33f09', '4fb0cf1ac7efc255f49670bed0a8c4df', '51098405ba288bae60741206934e38cf', '57281e825993e949b0cd36990092e92c', '5b21f19152fee878938917051dd65b2b', '5b3d2cbb359c740d994a78a863d3a8f1', '60e46213329f8da0acb2c7e45e87fc50', '6290c423ad59b4292b9025572291d592', '648f2f009de0bfeee5221db837af8a80', '66aff3c344fe4af82ab0951b021997cc', '69ab165e163948962484fcdec26c6ff8', '6f79fffdecb39763109154eb75760931', '70702bede9e146b5bdae76ebf7a12131', '7229b602fc45cd09e4248d213a8f96f5', '7b924334b5f144f75a1f04836d4fe1eb', '7e4667f37257b0b30ae5d409e8513615', '81b5b720ee046d2f716f4b9d3d7ac992', '82108f4b6145b78141400b9f7a215ff5', '86939693f94d5dba7b34be7625db9878', '8c16364eb3913a24b4b3738f647cef5d', '8c95cdb18e11d5dff4a175d8b5e340c3', '8e3a7f1501334d68d7e4b2cf9145da57', '8ea4bbf807461200e36ec198444f980f', '8f7bbcbb78ee709fc3790087e0685e5c', '8fc576e14b197c498d671adff70d0fd0', '901eac9da15f144beb97528f446ab12f', '9147bea6d938af5385fbbbcca89e780d', '94fd83701229f714206bcfb696c56fc0', '9bd808c315b595809ae9960e9148d600', '9d489238349eeedbba3ab382d729c363', '9d93e44d32d90665780ed40fb66ab513', 'a00bfd0df4eb04da53b011a94ebb8c8b', 'a3e26712bc5d20c3c3ed9b57a26f3aa1', 'a6b6de2e894835e805f4d981ae1d8ff8', 'a80695788841420cbfc6f4bf8839a7aa', 'ad7ea2032bb2081ee39668daf8d83707', 'af07419e344602f6bc53075141dd5766', 'b0256546966c572fdf7b015846c7b27b', 'b08ffbc28c3bd0f86d97a3a996693153', 'b1485ed65f825f8fe1903c5a7fb91523', 'b1f563c50c454024ee7c7752e17371d1', 'b2447bcf331b37e0e14801b5f102f6e6', 'b5d2a28383c4ebdce69228cf1c8d9487', 'b7897a34695e26aa48bae3f10b1c2a9c', 'b7d2bd3c093b7443214f0005231779a9', 'bb6097a3b208e7ce455b5f8ad0e07971', 'bbe9e62ae429561377e1f5458a8c5a9f', 'bc56e927ef9c1cde5848da16dd7e5d47', 'bd1ec0534fbf89701e237a81f0a12c1f', 'c11730e4df6217479f3259a4360c38d0', 'c16ad569a1ac75781689bb5eb4521c1c', 'c3d853457a5ae296e35275db9b219ced', 'c3e42be979af38cb875e0932fd681521', 'c3f74e1b9ffa0722cedfbe7c1ad755f4', 'c585533b21c5d99e542527a0136509b1', 'ceb19280c6156ef383729225809afeaf', 'cf958d4664fd1ca85399f6acf5b8e472', 'd02abbced8866e897213972008275fa4', 'd0ee22512b141be1a6a43d1607f466b2', 'd71890c6915d7f6f30a11b53c8d124c4', 'd888b01ac64a50576dd63e3a1670a0c4', 'dee447ead7bf610342f3480aa71879a3', 'e112d1cc248052b70e713563c1eb1f77', 'e1fdff9a0bf00fc6115cbd4803a2f024', 'e1fe02c2728ca695791a6de69dd86c72', 'e6352643fc6f18ad12057530dfc9db23', 'e8f2ec98479f7e76d52c75e2bbde8fe3', 'eb952be2fd809142a9b1ab12b554ccbf', 'eced4ed0ea96f59eaf219f48e9f5d0b3', 'ed09e6ed42ced8297aed229349693db2', 'edf862ea7f813dffac40deab7187975d', 'ef584c4fab0cf610511d751a577af1b4', 'f1cd7680e75d6cbbb2a5d721fd866082', 'f5a987608fde1925b3acbec8556fbb8d', 'f6ddeae74f06ed30eeba3c72a35d8693', 'f941014384c014d6b9c602904f058bcf', 'f962a8979fdeba966c8907b709687695', 'f98d9e639be66baee8a4f158a14e068d', 'fd18bc7114ddc83e6e2b6ee2f3ed93fe', 'fed8ef5fc6b01302d5d09c7ddbb71780', 'ff42a158b61c71fd3740d475c1473ba1')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferflocken, Blütenzarte Köllnflocken', 'not-applicable', null, 'none', '4000540000108'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'E Knusprige Haferfleks Klassik Kölln', 'not-applicable', 'Aldi', 'none', '4000540011050'),
  ('DE', 'Lorenz', 'Grocery', 'Cereals', 'Erdnußlocken Classic', 'not-applicable', 'Lidl', 'none', '4018077006203'),
  ('DE', 'K-Classic', 'Grocery', 'Cereals', 'Gefüllte Nougat Pockets', 'not-applicable', 'Kaufland', 'none', '4063367446207'),
  ('DE', 'Lorenz', 'Grocery', 'Cereals', 'Erdnußlocken Classic leicht', 'not-applicable', 'Lidl', 'none', '4018077006340'),
  ('DE', 'K-Classic', 'Grocery', 'Cereals', 'Ungesüßte Cornflakes', 'not-applicable', null, 'none', '4005528123367'),
  ('DE', 'K Bio', 'Grocery', 'Cereals', 'Cornflakes ungesüßt', 'not-applicable', null, 'none', '4008713713213'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Haferflocken Großblatt', 'not-applicable', null, 'none', '4067796181463'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Kernige Haferflocken', 'not-applicable', null, 'none', '4000540000306'),
  ('DE', 'Nippon', 'Grocery', 'Cereals', 'Puffreis mit Schokolade', 'not-applicable', 'Lidl', 'none', '4021700900021'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Zarte Haferflocken', 'not-applicable', 'Aldi', 'none', '4061464911895'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Bio-Haferflocken zart', 'not-applicable', 'Netto', 'none', '4000540000641'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Bio Haferflocken zart', 'not-applicable', 'Lidl', 'none', '4056489665519'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'not-applicable', 'Penny', 'none', '4000540005028'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Vollkorn Haferfleks', 'not-applicable', null, 'none', '4000540011081'),
  ('DE', 'DE-VAU-GE Gesundkostwerk', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', 'Aldi', 'none', '4061459674101'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Basis Porridge', 'not-applicable', null, 'none', '4066447607543'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Cereals hafer bits vegane creme vanillegeschmack', 'not-applicable', 'Penny', 'none', '4000540005059'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Haferflocken Feinblatt', 'not-applicable', null, 'none', '4067796181487'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', null, 'none', '4058172307348'),
  ('DE', 'Gut Bio', 'Grocery', 'Cereals', 'Bio-Haferflocken Vollkorn zart', 'not-applicable', 'Aldi', 'none', '4061458088725'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Honey Wheat gepuffter Weizen mit Honig', 'not-applicable', 'Aldi', 'none', '4061464177512'),
  ('DE', 'Kölln Flocken', 'Grocery', 'Cereals', 'Instant Flocken', 'not-applicable', 'Auchan', 'none', '4000540000405'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferkleie Flocken', 'not-applicable', null, 'none', '4000540002409'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Cremig-zartes Hafer-Porridge Schoko', 'not-applicable', null, 'none', '4000540010732'),
  ('DE', 'K Classic', 'Grocery', 'Cereals', 'Zarte Haferflocken', 'not-applicable', 'Kaufland', 'none', '4063367101885'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Nibbs gepuffter Hafer und Weizen mit Honig', 'not-applicable', 'Penny', 'none', '4000540025217'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Karamell Crisps', 'not-applicable', 'Aldi', 'none', '4061464177536'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Schmelzflocken', 'not-applicable', null, 'none', '4000540002508'),
  ('DE', 'EnerBio', 'Grocery', 'Cereals', 'Porridge Basis', 'not-applicable', 'Rossmann', 'none', '4068134046536'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Haferflocken Feinblatt glutenfrei', 'not-applicable', null, 'none', '4067796181500'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Hafer Flocken Zart', 'not-applicable', 'Lidl', 'none', '40897677'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferflocken (Kernig) Bio', 'not-applicable', null, 'none', '4000540000658'),
  ('DE', 'Nur Nur Natur', 'Grocery', 'Cereals', 'Haferflocken zart', 'not-applicable', null, 'none', '4061463845337'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Knusprige Haferfleks Schoko', 'not-applicable', null, 'none', '4000540091069'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Haferflocken kernig', 'not-applicable', null, 'none', '4061464912014'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Cereals', 'Cornflakes ungesüßt', 'not-applicable', null, 'none', '4311501043646'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Dinkel gepufft mit Honig gesüßt', 'not-applicable', null, 'none', '4337256379519'),
  ('DE', 'EnerBiO', 'Grocery', 'Cereals', 'Dinkel Gepufft', 'not-applicable', null, 'none', '4067796001839'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Fruchtringe', 'not-applicable', null, 'none', '4066447663075'),
  ('DE', 'Aldi', 'Grocery', 'Cereals', 'Knusprige Bio-Haferpops', 'not-applicable', null, 'none', '4061458198424'),
  ('DE', 'Frigeo', 'Grocery', 'Cereals', 'Knusperpuffreis mit Mais', 'not-applicable', null, 'none', '4033500101577'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'High Protein Porridge - Karamell Butterkeks', 'not-applicable', null, 'none', '4056489917700'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Zauberfleks Schoko', 'not-applicable', null, 'none', '4000540043013'),
  ('DE', 'Seitenbacher', 'Grocery', 'Cereals', 'Flocons d''epeautre au blé complet', 'not-applicable', null, 'none', '4008391212596'),
  ('DE', 'Rewe bio', 'Grocery', 'Cereals', 'Cornflakes ungesüsst', 'not-applicable', null, 'none', '4337256818506'),
  ('DE', 'DmBio', 'Grocery', 'Cereals', 'Sojaflocken', 'not-applicable', null, 'none', '4067796081428'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Haferkissen Zimt', 'not-applicable', null, 'none', '4000540003048'),
  ('DE', 'Milram', 'Grocery', 'Cereals', 'Porridge mit Vollkornhafer Natur', 'not-applicable', null, 'none', '4036300157638'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Porridge Klassisch', 'not-applicable', null, 'none', '4061464912243'),
  ('DE', 'Aldi Bio', 'Grocery', 'Cereals', 'Knusprige Haferpops', 'not-applicable', null, 'none', '4061461399276'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Hafer Porridge Beere', 'not-applicable', null, 'none', '4000540000726'),
  ('DE', 'Kölln', 'Grocery', 'Cereals', 'Risps - knuspriger Reis mit Schokoladengeschmack', 'not-applicable', null, 'none', '4000540015157'),
  ('DE', 'Golden Bridge Aldi', 'Grocery', 'Cereals', 'Haferflocken XXL', 'not-applicable', null, 'none', '4061461053703'),
  ('DE', 'Davert', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', null, 'none', '4019339291016'),
  ('DE', 'Bauck Hof', 'Grocery', 'Cereals', 'Hot Hafer Basis Porridge', 'not-applicable', null, 'none', '4015637825427'),
  ('DE', 'Kaufland', 'Grocery', 'Cereals', 'Haferflocken kernig,', 'not-applicable', null, 'none', '4063367107511'),
  ('DE', 'Bauck Hof', 'Grocery', 'Cereals', 'Porridge Beere, glutenfrei', 'not-applicable', null, 'none', '4015637825410'),
  ('DE', 'Golden Bridge', 'Grocery', 'Cereals', 'Schoko Chips', 'not-applicable', null, 'none', '4061464173538'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Haferflocken Großblatt', 'not-applicable', null, 'none', '4104420115743'),
  ('DE', 'Naturgut', 'Grocery', 'Cereals', 'Dinkel gepufft mit Honig gesüßt', 'not-applicable', null, 'none', '25814200'),
  ('DE', 'Ja', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4337256415965'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK Cerealien', 'not-applicable', null, 'none', '7613033212949'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Flocons d''Avoine', 'not-applicable', 'Lidl', 'none', '20003166'),
  ('DE', 'Wholey', 'Grocery', 'Cereals', 'Chillo Pillows - Bio-Kakaokissen', 'not-applicable', 'Aldi', 'none', '4260582961519'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'FITNESS Cerealien', 'not-applicable', 'Auchan', 'none', '3387390339499'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Cereals', 'Nougat Bits', 'not-applicable', null, 'none', '4311501720073'),
  ('DE', 'Rewe Bio', 'Grocery', 'Cereals', 'Rewe Bio Haferflocken zart', 'not-applicable', null, 'none', '4337256783132'),
  ('DE', 'Rewe Bio', 'Grocery', 'Cereals', 'Dinkel Flakes', 'not-applicable', null, 'none', '4337256739689'),
  ('DE', 'De-Vau-Ge', 'Grocery', 'Cereals', 'Cornflakes - Nougat Bits', 'not-applicable', null, 'none', '4337256436649'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Fiocchi di avena integrali', 'not-applicable', 'Lidl', 'none', '20283360'),
  ('DE', 'Edeka', 'Grocery', 'Cereals', 'Haferflocken extra zart', 'not-applicable', null, 'none', '4311501492246'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE NESQUIK WAVES Cerealien', 'not-applicable', 'Lidl', 'none', '7613287433633'),
  ('DE', 'Kellogg''s', 'Grocery', 'Cereals', 'Kellogg''s Smacks', 'not-applicable', 'Aldi', 'none', '5059319023670'),
  ('DE', 'Ja!', 'Grocery', 'Cereals', 'Chico Chips', 'not-applicable', null, 'none', '4337256782531'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE LION Cereals', 'not-applicable', null, 'none', '3387390321067'),
  ('DE', 'Rewe', 'Grocery', 'Cereals', 'Porridge Kakao', 'not-applicable', null, 'none', '4337256095891'),
  ('DE', 'De-Vau-Ge', 'Grocery', 'Cereals', 'Corn Flakes', 'not-applicable', null, 'none', '4337256850032'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Dinkel gepufft-mit Honig', 'not-applicable', null, 'none', '4104420018709'),
  ('DE', 'Aldi', 'Grocery', 'Cereals', 'Haferflocken Kernig', 'not-applicable', null, 'none', '4311501492277'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Corn Flakes', 'not-applicable', 'Lidl', 'none', '20159917'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Porridge Beere', 'not-applicable', null, 'none', '4337256427722'),
  ('DE', 'Wholey', 'Grocery', 'Cereals', 'Cinna Rollies - Bio-Zimtschnecken', 'not-applicable', 'Aldi', 'none', '4260582961502'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Dinkel Flakes', 'not-applicable', null, 'none', '4104420018747'),
  ('DE', 'Oreo', 'Grocery', 'Cereals', 'Oreo O''s', 'not-applicable', 'Carrefour', 'none', '5010029227062'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4311596412006'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Nougat Bits', 'not-applicable', 'Lidl', 'none', '20101268'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'Nesquik DUO', 'not-applicable', null, 'none', '7613031570126'),
  ('DE', 'Edeka', 'Grocery', 'Cereals', 'Choco Chips', 'not-applicable', null, 'none', '4311501688762'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Choco Shells', 'not-applicable', 'Lidl', 'none', '20621377'),
  ('DE', 'Alesto', 'Grocery', 'Cereals', 'Erdnuss-Mais-Mix', 'not-applicable', 'Lidl', 'none', '20937041'),
  ('DE', 'Rewe', 'Grocery', 'Cereals', 'White Wheaties', 'not-applicable', null, 'none', '4337256479639'),
  ('DE', 'REWE Bio', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4337256538596'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'KitKat Cereal', 'not-applicable', 'Auchan', 'none', '8445290728791'),
  ('DE', 'Ja!', 'Grocery', 'Cereals', 'Haferflocken kernig', 'not-applicable', null, 'none', '4337256412872'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'NESTLE CINI-MINIS CHURROS Cerealien', 'not-applicable', null, 'none', '7613287476678'),
  ('DE', 'Kornmühle', 'Grocery', 'Cereals', 'Kernige Haferflocken', 'not-applicable', 'Netto', 'none', '4316268586849'),
  ('DE', 'Crownfield', 'Grocery', 'Cereals', 'Golden Puffs', 'not-applicable', 'Lidl', 'none', '20003180'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Kakao Knusper Reis', 'not-applicable', 'Rossmann', 'none', '4104420237155'),
  ('DE', 'K-Classic', 'Grocery', 'Cereals', 'Zarte Haferflocken offen', 'not-applicable', 'Kaufland', 'none', '5906827022278'),
  ('DE', 'Ja!', 'Grocery', 'Cereals', 'Creamy bits', 'not-applicable', null, 'none', '4337256486057'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'Nestlé Cini Minis Maxi Pack', 'not-applicable', null, 'none', '3387390320190'),
  ('DE', 'EnerBio', 'Grocery', 'Cereals', 'Haferflocken Feinblatt', 'not-applicable', 'Rossmann', 'none', '4305615907840'),
  ('DE', 'Kellogg''s', 'Grocery', 'Cereals', 'Kellogg''s Crunchy Nut', 'not-applicable', 'Aldi', 'none', '5059319030760'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Dinkel Crunchy', 'not-applicable', null, 'none', '4104420254756'),
  ('DE', 'Weetabix', 'Grocery', 'Cereals', 'Weetabix produit à base de blé complet 100%', 'not-applicable', null, 'none', '5010029000023'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Schoko Hafer Crunchy', 'not-applicable', null, 'none', '4104420238244'),
  ('DE', 'EDEKA Bio', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4311501095355'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', null, 'none', '4104420139640'),
  ('DE', 'Naturgut', 'Grocery', 'Cereals', 'Haferflocken Kleinblatt', 'not-applicable', null, 'none', '20713812'),
  ('DE', 'Edeka', 'Grocery', 'Cereals', 'Haferflocken kernig', 'not-applicable', null, 'none', '4311501018989'),
  ('DE', 'Kellogg''s', 'Grocery', 'Cereals', 'KELLOGG''S Cerealien Frosties 400g 2.79€ Packung 1kg 6.64€', 'not-applicable', null, 'none', '5059319030791'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Haferflocken Feinblatt', 'not-applicable', null, 'none', '4104420021921'),
  ('DE', 'Nordisk Kellogg''S Norge Nuf', 'Grocery', 'Cereals', 'Cornflakes', 'not-applicable', null, 'none', '5738001092490'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Hafer Crunchy', 'not-applicable', null, 'none', '4104420257146'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Dinkel Hafer Crunchy', 'not-applicable', null, 'none', '4104420257108'),
  ('DE', 'Alnatura', 'Grocery', 'Cereals', 'Hafer dinkel porridge', 'not-applicable', null, 'none', '4104420136540'),
  ('DE', 'Kornmühle', 'Grocery', 'Cereals', 'Haferflocken', 'not-applicable', null, 'none', '4316268594431'),
  ('DE', 'Nestlé', 'Grocery', 'Cereals', 'Protein Trigo, Avena & Quinoa', 'not-applicable', null, 'none', '5900020043481'),
  ('DE', 'Schär', 'Grocery', 'Cereals', 'Choco Balls', 'not-applicable', null, 'none', '8008698007709'),
  ('DE', 'Verival', 'Grocery', 'Cereals', 'Porridge Erdbeer-Chia imp', 'not-applicable', null, 'none', '9004617066580'),
  ('DE', 'KoRo', 'Grocery', 'Cereals', 'Soja Protein Crispies', 'not-applicable', null, 'none', '4260335837351')
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
where country = 'DE' and category = 'Cereals'
  and is_deprecated is not true
  and product_name not in ('Haferflocken, Blütenzarte Köllnflocken', 'E Knusprige Haferfleks Klassik Kölln', 'Erdnußlocken Classic', 'Gefüllte Nougat Pockets', 'Erdnußlocken Classic leicht', 'Ungesüßte Cornflakes', 'Cornflakes ungesüßt', 'Haferflocken Großblatt', 'Kernige Haferflocken', 'Puffreis mit Schokolade', 'Zarte Haferflocken', 'Bio-Haferflocken zart', 'Bio Haferflocken zart', 'Cereal Hafer Bits vegane Creme Schokogeschmack', 'Vollkorn Haferfleks', 'Cornflakes', 'Basis Porridge', 'Cereals hafer bits vegane creme vanillegeschmack', 'Haferflocken Feinblatt', 'Cornflakes', 'Bio-Haferflocken Vollkorn zart', 'Honey Wheat gepuffter Weizen mit Honig', 'Instant Flocken', 'Haferkleie Flocken', 'Cremig-zartes Hafer-Porridge Schoko', 'Zarte Haferflocken', 'Nibbs gepuffter Hafer und Weizen mit Honig', 'Karamell Crisps', 'Schmelzflocken', 'Porridge Basis', 'Haferflocken Feinblatt glutenfrei', 'Hafer Flocken Zart', 'Haferflocken (Kernig) Bio', 'Haferflocken zart', 'Knusprige Haferfleks Schoko', 'Haferflocken kernig', 'Cornflakes ungesüßt', 'Dinkel gepufft mit Honig gesüßt', 'Dinkel Gepufft', 'Fruchtringe', 'Knusprige Bio-Haferpops', 'Knusperpuffreis mit Mais', 'High Protein Porridge - Karamell Butterkeks', 'Zauberfleks Schoko', 'Flocons d''epeautre au blé complet', 'Cornflakes ungesüsst', 'Sojaflocken', 'Haferkissen Zimt', 'Porridge mit Vollkornhafer Natur', 'Porridge Klassisch', 'Knusprige Haferpops', 'Hafer Porridge Beere', 'Risps - knuspriger Reis mit Schokoladengeschmack', 'Haferflocken XXL', 'Cornflakes', 'Hot Hafer Basis Porridge', 'Haferflocken kernig,', 'Porridge Beere, glutenfrei', 'Schoko Chips', 'Haferflocken Großblatt', 'Dinkel gepufft mit Honig gesüßt', 'Haferflocken', 'NESTLE NESQUIK Cerealien', 'Flocons d''Avoine', 'Chillo Pillows - Bio-Kakaokissen', 'FITNESS Cerealien', 'Nougat Bits', 'Rewe Bio Haferflocken zart', 'Dinkel Flakes', 'Cornflakes - Nougat Bits', 'Fiocchi di avena integrali', 'Haferflocken extra zart', 'NESTLE NESQUIK WAVES Cerealien', 'Kellogg''s Smacks', 'Chico Chips', 'NESTLE LION Cereals', 'Porridge Kakao', 'Corn Flakes', 'Dinkel gepufft-mit Honig', 'Haferflocken Kernig', 'Corn Flakes', 'Porridge Beere', 'Cinna Rollies - Bio-Zimtschnecken', 'Dinkel Flakes', 'Oreo O''s', 'Haferflocken', 'Nougat Bits', 'Nesquik DUO', 'Choco Chips', 'Choco Shells', 'Erdnuss-Mais-Mix', 'White Wheaties', 'Haferflocken', 'KitKat Cereal', 'Haferflocken kernig', 'NESTLE CINI-MINIS CHURROS Cerealien', 'Kernige Haferflocken', 'Golden Puffs', 'Kakao Knusper Reis', 'Zarte Haferflocken offen', 'Creamy bits', 'Nestlé Cini Minis Maxi Pack', 'Haferflocken Feinblatt', 'Kellogg''s Crunchy Nut', 'Dinkel Crunchy', 'Weetabix produit à base de blé complet 100%', 'Schoko Hafer Crunchy', 'Haferflocken', 'Cornflakes', 'Haferflocken Kleinblatt', 'Haferflocken kernig', 'KELLOGG''S Cerealien Frosties 400g 2.79€ Packung 1kg 6.64€', 'Haferflocken Feinblatt', 'Cornflakes', 'Hafer Crunchy', 'Dinkel Hafer Crunchy', 'Hafer dinkel porridge', 'Haferflocken', 'Protein Trigo, Avena & Quinoa', 'Choco Balls', 'Porridge Erdbeer-Chia imp', 'Soja Protein Crispies');

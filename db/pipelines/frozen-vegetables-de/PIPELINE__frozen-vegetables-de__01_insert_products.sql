-- PIPELINE (Frozen Vegetables): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-13

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'DE'
  and category = 'Frozen Vegetables'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('4008366006915', '4056489289265', '4061463826985', '4056489447801', '4061463829771', '4061458032513', '4061458011402', '4008366883387', '4056489123262', '4063367113116', '4056489499237', '4061458032568', '4061458032544', '4061459820898', '4056489499244', '4008366012879', '4061458032537', '4056489123279', '4056489230991', '4008366014712', '4008366009435', '4008366013449', '4061458011389', '4061458011426', '4063367112997', '4056489007463', '4061458024730', '4063367113031', '4061458040372', '4063367113055', '4061461634360', '4061458145671', '4063367113093', '4061458011273', '4027016480950', '4008366007196', '4008366006953', '4008366009336', '4056489289241', '4008366002559', '4008366016396', '4061462880957', '4008366009473', '4008366007011', '4008366009886', '4008366883363', '4008366017355', '4061462837173', '4061461634308', '4061463828866', '4061458031806', '4061458104227', '4061461634742', '4063367110788', '4008366015153', '4061458032520', '4008366015214', '4008366013241', '4061458011327', '4056489582731', '4017079411251', '4008366006939', '4061458024778', '4056489456476', '4061458011228', '4056489289258', '4056489123422', '4056489123828', '4063367389894', '4056489122876', '4056489123439', '4008366003303', '4061458011365', '4056489123644', '4061458011297', '4337256846813', '4337256665247', '4311501739280', '4250241201353', '4316268659116', '20046958', '4311501428184', '4250241208796', '4311501739341', '4337256149310', '4316268643221', '4337256693585', '4311501498804', '4311501733516', '4311501498446', '4337256193016', '4316268643214', '4056489447856', '4388860395167', '4250241207768', '20068189', '4250241201193', '4316268527965', '4337185571541', '20486099')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Frozen Vegetables by pipeline',
    ean = null
where country = 'DE'
  and category != 'Frozen Vegetables'
  and identity_key in ('02d38f05e984a79b894c521ae509ae42', '0620a6c702bcfda9d6b0b175cba54023', '062e839c65ebb193d308f9661045fb5d', '0b0cd5dc0e8fcd4e7eab706185302dff', '100e88f4334082a583e92a4393c97217', '153c30966c49dfb848da668288fa270e', '18cb58770a8d244b4b8cde3b57b1823e', '1a7c65a3a9ce86d460418fb8048b3dbd', '1aaf40068c92adaf15bcfdd5897ff2ad', '1be748bfcf15f8970d8a995ccf52caf0', '1eaa9ecf64199fbe776649bf687fb13a', '1f98029a61db6774faa478a18e6c0933', '203672094ac0d389f5870cde3eebc60b', '207a1463d7cfa9579df0096e2330a7e8', '20f6afba44261c0815bf23794f780d42', '22bef5d8c0e88d71b4080f0c4180412f', '24aadb16a2bcb1e23ca3f42df3a4d7db', '26cc70aaf8ee008c008891ce4386f8e9', '2999fa0bce32bfc74cc05671c0cd8f6e', '29ed39856d8ae287150af57831435abb', '2aa620879fbe355146cda8b9c90207c4', '30bc8b0a0a66f29dbe15fe46b81f10f2', '33dd7e61940647540928821f3630a12a', '33eab58e30ba53063bc4a7e4199a583b', '35f0e0756ac10028465c7a5044f6639b', '3b9db8050330e90b5904d769acc9c630', '3bce08cbf5a0fd9433423009315d5bea', '3d0c004eab49269fd9f45ecb6d19887f', '418a480b11971108b067333165fca620', '419efd38d5f819cbce437c2d6d95c710', '45288dae5c8ae5c07d660fcee6015dce', '47c70dd970b8b4aebf56aef5b2144758', '50cb34f428bd7e20798a0e287b51d844', '5224c7ada3e0b9e486dff5b42ab242dd', '52e0812496bc7724499bcc2c47a17a52', '5734a4a4432250b26a1f03ed6c52d782', '5aebafa55a8925f515361d41bfa157c6', '5b0899aa93bb55191f224e8fc1be45be', '5c19a78f718c75d98fdb35bf58fababc', '62f8b7d9ec2eb8e00857ef039369c298', '653d1f4f4fdc720ee6cc2f225276a1da', '670afbb6d993e5324f61c4e0041caea4', '6b5f2a124f5ca227ff244601e0f1ce07', '6c678a94a1ce43ea237715e2f6121dab', '6d5e512df5ee6502ff39c8d1c2926d28', '6d65b9896a11febff4012d7d0899eb0d', '773dce2e9a7656ba394bff9813b202d9', '7d0810f672df8d128c1a1d6351ff3cb8', '7dee0d59505465f2800242aa6a261a5b', '7e29b13883522ba2f53aeb66e976a3c4', '830aeba90b6c1f2c37ea521077364d0f', '883c1ceffa140a9bb56b371884d31af4', '89e9ae851bc46a6f7574eb8cd2007d85', '8b6f157f5f941931374367502d9d1ea9', '8bdb1d72e7d36310972b9082ee873879', '8c84461b0dafef30fd311cbe473afe58', '8df8bdb20e1c44bcb3208545ff07386b', '912a8fb96c93cb3309207e3080ec6012', '933fb6e51effa2bef542ac2fad88746d', '94bd5de7eeb0f78b671f00207ec02fcb', '95a0e73734920ec8a051d563e9d11ca4', '9628bfeba3110590b9d4f50e70dc3ab6', '999f202f4f7477c22a120b9230d266b0', '9be297adea013e014f63b89bfce3a761', '9d98ba8ea940cc715b2821d9cca2758a', 'a11b4aad978e828ccf0c69a57363f092', 'a177e58d2698daaf1ff2cd4c51def74d', 'a8b417df2d07f7b3b14fc86672441e2a', 'aa450563312f9cefa245272806644b43', 'ab2325b351f1e7a4e2cd87525cb30fed', 'aeaca64de19354bd010b9186b31418ac', 'b087b29c6e7474b4d951b8eb0aaf9c35', 'b0c077bba86fb0682f6fd2a87bb0698c', 'b1d19788b4f2368245f0a07aadf07a2f', 'b1ebb8e2163a002d79aca05f7993dc1f', 'b3454de94ceb27e4874b8b4721b5112a', 'b4d7e195f48daced4b34a871456b1777', 'cbf2e2e7edf1a3a58052944b547d498f', 'd125e5f8be0e5429f568ea85c6e94f05', 'd1b7c51bb13835859db70e46b470a94c', 'd5d70a7082f5a5c2e2c294cdd6484d26', 'd62dcdf3eea8114e3ac07b35267c8a51', 'dac040ae79272c38e4dabaa54e49e9af', 'df5d165737425c542b7b4cb73aa3a2d0', 'e008996404230372c91a03e0ec841d78', 'e351b6f4dfa26a5b705591594b560cb0', 'e397fb1851fc67038496a6fb2a4732d0', 'e79a3830cb8f1f2e8fa06d7ddcd14424', 'ee52b777809c2c28526c68e56fe5228c', 'f07303ca3303f969760e096aa6b767dc', 'f2fcf8164a6278dd12b2ff6f8bef590b', 'f521282fcbc8d8a5b04b3b70dcadf6d6', 'f7126c7276c2aef9319c3066af103b5b', 'f9421d9423da3ad50fa29a585e63db95', 'f9817b25597f4d7dc1491174ff321660', 'fa3265019a4da5585baa3013a29bcb24', 'fabca24997d46bfca653222da8ca42f0', 'fc387d2153b66c4db66910a76ee4a683', 'fd9da5e2fcaa76804a0867e0156fd740', 'ffce515ac53f05fed38aae34ed533348')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüse Pfanne alla Toscana', 'not-applicable', null, 'none', '4008366006915'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Bio Gemüse Pfanne Französische Art', 'not-applicable', 'Lidl', 'none', '4056489289265'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'China Gemüse', 'not-applicable', 'Aldi', 'none', '4061463826985'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Asiatische Art', 'fried', 'Lidl', 'none', '4056489447801'),
  ('DE', 'Bio', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne französische Art', 'not-applicable', 'Aldi', 'none', '4061463829771'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse - Asiatische Art', 'not-applicable', 'Aldi', 'none', '4061458032513'),
  ('DE', 'Gut Bio', 'Grocery', 'Frozen Vegetables', 'Bio-Gemüsepfanne - Französische Art', 'not-applicable', 'Aldi', 'none', '4061458011402'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüse-Bowl - Oriental Style', 'not-applicable', 'Aldi', 'none', '4008366883387'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse', 'not-applicable', 'Lidl', 'none', '4056489123262'),
  ('DE', 'K-Bio', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Asiatische Art', 'not-applicable', 'Kaufland', 'none', '4063367113116'),
  ('DE', 'Vitasia', 'Grocery', 'Frozen Vegetables', 'Wok Gemüse Thai', 'not-applicable', 'Lidl', 'none', '4056489499237'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse - Italienische Art', 'not-applicable', 'Aldi', 'none', '4061458032568'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse - Feinschmecker Art', 'not-applicable', 'Aldi', 'none', '4061458032544'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Buttergemüse XXL', 'not-applicable', 'Aldi', 'none', '4061459820898'),
  ('DE', 'Vitasia', 'Grocery', 'Frozen Vegetables', 'Wok gemüse', 'not-applicable', 'Lidl', 'none', '4056489499244'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüse Mix Thai', 'not-applicable', 'Kaufland', 'none', '4008366012879'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Kalifornische Art', 'not-applicable', 'Aldi', 'none', '4061458032537'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse erntefrisch tiefgefroren', 'not-applicable', 'Lidl', 'none', '4056489123279'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Sommergarten', 'not-applicable', 'Lidl', 'none', '4056489230991'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Suppengrün', 'not-applicable', null, 'none', '4008366014712'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüse Mix Asiatische Küche', 'not-applicable', null, 'none', '4008366009435'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Pasta mit Gemüse mediterraner Art', 'not-applicable', 'Aldi', 'none', '4008366013449'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne', 'not-applicable', 'Aldi', 'none', '4061458011389'),
  ('DE', 'Aldi Süd', 'Grocery', 'Frozen Vegetables', 'Bio-Gemüsepfanne - Mediterrane Art', 'not-applicable', 'Aldi', 'none', '4061458011426'),
  ('DE', 'K Classic', 'Grocery', 'Frozen Vegetables', 'Pfanngemüse Asiatiache Art', 'not-applicable', 'Kaufland', 'none', '4063367112997'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Bio-Gemüsepfanne Asiatische Art', 'not-applicable', 'Lidl', 'none', '4056489007463'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Bunte Gemüsemischung, tiefgefroren', 'not-applicable', 'Aldi', 'none', '4061458024730'),
  ('DE', 'Kaufland', 'Grocery', 'Frozen Vegetables', 'Pfanngemüse', 'not-applicable', 'Kaufland', 'none', '4063367113031'),
  ('DE', 'Gartenkrone', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse', 'not-applicable', 'Aldi', 'none', '4061458040372'),
  ('DE', 'K-Classic', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Italienische Art', 'not-applicable', 'Kaufland', 'none', '4063367113055'),
  ('DE', 'All seasons', 'Grocery', 'Frozen Vegetables', 'Bunte Gemüsemischung', 'not-applicable', 'Aldi', 'none', '4061461634360'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Gemüse Rahm-Kaisergemüse', 'not-applicable', 'Aldi', 'none', '4061458145671'),
  ('DE', 'K-Classic', 'Grocery', 'Frozen Vegetables', 'Gemüse Rustikale Art', 'not-applicable', 'Kaufland', 'none', '4063367113093'),
  ('DE', 'Gut Bio', 'Grocery', 'Frozen Vegetables', 'Bio-Kaisergemüse', 'not-applicable', 'Aldi', 'none', '4061458011273'),
  ('DE', 'Genuss pur', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Italienische Art', 'not-applicable', 'Netto', 'none', '4027016480950'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Frosta Gemüse Pfanne Curry Kokos', 'not-applicable', null, 'none', '4008366007196'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne a la Provence', 'not-applicable', null, 'none', '4008366006953'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüse Pfanne Style Asia Curry', 'fried', null, 'none', '4008366009336'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Bio Mediterrane Art', 'not-applicable', null, 'none', '4056489289241'),
  ('DE', 'EDEKA FRoSTA', 'Grocery', 'Frozen Vegetables', 'Frosta Gemüsemix Asiatische Küche', 'not-applicable', null, 'none', '4008366002559'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Wok Mix', 'not-applicable', null, 'none', '4008366016396'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', null, 'none', '4061462880957'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüse Mix italienische Küche', 'not-applicable', null, 'none', '4008366009473'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Sommergarten', 'not-applicable', null, 'none', '4008366007011'),
  ('DE', 'Fertiggerichte', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne al Italiana', 'not-applicable', null, 'none', '4008366009886'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüse-Bowl - Asian Style', 'not-applicable', null, 'none', '4008366883363'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Frosta Lieblingsgemüsemix ungewürzt', 'not-applicable', null, 'none', '4008366017355'),
  ('DE', 'Bio', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', null, 'none', '4061462837173'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse', 'not-applicable', null, 'none', '4061461634308'),
  ('DE', 'Bio', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne mediterrane Art', 'not-applicable', null, 'none', '4061463828866'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', null, 'none', '4061458031806'),
  ('DE', 'Gut bio', 'Grocery', 'Frozen Vegetables', 'Bio-Buttergemüse', 'not-applicable', null, 'none', '4061458104227'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'TK Gemüse - Brokkoli', 'not-applicable', null, 'none', '4061461634742'),
  ('DE', 'Kaufland', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse', 'not-applicable', null, 'none', '4063367110788'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüse Pfanne mit Falafeln & bunten Karotten', 'not-applicable', null, 'none', '4008366015153'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse - Rustikale Art', 'not-applicable', null, 'none', '4061458032520'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne mit gegrillter Zuchini & Kichererbsen', 'not-applicable', null, 'none', '4008366015214'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne mit Kichererbsen & Cranberries', 'not-applicable', null, 'none', '4008366013241'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Bio-Suppengemüse', 'not-applicable', null, 'none', '4061458011327'),
  ('DE', 'Culinea', 'Grocery', 'Frozen Vegetables', 'Kürbis Quinoa Bowl', 'not-applicable', null, 'none', '4056489582731'),
  ('DE', 'Frenzel', 'Grocery', 'Frozen Vegetables', 'Gemüse auf Reis', 'not-applicable', null, 'none', '4017079411251'),
  ('DE', 'FRoSTA', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Thai', 'not-applicable', null, 'none', '4008366006939'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Gemüse Blumenkohl-Röschen', 'not-applicable', null, 'none', '4061458024778'),
  ('DE', 'Greenyard Frozen Langemark', 'Grocery', 'Frozen Vegetables', 'Buckwheat & broccoli', 'not-applicable', 'Lidl', 'none', '4056489456476'),
  ('DE', 'All Seasons', 'Grocery', 'Frozen Vegetables', 'Rahm-Spinat', 'not-applicable', 'Aldi', 'none', '4061458011228'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Melange de légumes à l asiatique', 'not-applicable', 'Lidl', 'none', '4056489289258'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Erbsen', 'not-applicable', 'Lidl', 'none', '4056489123422'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Sommer Gemüse', 'not-applicable', null, 'none', '4056489123828'),
  ('DE', 'K Classic', 'Grocery', 'Frozen Vegetables', 'Rosmarinkartoffeln', 'not-applicable', 'Kaufland', 'none', '4063367389894'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Vegetable with fine butter herb sauce', 'not-applicable', 'Lidl', 'none', '4056489122876'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'TK - Erbsen', 'not-applicable', 'Lidl', 'none', '4056489123439'),
  ('DE', 'Frosta', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Mexicana', 'not-applicable', null, 'none', '4008366003303'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Brokkoli', 'not-applicable', 'Aldi', 'none', '4061458011365'),
  ('DE', 'Lidl', 'Grocery', 'Frozen Vegetables', 'Sojabohnen', 'not-applicable', 'Lidl', 'none', '4056489123644'),
  ('DE', 'Aldi', 'Grocery', 'Frozen Vegetables', 'Junge Erbsen', 'not-applicable', 'Aldi', 'none', '4061458011297'),
  ('DE', 'REWE Bio', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne nach französischer Art', 'not-applicable', null, 'none', '4337256846813'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Italienische Art', 'not-applicable', null, 'none', '4337256665247'),
  ('DE', 'Edeka', 'Grocery', 'Frozen Vegetables', 'Asia Style Gemüsepfanne', 'fried', null, 'none', '4311501739280'),
  ('DE', 'Iglo', 'Grocery', 'Frozen Vegetables', 'Gemüse-Ideen Italienisch', 'not-applicable', null, 'none', '4250241201353'),
  ('DE', 'Genuss Welt', 'Grocery', 'Frozen Vegetables', 'Pfannen Gemüse Mexikanische Art', 'not-applicable', 'Netto', 'none', '4316268659116'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', 'Lidl', 'none', '20046958'),
  ('DE', 'Edeka', 'Grocery', 'Frozen Vegetables', 'TK-Eigen EDEKA GEMÜSE Junger Spinat 450g 1.49€ 1kg 3.32€', 'not-applicable', null, 'none', '4311501428184'),
  ('DE', 'Iglo', 'Grocery', 'Frozen Vegetables', 'Veggie Love - Gemüse Curry', 'not-applicable', null, 'none', '4250241208796'),
  ('DE', 'Edeka', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Italienische Art', 'not-applicable', null, 'none', '4311501739341'),
  ('DE', 'REWE Bio', 'Grocery', 'Frozen Vegetables', 'TK Buttergemüse', 'not-applicable', null, 'none', '4337256149310'),
  ('DE', 'BioBio', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse mediterrane Art', 'not-applicable', 'Netto', 'none', '4316268643221'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Frozen Vegetables', 'Wok Mix ungewürzt', 'not-applicable', null, 'none', '4337256693585'),
  ('DE', 'Gut & Günstig', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', null, 'none', '4311501498804'),
  ('DE', 'Edeka Bio', 'Grocery', 'Frozen Vegetables', 'Bio Buttergemüse', 'not-applicable', null, 'none', '4311501733516'),
  ('DE', 'Edeka', 'Grocery', 'Frozen Vegetables', 'Butter Gemüse', 'not-applicable', null, 'none', '4311501498446'),
  ('DE', 'REWE Bio', 'Grocery', 'Frozen Vegetables', 'Kaisergemüse', 'not-applicable', null, 'none', '4337256193016'),
  ('DE', 'BioBio', 'Grocery', 'Frozen Vegetables', 'Pfannengemüse Französische Art', 'not-applicable', 'Netto', 'none', '4316268643214'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Mixed vegetable italian style', 'not-applicable', null, 'none', '4056489447856'),
  ('DE', 'REWE Beste Wahl', 'Grocery', 'Frozen Vegetables', 'Gemüsepfanne Asiatische Art in einer Sauce mit Kokosmilch 4388860395167', 'not-applicable', null, 'none', '4388860395167'),
  ('DE', 'Iglo', 'Grocery', 'Frozen Vegetables', 'Iglo Brokkoli Buchweizen 4250241207768 Gemüsemischung mit schwarzen Bohnen, Buchweizen und schwarzem Reis', 'not-applicable', null, 'none', '4250241207768'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', '1 Beutel Gemüsepfanne Asiatische Art', 'not-applicable', 'Lidl', 'none', '20068189'),
  ('DE', 'Iglo', 'Grocery', 'Frozen Vegetables', 'Rahm-Gemüse Blumenkohl', 'not-applicable', null, 'none', '4250241201193'),
  ('DE', 'Beste Ernte', 'Grocery', 'Frozen Vegetables', 'Gemüse', 'not-applicable', 'Netto', 'none', '4316268527965'),
  ('DE', 'K Classic', 'Grocery', 'Frozen Vegetables', 'Buttergemüse', 'not-applicable', 'Kaufland', 'none', '4337185571541'),
  ('DE', 'Freshona', 'Grocery', 'Frozen Vegetables', 'Festtagsgemüse', 'not-applicable', 'Lidl', 'none', '20486099')
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
where country = 'DE' and category = 'Frozen Vegetables'
  and is_deprecated is not true
  and product_name not in ('Gemüse Pfanne alla Toscana', 'Bio Gemüse Pfanne Französische Art', 'China Gemüse', 'Gemüsepfanne Asiatische Art', 'Gemüsepfanne französische Art', 'Pfannengemüse - Asiatische Art', 'Bio-Gemüsepfanne - Französische Art', 'Gemüse-Bowl - Oriental Style', 'Kaisergemüse', 'Pfannengemüse Asiatische Art', 'Wok Gemüse Thai', 'Pfannengemüse - Italienische Art', 'Pfannengemüse - Feinschmecker Art', 'Buttergemüse XXL', 'Wok gemüse', 'Gemüse Mix Thai', 'Pfannengemüse Kalifornische Art', 'Kaisergemüse erntefrisch tiefgefroren', 'Gemüsepfanne Sommergarten', 'Suppengrün', 'Gemüse Mix Asiatische Küche', 'Pasta mit Gemüse mediterraner Art', 'Gemüsepfanne', 'Bio-Gemüsepfanne - Mediterrane Art', 'Pfanngemüse Asiatiache Art', 'Bio-Gemüsepfanne Asiatische Art', 'Bunte Gemüsemischung, tiefgefroren', 'Pfanngemüse', 'Kaisergemüse', 'Pfannengemüse Italienische Art', 'Bunte Gemüsemischung', 'Gemüse Rahm-Kaisergemüse', 'Gemüse Rustikale Art', 'Bio-Kaisergemüse', 'Pfannengemüse Italienische Art', 'Frosta Gemüse Pfanne Curry Kokos', 'Gemüsepfanne a la Provence', 'Gemüse Pfanne Style Asia Curry', 'Gemüsepfanne Bio Mediterrane Art', 'Frosta Gemüsemix Asiatische Küche', 'Gemüsepfanne Wok Mix', 'Buttergemüse', 'Gemüse Mix italienische Küche', 'Gemüsepfanne Sommergarten', 'Gemüsepfanne al Italiana', 'Gemüse-Bowl - Asian Style', 'Frosta Lieblingsgemüsemix ungewürzt', 'Buttergemüse', 'Kaisergemüse', 'Gemüsepfanne mediterrane Art', 'Buttergemüse', 'Bio-Buttergemüse', 'TK Gemüse - Brokkoli', 'Kaisergemüse', 'Gemüse Pfanne mit Falafeln & bunten Karotten', 'Pfannengemüse - Rustikale Art', 'Gemüsepfanne mit gegrillter Zuchini & Kichererbsen', 'Gemüsepfanne mit Kichererbsen & Cranberries', 'Bio-Suppengemüse', 'Kürbis Quinoa Bowl', 'Gemüse auf Reis', 'Gemüsepfanne Thai', 'Gemüse Blumenkohl-Röschen', 'Buckwheat & broccoli', 'Rahm-Spinat', 'Melange de légumes à l asiatique', 'Erbsen', 'Sommer Gemüse', 'Rosmarinkartoffeln', 'Vegetable with fine butter herb sauce', 'TK - Erbsen', 'Gemüsepfanne Mexicana', 'Brokkoli', 'Sojabohnen', 'Junge Erbsen', 'Gemüsepfanne nach französischer Art', 'Gemüsepfanne Italienische Art', 'Asia Style Gemüsepfanne', 'Gemüse-Ideen Italienisch', 'Pfannen Gemüse Mexikanische Art', 'Buttergemüse', 'TK-Eigen EDEKA GEMÜSE Junger Spinat 450g 1.49€ 1kg 3.32€', 'Veggie Love - Gemüse Curry', 'Pfannengemüse Italienische Art', 'TK Buttergemüse', 'Pfannengemüse mediterrane Art', 'Wok Mix ungewürzt', 'Buttergemüse', 'Bio Buttergemüse', 'Butter Gemüse', 'Kaisergemüse', 'Pfannengemüse Französische Art', 'Mixed vegetable italian style', 'Gemüsepfanne Asiatische Art in einer Sauce mit Kokosmilch 4388860395167', 'Iglo Brokkoli Buchweizen 4250241207768 Gemüsemischung mit schwarzen Bohnen, Buchweizen und schwarzem Reis', '1 Beutel Gemüsepfanne Asiatische Art', 'Rahm-Gemüse Blumenkohl', 'Gemüse', 'Buttergemüse', 'Festtagsgemüse');

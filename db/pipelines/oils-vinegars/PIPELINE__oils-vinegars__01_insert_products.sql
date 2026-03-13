-- PIPELINE (Oils & Vinegars): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: 2026-03-12

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, deprecated_reason = 'Replaced by pipeline refresh', ean = null
where country = 'PL'
  and category = 'Oils & Vinegars'
  and is_deprecated is not true;

-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ('5905784317014', '5906823002342', '5903264000357', '5903264000555', '5901752702523', '5900311000209', '5900012000232', '5900012003608', '5906395631087', '5901882120914', '5903707849857', '5905279458000', '5900012010002', '5902768584295', '5903264001460', '5900012004858', '5903264000104', '5903264000142', '5904215146568', '5904730127844', '5901752701656', '5900247002438', '5903240278794', '5903111808037', '5904730127912', '8410660053186', '20729783', '5900229040984', '5900012006043', '5906245444324', '5901844101791', '5907544131038', '5901658000013', '5900012003196', '5900012004841', '8410660081691', '5900311002500', '5908249970687', '5900571100039', '5907559279084', '5903240972135', '5903264000883', '5904960012545', '5906245444157', '5904730127448', '5902037005087', '5907569005864', '5902150284123', '5906185012744', '5902627090516', '5906395631384', '5900085011180', '5903900941358', '5908235944975', '5204401580061', '8851046010025', '8004123005920', '5900783009960', '4056489973010', '8410660078929', '3560070973743', '5601855179009', '3245677726366', '4056489069553', '4056489158196', '3560070340316', '20013578', '20753504', '5410556213406', '3560070340408', '2000000552286', '20564933', '40875224', '3560071267643', '80053828', '5601252115983', '4056489095897', '8410660073368', '8018440050129', '2008080122207', '20706784', '8004123000284', '8423329113138', '8004123004237', '8003250000129', '5203447760055', '8410660073306', '8008460223139', '8424536944157', '8423329113121', '8004123004664', '8004123004909', '5712872292470', '80054627', '5601855579021', '8004123007306', '5601855579007', '4260355580572', '4260355580558', '8004123002509', '8594199375251', '8004123002721', '5601999400014', '8410660091416', '5200124185620', '8437000542445', '0720189810190', '0062273551283', '3160920774126')
  and ean is not null;

-- 0c. Deprecate cross-category products whose identity_key collides with this batch
update products
set is_deprecated = true,
    deprecated_reason = 'Reassigned to Oils & Vinegars by pipeline',
    ean = null
where country = 'PL'
  and category != 'Oils & Vinegars'
  and identity_key in ('00cecd95497d1cb78be90eb880d3fbe2', '0328dc443d9e2edc4c475633b316e5db', '04ff53479fe0c15e357a982e3a9f80f5', '0a280123576c89d4f444014d19fc4e46', '0b961687be8514fb14501a2bc7983784', '0e4a15a028251fe6f1c34e2ce2631d0a', '0fdf3d1c6240e1ef8f7376fe779375d2', '1335c6865f7894da0e44f6d4ba50cdfe', '1507d7aad3a3e643d89ba8a8258fffba', '1684a9b999aef6200ae19c1c7e13a254', '199c66ec435d8c2000bca63af33aeae9', '1b0c800731687cb60841013f059d7a82', '23832e6bdb58366ed694cc5287a2cb89', '2d1039a5d367ac7b1fbcfc9f0eed3633', '2d24b21a9d48af2be4df86938a4a3660', '327ca1735e111be3b9ae71fa70ab2c3f', '351484ffc20feb5591af8d4adf0a2f6b', '358de9cb05bb108239a58918d42b8177', '36568f43777432785d1ccbadb5b4dad5', '39b2b1c1c7dc6d7330206330e069688e', '3ae1e4b851dcd1be74238bf761edf72a', '3e99f6b7ddbbb9079b22959291f018f1', '437f79dd1b3c99d8645d579206d74fed', '468def28e7affddd4bf874f84059e646', '487c2b35bcd7e487781cfaf0e736d4ab', '4d2a6413f41e7b0c03c7510a569789a0', '4e9a87b9240fa694e6fbde626c1f75ef', '51fba37fb8fc8857c7facaed9ea019dc', '541dbe52e3f19d6b61ea2b85cc2b90ca', '57f89c2d81ab98dcfd69b815d7b5b28c', '57ff857c62ed2ea18b71a439e747e519', '589a7368e000ab6f08c0c6e8f995cfbe', '58a6264177cb183e7643f027681f7a0e', '5980621b4510a3aa76f66096dbb798f7', '5ece1d3099a31be46a34a234b4c83c82', '5ed4e334ebe31ffaa7806d42c69e264b', '61ddfd8a8b28c0df5a067056ba639009', '6359350f8635c421801f175f94fd4b86', '65797648fe70130f497a363211da7bb0', '667bd80085b89e4b62d662ccc6371c17', '66b5968ff19e929d55e46b7a4387d786', '69d4a62903d28d06649352cbd36545e5', '6a6a3b48e019c37644e45826d7a1e6e2', '6bd41dd405aab2bec15204fa561eb539', '6e2972ee797a59f1c4f235af8575ef54', '74c2ab8ff3d77b0c9205bd6202b43982', '786b569acd0aee6ab057cfcef7e0ed0a', '78cc570af9c697b7fe7f5e4230b651d4', '7a3607364104a9805abb19f57b96bf50', '7b34955d3d6338ebc8775699608a2271', '7b616ecb17d21edb584dafe5b7ab66eb', '7b6e29b8059d4ea0201f81d6958c3e9e', '7e853411965890c4e7fa01be4651ed08', '7eac442f3de8752efb2f474d1929a44a', '7fe976a6590c08ffeea1c8707fcba6b7', '827521ce3f2dc83204e3a6f036310ba9', '89621501edbc3163bea6369c729b7276', '8a2c5ddaa69529f4d63dbd3fc0bfe5d5', '8daddb968bd94a03378794973ca00f14', '8f7fc29d6719f656e6f36a2fa1063d4f', '91ec2b7f4b9495dd71fa80bf366c7dfd', '93c422f5e7a38e9f2338b6df36466d3d', '9736963fef96d19f85d5a472be656c29', '97f84f57aa9dc4accc85f299bb0871fc', '9aaec9e7c2c785f397329b2151a65783', '9ba02c0e0612112ccb8add9c3bc6d5b3', '9d9d04bf0de018359b24ee3d1c6e0745', '9f329a6967e6f9cab42e2d6bccf3bbe8', 'a049855240bc511eea01c09247d80732', 'a10d0b60743cc7ff62b5ddfbe2586d38', 'a212fe15bca7bfcf818fe47290acd721', 'a2f94bf125fddd699c93e9a49a7100cd', 'a3b98f63f9565357693858a93065821b', 'a40bddb67a0c719d2b0744f4f6597984', 'a6d4453336d7b3da23ff2b5ec8728158', 'aa8f50ca80453c055b1f2fd4c51b4be1', 'ab21521a17d53e7b789696f571edf560', 'ad0ed033af26b7c0343a36e887afae9d', 'b841100743e7a7b0158bcda8e1695c5e', 'b9407093424fdf63a27917fd369c65cc', 'bb18130490f7dd93aa3460970bd1dbfd', 'bf0a157b94a22efec014852421554b09', 'bf12c9caec1cfa9f9df499e664545884', 'c07b2880f52c2585730d1d55cfd5de4f', 'c0eecb5fd00ca5e9bbc8d8ab673b063c', 'c251e89c7416f8825c71715330ab4239', 'c26889d13fd1c90e3c9755adabc0970e', 'c35c01f09e52bf1afc16dd896cb193c9', 'c4dc9c6310707fe949efc96b6a09bca5', 'c7823b890dc802113b7cc08a2829d9bd', 'c8b2e1a94207e223100008d24a68da38', 'cb73150df0191e9fd3e54b1bc019a4ea', 'cf520bb8da5156b907b85c95c6ab87af', 'd08dc836490ad09a62f468267de6b72f', 'd09ef7a6bbbadd977e6d9d481f2f015e', 'd259ca92339180815938d71829621b17', 'd346295643bef9728c8190e91190a591', 'd57a798f784e5fc6a5066513f5a62254', 'd7be64ec1c4951d018f897982ad0e5b4', 'd954eda0bf56f684f276947ee1b57cc1', 'e0b4c815f6817364c7c22a71163e7627', 'e2c747d2b929aa9b87a824e65dccd120', 'e44f8e4ce37592bb652d6552c302b719', 'e955ebbfef2cd86b94f4683754dfecac', 'ea9c9a9b002201ac0567c3ddbbb71e5d', 'f6a6743177c1fd0f89a92043e67bef61', 'f90d77d719361ec440bd7825249872cf', 'ff3fbecbf65c8224367bc5652d7656c4', 'fff718feda35a24175d16cee2b66ecfd')
  and is_deprecated is not true;

-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
  ('PL', 'Carrefour', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'not-applicable', 'Carrefour', 'none', '5905784317014'),
  ('PL', 'Biedronka', 'Grocery', 'Oils & Vinegars', 'Wyborny olej słonecznikowy', 'not-applicable', 'Biedronka', 'none', '5906823002342'),
  ('PL', 'Wielkopolski', 'Grocery', 'Oils & Vinegars', 'Wielkopolski olej słonecznikowy rafinowany', 'not-applicable', 'Kaufland', 'none', '5903264000357'),
  ('PL', 'OEL Polska', 'Grocery', 'Oils & Vinegars', 'Wielkopolski olej rzepakowy tłoczony tylko raz, rafinowany.', 'not-applicable', 'Auchan', 'none', '5903264000555'),
  ('PL', 'House of Asia', 'Grocery', 'Oils & Vinegars', 'Ocet ryżowy', 'not-applicable', 'Auchan', 'none', '5901752702523'),
  ('PL', 'ZT Kruszwica', 'Grocery', 'Oils & Vinegars', 'Bartek olej słonecznikowy', 'not-applicable', null, 'none', '5900311000209'),
  ('PL', 'Kujawski', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'not-applicable', null, 'none', '5900012000232'),
  ('PL', 'Kujawski', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy z pierwszego tłoczenia', 'not-applicable', null, 'none', '5900012003608'),
  ('PL', 'Oliwa kaszubska', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy tłoczony na zimno', 'not-applicable', null, 'none', '5906395631087'),
  ('PL', 'Vifon', 'Grocery', 'Oils & Vinegars', 'Ocet ryżowy', 'not-applicable', null, 'none', '5901882120914'),
  ('PL', 'Asia Kitchen', 'Grocery', 'Oils & Vinegars', 'Ocet ryżowy', 'not-applicable', null, 'none', '5903707849857'),
  ('PL', 'Mi''Ra', 'Grocery', 'Oils & Vinegars', 'Olej z ryżu', 'not-applicable', null, 'none', '5905279458000'),
  ('PL', 'Slonecznikowy', 'Grocery', 'Oils & Vinegars', 'Olej wyborny', 'not-applicable', 'Biedronka', 'none', '5900012010002'),
  ('PL', 'Komagra', 'Grocery', 'Oils & Vinegars', 'Polski olej rzepakowy', 'not-applicable', 'Biedronka', 'none', '5902768584295'),
  ('PL', 'Wyborny Olej', 'Grocery', 'Oils & Vinegars', 'Wyborny olej rzepakowy', 'not-applicable', 'Biedronka', 'none', '5903264001460'),
  ('PL', 'Kujawski', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy pomidor czosnek bazylia', 'not-applicable', 'Biedronka', 'none', '5900012004858'),
  ('PL', 'Wyborny', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy', 'not-applicable', 'Biedronka', 'none', '5903264000104'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Olej wyborny rzepakowy', 'not-applicable', 'Biedronka', 'none', '5903264000142'),
  ('PL', 'Auchan', 'Grocery', 'Oils & Vinegars', 'Rafinowany olej rzepakowy', 'not-applicable', 'Auchan', 'none', '5904215146568'),
  ('PL', 'Vitanella', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy, bezzapachowy', 'not-applicable', 'Biedronka', 'none', '5904730127844'),
  ('PL', 'House of Asia', 'Grocery', 'Oils & Vinegars', 'Olej z prażonego sezamu', 'not-applicable', null, 'none', '5901752701656'),
  ('PL', 'Bunge', 'Grocery', 'Oils & Vinegars', 'Optima Cardio', 'not-applicable', 'Biedronka', 'none', '5900247002438'),
  ('PL', 'Intenson', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy rafinowany', 'not-applicable', 'Kaufland', 'none', '5903240278794'),
  ('PL', 'Look Food', 'Grocery', 'Oils & Vinegars', 'Olej lniany ekologiczny', 'not-applicable', 'Netto', 'none', '5903111808037'),
  ('PL', 'Lewiatan', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy', 'not-applicable', 'Lewiatan', 'none', '5904730127912'),
  ('PL', 'Coosur', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'not-applicable', 'Kaufland', 'none', '8410660053186'),
  ('PL', 'Lidl Primadonna', 'Grocery', 'Oils & Vinegars', 'Bio Hiszpańska oliwa z oliwek.', 'not-applicable', 'Lidl', 'none', '20729783'),
  ('PL', 'Bielmar', 'Grocery', 'Oils & Vinegars', 'Sonnenblumen Öl', 'not-applicable', null, 'none', '5900229040984'),
  ('PL', 'Oleo', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy', 'not-applicable', null, 'none', '5900012006043'),
  ('PL', 'Semco', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy', 'not-applicable', null, 'none', '5906245444324'),
  ('PL', 'Culineo', 'Grocery', 'Oils & Vinegars', 'Ocet spirytusowy 10%', 'not-applicable', null, 'none', '5901844101791'),
  ('PL', 'GustoBello', 'Grocery', 'Oils & Vinegars', 'Krem z octem balsamicznym', 'not-applicable', null, 'none', '5907544131038'),
  ('PL', 'Pegaz', 'Grocery', 'Oils & Vinegars', 'Ocet spirytusowy 10%', 'not-applicable', null, 'none', '5901658000013'),
  ('PL', 'Kujawski', 'Grocery', 'Oils & Vinegars', 'Olej 3 ziarna', 'not-applicable', null, 'none', '5900012003196'),
  ('PL', 'Kujawski', 'Grocery', 'Oils & Vinegars', 'Kujawski czosnek bazylia', 'not-applicable', null, 'none', '5900012004841'),
  ('PL', 'Biedronka', 'Grocery', 'Oils & Vinegars', 'Olej z awokado z pierwszego tłoczenia', 'not-applicable', 'Biedronka', 'none', '8410660081691'),
  ('PL', 'Oliver', 'Grocery', 'Oils & Vinegars', 'Olej', 'not-applicable', null, 'none', '5900311002500'),
  ('PL', 'EkoWital', 'Grocery', 'Oils & Vinegars', 'Ekologiczny Olej Kokosowy', 'not-applicable', null, 'none', '5908249970687'),
  ('PL', 'Felix', 'Grocery', 'Oils & Vinegars', 'Orzeszki z pieca', 'not-applicable', null, 'none', '5900571100039'),
  ('PL', 'LenVitol', 'Grocery', 'Oils & Vinegars', 'Olej lniany', 'not-applicable', null, 'none', '5907559279084'),
  ('PL', 'Olejowy Raj', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy', 'not-applicable', null, 'none', '5903240972135'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Wyborny Delio', 'not-applicable', null, 'none', '5903264000883'),
  ('PL', 'Oleofarm', 'Grocery', 'Oils & Vinegars', 'Olej z pestek dyni', 'not-applicable', null, 'none', '5904960012545'),
  ('PL', 'Semco', 'Grocery', 'Oils & Vinegars', 'Oil', 'not-applicable', null, 'none', '5906245444157'),
  ('PL', 'Premium Gold Master', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy', 'not-applicable', null, 'none', '5904730127448'),
  ('PL', 'Olejarnia Świecie', 'Grocery', 'Oils & Vinegars', 'Naturalny olej konopny', 'not-applicable', 'Delikatesy Centrum', 'none', '5902037005087'),
  ('PL', 'Radix-Bis', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy rafinowany', 'not-applicable', null, 'none', '5907569005864'),
  ('PL', 'Go Bio', 'Grocery', 'Oils & Vinegars', 'Olej Kokosowy', 'not-applicable', null, 'none', '5902150284123'),
  ('PL', 'Vita Natura', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy Bio', 'not-applicable', null, 'none', '5906185012744'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy bezzapachowy rafinowany', 'not-applicable', null, 'none', '5902627090516'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Olej z czarnuszki', 'not-applicable', null, 'none', '5906395631384'),
  ('PL', 'Nestlé', 'Grocery', 'Oils & Vinegars', 'Przyprawa Maggi', 'not-applicable', null, 'none', '5900085011180'),
  ('PL', 'Iorgos', 'Grocery', 'Oils & Vinegars', 'Olive Oil', 'not-applicable', null, 'none', '5903900941358'),
  ('PL', 'PPHU &quot;OLMAJ&quot; Sławomir Majewski', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy zwyczajny', 'not-applicable', null, 'none', '5908235944975'),
  ('PL', 'Lyrakis Family', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek z pierwszego tłoczenia', 'not-applicable', null, 'none', '5204401580061'),
  ('PL', 'Suriny', 'Grocery', 'Oils & Vinegars', 'Olej z ryżu 100%', 'not-applicable', null, 'none', '8851046010025'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Olej z ryżu', 'not-applicable', null, 'none', '8004123005920'),
  ('PL', 'Pudliszki', 'Grocery', 'Oils & Vinegars', 'Pudliszki', 'not-applicable', null, 'none', '5900783009960'),
  ('PL', 'Primadonna', 'Grocery', 'Oils & Vinegars', 'Extra Virgin Olive Oil', 'not-applicable', 'Lidl', 'none', '4056489973010'),
  ('PL', 'Casa de Azeite', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek', 'not-applicable', 'Biedronka', 'none', '8410660078929'),
  ('PL', 'Carrefour BIO', 'Grocery', 'Oils & Vinegars', 'Huile d''olive vierge extra', 'not-applicable', 'Carrefour', 'none', '3560070973743'),
  ('PL', 'Casa de Azeite', 'Grocery', 'Oils & Vinegars', 'Casa de Azeite', 'not-applicable', 'Biedronka', 'none', '5601855179009'),
  ('PL', 'Auchan', 'Grocery', 'Oils & Vinegars', 'Auchan huile d''olive extra vierge verre 0.75l pack b', 'not-applicable', 'Auchan', 'none', '3245677726366'),
  ('PL', 'Vita D''or', 'Grocery', 'Oils & Vinegars', 'Sonnenblumenöl', 'not-applicable', 'Lidl', 'none', '4056489069553'),
  ('PL', 'Vita D´or', 'Grocery', 'Oils & Vinegars', 'Sonnenblumenöl', 'not-applicable', 'Lidl', 'none', '4056489158196'),
  ('PL', 'Carrefour', 'Grocery', 'Oils & Vinegars', 'Huile De Tournesol', 'not-applicable', 'Carrefour', 'none', '3560070340316'),
  ('PL', 'Vita d''Or', 'Grocery', 'Oils & Vinegars', 'Rapsöl', 'not-applicable', 'Lidl', 'none', '20013578'),
  ('PL', 'Vita D''or', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy', 'not-applicable', 'Lidl', 'none', '20753504'),
  ('PL', 'Kaufland', 'Grocery', 'Oils & Vinegars', 'Rapsöl', 'not-applicable', 'Kaufland', 'none', '5410556213406'),
  ('PL', 'SimplCarrefour', 'Grocery', 'Oils & Vinegars', 'Huile de Colza', 'not-applicable', 'Carrefour', 'none', '3560070340408'),
  ('PL', 'Złote Łany', 'Grocery', 'Oils & Vinegars', 'Olej rzepakowy', 'not-applicable', 'Dino', 'none', '2000000552286'),
  ('PL', 'Vitasia', 'Grocery', 'Oils & Vinegars', 'Vinagre de arroz', 'not-applicable', 'Lidl', 'none', '20564933'),
  ('PL', 'Lidl', 'Grocery', 'Oils & Vinegars', 'Olej kokosowy', 'not-applicable', 'Lidl', 'none', '40875224'),
  ('PL', 'Carrefour', 'Grocery', 'Oils & Vinegars', 'Huile pour friture', 'fried', 'Carrefour', 'none', '3560071267643'),
  ('PL', 'Monini', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek', 'not-applicable', null, 'none', '80053828'),
  ('PL', 'Gallo', 'Grocery', 'Oils & Vinegars', 'Olive Oil', 'not-applicable', null, 'none', '5601252115983'),
  ('PL', 'Lidl', 'Grocery', 'Oils & Vinegars', 'Huile d''olive vierge extra origine Espagne extraite à froid bio', 'not-applicable', null, 'none', '4056489095897'),
  ('PL', 'K-Classic', 'Grocery', 'Oils & Vinegars', 'Extra virgin olive oil', 'not-applicable', 'Kaufland', 'none', '8410660073368'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Olio Extre Vergine Do Oliva Grecale', 'not-applicable', null, 'none', '8018440050129'),
  ('PL', 'Lyttos', 'Grocery', 'Oils & Vinegars', 'Greek Olive Oil', 'not-applicable', null, 'none', '2008080122207'),
  ('PL', 'Eridanous', 'Grocery', 'Oils & Vinegars', 'Öl - Griechisches natives Olivenöl Extra', 'not-applicable', null, 'none', '20706784'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Olio extravergine di oliva', 'not-applicable', null, 'none', '8004123000284'),
  ('PL', 'La PEDRIZA', 'Grocery', 'Oils & Vinegars', 'Aceite de Olive Virgen Extra', 'not-applicable', null, 'none', '8423329113138'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Oliwa z wytloczyn z oliwek', 'not-applicable', null, 'none', '8004123004237'),
  ('PL', 'Goccia d''oro', 'Grocery', 'Oils & Vinegars', 'Olio di Sansa di Oliva', 'not-applicable', null, 'none', '8003250000129'),
  ('PL', 'Neféli', 'Grocery', 'Oils & Vinegars', 'Extra Virgin Olive Oil', 'not-applicable', null, 'none', '5203447760055'),
  ('PL', 'Kaufland', 'Grocery', 'Oils & Vinegars', 'Bio oliwa z oliwek', 'not-applicable', null, 'none', '8410660073306'),
  ('PL', 'Salvadori', 'Grocery', 'Oils & Vinegars', 'Olio Di Sansa Di Oliva Salvadori', 'not-applicable', null, 'none', '8008460223139'),
  ('PL', 'Font Oliva', 'Grocery', 'Oils & Vinegars', 'Olive Oil', 'not-applicable', null, 'none', '8424536944157'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Pedriza extra virgin olive oil', 'not-applicable', null, 'none', '8423329113121'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek extra vergine al basilico', 'not-applicable', null, 'none', '8004123004664'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Oliwa z oliwek extra vergine al rosmarino', 'not-applicable', null, 'none', '8004123004909'),
  ('PL', 'Ollineo', 'Grocery', 'Oils & Vinegars', 'Ollineo Öl', 'not-applicable', null, 'none', '5712872292470'),
  ('PL', 'Monini', 'Grocery', 'Oils & Vinegars', 'Aceto di vino blanco 7,1 %', 'not-applicable', null, 'none', '80054627'),
  ('PL', 'JCCoinbra II', 'Grocery', 'Oils & Vinegars', 'Olej z pestek winogron. Rafinowany', 'not-applicable', null, 'none', '5601855579021'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Peanut oil', 'not-applicable', null, 'none', '8004123007306'),
  ('PL', 'Sottile Gusto', 'Grocery', 'Oils & Vinegars', 'Olej z pestek winogron', 'not-applicable', null, 'none', '5601855579007'),
  ('PL', 'Bio Planete', 'Grocery', 'Oils & Vinegars', 'Olej Kokosowy ekologiczny', 'not-applicable', null, 'none', '4260355580572'),
  ('PL', 'Bio planete', 'Grocery', 'Oils & Vinegars', 'Ekologiczny Olej kokosowy virgin', 'not-applicable', null, 'none', '4260355580558'),
  ('PL', 'Foodbroker as', 'Grocery', 'Oils & Vinegars', 'Olej z pestek winogron', 'not-applicable', null, 'none', '8004123002509'),
  ('PL', 'Vilgain', 'Grocery', 'Oils & Vinegars', 'Avocado oil spray', 'not-applicable', null, 'none', '8594199375251'),
  ('PL', 'Basso', 'Grocery', 'Oils & Vinegars', 'Olej z pestek winogron', 'not-applicable', null, 'none', '8004123002721'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Oliwa z Oliwek', 'not-applicable', null, 'none', '5601999400014'),
  ('PL', 'La Espanola', 'Grocery', 'Oils & Vinegars', 'Oliwa Z Oliwek', 'not-applicable', null, 'none', '8410660091416'),
  ('PL', 'Agrelos', 'Grocery', 'Oils & Vinegars', 'Extra Virgin Olive Oil', 'not-applicable', null, 'none', '5200124185620'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Aceite de oliva virgen extra', 'not-applicable', null, 'none', '8437000542445'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Orazio''s olive oil', 'not-applicable', null, 'none', '0720189810190'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Extra Virgin Olive Oil', 'not-applicable', null, 'none', '0062273551283'),
  ('PL', 'Unknown', 'Grocery', 'Oils & Vinegars', 'Huile de coco', 'not-applicable', null, 'none', '3160920774126')
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
where country = 'PL' and category = 'Oils & Vinegars'
  and is_deprecated is not true
  and product_name not in ('Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'Wyborny olej słonecznikowy', 'Wielkopolski olej słonecznikowy rafinowany', 'Wielkopolski olej rzepakowy tłoczony tylko raz, rafinowany.', 'Ocet ryżowy', 'Bartek olej słonecznikowy', 'Olej rzepakowy z pierwszego tłoczenia, filtrowany', 'Olej rzepakowy z pierwszego tłoczenia', 'Olej rzepakowy tłoczony na zimno', 'Ocet ryżowy', 'Ocet ryżowy', 'Olej z ryżu', 'Olej wyborny', 'Polski olej rzepakowy', 'Wyborny olej rzepakowy', 'Olej rzepakowy pomidor czosnek bazylia', 'Olej rzepakowy', 'Olej wyborny rzepakowy', 'Rafinowany olej rzepakowy', 'Olej kokosowy, bezzapachowy', 'Olej z prażonego sezamu', 'Optima Cardio', 'Olej kokosowy rafinowany', 'Olej lniany ekologiczny', 'Olej kokosowy', 'Oliwa z oliwek najwyższej jakości z pierwszego tłoczenia', 'Bio Hiszpańska oliwa z oliwek.', 'Sonnenblumen Öl', 'Olej rzepakowy', 'Olej rzepakowy', 'Ocet spirytusowy 10%', 'Krem z octem balsamicznym', 'Ocet spirytusowy 10%', 'Olej 3 ziarna', 'Kujawski czosnek bazylia', 'Olej z awokado z pierwszego tłoczenia', 'Olej', 'Ekologiczny Olej Kokosowy', 'Orzeszki z pieca', 'Olej lniany', 'Olej kokosowy', 'Wyborny Delio', 'Olej z pestek dyni', 'Oil', 'Olej kokosowy', 'Naturalny olej konopny', 'Olej kokosowy rafinowany', 'Olej Kokosowy', 'Olej kokosowy Bio', 'Olej kokosowy bezzapachowy rafinowany', 'Olej z czarnuszki', 'Przyprawa Maggi', 'Olive Oil', 'Olej rzepakowy zwyczajny', 'Oliwa z oliwek z pierwszego tłoczenia', 'Olej z ryżu 100%', 'Olej z ryżu', 'Pudliszki', 'Extra Virgin Olive Oil', 'Oliwa z oliwek', 'Huile d''olive vierge extra', 'Casa de Azeite', 'Auchan huile d''olive extra vierge verre 0.75l pack b', 'Sonnenblumenöl', 'Sonnenblumenöl', 'Huile De Tournesol', 'Rapsöl', 'Olej rzepakowy', 'Rapsöl', 'Huile de Colza', 'Olej rzepakowy', 'Vinagre de arroz', 'Olej kokosowy', 'Huile pour friture', 'Oliwa z oliwek', 'Olive Oil', 'Huile d''olive vierge extra origine Espagne extraite à froid bio', 'Extra virgin olive oil', 'Olio Extre Vergine Do Oliva Grecale', 'Greek Olive Oil', 'Öl - Griechisches natives Olivenöl Extra', 'Olio extravergine di oliva', 'Aceite de Olive Virgen Extra', 'Oliwa z wytloczyn z oliwek', 'Olio di Sansa di Oliva', 'Extra Virgin Olive Oil', 'Bio oliwa z oliwek', 'Olio Di Sansa Di Oliva Salvadori', 'Olive Oil', 'Pedriza extra virgin olive oil', 'Oliwa z oliwek extra vergine al basilico', 'Oliwa z oliwek extra vergine al rosmarino', 'Ollineo Öl', 'Aceto di vino blanco 7,1 %', 'Olej z pestek winogron. Rafinowany', 'Peanut oil', 'Olej z pestek winogron', 'Olej Kokosowy ekologiczny', 'Ekologiczny Olej kokosowy virgin', 'Olej z pestek winogron', 'Avocado oil spray', 'Olej z pestek winogron', 'Oliwa z Oliwek', 'Oliwa Z Oliwek', 'Extra Virgin Olive Oil', 'Aceite de oliva virgen extra', 'Orazio''s olive oil', 'Extra Virgin Olive Oil', 'Huile de coco');
